/*****************************************************************************/
/*                                                                           */
/*                                  816os.h                                  */
/*                                                                           */
/*                     816os system-specific definitions                     */
/*                                                                           */
/*                                                                           */
/*                                                                           */
/* This software is provided 'as-is', without any expressed or implied       */
/* warranty.  In no event will the authors be held liable for any damages    */
/* arising from the use of this software.                                    */
/*                                                                           */
/* Permission is granted to anyone to use this software for any purpose,     */
/* including commercial applications, and to alter it and redistribute it    */
/* freely, subject to the following restrictions:                            */
/*                                                                           */
/* 1. The origin of this software must not be misrepresented; you must not   */
/*    claim that you wrote the original software. If you use this software   */
/*    in a product, an acknowledgment in the product documentation would be  */
/*    appreciated but is not required.                                       */
/* 2. Altered source versions must be plainly marked as such, and must not   */
/*    be misrepresented as being the original software.                      */
/* 3. This notice may not be removed or altered from any source              */
/*    distribution.                                                          */
/*                                                                           */
/*****************************************************************************/



#ifndef _816OS_H
#define _816OS_H



/* Check for errors */
#if !defined(__816OS__)
#  error This module may only be used when compiling for 816os!
#endif



/*****************************************************************************/
/*                                   Data                                    */
/*****************************************************************************/



/* Timer ticks per second, as counted by os816_ticks() */
#define OS816_TICK_HZ   200



/*****************************************************************************/
/*                                   Code                                    */
/*****************************************************************************/



/* These call the 816os kernel services. */

void __fastcall__ os816_putc (char c);
/* Send a character to the console, as is (no newline translation). */

int os816_getc (void);
/* Return the next character received, or -1 if none is waiting. Only the
** foreground process receives input; for any other process this always
** returns -1.
*/

void __fastcall__ os816_puts (const char* s);
/* Send a zero-terminated string to the console, as is. */

void os816_yield (void);
/* Give the rest of this time slice to the next process. */

unsigned char os816_getpid (void);
/* Return this process's bank number (1-7). */

unsigned os816_ticks (void);
/* Return the low 16 bits of the kernel's timer tick count. */

void os816_con_lock (void);
void os816_con_unlock (void);
/* Take and release the console lock. While a process holds the lock, other
** processes' output waits. Unlike the kernel's lock, these calls nest: the
** lock is released by the os816_con_unlock() that matches the first
** os816_con_lock(). write() takes the lock this way for each call, so use
** these functions rather than calling the kernel's K_CON_LOCK yourself.
*/

unsigned char __fastcall__ os816_load (unsigned long addr);
/* Receive a file with XMODEM/CRC over the console into memory, starting at
** the 24-bit address addr. Writes whole 128-byte blocks. Returns 1 on
** success, 0 on failure or cancel, or if this isn't the foreground process.
*/

unsigned char __fastcall__ os816_save (unsigned long addr,
                                       unsigned long count);
/* Send count bytes of memory starting at the 24-bit address addr as a file,
** with XMODEM/CRC. Returns 1 on success, 0 on failure or cancel, or if this
** isn't the foreground process.
*/

unsigned char __fastcall__ os816_exec (unsigned char bank);
/* Start the program at $0000 of bank (1-7) as a new background process.
** Returns 1 if it started, 0 if the bank is out of range or in use.
*/



/* End of 816os.h */
#endif
