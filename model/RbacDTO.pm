package RbacDTO;

use strict;
use warnings;

sub new {
    my $class = shift;
    my $self = {
        role_id       => undef,
        on_role_id    => undef,
        role_name     => undef,
        on_role_name  => undef,
        feature_name  => undef,
    };

    bless $self, $class;
    return $self;
}

# Setters
sub set_role_id {
    my ($self, $role_id) = @_;
    $self->{role_id} = $role_id;
}

sub set_on_role_id {
    my ($self, $on_role_id) = @_;
    $self->{on_role_id} = $on_role_id;
}

sub set_role_name {
    my ($self, $role_name) = @_;
    $self->{role_name} = $role_name;
}

sub set_on_role_name {
    my ($self, $on_role_name) = @_;
    $self->{on_role_name} = $on_role_name;
}

sub set_feature_name {
    my ($self, $feature_name) = @_;
    $self->{feature_name} = $feature_name;
}

# Getters
sub get_role_id {
    my ($self) = @_;
    return $self->{role_id};
}

sub get_on_role_id {
    my ($self) = @_;
    return $self->{on_role_id};
}

sub get_role_name {
    my ($self) = @_;
    return $self->{role_name};
}

sub get_on_role_name {
    my ($self) = @_;
    return $self->{on_role_name};
}

sub get_feature_name {
    my ($self) = @_;
    return $self->{feature_name};
}

1; # Don't forget to return a true value at the end of the module

