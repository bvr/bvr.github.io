---
layout: post
title: Process Timeout
published: yes
tags:
  - C#
  - Process
  - WaitForExit
---
I recently needed to run an unreliable tool that might possibly get stuck. I don't have any control about this process, so if it does not finish in some time, I would like to stop it and try it again.

Turns out there is a parameter available to `WaitForExit` method of the `Process` that allows exactly that. It returns true when the process exited itself, so we can detect that condition and kill it if it is still running.

Here is the code:

```c#
const int timeoutMilliseconds = 2*60*1000;    // 2 minutes

Process process = new()
{
    StartInfo = new ProcessStartInfo
    {
        FileName = "tool.exe",
        Arguments = "something",
    }
};

try
{
    process.Start();
    if (!process.WaitForExit(timeoutMilliseconds))
        process.Kill(entireProcessTree: true);
}
catch (Exception ex)
{
    log.Error($"Error: {ex.Message}");
}
```

This is another example on nice design of the .NET and wide array of options it provides.
