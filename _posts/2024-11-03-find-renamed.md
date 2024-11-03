---
layout: post
title: Identify renamed photos
published: yes
tags:
  - perl
  - Photo
  - Path::Class
  - hash
  - Dictionary
---
This is mostly a reminder that [perl][1] hashes are pretty flexible and can easily handle large keys. In the case below I needed to find renamed photos. As I [explained before]({% post_url 2023-03-26-photo-organization %}), I use date-based naming scheme for my photos. After our last vacation in Corsica, my wife selected photos before I renamed them, so I needed to find photos from her folder in my renamed photos.

First I created signatures based on the content of each photo (about 10MB per file) and stored them in a hash:

```perl
use Path::Class qw(file dir);

my %signatures = map { scalar file($_)->slurp() => $_ } <*.jpg>;
warn "Signatures loaded for ", scalar @files, " files\n";
```

With the signatures in place, it was easy to list all files with matching content:

```perl
my $find_in = 'c:\\Photos\\2024\\240807 - Corsica';

my %reported = ();
for my $target (dir($find_in)->children) {
    next unless -f $target;       # check only files
    my $found = $signatures{ $target->slurp() };
    if(defined $found) {
        warn $target, "\n";
        $reported{ $found } = 1;
    }
}
```

This will report all renamed files that were found in her selection. You'll notice I track found files in a hash to cross-check for any missing items. This helped me validate my script, as ideally, every file should be accounted for. Here is a code to report them:

```perl
for my $item (sort values %signatures) {
    next if $reported{ $item };
    warn "Not found $item\n";
}
```

This solution saved me the effort of manually sorting through over 1,000 files to match those I already had.

[1]: https://www.perl.org/