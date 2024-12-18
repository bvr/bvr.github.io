---
layout: post
title: clipboard
published: yes
tags:
  - python
  - windows
  - Clipboard
  - pywin32
  - win32clipboard
  - clipboard
  - perl
  - Win32::Clipboard
---
I wanted to build simple script to get/set data in the clipboard in python. Something similar to what can be achieved with perl script and [Win32::Clipboard][1] module:

```perl
use Win32::Clipboard;

my $clip = Win32::Clipboard();
my $text = join ' ', @ARGV;
$clip->Set($text) if $text;
print $clip->Get();
```

This simply print out the contents of the clipboard to the console and if there are any parameters, it will put them into the clipboard.

In python, I found following ways to do such operation:

 - with `ctypes`
 - with `pywin32`
 - with `clipboard`

Lets look on each of them in more detail.

## ctypes

The [ctypes][2] is a library that allows to interoperate with foreign DLLs. In our case, we use Windows libraries `user32` and `kernel32` to access the clipboard. I gathered the examples below from StackOverflow and other internet sources and I placed them here for the study purposes. 

The `ctypes` is included in python distribution and thus can be quite cheap solution that does not need to install any dependencies.

```python
import sys
import ctypes

def get_clipboard():
    CF_TEXT = 1
    ctypes.windll.user32.OpenClipboard(0)
    try:
        if ctypes.windll.user32.IsClipboardFormatAvailable(CF_TEXT):
            data = ctypes.windll.user32.GetClipboardData(CF_TEXT)
            data_locked = ctypes.windll.kernel32.GlobalLock(data)
            text = ctypes.c_char_p(data_locked)
            value = text.value
            ctypes.windll.kernel32.GlobalUnlock(data_locked)
            return value
    finally:
        ctypes.windll.user32.CloseClipboard()

def set_clipboard(text):
    CF_TEXT = 1
    GMEM_DDESHARE = 0x2000
    ctypes.windll.user32.OpenClipboard(0)
    ctypes.windll.user32.EmptyClipboard()
    try:
        # works on Python 2 (bytes() only takes one argument)
        hCd = ctypes.windll.kernel32.GlobalAlloc(GMEM_DDESHARE, len(bytes(text))+1)
    except TypeError:
        # works on Python 3 (bytes() requires an encoding)
        hCd = ctypes.windll.kernel32.GlobalAlloc(GMEM_DDESHARE, len(bytes(text, 'ascii'))+1)
    pchData = ctypes.windll.kernel32.GlobalLock(hCd)
    try:
        # works on Python 2 (bytes() only takes one argument)
        ctypes.cdll.msvcrt.strcpy(ctypes.c_char_p(pchData), bytes(text))
    except TypeError:
        # works on Python 3 (bytes() requires an encoding)
        ctypes.cdll.msvcrt.strcpy(ctypes.c_char_p(pchData), bytes(text, 'ascii'))
    ctypes.windll.kernel32.GlobalUnlock(hCd)
    ctypes.windll.user32.SetClipboardData(CF_TEXT, hCd)
    ctypes.windll.user32.CloseClipboard()

text = ' '.join(sys.argv[1:])
if len(text) > 0:
    set_clipboard(text)
print(get_clipboard())
```

You can see all the hoops that needs to be covered for calling quite simple functions. Just the memory allocation is rather wordy.

## win32clipboard

The [win32clipboard][3] comes from pywin32 package (and can be installed with it). Usage is rather simple, you just need to keep in mind to open/close the clipboard to make it available to other applications.

```python
import sys
import win32clipboard

def set_clipboard(text):
    win32clipboard.OpenClipboard()
    win32clipboard.EmptyClipboard()
    win32clipboard.SetClipboardText(text)
    win32clipboard.CloseClipboard()

def get_clipboard():
    win32clipboard.OpenClipboard()
    data = win32clipboard.GetClipboardData()
    win32clipboard.CloseClipboard()
    return data

text = ' '.join(sys.argv[1:])
if len(text) > 0:
    set_clipboard(text)
print(get_clipboard())
```

## [clipboard][4]

Probably simplest interface for text data. It also should be multi-platform solution as it is based on [pyperclip][5] that works on all Windows, Linux, and Mac.

```python
import sys
import clipboard

text = ' '.join(sys.argv[1:])
if len(text) > 0:
    clipboard.copy(text)
print(clipboard.paste())
```

[1]: https://metacpan.org/pod/Win32::Clipboard
[2]: https://docs.python.org/3/library/ctypes.html
[3]: http://timgolden.me.uk/pywin32-docs/win32clipboard.html
[4]: https://pypi.org/project/clipboard/
[5]: https://pypi.org/project/pyperclip/
