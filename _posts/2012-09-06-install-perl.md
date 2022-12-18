---
layout: post
title: perl installation
tags:
  - perl
  - win32
  - activestate
  - install
  - module
---
Steps I am usually take when installing perl on new machine. 

On Windows, I was always going with ActiveState perl. It has worked for me well and I never needed to look elsewhere.

The steps below were just recently tried when I updated to 5.16 release.

 1. Download package from http://activeperl.com ...
 2. If there is previous version installed, make sure to rename or remove its directory. Installing over previous leads to many modules broken. Maybe somthing has changed since I did that, but had never enough courage to try again.
 3. Install downloaded package
 4. Run `ppm upg --install` to upgrade all modules shipped with it to latest version
 5. `ppm inst Moose`, `ppm inst dmake`, `ppm inst mingw`, `ppm inst App-cpanminus`
 6. Ready to work
 7. All missing modules either install with ppm (`ppm inst Module::Name`) or cpanm (`cpanm Module::Name`)
