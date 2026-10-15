;
; Ullrich von Bassewitz, 19.03.2001
;
; Stack checking code. These are actually two routines, one to check the C
; stack, and the other one to check the 6502 hardware stack.
;
; 816os version: each process's hardware stack is HWSTACK_SIZE bytes in
; bank 0, wherever the kernel put it, and S is 16 bits wide.
; For performance reasons (to avoid having to pass a parameter), the compiler
; calls the cstkchk routine *after* allocating space on the stack. So the
; stackpointer may already be invalid if this routine is called. In addition
; to that, pushs and pops that are needed for expression evaluation are not
; checked (this would be way too much overhead). As a consequence we will
; operate using a safety area at the stack bottom. Once the stack reaches this
; safety area, we consider it an overflow, even if the stack is still inside
; its' bounds.
;

        .export         stkchk, cstkchk
        .constructor    initstkchk, 25
        .import         __STACKSIZE__                   ; Linker defined
        .import         pusha0, _exit
        .importzp       c_sp

        .include        "816os.inc"

HWSAFETY        = 128           ; Safety zone for the hardware stack

        ; Use macros for better readability
        .macpack        generic


; ----------------------------------------------------------------------------
; Initialization code. This is a constructor, so it is called on startup if
; the linker has detected references to this module.

.segment        "ONCE"

.proc   initstkchk

        lda     c_sp
        sta     initialsp
        sub     #<__STACKSIZE__
        sta     lowwater
        lda     c_sp+1
        sta     initialsp+1
        sbc     #>__STACKSIZE__
.if .cap(CPU_HAS_INA)
        ina                     ; Add 256 bytes safety area
.else
        add     #1              ; Add 256 bytes safety area
.endif
        sta     lowwater+1

; The hardware stack. S is near the top of the process's stack now: only the
; kernel's return address and the startup code's calls are above it. Leave a
; safety area for the interrupt frame and the kernel services, which run on
; the caller's stack.

        rep     #$20
        .a16
        tsc
        sta     initialhw
        sec
        sbc     #HWSTACK_SIZE - HWSAFETY
        sta     lowhw
        sep     #$20
        .a8
        rts

.endproc

; ----------------------------------------------------------------------------
; Hardware stack checking routine. Does not need to save any registers.

.code

stkchk: rep     #$10
        .i16
        tsx
        cpx     lowhw
        sep     #$10
        .i8
        bcc     HwStackOverflow ; Jump on stack overflow
        rts                     ; Return if ok

; Hardware stack overflow. Reset the stack pointer, so the exit code (which
; calls C code) has room to run.

HwStackOverflow:
        rep     #$20
        .a16
        lda     initialhw
        tcs
        sep     #$20
        .a8
        bra     Fail

; ----------------------------------------------------------------------------
; C stack checking routine. Does not need to save any registers.

.code

cstkchk:

; Check the high byte of the software stack

@L0:    lda     lowwater+1
        cmp     c_sp+1
        bcs     @L1
        rts

; Check low byte

@L1:    bne     CStackOverflow
        lda     lowwater
        cmp     c_sp
        bcs     CStackOverflow
Done:   rts

; We have a C stack overflow. Set the stack pointer to the initial value, so
; we can continue without worrying about stack issues.

CStackOverflow:
        lda     initialsp
        sta     c_sp
        lda     initialsp+1
        sta     c_sp+1

; Generic abort entry. We should output a diagnostic here, but this is
; difficult, since we're operating at a lower level here.

Fail:   lda     #4
        ldx     #0
        jmp     _exit

; ----------------------------------------------------------------------------
; Data

.segment        "INIT"

; Initial stack pointer value. Stack is reset to this in case of overflows to
; allow program exit processing.
initialsp:      .res    2

; Stack low water mark.
lowwater:       .res    2

; Initial hardware stack pointer value, and its low water mark.
initialhw:      .res    2
lowhw:          .res    2



