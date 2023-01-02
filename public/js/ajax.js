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
