---
layout: post
title: C# documentation comments
published: yes
tags:
  - C#
  - documentation
  - xml
  - Sandcastle
---
There are many approaches to document a code. I really like having some kind of requirements/specification for the problem, then it is very useful to have design notes, documenting what was considered, which option was selected and why, and which option was not selected and why. Then comes documentation of smaller pieces (modules, classes, methods).

Last mentioned in C# is done using documentation comments. 

For [a problem in Advent of Code][2] I was implementing [look-and-say][1] sequence, which is generated iteratively from previous value. In each step it replaces run of same values with number of those and value itself. 

For example (taken from wikipedia):

 - 1 is read off as "one 1" or 11.
 - 11 is read off as "two 1s" or 21.
 - 21 is read off as "one 2, one 1" or 1211.
 - 1211 is read off as "one 1, one 2, two 1s" or 111221.
 - 111221 is read off as "three 1s, two 2s, one 1" or 312211.

Here is the attempt to implement this, documenting each piece with C# documentation XML. First we need to split string into sequence of runs.

```c#
/// <summary>
/// Returns sequences of same characters
/// </summary>
/// <param name="seq">Sequence of characters</param>
/// <returns>Enumerator of sequence of same character</returns>
IEnumerable<string> GetSequences(string seq)
{
    int start = 0, pos = 0;
    while(start < seq.Length)
    {
        while (pos < seq.Length && seq[start] == seq[pos])
            pos++;

        yield return seq.Substring(start, pos - start);
        start = pos;
    }
}
```

Then lets convert those sequences into pairs of length and the character itself.

```c#
/// <summary>
/// Convert sequence to Run Length Encoding (RLE), i.e. pairs of chars -- count of chars and char itself
/// </summary>
/// <param name="seq">Sequence of numbers</param>
/// <returns>Encoded sequence</returns>
string Convert(string seq)
{
    StringBuilder sb = new StringBuilder();
    foreach(string s in GetSequences(seq))
    {
        sb.Append(s.Length);
        sb.Append(s[0]);
    }
    return sb.ToString();
}
```

That would make one iteration, but we will need to repeat it number of times.

```c#
/// <summary>
/// Repeat the operation specified number of times, using result of previous iteration as input to the next
/// </summary>
/// <typeparam name="T">Type of the operation</typeparam>
/// <param name="rep">Number of repetitions</param>
/// <param name="op">Operation to transform the data</param>
/// <param name="init">Initial value for first iteration</param>
/// <returns>Result of last iteration</returns>
T Repeat<T>(int rep, Func<T, T> op, T init)
{
    T proc = init;
    for (int i = 0; i < rep; i++)
        proc = op(proc);
    return proc;
}
```

Here is some testing code, to make sure the implementation is correct.

```c#
Assert.AreEqual("11", Convert("1"));
Assert.AreEqual("1211", Convert("21"));
Assert.AreEqual("111221", Convert("1211"));
Assert.AreEqual("312211", Convert("111221"));
Assert.AreEqual(492982, Repeat(40, Convert, input).Length);
Assert.AreEqual(6989950, Repeat(50, Convert, input).Length);
```

This approach would provide number of benefits

 1. It is easier to come back to the methods and get idea what it does
 2. Tools like Visual Studio will help you with parameters
 3. When there are variants of parameters, you can document difference between them
 4. It is possible to generate nice documentation with tools like [Sandcastle][3]

Summary of all XML tags to use can be found in [Annex D of C# specification][4].

[1]: https://en.wikipedia.org/wiki/Look-and-say_sequence
[2]: https://adventofcode.com/2015/day/10
[3]: http://ewsoftware.github.io/SHFB/html/bd1ddb51-1c4f-434f-bb1a-ce2135d3a909.htm
[4]: https://learn.microsoft.com/en-us/dotnet/csharp/language-reference/language-specification/documentation-comments
