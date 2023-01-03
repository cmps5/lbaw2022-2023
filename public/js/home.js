
let ViewTopPosts = document.getElementById('ViewTopPosts');
let ViewRecentPosts = document.getElementById('ViewRecentPosts');
let STopPosts = document.getElementById('ShowTopPosts');
let SRecentPosts = document.getElementById('ShowRecentPosts');

function ShowRecentPosts(){
    ViewTopPosts.className = 'ml-3';
    ViewRecentPosts.className = 'ml-3 border-top border-secondary';

    STopPosts.style.display = 'none';
    SRecentPosts.style.display = 'block';
}

function ShowTopPosts(){
    ViewRecentPosts.className = 'ml-3';
    ViewTopPosts.className = 'ml-3 border-top border-secondary';

    STopPosts.style.display = 'block';
    SRecentPosts.style.display = 'none';
}
