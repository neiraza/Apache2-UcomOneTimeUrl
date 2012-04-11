package Apache2::UcomOneTimeUrl;

use 5.008008;
use strict;
use warnings;
use Apache2::RequestIO ();
use Apache2::Const -compile => ':common';
use Apache2::SubRequest ();
use Apache2::ServerUtil ();
use MLDBM qw(DB_File);
use Apache2::RequestRec ();
use Apache2::RequestUtil ();
use Digest::MD5 qw(md5_hex);
use Data::Dumper;

 sub handler {
    my $class = __PACKAGE__;
    my $r = shift;
    $r->path_info() =~ /([a-f0-9]{32})/ or return Apache2::Const::DECLINED;
    my $key = $1;
    my %o;
    my $db = $r->dir_config("OneTimeDb") or die "Database not specified in OneTimeDb!";
    tie %o , "MLDBM", $db or die "Couldn't not open database! $db: $!";
    if(!$o{$key}){
        die "Thre is no data available!!!";
    }
    my $stuff = $o{$key};
    if($stuff->{count}++ > 10){
#       $o{$key} = $stuff;
#       untie %o;
#       return $class->intruder($r, $stuff);
    }
    $o{$key} = $stuff;
    untie %o;
    return $class->deliver($r, $key);
 }

 sub deliver {
     my ($class, $r, $key) = @_;
     my %o;
     my $db = $r->dir_config("OneTimeDb") or die "Database not specified in OneTimeDb!";
     tie %o , "MLDBM", $db or die "Couldn't not open database! $db: $!"; 
     if(!$o{$key}){
         die "Thre is no data available!!!"; 
     }
     my $stuff = $o{$key};
     my $subr = $r->lookup_uri($stuff->{uri});
     return $subr->run;
 }

 sub authorize {
     my ($class, $db, $title, $uri) = @_;
     my $key = md5_hex(time().{}.rand().$$);
     my %o;
     tie %o, "MLDBM", $db or die "Couldn't open database: $!";
     $o{$key} = {
         title => $title,
         uri => $uri,
         count => 0,
         created => time
     };
     untie %o;
     return $key;
 }

 sub intruder {
     my ($class, $r, $hash) = @_;
     $r->content_type("text/html");
     print "<HTML><HEAD><title>Unauthorized access</title></HEAD>
         <BODY>You are not authorized to access this resource.
          This attempt has been recorded.</BODY></HTML>";
     return Apache2::Const::OK;
 }

1;
__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Apache2::UcomOneTimeUrl - One-Time use URLs(URIs) for senstive data

=head1 SYNOPSIS

PerlModule Apache2::UcomOneTimeUrl
<Location /contents>
  SetHandler perl-script
  PerlResponseHandler Apache2::UcomOneTimeUrl
  PerlSetVar OneTimeDb /opt/secret/access.db
  PerlSetVar OneTimeUri ../webm/sample5m_1thread_sd_6m50s.webm
</Location>

F<authorize.pl>:
#!/usr/bin/perl
use Apache2::UcomOneTimeUrl;
use Data::Dumper;

my $comments = join " ", @ARGV;
print Dumper("comments:".$comments);
my $db = "/opt/secret/access.db";
print Dumper("db:".$db);
print "http://172.27.20.25/contents/", Apache2::UcomOneTimeUrl->authorize($db, $comments), ".webm\n";

Now:

    #hogehogefugafuga is any word
    % authorize.pl hogehogefugafuga
    http://172.27.20.25/contents/2c61de78edd612cf79c0d73a3c7c94fb

=head1 DESCRIPTION

Stub documentation for Apache2::UcomOneTimeUrl, created by h2xs. It looks like the
author of the extension was negligent enough to leave the stub
unedited.

Blah blah blah.

=head2 EXPORT

None by default.



=head1 SEE ALSO

Mention other useful documentation such as the documentation of
related modules or operating system documentation (such as man pages
in UNIX), or any relevant external documentation such as RFCs or
standards.

If you have a mailing list set up for your module, mention it here.

If you have a web site set up for your module, mention it here.

=head1 AUTHOR

A. U. Thor, E<lt>ucomadmin@localdomainE<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2010 by A. U. Thor

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.8.8 or,
at your option, any later version of Perl 5 you may have available.


=cut
