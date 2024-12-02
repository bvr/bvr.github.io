---
layout: post
title: Building Graphviz
published: yes
tags:
  - graphviz
  - cmake
  - Visual Studio
---

 - [Mastering CMake][1]
 - Get Visual Studio Build Tools 2022 with C++ development module (CMake et all)
 - Get Graphviz from https://gitlab.com/graphviz/graphviz.git
 - Run `git submodule update --init` in the root of checkout directory (takes long time)
 - Run `cmake -DCMAKE_INSTALL_PREFIX=program_files -B build -S .` in the root of Graphviz directory
 - If there are any problems (wrong dependency detected or something similar), `git clean -d -f -x` cleans up all the caches
 - Run `cmake --build build`
 - Run `cmake --install build`



[1]: https://cmake.org/cmake/help/book/mastering-cmake/index.html