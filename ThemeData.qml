import QtQuick 2.15
import SortFilterProxyModel 0.2

import "Logger.js" as Logger

Item {

    // Add an All to the main collections model
    // Dynamically create a ListModel to keep compatability
    property alias collectionsListModel: collectionsListModel

    
    ListModel {
        id: collectionsListModel 

        Component.onCompleted: {
            const collections = api.collections
            const allCollection = {
                name: "All",
                shortName: "All",
                games: api.allGames
            }

            const favCollection = {
                name: "♥ Favorites",
                shortName: "♥ Fav",
                games: api.allGames
            }

            const recentCollection = {
                name: "Recent",
                shortName: "Recent",
                games: api.allGames
            }

            collectionsListModel.append(favCollection)

            if(themeSettings.lastPlayedDays > 0) {
                collectionsListModel.append(recentCollection)
            }

            if (themeSettings.collectionAllGames) {
                collectionsListModel.append(allCollection)
            }

            for (var i=0; i < collections.count; ++i) {
                collectionsListModel.append(collections.get(i))
            }
        }
    }

    property var allGamesModel: {
        return api.allGames;
    }


    property var colorTheme: {
    //don't include ending ff
    //primary - text
    //secondary - none
    //light - secondary text, selected item
    //dark - settings left side background
        "Test": {
            background: "#302442",
            primary: "#7ebcde",
            secondary: "#ffffffff",
            light: "#7ebcde",
            dark: "#302442",
        },
        "Green": {
            background: "#181810",
            primary: "#6bd425",
            secondary: "#618b25",
            light: "#618b25",
            dark: "#181810",
        },
        "Amber": {
            background: "#141514",
            primary: "#E0B700",
            secondary: "#A38500",
            light: "#A38500",
            dark: "#7A6400",
        },
        "Blue": {
            background: "#03071e",
            primary: "#d0dde2",
            secondary: "#d0dde2",
            light: "#b8bcc1",
            dark: "#03071e",
        },
        "Purple": {
            background: "#0b0410",
            primary: "#cc33ff",
            secondary: "#cc33ff",
            light: "#d250ff",
            dark: "#401a61",
        },
        "Vampire": {
            background: "#242631",
            primary: "#a576ce",
            secondary: "#622795ff",
            light: "#7c52a0",
            dark: "#151619ff",
        },
         "Black": {
            background: "#000000",
            primary: "#e9ecef",
            secondary: "#8e8e8eff",
            light: "#6c757d",
            dark: "#000000",
        },
        "White": {
            background: "#ffffff",
            primary: "#323432",
            secondary: "#323432",
            light: "#323432",
            dark: "#cbcdcb",
        },
        "Gray": {
            background: "#2b2b2b",
            primary: "#bfbfbf",
            secondary: "#bfbfbf",
            light: "#a6a6a6",
            dark: "#2b2b2b",
        },
    }

    property var languageNames: {
        "en": "English"
    }

    // Language shortcodes https://www.science.co.il/language/Codes.php
    property var text: {
        "en": {
            "menu_collections": "Games",
            "menu_favorites": "Favorites",
            "menu_lastplayed": "Last Played",
            "menu_settings": "Settings"
        }
    }

    property var font: {
        "HackRegular": ""
    }

}
