function onCreatePost()
    makeLuaSprite('dabg', 'endbg', -450, 4)
    scaleObject('dabg', 4, 4)
    setProperty('dabg.antialiasing', false)
    addLuaSprite('dabg')

    setProperty('dad.visible', false)
end