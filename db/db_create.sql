CREATE SCHEMA IF NOT EXISTS lbaw22134;
-- SET search_path TO lbaw22134;

-- drop the old schema

-- private contents
DROP TABLE IF EXISTS report;

-- user private contents
DROP TABLE IF EXISTS user_follow_tag;
DROP TABLE IF EXISTS follow;
DROP TABLE IF EXISTS "message";
DROP TABLE IF EXISTS "search";
DROP TABLE IF EXISTS "notification";
DROP TABLE IF EXISTS save_post;
DROP TABLE IF EXISTS "block";

-- public contents  
DROP TABLE IF EXISTS user_vote_comment;
DROP TABLE IF EXISTS user_vote_post;
DROP TABLE IF EXISTS "comment";
DROP TABLE IF EXISTS post_tag;
DROP TABLE IF EXISTS tag;
DROP TABLE IF EXISTS post;

-- user groups
DROP TABLE IF EXISTS moderator;
DROP TABLE IF EXISTS "user";
DROP TABLE IF EXISTS "admin";

DROP TYPE IF EXISTS type_of_media;
CREATE TYPE type_of_media AS ENUM ('text', 'image', 'video','*URL*'); 
DROP TYPE IF EXISTS post_status;
CREATE TYPE post_status AS ENUM ('open', 'closed', 'hidden','deleted'); 

-- create the new schema

-- user groups

CREATE TABLE "admin"
(
    admin_id SERIAL PRIMARY KEY, 
    "name" TEXT NOT NULL, 
    "password" TEXT NOT NULL
);

CREATE TABLE "user"
(
    user_id SERIAL PRIMARY KEY, 
    email TEXT NOT NULL CONSTRAINT user_email_uk UNIQUE, 
    username TEXT NOT NULL CONSTRAINT user_username_uk UNIQUE, 
    "name" TEXT NOT NULL, 
    "password" TEXT NOT NULL, 
    creation_date TIMESTAMP DEFAULT now(), 
    profile_picture TEXT, 
    bio TEXT, 
    birth_date TIMESTAMP, 
    reputation INTEGER DEFAULT 0, 
    end_timeout TIMESTAMP DEFAULT NULL,
    banned_by INTEGER REFERENCES "admin" (admin_id) ON UPDATE CASCADE,

    CONSTRAINT creation_date_ck CHECK 
    (creation_date > birth_date AND creation_date <= now()),
    CONSTRAINT birth_date_ck CHECK (birth_date < current_date)
);

CREATE TABLE moderator
(
    moderator_id INTEGER PRIMARY KEY REFERENCES "user" (user_id) 
    ON UPDATE CASCADE ON DELETE CASCADE, 
    assigned_by INTEGER NOT NULL REFERENCES "admin" (admin_id) 
    ON UPDATE CASCADE
);

-- public contents

CREATE TABLE post
(
    post_id SERIAL PRIMARY KEY, 
    time_posted TIMESTAMP DEFAULT now(), 
    title TEXT NOT NULL,
    "content" TEXT NOT NULL,
    media TEXT,
    media_type type_of_media,
    votes INTEGER DEFAULT 0,   
    edited BOOLEAN DEFAULT FALSE,
    "status" post_status DEFAULT 'open',
    user_id INTEGER NOT NULL REFERENCES "user" (user_id) 
    ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE tag
(
    "name" TEXT PRIMARY KEY, 
    description TEXT
); 

CREATE TABLE post_tag
(
    post_id INTEGER REFERENCES post (post_id) 
    ON UPDATE CASCADE ON DELETE CASCADE,
    tag_name TEXT REFERENCES tag ("name") 
    ON UPDATE CASCADE ON DELETE CASCADE,

    PRIMARY KEY (post_id, tag_name)

);

CREATE TABLE "comment"
(
    comment_id SERIAL PRIMARY KEY, 
    time_posted TIMESTAMP DEFAULT now(), 
    "content" TEXT NOT NULL,
    votes INTEGER DEFAULT 0, 
    edited BOOLEAN DEFAULT FALSE,
    user_id INTEGER NOT NULL REFERENCES "user" 
    ON UPDATE CASCADE ON DELETE SET NULL,
    post_id INTEGER NOT NULL REFERENCES post 
    ON UPDATE CASCADE ON DELETE CASCADE, 
    parent_comment INTEGER REFERENCES "comment" (comment_id) 
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE user_vote_post
(
    user_id INTEGER REFERENCES "user" (user_id) 
    ON UPDATE CASCADE ON DELETE CASCADE,
    post_id INTEGER REFERENCES post (post_id) 
    ON UPDATE CASCADE ON DELETE CASCADE,
    type_of_vote BOOLEAN,
    PRIMARY KEY (user_id, post_id)
);

CREATE TABLE user_vote_comment
(
    user_id INTEGER REFERENCES "user" (user_id) 
    ON UPDATE CASCADE ON DELETE CASCADE,
    comment_id INTEGER REFERENCES "comment" (comment_id) 
    ON UPDATE CASCADE ON DELETE CASCADE,
    type_of_vote BOOLEAN,
    PRIMARY KEY (user_id, comment_id)
);

-- user private contents

CREATE TABLE "block"
(
    blocker INTEGER REFERENCES "user" (user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
    blocked INTEGER REFERENCES "user" (user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (blocker, blocked),

    CONSTRAINT different_users_ck CHECK (blocker <> blocked)
);

CREATE TABLE save_post
(   
    post_id INTEGER REFERENCES post (post_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
    user_id INTEGER REFERENCES "user" (user_id) 
    ON UPDATE CASCADE ON DELETE CASCADE,  
    PRIMARY KEY (post_id, user_id)
);

CREATE TABLE "notification"
(  
    notification_id SERIAL PRIMARY KEY, 
    time_sent TIMESTAMP DEFAULT now(), 
    "content" TEXT NOT NULL,
    seen BOOLEAN DEFAULT FALSE, 
    user_id INTEGER NOT NULL REFERENCES "user" (user_id) 
    ON UPDATE CASCADE ON DELETE CASCADE, 
    comment_id INTEGER  REFERENCES "comment" (comment_id) 
    ON UPDATE CASCADE ON DELETE CASCADE,
    post_id INTEGER REFERENCES post (post_id) 
    ON UPDATE CASCADE ON DELETE CASCADE,

    CONSTRAINT notification_exclusivity CHECK (
        (post_id is NULL AND comment_id is NOT NULL) OR
        (post_id is NOT NULL AND comment_id is NULL)
    )
);

CREATE TABLE "search"
(  
    search_id SERIAL PRIMARY KEY, 
    time_searched TIMESTAMP DEFAULT now(), 
    "content" TEXT NOT NULL, 
    user_id INTEGER NOT NULL REFERENCES "user" (user_id)
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE "message"
(   
    message_id SERIAL PRIMARY KEY, 
    time_sent TIMESTAMP DEFAULT now(), 
    "content" TEXT NOT NULL, 
    sender INTEGER NOT NULL REFERENCES "user" (user_id)
    ON UPDATE CASCADE ON DELETE CASCADE, 
    receiver INTEGER NOT NULL REFERENCES "user" (user_id) 
    ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE follow
(
    follower INTEGER REFERENCES "user" (user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
    followed INTEGER REFERENCES "user" (user_id)
    ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (follower, followed),

    CONSTRAINT different_users_ck CHECK (follower <> followed)
);

CREATE TABLE user_follow_tag
(
    user_id SERIAL REFERENCES "user" (user_id) 
    ON UPDATE CASCADE ON DELETE CASCADE,
    tag_name TEXT REFERENCES tag ("name") 
    ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (user_id, tag_name)
);

-- private contents

CREATE TABLE report
(
    report_id SERIAL PRIMARY KEY, 
    "date" TIMESTAMP DEFAULT now(), 
    "content" TEXT NOT NULL,
    reviewed BOOLEAN DEFAULT FALSE, 
    reviewer INTEGER REFERENCES moderator (moderator_id) 
    ON UPDATE CASCADE ON DELETE SET NULL,
    reporter INTEGER NOT NULL REFERENCES "user" (user_id)
    ON UPDATE CASCADE ON DELETE SET NULL, 
    reported_user INTEGER REFERENCES "user" (user_id) 
    ON UPDATE CASCADE ON DELETE CASCADE, 
    reported_post INTEGER REFERENCES post (post_id)
    ON UPDATE CASCADE ON DELETE CASCADE, 
    reported_comment INTEGER REFERENCES "comment" (comment_id) 
    ON UPDATE CASCADE ON DELETE CASCADE

    CONSTRAINT target_exclusivity CHECK (
           (reported_user is NULL AND 
            reported_post is NULL AND 
            reported_comment IS NOT NULL) 
        OR (reported_user is NULL AND 
            reported_post is NOT NULL AND 
            reported_comment IS NULL)
        OR (reported_user is NOT NULL AND 
            reported_post is NULL AND
            reported_comment IS NULL)
    )
);

