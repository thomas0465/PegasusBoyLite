import QtQuick 2.15

import "../../Logger.js" as Logger

Item {

    // Each settings needs a type and value
    // The rendering and options available depend on
    // the type of setting
    // id: Matches to the relevant themeSettings value
    // types:
    //   - list
    //   - bool
    //   - range (min, max, step)
    // TODO Change this to a list model
    property var settingsModel: [
        {
            "name": "General",
            "settings": [
                // {
                //     "name": "Language",
                //     "id": "language",
                //     "description": "Change the theme's language",
                //     "type": "list",
                //     "default": "en",
                //     "options": ["en"],
                // },
                {
                    "name": "Theme",
                    "id": "theme",
                    "description": "Color theme",
                    "type": "list",
                    "default": "Black",
                    "options": [
                        { "value": "White" },
                        { "value": "Gray" },
                        { "value": "Black" },
                        { "value": "Green" },
                        { "value": "Amber" },
                        { "value": "Blue" },
                        { "value": "Purple" },
            			{ "value": "Vampire" },
                        { "value": "Test"}
                    ]
                },

                {
                    "name": "Sounds - Menu",
                    "id": "soundsmenu",
                    "description": "Enable sounds when navigating the Menu and favoriting games",
                    "type": "bool",
                    "default": "Enabled",
                },
                {
                    "name": "Sounds - Main List",
                    "id": "soundslist",
                    "description": "Enable sounds when navigating the Main List",
                    "type": "bool",
                    "default": "Enabled",
                },
                {
                    "name": "Show All Games",
                    "id": "collectionAllGames",
                    "description": "Show All games collection in the games list (may require restart)",
                    "type": "bool",
                    "default": "Disable",
                },
                {
                    "name": "Last Played Range",
                    "id": "lastPlayedDays",
                    "description": "How many days to show games on the recent list. Select 0 to disable (may require restart)",
                    "type": "list",
                    "default": "30",
                    "options": [
                        { "value": "0" },
			{ "value": "1" },
                        { "value": "3" },
                        { "value": "7" },
                        { "value": "14" },
 			{ "value": "30" },
                    ]
                },

                {
                    "name": "Primary Asset",
                    "id": "primaryAsset",
                    "description": "Show Title Screen or Box Art first",
                    "type": "list",
                    "default": "Title Screen",
                    "options": [
			{ "value": "Title Screen" },
                        { "value": "Box Art" },
                    ]
                },
                {
                    "name": "Collection Short Names",
                    "id": "collectionShortNames",
                    "description": "Use collection short names",
                    "type": "bool",
                    "default": "Disable",
                },

                {
                    "name": "Collection Scroll Bar",
                    "id": "collectionscroll",
                    "description": "Show the small Scroll Bar next to the Sub-Menu for collections",
                    "type": "bool",
                    "default": "Enable",
               },

                {
                    "name": "Favorites on Top",
                    "id": "gamesFavoritesOnTop",
                    "description": "Show favorites at the top of the Main List",
                    "type": "bool",
                    "default": "Disable",
                },

                {
                    "name": "Remove Text in ()",
                    "id": "replacePar",
                    "description": "Remove text in parenthises when showing game names",
                    "type": "bool",
                    "default": "Disable",
                },
               {
                   "name": "Word Wrap",
                   "id": "wordwrap",
                   "description": "Wrap long game names in the Main List",
                   "type": "bool",
                   "default": "Disable",
                },

            ]
        },
        {
            "name": "Layout",
            "settings": [

                {
		    "name": "Sub-Menu Font Size",
                    "id": "menusize",
                    "description": "The font size for the Sub-Menu",
                    "type": "range",
                    "default": "16",
                    "min": 10,
                    "max": 25,
                    "step": 1,
                },

                {
		    "name": "Height Adjust",
                    "id": "menuadjust",
                    "description": "Adjust the screen to be closer to the top of the screen",
                    "type": "range",
                    "default": "0",
                    "min": -25,
                    "max": 5,
                    "step": 1,
                },

                {
                    "name": "Main List - Rows",
                    "id": "itemListRows",
                    "description": "The number of rows to show on the Main List",
                    "type": "range",
                    "default": "9",
                    "min": 4,
                    "max": 12,
                    "step": 1,
                },
                {
                    "name": "Main List - Width",
                    "id": "itemListWidth",
                    "description": "The width of the Main List as a percentage of the screen",
                    "type": "range",
                    "default": "40",
                    "min": 35,
                    "max": 65,
                    "step": 5,
                },
                {
                    "name": "Sub-Menu - Columns",
                    "id": "subMenuColumns",
                    "description": "The number of Sub-Menu items to show on screen",
                    "type": "range",
                    "default": "4",
                    "min": 3,
                    "max": 8,
                    "step": 1,
                },
                //{
                //    "name": "Sub-Menu - Width",
                //    "id": "subMenuWidth",
                //    "description": "The percentage of width of the screen to define the width of the Sub-Menu",
                //    "type": "range",
                //    "default": "55",
                //    "min": 40,
                //    "max": 90,
                //    "step": 5,
                //},
                {
                    "name": "Sub-Menu - Height",
                    "id": "subMenuHeight",
                    "description": "The height of the Sub-Menu",
                    "type": "range",
                    "default": "6",
                    "min": 4,
                    "max": 12,
                    "step": 1,
                },
                {
                    "name": "Sub-Menu - Margin",
                    "id": "subMenuMargin",
                    "description": "The margin between the Main List and Sub-Menu",
                    "type": "range",
                    "default": "2",
                    "min": -2,
                    "max": 5,
                    "step": 1,
                },
                //{
                //    "name": "Sub-Menu - Empty Height",
                //    "id": "subMenuEmptyHeight",
                //    "description": "The margin between the Main List and Menu when there is no Sub-Menu",
                //    "type": "range",
                //    "default": "6",
                //    "min": 0,
                //    "max": 12,
                //    "step": 1,
                //},

            ]
        },

        {
            "name": "Footer",
            "visible": false,
            "settings": [

                {
		    "name": "Footer Font Size",
                    "id": "footerfontsize",
                    "description": "The font size for the Footer",
                    "type": "range",
                    "default": "20",
                    "min": 10,
                    "max": 25,
                    "step": 1,
                },
                
                {
                    "name": "Show Clock",
                    "id": "showClock",
                    "description": "Display the time",
                    "type": "bool",
                    "default": "Enable",
               },
                {
                    "name": "Show Counter",
                    "id": "gamesListCounter",
                    "description": "Display a counter in the games list",
                    "type": "bool",
                    "default": "Enable",
               },

                {
                    "name": "Show Battery",
                    "id": "showBattery",
                    "description": "Display the Battery Percentage",
                    "type": "bool",
                    "default": "Enable",
               },

		]
	},
        {
            "name": "Shaders",
            "visible": false,
            "settings": [
                {
                    "name": "Shaders - Global",
                    "id": "shaderEnable",
                    "description": "Enable or disable shaders",
                    "type": "bool",
                    "default": "Enable",
                },
                {
                    "name": "Curvature - Enable",
                    "id": "shaderCurvatureEnable",
                    "description": "Enable the screen curvature shader",
                    "type": "bool",
                    "default": "Enable",
                },
                {
		    "name": "Curvature - Amount",
                    "id": "shaderCurvatureAmount",
                    "description": "The intensity of the screen curvature",
                    "type": "range",
                    "default": "100",
                    "min": 40,
                    "max": 300,
                    "step": 20,
                },
                {
                    "name": "Scanlines - Enable",
                    "id": "shaderScanlinesEnable",
                    "description": "Enable the scanline shader",
                    "type": "bool",
                    "default": "Enable",
                },
                {
                    "name": "Scanlines - Distance",
                    "id": "shaderScanlinesImageSize",
                    "description": "The distance between scanlines",
                    "type": "range",
                    "default": "180",
                    "min": 100,
                    "max": 240,
                    "step": 1,

                }
            ]
        }
    ]

    property alias settingsListModel: settingsListModel
    ListModel {
        id: settingsListModel

        Component.onCompleted: {
            settingsModel.forEach((x) => {
                settingsListModel.append(x);
            })
            
            Logger.info("SettingsOptionsModel:settingsListModel:count:" + settingsListModel.count)
            Logger.info("SettingsOptionsModel:settingsListModel:element:" + settingsListModel.get(0).name)
        }
    }

}
