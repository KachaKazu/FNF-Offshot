camEventDone = false
realorfake = true

function onCreate()
	makeLuaSprite('sky', 'stages/phony/phonysky')
	setGraphicSize('sky', getProperty('sky.width') * 5)
	setScrollFactor('sky', 0.3, 0.3)
	setProperty('sky.antialiasing', false)
	addLuaSprite('sky', false)
	screenCenter('sky')
	setProperty('sky.x', getProperty('sky.x') + 50)
	
	makeLuaSprite('mount', 'stages/phony/phonymount')
	setGraphicSize('mount', getProperty('mount.width') * 5)
	setScrollFactor('mount', 0.6, 0.6)
	setProperty('mount.antialiasing', false)
	addLuaSprite('mount', false)
	screenCenter('mount')
	setProperty('mount.y', -800)
	
	makeLuaSprite('forest', 'stages/phony/phonyforest')
	setGraphicSize('forest', getProperty('forest.width') * 5)
	setScrollFactor('forest', 0.7, 0.7)
	setProperty('forest.antialiasing', false)
	addLuaSprite('forest', false)
	screenCenter('forest')
	setProperty('forest.y', getProperty('forest.y') + 100)

	createInstance('ebbg', 'flixel.addons.display.FlxBackdrop', {nil, 0x11})
	loadFrames('ebbg', 'stages/earthbound')
	addAnimationByPrefix('ebbg', 'idle', 'idle', 12, true)
	setProperty('ebbg.antialiasing', false)
	setProperty('ebbg.alpha', 0)
	setScrollFactor('ebbg', 0.7, 0.7)
	scaleObject('ebbg', 2, 2)
	setProperty('ebbg.velocity.x', -800)
	addInstance('ebbg')
	--setBlendMode('ebbg', 'add')

	makeLuaSprite('cliff', 'stages/phony/phonycliff')
	setGraphicSize('cliff', getProperty('cliff.width') * 5)
	setScrollFactor('cliff', 0.8, 0.8)
	setProperty('cliff.antialiasing', false)
	addLuaSprite('cliff', false)
	screenCenter('cliff')
	
	makeLuaSprite('ruins', 'stages/phony/phonyruins')
	setGraphicSize('ruins', getProperty('ruins.width') * 5)
	setScrollFactor('ruins', 0.9, 0.9)
	setProperty('ruins.antialiasing', false)
	addLuaSprite('ruins', false)
	screenCenter('ruins')
	setProperty('cliff.x', getProperty('cliff.x') - 100)
	
	makeLuaSprite('ground', 'stages/phony/phonyground')
	setGraphicSize('ground', getProperty('ground.width') * 5)
	setScrollFactor('ground', 1, 1)
	setProperty('ground.antialiasing', false)
	addLuaSprite('ground', false)
	screenCenter('ground')

	makeLuaSprite('blackblend')
	makeGraphic('blackblend', 3000, 3000, '020244')
	screenCenter('blackblend')
	setProperty('blackblend.alpha', 0.4)
	setBlendMode('blackblend', 'multiply')
end

function onBeatHit()
	if curBeat == 248 then
		addLuaSprite('blackblend', true)
		setObjectOrder('blackblend', getObjectOrder('boyfriendGroup') + 1)
	end

	if curBeat == 696 then setProperty('ebbg.alpha', 1) end
	if curBeat == 760 then setProperty('ebbg.velocity.x', -1350) end

	setProperty('ebbg.x', getProperty('ebbg.x') - 64)
	setProperty('ebbg.y', getProperty('ebbg.y') - 64)
end

function onCreatePost()
	runTimer('subterfuge', 1)
end

function onUpdate()
	setProperty('isCameraOnForcedPos', true)

	if realorfake == false then
		cancelTween('camTweenXStart')
		cancelTween('camTweenYStart')
	end
	if realorfake == true then
		doTweenX('camTweenXStart', 'camFollow', 300, 0.01, 'cubeInOut')
		doTweenY('camTweenYStart', 'camFollow', -400, 0.01, 'cubeInOut')
	end

	if camEventDone == true then
		cancelTween('camTweeeenX')
		cancelTween('camTweeeenY')
		setProperty('isCameraOnForcedPos', false)
	
		if mustHitSection then
			triggerEvent('Camera Follow Pos', '660', '700')
		else
			if curStep > 1024 then
				triggerEvent('Camera Follow Pos', '165', '500')
			else
				triggerEvent('Camera Follow Pos', '165', '700')
			end
		end
	end
end

function onTimerCompleted(tag)
	if tag == 'subterfuge' then
		realorfake = false
		cancelTween('camTweenXStart')
		cancelTween('camTweenYStart')
		
		doTweenX('camTweeeenX', 'camFollow', 300, 2, 'cubeInOut')
		doTweenY('camTweeeenY', 'camFollow', 700, 2, 'cubeInOut')
	end
end

function onTweenCompleted(tag)
	if tag == 'camTweeeenX' then
		camEventDone = true
	end
end
