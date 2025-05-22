function onCreate()
	setProperty('skipCountdown', true)
	setPropertyFromClass("openfl.Lib", "application.window.title", "BURIAL")
end

function onCreatePost()
	makeLuaSprite('pixelated')
    setSpriteShader('pixelated', 'pixel')
    runHaxeCode([[
        game.camGame.filters = [new ShaderFilter(game.getLuaObject('pixelated').shader)];
        game.camHUD.filters = [new ShaderFilter(game.getLuaObject('pixelated').shader)];
		game.camOther.filters = [new ShaderFilter(game.getLuaObject('pixelated').shader)];
    ]])
end

function onDestroy()
	setPropertyFromClass("openfl.Lib", "application.window.title", "Friday Night Funkin': Psych Engine")
end

function onUpdatePost()
	setProperty('grpNoteSplashes.visible', false)
	setProperty('camZooming', false)

    setShaderFloat('pixelated', 'iTime', os.clock())
	setShaderFloat('pixelated', 'pixelSize', 250)
end