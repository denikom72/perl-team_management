use strict;
use warnings;
use Test::More;
use Test::More::Behavior;
use Try::Tiny;

use_ok('User');

=head1 NAME

UserTest - Test script for User module

=head1 SYNOPSIS

    # To run the tests
    prove UserTest.t

=head1 DESCRIPTION

This script contains unit tests for the User module, covering the getters and setters.

=head1 FUNCTIONS

=head2 describe 'User module'

A behavior block that groups the tests for the User module.

=cut

describe 'User module' => sub {

    it 'should have a valid email' => sub {
        my $user = User->new('user@example.com', 'password123', 1);
        is($user->get_email, 'user@example.com', 'Email getter');

        try {
            $user->set_email('newuser@example.com');
            pass('Email setter - valid email');
        } catch {
            fail('Email setter - invalid email');
        };
    };

    it 'should have a password' => sub {
        my $user = User->new('user@example.com', 'password123', 1);
        is($user->get_password, 'password123', 'Password getter');

        $user->set_password('newpassword');
        is($user->get_password, 'newpassword', 'Password setter');
    };

    it 'should have an ID' => sub {
        my $user = User->new('user@example.com', 'password123', 1);
        is($user->get_id, 1, 'ID getter');

        $user->set_id(2);
        is($user->get_id, 2, 'ID setter');
    };
};

done_testing();

=head1 RUNNING THE TESTS

To run the tests, use the following command:

    prove UserTest.t

=head1 AUTHOR

Your Name

=cut

