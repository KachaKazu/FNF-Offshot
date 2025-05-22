package substates;

import backend.WeekData;
import backend.Highscore;
import backend.Song;
import backend.Paths;

import flixel.util.FlxStringUtil;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxBackdrop;
import flixel.sound.FlxSound;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.math.FlxMath;
import flixel.text.FlxText;

import states.StoryMenuState;
import states.FreeplayState;
import options.OptionsState;

class PauseSubState extends MusicBeatSubstate
{
    var menuItems:Array<String> = ['Resume', 'Restart Song', 'Options', 'Exit to menu'];
    var curSelected:Int = 0;
    var pauseMusic:FlxSound;
    var renderSprite:FlxSprite;
    var optionSprites:FlxTypedGroup<FlxSprite>;
    var selectSprite:FlxSprite;
    var checker1:FlxBackdrop;
    var checker2:FlxBackdrop;
    var thing:Float = 0;
    var pauseSong:String;

    override function create()
    {
        // Precache assets
        pauseSong = getPauseSong();
        if (pauseSong != null) Paths.music(pauseSong); // Precache music
        Paths.image('pause/buttons/fakerRender');
        Paths.image('pause/buttons/fakerRender-alt');
        Paths.image('pause/buttons/exeRender');
        Paths.image('pause/buttons/select');
        Paths.image('pause/buttons/resume');
        Paths.image('pause/buttons/restart');
        Paths.image('pause/buttons/options');
        Paths.image('pause/buttons/exit');

        // Black background
        var blackPause:FlxSprite = new FlxSprite().makeGraphic(FlxG.width, FlxG.height, 0xFF000000);
        blackPause.alpha = 0;
        blackPause.scrollFactor.set();
        add(blackPause);
        FlxTween.tween(blackPause, {alpha: 0.5}, 0.6, {ease: FlxEase.linear});

        // Checkerboard backdrops
        checker1 = new FlxBackdrop(null, 0x11, 80, 80);
        checker1.makeGraphic(80, 80, 0xFFFFFFFF);
        checker1.alpha = 0;
        checker1.velocity.set(20, 20);
        FlxTween.tween(checker1, {alpha: 0.06}, 0.6, {ease: FlxEase.linear});
        add(checker1);

        checker2 = new FlxBackdrop(null, 0x11, 80, 80);
        checker2.makeGraphic(80, 80, 0xFFFFFFFF);
        checker2.alpha = 0;
        checker2.velocity.set(20, 20);
        checker2.x = 80;
        checker2.y = 80;
        FlxTween.tween(checker2, {alpha: 0.06}, 0.6, {ease: FlxEase.linear});
        add(checker2);

        // Render sprite
        var renderName:String = 'fakerRender';
        renderSprite = new FlxSprite(FlxG.width, 0).loadGraphic(Paths.image('pause/buttons/' + renderName));
        var scale:Float = (renderName.indexOf('exe') != -1) ? 1.55 : 2;
        renderSprite.scale.set(scale, scale);
        renderSprite.updateHitbox();
        renderSprite.antialiasing = false;
        renderSprite.y = FlxG.height - renderSprite.height + ((renderName.indexOf('exe') != -1) ? 50 : 20);
        FlxTween.tween(renderSprite, {x: FlxG.width - renderSprite.width - 20}, 0.6, {ease: FlxEase.cubeOut});
        add(renderSprite);

        // Option selector
        selectSprite = new FlxSprite(-100, 140).loadGraphic(Paths.image('pause/buttons/select'));
        selectSprite.scale.set(3, 3);
        selectSprite.updateHitbox();
        selectSprite.antialiasing = false;
        FlxTween.tween(selectSprite, {x: 5}, 0.6, {ease: FlxEase.expoOut});
        add(selectSprite);

        // Menu options
        optionSprites = new FlxTypedGroup<FlxSprite>();
        add(optionSprites);
        for (i in 0...menuItems.length)
        {
            var button:String = menuItems[i].toLowerCase().replace(' ', '');
            var sprite:FlxSprite = new FlxSprite(70, 150 + 100 * i).loadGraphic(Paths.image('pause/buttons/' + button));
            sprite.scale.set(3, 3);
            sprite.updateHitbox();
            sprite.antialiasing = false;
            sprite.ID = i + 1; // 1-based index to match Lua
            optionSprites.add(sprite);
        }

        // Play pause music
        pauseMusic = new FlxSound();
        try
        {
            if (pauseSong != null)
            {
                pauseMusic.loadEmbedded(Paths.music(pauseSong), true, true);
                pauseMusic.volume = 0;
                pauseMusic.play(false, FlxG.random.int(0, Std.int(pauseMusic.length / 2)));
                pauseMusic.pitch = 0.6;
                FlxG.sound.list.add(pauseMusic);
            }
        }
        catch (e:Dynamic) {}

        // Initialize selection
        changeSelection();

        super.create();
        cameras = [FlxG.cameras.list[FlxG.cameras.list.length - 1]];
    }

    function getPauseSong():String
    {
        var formattedSongName:String = (PauseSubState.songName != null) ? Paths.formatToSongPath(PauseSubState.songName) : '';
        var formattedPauseMusic:String = Paths.formatToSongPath(ClientPrefs.data.pauseMusic);
        if (formattedSongName == 'none' || (formattedSongName != 'none' && formattedPauseMusic == 'none')) return null;
        return (formattedSongName != '') ? formattedSongName : formattedPauseMusic;
    }

    override function beatHit()
    {
        super.beatHit();
        if (curBeat == 144)
        {
            renderSprite.loadGraphic(Paths.image('pause/buttons/fakerRender-alt'));
            renderSprite.scale.set(2, 2);
            renderSprite.updateHitbox();
            renderSprite.y = FlxG.height - renderSprite.height + 20;
            renderSprite.x = FlxG.width - renderSprite.width - 20;
        }
        else if (curBeat == 248)
        {
            renderSprite.loadGraphic(Paths.image('pause/buttons/exeRender'));
            renderSprite.scale.set(1.55, 1.55);
            renderSprite.updateHitbox();
            renderSprite.y = FlxG.height - renderSprite.height + 50;
            renderSprite.x = FlxG.width - renderSprite.width - 20;
        }
    }

    override function update(elapsed:Float)
    {
        super.update(elapsed);

        // Fade in pause music
        if (pauseMusic.volume < 0.5)
            pauseMusic.volume += 0.025 * elapsed;

        // Handle input
        if (FlxG.keys.justPressed.C)
        {
            close();
        }
        else if (FlxG.keys.justPressed.V)
        {
            restartSong();
        }
        else if (FlxG.keys.justPressed.B)
        {
            exitToMenu();
        }
        else if (controls.UI_UP_P)
        {
            changeSelection(-1);
        }
        else if (controls.UI_DOWN_P)
        {
            changeSelection(1);
        }
        else if (controls.ACCEPT)
        {
            selectOption();
        }

        // Animate menu options
        thing += elapsed;
        for (sprite in optionSprites)
        {
            var index:Int = sprite.ID;
            sprite.y = (150 + 100 * (index - 1)) + Math.sin(thing - (0.2 * index)) * 2;
        }
        selectSprite.y = (140 + 100 * (curSelected - 1)) + Math.sin(thing) * 2;
    }

    function changeSelection(change:Int = 0):Void
    {
        curSelected = FlxMath.wrap(curSelected + change, 1, menuItems.length);
        FlxG.sound.play(Paths.sound('scrollMenu'), 0.6);

        for (sprite in optionSprites)
        {
            var index:Int = sprite.ID;
            FlxTween.cancelTweensOf(sprite);
            var targetY:Float = 150 + 100 * (index - 1) - (index == curSelected ? 5 : 0);
            FlxTween.tween(sprite, {y: targetY}, 0.6, {ease: FlxEase.expoOut});
        }
        FlxTween.cancelTweensOf(selectSprite);
        FlxTween.tween(selectSprite, {y: 140 + 100 * (curSelected - 1)}, 0.6, {ease: FlxEase.expoOut});
    }

    function selectOption():Void
    {
        switch (menuItems[curSelected - 1])
        {
            case 'Resume':
                close();
            case 'Restart Song':
                restartSong();
            case 'Options':
                PlayState.instance.paused = true;
                PlayState.instance.vocals.volume = 0;
                PlayState.instance.canResync = false;
                if (ClientPrefs.data.pauseMusic != 'None')
                {
                    FlxG.sound.playMusic(Paths.music(Paths.formatToSongPath(ClientPrefs.data.pauseMusic)), pauseMusic.volume);
                    FlxTween.tween(FlxG.sound.music, {volume: 1}, 0.8);
                    FlxG.sound.music.time = pauseMusic.time;
                    FlxG.sound.music.pitch = 0.7;
                }
                OptionsState.onPlayState = true;
                MusicBeatState.switchState(new OptionsState());
            case 'Exit to menu':
                #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
                PlayState.deathCounter = 0;
                PlayState.seenCutscene = false;
                PlayState.instance.canResync = false;
                Mods.loadTopMod();
                if (PlayState.isStoryMode)
                    MusicBeatState.switchState(new StoryMenuState());
                else
                    MusicBeatState.switchState(new FreeplayState());
                FlxG.sound.playMusic(Paths.music('freakyMenu'));
                PlayState.changedDifficulty = false;
                PlayState.chartingMode = false;
                FlxG.camera.followLerp = 0;
        }
    }

    public static function restartSong(noTrans:Bool = false):Void
    {
        PlayState.instance.paused = true;
        FlxG.sound.music.volume = 0;
        PlayState.instance.vocals.volume = 0;
        if (noTrans)
        {
            FlxTransitionableState.skipNextTransIn = true;
            FlxTransitionableState.skipNextTransOut = true;
        }
        MusicBeatState.resetState();
    }

    function exitToMenu():Void
    {
        #if DISCORD_ALLOWED DiscordClient.resetClientID(); #end
        PlayState.deathCounter = 0;
        PlayState.seenCutscene = false;
        PlayState.instance.canResync = false;
        Mods.loadTopMod();
        if (PlayState.isStoryMode)
            MusicBeatState.switchState(new StoryMenuState());
        else
            MusicBeatState.switchState(new FreeplayState());
        FlxG.sound.playMusic(Paths.music('freakyMenu'));
        PlayState.changedDifficulty = false;
        PlayState.chartingMode = false;
        FlxG.camera.followLerp = 0;
    }

    override function destroy()
    {
        if (pauseMusic != null)
            pauseMusic.destroy();
        super.destroy();
    }
}