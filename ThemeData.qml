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
    //secondary - unselected right side settings option
    //light - secondary text, selected item
    //dark - settings right side background
        "Green": {
            background: "#181810",
            primary: "#6bd425",
            secondary: "#497e00",
            light: "#67a50f",
            dark: "#181810",
        },
        "Amber": {
            background: "#141514",
            primary: "#E0B700",
            secondary: "#A38500",
            light: "#A38500",
            dark: "#7A6400",
        },
        "Dark Blue": {
            background: "#03071e",
            primary: "#d0dde2",
            secondary: "#a4afbdff",
            light: "#a4afbdff",
            dark: "#03071e",
        },
        "Light Blue": {
            background: "#302442",
            primary: "#7ebcde",
            secondary: "#3e7d9f",
            light: "#7ebcde",
            dark: "#302442",
        },
        "Purple": {
            background: "#0b0410",
            primary: "#d250ff",
            secondary: "#6d2087",
            light: "#d250ff",
            dark: "#401a61",
        },
        "Vampire": {
            background: "#242631",
            primary: "#a576ce",
            secondary: "#7c52a0",
            light: "#7c52a0",
            dark: "#151619ff",
        },         
        
        "Binary": {
            background: "#000000",
            primary: "#e9ecef",
            secondary: "#6c757d",
            light: "#e9ecef",
            dark: "#000000",
        },
         "Black": {
            background: "#000000",
            primary: "#e9ecef",
            secondary: "#6c757d",
            light: "#6c757d",
            dark: "#000000",
        },
        "White": {
            background: "#ffffff",
            primary: "#323432",
            secondary: "#858585",
            light: "#323432",
            dark: "#cbcdcb",
        },
        "Gray": {
            background: "#2b2b2b",
            primary: "#bfbfbf",
            secondary: "#6d6d6d",
            light: "#bfbfbf",
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


}
