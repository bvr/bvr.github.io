---
layout: post
title: Photo workflow
published: yes
tags:
  - Photo
  - Camera
  - System
  - perl
  - Image::ExifTool
  - Nikon
  - Canon
  - DSLR
  - jhead
  - EXIF
---
**Update 2025-12-25:** Revisited the list of equipment, updated the renaming script.

This post is a summary of my digital photography workflow and my ways of photo organization. It is a system developed over the last 20 years. It makes sense to explain my photography background first. My most common subject is capturing travel trips, people in the countryside, preferably mountains if I can help it.

![Vysoké Tatry](/img/tatry.jpg)
*The picture above was taken in the Slovak mountains called Vysoké Tatry (High Tatras).*

## Early days

I've been taking photos since I was small. Back then, I used 35mm film with full-manual cameras that were usually East German-made, like the [Praktica][1] SLR. The usual process was slow: you needed to finish your cassette with 24 or 36 frames and then have it developed. This was not much fun, so when digital started to be usable, I quickly jumped on that train and initially bought a [Cannon A40][2] with a 2-megapixel resolution. It is laughable these days, but back then it was a great camera and I took tens of thousands of pictures with it and learned a ton about photography that way.

![Canon A40](/img/canon-a40.jpg)

In the meantime, Canon came out with its first affordable DSLR (Canon Digital Rebel), and shortly after, Nikon came with its [D70][3]. I was able to save some money and bought it along with the standard 18-70 mm lens. This was a huge step forward, and I stayed with Nikon since then. Over time, I got some additional lenses, a flash, and a tripod. The DSLR experience is something that is hard to convey, but it is wonderful as a photographic tool. Every function is quickly accessible via external buttons, the viewfinder is bright and clear, providing great control over depth of field, focus, and camera settings.

![Nikon D70](/img/nikon-d70.jpg)

## Current equipment

The last iteration of a Nikon DSLR I currently use is the **Nikon D7200** camera. Compared to previous cameras, it has a much better 24-megapixel sensor, an even better viewfinder, great sports modes with fast focusing, and wonderful image quality. Controls are taken from higher-level cameras, while keeping a similar philosophy of usage.

![Nikon D7200](/img/nikon-d7200.jpg)

I use the following lenses at the moment:

 - **Nikon 18-300mm f/3.5-6.3 ED AF-S DX VR** - my primary lens, very universal, flexible and lightweight. It produces nice images, although at the long end it is a little soft
 - **Nikon 35mm f/1.8 AF-S DX** - one of the recent additions, very light and fast prime lens with good focal length (on the DX camera 52mm)
 - **Nikon 50mm f/1.8 AF-D** - fast prime lens with good bokeh
 - **Nikon 55-300mm f/4.5-5.6 ED DX VR** - provides faster and better quality telephoto when the primary lens is not good enough
 - **Tokina 12-24mm f/4 (IF) DX** - awesome wide lens, probably the best-built lens I have
 - **Sigma 28-135mm f/3.8-5.6 MACRO** - pretty bad lens overall, but it can provide 1:2 macro capability, which is the only reason I still have it

There is also a number of other devices that take pictures, like the cell phones of the whole family.

## Photo gathering

From the D7200 camera, I usually download data directly from the SD cards; from cell phones, I use a USB connection to the device and download photos. I have a directory called `00-Incoming` for this purpose. I try to make sure the devices are properly set up for the timezone where the capture happened -- on cell phones this happens automatically using operator synchronization; with the camera, you need to set the timezone manually. 

If it fails, there is an option to fix the time in downloaded photos using a trick described in [one of my previous posts using the jhead tool]({% post_url 2015-09-20-jhead %}).

Once all files are gathered in the incoming directory, I rename all of them to the format `YYMMDD-hhmmss-nn.jpg`, i.e. something like `210101-122046-00.jpg`, and put the files into a one-day directory named `YYMMDD`. For the purpose, I have a script like this:

```perl
use 5.16.3;
use File::Glob ':bsd_glob';

package File {
    use Moo;
    use Function::Parameters;
    use Types::Standard qw(InstanceOf);
    use Time::Moment;
    use Path::Class;

    has name => (
        is       => 'ro',
        required => 1,
    );
    has date => (
        is      => 'rw',
        isa     => InstanceOf ['Time::Moment'],
        default => sub { Time::Moment->new(year => 9999, month => 1, day => 1) },
    );
    has disambig => (
        is      => 'rw',
        default => 0,
    );

    method ext() {
        return $self->name =~ /(\.[^.]+)$/ ? $1 : '';
    }

    method valid_rename() {
        return $self->date->year != 9999;
    }

    method date_time() {
        return $self->date->strftime("%y%m%d-%H%M%S");
    }

    method target_path(:$no_dir = 0) {
        my $filename = $self->date_time . sprintf("-%02d", $self->disambig) . $self->ext;

        return $no_dir ? file($filename) 
                       : dir($self->date->strftime("%y%m%d"))->file($filename);
    }
};

use List::Util qw(reduce);
use Getopt::Long;
use Path::Class qw(dir);

our $VERSION = '1.0.0';

GetOptions(
    'help'         => sub { help() },
    'dryrun'       => \(my $dryrun = 0),
    'skip-dirs'    => \(my $skip_dirs = 0),
) or help("Command-line parsing failed");

# default directory
push @ARGV, "00-Incoming" unless @ARGV;

my $current_dir = dir();

for my $dir (@ARGV) {
    chdir($current_dir);        # go back to original directory to cover relative paths below
    chdir($dir);

    say "Working in " . dir()->absolute;

    # handle .jpg images
    open(my $in, "jhead.exe \"*.jpg\" 2>nul |") or die "Could not pipe: $!\n";
    my $last;
    my @files;
    while(my $line = <$in>) {
        # warn $line;
        chomp($line);
        my %items = $line =~ /^ ([^:]+?) \s* : \s* (.*?) \s*$ /gmx;
        if($items{"File name"}) {
            push @files, $last = File->new(name => $items{"File name"});
        }
        if(my $date = $items{"Date/Time"}) {
            if($date =~ /^(\d{2}\d{2}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})/) {
                $last->date(Time::Moment->new(year => $1, month => $2, day => $3, hour => $4, minute => $5, second => $6));
            }
        }
    }

    # handle videos
    for my $video_filename (<*.mp4>) {
        if($video_filename =~ /^(\d{4})(\d{2})(\d{2})_(\d{2})(\d{2})(\d{2})/) {
            push @files, File->new(
                name => $video_filename, 
                date => Time::Moment->new(year => $1, month => $2, day => $3, hour => $4, minute => $5, second => $6)
            );
        }
    }

    # add disambiguation for names that would be the same
    reduce { $a->date_time eq  $b->date_time && $b->disambig($a->disambig+1); $b }
    sort { $a->date_time cmp $b->date_time }
        @files;

    if($skip_dirs) {
        say "No directories are requested";
    }
    else {
        my %dirs = ();
        @dirs{map { $_->target_path->parent->absolute->stringify } @files } = ();
        for my $dir (sort keys %dirs) {
            say "Create directory: $dir";
            next if $dryrun;
            dir($dir)->mkpath();
        }
    }

    # all renames
    for my $file (sort { $a->date_time cmp $b->date_time } @files) {
        next unless $file->valid_rename;
        say $file->name, " -> ", $file->target_path(no_dir => $skip_dirs);
        next if $dryrun;
        rename($file->name, $file->target_path(no_dir => $skip_dirs));
    }

}

say "Done";

sub help {
    print STDERR <<HEADER;
$0 v.$VERSION
Copyright (C) 2014-2025

HEADER

    if(@_) {
        warn "Error: @_\n";
    }

    my $usage = <<USAGE;
Usage:
  $0 [options] [directories]

Rename images and videos in the specified directory/ies. By default it is 
processing the "00-Incoming" directory. It extracts creation date from files 
and moves them into something like "210925\\210925-181530-00.jpg"

Options:
  --dryrun           Only show what would be done
  --skip-dirs        Do not create daily directories
  --help             Shows this screen

Examples:
  $0
  $0 --dryrun
  $0 --skip-dirs . 
  $0 C:\\SomeDirectory\\Images
USAGE
    print STDERR $usage;
    exit(-1);
}
```

It uses the EXIF date stored in the photos, as file dates can differ wildly. The `nn` numbering is useful if multiple photos were created in the same second. This usually happens quite rarely, either when continuous drive is used or when two people are capturing photos at the same time. With this completed, the incoming directory looks like this:

```
├───210101
│       210101-122046-00.jpg
│
├───210114
│       210114-080142-00.jpg
│       210114-081329-00.jpg
│
├───210115
│       210115-114849-00.jpg
│
├───210116
│       210116-090543-00.jpg
│       210116-090618-00.jpg
│       210116-090648-00.jpg
│
├───210118
│       210118-150528-00.jpg
```

## Organization

My photo collection is a simple, directory-based structure. There is a top level directory for each year; the second level is per event, with directories named like `YYMMDD - Name of event`. This way, it is easy to find the event, name sorting reflects the date, and it keeps this information even if I take the whole directory and move it somewhere else.

This structure is created manually by walking through incoming directories and grouping them into an event. Most short events can stay as they are (just add the name), but with longer trips I merge them together.

Inside the event directory, I work through the photos and pick those that I like during the processing. It is often the case that I like the moment, but the photo is not too interesting. For the down-select, using [IrfanView][4] and its `File/Copy File (F8)` function, I transfer good photos into a directory `choice`. If there are too many selected photos, I usually repeat the process until I have a reasonable number of them. For events about a week long, I like to end with 50-100 photos.

Once I have my selection, I move all other photos into the sub-directory `other` and the selection ends up at the top. With post-processing, I want to keep originals in case I screw the editing up. For that, before editing, the original gets copied into the sub-directory `edited` (IfranView again). For editing, I have an old Photoshop CS version 8.0 from 2003, which still works great for my purposes. The editing usually means:

 - **Crop the photo** to a 2x3 format (can be printed as a 10x15cm paper photo). Nikon already creates such a format, for cell phone it needs some tweaking. The crop also allows me to get rid of anything that does not belong to the photo and improves focus on the subject
 - Apply **Levels** to use the whole tonal range. Photos look better if they have some black and some white in them, and at the same time it is possible to adjust mid-tones
 - If needed, change colors. I usually only play with Saturation to make the photo more vivid or muted
 - Locally darken/lighten. I usually do it by duplicating layers (with Screen or Multiply modes) and editing the mask of the top layer. You can also add vignetting to the photo, emphasize the subject, or hide something unimportant
 - Retouch if needed. I try to avoid mistakes during capture, but sometimes the photo is good and just needs some minor adjustment

The resulting event directory looks like this:

```
\220827 - Zell am See
│   220827-122835-00.jpg
│   220827-123720-00.jpg
│   220827-124032-00.jpg
│   ....
├───edited
│       220827-122835-00.jpg
│       ...
└───other
        220827-122829-00.jpg
        220827-123318-00.jpg
        220827-123713-00.jpg
        ....
```

## Face recognition, tagging, and descriptions

The photos are organized, selected and edited. Now, for the ones that will be used on my web page, I would like to add descriptions, tags and people present on the photo. For a long time, I have been using Windows Essentials 2012, which includes the `Photo Gallery` program. It is no longer supported, but is still available for download on the internet. 

It allows automatic face detection on the photos with good suggestions, and it learns from your selections. It will mark the faces in EXIF and add the list of people there.

You can also edit the caption and add descriptive tags. The latter feature is very well done: you can define hierarchical tags going from general to more specific, separating each part with `/`. So your tags can be 

 - `Mountains/Alps/Raxalpe`
 - `Water/River/Thaya`
 - `Austria/City/Vienna`

When you start typing `Vienna`, you get the full tag with more generic meanings.

Now we need a way to extract the information above from the photo. In Perl, there is nice module [Image::ExifTool][5], that allows exactly that. We will need the following entries

 - CreateDate
 - ImageSize
 - Title
 - Subject
 - RegionPersonDisplayName

Let's extract the data:

```perl
use 5.16.3;
use Image::ExifTool;

package Photo {
    use Moo;
    use Function::Parameters;
    use Types::Standard qw(ArrayRef InstanceOf Str Maybe);
    use List::MoreUtils qw(zip);
    use Encode          qw(decode_utf8);
    use DateTime;

    has file        => (is => 'rwp');
    has title       => (is => 'rwp', isa => Maybe[Str], predicate => 1);
    has create_date => (is => 'rwp', isa => InstanceOf['DateTime']);
    has tags        => (is => 'rwp', isa => ArrayRef[Str]);
    has size        => (is => 'rwp');

    method _decode_exif_string($string) {
        return decode_utf8($string);
    }

    method new_from_file($class: $filename, $exiftool) {
        my $info  = $exiftool->ImageInfo("$filename",     # stringify filename, could be  Path::Class::File
            qw(Title CreateDate Subject RegionPersonDisplayName ImageSize));

        my $title = $class->_decode_exif_string($info->{Title});

        my @tags  = ();
        push @tags, split /, /, $class->_decode_exif_string($info->{Subject});
        push @tags, split /, /, $class->_decode_exif_string($info->{RegionPersonDisplayName} // '');

        my @comp = qw(year month day hour minute second);
        my $date = DateTime->new(zip @comp, @{[ ($info->{CreateDate} =~ /(\d+)/g)[0..5] ]});

        return $class->new(
            file        => $filename,
            (title      => $title) x !!$title,
            tags        => \@tags,
            create_date => $date,
            size        => $info->{ImageSize},
        );
    }
};

my $file = shift // die "syntax: $0 file.jpg\n";
my $exif = Image::ExifTool->new;
my $photo = Photo->new_from_file($file, $exif);
say $photo->title;
say join ", ", @{$photo->tags};
```

So far, this works pretty well for me. At the moment, I have well over a hundred thousand photos in my collection. It is consistent, quite easy to find an event, and easy to get back to the photos.

[1]: https://en.wikipedia.org/wiki/Praktica
[2]: https://global.canon/en/c-museum/product/dcc472.html
[3]: https://en.wikipedia.org/wiki/Nikon_D70
[4]: https://www.irfanview.com/
[5]: https://metacpan.org/pod/Image::ExifTool

*[SLR]: single-lens reflex
*[DSLR]: digital single-lens reflex
