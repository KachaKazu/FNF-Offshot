local scaleOffset = 0.8

function onCreate()
	setProperty('skipCountdown', true)
end

function onCreatePost()
	for i = 0,3 do
		setProperty('strumLineNotes.members['..i..'].visible', false)

		setProperty('strumLineNotes.members['..(i + 4)..'].texture', 'newgreennotes')
		scaleObject('strumLineNotes.members['..(i + 4)..']', getProperty('strumLineNotes.members['..(i + 4)..'].scale.x') * 0.607 * scaleOffset, getProperty('strumLineNotes.members['..(i + 4)..'].scale.y') * 0.607 * scaleOffset)
		setProperty('strumLineNotes.members['..(i + 4)..'].x', 30 + 90 * i)
		setProperty('strumLineNotes.members['..(i + 4)..'].y', getProperty('strumLineNotes.members['..(i + 4)..'].y') + 40 * (downscroll and 1 or -1))
	end
	for i = 0,getProperty('unspawnNotes.length')-1 do
		setPropertyFromGroup('unspawnNotes', i, 'texture', 'newgreennotes')
		if not getProperty('unspawnNotes['..i..'].isSustainNote') then
			scaleObject('unspawnNotes['..i..']', getProperty('unspawnNotes['..i..'].scale.x') * 0.607 * scaleOffset, getProperty('unspawnNotes['..i..'].scale.y') * 0.607 * scaleOffset)
		else
			scaleObject('unspawnNotes['..i..']', getProperty('unspawnNotes['..i..'].scale.x') * 0.607 * scaleOffset, getProperty('unspawnNotes['..i..'].scale.y'))
			setProperty('unspawnNotes['..i..'].offset.x', -15)
		end
	end

	setProperty('timeBar.visible', false)
	setProperty('timeTxt.visible', false)
	setProperty('scoreTxt.visible', false)
	setProperty('healthBar.visible', false)
	setProperty('iconP1.visible', false)
	setProperty('iconP2.visible', false)
	setProperty('showComboNum', false)
	setProperty('showRating', false)

	makeAnimatedLuaSprite('warning', 'flashingwarn')
	addAnimationByPrefix('warning', 'idle', 'flashingwarn', 2, true)
	setProperty('warning.alpha', 0)
	setProperty('warning.antialiasing', false)
	setObjectCamera('warning', 'hud')
	scaleObject('warning', 3, 3)
	screenCenter('warning')
	setProperty('warning.y', getProperty('warning.y') - 50)
	addLuaSprite('warning', true)

	makeLuaText('scorenew', '', screenWidth - 20, 10, (downscroll and 30 or 550))
	setObjectCamera('scorenew', 'hud')
	setTextSize('scorenew', 26)
	setProperty('scorenew._defaultFormat.leading', -26)
	setTextFont('scorenew', 'djb_emphatic.ttf')
	setTextAlignment('scorenew', 'Left')
	setObjectOrder('scorenew', 0)
	addLuaText('scorenew')
end

function onSongStart()
	doTweenAlpha('warning', 'warning', 1, 1)
	doTweenY('warningY', 'warning', getProperty('warning.y') + 50, 1, 'cubeOut')
	runTimer('byebye', 3)
end

function onTimerCompleted(t)
	if t == 'byebye' then
		doTweenAlpha('warning', 'warning', 0, 1)
		doTweenY('warningY', 'warning', getProperty('warning.y') + 50, 1, 'cubeIn')
	end
end

local canBeatZoom = true
local zoomEveryBeats = 4
function onBeatHit()
	if canBeatZoom and curBeat % zoomEveryBeats == 0 then
		setProperty('camGame.zoom', getProperty('camGame.zoom') + (0.0075 * getProperty('camZoomingMult')))
		setProperty('camHUD.zoom', getProperty('camHUD.zoom') + (0.015 * getProperty('camZoomingMult')))
	end
end

function noteMiss()
	playAnim('boyfriend', 'idle', true)
end

function onUpdatePost(e)
	setProperty('camGame.zoom', lerp(getProperty('defaultCamZoom'), getProperty('camGame.zoom'), range(1 - (e * 1.5625 * getProperty('camZoomingDecay') * getProperty('playbackRate')), 0, 1)))
	setProperty('camHUD.zoom', lerp(1, getProperty('camHUD.zoom'), range(1 - (e * 1.5625 * getProperty('camZoomingDecay') * getProperty('playbackRate')), 0, 1)))

	setTextString('scorenew', 'SCR: '..score..'\nX: '..misses..'\nRT: '..decimal(rating * 100, 2)..'%\nTP: '..string.format("%d:%02d", math.floor(((getSongPosition() / 1000) % 3600) / 60), (getSongPosition() / 1000) % 60)..(getProperty('cpuControlled') and '\nBOTPLAY' or ''))
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function range(number, min, max)
	return math.max(min, math.min(max, number))
end

function decimal(number, dec)
	dec = dec or 1
	return math.floor(number * (10 ^ dec) + 0.5) / (10 ^ dec)
end