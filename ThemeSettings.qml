import QtQuick 2.15

import "Logger.js" as Logger

// All settings defined here
// Defaults are listed above
Item {
    id: themeSettings

    // property var settingsEnum: {
    //     "theme": theme,
    //     "menuItemCount": menuItemCount,
    //     "collectionItemCount": collectionItemCount
    // }

    // Add settings here to auto load from Pegasus
    property var settingsList: [
        "theme",
	    
        "raUsername",
	"raApiKey",
        "enableRA",

        "lastPlayedDays",
        "itemListRows",
        "itemListWidth",
        "subMenuColumns",
        "subMenuWidth",
        "subMenuHeight",
        "subMenuMargin",
        "subMenuEmptyHeight",
        "language",
        "collectionAllGames",
        "collectionShortNames",
        
        "shaderEnable",
        "shaderCurvatureEnable",
        "shaderCurvatureAmount",
        "shaderScanlinesEnable",
        "shaderScanlinesGrid",
        "shaderScanlinesImageSize",
        "shaderScanlinesOpacity",
        "shaderScanlinesGlow",
        "shaderScanlinesCurve",
        "shaderAberrationEnable",
        "shaderAberrationAmount",
        "shaderGlowEnable",
        "shaderGlowAmount",

        "menuIndex_main",
        "menuIndex_subMenu",
        "menuIndex_subMenu_name",
        "menuIndex_gamesList",
        "menuIndex_gamesList_name",
        "gamesFavoritesOnTop",
        "showClock",
        "showBattery",
        "gamesListCounter",
        "soundslist",
        "soundsmenu",
        "wordwrap",
        "listwrap",
        "subMenuWrap",
        "collectionscroll",
        "footerfontsize",
        "footeroffset",
        "mainFontSize",
        "fontInput",
        "menusize",
        "primaryAsset",
        "menuadjust",
        "replacePar",
	    "backgroundColor",
        "backgroundGradientColor",
        "backgroundGradientInvert"
    ]

    property bool enableRA: false
    property string raUsername: ""
    property string raApiKey: ""


    property string theme: "Black"

    property int settingsVersion: 1

    // Application state

    property int menuIndex_main: 0
    property int menuIndex_subMenu: 0
    property int menuIndex_gamesList: 0
    
    property string menuIndex_subMenu_name: ""
    property string menuIndex_gamesList_name: ""

    // User configurable settings
    property string lastPlayedDays: "0"

    property int itemListRows: 9
    property int itemListWidth: 40

    property int subMenuColumns: 4
    property int subMenuWidth: 55
    property int subMenuHeight: 6
    property int subMenuMargin:0
    property int subMenuEmptyHeight: 6

    property bool collectionAllGames: false
    property bool collectionShortNames: true
    property bool gamesFavoritesOnTop: false

    property bool showClock: true
    property bool showBattery: true
    property bool gamesListCounter: true

    property string language: "en"

    property bool shaderEnable: false
    property bool shaderCurvatureEnable: true
    property int shaderCurvatureAmount: 100
    property bool shaderScanlinesEnable: true
    property bool shaderScanlinesGrid: false
    property int shaderScanlinesImageSize: 180
    property int shaderScanlinesOpacity: 50
    property int shaderScanlinesGlow: 15
    property bool shaderScanlinesCurve: false
    property bool shaderAberrationEnable: true
    property int shaderAberrationAmount: 10
    property bool shaderGlowEnable: true
    property int shaderGlowAmount: 6

    property bool soundslist:true
    property bool soundsmenu:true

    property bool wordwrap:true
    property bool listwrap:true
    property bool subMenuWrap: true
    property bool collectionscroll: true
    property int footerfontsize: 20
    property int footeroffset: 0

    property int menusize: 16
    property string primaryAsset: "Title Screen"
    property int menuadjust: 0

    property bool replacePar: false
    property string fontInput: "Roboto-Regular"
    property int mainFontSize: 20
    property string backgroundColor: "transparent"
    property string backgroundGradientColor: "transparent"
    property bool backgroundGradientInvert: false

    FontLoader {
    id: customFont
    source: "./assets/fonts/" + themeSettings.fontInput +".ttf"
}

property var font: ({
    "customFont": customFont.name
})




    // Try to load the setting if not use default
    function loadSetting(name) {
        var value = api.memory.get(name);
        if (value === undefined) {
            Logger.warn("themeSettings:loadSetting:" + name + ":undefined");
            value = themeSettings[name];
        }
        //Logger.info("themeSettings:loadSetting:" + name + ":value:" + value);
        return value;
    }

    function saveSetting(name, value, type="value") {
        let v = value;
        if (type == "bool") {
            v = (value.toLowerCase() === "enable");
        }
        themeSettings[name] = v;
        api.memory.set(name, v);
        //Logger.info("themeSettings:saveSetting:" + name + ":value:" + v);
        api.memory.set("settingsVersion", settingsVersion);
    }

    function loadAllSettings() {
        for(let i=0; i < settingsList.length; i++) {
            themeSettings[settingsList[i]] = loadSetting(settingsList[i]);
        };
    }

    function saveAllSettings() {
        for(let i=0; i < settingsList.length; i++) {
            saveSetting(settingsList[i], themeSettings[settingsList[i]]);
        }
    }

    // Load settings
    Component.onCompleted: {
        loadAllSettings();
    }

    // Save settings
    Component.onDestruction: {
        saveAllSettings();
    }

}
