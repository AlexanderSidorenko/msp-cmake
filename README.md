MSP CMAKE
---------
Low-power **MSP** microcontrollers (**MSP430** and recently introduced **MSP432**) from **TI** are awesome! They are really easy to get started with. **Code Composer Studio** IDE from **TI** will help you to get started, but can feel cumbersome at times.
That's why I decided to create an alternative build system for **MSP** microcontrollers using **CMake**.

**CMake** is a cross-platform build system that doesn't build software, but rather produces input files for other build systems. **CMake** is able to generate build files on different platforms (**Linux**, **Windows**, **Mac OS**) and for different build systems (**Makefiles**, **NMake**, **Visual Studio**, **XCode**, etc.).
So if you want to build your project from command line or use IDEs other than **CCS**, **MSP CMake** is here to help.

**MSP CMake** supports different toolchains; so far only **TI's proprietary toolchain** and **MSPGCC** are supported, but **MSP CMake** can be easily extended.

FEATURES
--------
* Supports different toolchains. Currently supported:
  - **TI's proprietary toolchain**
  - **MSPGCC** and **GDB**
* Supports variety of **MSP430*** MCUs
* Automatically detects required tools, if installed under common path (e.g. `C:\TI`).
* Generates `upload_<EXECUTABLE_NAME>` target to upload firmware
* Supports multiple operating systems: **Linux**, **Windows**, **Mac OS**.
* Can output input files for many build systems: **Make**, **NMake**, **Visual Studio**, **XCode**.

REQUIREMENTS
------------
* Common:
  - `CMake` 2.8 or higher - http://www.cmake.org/download/
* **TI's proprietary toolchain**:
  - `Code Composer Studio` - http://www.ti.com/tool/ccstudio-msp
  - `MSPFlasher` - command line tool to upload firmware - http://www.ti.com/tool/msp430-flasher
* **MSPGCC toolchain**:
  - **Windows**
    + `MSPGCC` - tested with **TI**'s distribution - http://www.ti.com/tool/msp430-gcc-opensource
    + `GDB` - comes with **TI**'s `MSPGCC`
    + `GDB Proxy` (also known as `GDB Agent`) - comes with **TI**'s `MSPGCC`
  - **Linux**
    + `gcc-msp430` - available in standard Ubuntu repository - http://packages.ubuntu.com/precise/gcc-msp430
    + `mspdebug` - available in standard Ubuntu repository - http://packages.ubuntu.com/source/precise/electronics/mspdebug

FEEDBACK
--------
Project is hosted on GitHub:

https://github.com/AlexanderSidorenko/msp-cmake

Feedback and contributions are welcome!

LICENSE
-------
This Source Code Form is subject to the terms of the Mozilla Public License, v. 2.0. If a copy of the MPL was not distributed with this file, You can obtain one at http://mozilla.org/MPL/2.0/.

TODO
----
* Test on Mac OS
* Test with build systems other than `make`/`nmake`
* Add ability to configure serial port that is used to upload
* Test for **MSP432**
* Make upload tool an option

USING MSP CMAKE
---------------
**MSP CMake** comes with a few samples that you can find under `samples` folder. To compile samples, follow these steps.
**Windows**
```
cd samples\build
cmake -G "NMake Makefiles" ..
nmake
nmake upload_blink_c
```
**Linux**
```
cd samples/build
cmake ..
make
make upload_blink_c
```

If you want to add **MSP CMake** support into your project, follow these steps:

### 1. Specifying toolchain file
**CMake** supports *toolchain files*. *Toolchain file* tells **CMake** where to find compiler (or cross-compiler, in our case). You can specify *toolchain file* on command line:
```
cmake -DCMAKE_TOOLCHAIN_FILE=<path-to-msp-cmake>\msp-toolchain.cmake
```
Or in your `CMakeLists.txt` file, as samples do:
```
set(CMAKE_TOOLCHAIN_FILE <path-to-msp-cmake>\msp-toolchain.cmake)
```
**MSP Cmake** should automatically detect all required dependencies and just magically work.

### 2. Adding MSP executable
To add MSP executable, simply use `add_msp_executable` instead of `add_executable` in your `CMakeLists.txt`:
```
add_msp_executable(<name> arg1 ... argN)
```
The first argument `<name>` is treated as executable name, the rest of arguments are passed through to `add_executable` call.
Here's how sample does it:
```
project(blink_c C)
add_msp_executable(blink_c blink.c)
```
That's it! You are good to go!

### 3. Adding MSP library [optional]
Similar to MSP executable, you can add MSP library. Just use `add_msp_library` instead of `add_library` in your `CMakeLists.txt`. Syntax is similar:
```
add_msp_library(<name> arg1 ... argN)
```
The first argument `<name>` is treated as library name, the rest of arguments are passed through to `add_library` call.

CONFIGURING MSP CMAKE
---------------------
**MSP CMake** has a plenty of options that you can configure. File `msp-config.cmake` has default values for all of them, but you can override options on command line:
```
cmake -DMSP_TOOLCHAIN=ti ..
```
or in your `CMakeLists.txt`:
```
set(MSP_TOOLCHAIN ti)
```
Here's list of options:

|**Name**           |**Value**  |**Description**                                                                                                                                      |
|:------------------|:----------|:----------------------------------------------                                                                                                      |
|**MSP_TOOLCHAIN**  |gcc        |Use **MSP-GCC** toolchain. **Default**.                                                                                                              |
|                   |ti         |Use **TI's proprietary toolchain**.                                                                                                                  |
|**MSP_FAMILY**     |msp430     |Target **MSP430*** family of MCUs. **Default**.                                                                                                      |
|**MSP_MCU**        |msp430g2553|Specific MCU name. This is **default** value, but really any MCU that is supported by toolchain can be used.                                         |
|**MSP_AUTO_UPLOAD**|true       |Automatically upload firmware on every build; `upload_<EXECUTABLE_NAME>` will be added to `ALL`, so it will be executed automatically on every build.|
|                   |false      |Don't automatically upload firmware on build; `upload_<EXECUTABLE_NAME>` will still be generated.                                                    |
|**TI_BASE_DIR**    |`C:\ti`    |Base directory for **TI** software; **default** is `C:\ti` on **Windows**.                                                                           |
