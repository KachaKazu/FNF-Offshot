package states;

import flixel.FlxG;
import flixel.FlxState;
import flixel.addons.display.FlxBackdrop;
import flixel.FlxSprite;
import flixel.util.FlxColor;
import flixel.util.FlxAxes;
import flixel.graphics.frames.FlxAtlasFrames;
import flixel.system.FlxSound;
import flixel.text.FlxText;
import flixel.tweens.FlxTween;
import flixel.tweens.FlxEase;
import flixel.tweens.FlxTween.FlxTweenType;
import openfl.Assets;
import options.OptionsState;
import backend.Song;
import sys.FileSystem;
import sys.io.File;
import haxe.Json;
import haxe.ds.Map;
import haxe.ds.StringMap;

class OriginalMenu extends FlxState
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
    var songSprite:FlxSprite;
    var songCover:FlxSprite;
    var songNameText:FlxText;
    var bakerSprite:FlxSprite; // Sprite para baker
    var boomSound:FlxSound; // Sonido para boom

    var songs:Array<String> = ["phony", "burial", "dominion"]; // Predefined song names
    var songScores:Array<Int> = [1000, 1000, 1000]; // Initial scores for each song
    var currentSongIndex:Int = 0;

    var transitionTimer:Float = 0;
    var isTransitioning:Bool = false;

    // Variables para detectar la entrada de texto
    var inputBuffer:String = "";
    var bakerTimer:Float = 0; // Temporizador para ocultar el sprite después de 2 segundos
    var isSongLocked:Bool = false; // Nueva variable para bloquear la selección

    // Mapeo dinámico de canciones a sus carpetas externas
    var songFolders:Map<String, String> = new haxe.ds.StringMap<String>();

    override public function create():Void
    {
        super.create();

        // Initialize songFolders mappings
        songFolders.set("phony", "phony-oneshot");
        songFolders.set("burial", "burial-oneshot");
        songFolders.set("dominion", "zalgo-oneshot");

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

        pixelSprite = new FlxSprite(168, 320);
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
            pixelSprite.scale.set(1.3, 1.3);
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
            tvOutlineSprite.scale.set(1.3, 1.3);
            tvOutlineSprite.antialiasing = false;
            tvOutlineSprite.visible = false;
            tvOutlineSprite.exists = true;
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar tv-outline: " + e);
        }
        add(tvOutlineSprite);

        tvSprite = new FlxSprite(200, 448);
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
            tvSprite.scale.set(1.3, 1.3);
            tvSprite.antialiasing = false;
            tvSprite.visible = true;
            tvSprite.exists = true;
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar tv: " + e);
        }
        add(tvSprite);

        menucd = new FlxSprite(430, 380);
        try
        {
            var cdPath = "assets/shared/images/selector/menucd.png";
            if (Assets.exists(cdPath))
            {
                menucd.loadGraphic(cdPath);
                trace("menucd cargado desde: " + cdPath);
                menucd.scale.set(1.3, 1.3);
                FlxTween.angle(menucd, 0, 360, 10, { type: FlxTweenType.LOOPING, ease: FlxEase.linear });
            }
            else
            {
                trace("No se encontró menucd en: " + cdPath);
                menucd.makeGraphic(100, 100, FlxColor.GRAY);
                FlxTween.angle(menucd, 0, 360, 10, { type: FlxTweenType.LOOPING, ease: FlxEase.linear });
            }
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar menucd: " + e);
        }
        add(menucd);

        menuleftar = new FlxSprite(383, 424);
        try
        {
            var leftPath = "assets/shared/images/selector/menuleftar.png";
            if (Assets.exists(leftPath))
            {
                menuleftar.loadGraphic(leftPath);
                trace("menuleftar cargado desde: " + leftPath);
                menuleftar.scale.set(1.3, 1.3);
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

        menurightar = new FlxSprite(570, 424);
        try
        {
            var rightPath = "assets/shared/images/selector/menurightar.png";
            if (Assets.exists(rightPath))
            {
                menurightar.loadGraphic(rightPath);
                trace("menurightar cargado desde: " + rightPath);
                menurightar.scale.set(1.3, 1.3);
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

        // Inicializar songCover y agregarlo antes de songSprite
        songCover = new FlxSprite(548, 30);
        if (songCover != null) updateSongCover(); // Cargar la imagen inicial solo si es válido
        add(songCover);

        // Inicializar songSprite
        songSprite = new FlxSprite(132, 30);
        try
        {
            var songPath = "assets/shared/images/selector/songs/song.png";
            if (Assets.exists(songPath))
            {
                songSprite.loadGraphic(songPath);
                trace("songSprite cargado desde: " + songPath);
                songSprite.scale.set(1.3, 1.3);
            }
            else
            {
                trace("No se encontró songSprite en: " + songPath);
                songSprite.makeGraphic(200, 100, FlxColor.WHITE);
            }
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar songSprite: " + e);
            songSprite.makeGraphic(200, 100, FlxColor.WHITE); // Fallback
        }
        add(songSprite);

        // Inicializar songNameText y agregarlo después de songSprite con el nuevo font
        songNameText = new FlxText(132, 30, 0, "", 30); // Tamaño aumentado a 30
        if (songNameText != null)
        {
            var fontPath = "assets/fonts/upheavtt.ttf";
            if (Assets.exists(fontPath))
            {
                songNameText.setFormat(fontPath, 30, FlxColor.WHITE, CENTER); // Tamaño 30
                trace("Font upheavtt.ttf cargado para songNameText");
            }
            else
            {
                trace("No se encontró upheavtt.ttf en: " + fontPath + ". Usando font por defecto.");
                songNameText.setFormat(null, 30, FlxColor.WHITE, CENTER); // Fallback al font por defecto
            }
        }
        add(songNameText);

        credits = new FlxSprite(448, 630);
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
            credits.scale.set(1.3, 1.3);
            credits.antialiasing = false;
            credits.exists = true;
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar credits: " + e);
            credits.makeGraphic(136, 38, FlxColor.YELLOW);
        }
        add(credits);

        options = new FlxSprite(220, 630);
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
            options.scale.set(1.3, 1.3);
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

        // Cargar el sonido boom
        try
        {
            var boomPath = "assets/shared/images/selector/songs/boom.ogg";
            if (Assets.exists(boomPath))
            {
                boomSound = new FlxSound().loadEmbedded(boomPath, false, false);
                trace("boomSound cargado desde: " + boomPath);
            }
            else
            {
                trace("No se encontró boomSound en: " + boomPath);
            }
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar boomSound: " + e);
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
                trace("No se encontró cursor en: " + cursorPath);
                return;
            }
            cursor.scale.set(2, 2);
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar cursor.png: " + e);
            return;
        }
        add(cursor);

        // Inicializar bakerSprite después de todos los demás sprites en (411, 360)
        bakerSprite = new FlxSprite(411, 360); // Posición en (411, 360)
        try
        {
            var bakerPath = "assets/shared/images/selector/songs/baker.png";
            if (Assets.exists(bakerPath))
            {
                bakerSprite.loadGraphic(bakerPath);
                trace("bakerSprite cargado desde: " + bakerPath);
                bakerSprite.scale.set(1.3, 1.3); // Escala para que sea visible
            }
            else
            {
                trace("No se encontró bakerSprite en: " + bakerPath + ". Usando fallback.");
                bakerSprite.makeGraphic(100, 100, FlxColor.PURPLE); // Fallback si no se encuentra el archivo
            }
        }
        catch (e:Dynamic)
        {
            trace("Error al cargar bakerSprite: " + e);
            bakerSprite.makeGraphic(100, 100, FlxColor.PURPLE); // Fallback en caso de error
        }
        bakerSprite.visible = false; // Inicialmente invisible
        add(bakerSprite);

        // Escanear mods y cargar canciones dinámicamente (optional, can be removed if predefined songs are sufficient)
        loadSongsFromMods();

        if (songs.length < 1)
        {
            trace("No se encontraron canciones en mods.");
            return;
        }

        changeSelection();
        updateSongDisplay();
    }

    function loadSongsFromMods()
    {
        if (!FileSystem.exists("mods"))
            return;

        var modFolders = FileSystem.readDirectory("mods");
        for (modFolder in modFolders)
        {
            var modPath = "mods/" + modFolder;
            if (FileSystem.isDirectory(modPath))
            {
                var dataPath = modPath + "/data/";
                if (FileSystem.exists(dataPath))
                {
                    var songSubFolders = FileSystem.readDirectory(dataPath);
                    for (songFolder in songSubFolders)
                    {
                        var songPath = dataPath + songFolder;
                        if (FileSystem.isDirectory(songPath))
                        {
                            var jsonPath = songPath + "/" + songFolder + ".json";
                            if (FileSystem.exists(jsonPath))
                            {
                                try
                                {
                                    var songData:String = File.getContent(jsonPath);
                                    var parsedSong:Dynamic = Json.parse(songData);
                                    var songName:String = parsedSong.song != null ? parsedSong.song : songFolder;
                                    if (!songs.contains(songName)) // Avoid duplicates with predefined songs
                                    {
                                        songs.push(songName);
                                        songScores.push(1000);
                                        songFolders.set(songName, modFolder);
                                        trace("Canción detectada: " + songName + " en mod: " + modFolder);
                                    }
                                }
                                catch (e:Dynamic)
                                {
                                    trace("Error al parsear " + jsonPath + ": " + e);
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    function changeSelection(change:Int = 0):Void
    {
        if (!isSongLocked) // Solo cambiar si no está bloqueado
        {
            currentSongIndex += change;
            if (currentSongIndex < 0) currentSongIndex = songs.length - 1;
            if (currentSongIndex >= songs.length) currentSongIndex = 0;
            updateSongDisplay();
            trace("Canción seleccionada: " + songs[currentSongIndex]);
        }
    }

    function updateSongCover():Void
    {
        if (songCover != null)
        {
            var coverPath = "assets/shared/images/selector/songs/" + songs[currentSongIndex] + "_cover.png";
            if (Assets.exists(coverPath))
            {
                songCover.loadGraphic(coverPath);
                trace("Cover cargado para " + songs[currentSongIndex] + " desde: " + coverPath);
            }
            else
            {
                trace("No se encontró cover para " + songs[currentSongIndex] + " en: " + coverPath);
                songCover.makeGraphic(200, 100, FlxColor.GRAY);
            }
            songCover.scale.set(1.3, 1.3);
        }

        if (songNameText != null)
        {
            songNameText.text = songs[currentSongIndex].toUpperCase();
        }
    }

    override public function update(elapsed:Float):Void
    {
        super.update(elapsed);

        // Detectar entrada de texto para "baker"
        if (FlxG.keys.justPressed.ANY && !isTransitioning)
        {
            var lastKey = FlxG.keys.getIsDown()[0].ID.toString().toLowerCase();
            if (lastKey.length == 1) // Solo agregar si es una letra
            {
                inputBuffer += lastKey;
                if (inputBuffer.length > 5) // Limitar el buffer a 5 caracteres (longitud de "baker")
                {
                    inputBuffer = inputBuffer.substr(inputBuffer.length - 5);
                }
                trace("Input buffer: " + inputBuffer);
                // Manejar la reordenación de bakerSprite al frente cuando aparece
                if (inputBuffer.toLowerCase() == "baker")
                {
                    if (bakerSprite != null)
                    {
                        remove(bakerSprite); // Remover para reordenar
                        add(bakerSprite);   // Añadir de nuevo para colocarlo al frente
                        bakerSprite.visible = true;
                        bakerTimer = 2.0; // Mostrar por 2 segundos
                        trace("Mostrando bakerSprite al frente en (411, 360)");
                    }
                    if (boomSound != null)
                    {
                        boomSound.play(true); // Reproducir el sonido
                        trace("Reproduciendo boomSound");
                    }
                    inputBuffer = ""; // Reiniciar el buffer
                }
            }
        }

        // Manejar el temporizador para ocultar bakerSprite
        if (bakerSprite != null && bakerSprite.visible)
        {
            bakerTimer -= elapsed;
            if (bakerTimer <= 0)
            {
                bakerSprite.visible = false;
                bakerTimer = 0;
                trace("Ocultando bakerSprite");
            }
        }

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

        if (background != null && background.frames != null)
        {
            background.offset.x += speed * elapsed;
            if (background.offset.x > background.width * background.scale.x)
                background.offset.x -= background.width * background.scale.x;
        }

        if (cursor != null)
        {
            cursor.setPosition(FlxG.mouse.x, FlxG.mouse.y);
        }

        if (tvOutlineSprite != null)
        {
            tvOutlineSprite.x = tvSprite != null ? tvSprite.x : 300;
            tvOutlineSprite.y = tvSprite != null ? tvSprite.y : 550;
        }

        var cameraTargetX = (FlxG.mouse.x - FlxG.width / 2) * cameraMoveSpeed;
        var cameraTargetY = (FlxG.mouse.y - FlxG.height / 2) * cameraMoveSpeed;
        if (FlxG.camera != null)
        {
            FlxG.camera.scroll.x += (cameraTargetX - FlxG.camera.scroll.x) * cameraMoveSpeed;
            FlxG.camera.scroll.y += (cameraTargetY - FlxG.camera.scroll.y) * cameraMoveSpeed;
            FlxG.camera.scroll.x = Math.max(-100, Math.min(100, FlxG.camera.scroll.x));
            FlxG.camera.scroll.y = Math.max(-100, Math.min(100, FlxG.camera.scroll.y));
        }

        musicTime += elapsed;

        if (musicTime >= zoomStartDelay && !zoomStarted)
        {
            zoomStarted = true;
        }

        if (zoomStarted && FlxG.camera != null)
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

        // Manejar selección con Enter y Esc
        if (FlxG.keys.justPressed.ENTER && !isTransitioning && !isSongLocked)
        {
            if (songNameText != null)
            {
                songNameText.setFormat(null, 30, 0xFFD700, CENTER); // Cambiar a dorado
                isSongLocked = true; // Bloquear selección
                trace("Canción seleccionada: " + songs[currentSongIndex] + " (bloqueado)");
            }
        }
        else if (FlxG.keys.justPressed.ESCAPE && isSongLocked)
        {
            if (songNameText != null)
            {
                songNameText.setFormat(null, 30, FlxColor.WHITE, CENTER); // Volver a blanco
                isSongLocked = false; // Desbloquear selección
                trace("Selección desbloqueada");
            }
        }

        // Cambiar canción solo si no está bloqueada
        if ((FlxG.keys.justPressed.LEFT || (menuleftar != null && FlxG.mouse.justPressed && FlxG.mouse.overlaps(menuleftar))) && !isTransitioning)
        {
            changeSelection(-1);
        }
        if ((FlxG.keys.justPressed.RIGHT || (menurightar != null && FlxG.mouse.justPressed && FlxG.mouse.overlaps(menurightar))) && !isTransitioning)
        {
            changeSelection(1);
        }

        if (credits != null && FlxG.mouse.overlaps(credits))
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
        else if (credits != null)
        {
            credits.animation.play("idle0000");
        }

        if (options != null && FlxG.mouse.overlaps(options))
        {
            options.animation.play("idle0001");
            if (FlxG.mouse.justPressed && !isTransitioning)
            {
                trace("Options seleccionado, iniciando transición a OptionsState...");
                isTransitioning = true;
                FlxG.camera.fade(FlxColor.BLACK, 3, false, function()
                {
                    trace("Transición completada, entrando a OptionsState");
                    FlxG.switchState(new OptionsState());
                    isTransitioning = false;
                });
            }
        }
        else if (options != null)
        {
            options.animation.play("idle0000");
        }

        if (tvSprite != null && FlxG.mouse.justPressed && FlxG.mouse.overlaps(tvSprite) && !isTransitioning)
        {
            tvSprite.animation.play("loading");
            isTransitioning = true;
            transitionTimer = 0;
            trace("Iniciando transición para la canción: " + songs[currentSongIndex]);
            var songName = songs[currentSongIndex].toLowerCase();
            var folder = songFolders.get(songName);
            if (folder != null)
            {
                var jsonPath = 'mods/${folder}/data/${songName}/${songName}.json';
                var absolutePath = Sys.getCwd() + jsonPath;
                trace("Buscando archivo en la ruta absoluta: " + absolutePath);

                if (FileSystem.exists(jsonPath))
                {
                    try
                    {
                        var songData:String = File.getContent(jsonPath);
                        var parsedSong:Dynamic = Json.parse(songData);
                        if (parsedSong != null)
                        {
                            var songObject:Dynamic = {
                                song: parsedSong.song != null ? parsedSong.song : songName,
                                notes: parsedSong.notes != null ? parsedSong.notes : [],
                                bpm: parsedSong.bpm != null ? parsedSong.bpm : 100.0,
                                needsVoices: parsedSong.needsVoices != null ? parsedSong.needsVoices : false,
                                events: parsedSong.events != null ? parsedSong.events : [],
                                format: parsedSong.format != null ? parsedSong.format : "unknown",
                                offset: parsedSong.offset != null ? parsedSong.offset : 0.0,
                                speed: parsedSong.speed != null ? parsedSong.speed : 1.0,
                                player1: parsedSong.player1 != null ? parsedSong.player1 : "bf",
                                player2: parsedSong.player2 != null ? parsedSong.player2 : "dad",
                                gfVersion: parsedSong.gfVersion != null ? parsedSong.gfVersion : "gf",
                                stage: parsedSong.stage != null ? parsedSong.stage : "stage",
                                modFolder: folder // Add mod folder to song object
                            };
                            PlayState.SONG = songObject;
                            trace("Canción cargada desde: " + jsonPath);

                            FlxG.camera.fade(FlxColor.BLACK, 3, false, function()
                            {
                                trace("Transición completada, entrando a PlayState con la canción: " + songName);
                                FlxG.switchState(new states.PlayState());
                                isTransitioning = false;
                            });
                        }
                        else
                        {
                            trace("Error: parsedSong es nulo para " + jsonPath);
                            isTransitioning = false;
                        }
                    }
                    catch (e:Dynamic)
                    {
                        trace("Error al cargar o parsear el JSON para la canción " + songName + ": " + e);
                        isTransitioning = false;
                    }
                }
                else
                {
                    var dirPath = 'mods/${folder}/data/${songName}/';
                    if (FileSystem.exists(dirPath))
                    {
                        var files = FileSystem.readDirectory(dirPath);
                        trace("Contenido de la carpeta " + dirPath + ": " + files.join(", "));
                    }
                    else
                    {
                        trace("La carpeta " + dirPath + " no existe.");
                    }
                    trace("Error: No se encontró el archivo JSON en: " + jsonPath);
                    isTransitioning = false;
                }
            }
            else
            {
                trace("Error: No se encontró la carpeta del mod para la canción: " + songName);
                isTransitioning = false;
            }
        }

        if (tvSprite != null && FlxG.mouse.overlaps(tvSprite))
        {
            tvOutlineSprite.visible = true;
            if (tvSprite.animation.name != "loading" && !isTransitioning)
            {
                tvSprite.animation.play("idle");
            }
        }
        else if (tvOutlineSprite != null)
        {
            tvOutlineSprite.visible = false;
            if (tvSprite != null && tvSprite.animation.name != "loading" && !isTransitioning)
            {
                tvSprite.animation.play("idle");
            }
        }
    }

    function updateSongDisplay():Void
    {
        updateSongCover();
    }

    override public function destroy():Void
    {
        super.destroy();
        if (music != null)
        {
            music.stop();
            music.destroy();
        }
        if (boomSound != null)
        {
            boomSound.stop();
            boomSound.destroy();
        }
    }
}