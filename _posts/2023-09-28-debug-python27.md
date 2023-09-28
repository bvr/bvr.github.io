---
layout: post
title: Debug python 2.7
published: yes
tags:
  - Visual Studio Code
  - vscode
  - python
  - config
---
Recently I had to debug old program written years ago using python 2.7. The thing worked quite nicely for more than decade, but last month the version-control system used as data source -  [Dimensions][1] - was updated and various reports it produces changed their format.

I had to setup my [Visual Studio Code][2] to debug such thing. One crucial information came from [this Stack Overflow entry][3]:

> you have to install a previous version of the Python extension, because in the meanwhile support for Python 2 has been dropped.

> To install a previous version you have to:

> - Open the Extensions pane from the bar on the left and find Python
> - Click on the gear icon and select "Install another version"
> - Choose 2021.9.1246542782
> - After it's finished, restart VS Code.

There is more info on reasons for the version, long story short the version mentioned above is last where was still support for python 2.x.

The debugging then works, we just need to setup the tool to run with proper arguments and we can use it for resolving the problem.

```json
{
    "version": "0.2.0",
    "configurations": [
        {
            "name": "Python: Tool",
            "type": "python",
            "request": "launch",
            "program": "tool.py", // ,"program": "${file}",
            "args" : ["-ini=runtime.ini"],
            "console": "integratedTerminal"
        }
    ]
}
```

[1]: https://en.wikipedia.org/wiki/Dimensions_CM
[2]: https://code.visualstudio.com/
[3]: https://stackoverflow.com/questions/72214043/how-to-debug-python-2-7-code-with-vs-code
