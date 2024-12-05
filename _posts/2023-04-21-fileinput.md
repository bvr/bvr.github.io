---
layout: post
title: fileinput
published: yes
tags:
  - python
  - fileinput
  - input
  - argparse
  - dict
  - strip
  - rstrip
  - split
  - filelineno
---
There is a little helper in python to iterate number of files - [fileinput][1]. By default it takes files specified on command-line or stdin. Basic usage is something like this

```python
import fileinput

for line in fileinput.input():
    print(fileinput.filename() + "[" + str(fileinput.filelineno()) + "]:" + line.rstrip())
```

When run as 

```
python t1.py a.txt b.txt
```

It prints out each line of those files as sequence, each line preceded by current filename and line number

```
a.txt[1]:Lorem ipsum dolor sit amet consectetur adipisicing elit. Aliquid nam nobis itaque ab voluptatem consequuntur at commodi
a.txt[2]:atque consectetur. Sapiente sit, expedita doloribus non dolores sed? Et assumenda aspernatur delectus.
a.txt[3]:Placeat delectus dolore exercitationem, vero adipisci officia excepturi cumque beatae fugiat enim odit eveniet nesciunt
a.txt[4]:numquam aliquam iusto perspiciatis sit at tenetur eos provident facilis quisquam? Ducimus earum totam et.
b.txt[1]:Adipisicing elit. Corrupti dolorem, repellendus natus impedit iure nulla
b.txt[2]:molestias. Quod vel ratione earum? Nesciunt corrupti, veritatis reiciendis suscipit nam enim inventore quaerat deleniti?
b.txt[3]:Magni dolores minima vel voluptas non dolore harum eveniet quia maxime illum velit voluptatibus, quo nam, deleniti iure
```

The module can be also very useful for quickly loading the file into list comprehension and into other structure

```python
import fileinput

sizes = dict([line.strip().split("\t") for line in fileinput.input()])
print(sizes)
```

Code like this loads file with tab-separated names and sizes into a dictionary. Consider the data

| **Filename**         | **Size** |
| -------------------- | -------- |
| args.py              | 670      |
| czech-stemmer.pl     | 1734     |
| firefox.pl           | 838      |
| iterator.pl          | 323      |
| porter.pl            | 7311     |
| re-debug.pl          | 727      |
| repeated-regex.pl    | 155      |
| section-numbering.tt | 1053     |
| skyline.pl           | 3327     |

The `sizes` dictionary will look like this

```python
{'porter.pl': '7311', 'firefox.pl': '838', 're-debug.pl': '727', 
'czech-stemmer.pl': '1734', 'iterator.pl': '323', 'args.py': '670', 
'section-numbering.tt': '1053', 'skyline.pl': '3327', 'repeated-regex.pl': '155'}
```

Building on [previous post]({% post_url 2023-04-14-argparse %}) it can be also combined with [argparse][2]

```python
import fileinput
import argparse

cli = argparse.ArgumentParser(prog = 'generator', description = 'Builds summary spreadsheet')
cli.add_argument('--safety',   help = 'safety requirements file. Default: %(default)s', default = 'safety.xls')
cli.add_argument('-v', '--verbose', help = 'verbose output', action='store_true')
cli.add_argument('files', metavar='FILE', nargs='*', help='files to read, if empty, stdin is used')

args = cli.parse_args()

for line in fileinput.input(files=args.files):
    print(fileinput.filename() + "[" + str(fileinput.filelineno()) + "]:" + line.rstrip())
```


[1]: https://docs.python.org/3.8/library/fileinput.html
[2]: https://docs.python.org/3/library/argparse.html
