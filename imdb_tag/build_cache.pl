#!/usr/bin/perl -w

use strict;

use IMDB::Film;
use File::Basename;
use IO::Handle;
use Cwd 'abs_path';


my $movie_file = abs_path($ARGV[0]);

my $index_file = '/tipi/.cache/index';

my $basename = basename($movie_file, (".avi", ".mkv", ".ogg"));

print $basename."\n";

open F, '<', $index_file;
my @list=<F>;close F;
my @grep_result=grep /$basename/,@list;

my $movie = new IMDB::Film( crit => $basename, cache => 1 );
#  $movie->search( $basename );
my $ttaa;
foreach $ttaa ( @{$movie->matched} ) {
  my %hu = %{$ttaa};
  while ((my $key, my $value) = each(%hu)) {
  # do something with $key and $value
    print "$key: $value\n";
   }
}
exit(0);
# si le film n'est pas dans l'index
if (@grep_result == 0) {
  my $movie = new IMDB::Film( crit => $basename, cache => 1 );
  

  if (!$movie->status) {
    my $io = new IO::Handle;
    print "Enter IMDB id for $basename: ";
    if ($io->fdopen(fileno(STDIN),"r")) {
      my $imdb_id = $io->getline;
      chomp($imdb_id);
      $movie = new IMDB::Film(crit => $imdb_id, cache => 1 );
      $io->close;
      if (!$movie->status) {
        print "$basename has not been found in IMDB.\n";
        exit(1);
      }
    }
  }
  open F, '>>', $index_file;
  print F $movie_file."%".$movie->id."\n";
  close F;
}

