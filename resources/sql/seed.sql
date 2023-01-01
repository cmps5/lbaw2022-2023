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
DROP TABLE IF EXISTS post CASCADE;
-- public contents
DROP TABLE IF EXISTS user_vote_comment;
DROP TABLE IF EXISTS user_vote_post;
DROP TABLE IF EXISTS "comments";
DROP TABLE IF EXISTS post_tag;
DROP TABLE IF EXISTS tag;

-- user groups
DROP TABLE IF EXISTS moderator;
DROP TABLE IF EXISTS "users";
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

CREATE TABLE "users"
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
    moderator_id INTEGER PRIMARY KEY REFERENCES "users" (user_id)
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
    user_id INTEGER NOT NULL REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE SET NULL
);

CREATE TABLE tag
(
    "name" TEXT UNIQUE,
    description TEXT,
    tag_id SERIAL PRIMARY KEY
);

CREATE TABLE post_tag
(
    post_id INTEGER REFERENCES post (post_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    tag_id INTEGER REFERENCES tag ("tag_id")
        ON UPDATE CASCADE ON DELETE CASCADE,

    PRIMARY KEY (post_id, tag_id)

);

CREATE TABLE "comments"
(
    comment_id SERIAL PRIMARY KEY,
    time_posted TIMESTAMP DEFAULT now(),
    "content" TEXT NOT NULL,
    votes INTEGER DEFAULT 0,
    edited BOOLEAN DEFAULT FALSE,
    user_id INTEGER NOT NULL REFERENCES "users"
        ON UPDATE CASCADE ON DELETE SET NULL,
    post_id INTEGER NOT NULL REFERENCES post
        ON UPDATE CASCADE ON DELETE CASCADE,
    parent_comment INTEGER REFERENCES "comments" (comment_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE user_vote_post
(
    user_id INTEGER REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    post_id INTEGER REFERENCES post (post_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    type_of_vote BOOLEAN,
    PRIMARY KEY (user_id, post_id)
);

CREATE TABLE user_vote_comment
(
    user_id INTEGER REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    comment_id INTEGER REFERENCES "comments" (comment_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    type_of_vote BOOLEAN,
    PRIMARY KEY (user_id, comment_id)
);

-- user private contents

CREATE TABLE "block"
(
    blocker INTEGER REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    blocked INTEGER REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (blocker, blocked),

    CONSTRAINT different_users_ck CHECK (blocker <> blocked)
);

CREATE TABLE save_post
(
    post_id INTEGER REFERENCES post (post_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    user_id INTEGER REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (post_id, user_id)
);

CREATE TABLE "notification"
(
    notification_id SERIAL PRIMARY KEY,
    time_sent TIMESTAMP DEFAULT now(),
    "content" TEXT NOT NULL,
    seen BOOLEAN DEFAULT FALSE,
    user_id INTEGER NOT NULL REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    comment_id INTEGER  REFERENCES "comments" (comment_id)
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
    user_id INTEGER NOT NULL REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE "message"
(
    message_id SERIAL PRIMARY KEY,
    time_sent TIMESTAMP DEFAULT now(),
    "content" TEXT NOT NULL,
    sender INTEGER NOT NULL REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    receiver INTEGER NOT NULL REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE follow
(
    follower INTEGER REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    followed INTEGER REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (follower, followed),

    CONSTRAINT different_users_ck CHECK (follower <> followed)
);

CREATE TABLE user_follow_tag
(
    user_id SERIAL REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    tag_id INTEGER REFERENCES tag ("tag_id")
        ON UPDATE CASCADE ON DELETE CASCADE,
    PRIMARY KEY (user_id, tag_id)
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
    reporter INTEGER NOT NULL REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE SET NULL,
    reported_user INTEGER REFERENCES "users" (user_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    reported_post INTEGER REFERENCES post (post_id)
        ON UPDATE CASCADE ON DELETE CASCADE,
    reported_comment INTEGER REFERENCES "comments" (comment_id)
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


DROP TRIGGER IF EXISTS post_search_update ON post;
DROP FUNCTION IF EXISTS post_search_update();

-- full text search
ALTER TABLE post
    ADD COLUMN tsvectors TSVECTOR;

CREATE FUNCTION post_search_update() RETURNS TRIGGER AS $$
BEGIN
    IF TG_OP = 'INSERT' THEN
        NEW.tsvectors = (
                setweight(to_tsvector('english',  NEW.title), 'A') ||
                setweight(to_tsvector('english', NEW.content), 'B')
            );
    END IF;
    IF TG_OP = 'UPDATE' THEN
        IF (NEW.title <> OLD.title OR NEW.content <> OLD.content) THEN
            NEW.tsvectors = (
                    setweight(to_tsvector('english', NEW.title), 'A') ||
                    setweight(to_tsvector('english', NEW.content), 'B')
                );
        END IF;
    END IF;
    RETURN NEW;
END $$
    LANGUAGE plpgsql;

CREATE TRIGGER post_search_update
    BEFORE INSERT OR UPDATE ON post
    FOR EACH ROW
EXECUTE PROCEDURE post_search_update();

CREATE INDEX search_idx ON post USING GIN (tsvectors);

-- performance indexes
DROP INDEX IF EXISTS user_search;
DROP INDEX IF EXISTS user_message;
DROP INDEX IF EXISTS user_post;

CREATE INDEX user_search ON "search" USING btree (user_id, time_searched DESC);
CREATE INDEX user_message ON "message" USING btree (sender, receiver);
CREATE INDEX user_post ON post USING hash (user_id);


--triggers
SET search_path TO lbaw22134;

DROP TRIGGER IF EXISTS notify_new_post ON post;
DROP TRIGGER IF EXISTS notify_new_comment ON "comments";
DROP TRIGGER IF EXISTS delete_post ON post;
DROP TRIGGER IF EXISTS delete_comment ON "comments";
DROP TRIGGER IF EXISTS update_votes_post ON post CASCADE;
DROP TRIGGER IF EXISTS update_votes_comment ON "comments" CASCADE;

DROP FUNCTION IF EXISTS notify_new_post();
DROP FUNCTION IF EXISTS notify_new_comment();
DROP FUNCTION IF EXISTS delete_post();
DROP FUNCTION IF EXISTS delete_comment();
DROP FUNCTION IF EXISTS update_votes_post() CASCADE;
DROP FUNCTION IF EXISTS update_votes_comment() CASCADE;


CREATE FUNCTION notify_new_post() RETURNS TRIGGER AS
$BODY$
DECLARE
    temprow follow;
BEGIN
    FOR temprow IN
        SELECT follower, followed FROM follow WHERE followed = NEW.user_id
        LOOP
            INSERT INTO "notification" ("content", user_id, comment_id, post_id)
            VALUES(
                      'A user you follow just posted.', --content
                      temprow.follower,
                      NULL, --not a post
                      NEW.post_id); --post id
        END LOOP;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;

CREATE TRIGGER notify_new_post
    AFTER INSERT ON post
    FOR EACH ROW
EXECUTE FUNCTION notify_new_post();


CREATE FUNCTION notify_new_comment() RETURNS TRIGGER AS
$BODY$
DECLARE
    temprow follow;
BEGIN
    FOR temprow IN
        SELECT follower, followed FROM follow WHERE followed = NEW.user_id
        LOOP
            INSERT INTO "notification" ("content", user_id, comment_id, post_id)
            VALUES(
                      'A user you follow just commented.',
                      temprow.follower,
                      NEW.comment_id, --comment id
                      NULL); --post id
        END LOOP;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;

CREATE TRIGGER notify_new_comment
    AFTER INSERT ON "comments"
    FOR EACH ROW
EXECUTE FUNCTION notify_new_comment();


CREATE FUNCTION delete_post() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF EXISTS (SELECT * FROM user_vote_post WHERE user_vote_post.post_id = OLD.post_id AND user_vote_post.type_of_vote <> NULL) THEN
        RAISE EXCEPTION 'A post cannot be deleted if it has votes.';
    END IF;
    IF EXISTS (SELECT * FROM "comments" WHERE "comments".post_id = OLD.post_id) THEN
        RAISE EXCEPTION 'A post cannot be deleted if it has comments.';
    END IF;
    RETURN OLD;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE TRIGGER delete_post
    BEFORE DELETE ON post
    FOR EACH ROW
EXECUTE FUNCTION delete_post();


CREATE FUNCTION delete_comment() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF EXISTS (SELECT * FROM user_vote_comment WHERE user_vote_comment.comment_id = OLD.comment_id AND user_vote_comment.type_of_vote <> NULL) THEN
        RAISE EXCEPTION 'A comment cannot be deleted if it has votes.';
    END IF;
    IF EXISTS (SELECT * FROM "comments" WHERE "comments".post_id = OLD.comment_id) THEN
        RAISE EXCEPTION 'A comment cannot be deleted if it has comments.';
    END IF;
    RETURN OLD;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE TRIGGER delete_comment
    BEFORE DELETE ON "comments"
    FOR EACH ROW
EXECUTE FUNCTION delete_comment();


CREATE FUNCTION update_votes_post() RETURNS TRIGGER AS
$BODY$
DECLARE
    count_upvotes INTEGER;
    count_downvotes INTEGER;
BEGIN
    count_upvotes =
        (SELECT COUNT (*)
         FROM user_vote_post
         WHERE user_vote_post.post_id = NEW.post_id
           AND user_vote_post.type_of_vote = TRUE
        );
    count_downvotes = (
        SELECT COUNT (*)
        FROM user_vote_post
        WHERE user_vote_post.post_id = NEW.post_id
          AND user_vote_post.type_of_vote = FALSE
    );
    UPDATE post SET votes = (count_upvotes - count_downvotes) WHERE post.post_id = NEW.post_id;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;

CREATE TRIGGER update_votes_post
    AFTER INSERT OR UPDATE ON user_vote_post
    FOR EACH ROW
EXECUTE FUNCTION update_votes_post();



CREATE FUNCTION update_votes_comment() RETURNS TRIGGER AS
$BODY$
DECLARE
    count_upvotes INTEGER;
    count_downvotes INTEGER;
BEGIN
    count_upvotes =
        (SELECT COUNT (*)
         FROM user_vote_comment
         WHERE user_vote_comment.comment_id = NEW.comment_id
           AND user_vote_comment.type_of_vote = TRUE
        );
    count_downvotes = (
        SELECT COUNT (*)
        FROM user_vote_comment
        WHERE user_vote_comment.comment_id = NEW.comment_id
          AND user_vote_comment.type_of_vote = FALSE
    );
    UPDATE "comments" SET votes = (count_upvotes - count_downvotes) WHERE "comments".comment_id = NEW.comment_id;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;

CREATE TRIGGER update_votes_comment
    AFTER INSERT OR UPDATE ON user_vote_comment
    FOR EACH ROW
EXECUTE FUNCTION update_votes_comment();

SET search_path TO lbaw22134;


SET search_path TO lbaw22134;


INSERT INTO "admin" ("name", "password") VALUES ('matiasfg', 'd7201fad0eb9dbc54afbeeb24dbb5a6d');
INSERT INTO "admin" ("name", "password") VALUES ('joaodasneves', 'dfddc4aa86acec7c5df5cc97a2c9438d');
INSERT INTO "admin" ("name", "password") VALUES ('tomasagante', '26c6d3c118af81b36b9293d70ba03099');

INSERT INTO "users" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('mmoret@berkeley.edu', 'mmoret1', 'Marven Moret', '36a6ee38cd8c7a4375a91eb5bb3ca13f', 'http://dummyimage.com/85x47.png/cc0000/ffffff', 'Passionate for french cuisine', '1976-09-19 02:39:45', NULL);
INSERT INTO "users" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('ylippitt2@zimbio.com', 'ylippitt2', 'Yolande Lippitt', '403e2fa59c01287a8dc9cfaed1962a02', 'http://dummyimage.com/82x44.png/cc0000/ffffff', 'Organic food is really healthier', '1975-04-06 05:03:26', NULL);
INSERT INTO "users" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('khalsworth3@discuz.net', 'khalsworth3', 'Kimberli Halsworth', '5852371166eaa5fe740d372b247d803f', 'http://dummyimage.com/52x43.png/ff4444/ffffff', 'Beans lover', '1977-11-04 05:32:40', NULL);
INSERT INTO "users" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('ejosephs4@ihg.com', 'ejosephs4', 'Edouard Josephs', 'c72e1c5e3df0022083bfa7318d5a2b01', 'http://dummyimage.com/40x67.png/cc0000/ffffff', 'Professional bakery owner', '1968-04-03 04:43:02', NULL);
INSERT INTO "users" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('lfolds5@meetup.com', 'lfolds5', 'Leonerd Folds', '86673df685aa8a788a4007828b40c1d8', 'http://dummyimage.com/78x26.png/dddddd/000000', 'Graduated in cuisine', '1969-12-12 18:51:03', NULL);
INSERT INTO "users" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('reamer6@jugem.jp', 'reamer6', 'Roosevelt Eamer', '402f4be2277bfcfcba2c4ef5827ab057', 'http://dummyimage.com/99x50.png/dddddd/000000', 'I love cooking. ', '1977-02-07 20:17:34', NULL);
INSERT INTO "users" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('rnavarijo7@friendfeed.com', 'rnavarijo7', 'Rusty Navarijo', '3a1fd3f97b12ceed4d73356e3cdb31da', 'http://dummyimage.com/39x11.png/cc0000/ffffff', 'Hey, im here to help. Cooking is my passion', '1984-09-17 16:43:32', NULL);

INSERT INTO follow (follower, followed) VALUES (1, 7);
INSERT INTO follow (follower, followed) VALUES (2, 7);
INSERT INTO follow (follower, followed) VALUES (3, 7);
INSERT INTO follow (follower, followed) VALUES (4, 7);
INSERT INTO follow (follower, followed) VALUES (5, 7);
INSERT INTO follow (follower, followed) VALUES (6, 7);
INSERT INTO follow (follower, followed) VALUES (2, 6);
INSERT INTO follow (follower, followed) VALUES (4, 6);
INSERT INTO follow (follower, followed) VALUES (7, 6);
INSERT INTO follow (follower, followed) VALUES (3, 2);


INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('French Food tips for professionals?', 'Im trying to improve my skills in tradional french food. Any tips?', NULL, NULL, 1);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('How to cook healthier and easier?', 'I dont like to cook, but i want to be health and spend less.', NULL, NULL, 4);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Advanced tips to do the perfect potato fries?', 'That is a ask to help a potato fries lover', NULL, NULL, 3);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('How to create a better environment in my cuisine?', 'My professionals are constantly leaving they work because of bornout.', NULL, NULL, 4);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('What to buy to a new personal cuisine?', 'Planning to marry and move for my first house withou my parents :)', NULL, NULL, 5);




INSERT INTO moderator (moderator_id, assigned_by) VALUES (7, 3);
INSERT INTO moderator (moderator_id, assigned_by) VALUES (6, 1);
INSERT INTO moderator (moderator_id, assigned_by) VALUES (3, 2);

INSERT INTO tag ("name", description) VALUES ('French Food', 'French food for lovers.');
INSERT INTO tag ("name", description) VALUES ('Professional Cuisine', 'The best tips for advanced users');
INSERT INTO tag ("name", description) VALUES ('Begginers', 'Useful for begginers');
INSERT INTO tag ("name", description) VALUES ('For Everyone', 'A post useful for everyone');
INSERT INTO tag ("name", description) VALUES ('Cooking Better', 'Tutorials for everyone. Trying to explain specific techniques for improve your skills');
INSERT INTO post_tag (post_id, tag_id) VALUES (1, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (1, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (2, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (2, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (2, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (3, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (4, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (5, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (5, 5);


INSERT INTO "comments" ("content", user_id, post_id, parent_comment) VALUES ('Congratulations man!!! For helping you, i highly recommend at least 3 pans and 1 fridge. But depends for your budget. Can you give more details?', 1, 5, NULL);
INSERT INTO "comments" ("content", user_id, post_id, parent_comment) VALUES ('Thank u guy! Something around 1000 euros', 1, 5, 1);
INSERT INTO "comments" ("content", user_id, post_id, parent_comment) VALUES ('Try to avoid in the first moment too much specific tools. Observer first if you miss them.', 3, 5, NULL);


INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (1, 1, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (3, 1, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (2, 1, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (3, 2, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (4, 2, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (5, 3, TRUE);


INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (1, 2, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (3, 1, TRUE);


INSERT INTO "block" (blocker, blocked) VALUES (1, 3);


INSERT INTO save_post (post_id, user_id) VALUES (1, 2);
INSERT INTO save_post (post_id, user_id) VALUES (3, 4);



INSERT INTO "search" ("content", user_id) VALUES ('French food', 1);
INSERT INTO "search" ("content", user_id) VALUES ('Health', 1);
INSERT INTO "search" ("content", user_id) VALUES ('Potatos', 2);
INSERT INTO "search" ("content", user_id) VALUES ('New recipes', 3);


INSERT INTO "message" ("content", sender, receiver) VALUES ('Hello!', 1, 2);
INSERT INTO "message" ("content", sender, receiver) VALUES ('Hello, how are u?', 2, 1);
INSERT INTO "message" ("content", sender, receiver) VALUES ('Good and u?', 1, 2);



INSERT INTO user_follow_tag (user_id, tag_id) VALUES (1, 5);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (2, 5);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (2, 3);


INSERT INTO report ("content", reviewer, reporter, reported_user, reported_post, reported_comment) VALUES ('Confuse', 7, 4, NULL, 2, NULL);
INSERT INTO report ("content", reviewer, reporter, reported_user, reported_post, reported_comment) VALUES ('Missing information to understand', 6, 2, NULL, NULL, 1);
INSERT INTO report ("content", reviewer, reporter, reported_user, reported_post, reported_comment) VALUES ('Dont follow the guidelines', 7, 2, 2, NULL, NULL);


