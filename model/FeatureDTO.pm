package FeatureDTO;

use strict;
use warnings;
use Data::Dumper;

=head1 NAME

FeatureDTO - Data Transfer Object for representing a team

=head1 SYNOPSIS

  use FeatureDTO;

  # Create a new FeatureDTO object
  my $team = FeatureDTO->new();

  # Set the team data
  my $data = {
      id   => 1,
      name => 'Team A',
  };
  $team->set_data($data);

  # Get the team's ID and name
  my $team_id   = $team->get_id();
  my $team_name = $team->get_name();

  # Print the team's ID and name
  print "Team ID: $team_id\n";
  print "Team Name: $team_name\n";

=head1 DESCRIPTION

The FeatureDTO module represents a Data Transfer Object for a team.

=head1 METHODS

=head2 new()

Creates a new FeatureDTO object.

=head2 set_data($data)

Sets the team data based on the provided hash reference.

=over 4

=item * C<$data> - The hash reference containing the team data with keys 'id' and 'name'.

=back

=head2 set_id($id)

Sets the ID of the team.

=over 4

=item * C<$id> - The ID of the team.

=back

=head2 set_name($name)

Sets the name of the team.

=over 4

=item * C<$name> - The name of the team.

=back

=head2 get_id()

Returns the ID of the team.

=head2 get_name()

Returns the name of the team.

=head1 AUTHOR

Denis Komnenovic

=cut

sub new {
    my ($class, $data) = @_;
    
    print STDERR "xxxx__________===================================================\n";
    #print STDERR Dumper $data;
    print STDERR "===================================================\n";
    
    my $self = {
        id   => undef,
        name => undef,
	role => undef,
	on_role => undef,
	team => undef
    };
    
    bless $self, $class;
    
    $self->set_id($data->{id})     if exists $data->{id};
    $self->set_id($data->{ID})     if exists $data->{ID};
    #$self->set_name($data->{name}) if exists $data->{name};
    $self->set_role($data->{name}) if exists $data->{name};
    $self->set_on_role($data->{on_role}) if exists $data->{on_role};
    $self->set_team($data->{team}) if exists $data->{team};
    my @features; 
    
    map {
    	if ( $_ =~ m/feature.*/gi ){
		push ( @features, sprintf("%s", [ split /feature_/, $_ ]->[1] ) ); 
	}
    }  keys %{$data};

    $self->set_features(\@features);
    return $self;
}

sub set_features {
    my ($self, $features) = @_;
    # TODO : PLAUSIBILIIES
    $self->{features} = $features;    
}

sub get_features {
    my ($self) = @_;
    $self->{features};    
}

sub set_data {
    my ($self, $data) = @_;
    
    $self->set_id($data->{id})     if exists $data->{id};
    $self->set_name($data->{name}) if exists $data->{name};
}

sub set_id {
    my ($self, $id) = @_;
    
    # Perform plausibility check: ID must be a positive integer
    die "Invalid ID: $id" unless defined $id && $id =~ /^[1-9]\d*$/;
    
    $self->{id} = $id;
}

sub set_name {
    my ($self, $name) = @_;
    
    # Perform plausibility check: Name must be non-empty and contain only letters, numbers, and spaces
    #die "Invalid name: $name" unless defined $name && $name =~ /^[A-Za-z0-9\s]+$/;
    
    $self->{name}->{$name} = $name;
}

sub get_id {
    my ($self) = @_;
    return $self->{id};
}

sub get_name {
    my ($self) = @_;
    return $self->{name};
}

sub set_role {
    my ($self, $role) = @_;
    
    # Perform plausibility check: Name must be non-empty and contain only letters, numbers, and spaces
    #die "Invalid name: $name" unless defined $name && $name =~ /^[A-Za-z0-9\s]+$/;
    
    $self->{role} = $role;
}

sub get_role {
    my ($self) = @_;
    return $self->{role};
}

sub set_on_role {
    my ($self, $on_role) = @_;
    
    # Perform plausibility check: Name must be non-empty and contain only letters, numbers, and spaces
    #die "Invalid name: $name" unless defined $name && $name =~ /^[A-Za-z0-9\s]+$/;
    
    $self->{on_role} = $on_role;
}

sub get_on_role {
    my ($self) = @_;
    return $self->{on_role};
}

sub set_team {
    my ($self, $team) = @_;
    
    # Perform plausibility check: Name must be non-empty and contain only letters, numbers, and spaces
    #die "Invalid name: $name" unless defined $name && $name =~ /^[A-Za-z0-9\s]+$/;
    
    $self->{team} = $team;
}

sub get_team {
    my ($self) = @_;
    return $self->{team};
}

1;  # End of FeatureDTO module

