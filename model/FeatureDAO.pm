package TeamRoleDAO;

use strict;
use warnings;
use lib "model";
use TeamRoleDTO;
use Data::Dumper;

=head1 NAME

TeamRoleDAO - Data Access Object for managing team_roles

=head1 SYNOPSIS

  use TeamRoleDAO;

  # Create a TeamRoleDAO instance
  my $role_dao = TeamRoleDAO->new($db);

  # Retrieve team_roles
  my $team_roles_ref = $role_dao->get_team_roles();

  # Process the team_roles data
  foreach my $role (@$team_roles_ref) {
      # Do something with the role data
  }


=head1 DESCRIPTION

The TeamRoleDAO module provides an interface for interacting with the team_roles database table.

=head1 METHODS

=head2 new($db)

Creates a new TeamRoleDAO object.


=head2 get_team_roles()

Retrieves all team_roles from the team_roles table.

Returns an array reference containing role data.

=head1 AUTHOR

Denis Komnenovic

=cut

sub new {
    my ($class, $db) = @_;

    my $self = {
        db     => $db 
    };

    bless $self, $class;
    return $self;
}


sub get_roles {
    my ($self ) = @_;

    my $query = "SELECT * FROM team_roles";
    my $dbh   = $self->{db}->get_dbh();
    my $sth = $dbh->prepare($query);
    $sth->execute();
    
    my @team_roles;
    
    while (my $role_data = $sth->fetchrow_hashref) {
        
	my $team_role = TeamRoleDTO->new();
	$team_role->set_data($role_data);
	push @team_roles, $team_role;
    }
    
    $sth->finish;

    return \@team_roles;
}

sub save_role {

    my ($self, $role ) = @_;

    #print STDERR "XXXXXXXXXXXXXXXXXXX===================================================\n";
    #print STDERR Dumper $role;
    #print STDERR "===================================================\n";
    
    my $query = " UPDATE team_roles SET name = ? WHERE id = ? ";
    my $dbh   = $self->{db}->get_dbh();
    my $sth = $dbh->prepare($query);
    $sth->execute( $role->get_name, $role->get_id );
}

sub create_role {

    my ($self, $role ) = @_;

    
    print STDERR "IIIIIIIIIIIIIIIIIIIIIIIIIIIIII===================================================\n";
    print STDERR Dumper $role;
    print STDERR "===================================================\n";
    
    my $query = " INSERT INTO team_roles ( name ) VALUES ( ? )";
    my $dbh   = $self->{db}->get_dbh();
    my $sth = $dbh->prepare($query);
    $sth->execute( $role->get_name );
}

sub delete_role {

    my ($self, $role ) = @_;

    #print STDERR "XXXXXXXXXXXXXXXXXXX===================================================\n";
    #print STDERR Dumper $role;
    #print STDERR "===================================================\n";
    
    my $query = " DELETE FROM team_roles WHERE id = ? ";
    my $dbh   = $self->{db}->get_dbh();
    my $sth = $dbh->prepare($query);
    $sth->execute( $role->get_id );
}

1;    # End of TeamRoleDAO module

