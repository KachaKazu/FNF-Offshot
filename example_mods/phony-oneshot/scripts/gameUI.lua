noteHit = 0
ratingRank = 'S++'

function onCreate()
	makeLuaText('text_missesLabel', 'X:', 1000, 16, 602)
	setTextSize('text_missesLabel', 26)
    setTextFont('text_missesLabel', 'djb_emphatic.ttf')
    setTextAlignment('text_missesLabel', 'left')
	setTextBorder('text_missesLabel', 3, '000000', 'outline')
	setObjectCamera('text_missesLabel', 'hud')
	addLuaText('text_missesLabel', true)
	
	makeLuaText('text_pointsLabel', 'pts:', 1000, 16, 630)
	setTextSize('text_pointsLabel', 26)
    setTextFont('text_pointsLabel', 'djb_emphatic.ttf')
    setTextAlignment('text_pointsLabel', 'left')
	setTextBorder('text_pointsLabel', 3, '000000', 'outline')
	setObjectCamera('text_pointsLabel', 'hud')
	addLuaText('text_pointsLabel', true)
	
	makeLuaText('text_accuracyLabel', 'acc:', 1000, 16, 660)
	setTextSize('text_accuracyLabel', 26)
    setTextFont('text_accuracyLabel', 'djb_emphatic.ttf')
    setTextAlignment('text_accuracyLabel', 'left')
	setTextBorder('text_accuracyLabel', 3, '000000', 'outline')
	setObjectCamera('text_accuracyLabel', 'hud')
	addLuaText('text_accuracyLabel', true)
	
	makeLuaText('text_missesValue', '0', 1000, 65, 602)
	setTextSize('text_missesValue', 26)
    setTextFont('text_missesValue', 'djb_emphatic.ttf')
    setTextAlignment('text_missesValue', 'left')
	setTextBorder('text_missesValue', 3, '000000', 'outline')
	setObjectCamera('text_missesValue', 'hud')
	addLuaText('text_missesValue', true)
	
	makeLuaText('text_pointsValue', '0', 1000, 94, 629)
	setTextSize('text_pointsValue', 26)
    setTextFont('text_pointsValue', 'djb_emphatic.ttf')
    setTextAlignment('text_pointsValue', 'left')
	setTextBorder('text_pointsValue', 3, '000000', 'outline')
	setObjectCamera('text_pointsValue', 'hud')
	addLuaText('text_pointsValue', true)
	
	makeLuaText('text_accuracyValue', '-% - [N/A', 1000, 94, 660)
	setTextSize('text_accuracyValue', 26)
    setTextFont('text_accuracyValue', 'djb_emphatic.ttf')
    setTextAlignment('text_accuracyValue', 'left')
	setTextBorder('text_accuracyValue', 3, '000000', 'outline')
	setObjectCamera('text_accuracyValue', 'hud')
	addLuaText('text_accuracyValue', true)
	
	makeLuaText('text_accuracyBlank', ']', 1000, 271, 660)
	setTextSize('text_accuracyBlank', 26)
    setTextFont('text_accuracyBlank', 'djb_emphatic.ttf')
    setTextAlignment('text_accuracyBlank', 'left')
	setTextBorder('text_accuracyBlank', 3, '000000', 'outline')
	setObjectCamera('text_accuracyBlank', 'hud')
	setObjectOrder('text_accuracyBlank', getObjectOrder('text_accuracyValue') - 1)
	addLuaText('text_accuracyBlank', true)

	makeLuaSprite('hbRight', 'healthbar_1')
	scaleObject('hbRight', 2, 2)
	setObjectCamera('hbRight', 'hud')
	addLuaSprite('hbRight')
	setProperty('hbRight.x', screenWidth - getProperty('hbRight.width') - 40)
	setProperty('hbRight.y', (downscroll and 20 or (screenHeight - getProperty('hbRight.height') - 20)))
	setProperty('hbRight.antialiasing', false)

	makeLuaSprite('hbLeft', 'healthbar_1')
	scaleObject('hbLeft', 2, 2)
	setObjectCamera('hbLeft', 'hud')
	addLuaSprite('hbLeft')
	setProperty('hbLeft.x', screenWidth - getProperty('hbLeft.width') - 40)
	setProperty('hbLeft.y', (downscroll and 20 or (screenHeight - getProperty('hbLeft.height') - 20)))
	setProperty('hbLeft.antialiasing', false)

	makeLuaSprite('hbInd', 'hbmarker')
	scaleObject('hbInd', 0.5, 0.5)
	setObjectCamera('hbInd', 'hud')
	addLuaSprite('hbInd')
	setProperty('hbInd.antialiasing', false)

	makeLuaSprite('coverhud', '', -500, -500)
	makeGraphic('coverhud', screenWidth * 2, screenHeight * 2, '000000')
	setObjectCamera('coverhud', 'hud')
	addLuaSprite('coverhud', true)
	
	setProperty('skipCountdown', true)
	setPropertyFromClass("openfl.Lib", "application.window.title", "PHONY")
end

function onSongStart()
	doTweenAlpha('coverhudGone', 'coverhud', 0, 1, 'cubeOut')
end

function onCreatePost()
	setProperty('iconP1.visible', false)
	setProperty('iconP2.visible', false)
	setProperty('healthBar.visible', false)
	setProperty('scoreTxt.visible', false)
	setProperty('timeTxt.visible', false)
	setProperty('timeBar.visible', false)
	setProperty('timeBarBG.visible', false)
	setProperty('showComboNum', false)
	setProperty('showRating', false)
	setProperty('showCombo', false)

	createInstance('iconBF', 'objects.HealthIcon', {getProperty('boyfriend.healthIcon'), true})
	setObjectCamera('iconBF', 'hud')
	addInstance('iconBF')
	if not downscroll then setProperty('iconBF.y', screenHeight - 120) end

	createInstance('iconFaker', 'objects.HealthIcon', {getProperty('dad.healthIcon')})
	setObjectCamera('iconFaker', 'hud')
	addInstance('iconFaker')
	if not downscroll then setProperty('iconFaker.y', screenHeight - 120) end
	
	if downscroll then
		setProperty('text_missesLabel.y', 5)
		setProperty('text_pointsLabel.y', 33)
		setProperty('text_accuracyLabel.y', 63)
		setProperty('text_missesValue.y', 5)
		setProperty('text_pointsValue.y', 32)
		setProperty('text_accuracyValue.y', 63)
		setProperty('text_accuracyBlank.y', 63)
	end

	if hideHud then
		setProperty('iconBF.visible', false)
		setProperty('iconFaker.visible', false)
		setProperty('hbLeft.visible', false)
		setProperty('hbRight.visible', false)
		setProperty('hbInd.visible', false)
		setProperty('text_missesLabel.visible', false)
		setProperty('text_pointsLabel.visible', false)
		setProperty('text_accuracyLabel.visible', false)
		setProperty('text_missesValue.visible', false)
		setProperty('text_pointsValue.visible', false)
		setProperty('text_accuracyValue.visible', false)
		setProperty('text_accuracyBlank.visible', false)
	end

	setProperty('hbLeft.alpha', healthBarAlpha)
	setProperty('hbRight.alpha', healthBarAlpha)
	setProperty('hbInd.alpha', healthBarAlpha)
	setProperty('iconBF.alpha', healthBarAlpha)
	setProperty('iconFaker.alpha', healthBarAlpha)

	setProperty('hbRight.color', getColorFromHex(getHealthColor('boyfriend')))
	setProperty('hbLeft.color', getColorFromHex(getHealthColor('dad')))
end

function onUpdate()
	setTextString('text_missesValue', getProperty('songMisses'))
	setTextString('text_pointsValue', getProperty('songScore'))
    if noteHit >= 1 then
        setTextString('text_accuracyValue', math.floor(getProperty('ratingPercent') * 10000) / 100 .. '% - ' .. ratingRank)
		setProperty('text_accuracyBlank.alpha', 0)
    end
	
	if rating >= 1 then
		ratingRank = 'S++'
	elseif rating > 0.95 and rating < 01 then
		ratingRank = 'S'
	elseif rating > 0.9 and rating < 0.95 then
		ratingRank = 'A'
	elseif rating > 0.85 and rating < 0.9 then
		ratingRank = 'B'
	elseif rating > 0.8 and rating < 0.85 then
		ratingRank = 'C'
	elseif rating > 0.7 and rating < 0.8 then
		ratingRank = 'D'
	elseif rating > 0.5 and rating < 0.7 then
		ratingRank = 'E'
	elseif rating < 0.5 then
		ratingRank = 'F'
	end
end

function onUpdatePost(e)
	setProperty('grpNoteSplashes.visible', false)
	setProperty('camZoomingMult', 0)

	setProperty('hbInd.x', lerp(getProperty('hbRight.x') + getProperty('hbRight.width') - 36, getProperty('hbRight.x') + 13, getHealth() / 2))
	setProperty('hbInd.y', getProperty('hbRight.y') + 24 - math.sin(lerp(0, math.pi, getHealth() / 2)) * 30)
	setProperty('hbLeft._frame.frame.width', 13 + lerp(189, 0, getHealth() / 2))

	setProperty('iconBF.scale.x', lerp(1, getProperty('iconBF.scale.x'), range(1 - (e * 6.25 * getProperty('playbackRate')), 0, 1)))
	setProperty('iconBF.scale.y', lerp(1, getProperty('iconBF.scale.y'), range(1 - (e * 6.25 * getProperty('playbackRate')), 0, 1)))
	setProperty('iconFaker.scale.x', lerp(1, getProperty('iconFaker.scale.x'), range(1 - (e * 6.25 * getProperty('playbackRate')), 0, 1)))
	setProperty('iconFaker.scale.y', lerp(1, getProperty('iconFaker.scale.y'), range(1 - (e * 6.25 * getProperty('playbackRate')), 0, 1)))

	setProperty('iconBF.x', getProperty('hbRight.x') + getProperty('hbRight.width') - (getProperty('iconBF.width') / 2))
	setProperty('iconFaker.x', getProperty('hbRight.x') - (getProperty('iconFaker.width') / 2))

	setProperty('iconBF.animation.curAnim.curFrame', (getHealth() < 0.4 and 1 or 0))
	setProperty('iconFaker.animation.curAnim.curFrame', (getHealth() > 1.6 and 1 or 0))
end

function onEvent(n, v1, v2)
	if n == 'Change Character' then
		callMethod('icon'..(v1:lower() == 'dad' and 'Faker' or 'BF')..'.changeIcon', {getProperty(v1:lower()..'.healthIcon'), (v1:lower() == 'bf')})
		setProperty('hb'..(v1:lower() == 'dad' and 'Left' or 'Right')..'.color', getColorFromHex(getHealthColor(v1:lower())))
	end
end

function onBeatHit()
	scaleObject('iconBF', 1.2, 1.2, false)
	scaleObject('iconFaker', 1.2, 1.2, false)
end

function goodNoteHit(i, d, n, s)
	if not botPlay then
		if noteHit == 0 then
			noteHit = 1
		end
	end
end

function noteMiss(i, d, n, s)
	if not botPlay then
		if noteHit == 0 then
			noteHit = 1
		end
	end
end

function getHealthColor(arg)
	return string.format("%02x%02x%02x", math.floor(getProperty(arg..'.healthColorArray[0]')), math.floor(getProperty(arg..'.healthColorArray[1]')), math.floor(getProperty(arg..'.healthColorArray[2]')))
end

function lerp(a, b, t)
	return a + t * (b - a)
end

function range(number, min, max)
	return math.max(min, math.min(max, number))
end