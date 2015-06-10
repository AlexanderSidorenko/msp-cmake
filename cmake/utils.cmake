###############################################################################
# Author: Alexander Sidorenko                                                 #
# Mail:   <my last name>.<my first name> at google's email service            #
#                                                                             #
# This Source Code Form is subject to the terms of the Mozilla Public         #
# License, v. 2.0. If a copy of the MPL was not distributed with this         #
# file, You can obtain one at http://mozilla.org/MPL/2.0/.                    #
###############################################################################

# This files has a few useful utility functions/macros

# Lists all subdirectories of ${PARENTDIR} that match ${MASK} and puts the list
# into ${OUT_SUBDIRS}
function(list_subdirs PARENTDIR MASK OUT_SUBDIRS)
    file(GLOB children RELATIVE ${PARENTDIR} ${PARENTDIR}/${MASK})
    set(dirlist "")
    foreach(child ${children})
        if(IS_DIRECTORY ${PARENTDIR}/${child})
            list(APPEND dirlist ${child})
        endif()
    endforeach()
    set(${OUT_SUBDIRS} ${dirlist} PARENT_SCOPE)
endfunction(list_subdirs)

# Invokes list_subdirs with ${PARENTDIR} and ${MASK} and stores result in
# ${OUT_SUBDIRS}. Then list is alphabetically sorted and last subdir in
# the list is stored in ${OUT_LAST_SUBDIR}. If there were no matching
# subdirs, ${OUT_LAST_SUBDIR} will be set to "-NOTFOUND"
function(get_last_subdir PARENTDIR MASK OUT_SUBDIRS OUT_LAST_SUBDIR)
    set(LAST_SUBDIR "-NOTFOUND")
    list_subdirs(${PARENTDIR} ${MASK} SUBDIRS)
    if (SUBDIRS)
        list(GET SUBDIRS -1 LAST_SUBDIR)
    endif()
    set(${OUT_SUBDIRS} ${SUBDIRS} PARENT_SCOPE)
    set(${OUT_LAST_SUBDIR} ${LAST_SUBDIR} PARENT_SCOPE)
endfunction(get_last_subdir)

# If ${SOFTWARE_PATH} is not set, will search (non-recursively) by ${MASK} in
# ${SEARCH_DIR} and return the last one in alphabetically sorted list.
# If ${SOFTWARE_PATH} was set in the first place, it won't be modified. Function
# will display messages (searching/found/not found) about it's progress using
# ${SOFTWARE_NAME} as display name for the software.
function(find_software_if_not_set SOFTWARE_PATH SOFTWARE_NAME SEARCH_DIR MASK)
    if (NOT ${SOFTWARE_PATH})
        message(STATUS "${SOFTWARE_PATH} is not set, looking for ${SOFTWARE_NAME} under \"${SEARCH_DIR}\"...")
        get_last_subdir(${SEARCH_DIR} ${MASK} ALL_SOFTWARE_VERSION LATEST_SOFTWARE_VERSION)
        set(${SOFTWARE_PATH} ${SEARCH_DIR}\\${LATEST_SOFTWARE_VERSION})
        if (${SOFTWARE_PATH} AND EXISTS ${${SOFTWARE_PATH}})
            # So far we have set local scope variable; now need to set parent scope
            set(${SOFTWARE_PATH} ${${SOFTWARE_PATH}} PARENT_SCOPE)
            message(STATUS "Auto-detected ${SOFTWARE_NAME} under \"${${SOFTWARE_PATH}}\". If you want to use different version of ${SOFTWARE_NAME}, please explicitly set ${SOFTWARE_PATH}.")
        else()
            message(FATAL_ERROR "Could not find ${SOFTWARE_NAME} under \"${SEARCH_DIR}\". Please install ${SOFTWARE_NAME} or set ${SOFTWARE_PATH}.")
        endif()
    else()
        if (${SOFTWARE_PATH} AND EXISTS ${${SOFTWARE_PATH}})
            message(STATUS "${SOFTWARE_PATH} is set, using ${SOFTWARE_NAME} installation under \"${${SOFTWARE_PATH}}\"")
        else()
            message(FATAL_ERROR "${SOFTWARE_PATH} is set, but \"${${SOFTWARE_PATH}}\" doesn't exist!")
        endif()
    endif()
endfunction()
