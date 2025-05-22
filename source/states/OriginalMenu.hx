package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSound;
import flixel.tweens.FlxTween;
import openfl.Assets;

class SongSelector extends FlxState
{
    var background:FlxBackdrop;
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

        background = new FlxBackdrop();
        try
        {
            var bgPath = "assets/shared/images/selector/sprbackground_square.png";
            if (Assets.exists(bgPath))
            {
                background.loadGraphic(bgPath);
                trace("Fondo cargado desde: " + bgPath);
            }
            else
            {
                bgPath = "assets/images/selector/sprbackground_square.png";
                if (Assets.exists(bgPath))
                {
                    background.loadGraphic(bgPath);
                    trace("Fondo cargado desde: " + bgPath);
                }
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
            var menuPath = "assets/shared/images/selector/menubg.png";
            if (Assets.exists(menuPath))
            {
                pixelSprite.loadGraphic(menuPath);
                trace("pixelSprite cargado desde: " + menuPath);
            }
            else
            {
                menuPath = "assets/images/selector/menubg.png";
                if (Assets.exists(menuPath))
                {
                    pixelSprite.loadGraphic(menuPath);
                    trace("pixelSprite cargado desde: " + menuPath);
                }
            }
            pixelSprite.antialiasing = false;
            pixelSprite.scale.set(2.5, 2.5);
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar menubg.png: " + e);
        }
        add(pixelSprite);

        tvOutlineSprite = new FlxSprite(300, 550);
        try
        {
            tvOutlineSprite.frames = Paths.getSparrowAtlas("selector/tv/tv-outline");
            trace("Frames cargados para tv-outline: " + (tvOutlineSprite.frames != null ? tvOutlineSprite.frames.frames.length : 0));
            if (tvOutlineSprite.frames != null && tvOutlineSprite.frames.frames.length > 0)
            {
                tvOutlineSprite.animation.addByIndices("idle", "idle", [0, 1, 2, 3], "", 24, true);
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
        }
        add(tvOutlineSprite);

        tvSprite = new FlxSprite(300, 550);
        try
        {
            tvSprite.frames = Paths.getSparrowAtlas("selector/tv/tv");
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
        }
        add(tvSprite);

        menucd = new FlxSprite(700, 600);
        try
        {
            var cdPath = "assets/shared/images/selector/menucd.png";
            if (Assets.exists(cdPath))
            {
                menucd.loadGraphic(cdPath);
                trace("menucd cargado desde: " + cdPath);
                menucd.scale.set(2, 2);
                menucd.animation.add("spin", [for (i in 0...360) i], 2, true);
                menucd.animation.play("spin");
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
        }
        add(menucd);

        menuleftar = new FlxSprite(400, 700);
        try
        {
            var leftPath = "assets/shared/images/selector/menuleftar.png";
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
        }
        add(menuleftar);

        menurightar = new FlxSprite(600, 400);
        try
        {
            var rightPath = "assets/shared/images/selector/menurightar.png";
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
        }
        add(menurightar);

        credits = new FlxSprite(768, 877);
        try
        {
            credits.frames = Paths.getSparrowAtlas("selector/buttons/credits");
            trace("Frames cargados para credits: " + (credits.frames != null ? credits.frames.frames.length : 0));
            if (credits.frames != null && credits.frames.frames.length > 0)
            {
                credits.animation.addByPrefix("idle0000", "credits idle0000", 24, false);
                credits.animation.addByPrefix("idle0001", "credits idle0001", 24, false);
                credits.animation.play("idle0000");
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
            options.frames = Paths.getSparrowAtlas("selector/buttons/options");
            trace("Frames cargados para options: " + (options.frames != null ? options.frames.frames.length : 0));
            if (options.frames != null && options.frames.frames.length > 0)
            {
                options.animation.addByPrefix("idle0000", "options idle0000", 24, false);
                options.animation.addByPrefix("idle0001", "options idle0001", 24, false);
                options.animation.play("idle0000");
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
            var musicPath = "assets/shared/images/selector/music/song.ogg";
            if (Assets.exists(musicPath))
            {
                music = new FlxSound().loadEmbedded(musicPath, true, true);
                music.play();
                trace("Música cargada desde: " + musicPath);
            }
            else
            {
                trace("No se encontró la música en: " + musicPath);
            }
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar música: " + e);
        }

        FlxG.autoPause = true;

        cursor = new FlxSprite();
        try
        {
            var cursorPath = "assets/shared/images/cursor.png";
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

        if (!FlxG.autoPause && music != null && music.playing)
        {
            music.pause();
            trace("Música pausada por pérdida de foco");
        }
        else if (FlxG.autoPause && music != null && !music.playing && music.time > 0)
        {
            music.resume();
            trace("Música reanudada");
        }

        if (background.frames != null)
        {
            background.offset.x += speed * elapsed;
            if (background.offset.x > background.width * background.scale.x)
                background.offset.x -= background.width * background.scale.x;
        }

        cursor.setPosition(FlxG.mouse.x, FlxG.mouse.y);

        tvOutlineSprite.x = tvSprite.x;
        tvOutlineSprite.y = tvSprite.y;

        var cameraTargetX = (FlxG.mouse.x - FlxG.width / 2) * cameraMoveSpeed;
        var cameraTargetY = (FlxG.mouse.y - FlxG.height / 2) * cameraMoveSpeed;
        FlxG.camera.scroll.x += (cameraTargetX - FlxG.camera.scroll.x) * cameraMoveSpeed;
        FlxG.camera.scroll.y += (cameraTargetY - FlxG.camera.scroll.y) * cameraMoveSpeed;
        FlxG.camera.scroll.x = Math.max(-100, Math.min(100, FlxG.camera.scroll.x));
        FlxG.camera.scroll.y = Math.max(-100, Math.min(100, FlxG.camera.scroll.y));

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

        if (FlxG.keys.justPressed.LEFT || (menuleftar != null && FlxG.mouse.justPressed && FlxG.mouse.overlaps(menuleftar)))
        {
            currentSongIndex--;
            if (currentSongIndex < 0) currentSongIndex = songs.length - 1;
            trace("Movido a la izquierda, canción: " + songs[currentSongIndex]);
        }
        if (FlxG.keys.justPressed.RIGHT || (menurightar != null && FlxG.mouse.justPressed && FlxG.mouse.overlaps(menurightar)))
        {
            currentSongIndex++;
            if (currentSongIndex >= songs.length) currentSongIndex = 0;
            trace("Movido a la derecha, canción: " + songs[currentSongIndex]);
        }

        if (FlxG.keys.justPressed.ENTER)
        {
            trace("Canción seleccionada: " + songs[currentSongIndex]);
        }

        if (FlxG.mouse.overlaps(credits))
        {
            credits.animation.play("idle0001");
            if (FlxG.mouse.justPressed && !isTransitioning)
            {
                trace("Credits seleccionado, iniciando transición a CreditsState...");
                isTransitioning = true;
                FlxG.camera.fade(FlxColor.BLACK, 3, false, function()
                {
                    trace("Transición completada, entrando a CreditsState");
                    FlxG.switchState(new states.CreditsState());
                    isTransitioning = false;
                });
            }
        }
        else
        {
            credits.animation.play("idle0000");
        }

        if (FlxG.mouse.overlaps(options))
        {
            options.animation.play("idle0001");
            if (FlxG.mouse.justPressed && !isTransitioning)
            {
                trace("Options seleccionado, iniciando transición a BaseOptionsMenu...");
                isTransitioning = true;
                FlxG.camera.fade(FlxColor.BLACK, 3, false, function()
                {
                    trace("Transición completada, entrando a BaseOptionsMenu");
                    FlxG.switchState(new options.BaseOptionsMenu());
                    isTransitioning = false;
                });
            }
        }
        else
        {
            options.animation.play("idle0000");
        }

        if (FlxG.mouse.justPressed && FlxG.mouse.overlaps(tvSprite) && !isTransitioning)
        {
            tvSprite.animation.play("loading");
            isTransitioning = true;
            transitionTimer = 0;
            trace("Iniciando transición para: " + songs[currentSongIndex]);
        }

        if (isTransitioning)
        {
            transitionTimer += elapsed;
            FlxG.camera.fade(FlxColor.BLACK, 3, false, function()
            {
                trace("Transición completada, entrando a MainMenuState con: " + songs[currentSongIndex]);
                FlxG.switchState(new MainMenuState());
                isTransitioning = false;
            });
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
    }

    override public function destroy():Void
    {
        super.destroy();
        if (music != null)
        {
            music.stop();
            music.destroy();
        }
    }
}