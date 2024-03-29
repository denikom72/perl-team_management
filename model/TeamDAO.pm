package TeamDAO;

use strict;
use warnings;
use lib "model";
use TeamDTO;

=head1 NAME

TeamDAO - Data Access Object for managing teams

=head1 SYNOPSIS

  use TeamDAO;

  # Create a TeamDAO instance
  my $team_dao = TeamDAO->new($db);

  # Retrieve teams
  my $teams_ref = $team_dao->get_teams();

  # Process the teams data
  foreach my $team (@$teams_ref) {
      # Do something with the team data
  }


=head1 DESCRIPTION

The TeamDAO module provides an interface for interacting with the teams database table.

=head1 METHODS

=head2 new($db)

Creates a new TeamDAO object.


=head2 get_teams()

Retrieves all teams from the teams table.

Returns an array reference containing team data.

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

sub create_teams {

    my ($self, $team ) = @_;

    my $query = " INSERT INTO teams ( name ) VALUES ( ? )";
    my $dbh   = $self->{db}->get_dbh();
    my $sth = $dbh->prepare($query);
    $sth->execute( $team->get_name );
}


sub update_teams {

    my ($self, $team ) = @_;

    my $query = "UPDATE teams SET  name = ? WHERE id = ?";
    my $dbh   = $self->{db}->get_dbh();
    my $sth = $dbh->prepare($query);
    #$sth->execute( "xoo", 13  );
    $sth->execute( $team->get_name, $team->get_id );
}

sub delete_teams {

    my ($self, $team ) = @_;

    if( $team->get_id != 1 ){
	my $query = "DELETE FROM teams WHERE id = ?";
	my $dbh   = $self->{db}->get_dbh();
	my $sth = $dbh->prepare($query);
	$sth->execute( $team->get_id );
    	#$sth->execute( '3' );
    }
}

sub get_teams {
    my ($self ) = @_;

    my $query = "SELECT * FROM teams";
    my $dbh   = $self->{db}->get_dbh();
    my $sth = $dbh->prepare($query);
    $sth->execute();
    
    my @teams;
    
    while (my $team_data = $sth->fetchrow_hashref) {
        push @teams, TeamDTO->new($team_data);
    }

    $sth->finish;

    return \@teams;
}

1;    # End of TeamDAO module

