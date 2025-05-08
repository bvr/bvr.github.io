---
layout: post
title: Dispatch tables
published: yes
tags:
  - perl
  - dispatch
  - backup
  - mysql
---
I learned the technique of the dispatch table in excellent book [Higher-Order Perl][1]. It provides nice data-driven alternative to various switch or if-else constructs. If we distill the form to its minimum, we will get something like this:

```perl
my $actions = {
    one => sub { print "One"; },
    two => sub { print "Two"; },
};
$actions->{$an_action}->() // die "The action \"$an_action\" is not defined";
```

It has various advantages:

 - it is data-driven, so the actions can be loaded from configuration, built with factories, or serialized 
 - the dispatches can be chained - if the action is not found in one table, it can try other one, or a default

For larger example, I have a backup script that runs every day. According to a configuration it can backup files, mysql 5 databases, mysql 8 databases or anything else. The configuration looks like this:

```yaml
configuration:
    output_directory: backups
    interval: 24

backups:
    tool1:
        method: mysqldump
        server: machine1
        user: ...
        pass: ...
        conn_info:
            database:
                - one
                - two

    tool2:
        method: mysqldump5
        server: machine2
        user: ...
        pass: ...
        conn_info:
            database_wildcard: ^tool2

    data1:
        method: file
        paths:
           - d:\path\file.db
```

I have definition of methods that can be selected in the configuration file:

```perl
my %methods = (
    mysqldump  => build_mysql_commands('mysql',  'mysqldump'),
    mysqldump5 => build_mysql_commands('mysql5', 'mysqldump5'),

    file => {
        list => sub {
            return ("files");
        },
        backup => sub {
            my ($server_info, $database, $output_file) = @_;
            run_command("bin\\7z a $output_file " . join " ", map { "\"$_\"" } @{ $server_info->{paths} });
        },
    },
);

sub build_mysql_commands {
    my ($mysql, $mysqldump) = @_;

    return {
        list => sub {
            my ($server_info) = @_;
            my $conn_info     = $server_info->{conn_info};

            # either use "database" for list of databases, or "database_wildcard"/"skip_database" for a template
            my @databases = @{ $conn_info->{database} // [] };
            if(defined $conn_info->{database_wildcard} || defined $conn_info->{skip_database}) {
                my $output = run_command(
                    "bin\\$mysql --host=\"$server_info->{server}\" "
                  . "--user=\"$server_info->{user}\" --password=\"$server_info->{pass}\" "
                  . "-BNe \"SHOW DATABASES\""

                );
                @databases = grep { /$conn_info->{database_wildcard}/ } split /\n/, $output;
                if(defined $conn_info->{skip_database}) {
                    @databases = grep { ! /$conn_info->{skip_database}/ } @databases;
                }
            }

            return @databases;
        },
        backup => sub {
            my ($server_info, $database, $output_file) = @_;
            my $output_file_base = $output_file->basename;

            # do mysqldump piped with 7zip archiving
            my $additional_options = "";
            if($mysqldump ne 'mysqldump5') {
                # this option only works with mysqldump from version 8
                $additional_options = "--column-statistics=0 ";
            }

            run_command(
                "bin\\$mysqldump $additional_options --skip-lock-tables --hex-blob "
              . "--host=\"$server_info->{server}\" --user=\"$server_info->{user}\" "
              . "--password=\"$server_info->{pass}\" \"$database\" "
              . "| bin\\7z a $output_file -si\"$output_file_base.sql\""
            );
        },
    };
}
```

Then the processing of the backups is something like this:

```perl
for my $application (sort keys %{ $config->{backups} }) {
    if(defined $only) {
        next if none { $_ eq $application } @$only;
    }

    INFO "For application $application";

    # fetch info from config and select method
    my $server_info = $config->{backups}{$application};
    my $method      = $methods{ $server_info->{method} } // {
        list   => sub { return ("db") },
        backup => sub { WARN "$application backup method " . $server_info->{method} . " is not supported. Skipped\n"; }
    };

    # get list of databases/items and iterate over it
    my @databases = $method->{list}->($server_info);
    TRACE "Filtered databases: " . pp(\@databases);

    for my $database (@databases) {

        # determine filename and make sure its target directory exists
        my $output_file = $output_dir->subdir($application)->subdir($month)->subdir($database)->file("$application-$database-$day");
        $output_file->dir->mkpath
            unless -d $output_file->dir || $dryrun;

        INFO " - Backing up $database -> $output_file";
        $method->{backup}->($server_info, $database, $output_file);
    }
}
```

Other option would be create a class for each method and dispatch using the method polymorphism, but for small selection of methods this is nicely self-contained and easy to extend.

[1]: https://hop.perl.plover.com/
