
# soupTrainer
A rhythm game based trainer for fighting games
# Inpiration and Goals
The inspiration for this project comes from tatsunical's [DDR Combo video](https://www.youtube.com/watch?v=6s_KSEVVPp8) for Base Vegeta Loops in Dragonball FighterZ. The idea was to expand on this concept and make a flexible system to achieve the following:

 - Allows users/community to create their own combo files
 - Allow users to browse a local library of combo files to use in this format
 - Make the overlay transparent, such that it can be placed on top of a borderless windowed fighting game, akin to the style shown in the video
 - Add additional combo assistance such as a click track
# Engine Choice
Godot was chosen for this project as it's something I've been meaning to learn to use, and can easily read joypad inputs.

# Using this Software
Grab the most recent release [here](https://github.com/tomatosoupcan/soupTrainer/releases).

To add combos, simply open the application, go to **Settings**, and select **Open Combo Folder**, place your combo .txt files in that folder and select **Reload Combos**. The release zip comes with one sample combo, the same one used in tatsunical's video.

![settings screen](https://i.imgur.com/E5kh8pZ.png)

While you're in the setting screen you may wish to **Bind Keys** as well, and optionally **Disable Click Track**.

Once your combos are loaded and your keys are bound, simply **Return** to the main menu and choose **Select Combo**. Each option on this screen is a dropdown, so simply filter your way to the combo of your choice and **Start**.

![combo selector](https://i.imgur.com/D4TyXtH.png)
And with that you're ready to go, start up your game and place soupTrainer over it. I recommend placing it directly over the game window, then alt-tabbing back into the game. If the always on top setting isn't working, check out [AlwaysOnTopper](https://github.com/ClusterM/AlwaysOnTopper) to force it. It adds an option to the left click icon menu of windows when run:

![alwaysontopper](https://i.imgur.com/Zg7KpCm.png)

Time for some practice mode!
![gameplay!](https://i.imgur.com/CnPRxaX.png)


# Creating Combo Files
Combo files are composed of 5 sections:

 - Game
 - ComboName
 - CharacterName
 - Framerate
 - ComboData

Sections 1-3 are fairly self explanatory, they are used to indicate what filters to assign the combo to, for instance, the sample combo provided has settings:

- Game
	- Dragonball FighterZ
- ComboName
	- Base Vegeta Loops
- Character Name
	- Base Vegeta

Framerate is used to determine the playback speed of the window, i.e how many frames per second there are, this is critical for the ComboData section to playback at the right speed.

ComboData is an array of inputs and frame timings, the available inputs are:

- Left
- Down
- Up
- Right
- L
- LK
- LP
- M
- MK
- MP
- H
- HP
- HK
- S
- 1
- 2
- 3
- 4
- 5

ComboData is stored line by line as elements of an array. So for instance a combo of L and Right on frame 0, followed by M on frame 22 and H on frame 30 would look like this:

    ComboData=[
    [["L","Right"],0],
    [["M"],22],
    [["H"],30]
    ];

A combo text file is composed of all 5 elements together in a text document, separated by semi-colons, here is an example using the ComboData from above:

    Game=SleepFighter3;
    CharacterName=LateNightProgrammer;
    ComboName=Simple String;
    Framerate=60;
    ComboData=[
    [["L","Right"],0],
    [["M"],22],
    [["H"],30]
    ];
Simply save that off as a text file, and drop it to your combo folder, and you're ready to go.

# Future Improvements
In the future I would like to improve usability as well as add a combo recording function, but right now I lack the motivation to get that done. Additionally I'd like to be able to spruce up the visuals a bit, very programmer art at the moment.
