#!/usr/bin/perl
use Apache2::UcomOneTimeUrl;

my $title = @ARGV[0];
my $uri = @ARGV[1];
my $db = "/opt/secret/access.db";
print "http://fuga/contents/", Apache2::UcomOneTimeUrl->authorize($db, $title, $uri), ".webm\n";
