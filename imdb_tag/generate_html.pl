#!/usr/bin/perl -w

use strict;

my $cache_root = '/tipi/.cache/';
# create a list of all *.html files in
# the current directory
opendir(DIR, $cache_root);
my @files = grep(/\.info$/,readdir(DIR));
closedir(DIR);

open HTML, '>', $cache_root."list.html" or die $!;

print HTML "<html>\n";
print HTML "<body>\n";
print HTML "<table border=\"1\">\n";

# print all the filenames in our array
foreach my $file (@files) {
  open INFO, '<', $cache_root.$file or die $!;
  my %info = ();
  while (my $line = <INFO>) {
    (my $key, my $value) = split(/: /, $line);
    $info{$key} = $value;
  }
  print HTML "<tr><td>\n";
  print HTML $info{'filename'}."<br>\n";
  print HTML "Title: ".$info{'title'}." (".$info{'year'}.")<br>\n";
  print HTML "Director: ".$info{'director'}."<br>\n";
  print HTML "Cast: ".$info{'cast'}."<br>\n";
  print HTML "Plot: ".substr($info{'plot'}, 0, 250)."<br>\n";
  print HTML "</td><td>";
  print HTML "<img src=\"".$info{'coverart'}."\"/>\n";
  print HTML "</td></tr>";

  close INFO;
}

print HTML "</html>\n";
print HTML "</body>\n";
print HTML "</table>\n";

close HTML;

