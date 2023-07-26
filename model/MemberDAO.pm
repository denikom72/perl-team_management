package MemberDAO;

use strict;
use warnings;
use Data::Dumper;

=head1 NAME

MemberDAO - Data Access Object for Member entity

=head1 SYNOPSIS

  use MemberDAO;
  
  # Create a new Database instance
  my $db = Database->new("path/to/database.db");

  # Create a new MemberDAO instance
  my $dao = MemberDAO->new($db);

  # Perform data access operations

=head1 DESCRIPTION

The MemberDAO module provides data access operations for managing Member entities.

=head1 METHODS

=cut

=head2 new($db)

Creates a new MemberDAO instance.

  my $dao = MemberDAO->new($db);

Parameters:
  - $db: The Database instance to be used for database operations.

=cut

sub new {
    my ($class, $db) = @_;

    return bless {
        db => $db,
    }, $class;
}

sub sql_rid_in_features {
    my ( $self, $rid )= ( shift, shift );

    my $where_in_feat = $rid.
    			" IN ( SELECT 
		 		on_role_id 
			FROM 
				features 
			WHERE 
				? = role_id 
		    	 );
    ";

    $where_in_feat;
}

sub check_member {
    my ($self, $member) = @_;

    my $dbh = $self->{db}->get_dbh();
    my $query = "SELECT id FROM team_members WHERE email = ? AND password = ?";
    my $sth = $dbh->prepare($query);
    
    $sth->execute($member->get_email, $member->get_password);

    my $member_data = $sth->fetchrow_hashref;
    
    $sth->finish;

    $member->set_id( $member_data->{id} );

    $member;
}



=head2 create_member($member_data)

Creates a new member record in the database.

  $dao->create_member({
      name  => 'John Doe',
      email => 'john@example.com',
  });

=cut

sub create_member {
    my ( $self, $member, $logged_in_member ) = @_;
	print STDERR "\n (((((((((((((((((((((((((((((((((((((((   \n";
#	print STDERR Dumper $member;
#	print STDERR "\n (((((((((((((((((((((((((((((((((((((((   \n";
    my $dbh = $self->{db}->get_dbh();
    my $query = "INSERT INTO team_members 
    			(team_id, name, email, password, role_id)
		SELECT 
			teams.id, ?, ?, ?, team_roles.id
		FROM 
			teams, team_roles
		WHERE 
			teams.name = ? 
		AND 
			team_roles.name = ?
		AND" . $self->sql_rid_in_features( ' team_roles.id') .";";

    print STDERR $query;
    print STDERR Dumper $member;
    print STDERR Dumper $logged_in_member;
    
    my $sth = $dbh->prepare($query);
    #$sth->execute( $member->get_name, $member->get_email, "password22" );
    $sth->execute( 	$member->get_name,
	    		$member->get_email, 
			"password22", 
			$member->get_member_team, 
			$member->get_member_role, 
			$logged_in_member->get_member_role_id
    );
    
    $sth->finish;
}

=head1 OLD DELETE MEMBER
sub delete_member {
    my ($self, $member) = @_;
#	print STDERR "\n (((((((((((((((((((((((((((((((((((((((   \n";
#	print STDERR Dumper $member;
#	print STDERR "\n (((((((((((((((((((((((((((((((((((((((   \n";
    my $dbh = $self->{db}->get_dbh();
    my $query = "DELETE FROM team_members WHERE id = ?";
    
    my $sth = $dbh->prepare($query);
    $sth->execute( $member->get_id );
    $sth->finish;
}
=cut

sub update_member {
    my ($self, $member) = @_;
#	print STDERR "\n (((((((((((((((((((((((((((((((((((((((   \n";
#	print STDERR Dumper $member;
#	print STDERR "\n (((((((((((((((((((((((((((((((((((((((   \n";
    my $dbh = $self->{db}->get_dbh();
    my $query = "UPDATE 
    			team_members
		SET 
    			name = ?,
    			email = ?,
			team_id = (SELECT id FROM teams WHERE name = ?),
    			role_id = (SELECT id FROM team_roles WHERE name = ?)
		WHERE 
			id = ?;";
    
    my $sth = $dbh->prepare($query);
    $sth->execute( $member->get_name, $member->get_email, $member->get_member_team, $member->get_member_role, $member->get_id );
    $sth->finish;
}



=head2 pull_member_by_id($member_id)

Retrieves a member record from the database.

  my $member = $dao->get_member($member_id);

Returns:
  - The member record as a hash reference, or undef if not found.

=cut



sub pull_member_by_id {
    my ($self, $member) = @_;

    my $dbh = $self->{db}->get_dbh();
    my $query = "SELECT tm.id AS member_id, tm.role_id AS role_id, tm.name AS member_name, tm.email AS member_email, tr.name AS member_role_name, t.name AS member_team_name
			
    			FROM 
		
		team_members AS tm 
			
			JOIN 
			
		team_roles AS tr ON tm.role_id = tr.id
			
			JOIN 
			
		teams AS t ON tm.team_id = t.id
			
			WHERE 
			
		tm.id = ?";

    my $sth = $dbh->prepare($query);
    $sth->execute($member->get_id);

    my $member_data = $sth->fetchrow_hashref;
    $sth->finish;

    $member->set_data( $member_data );
    print STDERR "::::::::::::::::::::::::::::::::::::\n";	
    print STDERR Dumper $member_data;    
    print STDERR "::::::::::::::::::::::::::::::::::::\n";	
    return $member;
}

=head2 update_member($member_id, $member_data)

Updates a member record in the database.

  $dao->update_member($member_id, {
      name  => 'John Doe',
      email => 'john@example.com',
  });

=cut

#sub update_member {
#    my ($self, $member) = @_;
#
#    my $dbh = $self->{db}->get_dbh();
#    my $query = "UPDATE team_members SET name = ?, email = ? WHERE id = ?";
#    my $sth = $dbh->prepare($query);
#    $sth->execute($member->get_name, $member->get_email, $member->get_id);
#    $sth->finish;
#}

=head2 delete_member($member_id)

Deletes a member record from the database.

  $dao->delete_member($member_id);

=cut

sub delete_member {
    my ($self, $member, $logged_in_member ) = @_;

	print STDERR "\n (((((((((((((((((((((((((((((((((((((((   \n";
	print STDERR Dumper $member;
	print STDERR Dumper $logged_in_member;
	print STDERR "\n (((((((((((((((((((((((((((((((((((((((   \n";
    
	my $dbh = $self->{db}->get_dbh();
    
    	#my $query = "DELETE FROM team_members WHERE id = ?";

    	my $query = "
		 DELETE FROM 
    			team_members 
		 AS 
		 	tm 
		 WHERE 
		 	id = ? 
		 AND 
		 	tm.role_id 
		 IN 
		 	( SELECT 
		 		on_role_id 
			  FROM 
				features 
			  WHERE 
				? = role_id 
		    	 );";

    my $sth = $dbh->prepare($query);
    
    $sth->execute( $member->get_id, $logged_in_member->get_member_role_id );
    
    $sth->finish;
}

sub get_all_members {
    my ($self, $logged_in_member) = @_;

    my $query = "SELECT 
    			
    			tm.id AS member_id,
			tm.name AS name,
			tm.email AS email,
			tm.role_id AS m_rl_id,
			tr.name AS member_role,
			t.name AS member_team
		FROM 
		 	team_members tm
			
		JOIN 
			
			team_roles tr ON tm.role_id = tr.id
		JOIN 
			
			teams t ON t.id = tm.team_id
		WHERE
			m_rl_id
		 IN 
		 	( SELECT 
		 		on_role_id 
			  FROM 
				features 
			  WHERE 
				? = role_id 
		    	 );
			 ";
			

    my $dbh   = $self->{db}->get_dbh();
    
    my $sth = $dbh->prepare($query);
   
	print STDERR "333333333333333333333333333333333333333\n";
	print STDERR Dumper $logged_in_member;
	print STDERR "<<333333333333333333333333333333333333333\n";
    $sth->execute( $logged_in_member->get_member_role_id );
    
    my @members;
    while (my $member_data = $sth->fetchrow_hashref) {
	   
	    #if( $member->get_id == $member_data->{ member_id } ){
	    	
		    #push @members, $member->set_data( $member );

		#} else {
	    	push @members, MemberDTO->new( $member_data );
		#}
    }
    $sth->finish;
    
    print STDERR "==========================================================\n";
    print STDERR Dumper \@members;

    print STDERR "}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}}\n";
    return \@members;

}

sub get_team_members {
    #my ($self, $team) = @_;
    my ($self, $member) = @_;

    my $query = "SELECT 
    			tm.id AS member_id,
			tm.name AS name,
			tm.email AS email,
			tr.name AS member_role,
			t.name AS member_team
		 FROM 
		 	team_members AS tm
			
		JOIN 
			
			team_roles AS tr ON tm.role_id = tr.id
		JOIN 
			
			teams AS t ON t.id = tm.team_id
		
		WHERE 
			tm.id = ?";

    my $dbh   = $self->{db}->get_dbh();
    my $sth = $dbh->prepare($query);
    $sth->execute($member->get_id);
    my @members;
    while (my $member_data = $sth->fetchrow_hashref) {
	    print STDERR Dumper $member_data;
	    push @members, MemberDTO->new( $member_data );
    }
    $sth->finish;

    print STDERR "==========================================================\n";
    print STDERR Dumper \@members;
    
    return \@members;
}


1;  # End of MemberDAO module

