---
layout: post
title: Code review Trac/SVN
published: yes
tags:
  - perl
  - Trac
  - Subversion
  - Review
  - Path::Class
---
At work we are using combination of [Subversion][2] and [Trac][1] for the development. Both tools are connected, so if you commit with special `Refs #1234` in the message, it will show the updates in the ticket. Our process call for code review, which is usually done as a comment in Trac ticket. If the change is relatively simple, Trac provide nice diff, so it is easy to refer to changes.

But sometimes there is new development and you end up with reviewing everything in the repository.  In that case it is useful to avoid the diffs and walk through the code completely. In such cases I lack github approach of commenting on the code. This is a simple workaround.

I just go into the code to review and at any place I want to refer place comment like `RH: Text`. When I run `svn diff -x "-U0" directory` command, the output shows changes I've done with references to file, revision and particular line. Following script extracts it and generates markup that refers to the file revisions with my notes included

```perl
use 5.16.3;
use Path::Class qw(dir file);

my $dir = dir(shift // ".");

# find root svn directory
my $svn_root = $dir;
while(defined $svn_root) {
    $svn_root = $svn_root->parent;
    last if -d $svn_root->subdir('.svn');
}


my @output = `svn diff -x "-U0" $dir`;

# build a directory structure with comments included
my $all = {};
my $curr;
my $curr_line;
for my $ln (@output) {

    # target file
    if(my ($file, $rev) = $ln =~ /^--- (.*)\s+\(revision (\d+)\)/) {
        my @path = split m{/}, file($file)->relative($svn_root)->as_foreign('Unix');
        my $pos = $all;
        while(my $sec = shift @path) {
            $pos = $pos->{$sec} ||= {};
            $curr = $pos;
        }
        $curr->{rev} = $rev;
    }

    # line
    if(my ($line_no) = $ln =~ /^\@\@ -(\d+)/) {
        $curr_line = $line_no;
    }

    # comments
    if(my ($comment) = $ln =~ /^\+ .*RH:\s*(.*)$/) {
        $curr->{comments} ||= [];
        push @{ $curr->{comments} }, { line => $curr_line, text => $comment };
    }
}

# traverse the structure and build the output
build_trac_markup($all, 0, '');

sub build_trac_markup {
    my ($data, $level, $path, $file) = @_;
    if(defined $data->{rev}) {
        my $rev = $data->{rev};
        for my $cmt (@{ $data->{comments} }) {
            my $line = $cmt->{line};
            my $text = $cmt->{text};
            print "  "x$level . " - " . "[source:$path\@$rev#L$line line $line] - $text\n";
        }
    }
    else {
        for my $ky (sort keys %$data) {
            print "  "x$level . " - " . "$ky\n";
            build_trac_markup($data->{$ky}, $level+1, $path."/".$ky);
        }
    }
}
```

Result look like this

```
 - Database
   - DbLayer
     - [source:Tool/trunk/Database/DbLayer/Disposition.cs@11272#L21 Disposition.cs line 21] - Nice, consistent database interface with TraceDb]
```

Which in Trac builds nice structured list of comments with references to the connected Subversion.

[1]: https://trac.edgewall.org/
[2]: https://subversion.apache.org/
