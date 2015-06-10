###############################################################################
# Author: Alexander Sidorenko                                                 #
# Mail:   <my last name>.<my first name> at google's email service            #
#                                                                             #
# This Source Code Form is subject to the terms of the Mozilla Public         #
# License, v. 2.0. If a copy of the MPL was not distributed with this         #
# file, You can obtain one at http://mozilla.org/MPL/2.0/.                    #
###############################################################################

# Sets default value for a variable if it is empty and displays a message
function(set_variable_if_empty VARIABLE_NAME DEFAULT_VALUE)
    if (NOT ${VARIABLE_NAME})
        set(${VARIABLE_NAME} ${DEFAULT_VALUE} PARENT_SCOPE)
        message(STATUS "${VARIABLE_NAME} is not defined, defaulting to ${DEFAULT_VALUE}")
    endif()
endfunction()

# This file has default configuration

# Default MSP toolchain. List of supported toolchains:
# gcc           - GNU family of cross-compilers for MSP
# ti            - TI's MSP compiler
set_variable_if_empty(MSP_TOOLCHAIN gcc)

# Default MSP family. List of supported MSP families:
# msp430       - MSP430 family of processors
set_variable_if_empty(MSP_FAMILY msp430)

# Default MSP MCU. msp430g2553 is what comes with Launchpad, so let it
# be default
set_variable_if_empty(MSP_MCU msp430g2553)

# Don't automatically upload firmware by default
set_variable_if_empty(MSP_AUTO_UPLOAD FALSE)
