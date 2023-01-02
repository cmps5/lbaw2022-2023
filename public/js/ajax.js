function addEventListeners() {
    let followTag = document.querySelectorAll('div.tag');

    console.log(followTag);
    //dividir aqui
    [].forEach.call(followTag, function (tag) {

        tag.addEventListener('click', followTagRequest);

    });

    let followUser = document.querySelectorAll('.follow');
    console.log(followUser);
    [].forEach.call(followUser, function (user) {
        user.addEventListener('click', followUserRequest);
    });

    let blockUser = document.querySelectorAll('.block');
    console.log(blockUser);
    [].forEach.call(blockUser, function (user) {
        user.addEventListener('click', blockUserRequest);
    });
}

function encodeForAjax(data) {
    if (data == null) return null;
    return Object.keys(data).map(function (k) {
        console.log(data);
        return encodeURIComponent(k) + '=' + encodeURIComponent(data[k])
    }).join('&');
}

function sendAjaxRequest(method, url, data, handler) {
    try {

        let request = new XMLHttpRequest();
        request.open(method, url, true);
        request.setRequestHeader('X-CSRF-TOKEN', document.querySelector('meta[name="csrf-token"]').content);
        request.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        request.addEventListener('load', handler);
        request.send(encodeForAjax(data));

    } catch (err) {
        console.log(err);
    }

}


//Mudar o id (no blade)
//colocar a operação (+ -)no if (no blade)
//tratar aqui da mudança
function followTagRequest() {

    let tag_id = this.getAttribute('tag_id');
    let user_id = this.getAttribute('user_id');

    let operation = this.children.item(0).id;

    if (operation.includes("unfollow")) {

        sendAjaxRequest('post', '/api/user_tags', {
            user_id: user_id,
            tag_id: tag_id,
            '_method': 'DELETE'
        }, null);

    } else sendAjaxRequest('post', '/api/user_tags', {
        tag_id: tag_id,
        user_id: user_id
    }, null);
}



function followUserRequest() {

    let follower = this.getAttribute('follower');
    let followed = this.getAttribute('followed');

    if(this.id == 'unfollow-btn')
    {
        console.log("deleting relation");
        sendAjaxRequest('post', '/api/followers', {
            follower: follower,
            followed: followed,
            '_method': 'DELETE'
        }, null);

        this.textContent = "Follow";
        this.id = "follow-btn";

    }
    else
    {
        sendAjaxRequest('post', '/api/followers', {
            follower: follower,
            followed: followed
        }, null);

        this.textContent = "Unfollow";
        this.id = "unfollow-btn";
    }
    location.reload();

}

function blockUserRequest() {

    let blocker = this.getAttribute('blocker');
    let blocked = this.getAttribute('blocked');

    if(this.id == 'unblock-btn')
    {
        console.log("deleting relation");
        sendAjaxRequest('post', '/api/blocks', {
            blocker: blocker,
            blocked: blocked,
            '_method': 'DELETE'
        }, null);

        this.textContent = "Block";
        this.id = "block-btn";

    }
    else
    {
        sendAjaxRequest('post', '/api/blocks', {
            blocker: blocker,
            blocked: blocked
        }, null);

        this.textContent = "Unblock";
        this.id = "unblock-btn";
    }

    //location.reload();
}

addEventListeners();
