/*
** unsigned __fastcall__ sleep (unsigned wait);
**
** Gives the CPU to other processes while waiting.
*/



#include <unistd.h>
#include <816os.h>



unsigned __fastcall__ sleep (unsigned wait)
{
    unsigned goal = os816_ticks ();

    while (wait) {
        goal += OS816_TICK_HZ;
        while ((int) (os816_ticks () - goal) < 0) {
            os816_yield ();
        }
        --wait;
    }
    return 0;
}
