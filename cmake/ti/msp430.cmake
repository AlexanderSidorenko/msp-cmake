###############################################################################
# Author: Alexander Sidorenko                                                 #
# Mail:   <my last name>.<my first name> at google's email service            #
#                                                                             #
# This Source Code Form is subject to the terms of the Mozilla Public         #
# License, v. 2.0. If a copy of the MPL was not distributed with this         #
# file, You can obtain one at http://mozilla.org/MPL/2.0/.                    #
###############################################################################

# Some constants
set(TI_BASE_DIR "C:\\ti")
set(MSPFLASH_COMMAND_NAME msp430flasher)
set(MSPHEX_COMMAND_NAME hex430)

# Find CCS
if (NOT CCS_PATH)
    message(STATUS "CCS_PATH is not set, looking for Code Composer Studio (CCS) under \"${TI_BASE_DIR}\"...")
    get_last_subdir(${TI_BASE_DIR} "ccs*" ALL_CCS_VERSIONS LATEST_CCS_VERSION)
    set(CCS_PATH ${TI_BASE_DIR}\\${LATEST_CCS_VERSION})
    if (CCS_PATH AND EXISTS ${CCS_PATH})
        message(STATUS "Auto-detected CCS under \"${CCS_PATH}\". Please set CCS_PATH to point to CCS base dir (e.g. \"C:\\ti\\ccsv6\") if you want to use different version of CCS.")
    else()
        message(FATAL_ERROR "Could not find CCS under \"${TI_BASE_DIR}\". Please install CCS or set CCS_PATH to point to CCS base dir (e.g. \"C:\\ti\\ccsv6\").")
    endif()
else()
    if (CCS_PATH AND EXISTS ${CCS_PATH})
        message(STATUS "CCS_PATH is set, using CCS installation under \"${CCS_PATH}\"")
    else()
        message(FATAL_ERROR "CCS_PATH is set, but \"${CCS_PATH}\" doesn't exist!")
    endif()
endif()

set(CCS_ALL_COMPILERS_PATH ${CCS_PATH}\\tools\\compiler)

# Choose what version of compiler to use
if (NOT CCS_COMPILER_VERSION)
    message(STATUS "CCS_COMPILER_VERSION is not set, auto-selecting compiler version...")
    get_last_subdir(${CCS_ALL_COMPILERS_PATH} "msp430_*" ALL_COMPILER_VERSIONS LATEST_COMPILER_VERSION)
    set(CCS_COMPILER_PATH ${CCS_ALL_COMPILERS_PATH}\\${LATEST_COMPILER_VERSION})
    if (CCS_COMPILER_PATH AND EXISTS ${CCS_COMPILER_PATH})
        message(STATUS "Auto-selected TI compiler \"${CCS_COMPILER_PATH}\". Please set CCS_COMPILER_VERSION (e.g. msp430_4.3.5) if you want to use different version of TI compiler. Versions found: \"${ALL_COMPILER_VERSIONS}\".")
    else()
        message(FATAL_ERROR "Could not find any TI compilers under \"${CCS_ALL_COMPILERS_PATH}\". Please install TI compiler.")
    endif()
else()
    set(CCS_COMPILER_PATH ${CCS_ALL_COMPILERS_PATH}\\${CCS_COMPILER_VERSION})
    if (CCS_COMPILER_PATH AND EXISTS ${CCS_COMPILER_PATH})
        message(STATUS "CCS_COMPILER_VERSION is set, using TI compiler \"${CCS_COMPILER_PATH}\"")
    else()
        message(FATAL_ERROR "CCS_COMPILER_VERSION is set, but \"${CCS_COMPILER_PATH}\" doesn't exist!")
    endif()
endif()

# Add compiler into prefix path
list(APPEND CMAKE_PREFIX_PATH ${CCS_COMPILER_PATH})

# Find installation of ${MSPFLASH_COMMAND_NAME}, if present
get_last_subdir(${TI_BASE_DIR} "MSP430Flasher*" ALL_MSPFLASH_VERSIONS LATEST_MSPFLASH_VERSION)
set(MSPFLASH_INSTALLATION ${TI_BASE_DIR}\\${LATEST_MSPFLASH_VERSION})
if (MSPFLASH_INSTALLATION)
    message(STATUS "Found \"${MSPFLASH_COMMAND_NAME}\" installation under \"${MSPFLASH_INSTALLATION}\"...")
endif()

find_program(MSPFLASH_COMMAND_FULL_PATH ${MSPFLASH_COMMAND_NAME} PATHS ${MSPFLASH_INSTALLATION})
if (NOT MSPFLASH_COMMAND_FULL_PATH)
    message(WARNING "Can't find ${MSPFLASH_COMMAND_NAME}! Upload target won't be generated. Please add ${MSPFLASH_COMMAND_NAME} into CMAKE_PREFIX_PATH or CMAKE_PROGRAM_PATH to get upload target.")
endif()

find_program(MSPHEX_FULL_PATH ${MSPHEX_COMMAND_NAME})
if (NOT MSPHEX_FULL_PATH)
    message(WARNING "Can't find ${MSPHEX_COMMAND_NAME}! Upload target won't be generated. Please add ${MSPHEX_COMMAND_NAME} into CMAKE_PREFIX_PATH or CMAKE_PROGRAM_PATH to get upload target.")
endif()

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

    set(OUT_FILE ${EXECUTABLE_NAME}_${MSP_MCU_UPPER}.out)
    set(TXT_FILE ${EXECUTABLE_NAME}_${MSP_MCU_UPPER}.txt)

    add_executable(${EXECUTABLE_NAME} ${ARGN})

    set_target_properties(${EXECUTABLE_NAME} PROPERTIES OUTPUT_NAME ${OUT_FILE})

    if (MSPHEX_FULL_PATH AND MSPFLASH_COMMAND_FULL_PATH)
        # Run conversion
        add_custom_command(
            TARGET ${EXECUTABLE_NAME}
            POST_BUILD
            COMMAND
                ${MSPHEX_FULL_PATH} --ti_txt -o ${TXT_FILE} ${OUT_FILE}
            COMMENT "Converting ${OUT_FILE} into TI TXT file ${TXT_FILE}")

        if (MSP_AUTO_UPLOAD)
            set(UPLOAD_TARGET_ALL_FLAG ALL)
        endif()

        add_custom_target(
            upload_${EXECUTABLE_NAME} ${UPLOAD_TARGET_ALL_FLAG}
            ${MSPFLASH_COMMAND_FULL_PATH} -w ${TXT_FILE} -z [VCC]
            DEPENDS ${EXECUTABLE_NAME}
            COMMENT "Uploading ${TXT_FILE} into ${MSP_MCU} using ${MSPFLASH_COMMAND_NAME}")
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
