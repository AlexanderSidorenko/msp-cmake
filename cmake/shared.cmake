###############################################################################
# Author: Alexander Sidorenko                                                 #
# Mail:   <my last name>.<my first name> at google's email service            #
#                                                                             #
# This Source Code Form is subject to the terms of the Mozilla Public         #
# License, v. 2.0. If a copy of the MPL was not distributed with this         #
# file, You can obtain one at http://mozilla.org/MPL/2.0/.                    #
###############################################################################

# Some constants that I don't expect to change often (if ever)
set(MSPFLASHER_COMMAND_NAME msp430flasher)
set(MSPHEX_COMMAND_NAME hex430)

# Shared code to generate upload target using ${MSPFLASHER_COMMAND_NAME}
function(upload_with_mspflasher_prerequisites)
    # Find MSPFlasher
    find_software_if_not_set(MSPFLASHER_PATH "${MSPFLASHER_COMMAND_NAME}" ${TI_BASE_DIR} "MSP430Flasher*")
    find_program(MSPFLASHER_COMMAND_FULL_PATH ${MSPFLASHER_COMMAND_NAME} PATHS ${MSPFLASHER_PATH})
    if (NOT MSPFLASHER_COMMAND_FULL_PATH)
        message(WARNING "Can't find ${MSPFLASHER_COMMAND_NAME}! Upload target won't be generated. Please add ${MSPFLASHER_COMMAND_NAME} into CMAKE_PREFIX_PATH or CMAKE_PROGRAM_PATH to get upload target.")
    else()
        find_program(MSPHEX_FULL_PATH ${MSPHEX_COMMAND_NAME})
        if (NOT MSPHEX_FULL_PATH)
            message(WARNING "Can't find ${MSPHEX_COMMAND_NAME}! Upload target won't be generated. Please add ${MSPHEX_COMMAND_NAME} into CMAKE_PREFIX_PATH or CMAKE_PROGRAM_PATH to get upload target.")
        endif()
    endif()
endfunction()

function(upload_with_mspflasher_generate_target EXECUTABLE_NAME TXT_FILE OUT_FILE)
    if (MSPHEX_FULL_PATH AND MSPFLASHER_COMMAND_FULL_PATH)
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
            ${MSPFLASHER_COMMAND_FULL_PATH} -w ${TXT_FILE} -z [VCC]
            DEPENDS ${EXECUTABLE_NAME}
            COMMENT "Uploading ${TXT_FILE} into ${MSP_MCU} using ${MSPFLASHER_COMMAND_NAME}")
    endif()
endfunction()
