package BusyBird::Input::Feed;
use strict;
use warnings;

our $VERSION = "0.01";

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

C<$feed_xml_string> is the XML data to be parsed. It should be an encoded octet string.

Return value C<$statuses> is an array-ref of L<BusyBird> status objects.

If C<$feed_xml_string> is invalid, it croaks.

=head2 $statuses = $input->parse_file($feed_xml_filename)

Same as C<parse_string()> except C<parse_file()> reads the file named C<$feed_xml_filename> and converts its content.

=begin comment

... should we accept parameter to specify the file encoding?

=end comment

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

