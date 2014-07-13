use strict;
use warnings;
use Test::More;
use utf8;
use BusyBird::Input::Feed;
use Test::Deep 0.084 qw(cmp_deeply superhashof);
use File::Spec;

sub check_case {
    my ($label, $got_statuses, $case) = @_;
    is scalar(@$got_statuses), $case->{exp_num}, "$label: num of statuses OK";
    foreach my $i (0 .. $#{$case->{exp_partial}}) {
        my $got = $got_statuses->[$i];
        my $exp = $case->{exp_partial}[$i];
        cmp_deeply $got, superhashof($exp), "$label: status $i OK";
    }
}

my $input = BusyBird::Input::Feed->new(use_favicon => 0);

## Only the statuses at the head are checked. Only status fields
## present in the expected statuses are checked.

my @testcases = (
    { filename => 'rtcpan.rdf',
      exp_num => 15,
      exp_partial => [
          ## If <guid> is not present, use <link>.
          { id => 'https://rt.cpan.org/Ticket/Display.html?id=84118',
            text => 'I really beg you to take back the exception catching feature in Future 0.11',
            busybird => { status_permalink => 'https://rt.cpan.org/Ticket/Display.html?id=84118' },
            created_at => 'Thu Mar 21 12:36:07 +0000 2013',
            user => { screen_name => q{rt.cpan.org: Search Queue = 'future'} }},
          { id => 'https://rt.cpan.org/Ticket/Display.html?id=84187',
            text => 'needs_all() throws an exception when immediate failed subfutures are given',
            busybird => { status_permalink => 'https://rt.cpan.org/Ticket/Display.html?id=84187' },
            created_at => 'Mon Mar 25 05:09:05 +0000 2013',
            user => { screen_name => q{rt.cpan.org: Search Queue = 'future'} }},
          { id => 'https://rt.cpan.org/Ticket/Display.html?id=84188',
            text => 'Error message is not user-friendly for followed_by(), and_then(), or_else() and repeat()',
            busybird => { status_permalink => 'https://rt.cpan.org/Ticket/Display.html?id=84188' },
            created_at => 'Mon Mar 25 05:10:30 +0000 2013',
            user => { screen_name => q{rt.cpan.org: Search Queue = 'future'} }},
          { id => 'https://rt.cpan.org/Ticket/Display.html?id=84189',
            text => 'Behavior of repeat {...} foreach => [] may be counter-intuitive',
            busybird => { status_permalink => 'https://rt.cpan.org/Ticket/Display.html?id=84189' },
            created_at => 'Mon Mar 25 05:12:20 +0000 2013',
            user => { screen_name => q{rt.cpan.org: Search Queue = 'future'}}}
      ]},
    { filename => 'slashdot.rss',
      exp_num => 25,
      exp_partial => [
          ## use <guid> for id
          { id => 'http://slashdot.feedsportal.com/c/35028/f/647410/s/3c35f940/sc/38/l/0Lhardware0Bslashdot0Borg0Cstory0C140C0A70C0A60C0A0A392340Cby0E20A450Ethe0Etop0Especies0Ewill0Eno0Elonger0Ebe0Ehumans0Eand0Ethat0Ecould0Ebe0Ea0Eproblem0Dutm0Isource0Frss10B0Amainlinkanon0Gutm0Imedium0Ffeed/story01.htm',,
            text => q{By 2045 'The Top Species Will No Longer Be Humans,' and That Could Be a Problem},
            busybird => { status_permalink => 'http://rss.slashdot.org/~r/Slashdot/slashdot/~3/HdnfMBYoOr4/story01.htm' },
            created_at => 'Sun Jul 06 03:15:00 +0000 2014',
            user => { screen_name => 'Slashdot' }},
          { id => 'http://slashdot.feedsportal.com/c/35028/f/647410/s/3c35c953/sc/32/l/0Lscience0Bslashdot0Borg0Cstory0C140C0A70C0A60C0A0A42540Ctwo0Eearth0Elike0Eexoplanets0Edont0Eactually0Eexist0Dutm0Isource0Frss10B0Amainlinkanon0Gutm0Imedium0Ffeed/story01.htm',
            text => q{Two Earth-Like Exoplanets Don't Actually Exist},
            busybird => { status_permalink => 'http://rss.slashdot.org/~r/Slashdot/slashdot/~3/NcsdVQtQOQQ/story01.htm' },
            created_at => 'Sun Jul 06 00:33:00 +0000 2014',
            user => { screen_name => 'Slashdot' }},
      ]},
    { filename => 'stackoverflow.atom',
      exp_num => 30,
      exp_partial => [
          { id => 'http://stackoverflow.com/q/24593005',
            text => 'How to write Unit Test for IValidatableObject Model',
            busybird => { status_permalink => 'http://stackoverflow.com/questions/24593005/how-to-write-unit-test-for-ivalidatableobject-model' },
            
            ## use <updated> date
            created_at => 'Sun Jul 06 05:33:05 +0000 2014',
            user => { screen_name => 'Recent Questions - Stack Overflow' }},
          { id => 'http://stackoverflow.com/q/24593002',
            text => 'hide softkeyboard when it is called from menuitem',
            busybird => { status_permalink => 'http://stackoverflow.com/questions/24593002/hide-softkeyboard-when-it-is-called-from-menuitem' },
            created_at => 'Sun Jul 06 05:31:56 +0000 2014',
            user => { screen_name => 'Recent Questions - Stack Overflow' }},
      ]},
    { filename => 'googlejp.atom',
      exp_num => 25,
      exp_partial => [
          { id => 'tag:blogger.com,1999:blog-20042392.post-2515664455683743324',

            ## status text should be decoded.
            text => 'あたらしい「ごちそうフォト」で、あなたがどんな食通かチェックしましょう。',

            ## if there are multiple <link>s, use rel="alternate".
            busybird => { status_permalink => 'http://feedproxy.google.com/~r/GoogleJapanBlog/~3/RP_M-WXr_6I/blog-post.html' },
            created_at => 'Mon Jul 07 11:50:02 +0900 2014',
            user => { screen_name => 'Google Japan Blog' }},
          
          { id => 'tag:blogger.com,1999:blog-20042392.post-4467811587369881889',
            text => '最新の Chrome Experiment でキック、ドリブル、シュートを楽しもう!',
            busybird => { status_permalink => 'http://feedproxy.google.com/~r/GoogleJapanBlog/~3/qztQgCPoisw/chrome-experiment.html' },
            created_at => 'Fri Jun 20 16:02:52 +0900 2014',
            user => { screen_name => 'Google Japan Blog' }},
      ]},
    { filename => 'slashdotjp.rdf',
      exp_num => 13,
      exp_partial => [
          { id => 'http://linux.slashdot.jp/story/14/07/09/097242/',
            text => 'ミラクル・リナックス、ソフトバンク・テクノロジーに買収される',
            busybird => { status_permalink => 'http://linux.slashdot.jp/story/14/07/09/097242/' },
            created_at => 'Wed Jul 09 09:44:00 +0000 2014',
            user => { screen_name => 'スラッシュドット・ジャパン' }},
          { id => 'http://yro.slashdot.jp/story/14/07/09/0533213/',
            text => 'バイオハザードを手がけた三上真司氏の新作ホラーゲームはDLCでCERO Z相当になる',
            busybird => { status_permalink => 'http://yro.slashdot.jp/story/14/07/09/0533213/' },
            created_at => 'Wed Jul 09 08:55:00 +0000 2014',
            user => { screen_name => 'スラッシュドット・ジャパン' }},
      ]}
);

foreach my $case (@testcases) {
    my $filepath = File::Spec->catfile(".", "t", "samples", $case->{filename});
    check_case "$case->{filename} parse_file()", $input->parse_file($filepath), $case;
    open my $file, "<", $filepath or die "Cannot open $filepath: $!";
    my $data = do { local $/; <$file> };
    check_case "$case->{filename} parse()", $input->parse($data), $case;
    check_case "$case->{filename} parse_string()", $input->parse_string($data), $case;
    close $file;
}

done_testing;

