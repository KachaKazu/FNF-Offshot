local doShaderZoom = false

function onCreate()
	setProperty('skipCountdown', true)
	setPropertyFromClass("openfl.Lib", "application.window.title", "PHONY")
end

function onCreatePost()
    makeLuaSprite('opipio')
    makeLuaSprite('poxz')

	makeLuaSprite('pixelated')
    setSpriteShader('pixelated', 'pixel')
    makeLuaSprite('chrom')
    setSpriteShader('chrom', 'chromabber')
    makeLuaSprite('dist')
    setSpriteShader('dist', 'distort')
    runHaxeCode([[
        game.camGame.filters = [new ShaderFilter(game.getLuaObject('pixelated').shader), new ShaderFilter(game.getLuaObject('chrom').shader), new ShaderFilter(game.getLuaObject('dist').shader)];
        game.camHUD.filters = [new ShaderFilter(game.getLuaObject('pixelated').shader), new ShaderFilter(game.getLuaObject('dist').shader)];
		game.camOther.filters = [new ShaderFilter(game.getLuaObject('pixelated').shader)];
    ]])
end

local glitchtf = false
function onBeatHit()
    if curBeat == 216 then
        doTweenX('poxz', 'poxz', 0.07, 15)
        glitchtf = true
    end
    if curBeat == 248 then
        doShaderZoom = true
        glitchtf = false
        setShaderFloat('dist', 'amp', 0.0)
    end

    if curBeat == 696 then setShaderFloat('dist', 'amp', 0.0075) end
	if curBeat == 760 then setShaderFloat('dist', 'amp', 0.0185) end
    if curBeat == 848 then setProperty('poxz.x', 0.185) glitchtf = true doTweenX('poxz', 'poxz', 0.05, 2.58) end
    if curBeat == 856 then glitchtf = false end
end

function onUpdatePost()
	setProperty('grpNoteSplashes.visible', false)

    setShaderFloat('pixelated', 'iTime', os.clock())
    setShaderFloat('pixelated', 'pixelSize', 250)
    setShaderFloat('dist', 'iTime', os.clock())

    if istweenin then
        setShaderFloat('chrom', 'amount', getProperty('opipio.x')) end
    if glitchtf then
        setShaderFloat('dist', 'amp', getProperty('poxz.x')) end
end

function onEvent(n)
    if n == 'Add Camera Zoom' and doShaderZoom then
        istweenin = true
        cancelTween('bruhhhhh')
        setProperty('opipio.x', 0.65)
        doTweenX('bruhhhhh', 'opipio', 0, 1, 'cubeOut')
    end
end

function onTweenCompleted(t)
    if t == 'bruhhhhh' then istweenin = false end
end