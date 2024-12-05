---
layout: post
title: slicing in Python
published: yes
tags:
  - python
  - slice
  - list
  - range
  - icecream
---
I was recently looking at some solutions for [Advent Of Code][3]. I usually like solutions in python, although it often takes some time to understand how it works. 

One part that I needed to look up was expression

```python
d[::-1]
```

I was aware of array slices, but as I don't use python too often, I don't remember the notation. Here are results of brief study on the subject.

The basic slice notation uses square brackets and colons as separator like this:

```python
a[start:stop:step]    # start through, but not past stop, by step
```

The step is optional and defaults to one. It can be also negative, taking items from the end of the array.

Indexes as usual start from zero. Similar to perl approach, the indexes can be also negative, counting from the end of the sequence.

Some examples:

```python
from icecream import ic

a = range(1, 11)

# range
ic(a)                           # ic| a: range(1, 11)

# convert to list
ic(list(a))                     # ic| list(a): [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]            
ic(list(a[:]))                  # ic| list(a[:]): [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]

# individual items
ic(a[0])                        # ic| a[0]: 1
ic(a[1])                        # ic| a[1]: 2
ic(a[-2])                       # ic| a[-2]: 9
ic(a[-1])                       # ic| a[-1]: 10

# slice start:stop
ic(list(a[2:5]))                # ic| list(a[2:5]): [3, 4, 5]
ic(list(a[0:5]))                # ic| list(a[0:5]): [1, 2, 3, 4, 5]
ic(list(a[0:-1]))               # ic| list(a[0:-1]): [1, 2, 3, 4, 5, 6, 7, 8, 9]
ic(list(a[:-2]))                # ic| list(a[:-2]): [1, 2, 3, 4, 5, 6, 7, 8]
ic(list(a[2:]))                 # ic| list(a[2:]): [3, 4, 5, 6, 7, 8, 9, 10]

# stepping
ic(list(a[::2]))                # ic| list(a[::2]): [1, 3, 5, 7, 9]
ic(list(a[::-1]))               # ic| list(a[::-1]): [10, 9, 8, 7, 6, 5, 4, 3, 2, 1]
ic(list(a[::-2]))               # ic| list(a[::-2]): [10, 8, 6, 4, 2]

# two lists joined - skip the element 5
ic(list(a[:5]) + list(a[6:]))   # ic| list(a[:5]) + list(a[6:]): [1, 2, 3, 4, 5, 7, 8, 9, 10]
```

Few extra notes - the slices are also writable, you can assign empty list to remove the slice from the sequence or a sequence that will replace the slice.

As slicing is allowed only for indexable sequences the following data structures can use them:

- list
- tuple
- bytearray
- string
- range
- byte sequences

It is very concise and useful operation.

[1]: https://docs.python.org/3/library/functions.html#slice
[2]: https://docs.python.org/3/library/itertools.html#itertools.islice
[3]: https://adventofcode.com/
