local saveWindowX = 0
local saveWindowX = 0
local erm = false
local startWindowShake = false
local dafunny = false

--ぶっ壊して殺してやるよ！

function onCreatePost()
	makeLuaSprite('thing')

	createInstance('exe', 'objects.Character', {getProperty('DAD_X') + 50, getProperty('DAD_Y') + 200, 'exephony', false})
	addInstance('exe')
	setProperty('exe.alpha', 0)

	makeLuaSprite('lookinaahstupid', 'characters/phonylook2', getProperty('DAD_X') - 282, getProperty('DAD_Y') + 314)
	addLuaSprite('lookinaahstupid', true)
	scaleObject('lookinaahstupid', 5, 5)
	setProperty('lookinaahstupid.antialiasing', false)
	setProperty('lookinaahstupid.visible', false)

	makeLuaSprite('blackscree')
	makeGraphic('blackscree', 3000, 3000, '000000')
	screenCenter('blackscree')
	setProperty('blackscree.alpha', 0)
	addLuaSprite('blackscree', true)

	makeLuaText('japanese', '殺してやる…', screenWidth)
	setTextFont('japanese', 'JAPANESE.ttf')
	setTextColor('japanese', 'FF0000')
	setTextBorder('japanese', 0)
	setTextSize('japanese', 100)
	screenCenter('japanese')
	setProperty('japanese.alpha', 0)
	addLuaText('japanese')
	setBlendMode('japanese', 'ADD')
end

local asfaf = false
function onBeatHit()
	if curBeat == 138 then
		setProperty('lookinaahstupid.visible', true)
		setProperty('dad.visible', false)
	elseif curBeat == 139 then
		loadGraphic('lookinaahstupid', 'characters/phonylook')
	elseif curBeat == 140 then
		setProperty('blackscree.alpha', 1)
	elseif curBeat == 141 then
		setProperty('lookinaahstupid.visible', false)
		setProperty('dad.visible', true)
	elseif curBeat == 142 then
		doTweenAlpha('blackscree', 'blackscree', 0, 0.9, 'cubeIn')
	end

	if curBeat == 144 then
		doTweenAlpha('exe', 'exe', 0.1, 1)
	end
	if curBeat == 148 then asfaf = true end
	if curBeat == 216 then
		saveWindowX = getPropertyFromClass('flixel.FlxG', 'stage.window.x')
		saveWindowY = getPropertyFromClass('flixel.FlxG', 'stage.window.y')
		startWindowShake = true

		asfaf = false
		doTweenAlpha('exe', 'exe', 1, 10)
		doTweenAlpha('dadad', 'dad', 0, 10)
	end
	if curBeat == 248 then
		doShaderZoom = true
		startWindowShake = false
		setProperty('thing.x', getPropertyFromClass('flixel.FlxG', 'stage.window.x'))
		setProperty('thing.y', getPropertyFromClass('flixel.FlxG', 'stage.window.y'))
		erm = true
		doTweenX('mythingX', 'thing', saveWindowX, 1.5, 'cubeInOut')
		doTweenY('mythingY', 'thing', saveWindowY, 1.5, 'cubeInOut')
	end
	if curBeat == 232 then
		doTweenAlpha('blackscree', 'blackscree', 1, 3)
		doTweenAlpha('lmao', 'camHUD', 0, 3)
	end
	if curBeat == 260 then
		doTweenAlpha('blackscree', 'blackscree', 0, 1.6)
	end
	if curBeat == 276 then
		doTweenAlpha('lmao', 'camHUD', 1, 1.6)
	end

	if curBeat == 616 or curBeat == 648 then howMuch = 3
	elseif curBeat == 620 or curBeat == 652 then howMuch = 4 end

	if curBeat == 856 then setProperty('blackscree.alpha', 1) setProperty('camHUD.alpha', 0) end
end

local howMuch = 4
function onStepHit()

	dafunny = curBeat >= 589 and curBeat < 652
	if dafunny and curStep % howMuch == 0 then
		cancelTween('CG') cancelTween('CH')

		setProperty('camGame.angle', 2 * (curBeat % 2 == 0 and -1 or 1))
		setProperty('camHUD.angle', 1 * (curBeat % 2 == 0 and -1 or 1))

		doTweenAngle('CG', 'camGame', 0, 1, 'cubeOut')
		doTweenAngle('CH', 'camHUD', 0, 1, 'cubeOut')
	end

	if curStep == 2660 then
		setProperty('japanese.alpha', 1)
	elseif curStep == 2675 then
		doTweenAlpha('japanese', 'japanese', 0, 2)
	end

	if curStep == 2695 then
		setTextString('japanese', 'ぶっ壊して殺してやるよ！')
		cancelTween('japanese')
		setProperty('japanese.alpha', 1)
	elseif curStep == 2743 then
		doTweenAlpha('japanese', 'japanese', 0, 2)
	end

function onTweenCompleted(t)
	if t == 'mythingX' then erm = false end
	if t == 'dadad' then triggerEvent('Change Character', 'dad', 'exephony') setProperty('dad.alpha', 1) setProperty('exe.visible', false) end
end

local thing = 0
function onUpdatePost(e)
	if startWindowShake then
		thing = thing + (e * 0.5)
		setPropertyFromClass('flixel.FlxG', 'stage.window.x', saveWindowX + getRandomFloat(-1, 1) * (1 + thing))
		setPropertyFromClass('flixel.FlxG', 'stage.window.y', saveWindowY + getRandomFloat(-1, 1) * (1 + thing))
	end
	if erm then
		setPropertyFromClass('flixel.FlxG', 'stage.window.x', getProperty('thing.x'))
		setPropertyFromClass('flixel.FlxG', 'stage.window.y', getProperty('thing.y'))
	end
	if asfaf then setProperty('exe.alpha', ((math.sin(thing) + 1) / 2) / 10) end
end

function opponentNoteHit(id, nd)
	note = {'LEFT', 'DOWN', 'UP', 'RIGHT'}
	playAnim('exe', 'sing'..note[nd + 1], true)
	setProperty('exe.holdTimer', 0)
end