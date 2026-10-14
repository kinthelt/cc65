;
; CC65 runtime: call function via pointer in ptr4
;

        .export         callptr4
        .importzp       ptr4
.ifp816
        .import         jmpvec
.endif

callptr4:

.ifp816

; On the 65816, "jmp (abs)" reads its pointer from bank 0 without adding the
; direct page register, so it can't use a zero page pointer. Go through the
; jump vector in the data segment instead, keeping A, X and Y.

        pha
        lda     ptr4
        sta     jmpvec+1
        lda     ptr4+1
        sta     jmpvec+2
        pla
        jmp     jmpvec          ; jump there

.else

        jmp     (ptr4)          ; jump there

.endif
