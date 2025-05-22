function onCreatePost()
	makeLuaSprite('flashImage', -700, -700)
	makeGraphic('flashImage', 3000, 2500, 'FFFFFF')
	addLuaSprite('flashImage')
	setProperty('flashImage.alpha', 0)
	setObjectOrder('flashImage', getObjectOrder('boyfriendGroup') - 1)
end

function onEvent(n, val1, val2)
	if n == 'Flash' then
		splitted = stringSplit(val1:gsub(' ', ''), ',')
		config = {
			color = splitted[1] or 'FFFFFF',
			duration = splitted[2] or 1
		}
		if flashingLights then
			cancelTween('flashImage')
			cancelTween('boyfriendFlash')
			setProperty('flashImage.alpha', 1)
			setProperty('boyfriend.color', getColorFromHex('000000'))
			doTweenColor('boyfriendFlash', 'boyfriend', 'FFFFFF', config.duration)
			setProperty('flashImage.color', getColorFromHex(config.color))
			doTweenAlpha('flashImage', 'flashImage', 0, config.duration)
		end
	end
end