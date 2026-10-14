;
; Set up arguments for main
;
; 816os doesn't pass arguments to programs, so argc is 0. Point argv at a
; list that holds only the terminating NULL, as the C standard requires.
;

        .constructor    initmainargs, 24
        .import         __argv

.segment        "ONCE"

initmainargs:
        lda     #<argv
        ldx     #>argv
        sta     __argv
        stx     __argv+1
        rts

.rodata

argv:   .addr   0
