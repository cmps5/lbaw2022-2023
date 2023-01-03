function appearPlus(name) {
    var operationIcon = document.getElementById('follow' + name);

    if(operationIcon == null) operationIcon = document.getElementById('unfollow' + name);

    operationIcon.style.display= "unset";
    operationIcon.style.color = "black";
}

function disappearPlus(name) {
    var operationIcon = document.getElementById('follow' + name);

    if(operationIcon == null) operationIcon = document.getElementById('unfollow' + name);

    operationIcon.style.display= "none";
}

function pressedPlus(name){
    var operationIcon = document.getElementById('follow' + name);

    if(operationIcon == null) operationIcon = document.getElementById('unfollow' + name);

    operationIcon.style.backgroundColor = "black";
    operationIcon.style.color = "white";
}

function unpressedPlus(name){
    var operationIcon = document.getElementById('follow' + name);

    if(operationIcon == null) operationIcon = document.getElementById('unfollow' + name);

    operationIcon.style.backgroundColor = "azure";
    operationIcon.style.color = "black";
}


