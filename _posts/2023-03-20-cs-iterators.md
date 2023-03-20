---
layout: post
title: C# Enumerators
published: yes
tags:
  - C#
  - Iterator
  - Enumerator
  - LINQ
---
In [previous post]({% post_url 2023-03-18-iterator-simple %}) I discussed how iterators are done in perl. In C# they are called enumerators. Old C# required to create class that provides IEnumerator methods to init and get next item. But since C# version 2 there is very nice interface to generate items in natural way. Following code produces range per specified bounds

```c#
public static IEnumerable<int> GetRange(int from, int to, int step = 1)
{
    for(int i = from; i <= to; i += step) 
        yield return i; 
}
```

The statement `yield return` will make the code return a value and exit from the method. When next item is requested, the code re-enter the loop and produces another value. Iteration itself is easy with `foreach` statement

```c#
foreach(int i in GetRange(1, 10))
    Console.WriteLine(i);
```

For number of tools working with enumerables lazily we can reach LINQ methods. There is 

 - `Select` for transformation of items
 - `Where` for filtering them out
 - `SelectMany` for producing lists from each item
 - `OrderBy` and `ThenBy` for sorting items
 - `Take` and `Skip` for getting only portion of the sequence by number of items
 - `TakeWhile` and `SkipWhile` for portion of sequence by a condition
 - `Concat` for merging enumerables

It is worth remembering that enumerables are not guaranteed to reset, so in many cases they cannot be walked over twice. In such cases it is useful to convert them into something solid using `ToArray` or `ToList` methods.

Another example shows how to make your class enumerable. Suppose you have class around two-dimensional array that allows to transform rectangles of its data (it is something I used to solve [an AoC puzzle][1] with light bulbs)

```c#
class LightArray<T> : IEnumerable<T>
{
    public int Width { get; }
    public int Height { get; }

    public T[,] Array { get; protected set; }

    public LightArray(int width, int height)
    {
        Width = width;
        Height = height;
        Array = new T[Width, Height];
    }

    public void SetRect(int x1, int y1, int x2, int y2, Func<T, T> apply)
    {
        for (int y = y1; y <= y2; y++)
            for (int x = x1; x <= x2; x++)
                Array[x, y] = apply(Array[x, y]);
    }

    public IEnumerator<T> GetEnumerator()
    {
        for (int y = 0; y < Height; y++)
            for (int x = 0; x < Width; x++)
                yield return Array[x, y];
    }

    IEnumerator IEnumerable.GetEnumerator() => GetEnumerator();
}
```

The usage is pretty simple

```c#
LightArray<bool> lights = new LightArray<bool>(1000, 1000);
lights.SetRect(10,10, 50,100, v => true);           // set the rectangle to on
var numSwitchedOn = lights.Count(v => v == true);   // since it is enumerable, just use LINQ method on it
```

[1]: https://adventofcode.com/2015/day/6
