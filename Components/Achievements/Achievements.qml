import QtQuick 2.15

Item {
    id: achRoot

    signal achievementsReady()
    signal achievementsError(string reason)

    property string statusMessage: ""
    property bool statusVisible: false

    property string gameTitle: ""
    property string imageIcon: ""
    property var achievementsList: []

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

    // Tracks every ra_gameid_*/ra_cache_* key
    property var cacheKeys: []

    Component.onCompleted: {
        var stored = api.memory.get("ra_cache_index")
        if (stored) {
            try { cacheKeys = JSON.parse(stored) } catch (e) { cacheKeys = [] }
        }
    }

    function trackCacheKey(key) {
        if (cacheKeys.indexOf(key) === -1) {
            cacheKeys.push(key)
            api.memory.set("ra_cache_index", JSON.stringify(cacheKeys))
        }
    }

    // Clears every tracked cache entry.
    function clearCache() {
        var stored = api.memory.get("ra_cache_index")
        var keys = []
        if (stored) {
            try { keys = JSON.parse(stored) } catch (e) { keys = [] }
        }

        for (var i = 0; i < keys.length; i++) {
            api.memory.set(keys[i], "")
        }
        api.memory.set("ra_cache_index", JSON.stringify([]))

        cacheKeys = []
        consoleList = null
        gameListCache = {}

        showStatus("RA: Cache cleared (" + keys.length + " entries)")
    }

    // Each shortname maps to one or more full RA console names, use game consoles file in /assets for full names
    property var consoleNameHints: ({


        "nes": ["nes/famicom"],
        "snes": ["SNES/Super Famicom"],
        "gb":["game boy", "game boy color", "game boy advance"],
        "gbc": ["game boy color"],
        "gba": ["game boy advance"],
        "gameboy": ["game boy", "game boy color", "game boy advance"],
        "n64": ["nintendo 64"],
        "genesis": ["mega drive"],
        "megadrive": ["mega drive"],
        "md": ["mega drive"],
        "mastersystem": ["master system"],
        "psx": ["playstation"],
        "ps1": ["playstation"],
        "arcade": ["arcade"],


        "homebrew": ["game boy", "game boy color", "game boy advance"],
        "gb hacks": ["game boy", "game boy color", "game boy advance"],
        "nes hacks": ["nes/famicom"],
        "nes mario": ["nes/famicom"],
        "snes hacks": ["SNES/Super Famicom"],
        "snes mario": ["SNES/Super Famicom"],
        "n64 hacks": ["nintendo 64"],
        "n64 mario": ["nintendo 64"],
        "n64 zelda": ["nintendo 64"],
        "gcn": ["gamecube"],


    })

    // Manual overrides for titles that don't match automatically.
    property var titleOverrides: ({


        "For Who The Frog Bell Tolls (English Translation)": "Kaeru no Tame ni Kane wa Naru",
        "The Legendary Starfy (Starfy 1 Translation)": "Densetsu no Stafy",
	"The Second Reality Project 2 Reloaded [112 VH]": "The Second Reality Project 2 Reloaded: Zycloboo's Challenge"


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

                api.memory.set("ra_gameid_" + searchTitle, gameId)
                trackCacheKey("ra_gameid_" + searchTitle)
                fetchGameAchievements(gameId)
            }, function(reason) {
                offlineFallback(searchTitle, reason)
            })
        }, function(reason) {
            offlineFallback(searchTitle, reason)
        })
    }

    // No network / a lookup step failed - fallback
    function offlineFallback(searchTitle, reason) {
        var gameId = api.memory.get("ra_gameid_" + searchTitle)
        if (!gameId) {
            showStatus(reason)
            return
        }

        useCachedAchievements(gameId, reason)
    }

    function checkConsoles(shortNames, title, callback, onError) {
        if (consoleList) {
            callback(matchConsoles(shortNames, title))
            return
        }

        var url = "https://retroachievements.org/API/API_GetConsoleIDs.php"
                + "?z=" + themeSettings.raUsername + "&y=" + themeSettings.raApiKey

        getJson(url, function(data) {
            consoleList = data
            callback(matchConsoles(shortNames, title))
        }, onError)
    }

    // Returns every console ID that matches any hint
    function matchConsoles(shortNames, title) {
        var ids = []
        var hintsTried = []

        for (var i = 0; i < shortNames.length; i++) {
            var hints = consoleNameHints[shortNames[i]]

            for (var h = 0; h < hints.length; h++) {
                hintsTried.push(hints[h])

                for (var j = 0; j < consoleList.length; j++) {
                    if (consoleList[j].Name.toLowerCase() !== hints[h].toLowerCase()) { continue }
                    
                    //unneeded check if game is in multiple collections
                    //if (ids.indexOf(consoleList[j].ID) !== -1) { continue }

                    ids.push(consoleList[j].ID)
                    //console.log("RA: console candidate for \"" + title + "\": "
                    //    + consoleList[j].Name + " (ID " + consoleList[j].ID
                    //    + ") via shortname \"" + shortNames[i] + "\" hint \"" + hints[h] + "\"")
                }
            }
        }

        if (!ids.length) {
            showStatus("No console match. Tried: " + hintsTried.join(", "))
        }

        return ids
    }

    // Looks up the RA console names for a set of already-resolved console
    // IDs, for use in status/error messages.
    function consoleNamesForIds(ids) {
        var names = []
        for (var i = 0; i < ids.length; i++) {
            for (var j = 0; j < consoleList.length; j++) {
                if (consoleList[j].ID === ids[i]) {
                    names.push(consoleList[j].Name)
                    break
                }
            }
        }
        return names
    }

    // Tries each console in order until one has a matching game title.
    function tryConsoles(shortNames, consoleIds, index, title, callback, onError) {
        if (index >= consoleIds.length) {
            showStatus("No match for \"" + title + "\". Checked: " + consoleNamesForIds(consoleIds).join(", "))
            callback(null)
            return
        }

        checkGame(title, consoleIds[index], function(gameId) {
            if (gameId) {
                callback(gameId)
            } else {
                tryConsoles(shortNames, consoleIds, index + 1, title, callback, onError)
            }
        }, onError)
    }

    function checkGame(title, consoleId, callback, onError) {
        if (gameListCache[consoleId]) {
            callback(matchGame(title, gameListCache[consoleId], consoleId))
            return
        }

        var url = "https://retroachievements.org/API/API_GetGameList.php"
                + "?y=" + themeSettings.raApiKey + "&i=" + consoleId + "&f=1"

        getJson(url, function(data) {
            gameListCache[consoleId] = data
            callback(matchGame(title, data, consoleId))
        }, onError)
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
	//list game names checked in logs
        //for (var j = 0; j < list.length; j++) {
        //    console.log("  - " + list[j].Title)
        //}

        return null
    }

    function normalize(title) {
        return title.toLowerCase()
        .replace(/~.*?~/g, "")                             // ignore ~hack~ and ~homebrew~
        .replace(/\(.*?\)/g, "")                           // ignore ()
        .replace(/\[.*?\]/g, "")                           // ignore []
        .normalize("NFD").replace(/[\u0300-\u036f]/g, "")  // strip accents 
        .replace(/[^a-z0-9]/g, "")                         // ignore punctuation
        .replace(/SMB.* - /g, "")                          // replace 'SMB -', 'SMB2 -', etc
    }

    function fetchGameAchievements(gameId) {
        var url = "https://retroachievements.org/API/API_GetGameInfoAndUserProgress.php"
                + "?z=" + themeSettings.raUsername + "&y=" + themeSettings.raApiKey
                + "&g=" + gameId + "&u=" + themeSettings.raUsername

        getJson(url, function(data) {
            if(data.Title == null){
                showStatus("RA: Achievements not found for account, check if your Username is correct")
                return
            }
            gameTitle = data.Title
            imageIcon = data.ImageIcon
            console.log("data: " + imageIcon)
            achievementsList = buildAchievementsList(data)
            api.memory.set("ra_cache_" + gameId, JSON.stringify(data))
            trackCacheKey("ra_cache_" + gameId)
            achievementsReady()
        }, function(reason) {
            useCachedAchievements(gameId, reason)
        })
    }

    // Falls back to the last successfully-fetched payload for this game ID,
    // saved via api.memory. Used when a fetch fails (offline, RA down, etc).
    function useCachedAchievements(gameId, reason) {
        var cached = api.memory.get("ra_cache_" + gameId)
        if (!cached) {
            showStatus(reason)
            return
        }

        var data = JSON.parse(cached)
        gameTitle = data.Title
        imageIcon = data.ImageIcon
        achievementsList = buildAchievementsList(data)
        showStatus("RA: Offline - Showing cached achievements")
        achievementsReady()
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

    function getJson(url, callback, onError) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) { return }

            if (xhr.status !== 200) {
                var reason = "Request failed (HTTP " + xhr.status + "). Check your Username and API key"
                if (onError) { onError(reason) } else { showStatus(reason) }
                return
            }

            callback(JSON.parse(xhr.responseText))
        }
        xhr.onerror = function() {
            if (onError) { onError("network error") } else { showStatus("No online connection") }
        }
        xhr.send()
    }

    function showStatus(msg) {
        statusMessage = msg
        statusVisible = true
        statusTimer.restart()
    }

    Timer {
        id: statusTimer
        interval: 4000
        onTriggered: achRoot.statusVisible = false
    }

    Rectangle {
        visible: opacity > 0
        opacity: achRoot.statusVisible ? 1 : 0
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }

        anchors {
            left: achRoot.left
            bottom: parent.bottom

            leftMargin: (parent.width * 100 / themeSettings.itemListWidth) * .01
            rightMargin: (parent.width * 100 / themeSettings.itemListWidth) * .01
            bottomMargin: parent.height * 0.03
        }

        height: statusText.implicitHeight + 20
        width: Math.min( parent.width * 100 / themeSettings.itemListWidth - (parent.width * 100 / themeSettings.itemListWidth) * .1,  statusText.implicitWidth + (parent.width * 100 / themeSettings.itemListWidth) * .02)

        color: themeData.colorTheme[theme].secondary
        border.color: themeData.colorTheme[theme].primary
        border.width: 1
        z: 999

        Text {
            id: statusText

            anchors {
                left: parent.left
                right: parent.right
                verticalCenter: parent.verticalCenter

                //leftMargin: (parent.width * 100 / themeSettings.itemListWidth) * .005
                //rightMargin: (parent.width * 100 / themeSettings.itemListWidth) * .005
            }

            text: achRoot.statusMessage
            font.family: themeSettings.font.customFont
            font.pixelSize: achRoot.height / 22
                            + (themeSettings.mainFontSize - 20)

            color: themeData.colorTheme[theme].primary
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
