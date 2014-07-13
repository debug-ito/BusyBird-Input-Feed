
requires 'XML::FeedPP' => '0';
requires 'BusyBird::DateTime::Format' => '0';
requires 'DateTime::Format::ISO8601' => '0';
requires 'DateTime' => '0';
requires 'Try::Tiny' => '0';

on 'test' => sub {
    requires 'Test::More' => "0";
    requires 'Test::Deep' => '0.084';
    requires 'File::Spec' => '0';
    requires 'Test::Exception' => '0';
};

on 'configure' => sub {
    requires 'Module::Build', '0.42';
    requires 'Module::Build::Pluggable', '0.09';
    requires 'Module::Build::Pluggable::CPANfile', '0.02';
};
