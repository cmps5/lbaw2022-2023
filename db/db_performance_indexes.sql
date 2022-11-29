-- performance indexes
DROP INDEX IF EXISTS user_search;
DROP INDEX IF EXISTS user_message;
DROP INDEX IF EXISTS user_post;

CREATE INDEX user_search ON "search" USING btree (user_id, time_searched DESC);
CREATE INDEX user_message ON "message" USING btree (sender, receiver);
CREATE INDEX user_post ON post USING hash (user_id);
