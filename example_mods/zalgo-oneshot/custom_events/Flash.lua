function onCreatePost()
	makeLuaSprite('flashImage', nil, -1000, -1000)
	makeGraphic('flashImage', 3500, 3000, 'FFFFFF')
	addLuaSprite('flashImage', true)
	setProperty('flashImage.alpha', 0)
	setObjectOrder('flashImage', getObjectOrder('boyfriendGroup') + 10)
end

function onEvent(n, val1, val2)
	if n == 'Flash' then
		splitted = stringSplit(val1:gsub(' ', ''), ',')
		config = {
			color = 'FFFFFF',
			duration = splitted[2] or 1
		}
		if flashingLights then
			cancelTween('flashImage')
			setProperty('flashImage.alpha', 1)
			setProperty('flashImage.color', getColorFromHex(config.color))
			doTweenAlpha('flashImage', 'flashImage', 0, config.duration)
		end
	end
end