function onCreate()
	setProperty('skipCountdown', true)
	setProperty('camZoomingMult', 0)

	makeLuaSprite('bgzalgo', 'ZALGOBG', -900, -513)
	scaleObject('bgzalgo', 3.115, 3.115)
	setProperty('bgzalgo.antialiasing', false)
	addLuaSprite('bgzalgo')

	makeLuaSprite('bgknux', 'ZALGOBG', -100, 750)
	scaleObject('bgknux', 2.18, 2.18)
	setProperty('bgknux.antialiasing', false)
	addLuaSprite('bgknux')

	setProperty('dadGroup.visible', false)
end

function onBeatHit()
	if curBeat == 236 or curBeat == 406 or curBeat == 478 then
		playAnim('dad', 'intro', true)
		setProperty('dad.specialAnim', true)
		setProperty('dadGroup.visible', true)
	elseif curBeat == 309 or curBeat == 441 or curBeat == 543 then
		playAnim('dad', 'outro', true)
		setProperty('dad.specialAnim', true)
	end
end

function onUpdatePost()
	if getProperty('dad.animation.curAnim.name') == 'outro' and getProperty('dad.animation.curAnim.finished') then
		setProperty('dadGroup.visible', false)
	end
end