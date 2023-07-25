package RbacDTO;

use strict;
use warnings;

sub new {
    my ( $class, $data ) = @_;
    my $self = {
        role_id       => undef,
        on_role_id    => undef,
        role_name     => undef,
        on_role_name  => undef,
        feature_name  => undef,
    };

    bless $self, $class;
    
    $self->set_id($data->{id})     if exists $data->{id};
    $self->set_id($data->{ID})     if exists $data->{ID};
    $self->set_role_id($data->{role_id}) if exists $data->{role_id};
    $self->set_on_role_id($data->{on_role_id}) if exists $data->{on_role_id};
    $self->set_on_role_name($data->{on_role_name}) if exists $data->{on_role_name};
    $self->set_role_name($data->{role_name}) if exists $data->{role_name};
    #$self->set_team($data->{team}) if exists $data->{team};
    $self->set_feature_name($data->{f_name}) if exists $data->{f_name};
    
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

sub get_k_feature_name {
    my ($self) = @_;
    my $k_f = "k_".$self->get_feature_name;
    $k_f;
}

sub get_f_ref {
    my ($self) = @_;
    $self->{f_ref} = '\&' . $self->get_feature_name;
    return $self->{f_ref};
}

1; # Don't forget to return a true value at the end of the module

