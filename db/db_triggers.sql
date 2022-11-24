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
