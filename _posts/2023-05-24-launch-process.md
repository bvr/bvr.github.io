---
layout: post
title: Launch process
published: yes
tags:
  - python
  - subprocess
  - os.system
  - ffmpeg
  - mp3
  - m4a
  - docstring
  - PEP-0257
---
I am trying to use python for all possible scripting tasks at hand. Recently I needed to automate conversion of `.m4a` files into regular `.mp3`, so it can be used with my legacy mp3 player. I quickly found that [ffmpeg][1] works nicely for the conversion. 

So the rest of the task was rather trivial, just [embed list of files]({% post_url 2023-05-23-heredoc %}) to convert into the script, build target filename by replacing the extension and run the ffmpeg command

```python
import subprocess

def main():
    for file in files():
        convert(file, quality=9)

def convert(file, quality):
    """Convert m4a file downloaded from youtube to classic mp3 using specified quality."""
    file_mp3 = file.replace('.m4a', '.mp3')

    # for ffmpeg options see https://ffmpeg.org/ffmpeg.html
    cmd = [
        'ffmpeg', 
        '-y',                   # overwrite output file 
        '-i', file,             # input file
        '-c:v', 'copy',         # video codec
        '-c:a', 'libmp3lame',   # audio codec
        '-q:a', str(quality),   # audio quality 0=best, 9=worst
        file_mp3                # output file
    ]
    print(' '.join(cmd))
    subprocess.run(cmd)

def files():
    """Return list of .m4a files to convert."""
    return [
        'minecraft-be-together.m4a',
        'minecraft-doomsday.m4a',
        'minecraft-frame-of-mind.m4a',
        'minecraft-chains.m4a',
    ]

if __name__=="__main__":
    main()
```

When looking for way to execute command from python, from built-in options I found either [subprocess][2] or [os.system][3] calls. Since former was suggested as more safe, I went with that option and it worked nicely.

As I side-note, I explored using docstrings for documentation of the functions. There is [PEP 257 – Docstring Conventions][4] with conventions on how to write them. For the simple script, I went with one-line recommendation.

[1]: https://ffmpeg.org/ffmpeg.html
[2]: https://docs.python.org/3/library/subprocess.html
[3]: https://docs.python.org/3/library/os.html#os.system
[4]: https://peps.python.org/pep-0257/
