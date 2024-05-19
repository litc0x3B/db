DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
GRANT ALL ON SCHEMA public TO postgres;
GRANT ALL ON SCHEMA public TO public;

CREATE TYPE role as ENUM('user', 'admin', 'banned');

CREATE TABLE "user"
(
	ID_user              serial PRIMARY KEY,
	username             varchar(64) NOT NULL,
	registration_time    timestamp NOT NULL,
	login                varchar(64) UNIQUE NOT NULL,
	password_hash        bytea NOT NULL,
	profile_pic_url      varchar(512),
	role                 role NOT NULL
);

CREATE TABLE image
(
	ID_image             serial PRIMARY KEY,
	url                  varchar(512) NOT NULL,
	source_url           varchar(512),
	image_width          integer NOT NULL,
	image_height         integer NOT NULL,
	created_at           timestamp NOT NULL,
	ID_user              serial NOT NULL REFERENCES "user" (ID_user) ON UPDATE CASCADE
);

CREATE TABLE comment
(
	ID_comment           serial PRIMARY KEY, 
	content              varchar(10000) NOT NULL,
	created_at           timestamp NOT NULL,
	ID_image             serial NOT NULL REFERENCES image (ID_image) ON UPDATE CASCADE,
	ID_user              serial NOT NULL REFERENCES "user" (ID_user) ON UPDATE CASCADE
);

CREATE TABLE tag_category
(
	ID_tag_category      serial PRIMARY KEY,
	name                 varchar(64) NOT NULL,
	description_page_url varchar(512)
);

CREATE TABLE tag
(
	ID_tag               serial PRIMARY KEY,
	name    			 varchar(64) NOT NULL,
	description_page_url varchar(512),
	ID_tag_category      serial NOT NULL REFERENCES tag_category (ID_tag_category) ON UPDATE CASCADE
);

CREATE TABLE favorite_user_image
(
	ID_user              serial REFERENCES "user" (ID_user) ON UPDATE CASCADE,
	ID_image             serial REFERENCES image (ID_image) ON UPDATE CASCADE,
	created_at           timestamp NOT NULL,
	PRIMARY KEY (ID_user, ID_image)
);

CREATE TABLE image_tag
(
	ID_image             serial REFERENCES image (ID_image) ON UPDATE CASCADE,
	ID_tag               serial REFERENCES tag (ID_tag) ON UPDATE CASCADE,
	PRIMARY KEY (ID_image, ID_tag)
);