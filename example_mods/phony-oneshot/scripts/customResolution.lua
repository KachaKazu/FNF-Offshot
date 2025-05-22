-- Custom Resolution script by Stilic
-- Please credit me if used for your mods!!
local gameWidth, gameHeight = 822, 720

---  DON'T TOUCH THE STUFF BELOW UNLESS YOU KNOW WHAT YOU'RE DOING  ---

local keep = false

function hx(code) runHaxeCode("(function(){" .. code .. "})();") end

local function changeResolution(w, h)
    setPropertyFromClass("flixel.FlxG", "width", w)
    setPropertyFromClass("flixel.FlxG", "height", h)

    setPropertyFromClass("flixel.FlxG", "scaleMode.scale.x", 1)
    setPropertyFromClass("flixel.FlxG", "scaleMode.scale.y", 1)
    setPropertyFromClass("flixel.FlxG", "game.x", 0)
    setPropertyFromClass("flixel.FlxG", "game.y", 0)

    hx([[
        var w = ]] .. w .. [[;
        var h = ]] .. h .. [[;
        for (cam in FlxG.cameras.list) {
            var oldW = cam.width;
			var oldH = cam.height;

			var newW = Math.ceil(w / cam.zoom);
			var newH = Math.ceil(h / cam.zoom);

			cam.setSize(newW, newH);
			cam.flashSprite.x += (newW - oldW) / 2;
			cam.flashSprite.y += (newH - oldH) / 2;
        }
    ]])

    setPropertyFromClass("flixel.FlxG", "camera.width", w)
    setPropertyFromClass("flixel.FlxG", "camera.height", h)

    setPropertyFromClass("openfl.Lib", "application.window.width", w)
    setPropertyFromClass("openfl.Lib", "application.window.height", h)
end

function onCreate()
    setPropertyFromClass("openfl.Lib", "application.window.resizable", false)

    addHaxeLibrary("Math")
    addHaxeLibrary("RatioScaleMode", "flixel.system.scaleModes")
    hx("FlxG.scaleMode = new RatioScaleMode(true);")

    keep = getPropertyFromClass("openfl.Lib", "application.window.width") ~=
               gameWidth or
               getPropertyFromClass("openfl.Lib", "application.window.height") ~=
               gameHeight

    changeResolution(gameWidth, gameHeight)

    addHaxeLibrary('Application', 'lime.app')
    addHaxeLibrary('Image','lime.graphics')
    runHaxeCode([[
     var Icon:Image=Image.fromFile(Paths.modFolders('images/gameIcon.png'));
     Application.current.window.setIcon(Icon);
 ]])
end

function onCreatePost() if keep then restartSong(true) end end

function onCountdownStarted()
    if not middlescroll then
        for i = 0, getProperty("strumLineNotes.length") - 1 do
            setPropertyFromGroup("strumLineNotes", i, "x", getPropertyFromGroup(
                                     "strumLineNotes", i, "x") - 75)
        end
    end
    hx([[
        for (i in 0...game.playerStrums.length) {
            game.setOnLuas('defaultPlayerStrumX' + i, game.playerStrums.members[i].x);
            game.setOnLuas('defaultPlayerStrumY' + i, game.playerStrums.members[i].y);
        }
        for (i in 0...game.opponentStrums.length) {
            game.setOnLuas('defaultOpponentStrumX' + i, game.opponentStrums.members[i].x);
            game.setOnLuas('defaultOpponentStrumY' + i, game.opponentStrums.members[i].y);
        }
    ]])
end

function onDestroy()
    if not keep then
        setPropertyFromClass("openfl.Lib", "application.window.resizable", true)
        hx("FlxG.scaleMode = new RatioScaleMode();")
        changeResolution(getPropertyFromClass("flixel.FlxG", "initialWidth"),
                         getPropertyFromClass("flixel.FlxG", "initialHeight"))
    end
end
