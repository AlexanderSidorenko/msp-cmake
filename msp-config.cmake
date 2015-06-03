###############################################################################
# Author: Alexander Sidorenko                                                 #
# Mail:   <my last name>.<my first name> at google's email service            #
#                                                                             #
# This Source Code Form is subject to the terms of the Mozilla Public         #
# License, v. 2.0. If a copy of the MPL was not distributed with this         #
# file, You can obtain one at http://mozilla.org/MPL/2.0/.                    #
###############################################################################

# This file has default configuration

# Default MSP toolchain. List of supported toolchains:
# msp-gcc       - GNU family of cross-compilers for MSP
# ti            - TI's MSP compiler
set(MSP_DEFAULT_TOOLCHAIN msp-gcc)

# Default MSP family. List of supported MSP families:
# msp430       - MSP430 family of processors
set(MSP_DEFAULT_FAMILY msp430)

# Default MSP MCU. msp430g2553 is what comes with Launchpad, so let it
# be default
set(MSP_DEFAULT_MCU msp430g2553)
