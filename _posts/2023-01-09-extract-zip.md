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

```perl
use Archive::Zip;
use IO::String;

my $zip_contents = get_zip_file();

# build the accessor
my $zip = Archive::Zip->new();
my $dh = IO::String->new($zip_contents);
$zip->readFromFileHandle($dh) == AZ_OK or die 'read error';

# list contents of the zip
for my $entry ($zip->memberNames) {
    print "$entry\n";
}

# extract a file and print it out
my $member = $zip->memberNamed($some_file);
my ($contents, $status) = $member->contents;
die "error $status" unless $status == AZ_OK;
print $contents;
```

All the operations are nicely in memory (no temp directory is needed) and it looks like its performance is sufficient for my purposes. 
