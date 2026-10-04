// Editable data for the RetroAchievements system and game name overrides
// Use : to seperate values, 1 key value pair per line


//-----------------------------------------------------------------
//Collection Name Override
//-----------------------------------------------------------------
	//Left value is the collection short name to match
	//Right side is the full console name, not case sensitive
	//Check Assets/RetroAchievements Systems.txt for the exact expected system name
	
	import QtQuick 2.15; Item { property string consoleHintsText: "

nes:		nes/famicom
snes:		SNES/Super Famicom
n64:		nintendo 64
64:		nintendo 64
gc:		gamecube
gcn:		gamecube
ngc:		gamecube
wii:		wii
wiiu		Wii U
gb:		game boy,game boy color,game boy advance
gbc:		game boy color
gba:		game boy advance
gameboy:	game boy,game boy color,game boy advance
DS:		Nintendo DS
NDS:		Nintendo DS
DSi:		Nintendo DSi
3DS:		Nintendo 3DS
pokemon_mini:	Pokemon Mini
mini:		Pokemon Mini
VB:		Virtual Boy
virtualboy:	Virtual Boy

atari2600:	Atari 2600
2600:		Atari 2600
atari5200:	Atari 5200
5200:		Atari 5200
atari7800:	Atari 7800
7800:		Atari 7800
atarilynx:	Atari Lynx
lynx:		Atari Lynx
atarijaguar:	Atari Jaguar
jaguar:		Atari Jaguar
atariST:	Atari ST
ST:		Atari ST

mastersystem:	master system
ms:		master system
genesis:	mega drive, Sega CD, 32X
megadrive:	mega drive, Sega CD, 32X
md:		mega drive, Sega CD, 32X
SCD:		Sega CD
DC:		dreamcast
Pico:		Sega Pico
GG: 		Game Gear

ps:		playstation
psx:		playstation
ps1:		playstation
ps2:		playstation 2
ps3:		playstation 3
psp:		playstation portable

arcade:		arcade
mega_duck:	mega duck
neo_geo_pocket: Neo Geo Pocket
C64:		Commodore 64
CDI:		Philips CD-i
3DO:		3DO Interactive Multiplayer
NGage:		Nokia N-Gage
N-Gage:		Nokia N-Gage
wasm4:		WASM-4

HiddenGB:		game boy,game boy color
HiddenGBA:		game boy advance
HiddenNES:		nes/famicom
HiddenSNES:		SNES/Super Famicom
HiddenGenesis:		mega drive
HiddenSegaCD:		Sega CD
HiddenGBHomebrew:	game boy,game boy color
HiddenGBAHomebrew:	game boy advance
HiddenNESHomebrew:	nes/famicom
HiddenSNESHomebrew:	SNES/Super Famicom
HiddenGBHacks:		game boy,game boy color
HiddenGBAHacks:		game boy advance
HiddenNESHacks:		nes/famicom
HiddenSNESHacks:	SNES/Super Famicom
HiddenNESMarioHacks:	nes/famicom
HiddenSNESMarioHacks:	SNES/Super Famicom
HiddenN64:		nintendo 64
HiddenPS1:		playstation
HiddenN64Hacks:		nintendo 64
HiddenN64MarioHacks:	nintendo 64
HiddenN64ZeldaHacks:	nintendo 64
HiddenGamecube:		gamecube
HiddenPS2:		ps2
HiddenDreamcast:	dreamcast	
"


//-----------------------------------------------------------------
//Game Title Override
//-----------------------------------------------------------------
	//left value is the exact file name to match without file type extension, case sensitive
	//right is the RetroAchievements game name to match
	//replace periods in file names with spaces for example 'Mario (v2.1)' to 'Mario (v2 1)'
	
	property string titleOverridesText: "

For Who The Frog Bell Tolls (English Translation):	Kaeru no Tame ni Kane wa Naru
The Legendary Starfy (Starfy 1 Translation):		Densetsu no Stafy

SMB2 - Return to Subcon:				Super Mario Bros. 2 Squared: Return to Subcon
SMB3 - 3Mix:						Super Mario Bros. 3Mix 

Metroid - V I T A L I T Y:				V I T A L I T Y
Metroid - Hyper Metroid:				Hyper Metroid

A Link to the Past - Allhallows Eve:			The Legend of Zelda: Allhallow's Eve
A Link to the Past - Parallel Worlds:			The Legend of Zelda: Parallel Worlds

Zelda Revival (v1 1):					The Legend of Zelda: Zelda Revival

Pokemon Mariomon (v1 5 2):				Super Mariomon

1st RetroAchievements Vanilla Level Design Contest [41 H] (v1 0): RetroAchievements Vanilla Level Design Contest Vol. 1
11th Vanilla Level Design Contest [116 H] (1 4):	The 11th Annual Vanilla Level Design Contest
Peach's Adventure [61 N]:				Super Mario Bros. Peach's Adventure
The Second Reality Project 2 Reloaded [112 VH]:		The Second Reality Project 2 Reloaded: Zycloboo's Challenge
K-16 [25 H] (v1 3):					K-16: Story of Steel




	"}
