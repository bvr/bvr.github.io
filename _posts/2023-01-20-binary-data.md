---
layout: post
title: Store for binary data
published: yes
tags:
  - C#
  - .NET
  - Binary
  - Data
  - Hex Dump
---
For a parser working with binary data I needed handy storage of bytes with following features:

 - provide length of the data
 - allow to add blocks of bytes
 - convert it into byte array
 - allow hexdump for debugging purposes
 - compare with other binary data and store it into dictionaries

Here is the class implementation

```c#
/// <summary>
/// Simple storage for binary data
/// </summary>
public class BinaryData
{
    private List<byte> store;

    public BinaryData()
    {
        store = new List<byte>();
    }

    public BinaryData(byte[] data)
    {
        store = new List<byte>(data);
    }

    /// <summary>
    /// Length of the array
    /// </summary>
    public int Length => (int)store.Count;

    /// <summary>
    /// Add bytes into the array
    /// </summary>
    /// <param name="b"></param>
    public void Append(byte[] b) => store.AddRange(b);

    /// <summary>
    /// Extract the array
    /// </summary>
    /// <returns>Array of bytes</returns>
    public byte[] ToArray() => store.ToArray();

    /// <summary>
    /// Stringify the data as hexdump
    /// </summary>
    /// <returns></returns>
    public override string ToString()
    {
        StringBuilder hex = new StringBuilder();
        for(int i = 0; i < store.Count; i++)
        {
            if (i % 2 == 0)
                hex.Append(" ");
            if (i % 8 == 0)
                hex.Append("\n");
            hex.AppendFormat("{0:x2}", store[i]);
        }
        return hex.ToString().Trim();
    }

    public override bool Equals(object obj)
    {
        return obj is BinaryData data && store.SequenceEqual(data.store);
    }

    public override int GetHashCode()
    {
        int hashCode = -1592726837;
        hashCode = hashCode * -1521134295 + EqualityComparer<List<byte>>.Default.GetHashCode(store);
        return hashCode;
    }
}
```
