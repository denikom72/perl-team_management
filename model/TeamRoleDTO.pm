package TeamRoleDTO;

use strict;
use warnings;
use Data::Dumper;

=head1 NAME

TeamRoleDTO - Data Transfer Object for representing a team

=head1 SYNOPSIS

  use TeamRoleDTO;

  # Create a new TeamRoleDTO object
  my $team = TeamRoleDTO->new();

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

The TeamRoleDTO module represents a Data Transfer Object for a team.

=head1 METHODS

=head2 new()

Creates a new TeamRoleDTO object.

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
    print STDERR Dumper $data;
    print STDERR "===================================================\n";
    
    my $self = {
        id   => undef,
        name => undef,
    };
    
    bless $self, $class;
    
    $self->set_id($data->{id})     if exists $data->{id};
    $self->set_id($data->{ID})     if exists $data->{ID};
    $self->set_name($data->{name}) if exists $data->{name};
    
    return $self;
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
    
    $self->{name} = $name;
}

sub get_id {
    my ($self) = @_;
    return $self->{id};
}

sub get_name {
    my ($self) = @_;
    return $self->{name};
}

1;  # End of TeamRoleDTO module

