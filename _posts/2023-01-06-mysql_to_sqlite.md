---
layout: post
title: Mirror mysql database to SQLite
published: yes
tags:
  - perl
  - DBIx::Class
  - DBIx::Class::Schema::Loader
  - Class::Load
  - database
  - mysql
  - SQLite
---
Sometimes it can be useful to migrate server-based database like mysql into file-based database solution. It can be handy for self-contained testing and possibly also for other scenarios.

I needed to build such mirror today to provide an offline version of a tool. The [DBIx::Class][1] is probably most famous perl ORM and it allows bi-directional use. So you can build your schema in the database and then build your classes from it. Code-first approach is also available, but in my case I combined both approaches. 

First step in `migrate_database` function is creating schema and result classes using [DBIx::Class::Schema::Loader][2]. 

Just created source code can be dynamically loaded using [Class::Load][3] module and used for subsequent operations - deployment of the schema to target and populating the tables with all data from source.

```perl
use lib 'lib';
use DBIx::Class::Schema::Loader 'make_schema_at';
use Function::Parameters;
use Class::Load qw(load_class);

my $host = 'a_server';
migrate_database("SchemaName",
    from_dsn => ["dbi:mysql:host=$host;database=Aircraft", 'user', 'pwd'],
    to_dsn   => ["dbi:SQLite:dbname=aircraft.db"],
);

fun migrate_database($schema, :$from_dsn, :$to_dsn) {

    # build the DBIx::Class schema in lib directory
    my $options = {
        dump_directory => 'lib',
        generate_pod   => 0,
        debug          => 0,
    };
    make_schema_at($schema => $options, $from_dsn);

    # load the schema and deploy it into target
    load_class($schema);
    my $from_db = $schema->connect(@$from_dsn);
    my $to_db   = $schema->connect(@$to_dsn);
    $to_db->deploy({ add_drop_table => 1 });

    # copy all data
    my @sources = keys $from_db->source_registrations;
    for my $src (@sources) {
        $to_db->resultset($src)->populate([ map { +{ $_->get_columns } } $from_db->resultset($src)->all ]);
    }
}
```

The approach is quite simple, but it worked nicely in my case. The ORM classes also provide handy means to filter the migrated data or build some statistics.

[1]: https://metacpan.org/dist/DBIx-Class
[2]: https://metacpan.org/pod/DBIx::Class::Schema::Loader
[3]: https://metacpan.org/pod/Class::Load
