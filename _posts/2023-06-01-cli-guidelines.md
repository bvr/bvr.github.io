---
layout: post
title: CLI Guidelines
published: yes
tags:
  - CLI
  - Guideline
  - jq
  - pager
  - less
  - help
  - output
  - xml
---
Here are my notes from [Command Line Interface Guidelines][1] web site. I really like the summary and it opened various interesting points. Will try to incorporate those ideas into my command line programs.

![Command Line Interface Guidelines](/img/cli-guidelines.png)

 - movement from machine-first to human-first approach. From necessity to utility
 - UNIX philosophy - small, simple programs with clean interfaces can be combined to build larger system
 - conversation as a norm. The exchange with the CLI can be seen as conversation

## Key basic points

 - use standard library to keep CLI parsing consistent
 - return zero exit code on success, non-zero on failure
 - send output to `stdout`
 - send messaging into `stderr` so even when piping, the messages will be visible to users

## Help

 - display when passed no options, `-h` flag or the `--help` flag
 - use concise and advanced help
 - lead with examples, easy to copy/paste and start with
 - for advanced help, show web page (easy to search and copy from)

## Output

 - human-readable output is paramount, but make it machine-readable where it does not impact usability
 - expect the output of every program to become input to another program
 - it is good idea to provide option to produce structured output (json, yaml, or xml). There is number of tools like [jq][2] or [xq][3] to process and filter such output. Nice example is `svn` logs produced in XML that I utilized in [this post]({% post_url 2022-12-23-svn-logs %})
 - report state changes and make sure user knows what is going on
 - suggest commands the user can use
 - check whether tty is used and possibly use extended features like colors
 - for longer output pager is good idea (for instance `less -FIRX` is good default). This is generally not available on Windows

## Errors

 - make sure the error output is reasonable for user
 - make it easy to submit error report (an url with pre-filled information can help)

## Arguments and flags

 - provide long version for all flags. They are much more readable in the scripts
 - make sure arguments support globbing like `*.txt`
 - if there is a standard, use it. Common flags can be
   - `-a`, `--all`: All. For example, ps, fetchmail.
   - `-d`, `--debug`: Show debugging output.
   - `-f`, `--force`: Force. For example, rm -f will force the removal of files, even if it thinks it does not have permission to do it. This is also useful for commands which are doing something destructive that usually require user confirmation, but you want to force it to do that destructive action in a script.
   - `--json`: Display JSON output.
   - `-h`, `--help`: Help. This should only mean help.
   - `-o`, `--output`: Output file. For example, sort, gcc.
   - `-p`, `--port`: Port. For example, psql, ssh.
   - `-q`, `--quiet`: Quiet. Display less output. This is particularly useful when displaying output for humans that you might want to hide when running in a script.
   - `-u`, `--user`: User. For example, ps, ssh, mysql.
   - `--version`: Version.
 - confirm before doing anything dangerous
 - do not read secrets from flags, they will be visible in process list and shell history. Prefer taking secrets from files only

[1]: https://clig.dev/
[2]: https://jqlang.github.io/jq/
[3]: https://github.com/kislyuk/yq
