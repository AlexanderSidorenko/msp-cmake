/******************************************************************************
* Author: Alexander Sidorenko                                                 *
* Mail:   <my last name>.<my first name> at google's email service            *
*                                                                             *
* This Source Code Form is subject to the terms of the Mozilla Public         *
* License, v. 2.0. If a copy of the MPL was not distributed with this         *
* file, You can obtain one at http://mozilla.org/MPL/2.0/.                    *
******************************************************************************/

// A "Hello world" for an MCU - blinks an LED attached to pin 0 of port 1
// (as on Launchpad)

#include <msp430.h>

int main(void)
{
    volatile int i;

    // Stop watchdog timer
    WDTCTL = WDTPW | WDTHOLD;

    // Set up pin 0 of port 1 as output
    P1DIR = 0x01;

    // Intialize pin 0 of port 1 to 0
    P1OUT = 0x00;

    // Loop forever
    for (;;)
    {
        // Toggle pin 0 of port 1
        P1OUT ^= 0x01;
        // Delay for a while
        for (i = 0; i < 0x6000; i++);
    }
}
