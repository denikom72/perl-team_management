use strict;
use warnings;
use Test::More;
use Test::More::Behaviour;
use Try::Tiny;
use User;

=head1 NAME

UserTest - Unit tests for the User module

=head1 SYNOPSIS

    # Run the tests
    prove UserTest.t

=head1 DESCRIPTION

This script contains unit tests for the User module. It verifies the behavior of the User class and its setters.

=head1 AUTHOR

Denis Komnenovic

=cut

behaviour {
    describe 'User module' => sub {

        # Test valid email
        it 'should set a valid email correctly' => sub {
            my $user = User->new('user@example.com', 'password123', 1);
            is($user->get_email(), 'user@example.com', 'Email should be set correctly');
        };

        # Test invalid email
        it 'should throw an exception for an invalid email' => sub {
            try {
                my $user = User->new('invalid_email', 'password123', 1);
                fail('Invalid email should throw an exception');
            }
            catch {
                like($_, qr/Invalid email format/, 'Exception should be thrown for invalid email');
            };
        };

        # Test valid password
        it 'should set a valid password correctly' => sub {
            my $user = User->new('user@example.com', 'validpassword', 1);
            is($user->get_password(), 'validpassword', 'Password should be set correctly');
        };

        # Test invalid password
        it 'should throw an exception for an invalid password' => sub {
            try {
                my $user = User->new('user@example.com', 'invalidpassword\x{123}', 1);
                fail('Invalid password should throw an exception');
            }
            catch {
                like($_, qr/Invalid password format/, 'Exception should be thrown for invalid password');
            };
        };

        # Test valid ID
        it 'should set a valid ID correctly' => sub {
            my $user = User->new('user@example.com', 'password123', 1);
            is($user->get_id(), 1, 'ID should be set correctly');
        };

        # Test invalid ID
        it 'should throw an exception for an invalid ID' => sub {
            try {
                my $user = User->new('user@example.com', 'password123', 'invalidid');
                fail('Invalid ID should throw an exception');
            }
            catch {
                like($_, qr/Invalid ID format/, 'Exception should be thrown for invalid ID');
            };
        };

    };
};

done_testing();

