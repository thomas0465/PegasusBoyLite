	// Editable data for the RetroAchievements integration
	// Do not include more than one colon : in the line, put both values on one line

	//Collection Name Override
	//-----------------------------------------------------------------
	//Left value is the short name collection name to match
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

homebrew:	game boy,game boy color,game boy advance
gb hacks:	game boy,game boy color,game boy advance
nes hacks:	nes/famicom
nes mario:	nes/famicom
snes hacks:	SNES/Super Famicom
snes mario:	SNES/Super Famicom
n64 hacks:	nintendo 64
n64 mario:	nintendo 64
n64 zelda:	nintendo 64

	
	"
	//Game Title Override
	//-----------------------------------------------------------------
	//left value is the exact file name to match, case sensitive
	//right is the RetroAchievements game name to match
	//replace periods in file names with spaces (ex 'Mario (v2.1)' > 'Mario (v2 1)')
	
	property string titleOverridesText: "

For Who The Frog Bell Tolls (English Translation):	Kaeru no Tame ni Kane wa Naru
The Legendary Starfy (Starfy 1 Translation):		Densetsu no Stafy
The Second Reality Project 2 Reloaded [112 VH]:		The Second Reality Project 2 Reloaded: Zycloboo's Challenge
Zelda Revival (v1 1):					The Legend of Zelda: Zelda Revival
SMB2 - Return to Subcon:				Super Mario Bros. 2 Squared: Return to Subcon
SMB3 - 3Mix:						Super Mario Bros. 3Mix 
Metroid - V I T A L I T Y:				V I T A L I T Y
Peach's Adventure [61 N]:				Super Mario Bros. Peach's Adventure
A Link to the Past - Allhallows Eve:			The Legend of Zelda: Allhallow's Eve
Pokemon Mariomon (v1 5 2):				Super Mariomon

	"}
