---
layout: post
title: Named groups in C# regex
published: yes
tags:
  - C#
  - Regex
  - named group
  - IgnoreCase
---
I like feature for named group captures as I used in [post about ispell parsing]({% post_url 2023-05-06-ispell-nouns %}). Recently I worked on a program in C# and was wondering if this is supported by .net Regex implementation. 

It turned out it is:

```c#
static Regex syntax = new Regex(@"(?<command>toggle|turn off|turn on) (?<x1>\d+),(?<y1>\d+) through (?<x2>\d+),(?<y2>\d+)");

public search()
{
    // ...
    Match found = syntax.Match(line);
    if (!found.Success)
        throw new Exception($"Invalid format {line}");

    Console.WriteLine(found.Groups["command"].Value);
    // ...
}
```

As seen above, the format is `(?<name>group regex)` and `.Groups` property of the `Match` allows specify both number (starting from 1 counting opening brace from left) and string with name of the group.

I was also looking for a way to specify case-insensitive regex without the `RegexOptions.IgnoreCase` option. This is useful if the regex is specified in a configuration and we might want to have insensitive match.

```c#
Regex r1 = new(@"hello", RegexOptions.IgnoreCase);
Regex r2 = new(@"(?i)hello");
```

Both examples used above are equivalent, just the second one marks exact start of the insensitiveness and can be also ended with `(?-i)`.
