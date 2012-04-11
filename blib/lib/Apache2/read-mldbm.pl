#!/usr/bin/perl
use MLDBM qw(DB_File);
use Data::Dumper;

my $key = @ARGV[0];
print Dumper("key: ".$key);
my $db = "/opt/secret/access.db";
print Dumper("db: ".$db);
print Dumper("http://172.27.20.25/contents/".$key.".webm");
my %o;
tie %o, "MLDBM", $db or die "Couldn't open database: $!";
if(!$o{$key}){
    die "Thre is no data available!!!";
}
my $stuff = $o{$key};
print "stuff->{count}: ".$stuff->{count}."\n";
print "stuff->{title}: ".$stuff->{title}."\n";
print "stuff->{uri}: ".$stuff->{uri}."\n";
print "stuff->{created}: ".$stuff->{created}."\n";
