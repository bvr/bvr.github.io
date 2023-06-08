---
layout: post
title: CLI Guidelines
published: no
tags:
  - CLI
  - Guideline
---
Here are notes for [Command Line Interface Guidelines][1] web site.

 - movement from machine-first to human-first approach. From necessity to utility
 - UNIX philosophy - small, simple programs with clean interfaces can be combined to build larger system
 - conversation as a norm. The exchange with the CLI can be seen as conversation

 - key basic points:
   - use standard library to keep CLI parsing consistent
   - return zero exit code on success, non-zero on failure
   - send output to `stdout`
   - send messaging into `stderr` so even when piping, the messages will be visible to users

 - help
   - display when passed no options, `-h` flag or the `--help` flag
   - use concise and advanced help
   - lead with examples, easy to copy/paste and start with
   - for advanced help, show web page (easy to search and copy from)

 - output
   - human-readable output is paramount, but make it machine-readable where it does not impact usability
   - expect the output of every program to become input to another program



[1]: https://clig.dev/
