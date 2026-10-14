/*
** int __fastcall__ read (int fd, void* buf, unsigned count);
**
** Reads from the console a line at a time, like a terminal in canonical
** mode: characters are echoed, Backspace and Delete erase the last one, and
** Return ends the line, which reads back with '\n' at the end. Ctrl-D on an
** empty line is end-of-file. Only the foreground process gets input, so a
** background process waits here until it is brought to the foreground.
*/



#include <errno.h>
#include <unistd.h>
#include <816os.h>



#define LINE_SIZE       128

static char line[LINE_SIZE];
static unsigned char len;       /* Characters in line */
static unsigned char pos;       /* Next one to hand out */
static unsigned char lastcr;    /* The last character was CR */



static unsigned char getch (void)
/* Wait for a character */
{
    int c;

    while ((c = os816_getc ()) < 0) {
        os816_yield ();
    }
    return c;
}



static void echo (char c)
{
    os816_con_lock ();
    os816_putc (c);
    os816_con_unlock ();
}



static unsigned char readline (void)
/* Read a line into the buffer. Return 0 on end-of-file. */
{
    unsigned char c;

    pos = len = 0;
    while (1) {
        c = getch ();
        if (c == '\n' && lastcr) {
            /* Second half of a CR LF pair */
            lastcr = 0;
            continue;
        }
        lastcr = (c == '\r');

        if (c == '\r' || c == '\n') {
            line[len++] = '\n';
            os816_con_lock ();
            os816_putc ('\r');
            os816_putc ('\n');
            os816_con_unlock ();
            return 1;
        } else if (c == '\b' || c == 0x7F) {
            if (len) {
                --len;
                os816_con_lock ();
                os816_putc ('\b');
                os816_putc (' ');
                os816_putc ('\b');
                os816_con_unlock ();
            }
        } else if (c == 0x04) {
            /* Ctrl-D: end-of-file on an empty line, else hand out what
            ** has been typed so far, without a newline.
            */
            return len;
        } else if ((c >= ' ' || c == '\t') && len < LINE_SIZE - 1) {
            line[len++] = c;
            echo (c);
        }
    }
}



int __fastcall__ read (int fd, void* buf, unsigned count)
{
    char* p = buf;
    unsigned n = 0;

    if (fd != STDIN_FILENO) {
        errno = EBADF;
        return -1;
    }
    if (count == 0) {
        return 0;
    }
    if (pos == len && !readline ()) {
        return 0;
    }
    while (n < count && pos < len) {
        p[n++] = line[pos++];
    }
    return n;
}
