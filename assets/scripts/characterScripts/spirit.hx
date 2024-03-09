function createPost(){
    if (dad.curCharacter == "spirit"){
        var evilTrail = new FlxTrail(dad, null, 4, 24, 0.3, 0.069);
        add(evilTrail);
        trace('added the trail');
    }
}