#!/usr/bin/perl -w

use strict;
use warnings;

use LWP::Simple;
use HTML::TreeBuilder::XPath;
use File::Basename;

my $save_path = 'xkcd';
my $base_url = 'http://xkcd.com';
my $html = get $base_url;

my $tree = HTML::TreeBuilder::XPath->new_from_content($html);

my $latest_comic = $tree->findvalue('(//a[@rel="prev"]/@href)[1]');
$latest_comic = ($1 + 1) if ($latest_comic =~ m/(\d+)/);

for(my $i=1; $i<=$latest_comic; $i++) {
    my $curr_comic_html = get sprintf('%s/%s', $base_url, $i);
    my $comic_tree = HTML::TreeBuilder::XPath->new_from_content($curr_comic_html);
    my $comic_image_url = $comic_tree->findvalue('//div[@id="comic"]/img/@src');

    my $save_to = sprintf("%s/%s", $save_path, fileparse($comic_image_url));

    if (! -e  $save_to) {
        print sprintf("xkcd #%s does not exist @ %s. saving...\n", $i, $save_to);
        getstore($comic_image_url, $save_to);
    } else {
        print sprintf("xkcd #%s exists @ %s. skipping...\n", $i, $save_to);
    }

    sleep 1;
}
