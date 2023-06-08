-- Create teams table
CREATE TABLE IF NOT EXISTS teams (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT
);

-- Create team_members table
CREATE TABLE IF NOT EXISTS team_members (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  team_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  email TEXT NOT NULL,
  role_id INTEGER NOT NULL,
  FOREIGN KEY (team_id) REFERENCES teams (id) ON DELETE CASCADE,
  FOREIGN KEY (role_id) REFERENCES team_roles (id) ON DELETE CASCADE
);

-- Create team_roles table
CREATE TABLE IF NOT EXISTS team_roles (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name TEXT NOT NULL,
  description TEXT
);

-- Create the users table
CREATE TABLE IF NOT EXISTS users (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    username TEXT NOT NULL,
    --password BLOB NOT NULL
    password TEXT NOT NULL
);

-- Insert a default user with hashed password
-- INSERT INTO users (username, password) VALUES ('admin', '5f4dcc3b5aa765d61d8327deb882cf99');
INSERT INTO users (username, password) VALUES ('admin', 'password');


