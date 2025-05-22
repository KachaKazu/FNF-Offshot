import flixel.FlxObject;

var cameraLeft:FlxCamera;
var cameraRight:FlxCamera;
var pointOfZalgo:FlxObject;
var pointOfKnux:FlxObject;

function onCreatePost() {
	cameraLeft = new FlxCamera();
	cameraLeft.width = 411;
	cameraLeft.zoom = 0.7;

	cameraRight = new FlxCamera();
	cameraRight.width = 411;
	cameraRight.x += 411;
	cameraRight.zoom = 1.2;

	FlxG.cameras.remove(game.camHUD, false);
	FlxG.cameras.remove(game.camOther, false);
	FlxG.cameras.add(cameraLeft);
	FlxG.cameras.add(cameraRight);
	FlxG.cameras.add(game.camHUD, false);
	FlxG.cameras.add(game.camOther, false);

	var pointOfZalgo:FlxObject = new FlxObject();
	pointOfZalgo.setPosition(-340, 1);
	add(pointOfZalgo);

	var pointOfKnux:FlxObject = new FlxObject();
	pointOfKnux.setPosition(900, 1100);
	add(pointOfKnux);

	cameraLeft.follow(pointOfZalgo);
	cameraRight.follow(pointOfKnux);

	cameraLeft.filters = [new ShaderFilter(game.getLuaObject('bruh').shader)];
	cameraRight.filters = [new ShaderFilter(game.getLuaObject('bruh').shader)];
}

function onUpdatePost(e) {
	cameraLeft.zoom = FlxMath.lerp(0.7, cameraLeft.zoom, Math.exp(-e * 3.125 * playbackRate));
	cameraRight.zoom = FlxMath.lerp(1.2, cameraRight.zoom, Math.exp(-e * 3.125 * playbackRate));
}

function onEvent(n, v1, v2) {
	if (n == 'Add Camera Zoom') {
		cameraLeft.zoom += 0.0375;
		cameraRight.zoom += 0.075;
	}
}
