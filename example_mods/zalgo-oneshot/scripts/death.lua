local died = false
function onGameOver()
	died = true
	return Function_Stop
end

local thing = 0
function onUpdatePost(e)
	if died then
		openCustomSubstate('die', true)
	end
end

function onCustomSubstateCreate(n)
	if n == 'die' then
		makeLuaSprite('bruh')
		makeGraphic('bruh', screenWidth, screenHeight, '000000')
		addLuaSprite('bruh')
		setObjectCamera('bruh', 'other')

		makeLuaSprite('death', 'death')
		scaleObject('death', 2, 2)
		setProperty('death.alpha', 0)
		setProperty('death.antialiasing', false)
		screenCenter('death')
		addLuaSprite('death')
		setObjectCamera('death', 'other')

		playSound('wind', 1, 'waa', true)
		setSoundPitch('waa', 0.5)
	end
end

function onCustomSubstateUpdate(n, e)
	if n == 'die' then
		thing = thing + e
		if thing >= 5 then
			exitSong()
		end
		if getProperty('death.alpha') <= 1 then
			setProperty('death.alpha', getProperty('death.alpha') + 0.001)
			setProperty('death.x', 318 + math.sin(thing * 500) / 2)
		end
	end
end