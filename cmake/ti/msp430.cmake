###############################################################################
# Author: Alexander Sidorenko                                                 #
# Mail:   <my last name>.<my first name> at google's email service            #
#                                                                             #
# This Source Code Form is subject to the terms of the Mozilla Public         #
# License, v. 2.0. If a copy of the MPL was not distributed with this         #
# file, You can obtain one at http://mozilla.org/MPL/2.0/.                    #
###############################################################################

include(${CMAKE_CURRENT_LIST_DIR}\\..\\shared.cmake)

# Find CCS
find_software_if_not_set(CCS_PATH "Code Composer Studio" ${TI_BASE_DIR} "ccs*")

set(CCS_ALL_COMPILERS_PATH ${CCS_PATH}\\tools\\compiler)

# Choose what version of compiler to use
find_software_if_not_set(CCS_COMPILER_PATH "TI compiler" ${CCS_ALL_COMPILERS_PATH} "msp430_*")

# Add compiler into prefix path
list(APPEND CMAKE_PREFIX_PATH ${CCS_COMPILER_PATH})

upload_with_mspflasher_prerequisites()

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

    upload_with_mspflasher_generate_target(${EXECUTABLE_NAME} ${TXT_FILE} ${OUT_FILE})

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
