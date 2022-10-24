-- performance indexes 
CREATE INDEX user_search ON "search" USING btree (user_id, time_searched DESC);
CREATE INDEX user_message ON "message" USING btree (sender, receiver);
CREATE INDEX user_post ON post USING hash (user_id);
