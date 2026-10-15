;
; 1998-06-06, Ullrich von Bassewitz
; 2015-09-11, Greg King
;
; void __fastcall__ longjmp (jmp_buf buf, int retval);
;

        .export         _longjmp
        .import         popptr1
        .importzp       c_sp, ptr1, ptr2

_longjmp:
        sta     ptr2            ; Save retval
        stx     ptr2+1
        ora     ptr2+1          ; Check for 0
        bne     @L1
        inc     ptr2            ; 0 is illegal, according to the standard ...
                                ; ... and, must be replaced by 1
@L1:    jsr     popptr1         ; get buf
        ; ldy     #0            is guaranteed by popptr1

; Get the old parameter stack

        lda     (ptr1),y
        iny
        sta     c_sp
        lda     (ptr1),y
        iny
        sta     c_sp+1

; Get the old stack pointer

.ifp816
        ; In native mode, S is 16 bits wide. TCS copies B and A to it.
        iny
        lda     (ptr1),y        ; high byte
        xba
        dey
        lda     (ptr1),y        ; low byte
        tcs
        iny
        iny
.else
        lda     (ptr1),y
        iny
        tax
        txs
.endif

; Get the return address and push it on the stack

        lda     (ptr1),y
        iny
        pha
        lda     (ptr1),y
        pha

; Load the return value and return to the caller

        lda     ptr2
        ldx     ptr2+1
        rts
