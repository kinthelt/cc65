;
; Startup code for cc65 (816os version)
;
; The kernel copies the program to $0000 of a free bank and starts it there,
; in native mode with 16-bit registers. The data bank register is the
; program's bank, the direct page register points at the process's own
; direct page in bank 0, and the hardware stack is the process's own stack
; in bank 0. Code compiled by cc65 runs with 8-bit registers.
;

        .export         _exit
        .export         __STARTUP__ : absolute = 1      ; Mark as startup
        .import         zerobss, callmain
        .import         initlib, donelib
        .import         __MAIN_START__, __MAIN_SIZE__   ; Linker generated
        .import         __STACKSIZE__                   ; Linker generated

        .include        "zeropage.inc"
        .include        "816os.inc"

        .segment        "STARTUP"

startup:
        sep     #$30            ; 8-bit accumulator and index registers
        .a8
        .i8
        cld

; The C stack grows down from the end of the program's memory.

        lda     #<(__MAIN_START__ + __MAIN_SIZE__ + __STACKSIZE__)
        ldx     #>(__MAIN_START__ + __MAIN_SIZE__ + __STACKSIZE__)
        sta     c_sp
        stx     c_sp+1

        jsr     zerobss         ; The kernel doesn't clear BSS
        jsr     initlib
        jsr     callmain

; Back from main(). This is also exit(). The exit code is dropped: the
; kernel has nowhere to put it.

_exit:  jsr     donelib
        jsl     K_EXIT          ; Doesn't return
