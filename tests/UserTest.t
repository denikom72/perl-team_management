use strict;
use warnings;
use Test::More;
use Test::BDD::Cucumber::StepFile;
use Try::Tiny;
use User;

=head1 NAME

UserTest - Unit tests for the User module

=head1 SYNOPSIS

    # Run the tests
    prove -l UserTest.t

=head1 DESCRIPTION

This script contains unit tests for the User module. It verifies the behavior of the User class and its setters.

=head1 AUTHOR

Denis Komnenovic

=cut

Given 'a valid email address' => sub {
    my $user = User->new();
    my $email = 'user@example.com';
    $user->set_email($email);
    set_context('user' => $user);
};

Then 'the email should be set correctly' => sub {
    my $user = get_context('user');
    my $email = 'user@example.com';
    is($user->get_email(), $email, 'Email should be set correctly');
};

Given 'an invalid email address' => sub {
    my $user = User->new();
    my $invalid_email = 'invalid_email';
    set_context('user' => $user);
    set_context('invalid_email' => $invalid_email);
};

When 'setting the email' => sub {
    my $user = get_context('user');
    my $invalid_email = get_context('invalid_email');
    set_context('exception' => exception { $user->set_email($invalid_email) });
};

Then 'an exception should be thrown' => sub {
    my $exception = get_context('exception');
    ok($exception, 'An exception should be thrown');
};

Given 'a valid password' => sub {
    my $user = User->new();
    my $password = 'validpassword';
    $user->set_password($password);
    set_context('user' => $user);
};

Then 'the password should be set correctly' => sub {
    my $user = get_context('user');
    my $password = 'validpassword';
    is($user->get_password(), $password, 'Password should be set correctly');
};

Given 'an invalid password' => sub {
    my $user = User->new();
    my $invalid_password = 'invalidpassword\x{123}';
    set_context('user' => $user);
    set_context('invalid_password' => $invalid_password);
};

When 'setting the password' => sub {
    my $user = get_context('user');
    my $invalid_password = get_context('invalid_password');
    set_context('exception' => exception { $user->set_password($invalid_password) });
};

Then 'an exception should be thrown' => sub {
    my $exception = get_context('exception');
    ok($exception, 'An exception should be thrown');
};

run_feature();


