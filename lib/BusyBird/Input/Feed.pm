package BusyBird::Input::Feed;
use strict;
use warnings;
use XML::FeedPP;
use DateTime::Format::ISO8601;
use BusyBird::DateTime::Format;
use DateTime;
use Try::Tiny;
use Carp;
use WWW::Favicon ();
use LWP::UserAgent;

our $VERSION = "0.01";

our @CARP_NOT = qw(Try::Tiny XML::FeedPP);

sub new {
    my ($class, %args) = @_;
    my $self = bless {
        use_favicon => 1,
        favicon_detector => WWW::Favicon->new,
        ua => do {
            my $ua = LWP::UserAgent->new;
            $ua->env_proxy;
            $ua->timeout(20);
            $ua;
        }
    }, $class;
    if(defined($args{use_favicon})) {
        $self->{use_favicon} = $args{use_favicon};
    }
    return $self;
}

sub _get_home_url {
    my ($self, $feed, $statuses) = @_;
    my $home_url = $feed->link;
    return $home_url if defined $home_url;
    
    foreach my $status (@$statuses) {
        $home_url = $status->{busybird}{status_permalink} if defined($status->{busybird});
        return $home_url if defined $home_url;
    }
    return undef;
}

sub _get_favicon_url {
    my ($self, $feed, $statuses) = @_;
    my $home_url = $self->_get_home_url($feed, $statuses);
    return undef if not defined $home_url;
    my $favicon_url = $self->{favicon_detector}->detect($home_url);
    return undef if not defined $favicon_url;
    my $res = $self->{ua}->get($favicon_url);
    return undef if !$res->is_success;
    my $type = $res->header('Content-Type');
    return undef if defined($type) && $type !~ /^image/i;
    return $favicon_url;
}

sub _make_timestamp_datetime {
    my ($self, $timestamp_str) = @_;
    return undef if not defined $timestamp_str;
    if($timestamp_str =~ /^\d+$/) {
        return DateTime->from_epoch(epoch => $timestamp_str, time_zone => '+0000');
    }
    my $datetime = try { DateTime::Format::ISO8601->parse_datetime($timestamp_str) };
    return $datetime if defined $datetime;
    return BusyBird::DateTime::Format->parse_datetime($timestamp_str);
}

sub _make_status_from_item {
    my ($self, $feed_title, $feed_item) = @_;
    my $id = $feed_item->guid;
    $id = $feed_item->link if not defined $id;
    my $created_at_dt = $self->_make_timestamp_datetime($feed_item->pubDate);
    return {
        id => $id,
        text => $feed_item->title,
        busybird => { status_permalink => $feed_item->link },
        created_at => ($created_at_dt ? BusyBird::DateTime::Format->format_datetime($created_at_dt) : undef ),
        user => { screen_name => $feed_title },
    };
}

sub _make_statuses_from_feed {
    my ($self, $feed) = @_;
    my $feed_title = $feed->title;
    my $statuses = [ map { $self->_make_status_from_item($feed_title, $_) } $feed->get_item ];
    return $statuses if !$self->{use_favicon};
    my $favicon_url = $self->_get_favicon_url($feed, $statuses);
    return $statuses if not defined $favicon_url;
    $_->{user}{profile_image_url} = $favicon_url foreach @$statuses;
    return $statuses;
}

sub parse_string {
    my ($self, $string) = @_;
    return $self->_make_statuses_from_feed(XML::FeedPP->new($string, -type => "string", utf8_flag => 1));
}

*parse = *parse_string;

sub parse_file {
    my ($self, $filename) = @_;
    return $self->_make_statuses_from_feed(XML::FeedPP->new($filename, -type => "file", utf8_flag => 1));
}

sub parse_url {
    my ($self, $url) = @_;
    return $self->_make_statuses_from_feed(XML::FeedPP->new($url, -type => "url", utf8_flag => 1));
}

*parse_uri = *parse_url;

1;
__END__

=pod

=head1 NAME

BusyBird::Input::Feed - input BusyBird statuses from RSS/Atom feed

=head1 SYNOPSIS

    use BusyBird;
    use BusyBird::Input::Feed;
    
    my $input = BusyBird::Input::Feed->new;
    
    my $statuses = $input->parse($feed_xml);
    timeline("feed")->add($statuses);
    
    $statuses = $input->parse_file("feed.atom");
    timeline("feed")->add($statuses);
    
    $statuses = $input->parse_url('https://metacpan.org/feed/recent?f=');
    timeline("feed")->add($statuses);

=head1 DESCRIPTION

L<BusyBird::Input::Feed> converts RSS and Atom feeds into L<BusyBird> status objects.

=head1 CLASS METHODS

=head2 $input = BusyBird::Input::Feed->new(%args)

The constructor.

Fields in C<%args> are:

=over

=item C<use_favicon> => BOOL (optional, default: true)

If true (or omitted or C<undef>), it tries to use the favicon of the Web site providing the feed
as the statuses' icons.

If it's defined and false, it won't use favicon.

=back

=head1 OBJECT METHODS

=head2 $statuses = $input->parse($feed_xml_string)

=head2 $statuses = $input->parse_string($feed_xml_string)

Convert the given C<$feed_xml_string> into L<BusyBird> C<$statuses>.
C<parse()> method is an alias for C<parse_string()>.

C<$feed_xml_string> is the XML data to be parsed.
It must be a string encoded in UTF-8.

Return value C<$statuses> is an array-ref of L<BusyBird> status objects.

If C<$feed_xml_string> is invalid, it croaks.

=head2 $statuses = $input->parse_file($feed_xml_filename)

Same as C<parse_string()> except C<parse_file()> reads the file named C<$feed_xml_filename> and converts its content.

=head2 $statuses = $input->parse_url($feed_xml_url)

=head2 $statuses = $input->parse_uri($feed_xml_url)

Same as C<parse_string()> except C<parse_url()> downloads the feed XML from C<$feed_xml_url> and converts its content.

C<parse_uri()> method is an alias for C<parse_url()>.

=head1 SEE ALSO

=over

=item *

L<BusyBird>

=item *

L<BusyBird::Manual::Status>

=back

=head1 REPOSITORY

L<https://github.com/debug-ito/BusyBird-Input-Feed>

=head1 BUGS AND FEATURE REQUESTS

Please report bugs and feature requests to my Github issues
L<https://github.com/debug-ito/BusyBird-Input-Feed/issues>.

Although I prefer Github, non-Github users can use CPAN RT
L<https://rt.cpan.org/Public/Dist/Display.html?Name=BusyBird-Input-Feed>.
Please send email to C<bug-BusyBird-Input-Feed at rt.cpan.org> to report bugs
if you do not have CPAN RT account.


=head1 AUTHOR
 
Toshio Ito, C<< <toshioito at cpan.org> >>


=head1 LICENSE AND COPYRIGHT

Copyright 2014 Toshio Ito.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See L<http://dev.perl.org/licenses/> for more information.


=cut

