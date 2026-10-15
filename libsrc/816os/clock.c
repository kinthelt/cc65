/*
** clock_t clock (void);
**
** The kernel counts timer ticks since boot, but only hands out the low 16
** bits. Extend them here. This only works if clock() is called at least
** once every 65536 ticks (about five and a half minutes).
*/



#include <time.h>
#include <816os.h>



clock_t clock (void)
{
    static unsigned long high;
    static unsigned last;
    unsigned now = os816_ticks ();

    if (now < last) {
        high += 0x10000UL;
    }
    last = now;
    return high | now;
}
