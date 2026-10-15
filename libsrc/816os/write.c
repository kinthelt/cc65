/*
** int __fastcall__ write (int fd, const void* buf, unsigned count);
**
** Writes to the console, turning '\n' into CR LF. Holds the console lock
** for the whole call, so other processes' output can't land in the middle.
*/



#include <errno.h>
#include <unistd.h>
#include <816os.h>



int __fastcall__ write (int fd, const void* buf, unsigned count)
{
    const char* p = buf;
    unsigned n = count;

    if (fd != STDOUT_FILENO && fd != STDERR_FILENO) {
        errno = EBADF;
        return -1;
    }

    os816_con_lock ();
    while (n) {
        if (*p == '\n') {
            os816_putc ('\r');
        }
        os816_putc (*p);
        ++p;
        --n;
    }
    os816_con_unlock ();
    return count;
}
