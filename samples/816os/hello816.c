/*
** A first C program for 816os.
**
** Build:  cl65 -t 816os -o hello816.bin hello816.c
** Run:    at the 816os shell, "load 30000", send hello816.bin with XMODEM,
**         then "run 3".
*/



#include <stdio.h>
#include <string.h>
#include <unistd.h>
#include <816os.h>



int main (void)
{
    char name[40];
    unsigned char i;

    printf ("Hello from bank %u!\n", os816_getpid ());

    printf ("What's your name? ");
    if (fgets (name, sizeof name, stdin) == NULL) {
        return 0;
    }
    name[strcspn (name, "\n")] = '\0';

    /* Count down slowly. Other processes keep running while this one
    ** sleeps. Press Ctrl-Z to pause it and return to the shell.
    */
    for (i = 3; i > 0; --i) {
        printf ("%u...\n", i);
        sleep (1);
    }

    /* Keep the whole line together, even if other processes are printing */
    os816_con_lock ();
    printf ("Goodbye, %s. Uptime: %u ticks.\n", name, os816_ticks ());
    os816_con_unlock ();
    return 0;
}
