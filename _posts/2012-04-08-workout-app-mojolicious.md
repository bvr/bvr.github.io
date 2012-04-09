---
layout: post
title: Creating WorkOut application with Mojolicious
category: perl
published: no
perex: >
    I had used Mojolicious for few simple web applications at work, but wanted to
    learn more. For me, the best way is usually taking some project and learn
    by using.
tags:
  - perl
  - mojolicious
  - DBIx::Class
---
Application I want to write is simple evidence for my workout activity. 
Currently I have simple spreadsheet, but want something better. I am using 
simple sporttester watch Suunto T1C that provides various data like average 
heart rate, duration of training, etc. 

## Data Model

After each workout, the sporttester provides me with these information:

'''Item'''    | 
--------------+-------------------------------
datetime      | Date and time the workout started
duration      | How long it took
kcal          | Burned calories based on heart rate (HR) progress and some personal info (weight, height, max HR)
avg hr        | Average HR during workout
max hr        | Maximum HR during workout
z1            | Time spent within zone 1 (60-70% of personal max HR)
z2            | Time spent within zone 2 (70-80% -""-)
z3            | Time spent within zone 3 (80-90% -""-)
>z3           | Time spent above zone 3 (90% of personal max HR or more)
<z1           | Time spent below zone 1 (60% of personal max HR or less)

There are some additional info I would like to store as well:

'''Item'''    | 
--------------+-------------------------------
len           | Length or run, biking, walking, ...
workout type  | Type of workout (bike, run, walk, swim, volleyball, ...)
description   | Some more details of what happened
weather       | If outdoor, the temperature and weather details (12C, raining)

So lets create DBIx::Class definition of the database:

... TBD

Deploy it:

    use WorkOut::Schema;
    my $db = WorkOut::Schema->connect("dbi:SQLite:data.db", '', '', { RaiseError => 1 });
    $db->deploy({ add_drop_table => 1 });

Maybe some validation/normalization to database columns:

 - [DBIx::Class::FilterColumn](https://metacpan.org/module/DBIx::Class::FilterColumn)
 - [DBIx::Class::InflateColumn](https://metacpan.org/module/DBIx::Class::InflateColumn)

## The application

 - select Mojolicious

## How to add a command to the Mojolicious app

In main script of the application there is something like

    Mojolicious::Commands->start;

with following code we can push additional namespace where it looks for commands:

    my $cmd = Mojolicious::Commands->new;

    # Add WorkOut::Command namespace for additional commands
    my $ns = $cmd->namespaces;
    push @$ns, 'WorkOut::Command';
    $cmd->namespaces($ns);

    $cmd->start; 

The command is then a subclass of [Mojo::Command](...):

    package WorkOut::Command::import;
    use Mojo::Base 'Mojo::Command';

    has description => "Import XLS data into the database.\n";
    has usage       => "usage: $0 import file.xls\n";

    sub run { ... }
    
    1;

