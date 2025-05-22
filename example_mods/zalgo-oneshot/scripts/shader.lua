function onCreatePost()
	makeLuaSprite('bruh',nil,1)
	setSpriteShader('bruh', 'brightness')

	setProperty('camZooming', true)
	setProperty('camZoomingMult', 0)
end

function onUpdatePost()
	setShaderFloat('bruh', 'brightness', (getProperty('bruh.x') - 1) / 2)
	setShaderFloat('bruh', 'saturation', getProperty('bruh.x'))
	setShaderFloat('bruh', 'contrast', getProperty('bruh.x'))
end

function onEvent(n)
	if n == 'Add Camera Zoom' then
		cancelTween('bruh')
		setProperty('bruh.x', 2)
		doTweenX('bruh', 'bruh', 1, crochet / 250, 'cubeOut')
	end
end