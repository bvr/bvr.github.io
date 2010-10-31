---
layout: post
title: Address alignment
category: [C]
tags:
  - C
  - address
  - alignment
---
During recent work on analysis of ELF (Executable and Linkable Format) file
format I needed implement proper alignment of data in sections.

### How it should look like

address	| binary | aligned to 4B  | binary 
-------:|-------:|---------------:|-------:
0       |    0   | 0              |   00   
1       |    1   | 4              |  100   
2       |   10   | 4              |  100   
3       |   11   | 4              |  100   
4       |  100   | 4              |  100   
5       |  101   | 8              | 1000   
6       |  110   | 8              | 1000   
7       |  111   | 8              | 1000   
8       | 1000   | 8              | 1000   
9       | 1001   | 12             | 1100   
10      | 1010   | 12             | 1100   
...     |  ...   | ...            |  ...   

Note it always means that aligned address has zeroed part up-to-alignment.
So the code will just add one enough to move after next aligned address and
mask lower bits of result.

### C implementation

{% highlight cpp %}
inline unsigned int align(unsigned int addr, unsigned int align) {
    if(!align) align = 1;       // zero alignment means actually 1 byte
    return (addr + align-1) & ~(align-1);
}

// sample usage
new_addr = align(addr,4);
{% endhighlight %}
