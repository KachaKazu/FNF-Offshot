local curSelect = 1
local option = {
	[1] = function()
			removeInstance('checker1')
			removeInstance('checker2')
			stopSound('pauseMusic')

			closeCustomSubstate()
		end,
	[2] = restartSong,
	[3] = function()
			runHaxeCode([[
				import backend.MusicBeatState;
				import options.OptionsState;
				var pauseMusic = new flixel.sound.FlxSound();
				try {
					var pauseSong:String = getPauseSong();
					if(pauseSong != null) pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
				}
				catch(e:Dynamic) {}
				pauseMusic.volume = ]]..getSoundVolume('pauseMusic')..[[;
				pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
				OptionsState.onPlayState = true;
				MusicBeatState.switchState(new options.OptionsState());
				if(ClientPrefs.data.pauseMusic != 'None')
				{
					FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)),pauseMusic.volume);
					FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
					FlxG.sound.music.time = ]]..getSoundTime('pauseMusic')..[[;
					FlxG.sound.music.pitch = 0.7;
					modchartSounds["sound"].stop();
				}
			]])
		end,
	[4] = exitSong
}

local render = 'fakerRender'
local pauseSong = callMethodFromClass('backend.Paths', 'formatToSongPath', {getPropertyFromClass('backend.ClientPrefs', 'data.pauseMusic')})

function onCreate()
	--precaching
	precacheMusic(pauseSong)

	precacheImage('pause/fakerRender')
	precacheImage('pause/fakerRender-alt')
	precacheImage('pause/exeRender')
	precacheImage('pause/select')
	precacheImage('pause/resume')
	precacheImage('pause/restart')
	precacheImage('pause/options')
	precacheImage('pause/exit')
end

function onBeatHit()
	if curBeat == 144 then
		render = 'fakerRender-alt'
	elseif curBeat == 248 then
		render = 'exeRender'
	end
end

function onPause()
	openCustomSubstate('pause', true)
	return Function_Stop
end

function onCustomSubstateCreate(n)
	if n == 'pause' then
		makeLuaSprite('blackpause')
		makeGraphic('blackpause', screenWidth, screenHeight, '000000')
		setProperty('blackpause.alpha', 0)
		doTweenAlpha('blackpause', 'blackpause', 0.5, 0.6)
		insertToCustomSubstate('blackpause')

		createInstance('checker1', 'flixel.addons.display.FlxBackdrop', {nil, 0x11, 80, 80})
		makeGraphic('checker1', 80, 80, 'FFFFFF')
		setProperty('checker1.alpha', 0)
		doTweenAlpha('checker1', 'checker1', 0.06, 0.6)
		setProperty('checker1.velocity.x', 20)
		setProperty('checker1.velocity.y', 20)
		insertToCustomSubstate('checker1')

		createInstance('checker2', 'flixel.addons.display.FlxBackdrop', {nil, 0x11, 80, 80})
		makeGraphic('checker2', 80, 80, 'FFFFFF')
		setProperty('checker2.alpha', 0)
		doTweenAlpha('checker2', 'checker2', 0.06, 0.6)
		setProperty('checker2.velocity.x', 20)
		setProperty('checker2.velocity.y', 20)
		setProperty('checker2.x', 80)
		setProperty('checker2.y', 80)
		insertToCustomSubstate('checker2')

		makeLuaSprite('render', 'pause/'..render, screenWidth)
		scaleObject('render', (render:match('exe') and 1.55 or 2), (render:match('exe') and 1.55 or 2))
		setProperty('render.antialiasing', false)
		setProperty('render.y', screenHeight - getProperty('render.height') + (render:match('exe') and 50 or 20))
		doTweenX('render', 'render', screenWidth - getProperty('render.width') - 20, 0.6, 'cubeOut')
		insertToCustomSubstate('render')

		makeLuaSprite('optionSel', 'pause/select')
		scaleObject('optionSel', 3, 3)
		setProperty('optionSel.antialiasing', false)
		setProperty('optionSel.x', -getProperty('optionSel.width'))
		doTweenX('fucklmao', 'optionSel', 5, 0.6, 'expoOut')
		insertToCustomSubstate('optionSel')
		makeLuaSprite('ypossel', nil, 0, 140)
		for i = 1,4 do
			local button = {'resume', 'restart', 'options', 'exit'}
			makeLuaSprite('option'..i, 'pause/'..button[i], 70)
			scaleObject('option'..i, 3, 3)
			setProperty('option'..i..'.antialiasing', false)
			insertToCustomSubstate('option'..i)

			makeLuaSprite('ypos'..i, nil, 0, 150 + 100 * (i - 1))
		end

		playSound('../../assets/shared/music/'..pauseSong, 0, 'pauseMusic', true)
		setSoundPitch('pauseMusic', 0.6)
		setSoundTime('pauseMusic', getRandomFloat(0, getProperty('modchartSounds.pauseMusic.length', true) / 2))
		changeSel()
	end
end

local thing = 0
function onCustomSubstateUpdate(n, e)
	if n == 'pause' then
		if keyboardJustPressed('C') then
			closeCustomSubstate()
		elseif keyboardJustPressed('V') then
			restartSong()
		elseif keyboardJustPressed('B') then
			exitSong()
		end

		if getSoundVolume('pauseMusic') < 0.5 then
			setSoundVolume('pauseMusic', getSoundVolume('pauseMusic') + 0.025 * e)
		end

		if keyJustPressed('up') then
			changeSel(-1)
		elseif keyJustPressed('down') then
			changeSel(1)
		end

		if keyJustPressed('accept') then
			option[curSelect]()
		end

		thing = thing + e
		for i = 1,4 do
			setProperty('option'..i..'.y', getProperty('ypos'..i..'.y') + math.sin(thing - (0.2 * i)) * 2)
		end
		setProperty('optionSel.y', getProperty('ypossel.y') + math.sin(thing) * 2)
	end
end

function changeSel(change)
	change = change or 0
	curSelect = curSelect + change
	if curSelect > 4 then curSelect = 1
	elseif curSelect < 1 then curSelect = 4 end

	playSound('scrollMenu', 0.6)

	for i = 1,4 do
		cancelTween('move'..i)
		doTweenY('move'..i, 'ypos'..i, 150 + 100 * (i - 1) - (i == curSelect and 5 or 0), 0.6, 'expoOut')

		cancelTween('movesel')
		doTweenY('movesel', 'ypossel', (140 + 100 * (curSelect - 1)), 0.6, 'expoOut')
	end
end

function removeInstance(tag)
	callMethod('variables.remove', {tag})
    callMethod(tag..'.kill', {''})
    callMethod('remove', {instanceArg(tag)})
    callMethod(tag..'.destroy', {''})
end