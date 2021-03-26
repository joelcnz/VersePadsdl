module setupone;

import jecsdl;

import base;

enum programName = "Verse Pad"; /// Program name

Setup g_setup;

/// Main setup struct
struct Setup {
private:
    string _settingsFileName;
public:
    int psetup(string[] args = []) {
        import jecsdl, jmisc;

/+
        setSettingsFileName("settings.ini");
        assert(fileNameExists, _settingsFileName ~ " not found");
        loadSettings;
    +/
        string userName;
        if (args.length > 1) {
            import std.string: join;

            userName = args[1 .. $].join(" ");
        } else {
            writeln("Identify your self, next time - ok");
            return -10;
        }
        immutable WELCOME = "Welcome, " ~ userName ~ ", to " ~ programName;
        g_userName = userName;

        //SCREEN_WIDTH = 640; SCREEN_HEIGHT = 480;
        //SCREEN_WIDTH = 2560; SCREEN_HEIGHT = 1600;
        SCREEN_WIDTH = 1280; SCREEN_HEIGHT = 800;
        if (jecsdlsetup("Poorly Programmed Producions - Presents: " ~ programName,
            SCREEN_WIDTH, SCREEN_HEIGHT,
            SDL_WINDOW_SHOWN
            //SDL_WINDOW_OPENGL
            //SDL_WINDOW_FULLSCREEN_DESKTOP
            //SDL_WINDOW_FULLSCREEN
            ) != 0) {
            writeln("Init failed");
            return 1;
        }

        const ifontSize = 12;
        jx = new InputJex(Point(0, 800 - ifontSize - ifontSize / 4), ifontSize, "H for help>",
            InputType.history);
        g_terminal = false;
        jx.setColour = SDL_Color(255, 200, 0, 255);
        jx.addToHistory(""d);
        jx.edge = false;

        //#Bible
        import std.path : buildPath;
        immutable BIBLE_VER = "asv"; //""kjv";
        loadBible(BIBLE_VER, buildPath("..", "BibleLib", "Versions"));

        //g_mode = Mode.edit;
        g_terminal = true;

        jx.showHistory = false;

    //    g_window.setFramerateLimit(60);

        g_letterBase = new LetterManager(["lemgreen.png","lemblue.png"], 9, 16, SDL_Rect(0,0, 1280,800));
        assert(g_letterBase, "Error creating LetterManager");

        updateFileNLetterBase(WELCOME, newline);
        g_letterBase.setLockAll(true);

        //g_mode = Mode.edit;
    	g_terminal = true;

        return 0;
    }

    void shutdown() {
        // saveSettings;
        SDL_DestroyRenderer(gRenderer),
        SDL_Quit();
    }
    
    void setSettingsFileName(in string fileName) {
        _settingsFileName = fileName;
    }

    bool fileNameExists() {
        import std.file : exists;

        return exists(_settingsFileName); 
        //if (! exists(_settingsFileName))
        //    return false;
        //else
        //    return true;
    }

    void saveSettings() {
        /+
        import std.stdio : File;
        import std.string : format;

        char oneorzero(bool n) { return n ? '1' : '0'; }
        auto file = File(_settingsFileName, "w");
        with(file) {
            writeln("[main]");
            writeln("age=", g_age);
            writeln("rotate=", oneorzero(g_rotate));
            writeln("rotateSpeed=", g_rotateSpeed);
            writeln("image=", g_image);
            writeln("showNum=", oneorzero(g_showNum));
            writeln("radiusw=", g_radiusw);
            writeln("radiush=", g_radiush);
            writeln("rotateCircle=", g_rotateCircle);
            writeln("guiButtonsToggle=", oneorzero(g_guiButtonsToggle));
        }
        +/
    }

    void loadSettings() {
        /+
        if (fileNameExists) {
            auto ini = Ini.Parse(_settingsFileName);

            bool ifzero(string a) { return a == "1"; } 
            g_age = ini["main"].getKey("age").to!int;
            g_rotate = ifzero(ini["main"].getKey("rotate"));
            g_rotateSpeed = ini["main"].getKey("rotateSpeed").to!float;
            g_image = ini["main"].getKey("image");
            g_showNum= ifzero(ini["main"].getKey("showNum"));
            g_radiusw = ini["main"].getKey("radiusw").to!int;
            g_radiush = ini["main"].getKey("radiush").to!int;
            g_rotateCircle = ini["main"].getKey("rotateCircle").to!float;
            g_guiButtonsToggle = ifzero(ini["main"].getKey("guiButtonsToggle"));
        }
        +/
    }
}
