function showUserSavedPosts()
{
    document.getElementById('posts').style.display = 'none';
    document.getElementById('tags').style.display = 'none';
    document.getElementById('savedPosts').style.display = 'unset';

    document.getElementById('postsSelector').className = 'flex-item ml-3';
    document.getElementById('savedPostsSelector').className = 'flex-item ml-3 border-top border-secondary';
    document.getElementById('tagsSelector').className = 'flex-item ml-3';

}

function showUserTags()
{
    document.getElementById('posts').style.display = 'none';
    document.getElementById('tags').style.display = 'unset';
    document.getElementById('savedPosts').style.display = 'none';

    document.getElementById('postsSelector').className = 'flex-item ml-3';
    document.getElementById('savedPostsSelector').className = 'flex-item ml-3';
    document.getElementById('tagsSelector').className = 'flex-item ml-3 border-top border-secondary';

}

function showUserPosts()
{
    document.getElementById('posts').style.display = 'unset';
    document.getElementById('tags').style.display = 'none';
    document.getElementById('savedPosts').style.display = 'none';

    document.getElementById('postsSelector').className = 'flex-item ml-3 border-top border-secondary';
    document.getElementById('savedPostsSelector').className = 'flex-item ml-3';
    document.getElementById('tagsSelector').className = 'flex-item ml-3';

}

