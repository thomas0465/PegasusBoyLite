	// Editable data for the RetroAchievements integration
	// Do not include more than one colon : in the line, put both values on one line

	//Collection Name Override
	//-----------------------------------------------------------------
	//Left value is the collection name to match
	//Right side is the full console name, not case sensitive
	//Check Assets/RetroAchievements Systems.txt for the exact expected system name
	
	import QtQuick 2.15; Item { property string consoleHintsText: "

nes:		nes/famicom
snes:		SNES/Super Famicom
gb:		game boy,game boy color,game boy advance
gbc:		game boy color
gba:		game boy advance
gameboy:	game boy,game boy color,game boy advance
n64:		nintendo 64
genesis:	mega drive
megadrive:	mega drive
md:		mega drive
mastersystem:	master system
psx:		playstation
ps1:		playstation
arcade:		arcade

homebrew:	game boy,game boy color,game boy advance
gb hacks:	game boy,game boy color,game boy advance
nes hacks:	nes/famicom
nes mario:	nes/famicom
snes hacks:	SNES/Super Famicom
snes mario:	SNES/Super Famicom
n64 hacks:	nintendo 64
n64 mario:	nintendo 64
n64 zelda:	nintendo 64
gcn:		gamecube

	
	"
	//Game Title Override
	//-----------------------------------------------------------------
	//left value is the exact file name to match, case sensitive
	//right is the RetroAchievements game name to match
	
	property string titleOverridesText: "

For Who The Frog Bell Tolls (English Translation):	Kaeru no Tame ni Kane wa Naru
The Legendary Starfy (Starfy 1 Translation):		Densetsu no Stafy
The Second Reality Project 2 Reloaded [112 VH]:		The Second Reality Project 2 Reloaded: Zycloboo's Challenge
Zelda Revival (v1.1):					The Legend of Zelda: Zelda Revival
SMB2 - Return to Subcon:				Super Mario Bros. 2 Squared: Return to Subcon
SMB3 - 3Mix:						Super Mario Bros. 3Mix 
Metroid - V I T A L I T Y:				V I T A L I T Y
Peach's Adventure [61 N]:				Super Mario Bros. Peach's Adventure


	"}
