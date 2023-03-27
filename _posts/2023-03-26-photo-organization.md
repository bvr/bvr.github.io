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
---
This post is summary of my digital photography workflow and my ways for photo organization. It is a system developed during last 20 years. It would be good to explain my photo background first. My most common subject is capturing traveling trips, people in countryside, preferably mountains if I can help it.

![Vysoke Tatry](/img/tatry.jpg)
*The picture above is taken in Slovakia mountains called Vysoke Tatry (High Tatras).*

## Early days

I've been taking photos since I was small. Back then, I used 35mm film with full-manual cameras that were usually East Germany made, like [Praktica][1] SLR. The usual process was slow, you needed to finish your cassette with 24 or 36 frames and let it develop. This was not much fun, so when digital started to be usable, I quickly jumped that train and bought initially [Cannon A40][2] with 2 megapixel resolution. It is laughable these days, but back then it was great camera and I took tens of thousands pictures with it and learned a ton about photography that way.

![Canon A40](/img/canon-a40.jpg)

In the meantime Canon came with its first affordable DSLR (Canon Digital Rebel) and shortly after Nikon came with its [D70][3]. I was able to save some money and bought it along with standard 18-70 mm lens. This was huge step forward and I stayed with Nikon since then. Over the time I got some additional lenses, a flash, and a tripod. The DSLR experience is something that is hard to convey, but it is wonderful as a photographic tool. Every function is quickly accessible on external buttons, viewfinder is bright and clear, providing great control on depth of field, focus and camera settings.

![Nikon D70](/img/nikon-d70.jpg)

## Current equipment

Last iteration of Nikon DSLR I currently use is **Nikon D7200** camera. Over last cameras it has much better 24 megapixel sensor, even better viewfinder, great sport modes with fast focusing and wonderful image quality. Controls are taken from higher-level cameras, while keeping similar philosophy of usage.

![Nikon D7200](/img/nikon-d7200.jpg)

I use following lenses at the moment:

 - **Nikon 18-300mm f/3.5-6.3 ED AF-S DX VR** - my primary lens, very universal, flexible and lightweight. It produce nice images, although on long end it is a little soft
 - **Nikon 50mm f/1.8 AF-D** - fast prime lens with good bokeh
 - **Nikon 55-300mm f/4.5-5.6 ED DX VR** - provides faster and better quality telephoto for where the primary lens are not good enough
 - **Tokina 12-24mm f/4 (IF) DX** - awesome wide lens, probably best build quality lens I have
 - **Sigma 28-135mm f/3.8-5.6 MACRO** - pretty bad lens overall, but can provide 1:2 macro capability, which is only reason I still have it

There is also number of other devices that take pictures like cell phones of whole family.

## Photo gathering

From D7200 camera I usually download data directly from the SD cards, from cell phones I use USB connection to the device and download photos.  I have a folder called `00-Incoming` for the purpose. I try to make sure the devices are properly setup for the timezone where capture happened - in cell phones this happens automatically using operator synchronization, with the camera you need to setup the timezone manually. 

If it fails, there is an option to fix the time in downloaded photos using trick described in [one of previous posts on jhead tool]({% post_url 2015-09-20-jhead %}).

Once all files are gathered in the incoming I would like to rename all of them to format `YYMMDD-hhmmss-nn.jpg`, i.e. something like `210101-122046-00.jpg` and put the files into a one-day folder named `YYMMDD`. For the purpose I have script like this

```perl
use 5.16.3;
use File::Glob ':bsd_glob';

package ImageFile {
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

    method target_path() {
        return dir($self->date->strftime("%y%m%d"))
            ->file($self->date_time . sprintf("-%02d", $self->disambig) . $self->ext);
    }
};

use List::Util qw(reduce);
use Path::Class;

# default operation parameters
unless(@ARGV) {
    chdir("00-Incoming");
    @ARGV = "*.JPG";
}

my $escaped_argv = join " ", map { s/\"/^\"/g; "\"$_\"" } @ARGV;
open(my $in, "jhead.exe $escaped_argv|") or die "Could not pipe: $!\n";
my $last;
my @files;
while(my $line = <$in>) {
    # warn $line;
    chomp($line);
    my %items = $line =~ /^ ([^:]+?) \s* : \s* (.*?) \s*$ /gmx;
    if($items{"File name"}) {
        push @files, $last = ImageFile->new(name => $items{"File name"});
    }
    if(my $date = $items{"Date/Time"}) {
        if($date =~ /^(\d{2}\d{2}):(\d{2}):(\d{2}) (\d{2}):(\d{2}):(\d{2})/) {
            $last->date(Time::Moment->new(year => $1, month => $2, day => $3, hour => $4, minute => $5, second => $6));
        }
    }
}

# TODO: what about photos that already exist?  Keep a storage of names and use that for disambig?

# add disambiguation for names that would be the same
reduce { $a->date_time eq  $b->date_time && $b->disambig($a->disambig+1); $b }
  sort { $a->date_time cmp $b->date_time }
    @files;

# create dirs
my $action = 1;

my %dirs = ();
@dirs{map { $_->target_path->parent->absolute->stringify } @files } = ();
for my $dir (sort keys %dirs) {
    say "Create directory: $dir";
    if($action) {
        dir($dir)->mkpath();
    }
}

# all renames
for my $file (sort { $a->date_time cmp $b->date_time } @files) {
    next unless $file->valid_rename;
    say $file->name, " -> ", $file->target_path;
    if($action) {
        rename($file->name, $file->target_path);
    }
}
```

It uses EXIF date stored in the photos, as file dates can differ wildly. The `nn` numbering is useful if multiple photos were created in the same second. This usually happens quite rarely, either when continuous drive is used or when two people are capturing at the same time. With this completed, the incoming folder looks like this:

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

My photo collection is simple directory based structure. There is top level directory for each year, second level is per event, with directories named like `YYMMDD - Name of event`. This way it is easy to find the event, name sorting reflects the date and it keeps those information even if I take whole folder and move it somewhere else.

This structure is created manually by walking incoming folders and grouping them into an event. Most of short events can stay as they are (just add the name), but with longer trips I merge several together.

Inside the event folder, I work through the photos and pick those that I like even during the time of processing. It is often the case that I like the moment, but the photo is not too interesting. For the down-select, using [IrfanView][4] and its function `File/Copy File (F8)` transfer good photos into directory `choice`. If there is too many selected photos, I usually repeat the process until I have reasonable number of them. For events about week long, I like to end with 50-100 photos.

Once I have my selection, I move all other photos into subfolder `other` and the selection ends up at the top. With the post-processing, I want to keep originals in case I screw the editing up. For that, before the edit, original gets copied into subfolder `edited` (IfranView again). For editing, I have old Photoshop CS version 8.0 from 2003 which still works great for my purposes. The editing usually means:

 - **Crop the photo** to 2x3 format (can be printed to 10x15cm paper photo). Nikon already creates such format, for cell phone it needs some tweaking. The crop also allows to get rid of anything that does not belong to the photo and improves focus on the subject
 - Apply **Levels** to use whole range. The photos look better if they have some black and some white on it and at the same time it is possible to adjust mid-tones
 - If needed, change colors. I usually only play with Saturation to make the photo more vivid or muted
 - Locally darken/lighten. I usually do it with duplicating layers (with Screen or Multiply function) and editing the mask of top layer. You can add vignetting to the photo, emphasize the subject or hide something unimportant
 - Retouch if needed. I am trying to avoid this during the capture of the photo, but something the photo is good and just needs some minor adjustment

The resulting event folder looks like this

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

The photos are organized, selected and edited. Now for the one that will be used on my web page, I would like to add descriptions, tags and people on the photo. For long time I am using Windows Essentials 2012, which includes `Photo Gallery` program. It is no longer supported, but is still available for download on the internet. 

It allows to automatically detect faces on the photos with good suggestions and it learns from your selections. It will mark the faces in EXIF and add the list of people there.

You can also edit the caption and add descriptive tags. The latter feature is greatly done, you can define hierarchical tag going from general to more specific, separating each part with `/`. So your tags can be 

 - `Mountains/Alps/Raxalpe`
 - `Water/River/Thaya`
 - `Austria/City/Vienna`

When you start typing `Vienna`, you get full tag with more generic meanings.

Now we need some means to extract this information from the photo. In perl, there is nice module [Image::ExifTool][5] that allows exactly that. We will need following entries

 - CreateDate
 - ImageSize
 - Title
 - Subject
 - RegionPersonDisplayName

Let's extract the data

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

So far this works for me pretty well. At the moment I have much over hundred thousands photos in my collection. It is consistent, quite easy to find an event and get back to the data.

[1]: https://en.wikipedia.org/wiki/Praktica
[2]: https://global.canon/en/c-museum/product/dcc472.html
[3]: https://en.wikipedia.org/wiki/Nikon_D70
[4]: https://www.irfanview.com/
[5]: https://metacpan.org/pod/Image::ExifTool

*[SLR]: single-lens reflex
*[DSLR]: digital single-lens reflex
