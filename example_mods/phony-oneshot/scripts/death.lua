local poop = 0
function onGameOverStart()
	setProperty('boyfriend.visible', false)
	makeLuaSprite('dead', 'bfphonydead', getProperty('boyfriend.x'),  getProperty('boyfriend.y'))
	scaleObject('dead', 2, 2)
	setObjectCamera('dead', 'hud')
	setProperty('dead.antialiasing', false)
	screenCenter('dead')
	addLuaSprite('dead')


	makeLuaSprite('gameoverghost', 'gameover')
	setObjectCamera('gameoverghost', 'hud')
	scaleObject('gameoverghost', 5, 5)
	setProperty('gameoverghost.alpha', 0.3)
	setProperty('gameoverghost.antialiasing', false)
	screenCenter('gameoverghost')
	setProperty('gameoverghost.y', getProperty('gameoverghost.y') + 1000)
	addLuaSprite('gameoverghost')

	makeLuaSprite('gameover', 'gameover')
	setObjectCamera('gameover', 'hud')
	scaleObject('gameover', 5, 5)
	setProperty('gameover.antialiasing', false)
	screenCenter('gameover')
	poop = getProperty('gameover.x')
	setProperty('gameover.y', getProperty('gameover.y') + 1000)
	addLuaSprite('gameover')

	runTimer('bruh', 2.3)
end

function onTimerCompleted(t)
	if t == 'bruh' then
		doTweenY('gameover', 'gameover', getProperty('gameover.y') - 1200, 1, 'cubeOut')
		doTweenY('gameoverghost', 'gameoverghost', getProperty('gameoverghost.y') - 1200, 1.075, 'cubeOut')
	end
end

local thing = 0 
function onUpdate(e)
	if inGameOver then
		thing = thing + e
		setProperty('gameover.x', poop + math.sin(thing) * 2)
		setProperty('gameover.angle', math.sin(thing) * 2)

		setProperty('gameoverghost.x', poop + math.sin(thing - 1) * 2)
		setProperty('gameoverghost.angle', math.sin(thing - 1) * 2)
	end
end

function onGameOverConfirm()
	cancelTween('gameover')
	cancelTween('gameoverghost')
	doTweenY('gameovery', 'gameover.scale', 0, 2, 'backIn')
	doTweenX('gameoverx', 'gameover.scale', 0, 2, 'backIn')
	doTweenY('gameovergy', 'gameoverghost.scale', 0, 2.05, 'backIn')
	doTweenX('gameovergx', 'gameoverghost.scale', 0, 2.05, 'backIn')
	doTweenAlpha('dead', 'dead', 0, 2)
end