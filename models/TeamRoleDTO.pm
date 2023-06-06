package TeamRoleDTO;

use strict;
use warnings;

sub new {
    my ($class, %args) = @_;
    my $self = bless \%args, $class;
    return $self;
}

sub id {
    my ($self) = @_;
    return $self->{id};
}

sub name {
    my ($self) = @_;
    return $self->{name};
}

# Add other getters and setters as needed

1;

