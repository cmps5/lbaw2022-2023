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


