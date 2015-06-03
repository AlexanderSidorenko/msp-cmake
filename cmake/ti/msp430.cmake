###############################################################################
# Author: Alexander Sidorenko                                                 #
# Mail:   <my last name>.<my first name> at google's email service            #
#                                                                             #
# This Source Code Form is subject to the terms of the Mozilla Public         #
# License, v. 2.0. If a copy of the MPL was not distributed with this         #
# file, You can obtain one at http://mozilla.org/MPL/2.0/.                    #
###############################################################################

#TODO Try to guess it automatically
if (NOT CCS_PATH)
    message(FATAL_ERROR "Please set CCS_PATH to point to Code Composer Studio root folder (e.g. C:\\ti\\ccsv6).")
    return()
endif()

set(CCS_ALL_COMPILERS_PATH ${CCS_PATH}\\tools\\compiler)

#TODO Try to automatically figure out list of compilers and default to one of them with a warning
if (NOT CCS_COMPILER_VERSION)
    message(FATAL_ERROR "Please set CCS_COMPILER_VERSION (e.g. msp430_4.3.5).")
    return()
endif()

set(CCS_COMPILER_PATH ${CCS_ALL_COMPILERS_PATH}\\${CCS_COMPILER_VERSION})

list(APPEND CMAKE_PREFIX_PATH ${CCS_COMPILER_PATH})

set(CMAKE_C_COMPILER cl430)
set(CMAKE_CXX_COMPILER cl430)

# Both C and C++ compilers share most of options; let's build list of common parameters
# Instruction set: msp vs mspx. It's msp for msp430
set(CL430_COMMON_FLAGS "${CL430_COMMON_FLAGS} --silicon_version=msp")
# Includes
set(CL430_COMMON_FLAGS "${CL430_COMMON_FLAGS} --include_path=${CCS_PATH}\\ccs_base\\msp430\\include")
set(CL430_COMMON_FLAGS "${CL430_COMMON_FLAGS} --include_path=${CCS_COMPILER_PATH}\\include")
# Specific MCU
set(CL430_COMMON_FLAGS "${CL430_COMMON_FLAGS} --define=__${MSP_MCU_UPPER}__")

# TODO: Add debug options
#set(CL430_COMMON_FLAGS "${CL430_COMMON_FLAGS} -g")

set(CMAKE_C_FLAGS "${CL430_COMMON_FLAGS}" CACHE STRING "C flags")
set(CMAKE_CXX_FLAGS "${CL430_COMMON_FLAGS}" CACHE STRING "CXX flags")

# Both C and C++ linkers share most of options; let's build list of common parameters
# Includes - it is required for MCU-specific .cmd file
set(CL430_COMMON_LINK_FLAGS "${CL430_COMMON_LINK_FLAGS} --search_path=${CCS_PATH}\\ccs_base\\msp430\\include")
set(CL430_COMMON_LINK_FLAGS "${CL430_COMMON_LINK_FLAGS} --search_path=${CCS_COMPILER_PATH}\\include")
# Specific MCU
set(CL430_COMMON_LINK_FLAGS "${CL430_COMMON_LINK_FLAGS} --define=__${MSP_MCU_UPPER}__")
# Append standard lib path
set(CL430_COMMON_LINK_FLAGS "${CL430_COMMON_LINK_FLAGS} --search_path=${CCS_COMPILER_PATH}\\lib")
# Run MCU-specific CMD that is provided by TI toolchain
set(CL430_COMMON_LINK_FLAGS "${CL430_COMMON_LINK_FLAGS} -l${MSP_MCU_LOWER}.cmd")
set(CL430_COMMON_LINK_FLAGS "${CL430_COMMON_LINK_FLAGS} --rom_model")

set(CMAKE_C_LINK_FLAGS "${CL430_COMMON_LINK_FLAGS}" CACHE STRING "C link flags")
set(CMAKE_CXX_LINK_FLAGS "${CL430_COMMON_LINK_FLAGS}" CACHE STRING "CXX link flags")
