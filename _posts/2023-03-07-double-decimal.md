---
layout: post
title: Double vs Decimal
published: yes
tags:
  - C#
  - .NET
  - float
  - double
  - decimal
  - Floating-point types
  - Data Types
---
I was recently asked about floating point data types, so I did a little analysis on differences between them. Here is a little table to summarize the properties of each popular type. Obviously largest benefit of `decimal` type is that it is 10-based, so it does not loose precision in numbers like 0.1, which are periodic in 2-based `double`.

|               | float       | double        | decimal      |
|---------------|-------------|---------------|--------------|
| **Size**      | 4 bytes     | 8 bytes       | 16 bytes     |
| **Range**     | ±1.5 x 10<sup>−45</sup> .. ±3.4 x 10<sup>38</sup> | ±5.0 × 10<sup>−324</sup> .. ±1.7 × 10<sup>308</sup> | ±1.0 x 10<sup>-28</sup> .. ±7.9228 x 10<sup>28</sup> |
| **Precision** | ~6-9 digits | ~15-17 digits | 28-29 digits |
| **Form**      | ± (1 + F/2<sup>23</sup>) x 2<sup>E-127</sup><br>F = 23 bit uint<br>E = 8 bit uint | ± (1 + F/2<sup>52</sup>) x 2<sup>E-1023</sup><br>F = 52 bit uint<br>E = 11 bit uint | ± V/10<sup>X</sup><br>V = 96 bit uint<br>X = 0 .. 28 |
| **.NET Type** | [System.Single](https://learn.microsoft.com/en-us/dotnet/api/system.single)       | [System.Double](https://learn.microsoft.com/en-us/dotnet/api/system.double)         | [System.Decimal](https://learn.microsoft.com/en-us/dotnet/api/system.decimal) |
