use strict;
use warnings;
use Test::More;
use File::Temp qw(tempfile);

=head1 NAME

user_dao_test.pl - Unit tests for UserDAO module

=head1 SYNOPSIS

  perl user_dao_test.pl

=head1 DESCRIPTION

This script contains unit tests for the UserDAO module.

=head1 METHODS

=cut

# Set up the temporary database file
my ($fh, $db_file) = tempfile();
close($fh);

# Load the UserDAO module
use lib '../model';
use UserDAO;

=head2 test_create_get_user()

Tests the create_user and get_user methods.

=cut

sub test_create_get_user {
    my $dao = UserDAO->new($db_file);
    $dao->connect();

    $dao->create_user({ name => 'John Doe', email => 'john\@example.com' });
    my $user = $dao->get_user(1);
    is($user->{name}, "John Doe", "create_user and get_user");

    $dao->disconnect();
}

=head2 test_update_user()

Tests the update_user method.

=cut

sub test_update_user {
    my $dao = UserDAO->new($db_file);
    $dao->connect();

    $dao->update_user(1, { name => 'Jane Smith', email => 'jane\@example.com' });
    my $user = $dao->get_user(1);
    is($user->{name}, "Jane Smith", "update_user");

    $dao->disconnect();
}

=head2 test_delete_user()

Tests the delete_user method.

=cut

sub test_delete_user {
    my $dao = UserDAO->new($db_file);
    $dao->connect();

    $dao->delete_user(1);
    my $user = $dao->get_user(1);
    is($user, undef, "delete_user");

    $dao->disconnect();
}

# Run the tests
plan tests => 3;
test_create_get_user();
test_update_user();
test_delete_user();

# Clean up the temporary database file
unlink($db_file);

done_testing();

