function appearFollowTag(name) {
    var followIcon = document.getElementById('follow' + name);
    followIcon.style.display= "unset";
    followIcon.style.color = "black";
}

function disappearFollowTag(name) {
    var followIcon = document.getElementById('follow' + name);
    followIcon.style.display= "none";
}

function followTagPressed(name){
    var followIcon = document.getElementById('follow' + name);
    followIcon.style.backgroundColor = "black";
    followIcon.style.color = "white";
}

function followTagUnpressed(name){
    var followIcon = document.getElementById('follow' + name);
    followIcon.style.backgroundColor = "azure";
    followIcon.style.color = "black";
}
