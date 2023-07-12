package FeatureDAO;

use strict;
use warnings;
use lib "model";
use FeatureDTO;
use Data::Dumper;

=head1 NAME

FeatureDAO - Data Access Object for managing team_roles

=head1 SYNOPSIS

  use FeatureDAO;

  # Create a FeatureDAO instance
  my $role_dao = FeatureDAO->new($db);

  # Retrieve team_roles
  my $team_roles_ref = $role_dao->get_team_roles();

  # Process the team_roles data
  foreach my $role (@$team_roles_ref) {
      # Do something with the role data
  }


=head1 DESCRIPTION

The FeatureDAO module provides an interface for interacting with the team_roles database table.

=head1 METHODS

=head2 new($db)

Creates a new FeatureDAO object.


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


sub get_features {
    my ($self ) = @_;

    my $query = "SELECT * FROM team_roles";
    my $dbh   = $self->{db}->get_dbh();
    my $sth = $dbh->prepare($query);
    $sth->execute();
    
    my @team_roles;
    
    while (my $role_data = $sth->fetchrow_hashref) {
        
	my $team_role = FeatureDTO->new();
	$team_role->set_data($role_data);
	push @team_roles, $team_role;
    }
    
    $sth->finish;

    return \@team_roles;
}

sub save_feature {

    my ($self, $feature ) = @_;
    my $query;
    print STDERR "XXXXXXXXXXXXXXXXXXX===================================================\n";
    print STDERR Dumper $feature;
    print STDERR "===================================================\n";
    map {
    $query = "UPDATE 
    			features
		SET 
    			role_id = ( SELECT id FROM team_roles WHERE name = ? ),
			-- team_id = (SELECT id FROM teams WHERE name = ? ),
    			on_role_id = ?
		WHERE 
			name = ?;";
    
    } $feature->get_features;
    
    my $dbh   = $self->{db}->get_dbh();
    my $sth = $dbh->prepare($query);
    #$sth->execute( $feature->get_role, $feature->get_team, $feature->get_on_role, $_ );
    $sth->execute( $feature->get_role, $feature->get_on_role, $_ );
}

sub create_feature {

    my ($self, $feature ) = @_;
    my $query;
    
    print STDERR "IIIIIIIIIIIIIIIIIIIIIIIIIIIIII===================================================\n";
    print STDERR Dumper $feature;
    print STDERR "===================================================\n";
   
    my $dbh   = $self->{db}->get_dbh();
    
    $query = "INSERT INTO features 
    				( name, role_id, team_id, on_role_id )
			SELECT 
				 ?, team_roles.id, ?, ?
			FROM 
				team_roles
			WHERE
				team_roles.name = ?";
    	
    #$query = "INSERT INTO features (name, role_id, team_id, on_role_id ) VALUES ( 'CREATE2', '1' ,'1' ,'1' )";
			       
    my $sth = $dbh->prepare($query);
    
    map {
    

	print STDERR Dumper $_; 
	$sth->execute( $_, $feature->get_on_role, 1, $feature->get_role );
    
    } @{$feature->get_features};
    #$sth->execute( "create60", 16, 5, "role3" );
	#$sth->execute();
	$sth->finish;
    
}

sub delete_feature {

    my ($self, $role ) = @_;

    #print STDERR "XXXXXXXXXXXXXXXXXXX===================================================\n";
    #print STDERR Dumper $role;
    #print STDERR "===================================================\n";
    
    my $query = " DELETE FROM team_roles WHERE id = ? ";
    my $dbh   = $self->{db}->get_dbh();
    my $sth = $dbh->prepare($query);
    $sth->execute( $role->get_id );
}

1;    # End of FeatureDAO module

