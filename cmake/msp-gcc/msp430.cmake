###############################################################################
# Author: Alexander Sidorenko                                                 #
# Mail:   <my last name>.<my first name> at google's email service            #
#                                                                             #
# This Source Code Form is subject to the terms of the Mozilla Public         #
# License, v. 2.0. If a copy of the MPL was not distributed with this         #
# file, You can obtain one at http://mozilla.org/MPL/2.0/.                    #
###############################################################################

include(CMakeForceCompiler)
CMAKE_FORCE_C_COMPILER(msp430-gcc GNU)
CMAKE_FORCE_CXX_COMPILER(msp430-g++ GNU)

set(CMAKE_C_FLAGS "-mmcu=${MSP_MCU}" CACHE STRING "C flags")
set(CMAKE_CXX_FLAGS "-mmcu=${MSP_MCU} -nodefaultlibs" CACHE STRING "CXX flags")

if(UNIX)
    set(CMAKE_FIND_ROOT_PATH /usr/lib/gcc/msp430/)
endif()
