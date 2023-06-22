package Database;

use strict;
use warnings;
use DBI;

=head1 NAME

Database - Singleton Database Connection

=head1 SYNOPSIS

  use Database;
  
  # Create a new Database instance
  my $db = Database->new("path/to/database.db");
  
  # Get the singleton instance
  my $db = Database->instance();

  # Connect to the database
  $db->connect();

  # Get the DBI handle
  my $dbh = $db->dbh();

  # Disconnect from the database
  $db->disconnect();

=head1 DESCRIPTION

The Database module provides a singleton instance of the database connection.

=head1 METHODS

=cut

my $instance;  # Singleton instance

=head2 new($db_file)

Creates a new Database instance.

Parameters:
  - $db_file: The path to the database file.

=cut

sub new {
    my ($class, $db_file) = @_;

    # Only create a new instance if it doesn't exist already
    if (!$instance) {
        $instance = bless {
            db_file => $db_file,
            dbh     => undef,
        }, $class;
    }

    return $instance;
}

=head2 connect()

Establishes a connection to the database.

=cut

sub connect {
    my ($self) = @_;

    return if $self->{dbh};  # Return if already connected

    my $dsn = "dbi:SQLite:dbname=" . $self->{db_file};
    $self->{dbh} = DBI->connect($dsn) or die "Failed to connect to database: $DBI::errstr";
}

=head2 disconnect()

Closes the database connection.

=cut

sub disconnect {
    my ($self) = @_;

    $self->{dbh}->disconnect if $self->{dbh};
}

=head2 get_dbh()

Returns the connected DBI handle.

=cut

sub get_dbh {
    my ($self) = @_;

    $self->connect();  # Ensure connection is established
    return $self->{dbh};
}

=head2 instance()

Returns the singleton instance of the Database class.

=cut

sub instance {
    my ($class) = @_;

    # Only create a new instance if it doesn't exist already
    if (!$instance) {
        $instance = bless {}, $class;
    }

    return $instance;
}

1;  # End of Database module

