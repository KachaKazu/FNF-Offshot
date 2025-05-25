package substates;

import backend.WeekData;
import backend.Highscore;
import backend.Song;

import flixel.util.FlxStringUtil;
import flixel.FlxSprite;
import flixel.tweens.FlxTween;
import flixel.util.FlxTimer;
import flixel.input.keyboard.FlxKey;

import states.StoryMenuState;
import states.FreeplayState;
import options.OptionsState;

import flixel.addons.display.FlxBackdrop;

class PauseSubState extends MusicBeatSubstate
{
	var menuItems:Array<String> = [];
	var menuItemsOG:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];
	var curSelected:Int = 0;

	var pauseMusic:FlxSound;

	var missingTextBG:FlxSprite;
	var missingText:FlxText;

	var checkerBackdrop:FlxBackdrop;

	// Sprites para las opciones
	var resumeSprite:FlxSprite;
	var restartSprite:FlxSprite;
	var optionsSprite:FlxSprite;
	var exitSprite:FlxSprite;

	// Sprite para el indicador
	var arrowSprite:FlxSprite;

	// Sprites para las canciones
	var fakerSprite:FlxSprite;
	var burialSprite:FlxSprite;
	var dominionSprite:FlxSprite;

	// Nuevo sprite para "benjamin"
	var benjaminSprite:FlxSprite;

	// Variable para rastrear las teclas ingresadas
	var inputBuffer:String = "";
	var targetSequence:String = "benjamin";

	public static var songName:String = null;

	override function create()
	{
		menuItems = menuItemsOG;

		pauseMusic = new FlxSound();
		try
		{
			var pauseSong:String = getPauseSong();
			if(pauseSong != null) pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
		}
		catch(e:Dynamic) {}
		pauseMusic.volume = 0;
		pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));

		FlxG.sound.list.add(pauseMusic);

		// Crear el FlxBackdrop checker con transición
		checkerBackdrop = new FlxBackdrop();
		var checkerSize:Int = 64;
		checkerBackdrop.loadGraphic(FlxG.bitmap.create(checkerSize * 2, checkerSize * 2, FlxColor.TRANSPARENT, true, "checkerPattern"), false);
		checkerBackdrop.pixels.fillRect(new openfl.geom.Rectangle(0, 0, checkerSize, checkerSize), FlxColor.WHITE);
		checkerBackdrop.pixels.fillRect(new openfl.geom.Rectangle(checkerSize, checkerSize, checkerSize, checkerSize), FlxColor.WHITE);
		checkerBackdrop.alpha = 0;
		checkerBackdrop.velocity.set(15, 15);
		checkerBackdrop.scrollFactor.set();
		add(checkerBackdrop);

		FlxTween.tween(checkerBackdrop, {alpha: 0.5}, 0.6, {ease: FlxEase.quartInOut, startDelay: 0.1});

		var bg:FlxSprite = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		bg.scale.set(FlxG.width, FlxG.height);
		bg.updateHitbox();
		bg.alpha = 0;
		bg.scrollFactor.set();
		add(bg);

		FlxTween.tween(bg, {alpha: 0.6}, 0.4, {ease: FlxEase.quartInOut});

		missingTextBG = new FlxSprite().makeGraphic(1, 1, FlxColor.BLACK);
		missingTextBG.scale.set(FlxG.width, FlxG.height);
		missingTextBG.updateHitbox();
		missingTextBG.alpha = 0.6;
		missingTextBG.visible = false;
		add(missingTextBG);
		
		missingText = new FlxText(50, 0, FlxG.width - 100, '', 24);
		missingText.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
		missingText.scrollFactor.set();
		missingText.visible = false;
		add(missingText);

		// Determinar la canción actual
		var currentSong:String = (songName != null ? songName : PlayState.SONG.song).toLowerCase();

		// Cargar sprites de las opciones
		resumeSprite = new FlxSprite(150, 0);
		resumeSprite.loadGraphic(Paths.image('pause/resume'));
		if (resumeSprite.graphic == null) trace("Error: No se pudo cargar pause/resume.png");
		resumeSprite.scale.set(3.0, 3.0);
		resumeSprite.scrollFactor.set();
		resumeSprite.alpha = 0;
		add(resumeSprite);

		restartSprite = new FlxSprite(150, 0);
		restartSprite.loadGraphic(Paths.image('pause/restart'));
		if (restartSprite.graphic == null) trace("Error: No se pudo cargar pause/restart.png");
		restartSprite.scale.set(3.0, 3.0);
		restartSprite.scrollFactor.set();
		restartSprite.alpha = 0;
		add(restartSprite);

		optionsSprite = new FlxSprite(150, 0);
		optionsSprite.loadGraphic(Paths.image('pause/options'));
		if (optionsSprite.graphic == null) trace("Error: No se pudo cargar pause/options.png");
		optionsSprite.scale.set(3.0, 3.0);
		optionsSprite.scrollFactor.set();
		optionsSprite.alpha = 0;
		add(optionsSprite);

		exitSprite = new FlxSprite(150, 0);
		exitSprite.loadGraphic(Paths.image('pause/exit'));
		if (exitSprite.graphic == null) trace("Error: No se pudo cargar pause/exit.png");
		exitSprite.scale.set(3.0, 3.0);
		exitSprite.scrollFactor.set();
		exitSprite.alpha = 0;
		add(exitSprite);

		// Posición inicial compartida para los sprites
		var startX = FlxG.width;
		var startY = FlxG.height * 0.35; // Un poquito más abajo (35% de la pantalla)

		// Cargar sprite fakerRender para la canción "phony"
		if (currentSong == "phony") {
			fakerSprite = new FlxSprite(startX, startY);
			fakerSprite.loadGraphic(Paths.image('pause/spritescharacter/faker/fakerRender'));
			if (fakerSprite.graphic == null) trace("Error: No se pudo cargar pause/spritescharacter/faker/fakerRender.png");
			fakerSprite.scale.set(2.0, 2.0);
			fakerSprite.scrollFactor.set();
			fakerSprite.alpha = 0;
			add(fakerSprite);

			var finalX = FlxG.width - (0.8 * fakerSprite.width * fakerSprite.scale.x);
			var finalY = FlxG.height - (0.68 * fakerSprite.height * fakerSprite.scale.y);

			FlxTween.tween(fakerSprite, {x: finalX, y: finalY, alpha: 1}, 0.6, {ease: FlxEase.quartInOut, startDelay: 0.1});
		}

		// Cargar sprite placeholder para "burial"
		if (currentSong == "burial") {
			burialSprite = new FlxSprite(startX, startY);
			burialSprite.makeGraphic(100, 100, 0xFF000000); // Negro como base
			burialSprite.pixels.fillRect(new openfl.geom.Rectangle(0, 0, 50, 100), 0xFFFF0000); // Rojo a la izquierda
			burialSprite.scale.set(2.0, 2.0);
			burialSprite.scrollFactor.set();
			burialSprite.alpha = 0;
			add(burialSprite);

			var finalX = FlxG.width - (0.8 * burialSprite.width * burialSprite.scale.x);
			var finalY = FlxG.height - (0.68 * burialSprite.height * burialSprite.scale.y);

			FlxTween.tween(burialSprite, {x: finalX, y: finalY, alpha: 1}, 0.6, {ease: FlxEase.quartInOut, startDelay: 0.1});
		}

		// Cargar sprite placeholder para "dominion"
		if (currentSong == "dominion") {
			dominionSprite = new FlxSprite(startX, startY);
			dominionSprite.makeGraphic(100, 100, 0xFF000000); // Negro como base
			dominionSprite.pixels.fillRect(new openfl.geom.Rectangle(0, 0, 50, 100), 0xFFFF0000); // Rojo a la izquierda
			dominionSprite.scale.set(2.0, 2.0);
			dominionSprite.scrollFactor.set();
			dominionSprite.alpha = 0;
			add(dominionSprite);

			var finalX = FlxG.width - (0.8 * dominionSprite.width * dominionSprite.scale.x);
			var finalY = FlxG.height - (0.68 * dominionSprite.height * dominionSprite.scale.y);

			FlxTween.tween(dominionSprite, {x: finalX, y: finalY, alpha: 1}, 0.6, {ease: FlxEase.quartInOut, startDelay: 0.1});
		}

		// Cargar sprite benjamin (inicialmente oculto)
		benjaminSprite = new FlxSprite((FlxG.width - 200) / 2, (FlxG.height - 200) / 2); // Centrado
		benjaminSprite.loadGraphic(Paths.image('pause/benjamin'));
		if (benjaminSprite.graphic == null) trace("Error: No se pudo cargar pause/benjamin.png");
		benjaminSprite.scale.set(1.0, 1.0);
		benjaminSprite.scrollFactor.set();
		benjaminSprite.alpha = 0;
		add(benjaminSprite);

		// Crear el sprite indicador "arrow"
		arrowSprite = new FlxSprite(-100, 0);
		arrowSprite.loadGraphic(Paths.image('pause/arrow'));
		if (arrowSprite.graphic == null) trace("Error: No se pudo cargar pause/arrow.png");
		arrowSprite.scale.set(2.3, 2.3);
		arrowSprite.scrollFactor.set();
		arrowSprite.alpha = 0;
		add(arrowSprite);

		regenMenu();
		cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];

		// Transiciones para los sprites de las opciones
		FlxTween.tween(resumeSprite, {alpha: 1}, 0.6, {ease: FlxEase.quartInOut, startDelay: 0.1});
		FlxTween.tween(restartSprite, {alpha: 1}, 0.6, {ease: FlxEase.quartInOut, startDelay: 0.2});
		FlxTween.tween(optionsSprite, {alpha: 1}, 0.6, {ease: FlxEase.quartInOut, startDelay: 0.3});
		FlxTween.tween(exitSprite, {alpha: 1}, 0.6, {ease: FlxEase.quartInOut, startDelay: 0.4});

		// Transición para el arrow (entrada desde la izquierda)
		FlxTween.tween(arrowSprite, {x: 60, alpha: 1}, 0.6, {ease: FlxEase.quartInOut, startDelay: 0.5, onComplete: function(tween:FlxTween) {
			// Animación de subir y bajar (flotante) que se ejecuta continuamente
			FlxTween.tween(arrowSprite, {y: arrowSprite.y + 10}, 1.0, {type: FlxTween.PINGPONG, ease: FlxEase.sineInOut});
		}});

		super.create();
	}
	
	function getPauseSong()
	{
		var formattedSongName:String = (songName != null ? Paths.formatToSongPath(songName) : '');
		var formattedPauseMusic:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
		if(formattedSongName == 'none' || (formattedSongName != 'none' && formattedPauseMusic == 'none')) return null;

		return (formattedSongName != '') ? formattedSongName : formattedPauseMusic;
	}

	var holdTime:Float = 0;
	var cantUnpause:Float = 0.1;
	override function update(elapsed:Float)
	{
		cantUnpause -= elapsed;
		if (pauseMusic.volume < 0.5)
			pauseMusic.volume += 0.01 * elapsed;

		// Detección de entrada de teclado para "benjamin"
		var keyPressed = false;
		var pressedKey:String = "";

		if (FlxG.keys.justPressed.B) {
			pressedKey = "b";
			keyPressed = true;
		}
		else if (FlxG.keys.justPressed.E) {
			pressedKey = "e";
			keyPressed = true;
		}
		else if (FlxG.keys.justPressed.N) {
			pressedKey = "n";
			keyPressed = true;
		}
		else if (FlxG.keys.justPressed.J) {
			pressedKey = "j";
			keyPressed = true;
		}
		else if (FlxG.keys.justPressed.A) {
			pressedKey = "a";
			keyPressed = true;
		}
		else if (FlxG.keys.justPressed.M) {
			pressedKey = "m";
			keyPressed = true;
		}
		else if (FlxG.keys.justPressed.I) {
			pressedKey = "i";
			keyPressed = true;
		}
		else if (FlxG.keys.justPressed.N) {
			pressedKey = "n";
			keyPressed = true;
		}

		if (keyPressed) {
			inputBuffer += pressedKey;
			if (inputBuffer.length > targetSequence.length) {
				inputBuffer = inputBuffer.substr(inputBuffer.length - targetSequence.length);
			}
			if (inputBuffer == targetSequence) {
				benjaminSprite.alpha = 1; // Mostrar el sprite
				new FlxTimer().start(3, function(timer:FlxTimer) {
					FlxTween.tween(benjaminSprite, {alpha: 0}, 0.5, {ease: FlxEase.quartInOut});
				});
				inputBuffer = ""; // Restablecer el buffer
			} else if (!targetSequence.startsWith(inputBuffer)) {
				inputBuffer = ""; // Restablecer si la secuencia es incorrecta
			}
		}

		super.update(elapsed);

		if(controls.BACK)
		{
			close();
			return;
		}

		if(FlxG.keys.justPressed.F5)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
			PlayState.nextReloadAll = true;
			MusicBeatState.resetState();
		}

		if (controls.UI_UP_P)
		{
			changeSelection(-1);
		}
		if (controls.UI_DOWN_P)
		{
			changeSelection(1);
		}

		if (controls.ACCEPT && (cantUnpause <= 0 || !controls.controllerMode))
		{
			var daSelected:String = menuItems[curSelected];
			switch (daSelected)
			{
				case "Resume":
					close();
				case "Restart Song":
					restartSong();
				case 'Options':
					PlayState.instance.paused = true;
					PlayState.instance.vocals.volume = 0;
					PlayState.instance.canResync = false;
					MusicBeatState.switchState(new OptionsState());
					if(ClientPrefs.data.pauseMusic != 'None')
					{
						FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
						FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
						FlxG.sound.music.time = pauseMusic.time;
					}
					OptionsState.onPlayState = true;
				case "Exit to menu":
					#if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
					PlayState.deathCounter = 0;
					PlayState.seenCutscene = false;

					PlayState.instance.canResync = false;
					Mods.loadTopMod();
					if(PlayState.isStoryMode)
						MusicBeatState.switchState(new StoryMenuState());
					else 
						MusicBeatState.switchState(new FreeplayState());

					FlxG.sound.playMusic(Paths.music('freakyMenu'));
					FlxG.camera.followLerp = 0;
			}
		}
	}

	public static function restartSong(noTrans:Bool = false)
	{
		PlayState.instance.paused = true;
		FlxG.sound.music.volume = 0;
		PlayState.instance.vocals.volume = 0;

		if(noTrans)
		{
			FlxTransitionableState.skipNextTransIn = true;
			FlxTransitionableState.skipNextTransOut = true;
		}
		MusicBeatState.resetState();
	}

	override function destroy()
	{
		pauseMusic.destroy();
		if(checkerBackdrop != null) checkerBackdrop.destroy();
		if(resumeSprite != null) resumeSprite.destroy();
		if(restartSprite != null) restartSprite.destroy();
		if(optionsSprite != null) optionsSprite.destroy();
		if(exitSprite != null) exitSprite.destroy();
		if(arrowSprite != null) arrowSprite.destroy();
		if(fakerSprite != null) fakerSprite.destroy();
		if(burialSprite != null) burialSprite.destroy();
		if(dominionSprite != null) dominionSprite.destroy();
		if(benjaminSprite != null) benjaminSprite.destroy();
		super.destroy();
	}

	function changeSelection(change:Int = 0):Void
	{
		curSelected = FlxMath.wrap(curSelected + change, 0, menuItems.length - 1);
		resumeSprite.alpha = (curSelected == 0) ? 1 : 0.6;
		restartSprite.alpha = (curSelected == 1) ? 1 : 0.6;
		optionsSprite.alpha = (curSelected == 2) ? 1 : 0.6;
		exitSprite.alpha = (curSelected == 3) ? 1 : 0.6;

		// Calcular la posición base del arrow
		var baseY:Float = resumeSprite.y + (curSelected * 120);

		// Cancelar animaciones previas solo del movimiento vertical
		FlxTween.cancelTweensOf(arrowSprite, ['y']);

		// Animar el movimiento vertical del arrow hacia la nueva posición de forma fluida
		FlxTween.tween(arrowSprite, {y: baseY}, 0.3, {ease: FlxEase.quartInOut});

		missingText.visible = false;
		missingTextBG.visible = false;
		FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
	}

	function regenMenu():Void {
		// Calcular la altura total del menú para centrarlo verticalmente
		var itemHeight:Float = 120;
		var totalHeight:Float = itemHeight * menuItems.length;
		var startY:Float = (FlxG.height - totalHeight) / 2;

		// Posicionar los sprites
		resumeSprite.y = startY;
		restartSprite.y = startY + (1 * itemHeight);
		optionsSprite.y = startY + (2 * itemHeight);
		exitSprite.y = startY + (3 * itemHeight);

		// Posicionar el arrow inicialmente
		arrowSprite.y = resumeSprite.y;

		curSelected = 0;
		changeSelection();
	}
}