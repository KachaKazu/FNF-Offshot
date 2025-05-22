package states;

import flixel.FlxG;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import openfl.utils.Assets;
import flixel.math.FlxMath;

import states.MainMenuState;
import states.PlayState;
import backend.MusicBeatState;
import backend.Paths;
import backend.Controls;
import backend.ClientPrefs;
import flixel.FlxCamera;

class SongSelector extends MusicBeatState
{
    var background:FlxSprite;
    var speed:Float = 50;
    var pixelSprite:FlxSprite;
    var tvOutlineSprite:FlxSprite;
    var tvSprite:FlxSprite;
    var cursor:FlxSprite;
    var moveSpeed:Float = 0.1;
    var cameraMoveSpeed:Float = 0.05;
    var music:FlxSound;
    var beatTime:Float = 0;
    var beatLength:Float = 0.5;
    var zoomCycleTime:Float = 0;
    var zoomInDuration:Float = 0.1;
    var zoomOutDuration:Float = 0.4;
    var zoomCycleLength:Float = 0.5;
    var musicTime:Float = 0;
    var zoomStartDelay:Float = 16.0;
    var zoomStarted:Bool = false;

    var menucd:FlxSprite;
    var menuleftar:FlxSprite;
    var menurightar:FlxSprite;
    var credits:FlxSprite;
    var options:FlxSprite;

    var songs:Array<String> = ["peene", "good", "fighintg", "xenophanes"];
    var currentSongIndex:Int = 0;

    var transitionTimer:Float = 0;
    var isTransitioning:Bool = false;

    var controls(get, never):Controls;
    inline function get_controls():Controls
        return Controls.instance;

    override public function create():Void
    {
        super.create();

        if (FlxG.sound.music != null)
        {
            FlxG.sound.music.stop();
            FlxG.sound.music = null;
            trace("Música del estado anterior detenida");
        }

        FlxG.camera.setSize(FlxG.width, FlxG.height);
        FlxG.camera.scroll.set(0, 0);
        FlxG.camera.bgColor = FlxColor.BLACK;

        trace("Ventana: Resolución=" + FlxG.width + "x" + FlxG.height);
        trace("Cámara: Tamaño=" + FlxG.camera.width + "x" + FlxG.camera.height);

        background = new FlxSprite(0, 0);
        try
        {
            var bgPath = Paths.image('selector/sprbackground_square');
            if (Assets.exists(bgPath))
            {
                background.loadGraphic(bgPath);
                trace("Fondo cargado desde: " + bgPath);
            }
            else
            {
                trace("No se encontró sprbackground_square.png");
                background.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLUE);
            }
            background.setGraphicSize(FlxG.width, FlxG.height);
            background.updateHitbox();
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar fondo: " + e);
            background.makeGraphic(FlxG.width, FlxG.height, FlxColor.BLUE);
        }
        background.scrollFactor.set(0, 0);
        add(background);

        pixelSprite = new FlxSprite(376, 419);
        try
        {
            var menuPath = Paths.image('selector/menubg');
            if (Assets.exists(menuPath))
            {
                pixelSprite.loadGraphic(menuPath);
                trace("pixelSprite cargado desde: " + menuPath);
            }
            else
            {
                trace("No se encontró menubg.png");
                pixelSprite.makeGraphic(100, 100, FlxColor.GRAY);
            }
            pixelSprite.antialiasing = false;
            pixelSprite.scale.set(2.5, 2.5);
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar menubg.png: " + e);
            pixelSprite.makeGraphic(100, 100, FlxColor.GRAY);
        }
        add(pixelSprite);

        tvOutlineSprite = new FlxSprite(300, 550);
        try
        {
            tvOutlineSprite.frames = Paths.getSparrowAtlas('selector/tv/tv-outline');
            trace("Frames cargados para tv-outline: " + (tvOutlineSprite.frames != null ? tvOutlineSprite.frames.frames.length : 0));
            if (tvOutlineSprite.frames != null && tvOutlineSprite.frames.frames.length > 0)
            {
                tvOutlineSprite.animation.addByPrefix("idle", "idle", 24, true);
                tvOutlineSprite.animation.play("idle");
            }
            else
            {
                throw "No se cargaron frames para tv-outline";
            }
            tvOutlineSprite.scale.set(2, 2);
            tvOutlineSprite.antialiasing = false;
            tvOutlineSprite.visible = false;
            tvOutlineSprite.exists = true;
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar tv-outline: " + e);
            tvOutlineSprite.makeGraphic(100, 100, FlxColor.RED);
        }
        add(tvOutlineSprite);

        tvSprite = new FlxSprite(300, 550);
        try
        {
            tvSprite.frames = Paths.getSparrowAtlas('selector/tv/tv');
            trace("Frames cargados para tv: " + (tvSprite.frames != null ? tvSprite.frames.frames.length : 0));
            if (tvSprite.frames != null && tvSprite.frames.frames.length > 0)
            {
                tvSprite.animation.addByPrefix("idle", "idle", 24, true);
                tvSprite.animation.addByPrefix("loading", "loading", 24, true);
                tvSprite.animation.play("idle");
            }
            else
            {
                throw "No se cargaron frames para tv";
            }
            tvSprite.scale.set(2, 2);
            tvSprite.antialiasing = false;
            tvSprite.visible = true;
            tvSprite.exists = true;
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar tv: " + e);
            tvSprite.makeGraphic(100, 100, FlxColor.GREEN);
        }
        add(tvSprite);

        menucd = new FlxSprite(700, 600);
        try
        {
            var cdPath = Paths.image('selector/menucd');
            if (Assets.exists(cdPath))
            {
                menucd.loadGraphic(cdPath);
                trace("menucd cargado desde: " + cdPath);
                menucd.scale.set(2, 2);
            }
            else
            {
                trace("No se encontró menucd en: " + cdPath);
                menucd.makeGraphic(100, 100, FlxColor.GRAY);
            }
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar menucd: " + e);
            menucd.makeGraphic(100, 100, FlxColor.GRAY);
        }
        add(menucd);

        menuleftar = new FlxSprite(400, 700);
        try
        {
            var leftPath = Paths.image('selector/menuleftar');
            if (Assets.exists(leftPath))
            {
                menuleftar.loadGraphic(leftPath);
                trace("menuleftar cargado desde: " + leftPath);
                menuleftar.scale.set(2, 2);
            }
            else
            {
                trace("No se encontró menuleftar en: " + leftPath);
                menuleftar.makeGraphic(50, 50, FlxColor.RED);
            }
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar menuleftar: " + e);
            menuleftar.makeGraphic(50, 50, FlxColor.RED);
        }
        add(menuleftar);

        menurightar = new FlxSprite(600, 400);
        try
        {
            var rightPath = Paths.image('selector/menurightar');
            if (Assets.exists(rightPath))
            {
                menurightar.loadGraphic(rightPath);
                trace("menurightar cargado desde: " + rightPath);
                menurightar.scale.set(2, 2);
            }
            else
            {
                trace("No se encontró menurightar en: " + rightPath);
                menurightar.makeGraphic(50, 50, FlxColor.GREEN);
            }
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar menurightar: " + e);
            menurightar.makeGraphic(50, 50, FlxColor.GREEN);
        }
        add(menurightar);

        credits = new FlxSprite(768, 877);
        try
        {
            credits.frames = Paths.getSparrowAtlas('selector/buttons/credits');
            trace("Frames cargados para credits: " + (credits.frames != null ? credits.frames.frames.length : 0));
            if (credits.frames != null && credits.frames.frames.length > 0)
            {
                credits.animation.addByPrefix("idle", "credits idle0000", 24, false);
                credits.animation.addByPrefix("selected", "credits idle0001", 24, false);
                credits.animation.play("idle");
            }
            else
            {
                throw "No se cargaron frames para credits";
            }
            credits.scale.set(2, 2);
            credits.antialiasing = false;
            credits.exists = true;
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar credits: " + e);
            credits.makeGraphic(136, 38, FlxColor.YELLOW);
        }
        add(credits);

        options = new FlxSprite(310, 877);
        try
        {
            options.frames = Paths.getSparrowAtlas('selector/buttons/options');
            trace("Frames cargados para options: " + (options.frames != null ? options.frames.frames.length : 0));
            if (options.frames != null && options.frames.frames.length > 0)
            {
                options.animation.addByPrefix("idle", "options idle0000", 24, false);
                options.animation.addByPrefix("selected", "options idle0001", 24, false);
                options.animation.play("idle");
            }
            else
            {
                throw "No se cargaron frames para options";
            }
            options.scale.set(2, 2);
            options.antialiasing = false;
            options.exists = true;
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar options: " + e);
            options.makeGraphic(136, 38, FlxColor.PURPLE);
        }
        add(options);

        try
        {
            FlxG.sound.playMusic(Paths.music('freakyMenu'), 1, true);
            trace("Música freakyMenu cargada");
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar música: " + e);
        }

        FlxG.autoPause = true;

        cursor = new FlxSprite();
        try
        {
            var cursorPath = Paths.image('cursor');
            if (Assets.exists(cursorPath))
            {
                cursor.loadGraphic(cursorPath);
                trace("Cursor cargado desde: " + cursorPath);
            }
            else
            {
                cursor.makeGraphic(16, 16, FlxColor.WHITE);
                trace("Mostrando cursor placeholder blanco");
            }
            cursor.scale.set(2, 2);
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar cursor.png: " + e);
            cursor.makeGraphic(16, 16, FlxColor.WHITE);
        }
        add(cursor);
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        background.x -= speed * elapsed;
        if (background.x < -background.width)
            background.x += background.width;

        cursor.setPosition(FlxG.mouse.x, FlxG.mouse.y);

        tvOutlineSprite.x = tvSprite.x;
        tvOutlineSprite.y = tvSprite.y;

        var cameraTargetX = (FlxG.mouse.x - FlxG.width / 2) * cameraMoveSpeed;
        var cameraTargetY = (FlxG.mouse.y - FlxG.height / 2) * cameraMoveSpeed;
        FlxG.camera.scroll.x += (cameraTargetX - FlxG.camera.scroll.x) * cameraMoveSpeed;
        FlxG.camera.scroll.y += (cameraTargetY - FlxG.camera.scroll.y) * cameraMoveSpeed;
        FlxG.camera.scroll.x = FlxMath.clamp(FlxG.camera.scroll.x, -100, 100);
        FlxG.camera.scroll.y = FlxMath.clamp(FlxG.camera.scroll.y, -100, 100);

        menucd.angle += 2 * elapsed;

        musicTime += elapsed;

        if (musicTime >= zoomStartDelay && !zoomStarted)
        {
            zoomStarted = true;
        }

        if (zoomStarted)
        {
            zoomCycleTime += elapsed;
            if (zoomCycleTime >= zoomCycleLength)
            {
                zoomCycleTime -= zoomCycleLength;
            }
            var zoomProgress:Float = 0;
            if (zoomCycleTime < zoomInDuration)
            {
                zoomProgress = zoomCycleTime / zoomInDuration;
            }
            else
            {
                zoomProgress = 1 - ((zoomCycleTime - zoomInDuration) / zoomOutDuration);
            }
            FlxG.camera.zoom = 1.0 + (0.03 * zoomProgress);
        }

        if (controls.UI_LEFT_P || (menuleftar != null && FlxG.mouse.justPressed && FlxG.mouse.overlaps(menuleftar)))
        {
            currentSongIndex = (currentSongIndex - 1 + songs.length) % songs.length;
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
            trace("Movido a la izquierda, canción: " + songs[currentSongIndex]);
        }
        if (controls.UI_RIGHT_P || (menurightar != null && FlxG.mouse.justPressed && FlxG.mouse.overlaps(menurightar)))
        {
            currentSongIndex = (currentSongIndex + 1) % songs.length;
            FlxG.sound.play(Paths.sound('scrollMenu'), 0.4);
            trace("Movido a la derecha, canción: " + songs[currentSongIndex]);
        }

        if (controls.ACCEPT && !isTransitioning)
        {
            isTransitioning = true;
            trace("Canción seleccionada: " + songs[currentSongIndex]);
            PlayState.SONG = Song.loadFromJson(songs[currentSongIndex], songs[currentSongIndex]);
            MusicBeatState.switchState(new PlayState());
        }

        if (FlxG.mouse.overlaps(credits))
        {
            credits.animation.play("selected");
        }
        else
        {
            credits.animation.play("idle");
        }

        if (FlxG.mouse.overlaps(options))
        {
            options.animation.play("selected");
        }
        else
        {
            options.animation.play("idle");
        }

        if ((FlxG.mouse.justPressed && FlxG.mouse.overlaps(tvSprite) || controls.ACCEPT) && !isTransitioning)
        {
            tvSprite.animation.play("loading");
            isTransitioning = true;
            transitionTimer = 0;
            trace("Iniciando transición para: " + songs[currentSongIndex]);
            PlayState.SONG = Song.loadFromJson(songs[currentSongIndex], songs[currentSongIndex]);
            MusicBeatState.switchState(new PlayState());
        }

        if (FlxG.mouse.overlaps(tvSprite))
        {
            tvOutlineSprite.visible = true;
            if (tvSprite.animation.name != "loading" && !isTransitioning)
            {
                tvSprite.animation.play("idle");
            }
        }
        else
        {
            tvOutlineSprite.visible = false;
            if (tvSprite.animation.name != "loading" && !isTransitioning)
            {
                tvSprite.animation.play("idle");
            }
        }

        if (controls.BACK && !isTransitioning)
        {
            isTransitioning = true;
            FlxG.sound.play(Paths.sound('cancelMenu'), 0.4);
            MusicBeatState.switchState(new MainMenuState());
        }
    }

    override public function destroy():Void
    {
        super.destroy();
        if (FlxG.sound.music != null)
        {
            FlxG.sound.music.stop();
        }
    }
}