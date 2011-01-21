#!/usr/bin/perl -w


use Getopt::Std;
use IO::Handle;
use IMDB::Film;
use Env qw(HOME);
use Cwd 'abs_path';

use strict;

sub search_film {
  my $movie_path = @_;
  my $basename = basename($movie_file, (".avi", ".mkv", ".ogg"));
  my $movie = new IMDB::Film( crit => $basename, cache => 1 );
  # If there are multiple results
  if ( defined $movie->matched ) {
    foreach my $matched ( @{$movie->matched} ) {
      my %hu = %{$matched};
      while ((my $key, my $value) = each(%hu)) {
        # do something with $key and $value
        print "$key: $value\n";
      }
    }
  }

}

sub usage {
  print "$0 allows you to modify the IMDB id for a given movie file in the index\n";
  print "Usage: $0 [-h] -p movie_path [-i imdb_id] [-m]\n";
  print "Allows to modify an existing movie file in the index, or to add a new one if movie path is not found\n";
  print "  -p : movie path \n";
  print "  -c : cache root path \n";
  print "  -i : IMDB id (optional)\n";
  print "       IMDB id must be the form: xxxxxx where x is a number\n";
  print "  -m : append movie info even if already in index";
  print "  -h : print this help\n";
}


my %opt;
getopts('hp:i:c:', \%opt) or usage();


if ( !$opt{'p'} or $opt{'h'} ) {
  print "You must define at least the filename";
  usage();
  exit(1);
}

# Define cache root path, with the option OR by default
my $cache_root;
if ( !defined $opt{'c'} ) {
  $cache_root = "$HOME/.cache/";
}
else {
  $cache_root = $opt{'c'};
}
my $index_file = $cache_root.'index';

# Test if movie file exists
#if ( ! -e $opt{'p'} ) {
#  print "$opt{'p'} does not exist\n";
#  exit(1);
#}
#my $movie_path = abs_path($opt{'p'});
my $movie_path = $opt{'p'};

# Search in index if movie_path is present
open F, '<', $index_file;
my @list=<F>;close F;
my @grep_result=grep /$movie_path/,@list;

# If the movie is not in the index, OR if user defined option -m we must search for the movie
if (@grep_result == 0 or defined $opt{'m'}) {
  my $imdb_id;
# If user defined the IMDB id in the parameters
  if ( !defined $opt{'i'} ) {

    my $io = new IO::Handle;
    print "Enter IMDB id for $movie_path: ";
    if ($io->fdopen(fileno(STDIN),"r")) {
      $imdb_id = $io->getline;
      chomp($imdb_id);
    }
    $io->close;
  }
  else {
    $imdb_id = $opt{'i'};
  }

  my $movie = new IMDB::Film(crit => $imdb_id, cache => 1 );
  if (!$movie->status) {
    print "id '$imdb_id' has not been found in IMDB.\n";
    exit(1);
  }
  else {
    $imdb_id = $movie->id;
    my $title = $movie->title();
    print "$movie_path is now linked with $title\n";
  }

  # If movie_path is not in the index, we add it in the end of index
  if (@grep_result == 0) {
    open F, '>>', $index_file;
    print F "$movie_path%$imdb_id\n";
    close F;
  }
  # Else, we modify its line
  else {
    open F, '>', $index_file;
    foreach my $line (@lines) {
      print "$line\n$movie_path\n";
      chomp($line);
      if ( $line =~ m/'$movie_path.*'/ ) {
        print F "$movie_path%$imdb_id\n";
      }
      else {
        print F "$line\n";
      }
    }
    close F;

  }
}
else {
  print "Movie $movie_path is already in index";
}
