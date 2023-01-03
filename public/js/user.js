let posts = document.getElementById('posts');
let tags = document.getElementById('tags');
let followers = document.getElementById('followers');
let following = document.getElementById('following');
let blocking = document.getElementById('blocking');

let postsSelector = document.getElementById('postsSelector');
let tagsSelector = document.getElementById('tagsSelector');
let followersSelector = document.getElementById('followersSelector');
let followingSelector = document.getElementById('followingSelector');
let blockingSelector = document.getElementById('blockingSelector');


function showUserTags() {
    posts.style.display = "none";
    tags.style.display = "unset";
    followers.style.display = "none";
    following.style.display = "none";
    if (blocking != null) blocking.style.display = "none";

    postsSelector.className = 'flex-item ml-3';
    tagsSelector.className = 'flex-item ml-3 border-top border-secondary';
    followersSelector.className = 'flex-item ml-3';
    followingSelector.className = 'flex-item ml-3';
    if (blockingSelector != null) blockingSelector.className = 'flex-item ml-3';
}

function showUserPosts() {
    posts.style.display = "unset";
    tags.style.display = "none";
    followers.style.display = "none";
    following.style.display = "none";
    if (blocking != null) blocking.style.display = "none";

    postsSelector.className = 'flex-item ml-3 border-top border-secondary';
    tagsSelector.className = 'flex-item ml-3';
    followersSelector.className = 'flex-item ml-3';
    followingSelector.className = 'flex-item ml-3';
    if (blockingSelector != null) blockingSelector.className = 'flex-item ml-3';
}

function showFollowers() {
    console.log("opa")
    posts.style.display = "none";
    tags.style.display = "none";
    followers.style.display = "unset";
    following.style.display = "none";
    if (blocking != null) blocking.style.display = "none";

    postsSelector.className = 'flex-item ml-3';
    tagsSelector.className = 'flex-item ml-3';
    followersSelector.className = 'flex-item ml-3 border-top border-secondary';
    followingSelector.className = 'flex-item ml-3';
    if (blockingSelector != null) blockingSelector.className = 'flex-item ml-3';
}

function showFollowing() {
    posts.style.display = "none";
    tags.style.display = "none";
    followers.style.display = "none";
    following.style.display = "unset";
    if (blocking != null) blocking.style.display = "none";

    postsSelector.className = 'flex-item ml-3';
    tagsSelector.className = 'flex-item ml-3';
    followersSelector.className = 'flex-item ml-3';
    followingSelector.className = 'flex-item ml-3 border-top border-secondary';
    if (blockingSelector != null) blockingSelector.className = 'flex-item ml-3';
}

function showBlocking() {
    posts.style.display = "none";
    tags.style.display = "none";
    followers.style.display = "none";
    following.style.display = "none";
    blocking.style.display = "unset";

    postsSelector.className = 'flex-item ml-3';
    tagsSelector.className = 'flex-item ml-3';
    followersSelector.className = 'flex-item ml-3';
    followingSelector.className = 'flex-item ml-3';
    blockingSelector.className = 'flex-item ml-3 border-top border-secondary';
}
