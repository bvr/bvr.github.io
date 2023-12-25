---
layout: post
title: JSON Pretty
published: yes
tags:
  - json
  - formatting
  - pretty-print
  - jq
  - python
  - perl
  - JSON::XS
---
Working with JSON files in [Visual Studio Code][1] is quite convenient with [nice features][2]. But when the files are large, especially with everything on single line, it all stops working. A solution would be to reformat the file, so I looked for some options.

My file is around 14MB, exported from a web service.

With brief googling, I found solution using python's [json.tool][3]:

```
type file.json | python -m json.tool >file-pretty.json
```

Then it occurred to me that something similar will be available in perl, since the [JSON::XS][4] module can do the pretty-printing, too. And there is a command-line tool [json_xs][5]:

```
type file.json | json_xs >file-pretty.json
```

And when searching this very site, I found another option in [jq][6] tool presented in [this post]({% post_url 2023-06-08-jq %}). Its simplest usage with automatically pretty-print the output:

```
jq . file.json > file-pretty.json
```

Each option generate slight different formatting and encoding, especially for the unicode characters. All output (they are around 20MB) can be easily opened with the Visual Studio Code and worked with easily.

[1]: https://code.visualstudio.com/
[2]: https://code.visualstudio.com/docs/languages/json
[3]: https://docs.python.org/3/library/json.html#module-json.tool
[4]: https://metacpan.org/pod/JSON::XS
[5]: https://metacpan.org/pod/json_xs
[6]: https://jqlang.github.io/jq/manual/
