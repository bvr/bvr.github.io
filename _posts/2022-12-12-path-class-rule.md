---
layout: post
title: Searching for the files/directories recursively
published: yes
tags:
  - perl
  - Path::Class::Rule
  - files
  - Path::Iterator::Rule
---
I got used to use [Path::Class][1] module for file representation. It got bunch of
nice methods for file and directory related operations.

```perl
use Path::Class qw(file);

my $file = file('this.cpp');    # current directory
print $file->absolute;          # full path
print $file->relative($base_dir);   # relative to arbitrary directory

# reading of the file
my $fh = $file->openr();
while(<$fh>) {
  ...
}
close($fh);

print $file->stat->size;        # some handy information
```

Then, looking for files in directory structure using a criteria is rather
easy with [Path::Class::Rule][2] module. It provides nice iterative interface
to specify what you are looking for:

```perl
use Path::Class::Rule;

# all *.cpp files larger than 10k ignoring .git directories
my $finder = Path::Class::Rule->new->skip_dirs('.git')->file->size('>10k')->iname('*.cpp');
my $next_file = $finder->iter('.');
while (defined(my $file = $next_file->())) {
    # we got Path::Class::File object in $file
}
```

Since the construction of `Path::Class` objects was quite costly, the module was 
simplified into [Path::Iterator::Rule][3] that returns just strings and `Path::Class::Rule` is 
simple subclass that inflates them into `Path::Class`. In case of huge trees it might make 
difference.

[1]: https://metacpan.org/pod/Path::Class
[2]: https://metacpan.org/pod/Path::Class::Rule
[3]: https://metacpan.org/pod/Path::Iterator::Rule
