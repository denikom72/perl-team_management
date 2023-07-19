package FeatureDAO;

use strict;
use warnings;
use lib "model";
use FeatureDTO;
use Data::Dumper;
use Try::Tiny;

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


sub show_features {
    my ($self ) = @_;


    my $query = "
      SELECT 
    r.name AS role_name,
    r.id AS role_id,
    --GROUP_CONCAT(on_r.name) AS on_role_name,
    on_r.name AS on_role_name,
    on_r.id AS on_role_id,
    agg_f.f_name AS f_name
FROM
    team_roles AS r
LEFT JOIN
    (
    SELECT
        f.role_id,
        f.on_role_id,
        GROUP_CONCAT(f.name) AS f_name
    FROM
        features AS f
    GROUP BY
        f.role_id,
        f.on_role_id
    ) AS agg_f ON r.id = agg_f.role_id
    LEFT JOIN
        team_roles AS on_r ON agg_f.on_role_id = on_r.id
    --GROUP BY r.id
    ORDER BY role_id;";
    
    
    my $dbh   = $self->{db}->get_dbh();
    my $sth = $dbh->prepare($query);
    
    $sth->execute();
    
    my @features;
    
    my $n = 0;
    my $cmp_check = "";
    my $feature_rule; 
    while (my $f_data = $sth->fetchrow_hashref) {
   	
	    #print STDERR "VVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVVV\n";
	#print STDERR Dumper $f_data;
	
	$feature_rule = FeatureDTO->new($f_data);
	push( @features, $feature_rule );

    }
    
    $sth->finish;
    
    #print STDERR "FFFFFFFFFFFFFFFFFFFFFFEEEEEEEEEEEEAAAAAAAAAAATURESI";
    #print STDERR Dumper @features;
    #print STDERR "FFFFFFFFFFFFFFFFFFFFFFEEEEEEEEEEEEAAAAAAAAAAATURESI";
   
    return \@features;
}



sub save_feature {

    my ($self, $feature ) = @_;
    my $query;
    print STDERR "XXXXXXXXXXXXXXXXXXX===================================================\n";
    print STDERR Dumper $feature;
    print STDERR "===================================================\n";
    
    my $dbh   = $self->{db}->get_dbh();
    
    $query = "UPDATE 
    			features
		SET 
    			
			role_id = ( SELECT id FROM team_roles WHERE name = ? ),
			team_id = ?,
    			on_role_id = ?
		WHERE 
			name = ?";
    
    my $sth = $dbh->prepare($query);
    
    map {
    	
	$sth->execute( $feature->get_role, 1, $feature->get_on_role, $_ );
    
    } @{$feature->get_features};
    
    $sth->finish;
}

sub create_feature {

    my ($self, $feature ) = @_;
    my $query;
    
    print STDERR "IIIIIIIIIIIIIIIIIIIIIIIIIIIIII\n";
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
    
	print STDERR "rrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrrr\n";
	print STDERR Dumper $_; 
	
	try {
    		my $sth = $dbh->prepare($query);
		$sth->execute( $_, 1, $feature->get_on_role, $feature->get_role );
    		$sth->finish;
				
	} catch {
	
		croak("Error creating role rules: $_");
	}
    
    } @{$feature->get_features};
    
    #$sth->execute( "create60", 16, 5, "role3" );
    #$sth->execute();
    
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

