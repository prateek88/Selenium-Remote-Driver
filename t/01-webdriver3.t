use strict;
use warnings;

use Test::More;
use Test::Deep;

use Selenium::Remote::Driver;
use Selenium::Firefox::Profile;

#So we only modify _request_new_session to get webd3 working.
#As such, we should only test that.
NEWSESS: {

    #TODO cover case where ISA Selenium::Firefox
    my $self = bless({ is_wd3 => 1 },"Selenium::Remote::Driver");
    my $profile = Selenium::Firefox::Profile->new();
    $profile->set_preference(
        'browser.startup.homepage' => 'http://www.google.com',
    );
    my $args = {
        desiredCapabilities => {
            browser_name       => 'firefox',
            remote_server_addr => 'localhost',
            port               => 4444,
            version            => 666,
            platform           => 'ANY',
            javascript         => 1,
            accept_ssl_certs   => 1,
            firefox_profile    => $profile,
            proxy => {
                proxyType => 'direct',
                proxyAutoconfigUrl => 'http://localhost',
                ftpProxy           => 'localhost:1234',
                httpProxy          => 'localhost:1234',
                sslProxy           => 'localhost:1234',
                socksProxy         => 'localhost:1234',
                socksVersion       => 2,
                noProxy            => ['http://localhost'],
            },
            extra_capabilities => { #TODO these need to be translated as moz:firefoxOptions => {} automatically, and then to be put in the main hash
                binary  => '/usr/bin/firefox',
                args    => ['-profile', '~/.mozilla/firefox/vbdgri9o.default'],
                profile => 'some Base64 string of a zip file. I should really make this a feature',
                log     => 'trace', #trace|debug|config|info|warn|error|fatal
                prefs   => {}, #TODO check that this is auto-set above by the Selenium::Firefox::Profile stuff
                webdriverClick => 0, #This option is OP, *must* be set to false 24/7
            },
        },
    };

    no warnings qw{redefine once};
    local *Selenium::Remote::RemoteConnection::request = sub {return { sessionId => 'zippy', cmd_status => 'OK' }};
    local *File::Temp::newdir = sub { return bless { DIRNAME => '/tmp/zippy' }, 'File::Temp::Dir' };
    use warnings;

    my ($args_modified,undef) = $self->_request_new_session($args);

    my $expected = {
        'alwaysMatch' => {
            'browserVersion'     => 666,
            'moz:firefoxOptions' => {
                'args' => [
                    '-profile',
                    '/tmp/zippy'
                ],
                'binary'  => '/usr/bin/firefox',
                'log'     => 'trace',
                'prefs'   => {},
                'profile' => 'some Base64 string of a zip file. I should really make this a feature',
                'webdriverClick' => 0
            },
            'platformName' => 'ANY',
            'proxy'        => {
                'ftpProxy'           => 'localhost:1234',
                'httpProxy'          => 'localhost:1234',
                'noProxy'            => [
                    'http://localhost'
                ],
                'proxyAutoconfigUrl' => 'http://localhost',
                'proxyType'          => 'direct',
                'socksProxy'         => 'localhost:1234',
                'socksVersion'       => 2,
                'sslProxy'           => 'localhost:1234'
            }
        }
    };

    is_deeply($args_modified->{capabilities},$expected,"Desired capabilities correctly translated (WD3)");
}

done_testing();
