---
layout: post
title: Git file history
published: yes
tags:
  - git
  - perl
  - Text::Gitignore
  - history
  - TERM
  - PAGER
  - git log
  - git ls-tree
---
Recently I needed to build a list of files from a Bitbucket/git repository along with information of last version, author and when it was modified last time. To be able to do it, I needed to dig into git command-line and explore its peculiarities.

### Terminal and git command-line on Windows

As I am working on Windows, first thing that was incredibly annoying was endless complains for non-functional terminal:

```sh
$ git log topics/path-tiny.md
WARNING: terminal is not fully functional
Press RETURN to continue
```

After quick googling I found that it is enough to set the `TERM` variable to `xterm` and the complains stop. Another frequent gripe is using pager for everything, even if the output is one or two lines. I normally use [less][1], but with git command-line I ended up disabling the pager completely and pipe the output to it only when I decide to. You can disable it with

```sh
set PAGER=
```

### Get list of files in the repository

We need to get the list of files from the repository. There is a [git ls-tree][3] command to obtain recursively all files 

```sh
git ls-tree --full-tree --name-only -r HEAD
```

With this command, you get list of files like this:

```
script/schema.sql
script/section-numbering.tt
script/sharepoint.pl
script/skyline.pl
script/slices.py
script/test2-v0.pl
script/xml-validate.pl
site.webmanifest
sitemap.xml
sitemap.xsl
tags.html
tailwind.config.js
topics/ipc-system-simple.md
topics/path-tiny.md
```

### Filtering the files

Further step was to filter the files for only those of interest. I started with simple directory and extension filtering, but I kept running into cases that it could not cover. 

During git exploration I encountered the `.gitignore` files and thought the format is pretty flexible to pick almost any file from the repository. It turns out there is a perl module that support this format and can filter names for me - [Text::Gitignore][2]. For example, following code will only pick Matlab models in `slx` format, constants in `sldd` format for one area and some specific `xml` files:

```perl
use Text::Gitignore qw(match_gitignore);

my @all_files = map { chomp; $_ } `git ls-tree --full-tree --name-only -r HEAD`;
my @relevant_files = match_gitignore(['*.slx', 'sldd/PC12/*.sldd', 'Modelogic/*.xml'], @all_files);
```

### Log entries for files

```sh
git log -1 --pretty=format:"%h%x09%an%x09%as%x09%s" topics/path-tiny.md
```

The [git log][4] command returns log data. It can work for whole repository, but here we use it only for single file. The `-1` switch makes it only return last entry and `--pretty:format` allows us to specify what we want to see. I use following placeholders:

 - `%h` - abbreviated commit hash
 - `%x09` - tab character allows us easy splitting
 - `%an` - author name
 - `%as` - author date, short format `YYYY-MM-DD`
 - `%s` - subject

It produces following output:

```
4eda588 Roman Hubacek   2017-01-21      Topics for new articles
```

Putting it all together, we get this:

```perl
use Text::Gitignore qw(match_gitignore);

my @all_files = map { chomp; $_ } `git ls-tree --full-tree --name-only -r HEAD`;
my @relevant_files = match_gitignore(['*.slx', 'Modelogic/*.xml', 'sldd/PC12/*.sldd'], @all_files);
for my $file (@relevant_files) {
    my ($hash, $author, $date, $comment) = split /\t/, `git log -1 --pretty=format:"%h%x09%an%x09%as%x09%s" $file`;
    warn join(",", $file, $hash, $author, $date, $comment), "\n";
}
```

It is pretty easy to output any other format. In my case, I run this through a template to generate HTML table with list of files and associated data.

[1]: http://www.greenwoodsoftware.com/less/
[2]: https://metacpan.org/pod/Text::Gitignore
[3]: https://git-scm.com/docs/git-ls-tree
[4]: https://git-scm.com/docs/git-log
