//#line ?!
module app;

//#Bible

import base, setupone;

enum PROJECTS = "Projects"; /// List of projects

/**
	The Main
 */
int main(string[] args) {
	scope(exit) {
		writeln;
		writeln("#  #");
		writeln("## #");
		writeln("####");
		writeln("# ##");
		writeln("#  #");
		writeln;
	}

	version(OSX) {
		writeln("This is a Mac version of " ~ programName);
	}
	version(Windows) {
		writeln("This is a Windows version of " ~ programName);
	}
	version(linux) {
		writeln("This is a Linux version of " ~ programName);
	}

    //writeln("Over a million: ", addCommas(1_234_567));

/+
    assert(jf_setup(WELCOME,1280,800), "jf setup failed");
	scope(exit)
		close;
+/
	if (g_setup.psetup(args) != 0) {
		gh("Setup error, aborting...");

		return -1;
	}

	scope(exit)
		g_setup.shutdown;

    string[] files;

    doProjects(files, /* show */ false);
    run(files);

	return 0;
}

/// Run program
void run(string[] files) {
    import std.file : readText;
    import std.path : buildPath;
    //import std.string : ;

    string restoreFileName = "lastText" ~ g_userName ~ ".txt";
    import std.file: exists;
    if (! exists(restoreFileName)) {
        import std.stdio: File, write;
        File(restoreFileName, "w").write("Welcome, ", g_userName, ", to Verse Pad\n\nEnter 'help' to start:\n");
    }
    auto restoreText = readText(restoreFileName);
    g_letterBase.setText(restoreText);
    auto helpText = readText("_notes.txt");
    scope(exit) {
        import std.stdio: File, write;
        File(restoreFileName, "w").write(g_letterBase.getText);
    }
    with(g_letterBase)
        setTextType(TextType.block); //#line ?!
    scope(exit)
       close();
    string userInput, lastOutPut;
    bool enterPressed = false; //#enter pressed
    int prefix;
    prefix = g_letterBase.count();
    auto firstRun = true;
    auto done = NO;

    enum CharSet {green,blue}
	
    g_letterBase.currentGfxIndex(0);
    while(! done) {
        // FPS.start();

		//Handle events on queue
		while( SDL_PollEvent( &gEvent ) != 0 ) {
			//User requests quit
			if (gEvent.type == SDL_QUIT)
				done = true;
		}

        SDL_PumpEvents();

        if (g_keys[SDL_SCANCODE_LCTRL].keyPressed ||
            g_keys[SDL_SCANCODE_RCTRL].keyPressed) {
            if (g_keys[SDL_SCANCODE_1].keyInput) {
                g_letterBase.currentGfxIndex(CharSet.green);
            }
            if (g_keys[SDL_SCANCODE_2].keyInput) {
                g_letterBase.currentGfxIndex(CharSet.blue);
            }
        }

        //#windows version needed for short cut to quit

        // print for prompt, text depending on whether the section has any verses or not
        if (enterPressed || firstRun) {
            firstRun = false;
            if (firstRun)
                enterPressed = false;
            // if (! done)
            //     updateFileNLetterBase("Enter verse reference:");
            //g_letterBase.currentGfxIndex(0);
            g_letterBase.setLockAll(true);
            prefix = g_letterBase.count();
            //g_letterBase.currentGfxIndex(1);
        }

        // exit program if set to exit else get user input
        if (done == NO) {
            SDL_SetRenderDrawColor(gRenderer, 0x00, 0x00, 0x00, 0xFF);
            SDL_RenderClear(gRenderer);
            
            g_letterBase.draw(); //gRenderer);

            g_letterBase.doInput(/* ref: */ enterPressed);
            g_letterBase.update(); //#not much
            
            SDL_RenderPresent(gRenderer);
            // gGraph.drawning(); // Swap buffers
            // FPS.rate();

            if (enterPressed) {
                //g_letterBase.addText("\n");
                /+  
                size_t len = g_letterBase.getText.length;
                if (prefix < 0 || prefix >= len) {
                    "whoops..".gh;
                } else { +/
                auto output = g_letterBase.getText[g_letterBase.getText.stripRight.lastIndexOf('\n') + 1 .. $].stripRight;
                if (g_letterBase.getText.length > 0 && output != lastOutPut) {
                    lastOutPut = output;
                    userInput = lastOutPut;

                    jm_upDateStatus(userInput);
                } else {
                    //text("Error with prefix: ", prefix, ", getText: ", g_letterBase.getText.length).gh;
                }
                //}
                
                //auto txt = g_letterBase.getText;
                //userInput = txt[txt.lastIndexOf("\n") + 1 .. $];
            }
        }
        if (userInput.length > 0) {
            import std.string: toLower;

            // If command not used, the user input is treated as thing typed from memory
            // Switch on command
            const args = userInput.split[1 .. $];
            string fileNameTmp;
            if (args.length) {
                try {
                    import std.conv : to;

                    const index = args[0].to!int;
                    if (index >= 0 && index < files.length)
                        fileNameTmp = files[index];
                    else
                        updateFileNLetterBase(fileNameTmp, " index out of bounds");
                } catch(Exception e) {
                    import std.file : exists;
                    import std.path : buildPath;
                    if ((args[0] ~ ".txt").exists)
                        fileNameTmp = args[0] ~ ".txt";
                    else
                        fileNameTmp = buildPath(PROJECTS, args[0] ~ ".txt");
                }
            }
            switch (userInput.split[0].toLower) {
                // Display help
                case "help":
                    updateFileNLetterBase(helpText);
                break;
                case "edit":
                    import std.process : wait, spawnProcess;
                    import std.file : exists;
                    if (g_fileName.exists)
                        wait(spawnProcess(["open", g_fileName]));
                    else
                        updateFileNLetterBase(g_fileName, " not found. Select a project.");
                break;
                case "projects":
                    doProjects(files);
                break;
                case "load":
                    if (args.length != 1) {
                        updateFileNLetterBase("Wrong amount of parameters!");
                        break;
                    }
                    g_fileName = fileNameTmp;
                    loadProject(g_fileName);
                    updateFileNLetterBase(g_fileName, " - project loaded..");
                break;
				case "save":
                    g_fileName = fileNameTmp;
					import std.stdio : File, write;
                    File(g_fileName, "w").write(g_letterBase.getText);
                    updateFileNLetterBase(g_fileName, " - project saved..");
				break;
                case "delete":
                    if (args.length != 1) {
                        updateFileNLetterBase("Wrong amount of parameters!");
                        break;
                    }
                    g_fileName = fileNameTmp;
                    deleteProject(g_fileName);
                break;
                case "cls", "clear":
                    clearScreen;
                    updateFileNLetterBase("Screen cleared..");
                break;
                // quit program
                case "exit", "quit", "command+q", ":q":
                    done = true;
                break;
                default:
                    if (userInput.length) {
                        assert(g_bible, "Bible unallocated!");
                        import std : indexOf, strip;
                        size_t end = userInput.indexOf("->");
                        if (end == -1)
                            end = userInput.length;
                        auto refe = userInput[0 .. end].strip;
                        auto bible = g_bible.argReference(g_bible.argReferenceToArgs(refe)).stripRight;
                        if (bible.length > 2)
                            updateFileNLetterBase(bible);
                    }
                break;
            }
        } // if (userInput.length > 0) {
        if (enterPressed) {
            enterPressed = false;
            userInput.length = 0;
            g_letterBase.setLockAll(true);
            prefix = g_letterBase.count();
        }
        SDL_Delay(2);

        // if (g_global.delay > timer.peek.total!"msecs")
        //     SDL_Delay(cast(uint)(g_global.delay - timer.peek.total!"msecs"));
		// timer.reset;
		// timer.start;

    }
}

/// clear the screen
void clearScreen() {
    g_letterBase.setText("");
}

/// Collect project files
void doProjects(ref string[] files, in bool show = true) {
    import std.file: dirEntries, SpanMode;
    import std.path: buildPath, dirSeparator, stripExtension;
    import std.range: enumerate, array;
    import std.string: split;
    import std : sort, toLower;

    if (show)
        updateFileNLetterBase("File list:");
    files.length = 0;
    foreach(i, string name; dirEntries(buildPath(PROJECTS), "*.{txt}", SpanMode.shallow).array.sort!"a.toLower < b.toLower".enumerate) {
        import std.conv : to;

        if (show)
            updateFileNLetterBase(i, " - ", name[name.indexOf(dirSeparator) + 1 .. $].stripExtension);
        files ~= name;
    }
}

/// Load project
void loadProject(in string fileName) {
    import std : readText, exists;
 
	auto filen = fileName;
	if (filen.exists) {
		g_fileName = fileName;
	    g_letterBase.setText(readText(filen));
	} else
		g_letterBase.addText(" ", filen, " - not found");
}

void deleteProject(in string fileName) {
    import std : remove, exists;
 
	auto filen = fileName;
	if (filen.exists) {
		g_fileName = "";
	    remove(filen);
        g_letterBase.addText(filen, " - deleted\n");
	} else
		g_letterBase.addText(filen, " - not found\n");
}
