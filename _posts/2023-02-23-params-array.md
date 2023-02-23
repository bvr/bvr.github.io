---
layout: post
title: Parameter array
published: yes
tags:
  - C#
  - params
  - Parameter array
---
Parameter arrays allow to provide variable number of parameters to supply to a method. It starts with `params` keyword and must be last parameter. An example might be `Console.WriteLine` method

```c#
public class Console
{
    public static void WriteLine(String format, params Object[] arg) { ... }
}
```

In the method, the behavior is exactly same as with any other array. However it allows two different calling styles

```c#
Console.WriteLine("Format: {0}, {1}", x, y);
object[] args = new object[] { x, y };
Console.WriteLine("Format: {0}, {1}", args);
```

If you look into [Reference Source for Console class][1] it shows number of methods for common use-cases. This is because the params array gets created every time the method is called and can be inefficient in some tight loops or other heavy duty scenarios.

[1]: https://referencesource.microsoft.com/#mscorlib/system/console.cs,f907d79481da6ba4