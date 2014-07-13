use strict;
use warnings;
use Test::More;
use BusyBird::Input::Feed;
use LWP::UserAgent;
use File::Spec;

my $input = BusyBird::Input::Feed->new;
my $ua = LWP::UserAgent->new;
$ua->env_proxy;

{
    my $got_statuses = $input->parse_file(File::Spec->catfile(qw(. t samples stackoverflow.atom)));
    my $got_status = $got_statuses->[0];
    like $got_status->{user}{profile_image_url}, qr{^https?://}, "user.profile_image_url looks like URL";
    my $res = $ua->get($got_status->{user}{profile_image_url});
    ok $res->is_success, "Succeed to get favicon $got_status->{user}{profile_image_url}";
}

fail("TODO: testcase where favicon URL is the simple /favicon.ico");


{
    my $got_statuses = $input->parse_file(File::Spec->catfile(qw(. t samples pukiwiki_rss09.rss)));
    my $got_status = $got_statuses->[0];
    is $got_status->{user}{profile_image_url}, undef, "user.profile_image_url should be undef because this site does not have favicon";
}

done_testing;


