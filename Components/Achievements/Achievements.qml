import QtQuick 2.15

import "../../assets"

Item {
    id: achRoot

    signal achievementsReady()
    signal achievementsError(string reason)

    property string statusMessage: ""
    property bool statusVisible: false

    property string gameTitle: ""
    property string imageIcon: ""
    property var achievementsList: []

    property var subsetsList: []          // [{id, title}], base game always first
    property int currentSubsetIndex: 0

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

    //--------------------------------------------------------------------
    //overrides from the achievementsconfig file
    AchievementsConfig {
        id: achievementsConfig
    }
    property var consoleNameHints: parseOverrides(achievementsConfig.consoleHintsText,true)
    property var titleOverrides: parseOverrides(achievementsConfig.titleOverridesText,false)

    function parseOverrides(text, toLower) {
        var result = {}
        var entries = []

        //split lines from text and populate entries
        var lines = text.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (!line) { continue }

            var sep = line.indexOf(":")
            if (sep === -1) { continue }

            entries.push({
                key: line.substring(0, sep).trim(),
                value: line.substring(sep + 1).trim()
            })
        }

        //convert entries to values
        for (var i = 0; i < entries.length; i++) {

            var values = entries[i].value.split(",")
            for (var j = 0; j < values.length; j++) {
                values[j] = values[j].trim()
            }
            
            if(toLower){
                result[entries[i].key.toLowerCase()] = values
            }else{
                result[entries[i].key] = entries[i].value
            }
        }
        return result
    }

    //--------------------------------------------------------------------
    //track cached keys
    function trackCacheKey(key) {
        if (cacheKeys.indexOf(key) === -1) {
            cacheKeys.push(key)
            api.memory.set("ra_cache_index", JSON.stringify(cacheKeys))
        }
    }

    //--------------------------------------------------------------------
    // Clears every tracked cached game entry from the pegasus settings data.
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

        showStatus("Cache cleared, deleted " + keys.length + " entries")
    }

    //--------------------------------------------------------------------
    //Start of getting achievements and progress data
    function fetchAchievementsForGame(game) {
        var searchTitle = titleOverrides[game.title] || game.title

        var shortNames = []
        for (var i = 0; i < game.collections.count; i++) {
            shortNames.push(game.collections.get(i).shortName.toLowerCase())
        }

        // Shared failure path: a lookup step failed fall back to whatever we last cached for this title.
        var onFail = function(reason) {
            loadCachedAchievements(api.memory.get("ra_gameid_" + searchTitle), reason)
        }

        resolveConsoleIds(shortNames, function(consoleIds) {
            if (!consoleIds.length) { return }

            tryConsoles(consoleIds, 0, searchTitle, function(gameId) {
                if (!gameId) { return }

                api.memory.set("ra_gameid_" + searchTitle, gameId)
                trackCacheKey("ra_gameid_" + searchTitle)
                fetchGameAchievements(gameId)
            }, onFail)
        }, onFail)
    }

    // Fetches (or reuses the cached) console list, then returns every
    // console ID that matches one of the collection's configured hints.
    function resolveConsoleIds(shortNames, callback, onError) {
        var matchConsoles = function() {
            var ids = []
            var hintsTried = []

            for (var i = 0; i < shortNames.length; i++) {
                var hints = consoleNameHints[shortNames[i]]

                if (!hints) {
                    hintsTried.push(shortNames[i] + " (no override configured)")
                    continue
                }

                for (var h = 0; h < hints.length; h++) {
                    hintsTried.push(hints[h])

                    for (var j = 0; j < consoleList.length; j++) {
                        if (consoleList[j].Name.toLowerCase() !== hints[h].toLowerCase()) { continue }
                        ids.push(consoleList[j].ID)
                    }
                }
            }

            if (!ids.length) {
                showStatus("No console match for " + hintsTried.join(", "))
            }

            return ids
        }

        if (consoleList) {
            callback(matchConsoles())
            return
        }

        var url = "https://retroachievements.org/API/API_GetConsoleIDs.php"
                + "?z=" + themeSettings.raUsername + "&y=" + themeSettings.raApiKey

        getJson(url, function(data) {
            consoleList = data
            callback(matchConsoles())
        }, onError)
    }

    // Tries each console in order
    function tryConsoles(consoleIds, index, title, callback, onError) {
        if (index >= consoleIds.length) {
            var names = []
            for (var n = 0; n < consoleIds.length; n++) {
                for (var m = 0; m < consoleList.length; m++) {
                    if (consoleList[m].ID === consoleIds[n]) { names.push(consoleList[m].Name); break }
                }
            }

            showStatus("\"" +
                title
                .replace(/\(.*?\)/g, "")
                .replace(/\[.*?\]/g, "")
                .replace(/[ \t]+$/g, "")
                //remove () and [] on displayed title
                + "\" not found. Tried " + names.join(", "))
            callback(null)
            return
        }

        var consoleId = consoleIds[index]

        function matchGame(list) {
            var target = normalize(title)
            for (var i = 0; i < list.length; i++) {
                if (normalize(list[i].Title) === target) {
                    buildSubsetsList(list[i], list)
                    return list[i].ID
                }
            }
            //console.error("No match for \"" + title + "\" on console " + consoleId + ". checked " + list.length + " games")
            return null
        }

        function buildSubsetsList(baseEntry, list) {
            var subsets = [{ id: baseEntry.ID, title: baseEntry.Title }]

            for (var i = 0; i < list.length; i++) {
                if (list[i].ID === baseEntry.ID) { continue }
                if (list[i].Title.indexOf(baseEntry.Title) === 0 && list[i].Title.indexOf("[Subset") !== -1) {
                    subsets.push({ id: list[i].ID, title: list[i].Title })
                }
            }

            subsetsList = subsets
            currentSubsetIndex = 0
        }

        var onGameList = function(list) {
            var gameId = matchGame(list)
            if (gameId) {
                callback(gameId)
            } else {
                tryConsoles(consoleIds, index + 1, title, callback, onError)
            }
        }

        if (gameListCache[consoleId]) {
            onGameList(gameListCache[consoleId])
            return
        }

        var url = "https://retroachievements.org/API/API_GetGameList.php"
                + "?y=" + themeSettings.raApiKey + "&i=" + consoleId + "&f=1"

        getJson(url, function(data) {
            gameListCache[consoleId] = data
            onGameList(data)
        }, onError)
    }

    function normalize(title) {
        return title.toLowerCase()
        .replace(/~.*?~/g, "")                             // ignore ~hack~ and ~homebrew~
        .replace(/smb.* - /g, "")                          // replace 'SMB -', 'SMB2 -', etc
        .replace(/\(.*?\)/g, "")                           // ignore ()
        .replace(/\[.*?\]/g, "")                           // ignore []
        .normalize("NFD").replace(/[\u0300-\u036f]/g, "")  // strip accents 
        .replace(/[^a-z0-9]/g, "")                         // ignore punctuation

    }

    //--------------------------------------------------------------------
    // Cycles to the next/previous subset (direction: -1 or 1), does nothing if game has no subsets
    function switchSubset(direction) {
        if (subsetsList.length <= 1) { return }

        var newIndex = currentSubsetIndex + direction
        if (newIndex < 0) { newIndex = subsetsList.length - 1 }
        if (newIndex >= subsetsList.length) { newIndex = 0 }

        currentSubsetIndex = newIndex
        fetchGameAchievements(subsetsList[currentSubsetIndex].id)

        
    }

    function fetchGameAchievements(gameId) {
        var url = "https://retroachievements.org/API/API_GetGameInfoAndUserProgress.php"
                + "?z=" + themeSettings.raUsername + "&y=" + themeSettings.raApiKey
                + "&g=" + gameId + "&u=" + themeSettings.raUsername

        getJson(url, function(data) {
            if(data.Title == null){
                showStatus("Achievements not found for account, check if your Username is correct")
                return
            }
            achievementsReady()
            gameTitle = data.Title
            imageIcon = data.ImageIcon
            console.log("data: " + imageIcon)
            achievementsList = buildAchievementsList(data)
            api.memory.set("ra_cache_" + gameId, JSON.stringify(data))
            trackCacheKey("ra_cache_" + gameId)
        
        //on failure to load url, try to fallback to cached acheievement data
        }, function(reason) {
            loadCachedAchievements(gameId, reason)
        })
    }

    //--------------------------------------------------------------------
    // Falls back to the last successfully-fetched payload for this game ID
    function loadCachedAchievements(gameId, reason) {
        var cached = gameId ? api.memory.get("ra_cache_" + gameId) : null
        if (!cached) {
            showStatus(reason)
            return
        }
        achievementsReady()
        var data = JSON.parse(cached)
        gameTitle = data.Title
        imageIcon = data.ImageIcon
        achievementsList = buildAchievementsList(data)
        showStatus("Offline - Showing cached achievements")
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

    //--------------------------------------------------------------------
    //get status
    function getJson(url, callback, onError) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)
        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) { return }

            if (xhr.status !== 200) {
                var reason = "Request failed (HTTP " + xhr.status + "). Check your Username and API key"
                showStatus(reason)
                return
            }

            callback(JSON.parse(xhr.responseText))
        }
        xhr.onerror = function() {
            showStatus("No online connection")
        }
        xhr.send()
    }

    //--------------------------------------------------------------------
    //show Status message
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
