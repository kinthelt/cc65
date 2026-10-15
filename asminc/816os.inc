;
; 816os definitions
;
; The kernel services, from 816os's include/os816.inc. Call each one with JSL,
; in native mode. They keep the caller's register widths, X, Y, the direct
; page register and the data bank register. A is kept unless the service
; returns a value in it. Services that return 16 bits leave the high byte in
; B when they're called with an 8-bit accumulator.
;

K_PUTC          = $00FFB0       ; A low byte = character
K_GETC          = $00FFB3       ; Carry set: A = character; clear: none waiting
K_PUTS          = $00FFB6       ; A (16 bits) = address of a zero-terminated string
K_YIELD         = $00FFB9       ; Give up the rest of this time slice
K_EXIT          = $00FFBC       ; End this process; doesn't return
K_GETPID        = $00FFBF       ; A = this process's bank number (1-7)
K_TICKS         = $00FFC2       ; A = low 16 bits of the timer tick count
K_CON_LOCK      = $00FFC5       ; Take the console lock (not recursive)
K_CON_UNLOCK    = $00FFC8       ; Release the console lock
K_LOAD          = $00FFCB       ; Receive a file with XMODEM/CRC
K_SAVE          = $00FFCE       ; Send memory as a file with XMODEM/CRC
K_EXEC          = $00FFD1       ; Start the program at $0000 of a bank

TICK_HZ         = 200           ; Timer ticks per second

; Each process's hardware stack, in bank 0
HWSTACK_SIZE    = $0800
