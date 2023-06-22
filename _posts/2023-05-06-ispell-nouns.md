---
layout: post
title: ispell nouns
published: yes
tags:
  - python
  - ispell
  - itertools
  - fileinput
  - re
  - named group
  - regex
---
I am working on a small Hangman game that allows to guess words. Part of the problem is to find good czech language dictionary that I can use as an input. Searching of the internet for text-based dictionaries I found [ispell Czech dictionary][1] that looks good for my purpose.

Since I am trying to get more orientation in python world, I tried to use it to find suitable words. My primary requirements were:

 - take nouns
 - longer than 8 characters
 - keep accents

The **ispell** format is pretty simple, just plain text in utf-8 encoding. On each line, there can be number of words separated by space, optionally followed by slash and some flags that denote the suffix of the word. In some cases, there is also way to expand number of prefixes for the word. For example

```
aeroplán/H
aféra/ZQ
afinita/ZQ
{a,in,post,pre,su}fix/H
{a,bezpre,in,post,pre,su}fixový/YKR
aforismus/Q
aforistický/YCRN
afrikáta/ZQ
...
baba/ZQ babi
{,pra,prapra}bába/ZQ bábi
{,pra,prapra}bábin/Y
{,pra,prapra}babiččin/Y
{,pra,prapra}babička/ZQ
babin/Y
babí/Y
babizna/ZQ
```

In the script I tried to use number of techniques. Core of the functionality is generator function `ispell_entries` that parses ispell lines and lazily produces entries as tuple of the word and its flags. On top of building the generator with `yield` command, I also tried [regular expressions][3] including the verbose syntax that allows to make the patterns more readable. Another nice thing is named capture groups with `(?P<name> ... )` syntax.

The entries are then filtered through `longer_noun` function that allows only flags I am interested in and longer words. Final part is printing only first few hundreds of words via `islice` function from [itertools][2]

```python
import fileinput
from itertools import islice
import re

def ispell_entries(file):
    for line in file:
        # each line can contain multiple entries - "blána/Z blanou blan blanám blanách blanami"
        for entry in line.rstrip().split(' '):
            word, sep, flags = entry.partition('/')

            # handle format like {a,in,post,pre,su}fix
            match = re.search(r' \{ (?P<prefix> .*? ) \} (?P<rest> .* )$', word, re.VERBOSE)
            if match:
                for prefix in match.group('prefix').split(','):
                    yield prefix + match.group('rest'), flags
            else:
                yield word, flags

def longer_noun(entry):
    word, flags = entry
    if not re.search(r'[HQXZPI]', flags):
        return False
    return len(word) >= 8

input = fileinput.input(encoding="utf-8")
for entry in islice(filter(longer_noun, ispell_entries(input)), 200):
    print(entry[0])
```

The script accepts `.cat` files on command-line, here is the output I got from using `hlavni.cat` input file

```
abdikace
abnormalita
absentér
absentismus
absolutismus
abstinence
abstrakce
absurdita
acetylén
adaptace
adjektivum
administrativa
administrátor
admiralita
viceadmirál
adresátka
advokacie
...
```

[1]: https://github.com/tvondra/ispell_czech
[2]: https://docs.python.org/3/library/itertools.html
[3]: https://docs.python.org/3/library/re.html
