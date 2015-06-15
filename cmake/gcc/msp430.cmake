###############################################################################
# Author: Alexander Sidorenko                                                 #
# Mail:   <my last name>.<my first name> at google's email service            #
#                                                                             #
# This Source Code Form is subject to the terms of the Mozilla Public         #
# License, v. 2.0. If a copy of the MPL was not distributed with this         #
# file, You can obtain one at http://mozilla.org/MPL/2.0/.                    #
###############################################################################

include(CMakeForceCompiler)

# Add compiler into prefix path
if (UNIX)
    list(APPEND CMAKE_PREFIX_PATH /usr/msp430/)

    # On Unix, use mspdebug to upload into MCU
    set(MSPDEBUG_COMMAND_NAME mspdebug)
    find_program(MSPDEBUG_COMMAND_FULL_PATH ${MSPDEBUG_COMMAND_NAME})

    if (NOT MSPDEBUG_COMMAND_FULL_PATH)
        message(WARNING "Can't find ${MSPDEBUG_COMMAND_NAME}! Upload target won't be generated.")
    else()
        # Default specific to mspdebug
        set_variable_if_empty(MSPDEBUG_DRIVER rf2500)
    endif()

elseif(WIN32)
    # Find GCC
    find_software_if_not_set(GCC_PATH "GCC" ${TI_BASE_DIR} "gcc*")

    # Add GCC into prefix path
    list(APPEND CMAKE_PREFIX_PATH ${GCC_PATH})

    set(GDB_COMMAND_NAME msp430-elf-gdb)
    find_program(GDB_COMMAND_FULL_PATH ${GDB_COMMAND_NAME})
    set(GDB_AGENT_COMMAND_NAME gdb_agent_console)
    find_program(GDB_AGENT_FULL_PATH ${GDB_AGENT_COMMAND_NAME})

    # MSP GCC on Windows requires us to explicitly add include directories
    set(GCC_COMMON_FLAGS "${GCC_COMMON_FLAGS} -I\"${GCC_PATH}\\include\"")
    set(GCC_COMMON_FLAGS "${GCC_COMMON_FLAGS} -L\"${GCC_PATH}\\include\"")
endif()

# Set names of compilers; they differ for Windows and Unix.
if(UNIX)
    CMAKE_FORCE_C_COMPILER(msp430-gcc GNU)
    CMAKE_FORCE_CXX_COMPILER(msp430-g++ GNU)
elseif(WIN32)
    CMAKE_FORCE_C_COMPILER(msp430-elf-gcc GNU)
    CMAKE_FORCE_CXX_COMPILER(msp430-elf-g++ GNU)
endif()

set(GCC_COMMON_FLAGS "${GCC_COMMON_FLAGS} -mmcu=${MSP_MCU}")

set(CMAKE_C_FLAGS "${GCC_COMMON_FLAGS}" CACHE STRING "C flags")
set(CMAKE_CXX_FLAGS "${GCC_COMMON_FLAGS} -nodefaultlibs" CACHE STRING "CXX flags")

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

    # TODO This line should have been if (UNIX), but for some reason this variable
    # doesn't get propagated into functions. We only set MSPDEBUG_COMMAND_NAME on UNIX,
    # so let's use it as a way to test if we are on UNIX.
    if (MSPDEBUG_COMMAND_NAME)
        # Generate upload target if we can
        if (MSPDEBUG_COMMAND_FULL_PATH)
            if (MSP_AUTO_UPLOAD)
                set(UPLOAD_TARGET_ALL_FLAG ALL)
            endif()

            add_custom_target(
                upload_${EXECUTABLE_NAME} ${UPLOAD_TARGET_ALL_FLAG}
                ${MSPDEBUG_COMMAND_FULL_PATH} ${MSPDEBUG_DRIVER} \"prog ${ELF_FILE}\" exit
                DEPENDS ${EXECUTABLE_NAME}
                COMMENT "Uploading ${ELF_FILE} into ${MSP_MCU} using ${MSPDEBUG_COMMAND_NAME}")
        endif()
    elseif(GDB_COMMAND_NAME)
        if (NOT GDB_AGENT_FULL_PATH)
            message(WARNING "Can't find ${GDB_AGENT_FULL_PATH}! start_gdb_agent target won't be generated. Please add ${GDB_AGENT_FULL_PATH} into CMAKE_PREFIX_PATH or CMAKE_PROGRAM_PATH to get upload target.")
        else()
            if (NOT TARGET start_gdb_agent)
                add_custom_target(
                    start_gdb_agent
                    START ${GDB_AGENT_FULL_PATH} ${GCC_PATH}\\${MSP_FAMILY}.dat
                    COMMENT "Starting GDB Agent ...")
            endif()
        endif()

        if (NOT GDB_COMMAND_FULL_PATH)
            message(WARNING "Can't find ${GDB_COMMAND_NAME}! Upload target won't be generated. Please add ${GDB_COMMAND_NAME} into CMAKE_PREFIX_PATH or CMAKE_PROGRAM_PATH to get upload target.")
        else()
            add_custom_target(
                upload_and_debug_${EXECUTABLE_NAME} ${UPLOAD_TARGET_ALL_FLAG}
                ${GDB_COMMAND_FULL_PATH} -ex "target remote :55000" -ex "load" ${ELF_FILE}
                DEPENDS ${EXECUTABLE_NAME}
                COMMENT "Uploading ${ELF_FILE} into ${MSP_MCU} and starting debugging using ${GDB_COMMAND_NAME}")
        endif()
    endif()

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
