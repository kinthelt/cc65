;
; void os816_con_lock (void);
; void os816_con_unlock (void);
;
; The kernel's console lock isn't recursive: taking it twice waits forever.
; Count the nesting here, so write() can take the lock around its output
; even when the program already holds it.
;

        .export         _os816_con_lock, _os816_con_unlock

        .include        "816os.inc"

.code

_os816_con_lock:
        lda     depth
        bne     @held           ; This process already holds it
        jsl     K_CON_LOCK
@held:  inc     depth
        rts

_os816_con_unlock:
        lda     depth
        beq     @done           ; Not held
        dec     depth
        bne     @done           ; Still held by an outer lock
        jsl     K_CON_UNLOCK
@done:  rts

.bss

depth:  .res    1
