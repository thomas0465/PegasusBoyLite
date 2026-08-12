import QtQuick 2.15

Item {
    id: root

    signal achievementsReady()
    signal achievementsError(string reason)

    property string statusMessage: ""
    property bool statusVisible: false

    // Populated on a successful fetch - the UI panel binds to these.
    property string gameTitle: ""
    property var achievementsList: []

    // Derived counts - recompute automatically whenever achievementsList
    // is reassigned (ie. after every fetch).
    property int achievementsTotal: achievementsList.length
    property int achievementsUnlocked: {
        var count = 0
        for (var i = 0; i < achievementsList.length; i++) {
            if (achievementsList[i].DateEarned) { count++ }
        }
        return count
    }

    property var consoleList: null
    property var gameListCache: ({})

    // Each shortname maps to one or more RA console name hints (substring
    // matched, case-insensitive). A shortname with multiple hints checks
    // ALL of those consoles for a matching game title - useful for merged
    // collections like a "Game Boy" folder that actually contains GB, GBC,
    // and GBA games.
    property var consoleNameHints: ({


        "nes": ["nintendo entertainment"],
        "snes": ["super nintendo"],
        "gb": ["game boy"],
        "gbc": ["game boy color"],
        "gba": ["game boy advance"],
        "gameboy": ["game boy", "game boy color", "game boy advance"],
        "n64": ["nintendo 64"],
        "genesis": ["mega drive"],
        "megadrive": ["mega drive"],
        "md": ["mega drive"],
        "mastersystem": ["master system"],
        "psx": ["playstation"],
        "arcade": ["arcade"],
        "homebrew": ["game boy", "game boy color", "game boy advance"],
        "gb hacks": ["game boy", "game boy color", "game boy advance"],
        "nes hacks": ["nintendo entertainment"],
        "nes mario": ["nintendo entertainment"],
        "snes hacks": ["super nintendo"],
        "snes mario": ["super nintendo"],
        "ps1": ["playstation"],
        "n64 hacks": ["nintendo 64"],
        "n64 mario": ["nintendo 64"],
        "n64 zelda": ["nintendo 64"],
        "gcn": ["gamecube"],


    })

    // Manual overrides for titles that don't match automatically. Key is
    // your local Pegasus game title (must match exactly, case-sensitive),
    // value is the title to search for on RA instead.
    property var titleOverrides: ({


        "For Who The Frog Bell Tolls (English Translation)": "Kaeru no Tame ni Kane wa Naru",
        "The Legendary Starfy (Starfy 1 Translation)": "Densetsu no Stafy"


    })

    function fetchAchievementsForGame(game) {
        var searchTitle = titleOverrides[game.title] || game.title

        var shortNames = []
        for (var i = 0; i < game.collections.count; i++) {
            shortNames.push(game.collections.get(i).shortName.toLowerCase())
        }

        checkConsoles(shortNames, searchTitle, function(consoleIds) {
            if (!consoleIds.length) { return }

            tryConsoles(shortNames, consoleIds, 0, searchTitle, function(gameId) {
                if (!gameId) { return }

                fetchGameAchievements(gameId)
            })
        })
    }

    function checkConsoles(shortNames, title, callback) {
        if (consoleList) {
            callback(matchConsoles(shortNames, title))
            return
        }

        var url = "https://retroachievements.org/API/API_GetConsoleIDs.php"
                + "?z=" + themeSettings.raUsername + "&y=" + themeSettings.raApiKey

        getJson(url, function(data) {
            consoleList = data
            callback(matchConsoles(shortNames, title))
        })
    }

    // Returns every console ID that matches any hint for any of the
    // game's shortnames (deduplicated, in match order).
    function matchConsoles(shortNames, title) {
        var ids = []

        for (var i = 0; i < shortNames.length; i++) {
            var hints = consoleNameHints[shortNames[i]] || [shortNames[i]]

            for (var h = 0; h < hints.length; h++) {
                for (var j = 0; j < consoleList.length; j++) {
                    var name = consoleList[j].Name.toLowerCase()
                    if (name.indexOf(hints[h]) === -1) { continue }
                    if (ids.indexOf(consoleList[j].ID) !== -1) { continue }

                    ids.push(consoleList[j].ID)
                    console.log("RA: console candidate for \"" + title + "\": "
                        + consoleList[j].Name + " (ID " + consoleList[j].ID
                        + ") via shortname \"" + shortNames[i] + "\" hint \"" + hints[h] + "\"")
                }
            }
        }

        if (!ids.length) {
            reportError("No console match. Tried: " + shortNames.join(", "))
        }

        return ids
    }

    // Tries each console in order until one has a matching game title.
    function tryConsoles(shortNames, consoleIds, index, title, callback) {
        if (index >= consoleIds.length) {
            reportError("No match for \"" + title + "\". Checked: " + shortNames.join(", "))
            callback(null)
            return
        }

        checkGame(title, consoleIds[index], function(gameId) {
            if (gameId) {
                callback(gameId)
            } else {
                tryConsoles(shortNames, consoleIds, index + 1, title, callback)
            }
        })
    }

    function checkGame(title, consoleId, callback) {
        if (gameListCache[consoleId]) {
            callback(matchGame(title, gameListCache[consoleId], consoleId))
            return
        }

        var url = "https://retroachievements.org/API/API_GetGameList.php"
                + "?y=" + themeSettings.raApiKey + "&i=" + consoleId + "&f=1"

        getJson(url, function(data) {
            gameListCache[consoleId] = data
            callback(matchGame(title, data, consoleId))
        })
    }

    function matchGame(title, list, consoleId) {
        var target = normalize(title)

        for (var i = 0; i < list.length; i++) {
            if (normalize(list[i].Title) === target) {
                console.log("RA: game match for \"" + title + "\" on console " + consoleId
                    + ": " + list[i].Title + " (ID " + list[i].ID + ")")
                return list[i].ID
            }
        }

        console.error("RA: no match for \"" + title + "\" on console " + consoleId + " - checked " + list.length + " games:")
        for (var j = 0; j < list.length; j++) {
            console.log("  - " + list[j].Title)
        }

        return null
    }

    function normalize(title) {
        return title.toLowerCase()
        .replace(/~.*?~/g, "")                             // ignore ~hack~ and ~homebrew~
        .replace(/\(.*?\)/g, "")                           // ignore ()
        .replace(/\[.*?]/g, "")                            // ignore []
        .normalize("NFD").replace(/[\u0300-\u036f]/g, "")  // strip accents 
        .replace(/[^a-z0-9]/g, "")                         // ignore punctuation
    }

    function fetchGameAchievements(gameId) {
        var url = "https://retroachievements.org/API/API_GetGameInfoAndUserProgress.php"
                + "?z=" + themeSettings.raUsername + "&y=" + themeSettings.raApiKey
                + "&g=" + gameId + "&u=" + themeSettings.raUsername

        getJson(url, function(data) {
            if(data.Title == null){
                reportError("Achievements not found for account, check if your Username is correct")
            }
            gameTitle = data.Title
            achievementsList = buildAchievementsList(data)
            achievementsReady()
        })
    }

    function buildAchievementsList(data) {
        var arr = []
        for (var id in data.Achievements) {
            arr.push(data.Achievements[id])
        }

        arr.sort(function(a, b) {
            return (a.DisplayOrder || 0) - (b.DisplayOrder || 0)
        })
        return arr
    }

    function getJson(url, callback) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) { return }

            if (xhr.status !== 200) {
                reportError("Request failed (HTTP " + xhr.status + "). Check your Username and API key")
                return
            }

            callback(JSON.parse(xhr.responseText))
        }
        xhr.onerror = function() {
            reportError("network error")
        }
        xhr.send()
    }

    function reportError(msg) {
        console.error("RA: " + msg)
        showStatus("RA: " + msg)
        achievementsError(msg)
    }

    function showStatus(msg) {
        statusMessage = msg
        statusVisible = true
        statusTimer.restart()
    }

    Timer {
        id: statusTimer
        interval: 4000
        onTriggered: root.statusVisible = false
    }

    Rectangle {
        visible: opacity > 0
        opacity: root.statusVisible ? 1 : 0
        Behavior on opacity { NumberAnimation { duration: 200 } }

        width: statusText.implicitWidth + 40
        height: statusText.implicitHeight + 20
        radius: 4

        anchors {
            bottom: parent.bottom

            bottomMargin: parent.height * 0.03
        }

        color: themeData.colorTheme[theme].light
        border.color: themeData.colorTheme[theme].primary
        border.width: 1
        z: 999

        Text {
            id: statusText
            anchors.centerIn: parent
            text:  root.statusMessage
            font.family: themeSettings.font.customFont
            font.pixelSize: 20 + ( themeSettings.mainFontSize - 20)
            color: themeData.colorTheme[theme].primary
        }
    }
}
