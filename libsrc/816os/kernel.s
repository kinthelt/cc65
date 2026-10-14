;
; 816os kernel services, callable from C. See 816os.h.
;
; cc65 code runs with 8-bit registers. The services keep the caller's
; register widths, so most of them can be called as they are.
;

        .export         _os816_putc, _os816_getc, _os816_puts
        .export         _os816_yield, _os816_getpid, _os816_ticks
        .export         _os816_load, _os816_save, _os816_exec
        .import         popeax
        .importzp       sreg

        .include        "816os.inc"

.code

; void __fastcall__ os816_putc (char c);

_os816_putc:
        jsl     K_PUTC
        rts

; int os816_getc (void);

_os816_getc:
        jsl     K_GETC
        bcc     @none
        ldx     #0
        rts
@none:  lda     #$FF
        tax
        rts

; void __fastcall__ os816_puts (const char* s);
; K_PUTS takes the address in a 16-bit accumulator.

_os816_puts:
        pha
        txa
        xba                     ; high byte to B
        pla                     ; low byte to A
        rep     #$20
        .a16
        jsl     K_PUTS
        sep     #$20
        .a8
        rts

; void os816_yield (void);

_os816_yield:
        jsl     K_YIELD
        rts

; unsigned char os816_getpid (void);

_os816_getpid:
        jsl     K_GETPID
        ldx     #0
        rts

; unsigned os816_ticks (void);
; With an 8-bit accumulator, the high byte comes back in B.

_os816_ticks:
        jsl     K_TICKS
        xba
        tax                     ; high byte
        xba                     ; low byte
        rts

; unsigned char __fastcall__ os816_load (unsigned long addr);
; K_LOAD takes the address of a 3-byte table in the data bank.

_os816_load:
        sta     addr
        stx     addr+1
        lda     sreg
        sta     addr+2
        rep     #$20
        .a16
        lda     #addr
        jsl     K_LOAD
        sep     #$20            ; Doesn't change the carry
        .a8
        bra     return_carry

; unsigned char __fastcall__ os816_save (unsigned long addr,
;                                        unsigned long count);
; K_SAVE takes the addresses of two 3-byte tables in the data bank.

_os816_save:
        sta     count
        stx     count+1
        lda     sreg
        sta     count+2
        jsr     popeax
        sta     addr
        stx     addr+1
        lda     sreg
        sta     addr+2
        rep     #$30
        .a16
        .i16
        lda     #addr
        ldx     #count
        jsl     K_SAVE
        sep     #$30            ; Doesn't change the carry
        .a8
        .i8
        bra     return_carry

; unsigned char __fastcall__ os816_exec (unsigned char bank);

_os816_exec:
        jsl     K_EXEC

; Return the carry as 0 or 1.

return_carry:
        lda     #0
        tax
        rol     a
        rts

.bss

addr:   .res    3
count:  .res    3
