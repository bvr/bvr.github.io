---
layout: post
title: SVN Repository Migration
published: yes
tags:
  - Subversion
  - svnrdump
  - SVNBook
  - repository
  - dump
  - load
---
I was asked to help with migration of a branch from huge Subversion repository to new repository that can be easily converted into git. Digging through my old scripts and [SVNBook](https://svnbook.red-bean.com/en/1.7/svn-book.html#svn.reposadmin.maint.migrate) I found methods of the migration via Subversion dump format. There is a command `svnrdump` that allows to `dump` or `load` even remote repository. 

    svnrdump dump svn://a_server/branches/dev --file dev.dmp

The dump format is binary file with all revisions exported. It can contain full repository or just some sub-directory, as shown in example above.

We are using [VisualSVN Server](https://www.visualsvn.com/server/), the new repository can be created in VisualSVN Server Manager, click on `Repositories` and select `New repository`. In the wizard you can set name, privileges and other options. In order to load into the repository, the `pre-revprop-change` hook needs to be set. I put following in the hook:

```bat
@echo off
echo Path:     %1
echo Revision: %2
echo User:     %3
echo Propname: %4
echo Action:   %5
echo.
```

Loading is as simple as

    svnrdump load svn://new_server --file dev.dmp

As my dumps were over 2GB, the export and import took several hours, but ended without an issue.