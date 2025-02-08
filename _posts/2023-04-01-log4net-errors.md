---
layout: post
title: Different layout for errors 
published: yes
tags:
  - C#
  - .NET
  - log4net
  - logging
  - LevelRangeFilter
  - ConsoleAppender
---
In [post about log4net]({% post_url 2023-01-11-log4net %}) I showed configuration to use to logger to help with debugging, report progress on console and create log in the rolled file. 

I was recently working on a program like this:

```c#
class Program 
{
    private static readonly ILog log = LogManager.GetLogger(MethodBase.GetCurrentMethod().DeclaringType);

    static int Main(string[] args)
    {
        log.Info($"Start parameters: {string.Join(" ", args)}");

        try 
        {
            log.Info($"Loading {inputFile}");
            //...

            log.Info("Processing the data");
            // ...

        }
        catch(Exception e) 
        {
            log.Error(e.Message);
        }
    }
}
```

The report in the log is good as it contains level of the message along with other details:

```
2023-03-31 09:15:27,302 INFO Program - Loading TestData\file.xml
2023-03-31 09:15:27,374 ERROR Program - Deserialization of input XML file failed
```

But on console it does not say anything that the second report is an error. I played a bit with various options and ended with condition for levels and changing the pattern layout for errors and fatals.

```xml
<?xml version="1.0" encoding="utf-8" ?>
<configuration>
  <log4net>
    <root>
      <level value="ALL" />
      <appender-ref ref="console" />
      <appender-ref ref="console_error" />
      <appender-ref ref="debug" />
      <appender-ref ref="file" />
    </root>

    <appender name="console" type="log4net.Appender.ConsoleAppender">
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="%message%newline" />
      </layout>
      <filter type="log4net.Filter.LevelRangeFilter">
        <acceptOnMatch value="true" />
        <levelMin value="DEBUG" />
        <levelMax value="WARN" />
      </filter>
    </appender>

    <appender name="console_error" type="log4net.Appender.ConsoleAppender">
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="Error: %message%newline" />
      </layout>
      <filter type="log4net.Filter.LevelRangeFilter">
        <acceptOnMatch value="true" />
        <levelMin value="ERROR" />
        <levelMax value="FATAL" />
      </filter>
    </appender>

    <appender name="debug" type="log4net.Appender.DebugAppender">
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="%file(%line): %level %message%newline" />
      </layout>
    </appender>

    <appender name="file" type="log4net.Appender.RollingFileAppender">
      <file value="log.txt" />
      <appendToFile value="false" />
      <rollingStyle value="Size" />
      <maxSizeRollBackups value="5" />
      <maximumFileSize value="10MB" />
      <staticLogFileName value="true" />
      <layout type="log4net.Layout.PatternLayout">
        <conversionPattern value="%date %level %logger - %message%newline" />
      </layout>
    </appender>

  </log4net>
</configuration>
```

You can see first two appenders that handle reporting to console, debug appender and rolled logger. All the reporting is done through the `log4net`, the log and console output is consistent and there is no duplication in the program output.
