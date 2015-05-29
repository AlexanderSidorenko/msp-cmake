###############################################################################
# Author: Alexander Sidorenko                                                 #
# Mail:   <my last name>.<my first name> at google's email service            #
#                                                                             #
# This Source Code Form is subject to the terms of the Mozilla Public         #
# License, v. 2.0. If a copy of the MPL was not distributed with this         #
# file, You can obtain one at http://mozilla.org/MPL/2.0/.                    #
###############################################################################

cmake_minimum_required(VERSION 2.8)

set(CMAKE_TOOLCHAIN_FILE ${CMAKE_CURRENT_SOURCE_DIR}/../msp-toolchain.cmake)

# For some reason CMake would ignore CMAKE_TOOLCHAIN_FILE if there is no project
# in this file.
project(samples C CXX)

add_subdirectory(01_blink_c)
add_subdirectory(02_blink_cpp)
