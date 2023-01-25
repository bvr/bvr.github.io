---
layout: post
title: Capture Process output
published: yes
tags:
  - C#
  - Process
  - System.Diagnostics
---
Here is little example how to run a command (`dir` in this case) and capture all it outputs to standard output.

```c#
StringBuilder output = new();

Process proc = new();
proc.StartInfo = new()
{
    FileName = "cmd.exe",
    Arguments = "/c dir",
    UseShellExecute = false,    // cannot be used with capturing the output
    CreateNoWindow = true,
    RedirectStandardOutput = true,
};
proc.Start();
proc.WaitForExit();

output.Append(proc.StandardOutput.ReadToEnd());

foreach(string line in output.ToString().Split('\n').Where(line => !line.StartsWith(" ")))
    Console.WriteLine(line);
```

If the command has an executable, there is no need to run it via `cmd`.