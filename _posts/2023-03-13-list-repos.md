---
layout: post
title: List svn/git repositories
published: yes
tags:
  - perl
  - Migration
  - Subversion
  - Git
---
As I was migrating to new computer, I wanted to list all repositories I have checked out. Simple perl script to help

```perl
use Path::Class qw(dir file);
use Cwd;
use XML::LibXML;

visit(dir(shift // '.'));

sub visit {
    my ($dir) = @_;

    next if ! $dir->is_dir;
    for my $entry ($dir->children) {
        next unless -d $entry;
        my $svn = get_svn_url($entry);
        if(defined $svn) {
            warn join("\t", $entry, $svn), "\n";
            next;
        }

        if(-d $entry->file('.git')) {
            my $curr = getcwd;
            chdir($entry->absolute);
            my @remotes = `git remote -v`;
            chdir($curr);
            for my $rem (@remotes) {
                chomp($rem);
                warn join("\t", $entry, $rem), "\n";
            }
            next;
        }

        visit($entry);
    }
}

sub get_svn_url {
    my ($dir) = @_;

    my $svn_info = `svn info $dir --xml 2>nul`;
    return unless $svn_info =~ /<url>/;
    my $doc = XML::LibXML->load_xml(string => $svn_info);
    my $url = $doc->findvalue('//url');
    return $url;
}
```

This will recurse along all directories under the specified one and if it finds it is Subversion or Git one, it will get remotes or Subversion url. Result is reported in simple table.

You may notice `chdir` into the directory to check git remotes.  I don't like it, but haven't found good way to report them without going into the directory.
