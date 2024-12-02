---
layout: post
title: Devel::DumpTrace
published: yes
tags:
  - perl
  - Devel::Trace
  - Devel::DumpTrace
---
Sometimes it is useful to see how your program is unfolding. If the debugging is not an option because the process is running on server or it is running for long time and you have no idea where is the problem, you can use tracing of program. It basically means printing out every line executed.

In perl, there is core module [Devel::Trace][1] for such purpose. Let's say we have following program to implement recursive `factorial` function:

```perl
use Function::Parameters;

print factorial(5);

fun factorial($n) {
    return 1 if $n <= 1;
    return $n * factorial($n - 1);
}
```

Then we can run it as:

    perl -d:Trace fact.pl

The output is like this:

```
>> fact.pl:4: print factorial(5);
>> fact.pl:6: fun factorial($n) {
>> fact.pl:6: fun factorial($n) {
>> fact.pl:7:     return 1 if $n <= 1;
>> fact.pl:8:     return $n * factorial($n - 1);
>> fact.pl:6: fun factorial($n) {
>> fact.pl:6: fun factorial($n) {
>> fact.pl:7:     return 1 if $n <= 1;
>> fact.pl:8:     return $n * factorial($n - 1);
>> fact.pl:6: fun factorial($n) {
>> fact.pl:6: fun factorial($n) {
>> fact.pl:7:     return 1 if $n <= 1;
>> fact.pl:8:     return $n * factorial($n - 1);
>> fact.pl:6: fun factorial($n) {
>> fact.pl:6: fun factorial($n) {
>> fact.pl:7:     return 1 if $n <= 1;
>> fact.pl:8:     return $n * factorial($n - 1);
>> fact.pl:6: fun factorial($n) {
>> fact.pl:6: fun factorial($n) {
>> fact.pl:7:     return 1 if $n <= 1;
>> fact.pl:9: }120
```

This is already quite handy and useful, but we cannot see values of variables and parameters, which makes analysis a bit difficult. Fortunately there is also a module [Devel::DumpTrace][2]. With similar usage it outputs also all values:

    perl -d:DumpTrace fact.pl

The output is as follows:

```
>>>   fact.pl:4:[__top__]:      print factorial(5);
>>>   fact.pl:6:[factorial]:    fun factorial($n:undef) {
>>>   fact.pl:6:[factorial]:    fun factorial($n:5) {
>>>   fact.pl:7:[factorial]:    return 1 if $n:5 <= 1;
>>>   fact.pl:8:[factorial]:    return $n:5 * factorial($n:5 - 1);
>>>   fact.pl:6:[factorial]:    fun factorial($n:undef) {
>>>   fact.pl:6:[factorial]:    fun factorial($n:4) {
>>>   fact.pl:7:[factorial]:    return 1 if $n:4 <= 1;
>>>   fact.pl:8:[factorial]:    return $n:4 * factorial($n:4 - 1);
>>>   fact.pl:6:[factorial]:    fun factorial($n:undef) {
>>>   fact.pl:6:[factorial]:    fun factorial($n:3) {
>>>   fact.pl:7:[factorial]:    return 1 if $n:3 <= 1;
>>>   fact.pl:8:[factorial]:    return $n:3 * factorial($n:3 - 1);
>>>   fact.pl:6:[factorial]:    fun factorial($n:undef) {
>>>   fact.pl:6:[factorial]:    fun factorial($n:2) {
>>>   fact.pl:7:[factorial]:    return 1 if $n:2 <= 1;
>>>   fact.pl:8:[factorial]:    return $n:2 * factorial($n:2 - 1);
>>>   fact.pl:6:[factorial]:    fun factorial($n:undef) {
>>>   fact.pl:6:[factorial]:    fun factorial($n:1) {
>>>   fact.pl:7:[factorial]:    return 1 if $n:1 <= 1;
>>>   fact.pl:9:[__top__]:
120
```

It can also quite nicely print arrays and other more complex structures. Let's take an example:

```perl
my $array   = [1 .. 10];
my $complex = {
    name     => 'Rodrigo',
    age      => 12,
    lives_at => {
        street => 'Cactus Rd',
        number => 10,
        city   => 'Wichita'
    }
};

print $complex->{name};
while (my $first = shift @$array) {
    print $first;
}
```

When run as 

    perl -d:DumpTrace array_hash.pl

We get this:

```
>>>>> array_hash.pl:1:[__top__]:        my $array:[1,2,3,4,5,6,7,8,9,10]   = [$.:0==1 .. 10];
>>>>> array_hash.pl:2:[__top__]:        my $complex:{'age'=>12;'name'=>'Rodrigo';'lives_at'=>{'city'=>'Wichita';'number'=>10;'street'=>'Cactus Rd'}} = {
>>>   array_hash.pl:12:[__top__]:       print $complex:{'age'=>12;'name'=>'Rodrigo';'lives_at'=>{'city'=>'Wichita';'number'=>10;'street'=>'Cactus Rd'}}->{name};
>>>>> array_hash.pl:13:[__top__]:       while (my $first:1 = shift @$array:[1,2,3,4,5,6,7,8,9,10]) {
>>>   array_hash.pl:14:[__top__]:       print $first:1;
>>>>> array_hash.pl:14:[__top__]:       WHILE: (my $first:3 = shift @$array:[3,4,5,6,7,8,9,10])
                                        print $first:2;
>>>>> array_hash.pl:14:[__top__]:       WHILE: (my $first:4 = shift @$array:[4,5,6,7,8,9,10])
                                        print $first:3;
>>>>> array_hash.pl:14:[__top__]:       WHILE: (my $first:5 = shift @$array:[5,6,7,8,9,10])
                                        print $first:4;
>>>>> array_hash.pl:14:[__top__]:       WHILE: (my $first:6 = shift @$array:[6,7,8,9,10])
                                        print $first:5;
>>>>> array_hash.pl:14:[__top__]:       WHILE: (my $first:7 = shift @$array:[7,8,9,10])
                                        print $first:6;
>>>>> array_hash.pl:14:[__top__]:       WHILE: (my $first:8 = shift @$array:[8,9,10])
                                        print $first:7;
>>>>> array_hash.pl:14:[__top__]:       WHILE: (my $first:9 = shift @$array:[9,10])
                                        print $first:8;
>>>>> array_hash.pl:14:[__top__]:       WHILE: (my $first:10 = shift @$array:[10])
                                        print $first:9;
>>>>> array_hash.pl:14:[__top__]:       WHILE: (my $first:10 = shift @$array:[])
                                        print $first:10;
```

At times it can be very useful.

[1]: https://metacpan.org/pod/Devel::Trace
[2]: https://metacpan.org/pod/Devel::DumpTrace
