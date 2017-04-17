# osx-razer-blade
Userland console application to control lights on Razer Blade that are running a Hackintosh (macOS on a non-Apple device).

The tool is currently a proof of concept and is intended for use by developers. The Razer driver logic was ported from the Linux project, https://github.com/terrycain/razer-drivers/.

Xcode is needed to build and run this project.

Usage:
1. Clone the repo
2. Edit the `razer_attr_write_mode_breath` line (in main.m) with your own effect (see header file in razer_knd.h).
3. Build and run the project.

This project unless otherwise stated in the file is licensed under the GPLv2 license.
