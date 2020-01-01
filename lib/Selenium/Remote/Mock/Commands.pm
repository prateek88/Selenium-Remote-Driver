package Selenium::Remote::Mock::Commands;

# ABSTRACT: utility class to mock Selenium::Remote::Commands

use strict;
use warnings;

use Moo;
extends 'Selenium::Remote::Commands';

=for Pod::Coverage *EVERYTHING*

=cut

# override get_params so we do not rewrite the parameters

sub get_params {
    my $self    = shift;
    my $args    = shift;
    my $data    = {};
    my $command = delete $args->{command};
    $data->{'url'}                = $self->get_url($command);
    $data->{'method'}             = $self->get_method($command);
    $data->{'no_content_success'} = $self->get_no_content_success($command);
    $data->{'url_params'}         = $args;
    return $data;
}

sub get_method_name_from_parameters {
    my $self        = shift;
    my $params      = shift;
    my $method_name = '';
    my $cmds        = $self->get_cmds();
    foreach my $cmd ( keys %{$cmds} ) {
        if (   ( $cmds->{$cmd}->{method} eq $params->{method} )
            && ( $cmds->{$cmd}->{url} eq $params->{url} ) )
        {
            $method_name = $cmd;
            last;
        }
    }
    return $method_name;
}

1;

__END__

=pod

=head1 DESCRIPTION

Utility class to be for testing purposes, with L<Selenium::Remote::Mock::RemoteConnection> only.

=cut
