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
DROP TABLE IF EXISTS "comment";
DROP TABLE IF EXISTS post_tag;
DROP TABLE IF EXISTS tag;

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
DROP TRIGGER IF EXISTS notify_new_comment ON "comment";
DROP TRIGGER IF EXISTS delete_post ON post;
DROP TRIGGER IF EXISTS delete_comment ON "comment";
DROP TRIGGER IF EXISTS update_votes_post ON post CASCADE;
DROP TRIGGER IF EXISTS update_votes_comment ON "comment" CASCADE;

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
    AFTER INSERT ON "comment"
    FOR EACH ROW
EXECUTE FUNCTION notify_new_comment();


CREATE FUNCTION delete_post() RETURNS TRIGGER AS
$BODY$
BEGIN
    IF EXISTS (SELECT * FROM user_vote_post WHERE user_vote_post.post_id = OLD.post_id AND user_vote_post.type_of_vote <> NULL) THEN
        RAISE EXCEPTION 'A post cannot be deleted if it has votes.';
    END IF;
    IF EXISTS (SELECT * FROM "comment" WHERE "comment".post_id = OLD.post_id) THEN
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
    IF EXISTS (SELECT * FROM "comment" WHERE "comment".post_id = OLD.comment_id) THEN
        RAISE EXCEPTION 'A comment cannot be deleted if it has comments.';
    END IF;
    RETURN OLD;
END;
$BODY$
    LANGUAGE plpgsql;


CREATE TRIGGER delete_comment
    BEFORE DELETE ON "comment"
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
    UPDATE "comment" SET votes = (count_upvotes - count_downvotes) WHERE "comment".comment_id = NEW.comment_id;
    RETURN NEW;
END;
$BODY$
    LANGUAGE plpgsql;

CREATE TRIGGER update_votes_comment
    AFTER INSERT OR UPDATE ON user_vote_comment
    FOR EACH ROW
EXECUTE FUNCTION update_votes_comment();

SET search_path TO lbaw22134;


INSERT INTO "admin" ("name", "password") VALUES ('Sigismundo Sheardown', 'd7201fad0eb9dbc54afbeeb24dbb5a6d');
INSERT INTO "admin" ("name", "password") VALUES ('Kaylee Gabbitas', 'dfddc4aa86acec7c5df5cc97a2c9438d');
INSERT INTO "admin" ("name", "password") VALUES ('Rand De Cleyne', '26c6d3c118af81b36b9293d70ba03099');

INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('mmoret1@berkeley.edu', 'mmoret1', 'Marven Moret', '36a6ee38cd8c7a4375a91eb5bb3ca13f', 'http://dummyimage.com/85x47.png/cc0000/ffffff', 'Stand-alone mission-critical Graphical User Interface', '1976-09-19 02:39:45', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('ylippitt2@zimbio.com', 'ylippitt2', 'Yolande Lippitt', '403e2fa59c01287a8dc9cfaed1962a02', 'http://dummyimage.com/82x44.png/cc0000/ffffff', 'Organic mission-critical intranet', '1975-04-06 05:03:26', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('khalsworth3@discuz.net', 'khalsworth3', 'Kimberli Halsworth', '5852371166eaa5fe740d372b247d803f', 'http://dummyimage.com/52x43.png/ff4444/ffffff', 'Fundamental analyzing benchmark', '1977-11-04 05:32:40', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('ejosephs4@ihg.com', 'ejosephs4', 'Edouard Josephs', 'c72e1c5e3df0022083bfa7318d5a2b01', 'http://dummyimage.com/40x67.png/cc0000/ffffff', 'Exclusive eco-centric secured line', '1968-04-03 04:43:02', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('lfolds5@meetup.com', 'lfolds5', 'Leonerd Folds', '86673df685aa8a788a4007828b40c1d8', 'http://dummyimage.com/78x26.png/dddddd/000000', 'Automated interactive benchmark', '1969-12-12 18:51:03', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('reamer6@jugem.jp', 'reamer6', 'Roosevelt Eamer', '402f4be2277bfcfcba2c4ef5827ab057', 'http://dummyimage.com/99x50.png/dddddd/000000', 'Switchable asymmetric interface', '1977-02-07 20:17:34', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('rnavarijo7@friendfeed.com', 'rnavarijo7', 'Rusty Navarijo', '3a1fd3f97b12ceed4d73356e3cdb31da', 'http://dummyimage.com/39x11.png/cc0000/ffffff', 'User-friendly solution-oriented migration', '1984-09-17 16:43:32', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('uperello8@hud.gov', 'uperello8', 'Udell Perello', 'c2e2fe377040c2003777c369e1b14ca6', 'http://dummyimage.com/22x40.png/5fa2dd/ffffff', 'Programmable maximized contingency', '1993-07-18 11:11:16', 3);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('spaxman9@loc.gov', 'spaxman9', 'Sheelah Paxman', '6325e2cf52bfe350e8c747f0a985a396', 'http://dummyimage.com/34x24.png/5fa2dd/ffffff', 'Intuitive heuristic capability', '1995-07-14 10:51:40', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('bkillingbacka@answers.com', 'bkillingbacka', 'Beverlie Killingback', '1dd1819e6b1036a772e387ada2ff7f08', 'http://dummyimage.com/79x42.png/cc0000/ffffff', 'Optional methodical parallelism', '1989-08-26 17:57:38', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('aevesb@buzzfeed.com', 'aevesb', 'Arty Eves', '52af1d233005d114b5ff56252c2336ce', 'http://dummyimage.com/81x99.png/ff4444/ffffff', 'Centralized multimedia workforce', '1972-06-30 18:37:07', 1);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('adelouchc@uol.com.br', 'adelouchc', 'Ammamaria Delouch', '1edd6f03bdb3d9f87b2f44a35957ec64', 'http://dummyimage.com/45x53.png/ff4444/ffffff', 'Team-oriented maximized database', '1985-03-20 13:36:44', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('jellerd@amazon.de', 'jellerd', 'Jerrilee Eller', '849b81711b4b739174d785c5efe56f49', 'http://dummyimage.com/89x24.png/5fa2dd/ffffff', 'Organic dedicated core', '2003-04-17 12:15:12', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('bgrevee@google.nl', 'bgrevee', 'Bevin Greve', '507578d208068406cb652d97e2262207', 'http://dummyimage.com/13x30.png/dddddd/000000', 'Fundamental directional concept', '1959-01-18 05:36:46', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('jpetrofff@symantec.com', 'jpetrofff', 'Jeffie Petroff', '9139916ca18d5761f75f1af6de02f00a', 'http://dummyimage.com/26x38.png/5fa2dd/ffffff', 'Implemented asymmetric protocol', '1967-02-18 03:25:40', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('edibbleg@usa.gov', 'edibbleg', 'Eartha Dibble', '2e3661150980687b9da482c98e096f11', 'http://dummyimage.com/45x91.png/dddddd/000000', 'Mandatory object-oriented implementation', '1971-02-26 17:53:27', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('ibaudinh@mtv.com', 'ibaudinh', 'Ikey Baudin', '213d65a505011d4f1de3b86322667c29', 'http://dummyimage.com/33x96.png/5fa2dd/ffffff', 'Managed intermediate collaboration', '1992-07-23 20:18:31', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('ehurcombei@archive.org', 'ehurcombei', 'Earl Hurcombe', 'c3e0383d22e87a4035ead29b36695a8f', 'http://dummyimage.com/97x31.png/cc0000/ffffff', 'Multi-channelled leading edge synergy', '1960-09-22 19:58:51', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('dgiacoboj@archive.org', 'dgiacoboj', 'Dionisio Giacobo', 'bbf78db45828992c50c0d8ca1362ab36', 'http://dummyimage.com/83x19.png/cc0000/ffffff', 'Programmable 3rd generation moratorium', '1981-04-19 07:28:40', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('rnaulk@bigcartel.com', 'rnaulk', 'Rubina Naul', '71d92da288feacc3bad34268f9e32ef8', 'http://dummyimage.com/35x46.png/ff4444/ffffff', 'Customizable bandwidth-monitored ability', '1954-10-22 16:34:29', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('bgianellil@nationalgeographic.com', 'bgianellil', 'Burty Gianelli', '38703254ab77f158dc7d4d2e839f5965', 'http://dummyimage.com/99x13.png/5fa2dd/ffffff', 'Advanced next generation toolset', '1952-05-07 04:35:50', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('dwhannelm@vkontakte.ru', 'dwhannelm', 'Daloris Whannel', 'ac26555b4d3995fdd3e4df3c39b88fb4', 'http://dummyimage.com/38x24.png/5fa2dd/ffffff', 'Customer-focused demand-driven focus group', '1988-11-12 12:00:48', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('ebellfieldn@boston.com', 'ebellfieldn', 'Elicia Bellfield', 'b278de45f61123dab4c9124c8e4f82bd', 'http://dummyimage.com/50x98.png/cc0000/ffffff', 'Enterprise-wide dynamic monitoring', '1988-11-19 23:07:31', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('mewerto@aol.com', 'mewerto', 'Mart Ewert', 'db2f055cb789a1e0e354a6ad96aeeae1', 'http://dummyimage.com/100x80.png/ff4444/ffffff', 'Seamless didactic software', '1966-09-29 14:17:53', 2);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('ryvesp@fda.gov', 'ryvesp', 'Rafa Yves', '60b2c6ea9fe7dc34400d22edd6ac0b4e', 'http://dummyimage.com/80x88.png/cc0000/ffffff', 'Object-based didactic open system', '1969-03-19 08:53:50', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('eaikmanq@whitehouse.gov', 'eaikmanq', 'Emmy Aikman', '44612c4f839e20fd7947ac4cde556df7', 'http://dummyimage.com/65x91.png/5fa2dd/ffffff', 'Right-sized zero administration array', '1953-12-07 01:20:44', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('awestellr@skyrock.com', 'awestellr', 'Anstice Westell', 'a392dbfa722cd0b60360bde5ef899a06', 'http://dummyimage.com/72x32.png/cc0000/ffffff', 'Ameliorated local attitude', '1971-01-15 00:55:02', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('mdeverells@github.io', 'mdeverells', 'Mariejeanne Deverell', 'ac911e262e43c257aa6ce018121e185b', 'http://dummyimage.com/67x60.png/cc0000/ffffff', 'Public-key modular leverage', '1993-09-03 13:26:02', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('cdyersont@army.mil', 'cdyersont', 'Carmelina Dyerson', 'b65101c9ddca5ee60f1ec36e4b9290ec', 'http://dummyimage.com/83x25.png/5fa2dd/ffffff', 'Up-sized web-enabled utilisation', '1991-11-22 16:59:59', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('ldabernottu@reverbnation.com', 'ldabernottu', 'Lorilyn Dabernott', '63b7a6d0fd6cf8e82be8f520a9540bd8', 'http://dummyimage.com/97x57.png/5fa2dd/ffffff', 'Total holistic local area network', '1976-12-12 05:44:20', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('bramblev@si.edu', 'bramblev', 'Bealle Ramble', '7cb95a62ea0b4b9d4c18c8f829485b93', 'http://dummyimage.com/66x22.png/dddddd/000000', 'Multi-channelled didactic open architecture', '1969-03-23 14:29:36', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('tkonkew@cmu.edu', 'tkonkew', 'Taddeusz Konke', '55667524dd561762807eeb9af1472525', 'http://dummyimage.com/72x68.png/dddddd/000000', 'Intuitive tangible capability', '1973-10-31 07:10:15', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('dplumbx@pagesperso-orange.fr', 'dplumbx', 'Derrick Plumb', 'e391d0797686bdab391d294de0572912', 'http://dummyimage.com/12x22.png/5fa2dd/ffffff', 'Expanded neutral model', '1952-03-04 13:41:10', 1);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('pcatlowy@delicious.com', 'pcatlowy', 'Pearl Catlow', '78102277d49e81a2df0c2c41ae094b8c', 'http://dummyimage.com/96x75.png/ff4444/ffffff', 'Vision-oriented local portal', '1997-01-16 07:29:08', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('dpaysz@sohu.com', 'dpaysz', 'Darnell Pays', '1383c82e69b3b8cec3b32cc15f01e018', 'http://dummyimage.com/78x70.png/dddddd/000000', 'Optimized explicit structure', '1970-12-11 05:45:43', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('nbernardot10@constantcontact.com', 'nbernardot10', 'Norris Bernardot', 'bf1087807cc67e61953389a145d284e8', 'http://dummyimage.com/27x26.png/ff4444/ffffff', 'Expanded next generation ability', '1975-10-31 06:51:04', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('nwilkinson11@g.co', 'nwilkinson11', 'Nicoli Wilkinson', '8c0853fe3460c248a0e53ec02ef3d4ae', 'http://dummyimage.com/61x42.png/ff4444/ffffff', 'Digitized coherent database', '1972-06-04 23:54:51', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('jpoundsford12@businessinsider.com', 'jpoundsford12', 'Joyous Poundsford', 'ef1c18f3033e4ba8c14997febdb77c7d', 'http://dummyimage.com/36x96.png/ff4444/ffffff', 'Versatile demand-driven matrix', '1977-06-23 19:03:50', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('iziemen13@sfgate.com', 'iziemen13', 'Isidora Ziemen', '27f33f7d8bd66458b90a2240a830089c', 'http://dummyimage.com/69x99.png/cc0000/ffffff', 'Networked zero tolerance installation', '1978-04-14 14:24:30', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('sgisbye14@pcworld.com', 'sgisbye14', 'Salem Gisbye', '39461289a7e66ab74de74bb42be266a5', 'http://dummyimage.com/23x50.png/cc0000/ffffff', 'Down-sized contextually-based instruction set', '1997-05-19 08:22:31', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('rsleightholm15@deviantart.com', 'rsleightholm15', 'Roxi Sleightholm', '1588f99456584ecb0b0da9f19b593d41', 'http://dummyimage.com/66x44.png/cc0000/ffffff', 'Organized tangible intranet', '1960-06-06 22:14:40', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('cdeely16@icio.us', 'cdeely16', 'Corine Deely', '0204de1a4c9b5f27649e98cd190204d7', 'http://dummyimage.com/17x60.png/ff4444/ffffff', 'Pre-emptive fresh-thinking hierarchy', '2000-01-15 03:18:18', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('zadnam17@miibeian.gov.cn', 'zadnam17', 'Zilvia Adnam', 'cf4f52f6f4385ac4eb6078ce849a8aff', 'http://dummyimage.com/20x21.png/5fa2dd/ffffff', 'Front-line even-keeled migration', '1968-12-09 19:43:02', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('aschulke18@gizmodo.com', 'aschulke18', 'Annadiana Schulke', '41016df5ec84fa3a4e4f9d3692fbe776', 'http://dummyimage.com/87x71.png/dddddd/000000', 'Multi-lateral context-sensitive ability', '1953-12-09 14:43:24', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('rboutton19@bandcamp.com', 'rboutton19', 'Rosene Boutton', 'abc7679eea78ed424f0b2374eee7575f', 'http://dummyimage.com/66x78.png/5fa2dd/ffffff', 'Implemented demand-driven knowledge user', '1985-02-06 21:26:56', 2);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('nphillipson1a@salon.com', 'nphillipson1a', 'Niki Phillipson', '62a75ae0b7c90414597fcb6f3bc99872', 'http://dummyimage.com/49x67.png/cc0000/ffffff', 'Front-line radical conglomeration', '1962-01-17 20:11:53', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('roshevlan1b@epa.gov', 'roshevlan1b', 'Rafaello O''Shevlan', 'a36c87488495a7f6294c1354fc520459', 'http://dummyimage.com/99x94.png/dddddd/000000', 'Switchable stable toolset', '1973-05-01 15:39:06', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('tsearight1c@businesswire.com', 'tsearight1c', 'Thekla Searight', 'ab4bc5b52f4ed07e46d4dc3f8c7ac178', 'http://dummyimage.com/28x11.png/5fa2dd/ffffff', 'Ameliorated high-level complexity', '1998-08-30 02:54:11', NULL);
INSERT INTO "user" (email, username, "name", "password", profile_picture, bio , birth_date, banned_by) VALUES ('mcarruth1d@auda.org.au', 'mcarruth1d', 'Morey Carruth', '61da0aee32c1ab850d455c90e5e5731b', 'http://dummyimage.com/83x47.png/cc0000/ffffff', 'Secured fresh-thinking website', '1986-03-01 21:22:12', NULL);

INSERT INTO follow (follower, followed) VALUES (10, 26);
INSERT INTO follow (follower, followed) VALUES (41, 10);
INSERT INTO follow (follower, followed) VALUES (35, 48);
INSERT INTO follow (follower, followed) VALUES (2, 25);
INSERT INTO follow (follower, followed) VALUES (34, 5);
INSERT INTO follow (follower, followed) VALUES (22, 38);
INSERT INTO follow (follower, followed) VALUES (4, 27);
INSERT INTO follow (follower, followed) VALUES (8, 21);
INSERT INTO follow (follower, followed) VALUES (49, 48);
INSERT INTO follow (follower, followed) VALUES (19, 31);
INSERT INTO follow (follower, followed) VALUES (19, 10);
INSERT INTO follow (follower, followed) VALUES (31, 34);
INSERT INTO follow (follower, followed) VALUES (41, 39);
INSERT INTO follow (follower, followed) VALUES (8, 11);
INSERT INTO follow (follower, followed) VALUES (18, 5);
INSERT INTO follow (follower, followed) VALUES (16, 21);
INSERT INTO follow (follower, followed) VALUES (22, 49);
INSERT INTO follow (follower, followed) VALUES (24, 16);
INSERT INTO follow (follower, followed) VALUES (43, 22);
INSERT INTO follow (follower, followed) VALUES (7, 14);
INSERT INTO follow (follower, followed) VALUES (39, 26);
INSERT INTO follow (follower, followed) VALUES (13, 5);
INSERT INTO follow (follower, followed) VALUES (22, 6);
INSERT INTO follow (follower, followed) VALUES (7, 13);
INSERT INTO follow (follower, followed) VALUES (47, 10);
INSERT INTO follow (follower, followed) VALUES (39, 15);
INSERT INTO follow (follower, followed) VALUES (38, 49);
INSERT INTO follow (follower, followed) VALUES (31, 7);
INSERT INTO follow (follower, followed) VALUES (13, 1);
INSERT INTO follow (follower, followed) VALUES (9, 2);
INSERT INTO follow (follower, followed) VALUES (12, 16);
INSERT INTO follow (follower, followed) VALUES (20, 26);
INSERT INTO follow (follower, followed) VALUES (26, 45);
INSERT INTO follow (follower, followed) VALUES (26, 32);
INSERT INTO follow (follower, followed) VALUES (25, 42);
INSERT INTO follow (follower, followed) VALUES (17, 7);
INSERT INTO follow (follower, followed) VALUES (42, 32);
INSERT INTO follow (follower, followed) VALUES (8, 46);
INSERT INTO follow (follower, followed) VALUES (23, 35);
INSERT INTO follow (follower, followed) VALUES (18, 47);
INSERT INTO follow (follower, followed) VALUES (31, 42);
INSERT INTO follow (follower, followed) VALUES (2, 23);
INSERT INTO follow (follower, followed) VALUES (26, 18);
INSERT INTO follow (follower, followed) VALUES (33, 21);
INSERT INTO follow (follower, followed) VALUES (16, 2);
INSERT INTO follow (follower, followed) VALUES (39, 22);
INSERT INTO follow (follower, followed) VALUES (36, 45);
INSERT INTO follow (follower, followed) VALUES (36, 42);
INSERT INTO follow (follower, followed) VALUES (41, 32);
INSERT INTO follow (follower, followed) VALUES (32, 30);
INSERT INTO follow (follower, followed) VALUES (23, 33);
INSERT INTO follow (follower, followed) VALUES (40, 24);
INSERT INTO follow (follower, followed) VALUES (19, 47);
INSERT INTO follow (follower, followed) VALUES (4, 1);
INSERT INTO follow (follower, followed) VALUES (35, 17);
INSERT INTO follow (follower, followed) VALUES (26, 4);
INSERT INTO follow (follower, followed) VALUES (11, 49);
INSERT INTO follow (follower, followed) VALUES (13, 18);
INSERT INTO follow (follower, followed) VALUES (12, 34);
INSERT INTO follow (follower, followed) VALUES (23, 25);
INSERT INTO follow (follower, followed) VALUES (34, 38);
INSERT INTO follow (follower, followed) VALUES (17, 47);
INSERT INTO follow (follower, followed) VALUES (37, 28);
INSERT INTO follow (follower, followed) VALUES (5, 34);
INSERT INTO follow (follower, followed) VALUES (12, 41);
INSERT INTO follow (follower, followed) VALUES (26, 30);
INSERT INTO follow (follower, followed) VALUES (38, 19);
INSERT INTO follow (follower, followed) VALUES (47, 34);
INSERT INTO follow (follower, followed) VALUES (5, 16);
INSERT INTO follow (follower, followed) VALUES (46, 47);
INSERT INTO follow (follower, followed) VALUES (4, 23);
INSERT INTO follow (follower, followed) VALUES (24, 15);
INSERT INTO follow (follower, followed) VALUES (23, 13);
INSERT INTO follow (follower, followed) VALUES (44, 14);
INSERT INTO follow (follower, followed) VALUES (18, 17);
INSERT INTO follow (follower, followed) VALUES (16, 26);
INSERT INTO follow (follower, followed) VALUES (9, 34);
INSERT INTO follow (follower, followed) VALUES (31, 40);
INSERT INTO follow (follower, followed) VALUES (45, 32);
INSERT INTO follow (follower, followed) VALUES (27, 26);
INSERT INTO follow (follower, followed) VALUES (38, 15);
INSERT INTO follow (follower, followed) VALUES (20, 47);
INSERT INTO follow (follower, followed) VALUES (45, 47);
INSERT INTO follow (follower, followed) VALUES (15, 48);
INSERT INTO follow (follower, followed) VALUES (20, 4);
INSERT INTO follow (follower, followed) VALUES (30, 31);
INSERT INTO follow (follower, followed) VALUES (9, 22);
INSERT INTO follow (follower, followed) VALUES (4, 36);
INSERT INTO follow (follower, followed) VALUES (17, 18);
INSERT INTO follow (follower, followed) VALUES (7, 16);
INSERT INTO follow (follower, followed) VALUES (1, 35);
INSERT INTO follow (follower, followed) VALUES (44, 38);
INSERT INTO follow (follower, followed) VALUES (35, 18);

INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('User-friendly national capability', 'eget congue eget semper rutrum', NULL, NULL, 8);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Profit-focused static conglomeration', 'dolor quis odio consequat varius integer ac leo pellentesque ultrices mattis odio donec vitae nisi nam ultrices libero', NULL, NULL, 4);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Multi-channelled modular throughput', 'nisi nam ultrices libero non mattis pulvinar NULLa pede ullamcorper augue a suscipit NULLa elit ac NULLa sed vel', NULL, NULL, 17);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Polarised radical projection', 'luctus et ultrices posuere cubilia curae mauris viverra diam vitae quam suspendisse potenti NULLam porttitor lacus at', NULL, NULL, 16);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Up-sized local service-desk', 'cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi', NULL, NULL, 49);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Virtual uniform paradigm', 'at dolor quis odio consequat', NULL, NULL, 6);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Intuitive tertiary function', 'augue aliquam erat volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst', NULL, NULL, 45);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Devolved impactful installation', 'curabitur gravida nisi at nibh in hac habitasse', NULL, NULL, 45);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Switchable holistic Graphic Interface', 'at lorem integer tincidunt ante', NULL, NULL, 36);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Persistent needs-based alliance', 'a nibh in quis justo maecenas rhoncus aliquam lacus morbi quis tortor id NULLa ultrices aliquet maecenas leo odio condimentum', NULL, NULL, 2);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Mandatory demand-driven success', 'id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris', NULL, NULL, 45);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Open-source exuding protocol', 'diam cras pellentesque volutpat dui maecenas tristique est et tempus', NULL, NULL, 11);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Visionary neutral middleware', 'NULLa nisl nunc nisl duis bibendum felis sed', NULL, NULL, 41);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Expanded mission-critical attitude', 'vivamus metus arcu adipiscing molestie hendrerit at vulputate vitae nisl', NULL, NULL, 48);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Enhanced homogeneous framework', 'tristique est et tempus semper est quam pharetra magna ac', 'http://dummyimage.com/85x65.png/dddddd/000000', NULL, 40);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Digitized disintermediate time-frame', 'justo lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare consequat lectus in est risus', 'http://dummyimage.com/54x61.png/ff4444/ffffff', 'image', 32);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('De-engineered upward-trending implementation', 'tellus NULLa ut erat id mauris vulputate elementum NULLam varius NULLa facilisi cras non velit nec nisi vulputate', NULL, NULL, 13);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Persistent content-based open architecture', 'lectus pellentesque eget nunc donec quis orci eget orci vehicula condimentum curabitur in libero ut massa', NULL, NULL, 24);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Optimized eco-centric protocol', 'orci luctus et ultrices posuere cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui nec', NULL, NULL, 20);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Exclusive client-server algorithm', 'mi sit amet lobortis sapien sapien non', NULL, NULL, 31);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Ergonomic user-facing implementation', 'volutpat quam pede lobortis ligula sit amet eleifend pede libero quis orci NULLam molestie nibh in lectus pellentesque', NULL, NULL, 44);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Intuitive 24 hour hierarchy', 'rutrum ac lobortis vel dapibus at', NULL, NULL, 11);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Exclusive bottom-line concept', 'vel ipsum praesent blandit lacinia erat vestibulum sed magna', NULL, NULL, 7);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Vision-oriented full-range ability', 'mattis pulvinar NULLa pede ullamcorper augue a suscipit NULLa elit ac NULLa sed vel enim sit amet nunc', NULL, NULL, 49);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Stand-alone demand-driven concept', 'tortor quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut', NULL, NULL, 29);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Cross-platform multi-state secured line', 'donec ut dolor morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet', NULL, NULL, 17);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Innovative 4th generation encryption', 'lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit nam NULLa integer', 'http://dummyimage.com/38x99.png/ff4444/ffffff', 'image', 7);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Virtual context-sensitive budgetary management', 'suscipit ligula in lacus curabitur', NULL, NULL, 2);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Up-sized analyzing project', 'urna pretium nisl ut volutpat', 'http://dummyimage.com/46x24.png/ff4444/ffffff', 'image', 38);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Networked system-worthy model', 'in eleifend quam a odio', NULL, NULL, 10);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Polarised methodical hierarchy', 'nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin', NULL, NULL, 45);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Public-key multi-tasking instruction set', 'non ligula pellentesque ultrices phasellus id sapien in sapien iaculis', NULL, NULL, 3);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Configurable exuding service-desk', 'nibh ligula nec sem duis aliquam convallis nunc proin at turpis a pede posuere nonummy integer non', NULL, NULL, 36);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Implemented scalable challenge', 'dignissim vestibulum vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae NULLa dapibus dolor vel', NULL, NULL, 35);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Multi-channelled neutral throughput', 'commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet consectetuer', NULL, NULL, 16);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Managed uniform focus group', 'erat vestibulum sed magna at nunc commodo placerat praesent blandit nam NULLa integer pede justo lacinia', NULL, NULL, 45);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Triple-buffered full-range firmware', 'diam cras pellentesque volutpat dui maecenas tristique est et tempus', NULL, NULL, 23);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Managed directional success', 'vulputate elementum NULLam varius NULLa facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at', NULL, NULL, 19);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Switchable 24 hour complexity', 'id luctus nec molestie sed justo pellentesque viverra pede ac diam cras pellentesque volutpat dui maecenas tristique est et', NULL, NULL, 4);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Down-sized incremental database', 'elementum ligula vehicula consequat morbi a ipsum integer', NULL, NULL, 25);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Synergized demand-driven benchmark', 'curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet NULLa quisque arcu libero', NULL, NULL, 19);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Expanded content-based approach', 'magna bibendum imperdiet NULLam orci pede venenatis non sodales sed tincidunt eu felis fusce posuere felis', NULL, NULL, 38);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Up-sized 3rd generation product', 'pretium nisl ut volutpat sapien', NULL, NULL, 3);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Balanced background superstructure', 'luctus et ultrices posuere cubilia curae', NULL, NULL, 17);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Enhanced 3rd generation contingency', 'lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet NULLa quisque arcu libero rutrum', NULL, NULL, 46);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Intuitive transitional archive', 'NULLa suscipit ligula in lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus', 'http://dummyimage.com/79x50.png/dddddd/000000', 'image', 38);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Fully-configurable exuding toolset', 'amet turpis elementum ligula vehicula consequat', NULL, NULL, 31);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Expanded dedicated array', 'ligula in lacus curabitur at ipsum ac', NULL, NULL, 33);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Multi-tiered non-volatile groupware', 'NULLa suspendisse potenti cras in purus eu', NULL, NULL, 13);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Synergized eco-centric budgetary management', 'quis libero NULLam sit amet turpis elementum ligula vehicula consequat morbi a ipsum integer a nibh', 'http://dummyimage.com/19x22.png/cc0000/ffffff', 'image', 31);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Streamlined incremental project', 'nunc commodo placerat praesent blandit nam', NULL, NULL, 10);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Front-line bottom-line artificial intelligence', 'felis ut at dolor quis odio consequat varius integer ac leo pellentesque', NULL, NULL, 41);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Enterprise-wide non-volatile interface', 'ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et', 'http://dummyimage.com/98x83.png/cc0000/ffffff', 'image', 4);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Upgradable modular groupware', 'nec dui luctus rutrum NULLa tellus in sagittis dui vel nisl duis ac nibh fusce lacus purus', NULL, NULL, 8);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Multi-tiered eco-centric superstructure', 'diam nam tristique tortor eu pede', NULL, NULL, 48);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('User-friendly heuristic help-desk', 'morbi vel lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id', NULL, NULL, 13);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Synergistic mission-critical time-frame', 'lectus aliquam sit amet diam', NULL, NULL, 4);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Switchable multi-state interface', 'mauris viverra diam vitae quam suspendisse potenti NULLam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non', NULL, NULL, 44);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Self-enabling zero administration attitude', 'lectus in quam fringilla rhoncus mauris enim leo rhoncus sed vestibulum sit amet cursus id turpis integer aliquet', NULL, NULL, 45);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Centralized next generation algorithm', 'magna vulputate luctus cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus mus', NULL, NULL, 48);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Team-oriented full-range hub', 'vestibulum aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque', NULL, NULL, 27);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Fundamental 4th generation model', 'ut tellus NULLa ut erat id mauris vulputate elementum NULLam varius NULLa facilisi cras non velit', NULL, NULL, 19);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Intuitive attitude-oriented forecast', 'vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris eget massa', NULL, NULL, 48);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Pre-emptive user-facing matrices', 'NULLam varius NULLa facilisi cras non velit nec nisi vulputate nonummy maecenas tincidunt lacus at', NULL, NULL, 44);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Function-based hybrid matrix', 'at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent', NULL, NULL, 3);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Distributed well-modulated service-desk', 'lacus morbi quis tortor id NULLa ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed', NULL, NULL, 28);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Profit-focused composite model', 'orci eget orci vehicula condimentum', NULL, NULL, 28);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Multi-tiered upward-trending approach', 'volutpat in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus', NULL, NULL, 21);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Intuitive contextually-based array', 'quisque id justo sit amet sapien dignissim vestibulum vestibulum', NULL, NULL, 34);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Fundamental zero tolerance utilisation', 'sagittis sapien cum sociis natoque penatibus et magnis dis parturient montes nascetur ridiculus', NULL, NULL, 15);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Decentralized multimedia migration', 'accumsan odio curabitur convallis duis consequat dui nec nisi volutpat eleifend donec ut dolor morbi vel lectus in quam fringilla', NULL, NULL, 11);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Managed stable frame', 'lorem ipsum dolor sit amet consectetuer adipiscing elit proin', NULL, NULL, 41);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Stand-alone 24/7 migration', 'ante NULLa justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan', NULL, NULL, 18);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Customer-focused directional productivity', 'accumsan odio curabitur convallis duis consequat dui nec nisi volutpat eleifend donec ut dolor', NULL, NULL, 13);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Decentralized tangible core', 'tristique in tempus sit amet sem fusce consequat NULLa nisl nunc nisl duis bibendum felis', NULL, NULL, 34);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Optional demand-driven open system', 'ipsum primis in faucibus orci luctus et', NULL, NULL, 15);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Secured motivating superstructure', 'justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia nisi venenatis', NULL, NULL, 10);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Optional user-facing interface', 'quis libero NULLam sit amet turpis elementum ligula vehicula consequat morbi a ipsum integer a nibh in quis', NULL, NULL, 13);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Innovative multi-tasking orchestration', 'at turpis a pede posuere nonummy integer non velit donec diam neque vestibulum eget', NULL, NULL, 15);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Down-sized coherent analyzer', 'posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed nisl nunc rhoncus dui', NULL, NULL, 16);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Phased responsive knowledge base', 'proin at turpis a pede posuere nonummy integer non velit donec diam neque vestibulum eget vulputate', NULL, NULL, 39);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Operative 24/7 process improvement', 'faucibus orci luctus et ultrices posuere cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui nec nisi volutpat', NULL, NULL, 14);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Inverse neutral structure', 'dui luctus rutrum NULLa tellus in sagittis dui vel nisl duis ac nibh', 'http://dummyimage.com/28x15.png/ff4444/ffffff', 'image', 36);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('De-engineered multi-tasking access', 'sem sed sagittis nam congue risus semper porta volutpat quam pede lobortis ligula sit', NULL, NULL, 7);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Cloned transitional matrix', 'praesent id massa id nisl venenatis lacinia aenean sit amet justo morbi ut odio cras mi pede malesuada in imperdiet', NULL, NULL, 10);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Cross-group intermediate architecture', 'in congue etiam justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus', 'http://dummyimage.com/39x90.png/ff4444/ffffff', 'image', 30);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Team-oriented user-facing customer loyalty', 'bibendum felis sed interdum venenatis turpis enim blandit mi in', NULL, NULL, 44);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Operative zero tolerance model', 'massa volutpat convallis morbi odio', NULL, NULL, 15);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Adaptive incremental capability', 'libero nam dui proin leo odio porttitor id consequat in consequat ut', NULL, NULL, 1);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Right-sized context-sensitive throughput', 'amet eros suspendisse accumsan tortor quis turpis', NULL, NULL, 38);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Fundamental clear-thinking function', 'mus vivamus vestibulum sagittis sapien', NULL, NULL, 2);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Pre-emptive local budgetary management', 'NULLa sed accumsan felis ut at dolor quis odio consequat varius integer ac', NULL, NULL, 8);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Visionary mission-critical support', 'viverra diam vitae quam suspendisse potenti NULLam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris morbi', NULL, NULL, 49);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Upgradable 24/7 time-frame', 'luctus rutrum NULLa tellus in', NULL, NULL, 9);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Future-proofed systemic contingency', 'proin leo odio porttitor id consequat', NULL, NULL, 14);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('User-centric heuristic system engine', 'sed vel enim sit amet nunc viverra dapibus NULLa suscipit ligula in lacus', 'http://dummyimage.com/37x77.png/cc0000/ffffff', 'image', 30);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Function-based responsive support', 'at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna at nunc commodo placerat praesent blandit', NULL, NULL, 39);
INSERT INTO post (title, "content", media, media_type, user_id) VALUES ('Robust zero administration database', 'curae mauris viverra diam vitae quam suspendisse potenti', NULL, NULL, 30);

INSERT INTO moderator (moderator_id, assigned_by) VALUES (24, 3);
INSERT INTO moderator (moderator_id, assigned_by) VALUES (6, 1);
INSERT INTO moderator (moderator_id, assigned_by) VALUES (34, 2);
INSERT INTO moderator (moderator_id, assigned_by) VALUES (26, 1);

INSERT INTO tag ("name", description) VALUES ('sapien', NULL);
INSERT INTO tag ("name", description) VALUES ('odio', NULL);
INSERT INTO tag ("name", description) VALUES ('a', NULL);
INSERT INTO tag ("name", description) VALUES ('justo', NULL);
INSERT INTO tag ("name", description) VALUES ('orci', 'pellentesque ultrices phasellus id sapien in sapien iaculis congue vivamus');
INSERT INTO post_tag (post_id, tag_id) VALUES (49, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (23, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (16, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (12, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (17, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (27, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (42, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (9, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (41, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (26, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (37, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (27, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (38, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (48, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (32, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (30, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (22, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (13, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (3, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (17, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (13, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (26, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (30, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (14, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (32, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (28, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (9, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (4, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (44, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (3, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (45, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (23, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (44, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (22, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (21, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (42, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (50, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (20, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (20, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (4, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (36, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (2, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (49, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (23, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (10, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (5, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (32, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (21, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (24, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (11, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (27, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (47, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (34, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (20, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (38, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (49, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (11, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (19, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (18, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (18, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (14, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (31, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (36, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (1, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (15, 1);
INSERT INTO post_tag (post_id, tag_id) VALUES (36, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (32, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (10, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (20, 2);
INSERT INTO post_tag (post_id, tag_id) VALUES (12, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (22, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (43, 4);
INSERT INTO post_tag (post_id, tag_id) VALUES (10, 5);
INSERT INTO post_tag (post_id, tag_id) VALUES (44, 3);
INSERT INTO post_tag (post_id, tag_id) VALUES (28, 1);

INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('lectus aliquam sit amet diam in magna bibendum imperdiet NULLam orci pede venenatis non sodales sed tincidunt', 47, 68, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('rutrum rutrum neque aenean auctor gravida sem praesent id massa id nisl venenatis lacinia aenean sit amet', 15, 84, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('potenti NULLam porttitor lacus at turpis donec posuere metus vitae ipsum aliquam non mauris', 48, 86, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum at lorem', 4, 16, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit amet', 12, 54, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet diam in magna bibendum imperdiet', 38, 11, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('NULLa quisque arcu libero rutrum ac lobortis vel dapibus at diam', 17, 39, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis libero NULLam sit amet turpis', 27, 61, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('ac NULLa sed vel enim sit amet nunc viverra dapibus NULLa', 37, 20, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('a libero nam dui proin leo odio porttitor id consequat in consequat ut NULLa sed accumsan', 14, 3, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('duis mattis egestas metus aenean fermentum donec ut mauris eget massa tempor convallis NULLa neque libero convallis', 27, 35, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('neque vestibulum eget vulputate ut ultrices vel augue vestibulum ante ipsum primis in faucibus orci luctus et', 16, 14, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet NULLa quisque arcu libero rutrum', 16, 52, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('aliquam lacus morbi quis tortor id NULLa ultrices aliquet maecenas leo odio condimentum id', 49, 67, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('semper porta volutpat quam pede lobortis ligula sit amet eleifend pede libero quis orci NULLam molestie', 49, 17, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('et ultrices posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin', 2, 98, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus aliquet pulvinar sed', 21, 66, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus NULLa', 10, 33, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('mi integer ac neque duis bibendum morbi non quam nec dui luctus rutrum NULLa tellus in', 41, 20, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('pellentesque quisque porta volutpat erat quisque erat eros viverra eget congue eget semper rutrum NULLa nunc purus phasellus in felis', 17, 71, 5);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus orci', 8, 27, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('tincidunt eu felis fusce posuere felis sed lacus morbi sem mauris laoreet ut rhoncus', 46, 18, 3);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit', 43, 83, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('a feugiat et eros vestibulum ac est lacinia nisi venenatis tristique fusce', 44, 59, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('ipsum ac tellus semper interdum mauris ullamcorper purus sit amet NULLa quisque arcu libero rutrum', 1, 8, 1);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('fermentum donec ut mauris eget massa tempor convallis NULLa neque', 5, 55, 10);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('pede justo lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare consequat lectus', 21, 47, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('nibh in lectus pellentesque at NULLa suspendisse potenti cras in purus eu magna vulputate', 6, 3, 11);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('scelerisque quam turpis adipiscing lorem vitae mattis nibh ligula nec sem duis aliquam convallis nunc proin at', 29, 41, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('justo etiam pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus NULLa', 41, 4, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('eget eros elementum pellentesque quisque porta volutpat erat quisque erat eros viverra eget congue eget', 12, 53, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('pulvinar lobortis est phasellus sit amet erat NULLa tempus vivamus', 3, 8, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor quis turpis sed', 35, 5, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('eget tempus vel pede morbi porttitor lorem id ligula suspendisse ornare consequat lectus in est risus auctor sed', 9, 25, 12);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('dictumst maecenas ut massa quis augue luctus tincidunt NULLa mollis', 1, 17, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('lobortis ligula sit amet eleifend pede libero quis orci NULLam molestie nibh in lectus pellentesque', 21, 39, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut', 44, 16, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci mauris lacinia sapien quis', 23, 75, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('primis in faucibus orci luctus et ultrices posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin', 2, 20, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('duis bibendum morbi non quam nec dui luctus rutrum NULLa tellus in sagittis dui vel nisl duis ac nibh fusce', 28, 60, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('luctus et ultrices posuere cubilia curae NULLa dapibus dolor vel est donec', 8, 97, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('fermentum justo nec condimentum neque sapien placerat ante NULLa justo aliquam quis turpis eget elit sodales scelerisque', 30, 93, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus NULLa ut erat id mauris', 28, 17, 26);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('dapibus NULLa suscipit ligula in lacus curabitur at ipsum ac tellus semper interdum', 19, 11, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('id NULLa ultrices aliquet maecenas leo odio condimentum id luctus nec molestie sed justo pellentesque viverra', 33, 19, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('et ultrices posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi', 48, 79, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('quam pharetra magna ac consequat metus sapien ut nunc vestibulum', 33, 61, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('hac habitasse platea dictumst maecenas ut massa quis augue luctus', 13, 13, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('at turpis donec posuere metus vitae ipsum aliquam non mauris morbi non lectus aliquam sit amet', 17, 18, 21);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('morbi non quam nec dui luctus rutrum NULLa tellus in sagittis dui vel nisl', 18, 96, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('quisque porta volutpat erat quisque erat eros viverra eget congue eget semper rutrum NULLa', 44, 18, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('in faucibus orci luctus et ultrices posuere cubilia curae duis faucibus accumsan odio', 48, 23, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('et ultrices posuere cubilia curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit amet lobortis', 32, 67, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('curae donec pharetra magna vestibulum aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer', 19, 31, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('integer aliquet massa id lobortis convallis tortor risus dapibus augue vel accumsan tellus nisi eu orci', 36, 3, 14);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('ut erat curabitur gravida nisi at nibh in hac habitasse platea dictumst aliquam augue quam sollicitudin vitae consectetuer eget rutrum', 34, 35, 14);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('morbi non quam nec dui luctus rutrum NULLa tellus in sagittis dui vel nisl duis', 49, 24, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('hac habitasse platea dictumst maecenas ut massa quis augue luctus tincidunt', 10, 87, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('lacus curabitur at ipsum ac tellus semper interdum mauris ullamcorper purus sit amet', 18, 73, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('justo sollicitudin ut suscipit a feugiat et eros vestibulum ac est lacinia nisi venenatis tristique fusce congue diam id ornare', 32, 69, 13);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('volutpat dui maecenas tristique est et tempus semper est quam pharetra magna', 29, 33, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('porttitor lorem id ligula suspendisse ornare consequat lectus in est risus auctor sed tristique in tempus sit amet sem', 45, 28, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('pretium iaculis justo in hac habitasse platea dictumst etiam faucibus cursus urna ut tellus NULLa', 31, 75, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('vivamus in felis eu sapien cursus vestibulum proin eu mi NULLa ac enim in tempor turpis nec euismod scelerisque quam', 13, 30, 10);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('elementum in hac habitasse platea dictumst morbi vestibulum velit id pretium', 41, 1, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('at turpis a pede posuere nonummy integer non velit donec diam neque', 42, 7, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('lobortis sapien sapien non mi integer ac neque duis bibendum', 44, 83, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('justo aliquam quis turpis eget elit sodales scelerisque mauris sit amet eros suspendisse accumsan tortor quis', 16, 7, 6);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('primis in faucibus orci luctus et ultrices posuere cubilia curae duis faucibus accumsan odio curabitur convallis duis consequat dui', 35, 64, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('sapien ut nunc vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae', 48, 20, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('suscipit NULLa elit ac NULLa sed vel enim sit amet nunc viverra dapibus', 14, 18, 33);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('mi integer ac neque duis bibendum morbi non quam nec dui luctus rutrum NULLa tellus in sagittis', 25, 27, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('phasellus in felis donec semper sapien a libero nam dui proin leo odio porttitor id consequat', 36, 71, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('malesuada in imperdiet et commodo vulputate justo in blandit ultrices enim lorem ipsum dolor sit amet consectetuer adipiscing elit proin', 6, 5, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('interdum in ante vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia', 13, 70, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('aliquet at feugiat non pretium quis lectus suspendisse potenti in eleifend quam a', 22, 13, 24);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('mus vivamus vestibulum sagittis sapien cum sociis natoque penatibus et magnis dis', 24, 6, 32);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('volutpat quam pede lobortis ligula sit amet eleifend pede libero quis orci NULLam molestie nibh in lectus pellentesque at', 7, 25, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('proin interdum mauris non ligula pellentesque ultrices phasellus id sapien in', 24, 25, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('dis parturient montes nascetur ridiculus mus etiam vel augue vestibulum rutrum rutrum neque aenean', 48, 48, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('NULLa integer pede justo lacinia eget tincidunt eget tempus vel pede morbi porttitor lorem id ligula suspendisse', 16, 8, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('nonummy maecenas tincidunt lacus at velit vivamus vel NULLa eget eros elementum pellentesque', 45, 65, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('eros viverra eget congue eget semper rutrum NULLa nunc purus phasellus in felis', 9, 58, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('eget eleifend luctus ultricies eu nibh quisque id justo sit amet sapien dignissim vestibulum vestibulum ante ipsum primis in faucibus', 9, 10, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('ridiculus mus etiam vel augue vestibulum rutrum rutrum neque aenean auctor', 33, 25, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('at lorem integer tincidunt ante vel ipsum praesent blandit lacinia erat vestibulum sed magna', 3, 57, 23);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('sem sed sagittis nam congue risus semper porta volutpat quam pede lobortis ligula sit', 17, 23, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('duis ac nibh fusce lacus purus aliquet at feugiat non pretium quis lectus suspendisse potenti', 37, 21, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('vestibulum aliquet ultrices erat tortor sollicitudin mi sit amet lobortis sapien sapien non mi integer ac neque duis bibendum morbi', 30, 90, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('tincidunt in leo maecenas pulvinar lobortis est phasellus sit amet erat NULLa tempus vivamus in felis eu sapien', 20, 22, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('vehicula condimentum curabitur in libero ut massa volutpat convallis morbi odio odio elementum eu interdum', 1, 81, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('pellentesque quisque porta volutpat erat quisque erat eros viverra eget congue eget semper rutrum NULLa nunc purus phasellus in felis', 5, 58, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('pede libero quis orci NULLam molestie nibh in lectus pellentesque at NULLa suspendisse potenti cras in purus eu magna vulputate', 30, 31, 93);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('etiam faucibus cursus urna ut tellus NULLa ut erat id mauris vulputate elementum NULLam', 15, 17, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('lectus aliquam sit amet diam in magna bibendum imperdiet NULLam orci pede venenatis non sodales sed', 2, 82, 47);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('est et tempus semper est quam pharetra magna ac consequat metus sapien ut nunc vestibulum ante ipsum primis in faucibus', 2, 94, NULL);
INSERT INTO "comment" ("content", user_id, post_id, parent_comment) VALUES ('quis turpis sed ante vivamus tortor duis mattis egestas metus aenean fermentum donec ut mauris eget massa tempor', 33, 12, NULL);

INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (42, 69, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (12, 82, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (12, 63, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (3, 87, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (17, 69, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (3, 66, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (40, 1, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (45, 15, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (32, 60, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (37, 98, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (9, 86, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (47, 56, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (44, 43, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (12, 18, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (31, 35, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (21, 62, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (35, 75, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (10, 49, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (16, 94, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (42, 37, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (25, 70, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (21, 26, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (5, 49, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (16, 78, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (48, 86, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (13, 38, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (46, 18, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (22, 50, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (26, 43, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (42, 68, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (27, 8, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (14, 28, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (13, 60, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (3, 93, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (33, 21, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (46, 64, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (10, 97, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (19, 83, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (26, 77, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (14, 63, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (17, 8, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (49, 33, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (42, 83, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (47, 85, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (28, 87, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (40, 98, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (44, 35, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (14, 6, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (17, 39, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (42, 87, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (11, 10, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (41, 13, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (30, 19, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (24, 33, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (19, 77, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (4, 85, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (7, 46, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (26, 84, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (11, 34, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (4, 50, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (36, 5, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (33, 56, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (38, 16, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (10, 20, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (6, 86, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (31, 62, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (28, 83, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (28, 8, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (21, 41, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (27, 58, FALSE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (40, 77, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (38, 18, TRUE);
INSERT INTO user_vote_post (user_id, post_id, type_of_vote) VALUES (45, 2, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (1, 59, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (13, 35, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (19, 56, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (23, 92, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (47, 6, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (26, 44, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (7, 47, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (11, 69, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (38, 64, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (36, 2, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (40, 8, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (10, 40, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (32, 86, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (19, 67, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (27, 31, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (6, 84, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (10, 96, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (27, 69, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (2, 83, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (27, 76, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (46, 23, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (14, 25, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (38, 47, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (36, 47, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (21, 7, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (44, 47, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (40, 81, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (27, 61, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (17, 7, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (16, 28, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (30, 39, FALSE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (11, 14, TRUE);
INSERT INTO user_vote_comment (user_id, comment_id, type_of_vote) VALUES (34, 63, FALSE);

INSERT INTO "block" (blocker, blocked) VALUES (5, 17);
INSERT INTO "block" (blocker, blocked) VALUES (27, 37);
INSERT INTO "block" (blocker, blocked) VALUES (37, 2);
INSERT INTO "block" (blocker, blocked) VALUES (29, 19);
INSERT INTO "block" (blocker, blocked) VALUES (39, 49);
INSERT INTO "block" (blocker, blocked) VALUES (35, 28);
INSERT INTO "block" (blocker, blocked) VALUES (32, 13);
INSERT INTO "block" (blocker, blocked) VALUES (9, 21);
INSERT INTO "block" (blocker, blocked) VALUES (30, 10);
INSERT INTO "block" (blocker, blocked) VALUES (40, 36);
INSERT INTO "block" (blocker, blocked) VALUES (17, 27);

INSERT INTO save_post (post_id, user_id) VALUES (24, 2);
INSERT INTO save_post (post_id, user_id) VALUES (65, 33);
INSERT INTO save_post (post_id, user_id) VALUES (36, 44);
INSERT INTO save_post (post_id, user_id) VALUES (89, 29);
INSERT INTO save_post (post_id, user_id) VALUES (67, 5);
INSERT INTO save_post (post_id, user_id) VALUES (90, 3);
INSERT INTO save_post (post_id, user_id) VALUES (13, 40);
INSERT INTO save_post (post_id, user_id) VALUES (20, 46);
INSERT INTO save_post (post_id, user_id) VALUES (77, 30);
INSERT INTO save_post (post_id, user_id) VALUES (41, 4);
INSERT INTO save_post (post_id, user_id) VALUES (95, 7);
INSERT INTO save_post (post_id, user_id) VALUES (30, 22);
INSERT INTO save_post (post_id, user_id) VALUES (72, 12);
INSERT INTO save_post (post_id, user_id) VALUES (48, 33);
INSERT INTO save_post (post_id, user_id) VALUES (47, 28);
INSERT INTO save_post (post_id, user_id) VALUES (61, 36);
INSERT INTO save_post (post_id, user_id) VALUES (36, 43);
INSERT INTO save_post (post_id, user_id) VALUES (26, 35);
INSERT INTO save_post (post_id, user_id) VALUES (92, 44);
INSERT INTO save_post (post_id, user_id) VALUES (50, 5);
INSERT INTO save_post (post_id, user_id) VALUES (90, 43);
INSERT INTO save_post (post_id, user_id) VALUES (5, 46);
INSERT INTO save_post (post_id, user_id) VALUES (77, 17);
INSERT INTO save_post (post_id, user_id) VALUES (13, 32);
INSERT INTO save_post (post_id, user_id) VALUES (19, 47);
INSERT INTO save_post (post_id, user_id) VALUES (36, 12);


INSERT INTO "search" ("content", user_id) VALUES ('vulputate elementum NULLam', 7);
INSERT INTO "search" ("content", user_id) VALUES ('montes', 49);
INSERT INTO "search" ("content", user_id) VALUES ('mi', 30);
INSERT INTO "search" ("content", user_id) VALUES ('mus etiam vel augue', 24);
INSERT INTO "search" ("content", user_id) VALUES ('nisl nunc rhoncus dui', 24);
INSERT INTO "search" ("content", user_id) VALUES ('eros vestibulum ac est lacinia', 28);
INSERT INTO "search" ("content", user_id) VALUES ('ante', 46);
INSERT INTO "search" ("content", user_id) VALUES ('mus vivamus', 44);
INSERT INTO "search" ("content", user_id) VALUES ('sagittis sapien cum sociis natoque', 7);
INSERT INTO "search" ("content", user_id) VALUES ('eu orci mauris lacinia', 39);
INSERT INTO "search" ("content", user_id) VALUES ('platea dictumst aliquam', 34);
INSERT INTO "search" ("content", user_id) VALUES ('vestibulum sagittis', 7);
INSERT INTO "search" ("content", user_id) VALUES ('mattis pulvinar NULLa', 7);
INSERT INTO "search" ("content", user_id) VALUES ('magna at nunc', 1);
INSERT INTO "search" ("content", user_id) VALUES ('viverra eget congue', 36);
INSERT INTO "search" ("content", user_id) VALUES ('sagittis nam congue risus', 40);
INSERT INTO "search" ("content", user_id) VALUES ('eleifend donec ut', 8);
INSERT INTO "search" ("content", user_id) VALUES ('aenean lectus pellentesque', 27);
INSERT INTO "search" ("content", user_id) VALUES ('rutrum neque aenean auctor', 20);


INSERT INTO "message" ("content", sender, receiver) VALUES ('elementum eu interdum eu tincidunt in leo maecenas pulvinar', 11, 39);
INSERT INTO "message" ("content", sender, receiver) VALUES ('curabitur in libero ut massa volutpat convallis', 8, 15);
INSERT INTO "message" ("content", sender, receiver) VALUES ('in eleifend quam a odio in hac habitasse platea dictumst', 24, 48);
INSERT INTO "message" ("content", sender, receiver) VALUES ('et eros vestibulum ac est', 48, 12);
INSERT INTO "message" ("content", sender, receiver) VALUES ('erat vestibulum sed magna at nunc', 17, 6);
INSERT INTO "message" ("content", sender, receiver) VALUES ('at velit eu est congue', 6, 27);


INSERT INTO user_follow_tag (user_id, tag_id) VALUES (21, 5);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (33, 5);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (23, 3);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (45, 1);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (15, 3);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (36, 3);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (14, 1);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (27, 2);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (38, 4);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (44, 1);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (11, 4);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (16, 2);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (35, 5);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (28, 4);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (10, 2);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (48, 5);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (31, 3);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (26, 1);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (28, 3);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (37, 3);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (30, 4);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (16, 5);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (5, 1);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (4, 2);
INSERT INTO user_follow_tag (user_id, tag_id) VALUES (34, 1);

INSERT INTO report ("content", reviewer, reporter, reported_user, reported_post, reported_comment) VALUES ('bla bla bla', 24, 2, 1, NULL, NULL);
INSERT INTO report ("content", reviewer, reporter, reported_user, reported_post, reported_comment) VALUES ('bla ahah bla', 6, 4, NULL, 34, NULL);
INSERT INTO report ("content", reviewer, reporter, reported_user, reported_post, reported_comment) VALUES ('bla djhfle bla', 34, 2, NULL, NULL, 8);
INSERT INTO report ("content", reviewer, reporter, reported_user, reported_post, reported_comment) VALUES ('bla bla bncewçnla', 26, 2, 14, NULL, NULL);

