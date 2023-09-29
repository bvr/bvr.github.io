---
layout: post
title: Capture STDOUT/ERR
published: yes
tags:
  - perl
  - Capture::Tiny
  - output
  - console
---
There is very useful utility I use very often - [Capture::Tiny][1]. It takes almost anything sent to STDOUT and STDERR in a code block. This is very useful for any kind of logging, for example

```perl

use Capture::Tiny qw(capture_merged);

my $output = capture_merged { 
    print "Something for STDOUT\n";
    warn "Warning sent to STDERR\n";
    system "robocopy from to /MIR";
};
```

The `capture_merged` will take everything sent to both STDOUT and STDERR. It will be merged into the `$output` variable in roughly same order as printed (it can vary because of buffering, but it does not happen too much on my setup).

Result can be analyzed or logged, whatever is needed.

[1]: https://metacpan.org/pod/Capture::Tiny