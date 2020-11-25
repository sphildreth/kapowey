BEGIN;

DROP TABLE IF EXISTS api_application;
DROP TABLE IF EXISTS collection_issue_grade_term;
DROP TABLE IF EXISTS collection_issue;
DROP TABLE IF EXISTS collection;
DROP TABLE IF EXISTS grade_term;
DROP TABLE IF EXISTS grade;
DROP TABLE IF EXISTS issue;
DROP TABLE IF EXISTS issuetype;
DROP TABLE IF EXISTS series;
DROP TABLE IF EXISTS series_category;
DROP TABLE IF EXISTS genre;
DROP TABLE IF EXISTS franchise;
DROP TABLE IF EXISTS franchise_category;
DROP TABLE IF EXISTS publisher;
DROP TABLE IF EXISTS publisher_category;
DROP TABLE IF EXISTS user_login;
DROP TABLE IF EXISTS user_token;
DROP TABLE IF EXISTS user_claim;
DROP TABLE IF EXISTS user_role_claim;
DROP TABLE IF EXISTS user_user_role;
DROP TABLE IF EXISTS user_role;
DROP TABLE IF EXISTS user_device_code;
DROP TABLE IF EXISTS persisted_grant;
DROP TABLE IF EXISTS "user";
DROP TYPE IF EXISTS e_status;
DROP TYPE IF EXISTS e_rating;


CREATE EXTENSION IF NOT EXISTS "uuid-ossp"; -- necessary for uuid_generate_v4

CREATE TYPE e_status AS ENUM (
 'New',
 'Imported',
 'Ok',
 'Edited',
 'Pending Review',
 'Under Review',
 'Locked',
 'Inactive'
);

CREATE TYPE e_rating AS ENUM (
 'Not Specified',
 'Poor',
 'Fair',
 'Good',
 'Very Good',
 'Excellent'
);

CREATE TABLE "user" (
	user_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	status e_status default 'New',
	api_key uuid DEFAULT uuid_generate_v4(),
	user_name varchar(256) NULL,
	normalized_user_name varchar(256) NULL,
	email varchar(256) NULL,
	normalized_email varchar(256) NULL,
	email_confirmed bool DEFAULT FALSE,
	password_hash text NULL,
	security_stamp text NULL,
	concurrency_stamp text NULL,
	phone_number text NULL,
	phone_number_confirmed bool DEFAULT FALSE,
	two_factor_enabled bool DEFAULT FALSE,
	lockout_end timestamptz NULL,
	lockout_enabled bool DEFAULT FALSE,
	access_failed_count int4 NOT NULL,
	successful_authenticate_count int4 NULL,
	tags text[] NULL,	
	is_public bool DEFAULT FALSE,	
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	modified_date timestamptz NULL,
	modified_user_id int4 REFERENCES "user" ON DELETE RESTRICT,		
	last_authenticate_date timestamptz NULL,
	CONSTRAINT user_id_pkey PRIMARY KEY (user_id)
);
CREATE INDEX user_tags ON "user" USING GIN("tags");
CREATE INDEX user_email_idx ON "user" USING btree (normalized_email);
CREATE UNIQUE INDEX user_api_key_idx ON "user" USING btree (api_key);
CREATE UNIQUE INDEX user_username_idx ON "user" USING btree (normalized_user_name);


CREATE TABLE collection ( 
	collection_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	user_id int4 REFERENCES "user" ON DELETE CASCADE,
	status e_status default 'New',	
	sort_order int4 NULL,	
	api_key uuid DEFAULT uuid_generate_v4(),
	"name" varchar(500) NOT NULL,
	short_name varchar(10) NOT NULL,
	description text NULL,	
	tags text[] NULL,	
	is_public bool DEFAULT FALSE,
	last_activity timestamptz NULL,
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT collection_pkey PRIMARY KEY (collection_id)
);
CREATE INDEX collection_tags ON collection USING GIN("tags");
CREATE UNIQUE INDEX collection_api_key_idx ON collection USING btree (api_key);
CREATE UNIQUE INDEX collection_user_id_idx ON collection USING btree (user_id);
CREATE UNIQUE INDEX collection_name_idx ON collection USING btree (name);
CREATE UNIQUE INDEX collection_short_name_idx ON collection USING btree (short_name);


CREATE TABLE user_claim ( 
	user_claim_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	user_id int4 REFERENCES "user" ON DELETE CASCADE,
	claim_type text NULL,
	claim_value text NULL,
	CONSTRAINT user_claim_pkey PRIMARY KEY (user_claim_id)
);
CREATE UNIQUE INDEX user_claim_user_idx ON user_claim USING btree (user_claim_id);
CREATE INDEX ix_user_claim_user_id ON user_claim USING btree (user_id);


CREATE TABLE user_login (
	login_provider varchar(128) NOT NULL,
	provider_key varchar(128) NOT NULL,
	provider_display_name text NULL,
	user_id int4 REFERENCES "user" ON DELETE CASCADE,
	CONSTRAINT pk_user_logins PRIMARY KEY (login_provider, provider_key)
);
CREATE INDEX ix_user_logins_user_id ON user_login USING btree (user_id);


CREATE TABLE user_token (
	user_id int4 REFERENCES "user" ON DELETE CASCADE,
	login_provider varchar(128) NOT NULL,
	"name" varchar(128) NOT NULL,
	value text NULL,
	CONSTRAINT pk_user_tokens PRIMARY KEY (user_id, login_provider, name)
);
CREATE INDEX ix_user_token_user_id ON user_login USING btree (user_id);


CREATE TABLE user_role ( -- definitions of a user role
	user_role_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	"name" varchar(256) NULL,
	normalized_name varchar(256) NULL,
	concurrency_stamp text NULL,
	CONSTRAINT user_role_id_pkey PRIMARY KEY (user_role_id)
);
CREATE UNIQUE INDEX user_role_name_idx ON user_role USING btree (normalized_name);


CREATE TABLE user_role_claim ( 
	user_role_claim_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	user_role_id int4 REFERENCES user_role ON DELETE CASCADE,
	claim_type text NULL,
	claim_value text NULL,
	CONSTRAINT user_role_claim_pkey PRIMARY KEY (user_role_claim_id)
);
CREATE UNIQUE INDEX user_role_claim_user_role_idx ON user_role_claim USING btree (user_role_id);


CREATE TABLE user_user_role ( -- what user is in what role
	user_id int4 REFERENCES "user" ON DELETE CASCADE,
	user_role_id int4 REFERENCES user_role ON DELETE CASCADE,
	CONSTRAINT pk_user_roles PRIMARY KEY (user_id, user_role_id)
);
CREATE INDEX ix_user_roles_role_id ON user_user_role USING btree (user_id, user_role_id);


CREATE TABLE user_device_code (
	user_code varchar(200) NOT NULL,
	device_code varchar(200) NOT NULL,
	subject_id varchar(200) NULL,
	client_id varchar(200) NOT NULL,
	creation_time timestamp NOT NULL,
	expiration timestamp NOT NULL,
	"data" varchar(50000) NOT NULL,
	CONSTRAINT pk_device_codes PRIMARY KEY (user_code)
);
CREATE UNIQUE INDEX ix_device_codes_device_code ON user_device_code USING btree (device_code);
CREATE INDEX ix_device_codes_expiration ON user_device_code USING btree (expiration);


CREATE TABLE persisted_grant (
	"key" varchar(200) NOT NULL,
	"type" varchar(50) NOT NULL,
	subject_id varchar(200) NULL,
	client_id varchar(200) NOT NULL,
	creation_time timestamp NOT NULL,
	expiration timestamp NULL,
	"data" varchar(50000) NOT NULL,
	CONSTRAINT pk_persisted_grants PRIMARY KEY (key)
);
CREATE INDEX ix_persisted_grants_expiration ON persisted_grant USING btree (expiration);
CREATE INDEX ix_persisted_grants_subject_id_client_id_type ON persisted_grant USING btree (subject_id, client_id, type);


CREATE TABLE api_application (
	api_application_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	status e_status default 'New',		
	api_key uuid DEFAULT uuid_generate_v4(),
	"name" varchar(500) NOT NULL,
	short_name varchar(10) NOT NULL,
	description text NULL,	
	url varchar(1000) NULL,
	tags text[] NULL,	
	last_activity timestamptz NULL,
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	created_user_id int4 REFERENCES "user" ON DELETE RESTRICT,
	modified_date timestamptz NULL,
	modified_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	reviewed_date timestamptz NULL,
	reviewed_user_id int4 REFERENCES "user" ON DELETE RESTRICT,		
	CONSTRAINT api_application_id_pkey PRIMARY KEY (api_application_id)
);
CREATE INDEX api_application_tags ON api_application USING GIN("tags");
CREATE UNIQUE INDEX api_api_key_idx ON api_application USING btree (api_key);
CREATE UNIQUE INDEX api_application_name_idx ON api_application USING btree (name);
CREATE UNIQUE INDEX api_application_short_name_idx ON api_application USING btree (short_name);


CREATE TABLE publisher_category (
	publisher_category_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	parent_publisher_category_id int4 NULL,
	status e_status default 'New',		
	"name" varchar(500) NOT NULL,
	short_name varchar(10) NOT NULL,
	description text NULL,	
	url varchar(1000) NULL,
	tags text[] NULL,	
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	created_user_id int4 REFERENCES "user" ON DELETE RESTRICT,
	modified_date timestamptz NULL,
	modified_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	reviewed_date timestamptz NULL,
	reviewed_user_id int4 REFERENCES "user" ON DELETE RESTRICT,		
	CONSTRAINT publisher_category_id_pkey PRIMARY KEY (publisher_category_id)
);
CREATE INDEX publisher_category_tags ON publisher_category USING GIN("tags");
CREATE INDEX pc_parent_pc_idx ON publisher_category USING btree (parent_publisher_category_id);
CREATE UNIQUE INDEX publisher_category_name_idx ON publisher_category USING btree (name);
CREATE UNIQUE INDEX publisher_category_short_name_idx ON publisher_category USING btree (short_name);

CREATE TABLE publisher (
	publisher_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	parent_publisher_id int4 NULL,
	publisher_category_id int4 NULL,
	status e_status default 'New',	
	api_key uuid DEFAULT uuid_generate_v4(),	
	gcd_id int4 NULL,
	"name" varchar(500) NOT NULL,
	short_name varchar(10) NOT NULL,
	year_began int4 NULL,
	year_end int4 NULL,
	country_code varchar(3) NOT NULL DEFAULT 'USA'::character varying,
	description text NULL,
	url varchar(1000) NULL,
	tags text[] NULL,
	franchise_count int4 NOT NULL DEFAULT 0,
	series_count int4 NOT NULL DEFAULT 0,
	issue_count int4 NOT NULL DEFAULT 0,
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	created_user_id int4 REFERENCES "user" ON DELETE RESTRICT,
	modified_date timestamptz NULL,
	modified_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	reviewed_date timestamptz NULL,
	reviewed_user_id int4 REFERENCES "user" ON DELETE RESTRICT,			
	CONSTRAINT publisher_pkey PRIMARY KEY (publisher_id)
);
CREATE INDEX publisher_tags ON publisher USING GIN("tags");
CREATE INDEX publisher_parent_publisher_idx ON publisher USING btree (parent_publisher_id);
CREATE INDEX publisher_publisher_category_idx ON publisher USING btree (publisher_category_id);
CREATE UNIQUE INDEX publisher_api_key_idx ON publisher USING btree (api_key);
CREATE UNIQUE INDEX publisher_name_idx ON publisher USING btree (name);
CREATE UNIQUE INDEX publisher_short_name_idx ON publisher USING btree (short_name);

CREATE TABLE franchise_category (
	franchise_category_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	parent_franchise_category_id int4 NULL,
	status e_status default 'New',		
	api_key uuid DEFAULT uuid_generate_v4(),	
	"name" varchar(500) NOT NULL,
	short_name varchar(10) NOT NULL,
	description text NULL,
	url varchar(1000) NULL,
	tags text[] NULL,		
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	created_user_id int4 REFERENCES "user" ON DELETE RESTRICT,
	modified_date timestamptz NULL,
	modified_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	reviewed_date timestamptz NULL,
	reviewed_user_id int4 REFERENCES "user" ON DELETE RESTRICT,			
	CONSTRAINT franchise_category_id_pkey PRIMARY KEY (franchise_category_id)
);
CREATE INDEX franchise_category_tags ON franchise_category USING GIN("tags");
CREATE INDEX franchise_category_parent_franchise_category_idx ON franchise_category USING btree (parent_franchise_category_id);
CREATE UNIQUE INDEX franchise_category_name_idx ON franchise_category USING btree (name);
CREATE UNIQUE INDEX franchise_category_short_name_idx ON franchise_category USING btree (short_name);

CREATE TABLE franchise (
	franchise_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	publisher_id int4 REFERENCES publisher ON DELETE CASCADE,
	parent_franchise_id int4 NULL,
	franchise_category_id int4 NULL,
	status e_status default 'New',	
	api_key uuid DEFAULT uuid_generate_v4(),		
	gcd_id int4 NULL,
	"name" varchar(500) NOT NULL,
	short_name varchar(20) NOT NULL,
	year_began int4 NULL,
	year_end int4 NULL,
	description text NULL,
	url varchar(1000) NULL,
	tags text[] NULL,
	series_count int4 NOT NULL DEFAULT 0,
	issue_count int4 NOT NULL DEFAULT 0,
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	created_user_id int4 REFERENCES "user" ON DELETE RESTRICT,
	modified_date timestamptz NULL,
	modified_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	reviewed_date timestamptz NULL,
	reviewed_user_id int4 REFERENCES "user" ON DELETE RESTRICT,			
	CONSTRAINT franchise_pkey PRIMARY KEY (franchise_id)
);
CREATE INDEX franchise_tags ON franchise USING GIN("tags");
CREATE INDEX franchise_parent_franchise_idx ON franchise USING btree (parent_franchise_id);
CREATE INDEX franchise_franchise_category_idx ON franchise USING btree (franchise_category_id);
CREATE INDEX franchise_publisher_idx ON franchise USING btree (publisher_id);
CREATE UNIQUE INDEX franchise_api_key_idx ON franchise USING btree (api_key);
CREATE UNIQUE INDEX franchise_name_idx ON franchise USING btree (name);
CREATE UNIQUE INDEX franchise_short_name_idx ON franchise USING btree (short_name);

CREATE TABLE series_category (
	series_category_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	parent_series_category_id int4 NULL,
	status e_status default 'New',		
	api_key uuid DEFAULT uuid_generate_v4(),	
	"name" varchar(500) NOT NULL,
	short_name varchar(10) NOT NULL,
	description text NULL,
	url varchar(1000) NULL,
	tags text[] NULL,		
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	created_user_id int4 REFERENCES "user" ON DELETE RESTRICT,
	modified_date timestamptz NULL,
	modified_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	reviewed_date timestamptz NULL,
	reviewed_user_id int4 REFERENCES "user" ON DELETE RESTRICT,				
	CONSTRAINT series_category_id_pkey PRIMARY KEY (series_category_id)
);
CREATE INDEX series_category_tags ON series_category USING GIN("tags");
CREATE INDEX series_parent_series_category_idx ON series_category USING btree (parent_series_category_id);
CREATE UNIQUE INDEX series_category_name_idx ON series_category USING btree (name);
CREATE UNIQUE INDEX series_category_short_name_idx ON series_category USING btree (short_name);


CREATE TABLE genre (
	genre_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	parent_genre_id int4 NULL,
	status e_status default 'New',		
	"name" varchar(500) NOT NULL,	
	short_name varchar(10) NOT NULL,
	description text NULL,
	url varchar(1000) NULL,
	tags text[] NULL,	
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	created_user_id int4 REFERENCES "user" ON DELETE RESTRICT,
	modified_date timestamptz NULL,
	modified_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	reviewed_date timestamptz NULL,
	reviewed_user_id int4 REFERENCES "user" ON DELETE RESTRICT,		
	CONSTRAINT genre_id_pkey PRIMARY KEY (genre_id)
);
CREATE INDEX genre_tags ON genre USING GIN("tags");
CREATE INDEX genre_parent_genre_idx ON genre USING btree (parent_genre_id);
CREATE UNIQUE INDEX genre_name_idx ON genre USING btree (name);
CREATE UNIQUE INDEX genre_short_name_idx ON genre USING btree (short_name);


CREATE TABLE series (
	series_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	franchise_id int4 REFERENCES franchise ON DELETE CASCADE,
	series_category_id int4 NULL,
	genre_id int4 NULL,	
	status e_status default 'New',	
	rating e_rating default 'Not Specified',
	api_key uuid DEFAULT uuid_generate_v4(),		
	gcd_id int4 NULL,
	first_issue_id int4 NULL,
	last_issue_id int4 NULL,
	"name" varchar(500) NOT NULL,
	short_name varchar(20) NOT NULL,
	year_began int4 NULL,
	year_end int4 NULL,
	culture_code varchar(2) NOT NULL DEFAULT 'en'::character varying,
	description text NULL,
	url varchar(1000) NULL,
	tags text[] NULL,
	issue_count int4 NOT NULL DEFAULT 0,
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	created_user_id int4 REFERENCES "user" ON DELETE RESTRICT,
	modified_date timestamptz NULL,
	modified_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	reviewed_date timestamptz NULL,
	reviewed_user_id int4 REFERENCES "user" ON DELETE RESTRICT,		
	CONSTRAINT series_pkey PRIMARY KEY (series_id)
);
CREATE INDEX series_tags ON series USING GIN("tags");
CREATE INDEX series_series_category_idx ON series USING btree (series_category_id);
CREATE INDEX series_genre_idx ON series USING btree (genre_id);
CREATE INDEX series_franchise_idx ON series USING btree (franchise_id);
CREATE UNIQUE INDEX series_api_key_idx ON series USING btree (api_key);
CREATE UNIQUE INDEX series_name_idx ON series USING btree (name);
CREATE UNIQUE INDEX series_short_name_idx ON series USING btree (short_name);

CREATE TABLE issuetype (
	issuetype_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	status e_status default 'New',	
	api_key uuid DEFAULT uuid_generate_v4(),
	"name" varchar(500) NOT NULL,	
	abbreviation varchar(2) NOT NULL,
	description text NULL,
	tags text[] NULL,
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	created_user_id int4 REFERENCES "user" ON DELETE RESTRICT,
	modified_date timestamptz NULL,
	modified_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	reviewed_date timestamptz NULL,
	reviewed_user_id int4 REFERENCES "user" ON DELETE RESTRICT,				
	CONSTRAINT issuetype_id_pkey PRIMARY KEY (issuetype_id)
);
CREATE INDEX issuetype_tags ON issuetype USING GIN("tags");
CREATE UNIQUE INDEX issuetype_name_idx ON issuetype USING btree (name);
CREATE UNIQUE INDEX issuetype_abbreviation_idx ON issuetype USING btree (abbreviation);


CREATE TABLE issue (
	issue_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	series_id int4 REFERENCES series ON DELETE CASCADE,
	status e_status default 'New',	
	rating e_rating default 'Not Specified',
	issuetype_id int4 REFERENCES issuetype ON DELETE RESTRICT,
	api_key uuid DEFAULT uuid_generate_v4(),	
	gcd_id int4 NULL,
	reprint_of_issue_id int4 NULL,
	sort_order int4 NULL,
	"number" varchar(10) NULL,
	"title" varchar(500) NOT NULL,
	variant_title varchar(500) NULL,
	short_title varchar(20) NULL,
	culture_code varchar(2) NOT NULL DEFAULT 'en'::character varying,
	description text NULL,
	url varchar(1000) NULL,
	tags text[] NULL,
	key_date timestamptz NOT NULL,
	isbn varchar(25) NULL,
	cover_price decimal(12,2),
	barcode varchar(25) NULL,
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	created_user_id int4 REFERENCES "user" ON DELETE RESTRICT,
	modified_date timestamptz NULL,
	modified_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	reviewed_date timestamptz NULL,
	reviewed_user_id int4 REFERENCES "user" ON DELETE RESTRICT,			
	CONSTRAINT issue_pkey PRIMARY KEY (issue_id)
);
CREATE INDEX issue_tags ON issue USING GIN("tags");
CREATE INDEX issue_series_idx ON issue USING btree (series_id);
CREATE INDEX issue_issuetype_idx ON issue USING btree (issuetype_id);
CREATE UNIQUE INDEX issue_api_key_idx ON issue USING btree (api_key);
CREATE UNIQUE INDEX issue_title_idx ON issue USING btree (title);
CREATE UNIQUE INDEX issue_short_title_idx ON issue USING btree (short_title);


CREATE TABLE grade ( 
	grade_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	status e_status default 'New',	
	"scale" decimal(3,1), -- ten point grading scale ranging from 10.0 (highest) down to 0.5 (lowest):
	sort_order int4 NULL,	
	"name" varchar(500) NOT NULL,	
	abbreviation varchar(6) NOT NULL,
	description text NULL,
	api_key uuid DEFAULT uuid_generate_v4(),
	notes text NULL,
	tags text[] NULL,	
	is_basic_grade bool DEFAULT FALSE,
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	created_user_id int4 REFERENCES "user" ON DELETE RESTRICT,
	modified_date timestamptz NULL,
	modified_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	reviewed_date timestamptz NULL,
	reviewed_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	CONSTRAINT grade_pkey PRIMARY KEY (grade_id)
);
CREATE INDEX grade_tags ON grade USING GIN("tags");
CREATE UNIQUE INDEX grade_name_idx ON grade USING btree ("name");
CREATE UNIQUE INDEX grade_scale_idx ON grade USING btree ("scale");
CREATE UNIQUE INDEX grade_abbreviation_idx ON grade USING btree (abbreviation);


CREATE TABLE grade_term ( 
	grade_term_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	status e_status default 'New',	
	sort_order int4 NULL,	
	"name" varchar(500) NOT NULL,	
	description text NULL,
	api_key uuid DEFAULT uuid_generate_v4(),
	tags text[] NULL,	
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	created_user_id int4 REFERENCES "user" ON DELETE RESTRICT,
	modified_date timestamptz NULL,
	modified_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	reviewed_date timestamptz NULL,
	reviewed_user_id int4 REFERENCES "user" ON DELETE RESTRICT,	
	CONSTRAINT grade_term_id_pkey PRIMARY KEY (grade_term_id)
);
CREATE INDEX grade_term_ide_tags ON grade_term USING GIN("tags");
CREATE UNIQUE INDEX grade_term_name_idx ON grade_term USING btree ("name");


CREATE TABLE collection_issue ( 
	collection_issue_id int4 NOT NULL GENERATED ALWAYS AS IDENTITY,
	collection_id int4 REFERENCES collection ON DELETE CASCADE,
	issue_id int4 REFERENCES issue ON DELETE RESTRICT,
	status e_status default 'New',	
	grade_id int4 REFERENCES grade ON DELETE RESTRICT,
	rating e_rating default 'Not Specified',
	sort_order int4 NULL,		
	api_key uuid DEFAULT uuid_generate_v4(),
	notes text NULL,
	tags text[] NULL,	
	number_of_copies_owned int4 NULL,
	is_digital bool DEFAULT FALSE,
	is_wanted bool DEFAULT FALSE, -- 0 not wanted but owned, 1 wanted not owned
	is_public bool DEFAULT FALSE,
	has_read bool DEFAULT FALSE,
	is_for_sale bool DEFAULT FALSE,
	price_paid decimal(12,2),
	acquisition_date timestamptz NULL,
	last_activity timestamptz NULL,
	created_date timestamptz NULL DEFAULT CURRENT_TIMESTAMP,
	CONSTRAINT collection_issue_pkey PRIMARY KEY (collection_issue_id)
);
CREATE INDEX collection_issue_tags ON collection_issue USING GIN("tags");
CREATE UNIQUE INDEX collection_issue_collection_id_idx ON collection_issue USING btree (collection_id);
CREATE UNIQUE INDEX collection_issue_issue_id_idx ON collection_issue USING btree (issue_id);
CREATE UNIQUE INDEX collection_issue_api_key_idx ON collection_issue USING btree (api_key);


CREATE TABLE collection_issue_grade_term (
	collection_issue_id int4 REFERENCES collection_issue ON DELETE CASCADE,
	grade_term_id int4 REFERENCES grade_term ON DELETE CASCADE,
	CONSTRAINT pk_collection_issue_grade_term PRIMARY KEY (collection_issue_id, grade_term_id)
);
CREATE UNIQUE INDEX collection_issue_grade_term_idx ON collection_issue_grade_term USING btree (collection_issue_id,grade_term_id);


COMMIT;


BEGIN;

INSERT INTO issuetype (abbreviation, name) VALUES ('AN', 'Annual');
INSERT INTO issuetype (abbreviation, name) VALUES ('BO', 'Bound');
INSERT INTO issuetype (abbreviation, name) VALUES ('DI', 'Digest');
INSERT INTO issuetype (abbreviation, name) VALUES ('DG', 'Digital');
INSERT INTO issuetype (abbreviation, name) VALUES ('FL', 'Floppy (standard/comic/issue)');
INSERT INTO issuetype (abbreviation, name) VALUES ('GN', 'Graphic Novel (book/usually has isbn)');
INSERT INTO issuetype (abbreviation, name) VALUES ('GS', 'Giant-Size');
INSERT INTO issuetype (abbreviation, name) VALUES ('HC', 'Hardcover');
INSERT INTO issuetype (abbreviation, name) VALUES ('OB', 'Omnibus');
INSERT INTO issuetype (abbreviation, name, description) VALUES ('OS', 'One-Shot', 'Single stand alone issue with self-contained story, not part of a series');
INSERT INTO issuetype (abbreviation, name) VALUES ('PA', 'Pamphlet');
INSERT INTO issuetype (abbreviation, name) VALUES ('PR', 'Prestige');
INSERT INTO issuetype (abbreviation, name) VALUES ('QA', 'Quarterly');
INSERT INTO issuetype (abbreviation, name) VALUES ('SP', 'Special');
INSERT INTO issuetype (abbreviation, name, description) VALUES ('TP', 'Trade (Trade Paperback, TPB)', 'A collection of issues or stories.');
INSERT INTO issuetype (abbreviation, name) VALUES ('VI', 'Variant');


INSERT INTO grade (scale, abbreviation, "name") VALUES (10.0,'GM','Gem Mint');
INSERT INTO grade (scale, abbreviation, "name") VALUES (9.9,'M','Mint');
INSERT INTO grade (scale, abbreviation, "name") VALUES (9.8,'NM/M','Near Mint/Mint');
INSERT INTO grade (scale, abbreviation, "name") VALUES (9.6,'NM+','Near Mint+');
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (9.4,'NM','Near Mint', true);
INSERT INTO grade (scale, abbreviation, "name") VALUES (9.2,'NM-','Near Mint-');
INSERT INTO grade (scale, abbreviation, "name") VALUES (9.0,'VF/NM','Very Fine/Near Mint');
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (8.0,'VF','Very Fine', true);
INSERT INTO grade (scale, abbreviation, "name") VALUES (8.5,'VF+','Very Fine+');
INSERT INTO grade (scale, abbreviation, "name") VALUES (7.5,'VF-','Very Find-');
INSERT INTO grade (scale, abbreviation, "name") VALUES (7.0,'FN/VF','Fine/Very Fine');
INSERT INTO grade (scale, abbreviation, "name") VALUES (6.5,'FN+','Fine+');
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (6.0,'FN','Fine', true);
INSERT INTO grade (scale, abbreviation, "name") VALUES (5.5,'FN-','Fine-');
INSERT INTO grade (scale, abbreviation, "name") VALUES (5.0,'VG/FN','Very Good/Fine');
INSERT INTO grade (scale, abbreviation, "name") VALUES (4.5,'VG+','Very Good+');
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (4.0,'VG','Very Good', true);
INSERT INTO grade (scale, abbreviation, "name") VALUES (3.5,'VG-','Very Good-');
INSERT INTO grade (scale, abbreviation, "name") VALUES (3.0,'GD/VG','Good/Very Good');
INSERT INTO grade (scale, abbreviation, "name") VALUES (2.5,'GD+','Good+');
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (2.0,'GD','Good', true);
INSERT INTO grade (scale, abbreviation, "name") VALUES (1.8,'GD-','Good-');
INSERT INTO grade (scale, abbreviation, "name") VALUES (1.5,'FR/GD','Fair/Good');
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (1.0,'FR','Fair', true);
INSERT INTO grade (scale, abbreviation, "name", is_basic_grade) VALUES (0.5,'PR','Poor', true);

INSERT INTO grade_term ("name", description) VALUES('Bend', 'When part of a comic is curved, interrupting the flat, smooth cover surface. Bends WILL NOT show distinct lines.');
INSERT INTO grade_term ("name", description) VALUES('Bindery Tear', 'A small horizontal rip in a comic''s cover that can usually be seen on both the front and the back. These are always found along the spine and should be graded like spine stress if they are shorter than 1/4".');
INSERT INTO grade_term ("name", description) VALUES('Chew', 'Damage caused by the gnawing of rodents or insects (usually). Results in multi-page paper loss with jagged edges. Very visually distinct.');
INSERT INTO grade_term ("name", description) VALUES('Cockling', 'Bubbling on a cover''s surface (typically a printing defect).');
INSERT INTO grade_term ("name", description) VALUES('Crease', 'A fold that causes ink removal/color break, usually resulting in a white line (see bend/fold).');
INSERT INTO grade_term ("name", description) VALUES('Denting', 'Indentations or dimpling (usually in the cover) that don''t penetrate the paper or remove any gloss, but do interrupt the smooth, flat surface.');
INSERT INTO grade_term ("name", description) VALUES('Double Cover', 'Technically a printing defect, double-cover books had an extra copy of the cover stapled on during manufacturing. This protective extra cover can be a boon, as these books are graded by the condition of the innermost cover.');
INSERT INTO grade_term ("name", description) VALUES('Dust Shadow', 'When a comic has been stored in a stack at some point in its life, any portions of the cover that weren''t covered up by the adjacent books have been exposed to environmental air, light, and settling dust particles, sometimes creating lines of discoloration along the edges.');
INSERT INTO grade_term ("name", description) VALUES('Fingerprints', 'When finger oils left behind from everyday handling remain on a comic''s surface, they can begin to eat away at the ink, literally creating color-breaking fingerprints on the cover that are sometimes distinct and sometimes smudged. Finger oils can usually be wiped away, but fingerprints are irreversible.');
INSERT INTO grade_term ("name", description) VALUES('Flash', 'A method of examining a comic that uses its natural gloss and light (glare) to help you see imperfections in its surface, like denting.');
INSERT INTO grade_term ("name", description) VALUES('Foxing', 'Bacterial or fungal growth in the paper of a comic (usually the cover) that presents in brownish discolored clusters or spots.');
INSERT INTO grade_term ("name", description) VALUES('Fold', 'Linear dents in paper that have distinct lines, but DO NOT break color (see also bend/crease).');
INSERT INTO grade_term ("name", description) VALUES('Gloss', 'The shiny surface finish of a comic.');
INSERT INTO grade_term ("name", description) VALUES('Moisture/Water Damage', 'The damage left behind when a comic has been exposed to moisture (directly or environmentally). Water damage often presents with staining and/or a stiff or swollen feel to the paper. Look for lines of demarcation.');
INSERT INTO grade_term ("name", description) VALUES('Paper Loss', 'When the surface of a comic has been compromised. This can be the result of heavy scuffing/abrasion, accidental tape pull, or the chemical reactions caused by some kinds of moisture damage.');
INSERT INTO grade_term ("name", description) VALUES('Paper Quality', 'Paper quality refers to the coloration and structural integrity of a comic''s cover and interior pages. We do give some leeway on pre-1980s comics, but when environmental conditions have caused the paper to oxidize and/or deteriorate significantly, the decrease in eye appeal and paper strength will bring a book''s grade down. Generally, paper quality will not be a concern for most modern (post-1980) comics.');
INSERT INTO grade_term ("name", description) VALUES('Printing Defect', 'A flaw caused in the printing process. Examples: paper wrinkling, mis-cut edges, mis-folded or mis-wrapped spine, untrimmed pages/corners, off-registered color, color artifacts, off-centered trimming, mis-folded or unbound pages, missing staples.');
INSERT INTO grade_term ("name", description) VALUES('Reading Crease', 'A vertical cover crease near the staples that runs (generally) parallel to the spine, caused by bending the cover over the staples or just too far to the left. Squarebound books get these very easily.');
INSERT INTO grade_term ("name", description) VALUES('Restoration', 'Any attempt (professional or amateur) to enhance the appearance of an aging or damaged comic book. Dry pressing/cleaning and the simple addition of tape repairs are not considered restoration, but the following techniques are: recoloring/color touch, adding missing paper, stain/ink/dirt/tape removal, whitening, chemical pressing, staple replacement, trimming, re- glossing, married pages, etc. Restored comics generally carry lower value than their unaltered counterparts.');
INSERT INTO grade_term ("name", description) VALUES('Scuffing', 'A light paper abrasion that may or may not break color, but interrupts the surface gloss of the book. Its effect on grading is determined by severity.');
INSERT INTO grade_term ("name", description) VALUES('Soiling', 'Substances or residue on the surface of a comic. Most commonly found in white spaces. Residue is a more severe form of soiling.');
INSERT INTO grade_term ("name", description) VALUES('Spine Break', 'A spine stress that has devolved into a tear (usually through multiple wraps). Spine breaks greatly decrease the spine''s structural integrity and are often found close to the staples.');
INSERT INTO grade_term ("name", description) VALUES('Spine Roll', 'A condition where the left edge of a comic curves toward the front or back, caused by folding back each page as the comic was read. Also usually results in page fanning.');
INSERT INTO grade_term ("name", description) VALUES('Spine Split', 'A clean, even separation at the spine fold, commonly above or below the staple, but can occur anywhere along the spine length.');
INSERT INTO grade_term ("name", description) VALUES('Spine Stress', 'A small crimp/fold perpendicular to the spine, usually less than 1/4" long.');
INSERT INTO grade_term ("name", description) VALUES('Staple Detached', 'When a wrap has come completely loose from a staple and is no longer bound to the comic in that area.');
INSERT INTO grade_term ("name", description) VALUES('Staple Migration', 'When staple rust has moved onto the surrounding paper, causing staining.');
INSERT INTO grade_term ("name", description) VALUES('Staple Popped', 'When one side of a cover has torn right next to the staple, but is still attached by the slip of paper beneath the staple. If not handled carefully, a popped staple can lead to a detached staple.');
INSERT INTO grade_term ("name", description) VALUES('Staple Rust', 'Literally, rust on the staple.');
INSERT INTO grade_term ("name", description) VALUES('Store Stamp', 'Store name, or other details, stamped in ink on cover.');
INSERT INTO grade_term ("name", description) VALUES('Subscription Crease', 'A vertical cover-to-cover fold caused by the book being folded in half when sent through the mail directly from the publisher.');
INSERT INTO grade_term ("name", description) VALUES('Wrap', 'A single sheet of paper folded to form four pages of a story.');
INSERT INTO grade_term ("name", description) VALUES('Writing/Signed', 'Has one or more signature or writing can be found on/in comic in any form.');


COMMIT;
