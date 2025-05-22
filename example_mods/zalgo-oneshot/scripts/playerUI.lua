function onCreate()
	addHaxeLibrary('Application', 'lime.app')
	addHaxeLibrary('Image','lime.graphics')
	runHaxeCode([[
		var Icon:Image=Image.fromFile(Paths.modFolders('images/gameIcon.png'));
		Application.current.window.setIcon(Icon);
	]])
end

local scaleOffset = 0.8
function onCreatePost()
	setProperty('healthBar.visible', false)
	setProperty('timeTxt.visible', false)
	setProperty('timeBar.visible', false)
	setProperty('iconP1.visible', false)
	setProperty('iconP2.visible', false)
	setProperty('scoreTxt.visible', false)
	setProperty('showRating', false)
	setProperty('showComboNum', false)
	setProperty('grpNoteSplashes.visible', false)

	makeAnimatedLuaSprite('border', 'border')
	addAnimationByPrefix('border', 'idle', 'border border', 6, true)
	scaleObject('border', 2, 2)
	setProperty('border.antialiasing', false)
	screenCenter('border')
	setObjectCamera('border', 'hud')
	addLuaSprite('border')

	makeAnimatedLuaSprite('missesTxtshadow', 'missestxt', 0, downscroll and 53 or (screenHeight - 103))
	addAnimationByPrefix('missesTxtshadow', 'idle', 'idle', 3, true)
	screenCenter('missesTxtshadow', 'x')
	setProperty('missesTxtshadow.color', getColorFromHex('000000'))
	setProperty('missesTxtshadow.x', getProperty('missesTxtshadow.x') - 47)
	setObjectCamera('missesTxtshadow', 'hud')
	addLuaSprite('missesTxtshadow')

	makeAnimatedLuaSprite('missesNumshadow', 'missesnums', getProperty('missesTxtshadow.x') + getProperty('missesTxtshadow.width'), downscroll and 53 or (screenHeight - 103))
	addAnimationByPrefix('missesNumshadow', '0', 'zero', 3, true)
	addAnimationByPrefix('missesNumshadow', '1', 'one', 3, true)
	addAnimationByPrefix('missesNumshadow', '2', 'two', 3, true)
	addAnimationByPrefix('missesNumshadow', '3', 'three', 3, true)
	setProperty('missesNumshadow.color', getColorFromHex('000000'))
	setObjectCamera('missesNumshadow', 'hud')
	addLuaSprite('missesNumshadow')

	makeAnimatedLuaSprite('missesTxt', 'missestxt', 0, downscroll and 50 or (screenHeight - 100))
	addAnimationByPrefix('missesTxt', 'idle', 'idle', 3, true)
	screenCenter('missesTxt', 'x')
	setProperty('missesTxt.x', getProperty('missesTxt.x') - 50)
	setObjectCamera('missesTxt', 'hud')
	addLuaSprite('missesTxt')

	makeAnimatedLuaSprite('missesNum', 'missesnums', getProperty('missesTxt.x') + getProperty('missesTxt.width'), downscroll and 50 or (screenHeight - 100))
	addAnimationByPrefix('missesNum', '0', 'zero', 3, true)
	addAnimationByPrefix('missesNum', '1', 'one', 3, true)
	addAnimationByPrefix('missesNum', '2', 'two', 3, true)
	addAnimationByPrefix('missesNum', '3', 'three', 3, true)
	setObjectCamera('missesNum', 'hud')
	addLuaSprite('missesNum')

	for i = 0,3 do
		setPropertyFromGroup('opponentStrums', i, 'x', -1000)
		
		setSpriteShader('strumLineNotes.members['..(i+4)..']', 'distort')
		setShaderFloat('strumLineNotes.members['..(i+4)..']', 'amp', '0.05')
	end

	for i = 0,7 do
		setPropertyFromGroup('strumLineNotes', i, 'texture', 'newnotes')
		scaleObject('strumLineNotes.members['..i..']', getProperty('strumLineNotes.members['..i..'].scale.x') * 0.607 * scaleOffset, getProperty('strumLineNotes.members['..i..'].scale.y') * 0.607 * scaleOffset)
		if i > 3 then setPropertyFromGroup('strumLineNotes', i, 'x', -134 + 10 + 90 * i) end
	end
	for i = 0,getProperty('unspawnNotes.length')-1 do
		setPropertyFromGroup('unspawnNotes', i, 'texture', 'newnotes')
		if not getProperty('unspawnNotes['..i..'].isSustainNote') then
			scaleObject('unspawnNotes['..i..']', getProperty('unspawnNotes['..i..'].scale.x') * 0.607 * scaleOffset, getProperty('unspawnNotes['..i..'].scale.y') * 0.607 * scaleOffset)
		else
			scaleObject('unspawnNotes['..i..']', getProperty('unspawnNotes['..i..'].scale.x') * 0.607 * scaleOffset, getProperty('unspawnNotes['..i..'].scale.y'))
			setProperty('unspawnNotes['..i..'].offset.x', -15)
		end
	end
end

function onUpdatePost(e)
	for i = 4,7 do
		setShaderFloat('strumLineNotes.members['..i..']', 'iTime', decimal(os.clock(), 1)+ i)
	end
end

local misss = 3
function onUpdateScore(miss)
	if miss then
		misss = misss - 1

		if misss < 0 then
			setHealth(-2)
		end

		playAnim('missesNumshadow', misss, true)
		playAnim('missesNum', misss, true)
	end
end

function decimal(number, dec)
	return math.floor(number * (10 ^ dec) + 0.5) / (10 ^ dec)
end