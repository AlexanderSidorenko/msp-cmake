###############################################################################
# Author: Alexander Sidorenko                                                 #
# Mail:   <my last name>.<my first name> at google's email service            #
#                                                                             #
# This Source Code Form is subject to the terms of the Mozilla Public         #
# License, v. 2.0. If a copy of the MPL was not distributed with this         #
# file, You can obtain one at http://mozilla.org/MPL/2.0/.                    #
###############################################################################

include(CMakeForceCompiler)

# Defaults specific for GCC
if (NOT MSPDEBUG_DRIVER)
    set(MSPDEBUG_DRIVER rf2500)
    message(STATUS "MSPDEBUG_DRIVER is not defined, defaulting to ${MSPDEBUG_DRIVER}")
endif()

set(MSPDEBUG_COMMAND_NAME mspdebug)
find_program(MSPDEBUG_COMMAND_FULL_PATH ${MSPDEBUG_COMMAND_NAME})

if(UNIX)
    set(CMAKE_FIND_ROOT_PATH /usr/msp430/)
endif()

CMAKE_FORCE_C_COMPILER(msp430-gcc GNU)
CMAKE_FORCE_CXX_COMPILER(msp430-g++ GNU)

set(CMAKE_C_FLAGS "-mmcu=${MSP_MCU}" CACHE STRING "C flags")
set(CMAKE_CXX_FLAGS "-mmcu=${MSP_MCU} -nodefaultlibs" CACHE STRING "CXX flags")

###############################################################################
# add_msp_executable                                                          #
#                                                                             #
# Creates target to build an MSP executable and adds an additional target to  #
# upload it into MCU. If MSP_AUTO_UPLOAD is set to TRUE, upload command will  #
# be added to ALL and therefore executed automatically.                       #
###############################################################################
function(add_msp_executable EXECUTABLE_NAME)
    if (NOT ARGN)
        message(FATAL_ERROR "List of source files for target ${EXECUTABLE_NAME} is empty")
    endif()

    set(ELF_FILE ${EXECUTABLE_NAME}_${MSP_MCU_UPPER}.elf)

    add_executable(${EXECUTABLE_NAME} ${ARGN})

    set_target_properties(${EXECUTABLE_NAME} PROPERTIES OUTPUT_NAME ${ELF_FILE})

    if (MSP_AUTO_UPLOAD)
        set(UPLOAD_TARGET_ALL_FLAG ALL)
    endif()

    add_custom_target(
        upload_${EXECUTABLE_NAME} ${UPLOAD_TARGET_ALL_FLAG}
        ${MSPDEBUG_COMMAND_FULL_PATH} ${MSPDEBUG_DRIVER} \"prog ${ELF_FILE}\" exit
        DEPENDS ${EXECUTABLE_NAME}
        COMMENT "Uploading ${ELF_FILE} into ${MSP_MCU} using ${MSPDEBUG_COMMAND_NAME}")

endfunction(add_msp_executable)

###############################################################################
# add_msp_library                                                             #
#                                                                             #
# Creates targets to build an MSP library. Just calling add_library for now,  #
# but we want users to take dependency on this function in case we need to    #
# do some extra work for libraries in the future.                             #
###############################################################################
function(add_msp_library LIBRARY_NAME)
    if (NOT ARGN)
        message(FATAL_ERROR "List of source files for target ${LIBRARY_NAME} is empty")
    endif()

    add_library(${LIBRARY_NAME} ${ARGN})

endfunction(add_msp_library)
