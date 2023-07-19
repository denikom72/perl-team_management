-- Create teams table
CREATE TABLE IF NOT EXISTS teams (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  description TEXT
);

-- Create team_members table
CREATE TABLE IF NOT EXISTS team_members (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  team_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  email TEXT NOT NULL UNIQUE,
  --password BLOB NOT NULL,
  password TEXT NOT NULL,
  role_id INTEGER NOT NULL,
  FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE,
  FOREIGN KEY (role_id) REFERENCES team_roles (id) ON DELETE CASCADE
  UNIQUE (id, team_id, role_id)
);

-- Create team_roles table
CREATE TABLE IF NOT EXISTS team_roles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL UNIQUE,
  description TEXT
);

-- Feature Configurator Table
CREATE TABLE IF NOT EXISTS features(
	id INTEGER PRIMARY KEY AUTOINCREMENT,
  	name TEXT NOT NULL,
  	role_id INTEGER NOT NULL,
	team_id INTEGER NOT NULL,
	on_role_id INTEGER NOT NULL,
  	FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE,
  	FOREIGN KEY (role_id) REFERENCES team_roles (id) ON DELETE CASCADE,
  	FOREIGN KEY (on_role_id) REFERENCES team_roles (id) ON DELETE CASCADE
  	UNIQUE (name, team_id, role_id, on_role_id)
);
-- Create the users table
-- Insert a default user with hashed password
-- INSERT INTO users (username, password) VALUES ('admin', '5f4dcc3b5aa765d61d8327deb882cf99');
INSERT INTO teams (name, description) VALUES('No_Team', "No_Team is for members which aren't assigned to a team yet");
INSERT INTO team_roles (name, description) VALUES('No_Role', "No_Role is for a member which doesn't get a role yet");
INSERT INTO team_members ( role_id ,team_id, name, email, password) VALUES ( 1, 1, 'Popov', 'admin@foo.com', 'password');


