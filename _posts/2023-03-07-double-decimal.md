---
layout: post
title: Double vs Decimal
published: yes
tags:
  - C#
  - float
  - double
  - decimal
  - Floating-point types
  - Data Types
---
I was recently asked about floating point data types, so I did a little analysis on differences between them. 

|Feature|float|double|decimal|
|---|---|---|---|
|Size|4 bytes|8 bytes|16 bytes|
|Range|±1.5 x 10^−45 to ±3.4 x 10^38|±5.0 × 10^−324 to ±1.7 × 10^308|±1.0 x 10^-28 to ±7.9228 x 10^28|
|Precision|~6-9 digits|~15-17 digits|28-29 digits|
|Form|± (1 + F/2^23) x 2^(E-127)<br>where F ... 23 bit uint| E ... 8 bit uint|± (1 + F/2^52) x 2^(E-1023)<br>where F ... 52 bit uint| E ... 11 bit uint|± V/10^X<br>where V ... 96 bit uint| X ... 0 .. 28|
|.NET Type|[System.Single](https://learn.microsoft.com/en-us/dotnet/api/system.single)|[System.Double](https://learn.microsoft.com/en-us/dotnet/api/system.double)|[System.Decimal](https://learn.microsoft.com/en-us/dotnet/api/system.decimal)|
