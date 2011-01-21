#!/usr/bin/perl -w

use strict;

use IMDB::Film;

my $cache_root = '/tipi/.cache/';
my $index_file = $cache_root.'index';

open INDEX, '<', $index_file or die $!;

while (my $line = <INDEX>) {
  (my $filename, my $imdb_id) = split(/%/, $line);
  chomp($imdb_id);
  my $imdbObj = new IMDB::Film(crit => $imdb_id);
  
  open FILE, '>', $cache_root.$imdb_id.".info" or die $!;
  
  if($imdbObj->status) {
    print "Processing ".$imdbObj->title()."\n";
    print FILE "filename: $filename\n";
    print FILE "id: ".$imdb_id."\n";
    print FILE "title: ".$imdbObj->title()."\n";
    my @directors = @{ $imdbObj->directors() };
    print FILE "director: ".$directors[0]{'name'}."\n";
    print FILE "year: ".$imdbObj->year()."\n";
    print FILE "plot: ".$imdbObj->full_plot()."\n";
    print FILE "coverart: ".$imdbObj->cover()."\n";
    #print "Genre: ".$imdbObj->genres()."\n";
    my @cast = @{ $imdbObj->cast() };
    print FILE "cast: ";
    for (my $i = 0; $i < 3; $i++) {
      print FILE $cast[$i]{'name'}.", ";
    }
    print FILE "\n";
  } else {
    print "Something wrong with $imdb_id: ".$imdbObj->error."\n";
  }
  close FILE;

}
