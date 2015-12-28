DROP SCHEMA IF EXISTS application CASCADE;
CREATE SCHEMA application;
SET search_path TO application, public;

CREATE TABLE roles (
	role_name TEXT PRIMARY KEY,
	role_password TEXT NOT NULL,
	role_email TEXT NOT NULL UNIQUE,
	is_active BOOLEAN NOT NULL DEFAULT true,
	is_admin BOOLEAN NOT NULL DEFAULT false
);

CREATE TABLE groups (
	group_name TEXT NOT NULL,
	group_description TEXT,
	group_kind TEXT NOT NULL,
	CHECK (group_kind IN ('instance', 'role')),
	PRIMARY KEY (group_name, group_kind)
);

CREATE TABLE instances (
	agent_address TEXT NOT NULL,
	agent_port INTEGER NOT NULL,
	agent_key TEXT,
	hostname TEXT NOT NULL,
	cpu INTEGER,
	memory_size BIGINT,
	pg_port INTEGER,
	pg_version TEXT,
	pg_data TEXT,
	PRIMARY KEY (agent_address, agent_port)
);

CREATE TABLE instance_groups (
	agent_address TEXT NOT NULL,
	agent_port INTEGER NOT NULL,
	group_name TEXT NOT NULL,
	group_kind TEXT NOT NULL DEFAULT 'instance' CHECK (group_kind = 'instance'),
	FOREIGN KEY (agent_address, agent_port) REFERENCES instances (agent_address, agent_port) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (group_name, group_kind) REFERENCES groups(group_name, group_kind) ON DELETE CASCADE ON UPDATE CASCADE,
	PRIMARY KEY (agent_address, agent_port, group_name)
);

CREATE TABLE role_groups (
	role_name TEXT NOT NULL,
	group_name TEXT NOT NULL,
	group_kind TEXT NOT NULL DEFAULT 'role' CHECK (group_kind = 'role'),
	PRIMARY KEY (role_name, group_name),
	FOREIGN KEY (role_name) REFERENCES roles(role_name) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (group_name, group_kind) REFERENCES groups(group_name, group_kind) ON DELETE CASCADE ON UPDATE CASCADE
);

CREATE TABLE access_role_instance (
	role_group_name TEXT NOT NULL,
	role_group_kind TEXT NOT NULL DEFAULT 'role' CHECK (role_group_kind = 'role'),
	instance_group_name TEXT NOT NULL,
	instance_group_kind TEXT NOT NULL DEFAULT 'instance' CHECK (instance_group_kind = 'instance'),
	PRIMARY KEY (role_group_name, instance_group_name),
	FOREIGN KEY (role_group_name, role_group_kind) REFERENCES groups (group_name, group_kind) ON DELETE CASCADE ON UPDATE CASCADE,
	FOREIGN KEY (instance_group_name, instance_group_kind) REFERENCES groups (group_name, group_kind) ON DELETE CASCADE ON UPDATE CASCADE
);

INSERT INTO roles VALUES ('julien', 'toto', 'julmon@gmail.com', true, true);
INSERT INTO groups VALUES ('dalibo', 'Dalibo DBA group.', 'role');
INSERT INTO role_groups(role_name, group_name) VALUES ('julien', 'dalibo');
INSERT INTO instances VALUES ('https://192.168.1.19', 2345, 'secret key', 'main', 'localhost', 4, 8 * 1024 * 2014, 5432, '9.4.5');
INSERT INTO groups VALUES ('client1', 'Client 1 instances.', 'instance');
INSERT INTO instance_groups(agent_address, agent_port, group_name) VALUES ('https://192.168.1.19', 2345, 'client1');
INSERT INTO access_role_instance(role_group_name, instance_group_name) VALUES ('dalibo', 'client1');
