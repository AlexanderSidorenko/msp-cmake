###############################################################################
# Author: Alexander Sidorenko                                                 #
# Mail:   <my last name>.<my first name> at google's email service            #
#                                                                             #
# This Source Code Form is subject to the terms of the Mozilla Public         #
# License, v. 2.0. If a copy of the MPL was not distributed with this         #
# file, You can obtain one at http://mozilla.org/MPL/2.0/.                    #
###############################################################################

cmake_minimum_required(VERSION 2.8)

include(${CMAKE_CURRENT_LIST_DIR}/msp-config.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/cmake/utils.cmake)

###############################################################################
#              Set defaults if critical variables are not set                 #
###############################################################################
if (NOT MSP_TOOLCHAIN)
    set(MSP_TOOLCHAIN ${MSP_DEFAULT_TOOLCHAIN})
    message(STATUS "MSP_TOOLCHAIN is not defined, defaulting to ${MSP_TOOLCHAIN}")
endif()

if (NOT MSP_FAMILY)
    set(MSP_FAMILY ${MSP_DEFAULT_FAMILY})
    message(STATUS "MSP_FAMILY is not defined, defaulting to ${MSP_FAMILY}")
endif()

if (NOT MSP_MCU)
    set(MSP_MCU ${MSP_DEFAULT_MCU})
    message(STATUS "MSP_MCU is not defined, defaulting to ${MSP_MCU}")
endif()

if (NOT MSP_AUTO_UPLOAD)
    set(MSP_AUTO_UPLOAD ${MSP_DEFAULT_AUTO_UPLOAD})
    message(STATUS "MSP_AUTO_UPLOAD is not defined, defaulting to ${MSP_AUTO_UPLOAD}")
endif()

###############################################################################
#                 Variables common for all toolchains                         #
###############################################################################
set(CMAKE_SYSTEM_NAME Generic)
# Adjust the default behavior of the FIND_XXX() commands:
# Search programs in the host environment
set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)
# Search headers and libraries in the target environment
set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)
set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)

# Produce some useful derivatives
string(TOUPPER ${MSP_MCU} MSP_MCU_UPPER)
string(TOLOWER ${MSP_MCU} MSP_MCU_LOWER)

###############################################################################
#                    MCU family/Toolchain specific                            #
###############################################################################
set (SPECIFIC_TOOLCHAIN_FILE "${CMAKE_CURRENT_LIST_DIR}/cmake/${MSP_TOOLCHAIN}/${MSP_FAMILY}.cmake")

if (NOT EXISTS ${SPECIFIC_TOOLCHAIN_FILE})
    message(FATAL_ERROR "Can't locate specific toolchain file ${SPECIFIC_TOOLCHAIN_FILE} for ${MSP_FAMILY} family of MCUs and ${MSP_TOOLCHAIN} toolchain!")
endif()

# Now let's load CMake file that corresponds to specific MCU family-toolchain
# combination
include (${SPECIFIC_TOOLCHAIN_FILE})
