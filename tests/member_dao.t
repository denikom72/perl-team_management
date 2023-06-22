use strict;
use warnings;
use Test::More;
use File::Temp qw(tempfile);

=head1 NAME

member_dao_test.pl - Unit tests for MemberDAO module

=head1 SYNOPSIS

  perl member_dao.t

=head1 DESCRIPTION

This script contains unit tests for the MemberDAO module.

=head1 METHODS

=cut

# Set up the temporary database file
my ($fh, $db_file) = tempfile();
close($fh);

# Load the MemberDAO module
use lib './model';
use MemberDAO;

=head2 test_create_get_member()

Tests the create_member and get_member methods.

=cut

sub test_create_get_member {
    my $dao = MemberDAO->new($db_file);
    $dao->connect();

    $dao->create_member({ name => "John Doe", email => 'john\@example.com' });
    my $member = $dao->get_member(1);
    is($member->{name}, "John Doe", "create_member and get_member");

    $dao->disconnect();
}

=head2 test_update_member()

Tests the update_member method.

=cut

sub test_update_member {
    my $dao = MemberDAO->new($db_file);
    $dao->connect();

    $dao->update_member(1, { name => "Jane Smith", email => 'jane\@example.com' });
    my $member = $dao->get_member(1);
    is($member->{name}, "Jane Smith", "update_member");

    $dao->disconnect();
}

=head2 test_delete_member()

Tests the delete_member method.

=cut

sub test_delete_member {
    my $dao = MemberDAO->new($db_file);
    $dao->connect();

    $dao->delete_member(1);
    my $member = $dao->get_member(1);
    is($member, undef, "delete_member");

    $dao->disconnect();
}

# Run the tests
plan tests => 3;
test_create_get_member();
test_update_member();
test_delete_member();

# Clean up the temporary database file
unlink($db_file);

done_testing();

