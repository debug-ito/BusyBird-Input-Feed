use strict;
use warnings;
use Test::More;
use LWP::UserAgent;
use BusyBird::Input::Feed;

my @request_log = ();
my $useragent = do {
    my $lwp = LWP::UserAgent->new();
    $lwp->env_proxy;
    $lwp->add_handler(request_send => sub {
        my ($request) = @_;
        push @request_log, $request;
        return;
    });
    $lwp;
};

my $input = BusyBird::Input::Feed->new(user_agent => $useragent);
my $statuses = $input->parse_url('https://metacpan.org/feed/recent?f=');
cmp_ok scalar(@$statuses), '>', 0, 'at least 1 statuses loaded';
cmp_ok scalar(@request_log), '>', 0, 'communication logged.';
cmp_ok scalar(grep { $_->uri eq 'https://metacpan.org/feed/recent?f=' } @request_log), '>', 0, 'logged fetching feed URL';
cmp_ok scalar(grep { $_->uri eq 'https://metacpan.org/' } @request_log), '>', 0, 'logged fetching main URL';
cmp_ok scalar(grep { $_->uri =~ qr/favicon\.ico/ } @request_log), '>', 0, 'logged fetching favicon';

done_testing;
