use strict;
use warnings;
use Plack::Request;
use Plack::Response;
use Plack::Builder;
use Digest::SHA qw(sha256_hex);
use Data::Dumper;
use Template;
use DBI;
use CGI::Session;
use Try::Tiny;
use Storable;
use File::Slurp;
use lib '.';
#use Plack::Session;

use lib "model";
use MemberDTO;
use MemberDAO;

use TeamDTO;
use TeamDAO;

use FeatureDAO;

use TeamRoleDAO;

use Database; 


my ( $tpl, $vars, $session, $member, $memb );

# Configure the database connection
#my $db_file = 'team_management.db';
#my $dbh = DBI->connect("dbi:SQLite:dbname=$db_file") or die "Couldn't connect to database: $DBI::errstr";


	my $meths = {};
	#my $mth = {};
	
	my $db = Database->new('team_management.db');

	### MOCKUP DATA ###	
	$meths->{logged_in_member}->{Role7} = \&logged_in_member;
	$meths->{team_roles}->{Role6} = \&team_roles;
	$meths->{team_roles}->{Role7} = \&team_roles;
	print STDERR "44444444444444444444444\n";
	#print STDERR Dumper $meths;
	print STDERR "44444444444444444444444\n";
	
	my $mthds = FeatureDAO->new($db)->load_rbac;
	
	try {
		open( my $filehandle, '>', "RbacConf.pm") or die "Cannot open file RbacConf.pm: $!";
		print $filehandle "package RbacConf;\nuse warnings;\nuse Storable qw(nfreeze thaw);\nuse Exporter 'import';\nour \$mth = {};\nour \@EXPORT_OK = qw(\$get_mth \$mth);\n";
		#print Sfilehandle "\nour $mth = {};\n";
		close $filehandle;

		open( my $filehandle2, '>>', "RbacConf.pm") or die "Cannot open file RbacConf.pm: $!";
		map {
			#my $tmp_f_ref = $_->get_f_ref;
			

			#$mth->{ $_->get_feature_name }->{ $_->get_role_name } = '\&'.$_->get_feature_name;	
			
			#print STDERR Dumper $mth;
			#my $mth;	
			#print STDERR '$mth->{' . $_->get_role_name . '}->{' . $_->get_feature_name . '} = \&' .$_->get_feature_name.";" if defined $_->get_role_name;
			#AVOID THE DOUBLE BACKSLASH PRODUCED FROM PERL TRYING TO BUILD A REFERENCE ON THE SUB ABOVE
			print $filehandle2 '$mth->{' . $_->get_role_name . '}->{' . $_->get_feature_name . '} = \&' .$_->get_feature_name.";\n" if defined $_->get_role_name;	
		} @{$mthds};
		
		print $filehandle2 "our \$get_mth = sub { return \$mth; };\n\n";
		#print $filehandle2 "\nstore \$mth, 'RbacConf_data.storable';\n";
		
		print $filehandle2 "1;\n";

		close $filehandle2;
		#my $rbac_content = read_file("RbacConf.pm");
		
		#print STDERR $rbac_content;
		
		
		#do "./RbacConf.pl" or die "Error loading data file 'RbacConf.pm': $!";
		require "./RbacConf.pm" or die "Error loading data file 'RbacConf.pm': $!";
		use RbacConf qw($mth);	
		#my $mymth = retrieve('RbacConf_data.storable'); 
		#my $mymth = $RbacConf::get_mth->();
		print STDERR "||||||||||||||||||||||||||||||||||||||||||||||||||||||\n";
		print STDERR Dumper $mth;
		print STDERR "||||||||||||||||||||||||||||||||||||||||||||||||||||||\n";
	} catch {
		my $error = $_;
		# Handle the exception
		print "Caught exception: $error\n";
	};
	
	print STDERR "\n^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^\n";
	#print STDERR $mth->{create_teams}->{Role7};
	#print STDERR $mth->{create_teams}->{role7};


# Set up the template engine
my $template = Template->new({
    INCLUDE_PATH => './views',
    INTERPOLATE  => 1,
    CACHE_SIZE => 64 
}) or die "Couldn't initialize template: $Template::ERROR";


#### THE BEGINNING OF THE RBAC CONSTRUCTION #####
my %methods = (
	team_members => \&team_members,
	all_members => \&all_members,	
	team_roles => \&team_roles,
	teams => \&teams,
	logged_in_member => \&logged_in_member,
	members => \&members,	
	create_teams => \&create_teams,	
	delete_teams => \&delete_teams,	
	update_teams => \&update_teams,	
	create_team_roles => \&create_roles,	
	delete_team_roles => \&delete_roles,
	update_team_roles => \&update_roles,
	create_all_members => \&create_members,
	delete_all_members => \&delete_members,
	update_all_members => \&update_members
);




my %feat_names = (

	team_members => "team_members",
	all_members => "all_members",	
	team_roles => "team_roles",
	teams => "teams",
	logged_in_member => "logged_in_member",
	create_teams => "create_teams",	
	delete_teams => "delete_teams",	
	update_teams => "update_teams",	
	create_team_roles => "create_roles",	
	delete_team_roles => "delete_roles",
	update_team_roles => "update_roles",
	create_all_members => "create_members",
	delete_all_members => "delete_members",
	update_all_members => "update_members"

);


print STDERR Dumper \%methods;
#### END OF RBAC ####

sub RbacConf::logged_in_member {
	
	$memb = new MemberDAO($db)->pull_member_by_id( $memb );
	
	# TODO: JUST RETURN INSTANCES. EVERY PART CAN USE THEN THE NEEDED ACCESSORS. EVEN TTK CAN DO IT.			
        return { 
		userMail => $memb->get_email, 
		memberMail => $memb->get_email,
		memberName => $memb->get_name,
		#memberId => $memb->get_id,
		memberTeam => $memb->get_member_team,
		memberRole => $memb->get_member_role,
		content => "some content if necessary"
	};

}

sub RbacConf::members {
	
	return { 
		
		userMail => $memb->get_email, 
                content => "TODO : EVERY TEAM ITEM HAVE TO BIND A CLICK EVENT AND RESPONSE WITH ALL TEAM-MEMBERS"
	};	

};

sub RbacConf::create_members {

	my $args = shift;
	my ( $member_list, $teams, $roles );

	my $memberDAO = MemberDAO->new($db);
	
	map {
		my $data = $_;
		if( defined $data->{active} && $data->{active} eq 'on' ){
					
			$memberDAO->create_member( MemberDTO->new( $data ), $memb ); 
		}
	} @{ $args->{post} };
	
	$member_list = $memberDAO->get_all_members( $memb );
	
	$teams = TeamDAO->new($db)->get_teams;	
	$roles = TeamRoleDAO->new($db)->get_roles;	
	
	return { 
		
		user => $memb, 
		member_email => $memb->get_email,
		teams => $teams,
		roles => $roles,
		all_members => $member_list,
		action => 'all_members',
		#content => "some content if necessary"
	};	
}

sub RbacConf::delete_members {

	my $args = shift;
	my ( $member_list, $teams, $roles );

	my $memberDAO = MemberDAO->new($db);
	
	map {
		my $data = $_;
		if( defined $data->{active} && $data->{active} eq 'on' ){
					
			$memberDAO->delete_member( MemberDTO->new( $data ), $memb ); 
		}
	} @{ $args->{post} };
	
	$member_list = $memberDAO->get_all_members( $memb );
	
	$teams = TeamDAO->new($db)->get_teams;	
	$roles = TeamRoleDAO->new($db)->get_roles;	
	
	return { 
		
		user => $memb, 
		member_email => $memb->get_email,
		teams => $teams,
		roles => $roles,
		all_members => $member_list,
		action => 'all_members',
		#content => "some content if necessary"
	};	
}


sub RbacConf::update_members {

	my $args = shift;
	my ( $member_list, $teams, $roles );

	my $memberDAO = MemberDAO->new($db);
	
	map {
		my $data = $_;
		if( defined $data->{active} && $data->{active} eq 'on' ){
					
			$memberDAO->update_member( MemberDTO->new( $data ) ); 
		}
	} @{ $args->{post} };
	
	$member_list = $memberDAO->get_all_members( $memb );
	
	$teams = TeamDAO->new($db)->get_teams;	
	$roles = TeamRoleDAO->new($db)->get_roles;	
	
	return { 
		
		user => $memb, 
		member_email => $memb->get_email,
		teams => $teams,
		roles => $roles,
		all_members => $member_list,
		action => 'all_members',
		#content => "some content if necessary"
	};	
}



sub RbacConf::create_teams {

	my $args = shift;
	my $team_list;
	
	print STDERR "333333333333333333333333333333333333333333333\n";
	print STDERR Dumper $args;

	print STDERR "333333333333333333333333333333333333333333333\n";

	my $teamDAO = TeamDAO->new($db);
	
	map {
		my $data = $_;
		if( defined $data->{active} && $data->{active} eq 'on' ){
					
			$teamDAO->create_teams( TeamDTO->new( $data ) ); 
		}
	} @{ $args->{post} };
	
	$team_list = $teamDAO->get_teams();
	
	return {
		
		user => $memb, 
		team_list => $team_list,
		action => 'teams'
	}	
}

sub RbacConf::delete_teams {

	my $args = shift;
	my $team_list;

	my $teamDAO = TeamDAO->new($db);
	
	map {
		#my $data = $_;
		if( defined $_->{active} && $_->{active} eq 'on' ){
			$teamDAO->delete_teams( TeamDTO->new( $_ ) ); 
		}
	} @{ $args->{post} };


	return {
		
		user => $memb, 
		team_list => $teamDAO->get_teams,
		action => 'teams'
	}	
}

sub RbacConf::update_teams {

	my $args = shift;
	my $team_list;

	my $teamDAO = TeamDAO->new($db);
	
	map {
		#my $data = $_;
		if( defined $_->{active} && $_->{active} eq 'on' ){
			$teamDAO->update_teams( TeamDTO->new( $_ ) ); 
		}
	} @{ $args->{post} };


	return {
		
		user => $memb, 
		team_list => $teamDAO->get_teams,
		action => 'teams'
	}	
}

sub RbacConf::update_roles {

	my $args = shift;
	my $roles;
	#print STDERR "''''''''''''''''''''''''''''''''''''''''''''''''''\n";
	#print STDERR Dumper $args;	
	my $roleDAO = TeamRoleDAO->new( $db );
	my $featureDAO = FeatureDAO->new( $db );

	map {
		if( defined $_->{active} && $_->{active} eq 'on' ){
			#$roleDAO->save_role( TeamRoleDTO->new( $_ ) );
			# it isn't possible to update the features, just create a new unique combination
			$featureDAO->create_feature( FeatureDTO->new( $_ ) );	
		}
	} @{ $args->{post} };

	$roles = team_roles(); 
	$roles->{'action'} = 'team_roles';
	$roles;
}

sub RbacConf::delete_roles {

	my $args = shift;
	my $roles;
	
	my $roleDAO = TeamRoleDAO->new( $db );

	map {
		#my $data = $_;
		if( defined $_->{active} && $_->{active} eq 'on' ){
			$roleDAO->delete_role( TeamRoleDTO->new( $_ ) ); 
		}
	} @{ $args->{post} };
	
	# DB is singleton, so it doesn't matter how many instances in other class are tried to launch
	$roles = team_roles(); 
	$roles->{'action'} = 'team_roles';
	$roles;
}

sub RbacConf::create_roles {

	my $args = shift;
	my $roles;

	my $teamRoleDAO = TeamRoleDAO->new($db);
	my $featureDAO = FeatureDAO->new($db);
	
	map {
		my $data = $_;
		if( defined $data->{active} && $data->{active} eq 'on' ){
					
			$teamRoleDAO->create_role( TeamRoleDTO->new( $data ) ); 
		        $featureDAO->create_feature( FeatureDTO->new( $data ) );	
		}
	} @{ $args->{post} };
	
	$roles = team_roles(); 
	$roles->{'action'} = 'team_roles';
	
	$roles;
}


sub RbacConf::teams {
	my $team_list;
	$team_list = TeamDAO->new($db)->get_teams();
	
	return { 
		
		user => $memb, 
		team_list => $team_list,
	};	

};

sub RbacConf::team_members {
	
	my $args = shift;
	
	my ( $team_members, $teams, $roles );
	
	my $teamDTO = TeamDTO->new();
	#$teamDTO->set_name($args->{team_name});

	#$team_members = MemberDAO->new($db)->get_team_members( $teamDTO );
	$team_members = MemberDAO->new($db)->get_team_members( $memb );
	$teams = TeamDAO->new($db)->get_teams;	
	$roles = TeamRoleDAO->new($db)->get_roles;	
	
	#### MOCK DATA ###
	#my $teams = [ { get_id => 1, get_name => "No_Team" }, { get_id => 2, get_name => "team2" } ];
	#my $roles = [ { get_id => 1, get_name => "role1" }, { get_id => 2, get_name => "No_Role" } ];


	return { 
		
		user => $memb, 
		team_name => $teamDTO->get_name(),
		teams => $teams,
		roles => $roles,
		team_members => $team_members,
                content => "some content if necessary"
	};	
};

sub RbacConf::team_roles {
	
	my $roles = TeamRoleDAO->new($db)->get_roles;
	my $features = FeatureDAO->new($db)->show_features;
	my @actions = values %feat_names; 

	#### MOCK DATA ###
	#my $actions = [ { action_id => 1, name => "action11" }, { action_id => 2, name => "action2" } ];
	#my %actions = ( action_name => "action11",  name => "action2" );
	#my $roles = [ { role_id => 1, name => "role1" }, { role_id => 2, name => "role2" } ];
	print STDERR "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT\n";
	print STDERR Dumper $features;	
	print STDERR "TTTTTTTTTTTTTTTTTTTTTTTTTTTTTT\n";
	
	return {
		user => $memb, 
		role_f_role => $features,
		team_roles => $roles,
		actions => \@actions,
                content => "TODO : EVERY ROLE HAVE TO HAS AN CLICK EVENT AND RESPONSE TO IT RIGHTS OF IT. MEANS THE BOUNCE OF FEATURES/METHODS IT CAN USE ON OTHER ROLES - EXAMPLE, ROLE CAN CREATE USER WITH ROLE XY, BUT NOT WITH THE ROLE - ADMIN"
	};
	
};

sub RbacConf::all_members {
	
	my $args = shift;
	
	my ( $all_members, $teams, $roles );
	
	#print STDERR "==========================================================\n";
	#print STDERR Dumper $all_members;

	#### MOCK DATA ###
	#my $teams = [ { get_id => 1, get_name => "No_Team" }, { get_id => 2, get_name => "team2" } ];
	#my $roles = [ { get_id => 1, get_name => "role1" }, { get_id => 2, get_name => "No_Role" } ];
	
	$all_members = MemberDAO->new($db)->get_all_members( $memb );
	$teams = TeamDAO->new($db)->get_teams;	
	$roles = TeamRoleDAO->new($db)->get_roles;	
	
	return { 
		
		user => $memb, 
		member_email => $memb->get_email,
		teams => $teams,
		roles => $roles,
		all_members => $all_members,
		#content => "some content if necessary"
	};	
};



########## UNSESSIONED FRONTEND #################

my $loginpage = sub {
    
    my $env = shift;
    my $req = Plack::Request->new($env);
    
    my $csrf_token = generate_csrf_token();
    
    #TODO: how to set here the session-state-cookie expiration?

    my $res = Plack::Response->new(200);
    $res->content_type('text/html');
   
    # Define vars for Response 
    my $html = '';
    my $vars = { login_count => undef, csrf_token => $csrf_token };
    my $tpl = "login.tmpl";
    
    # Build Html Answer 
    my $template_context = $template->context;
    unless ( $template_context->template($tpl)->_is_cached ) { 
         $template->process($tpl, { vars => $vars }, \$html) or die "Template processing failed: $template::ERROR";
    }

    # Response
    $res->body($html);
    return $res->finalize;
};

my $logged_in_or_rejected = sub {
    my $env = shift;
    
    my $req = Plack::Request->new($env);

    my $res = Plack::Response->new(200);

    my $check_credentials = undef; 

#    # Validate CSRF token
#    my $is_valid = $req->method eq 'POST' && $req->param('csrf_token') eq $session->param('csrf_token');
    
    $memb = MemberDTO->new( { email => $req->param('username'), password => $req->param('password') } );
    my $memb_dao = MemberDAO->new( $db );
    
    $check_credentials = $memb_dao->check_member( $memb );
    my $tst = undef; 
    
    if( $memb->get_id ){
    	
	$memb = $memb_dao->pull_member_by_id($memb);
	
	$session = CGI::Session->new();
        my $cookie = $session->cookie();
	$session->load( $cookie );
	
        $res->header('Set-Cookie' => $cookie);
	
	$res->content_type('text/html');
        
        my $html = '';
        
        my  $vars = { userMail => $memb->get_email(), content => "" };
        $tpl = "admin_panel.tmpl";
        
        my $template_context = $template->context;
        unless ( $template_context->template($tpl)->_is_cached ) { 
             $template->process($tpl, { vars => $vars }, \$html) or die " Template processing failed: $template::ERROR";
        }

        $res->body($html);
    } else {
    	$res->redirect("/", 302);
    }
    
    return $res->finalize;
};


my $logout = sub {
    my $env = shift;
    my $req = Plack::Request->new($env);
    delete $env->{'HTTP_COOKIE'};
    my $res = Plack::Response->new();
    $res->redirect("/", 302);
    return $res->finalize;
};


my $admin_panel_crud = sub {

    my $env = shift;
    my $req = Plack::Request->new($env);
    my $submitted_session = $req->session;
     
    #TODO:
    #check_csrf_token();
    #check_session_id
    
    #if( checks ore done ) { call the action pm with params - for example show team or delete team, but with rbac, cause check give as membername and memberrole too. logout always necessary here, Use DTOs. If credentials aren't valide just redirect to login page  } 

    my $res = Plack::Response->new(200);

    # Parse hexa into chars 
    $req->{env}->{HTTP_COOKIE} =~ s/\\x\{([0-9A-Fa-f]+)\}/chr(hex($1))/eg; 
    
    my $session_cookie = sprintf( "%s", [ split( /=/, [ split( /;/, $req->{env}->{HTTP_COOKIE} ) ]->[1] ) ]->[1] );
    $session_cookie =~ s/^\s*|\s*$//gi;
    
    if( $session->id eq $session_cookie ){
    
		print STDERR "\n\n ????????????????? " . $memb->get_member_role . " ??????????????????? \n\n" ;
		print STDERR Dumper $memb;
		print STDERR "\n\n ????????????????? " . $memb->get_member_role . " ??????????????????? \n\n" ;
	my %args;
	
	$res->content_type('text/html');
        
	my $action;

        my $html = '';
        
        my $vars = { membermail => $memb->get_email, content => "<a href='/logout'>logout</a>" };
        
	$tpl = "admin_panel.tmpl";
	
	my $query_parts = [ split( /=/, $req->{env}->{QUERY_STRING} ) ];

	my $amp = undef;	
	$query_parts = [ split( /&/, $req->{env}->{QUERY_STRING} ) ] if $req->{env}->{QUERY_STRING} =~ /&/;
		
	if( defined $req->{env}->{REQUEST_METHOD} && $req->{env}->{REQUEST_METHOD} eq 'POST' ){
		my $post_data = $req->{env}->{'plack.request.body_parameters'};
		
		my $cnt = @{$post_data} if defined $post_data;
		
		my $psh = -1;
		my ( @post, %hidden_post, %_post );
		
		if($cnt > 0){
			
			for my $i ( 0..$cnt ){
				# Read hash keys
				if( $i % 2 == 0 ){
					my  %post;
					
					if( $post_data->[$i] eq 'member_id' || $post_data->[$i] eq 'id' || $post_data->[$i] eq 'ID' ) {
						$psh++;
						$post[$psh] = [];
					}

					$post{ $post_data->[$i] } = $post_data->[$i + 1];
					
					if( $psh == -1 ){
						$hidden_post{ $post_data->[$i] } = $post_data->[$i + 1];
					} else {
						push @{ $post[$psh] }, \%post;
					}
				} 
			}
		}
		
		my @post_data;
		
		map {
			my $tmp = $_;
			my %_tmp;

			map {
				my $hsh = $_;
				
				map{
					$_tmp{$_} = $hsh->{$_};
				} keys %{$hsh};

			}  @{$tmp};
			push @post_data, \%_tmp;
			
		} @post;

		$args{post} = [ @post_data ];
		$args{hidden_post} = \%hidden_post;
		
	}
	
	if( $req->{env}->{QUERY_STRING} =~ /&/ ){
		my $key_val;
		map {
			$key_val = [ split /=/ ];

			$args{ sprintf( "%s", $key_val->[0] ) }= sprintf( "%s", $key_val->[1] );	
		} @$query_parts;		

		$action = sprintf( "%s", [ split( /=/, $query_parts->[0] ) ]->[1] );
		print STDERR $action . " AAAAAAAAAAAAAAAACCCCTION \n";
		#$vars = $methods{$action}->(\%args);
		my $act = $feat_names{ $action };
		print STDERR $act . " AAAAAAAAAAAAAAAACCCCTION \n";
		$vars = $mth->{ $memb->get_member_role }->{ $feat_names{ $action } }->(\%args);
		#$vars = $mth->{ Role7 }->{ create_members }->(\%args);
	} else {
		if( defined $args{hidden_post}->{action} ){
						
			my $act = $feat_names{ $args{hidden_post}->{action} };

			#print STDERRR " CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC --> " . $memb->get_member_role . " --> " . $feat_names{ $args{hidden_post}->{action} . ";

			#$vars = $mth->{ $memb->get_member_role }->{ $act }->(\%args);
			$vars = $mth->{ $memb->get_member_role }->{ $feat_names{ $args{hidden_post}->{action} } }->(\%args);
			#$vars = $methods{ $args{hidden_post}->{action} }->(\%args);
			#$vars = $mth->{ $memb->get_member_role }->{ $args{hidden_post}->{action} }->(\%args);
			#$vars = $mth->{ Role7 }->{ create_members }->(\%args);
		}else{
			$action = sprintf( "%s", $query_parts->[1] );
			#$vars = $methods{$action}->();
			#$vars = $meths->{team_roles}->{Role2}->();
			
			#$vars = $meths->{$action}->{ $memb->get_member_role }->();
			print STDERR "++++^^^^^^^^^^^^^^^^^^^^^^^^^^";
			print STDERR Dumper $mth;
			print STDERR "\n\n < " . $memb->get_member_role . " --- $action > \n\n";
			print STDERR "----^^^^^^^^^^^^^^^^^^^^^^^^^^";
			
			#$vars = $mth->{ $memb->get_member_role }->{ $action }->();
			$vars = $mth->{ $memb->get_member_role }->{ $feat_names{ $action } }->();
			
			#$vars = $mth->{ Role7 }->{ team_roles }->();
			
			print STDERR $mth->{ Role7 }->{ team_roles }->();
			print STDERR "*********************";
		}	
	}
	

	#print STDERR "=============***************************\n";
	#print STDERR Dumper \%args;
	
	
	$action = $vars->{'action'} if defined $vars->{'action'};

	my $template_context = $template->context;
        unless ( $template_context->template($tpl)->_is_cached ) { 
             $template->process($tpl, { vars => $vars, action => $action.'.tmpl', site => ' > ' . $action, submit_action => $action }, \$html) or die " Template processing failed: $template::ERROR";
        }

        $res->body($html);
    } else {
    	$res->redirect("/loginpage", 302);
    }
    
    return $res->finalize;

};


# Generate a CSRF token
sub generate_csrf_token {
    return sha256_hex(rand() . time . rand());
}

# Check if the CSRF token is valid
sub check_csrf_token {
    my $env = shift;
    my $req = Plack::Request->new($env);
    my $session = $req->session;
    my $csrf_token = $session->{csrf_token};
    my $submitted_token = $session->{csrf_token};
    return $csrf_token && $submitted_token && $csrf_token eq $submitted_token;
}

builder {
    enable 'Session', store => 'File';
    enable 'Static',
            path => qr!^/(public|assets|favicon|yui)/!,
            root => '/home/sw-engineer/perl_projects/perl-team_management';
    enable 'CSRFBlock',
	    parameter_name => 'csrf_secret',
	    token_length => 20,
	    session_key => 'csrf_token',
	    blocked => sub {
	      [302, [Location => '/'], ['']];
	    },
	    onetime => 0;
    mount "/" => $loginpage;
    mount "/login" => $logged_in_or_rejected;
    mount "/logout" => $logout;
    mount "/admin_panel" => $admin_panel_crud;
    mount "/favicon.ico" => sub { return [ 200, ['Content-Type' => 'text/html'], [ '404 Not Found' ] ] };
    mount "/assets/style.css" => sub { return [ 200, ['Content-Type' => 'text/css'], [ '404 Not Found' ] ] };
    #mount "/" => $app;
};

