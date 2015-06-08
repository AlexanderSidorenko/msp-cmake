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
