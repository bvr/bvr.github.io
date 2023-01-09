---
layout: post
title: Extract files from zip
published: yes
tags:
  - perl
  - zip
  - Archive::Zip
  - IO::String
  - PerlApp
---
For my offline application I am currently working on, I need to include many small files placed in the executable. As for this, I need work with zip file that I am getting in a string variable, list its contents and output contents of individual files.

We will need [Archive::Zip][1] and [IO::String][2] libraries

```perl
use Archive::Zip;
use IO::String;
```

During the init time, get the zip file contents

```perl
my $zip_contents = get_zip_file();
```

Create the main object, create string-based file handle and read the contents

```perl
my $zip = Archive::Zip->new();
my $dh = IO::String->new($zip_contents);
$zip->readFromFileHandle($dh) == AZ_OK or die 'read error';
```

List contents of the zip, entries have Unix path format without leading forward slash

```perl
for my $entry ($zip->memberNames) {
    print "$entry\n";           # dir/lib/nls/ru/common.js
}
```

Extract a file and print it out

```perl
my $member = $zip->memberNamed($some_file);
my ($contents, $status) = $member->contents;
die "error $status" unless $status == AZ_OK;
print $contents;
```

All the operations are nicely in memory (no temp directory is needed) and it looks like its performance is sufficient for my purposes. 

[1]: https://metacpan.org/pod/Archive::Zip
[2]: https://metacpan.org/pod/IO::String
