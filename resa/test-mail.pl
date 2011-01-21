#!/usr/bin/perl -w

use strict;
use warnings;

use DateTime;
use Getopt::Long qw(:config no_getopt_compat);
use Sys::Hostname;
use Term::ANSIColor;

sub sendEmail
{
  my ($to, $from, $subject, $message) = @_;
  utf8::decode($message);
  my $sendmail = '/usr/lib/sendmail';
  open(MAIL, "|$sendmail -oi -t");
  print MAIL "From: $from\n";
  print MAIL "To: $to\n";
  print MAIL "Subject: $subject\n\n";
  print MAIL "$message\n";
  close(MAIL);
}

  my $mail_message = <<END_MAIL;
Bonjour,

idrouille sera réservé de à poulet

Merci de contacter toto à jreybert\@gmail.com en cas de problème.

-- 
L'ordinateur
END_MAIL
  sendEmail("reybert\@imag.fr", "jreybert\@gmail.com", "Réservation idrouille", $mail_message);

