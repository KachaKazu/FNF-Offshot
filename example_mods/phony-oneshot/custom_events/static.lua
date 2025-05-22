local existingSound = false
function onCreatePost()
    makeAnimatedLuaSprite('dastatic', 'static')
    addAnimationByPrefix('dastatic', 'idle', 'idle', 24, true)
    setProperty('dastatic.color', getColorFromHex('FF0000'))
    setProperty('dastatic.alpha', 0.2)
    setGraphicSize('dastatic', screenWidth, screenHeight)
    setProperty('dastatic.antialiasing', false)
    setObjectCamera('dastatic', 'other')
    addLuaSprite('dastatic', true)
    setProperty('dastatic.visible', false)
end

function onEvent(n)
    if n == 'static' then
        cancelTimer('byeee')
        runTimer('byeee', 0.2)
        if not existingSound then
            existingSound = true
            setProperty('dastatic.visible', true)
            playSound('staticSound', 0.075, 'staticc')
        end
    end
end

function onTimerCompleted(t)
    if t == 'byeee' then
        existingSound = false
        setProperty('dastatic.visible', false)
        stopSound('staticc')
    end
end