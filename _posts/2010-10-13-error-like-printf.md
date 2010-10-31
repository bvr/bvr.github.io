---
layout: post
title: Error like printf
perex: >
    Sometimes it is handy to have single function to quit application with an
    error message. Even better when it accepts <code>printf</code> formatting.
category: [C]
tags:
    - printf
    - C
    - exit
---
Fortunately it is easy to implement with *stdarg* library and *vfprintf* function
of *stdio*.

{% highlight cpp %}
#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>

void Error(char * format, ...) {
    va_list args;
    va_start(args, format);
    vfprintf(stderr, format, args);
    va_end(args);
    exit(-1);
}
{% endhighlight %}

Example usage:

{% highlight cpp %}
...
FILE *fin = fopen(argv[1],"r");
if(! fin)
    Error("File \"%s\" could not be opened",argv[1]);
{% endhighlight %}
