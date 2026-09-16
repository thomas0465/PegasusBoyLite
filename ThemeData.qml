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
        "background": "#0d0208",
        "primary": "#00ff41",
        "secondary": "#008f11",
        "light": "#00ff41",
        "dark": "#0d0208"
    },
    "Amber": {
        "background": "#141514",
        "primary": "#E0B700",
        "secondary": "#A38500",
        "light": "#A38500",
        "dark": "#7A6400"
    },
    "Light Blue": {
        "background": "#6b9aa9",
        "primary": "#001261",
        "secondary": "#a4afbd",
        "light": "#001261",
        "dark": "#6b9aa9"
    },
    "Dark Blue": {
        "background": "#063d3b",
        "primary": "#7ebcde",
        "secondary": "#3e7d9f",
        "light": "#7ebcde",
        "dark": "#302442"
    },
    "Purple": {
        "background": "#0b0410",
        "primary": "#d250ff",
        "secondary": "#6d2087",
        "light": "#d250ff",
        "dark": "#401a61"
    },
    "Vampire": {
        "background": "#282a36",
        "primary": "#bd93f9",
        "secondary": "#6272a4",
        "light": "#bd93f9",
        "dark": "#282a36"
    },
    "Black": {
        "background": "#000000",
        "primary": "#e9ecef",
        "secondary": "#6c757d",
        "light": "#e9ecef",
        "dark": "#000000"
    },
    "White": {
        "background": "#ffffff",
        "primary": "#000000",
        "secondary": "#858585",
        "light": "#000000",
        "dark": "#cbcdcb"
    },
    "Gray": {
        "background": "#292929",
        "primary": "#949494",
        "secondary": "#bcbcbc",
        "light": "#949494",
        "dark": "#292929"
    },
    "Game Boy": {
        "background": "#8b956d",
        "primary": "#303424",
        "secondary": "#78815c",
        "light": "#525a37",
        "dark": "#2b2b2b"
    },

    "Red": {
        "background": "#1a0f0f",
        "primary": "#ff4444",
        "secondary": "#a02c2c",
        "light": "#ff4444",
        "dark": "#1a0f0f"
    },
    "Sepia": {
        "background": "#3a2e22",
        "primary": "#e8d5b7",
        "secondary": "#a8896a",
        "light": "#e8d5b7",
        "dark": "#3a2e22"
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
