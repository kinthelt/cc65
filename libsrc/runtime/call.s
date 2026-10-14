;
; Ullrich von Bassewitz, 06.08.1998
;
; CC65 runtime: call function via pointer in ax
;

        .export         callax
.ifp816
        .import         jmpvec
.else
        .importzp       ptr1
.endif

.ifp816

; On the 65816, "jmp (abs)" reads its pointer from bank 0 without adding the
; direct page register, so it can't use a zero page pointer. Go through the
; jump vector in the data segment instead.

callax: sta     jmpvec+1
        stx     jmpvec+2
        jmp     jmpvec          ; jump there

.else

callax: sta     ptr1
        stx     ptr1+1
        jmp     (ptr1)          ; jump there

.endif
