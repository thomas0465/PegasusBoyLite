import QtQuick 2.15

import "../../assets"

Item {
    id: achRoot

    signal achievementsReady()
    signal achievementsError()

    property string statusMessage: ""
    property bool statusVisible: false

    property string gameTitle: ""
    property string imageIcon: ""
    property var achievementsList: []

    property var currentGame: null        // last base game passed to fetchAchievementsForGame
    property var subsetsList: []          // [{id, title}], base game always first
    property int currentSubsetIndex: 0    // subset currently displayed
    property int pendingSubsetIndex: 0    // subset most recently requested (may be ahead of the display)

    // Bumped on every fetchAchievementsForGame call. Responses to older calls
    // are cached but never applied, so fast switching can't show stale data.
    property int requestSerial: 0

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

    // Tracks every ra_gameid_*/ra_cache_*/ra_subsets_* key
    property var cacheKeys: []

    Component.onCompleted: {
        var stored = api.memory.get("ra_cache_index")
        if (stored) {
            try { cacheKeys = JSON.parse(stored) } catch (e) { cacheKeys = [] }
        }
    }

    //--------------------------------------------------------------------
    // Config (console hints + title overrides)
    AchievementsConfig {
        id: achievementsConfig
    }
    property var consoleNameHints: parseOverrides(achievementsConfig.consoleHintsText, true)
    property var titleOverrides: parseOverrides(achievementsConfig.titleOverridesText, false)

    function parseOverrides(text, toLower) {
        var result = {}
        var lines = text.split("\n")

        for (var i = 0; i < lines.length; i++) {
            var line = lines[i].trim()
            if (!line) { continue }

            var sep = line.indexOf(":")
            if (sep === -1) { continue }

            var key = line.substring(0, sep).trim()
            var value = line.substring(sep + 1).trim()

            if (toLower) {
                var values = value.split(",")
                for (var j = 0; j < values.length; j++) { values[j] = values[j].trim() }
                result[key.toLowerCase()] = values
            } else {
                result[key] = value
            }
        }
        return result
    }

    //--------------------------------------------------------------------
    // Cache bookkeeping
    function trackCacheKey(key) {
        if (cacheKeys.indexOf(key) === -1) {
            var updated = cacheKeys.slice()
            updated.push(key)
            cacheKeys = updated
            api.memory.set("ra_cache_index", JSON.stringify(cacheKeys))
        }
    }

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
    // Resolves consoles -> game -> achievements. Optional `subset` ({id, title})
    // skips the title lookup and loads that subset through the same
    // preload -> refresh -> offline-fallback flow.
    function fetchAchievementsForGame(game, subset) {
        var serial = ++requestSerial
        var isSubset = !!subset
        var cachedShown = false     // cached data is on screen, so the panel is open

        showStatus("stop")
        if (!isSubset) { currentGame = game }

        // Every failure ends here. Panel already open (subset switch or cached data
        // on screen): only show the message and stay on what's displayed. Nothing on
        // screen: also hand control back to the list. Offline over cached data says
        // so, except when switching subsets.
        var onError = function(message, offline) {
            if (offline && cachedShown) {
                if (!isSubset) { showStatus("Offline - Showing cached achievements") }
            } else {
                showStatus(message)
            }

            if (isSubset || cachedShown) {
                pendingSubsetIndex = currentSubsetIndex
            } else {
                achievementsError()
            }
        }

        if (!themeSettings.raUsername || !themeSettings.raApiKey) {
            onError("RetroAchievements username or API key is not set", false)
            return
        }

        // Shows the last successfully-fetched payload for this game ID, if any
        var showCached = function(gameId) {
            var cached = api.memory.get("ra_cache_" + gameId)
            if (!cached) { return false }

            try {
                applyGameData(gameId, JSON.parse(cached))
                return true
            } catch (e) {
                return false    // invalid cache
            }
        }

        // `preload`: show cached data right away; otherwise it is only the offline fallback
        var loadAchievements = function(gameId, preload) {
            cachedShown = preload && showCached(gameId)

            var url = "https://retroachievements.org/API/API_GetGameInfoAndUserProgress.php"
                    + "?z=" + themeSettings.raUsername + "&y=" + themeSettings.raApiKey
                    + "&g=" + gameId + "&u=" + themeSettings.raUsername

            getJson(serial, url, function(data, stale) {
                if (data.Title == null) {
                    if (!stale) { onError("RetroAchievements error: Check your username", false) }
                    return
                }

                // Always store the fresh data, even if the user has moved on
                api.memory.set("ra_cache_" + gameId, JSON.stringify(data))
                trackCacheKey("ra_cache_" + gameId)

                if (!stale) { applyGameData(gameId, data) }
            }, function(message, offline) {
                // Offline right after a fresh lookup: fall back to cached data
                if (offline && !cachedShown) { cachedShown = showCached(gameId) }
                onError(message, offline)
            })
        }

        var searchTitle = titleOverrides[game.title] || game.title

        // Subsets already know their ID; base games use the cached title -> ID mapping.
        // With an ID, the online console/game lookups are skipped entirely.
        var knownId = isSubset ? subset.id : api.memory.get("ra_gameid_" + searchTitle)
        if (knownId) {
            loadAchievements(knownId, true)
            return
        }

        var findGame = function() {
            var consoleIds = []
            var hintsTried = []

            for (var i = 0; i < game.collections.count; i++) {
                var shortName = game.collections.get(i).shortName.toLowerCase()
                var hints = consoleNameHints[shortName]

                if (!hints) {
                    hintsTried.push(shortName + " (no override configured)")
                    continue
                }
                for (var h = 0; h < hints.length; h++) {
                    hintsTried.push(hints[h])
                    for (var j = 0; j < consoleList.length; j++) {
                        if (consoleList[j].Name.toLowerCase() === hints[h].toLowerCase()) {
                            consoleIds.push(consoleList[j].ID)
                        }
                    }
                }
            }

            if (!consoleIds.length) {
                onError("No console match for " + hintsTried.join(", "), false)
                return
            }

            tryConsoles(consoleIds, 0, searchTitle, serial, function(foundId) {
                api.memory.set("ra_gameid_" + searchTitle, foundId)
                trackCacheKey("ra_gameid_" + searchTitle)
                loadAchievements(foundId, false)
            }, onError)
        }

        if (consoleList) {
            findGame()
            return
        }

        var url = "https://retroachievements.org/API/API_GetConsoleIDs.php"
                + "?z=" + themeSettings.raUsername + "&y=" + themeSettings.raApiKey

        getJson(serial, url, function(data, stale) {
            consoleList = data
            if (!stale) { findGame() }
        }, onError)
    }

    // Tries each console until the title matches, then saves the game's subset list
    function tryConsoles(consoleIds, index, title, serial, onFound, onError) {
        if (index >= consoleIds.length) {
            var names = []
            for (var n = 0; n < consoleIds.length; n++) {
                for (var m = 0; m < consoleList.length; m++) {
                    if (consoleList[m].ID === consoleIds[n]) { names.push(consoleList[m].Name); break }
                }
            }

            onError("\"" +
                title
                .replace(/\(.*?\)/g, "")
                .replace(/\[.*?\]/g, "")
                .replace(/[ \t]+$/g, "")
                //remove () and [] on displayed title
                + "\" not found. Tried " + names.join(", "), false)
            return
        }

        var consoleId = consoleIds[index]

        var onGameList = function(list) {
            var target = normalize(title)
            var match = null
            for (var i = 0; i < list.length; i++) {
                if (normalize(list[i].Title) === target) { match = list[i]; break }
            }

            if (!match) {
                tryConsoles(consoleIds, index + 1, title, serial, onFound, onError)
                return
            }

            var subsets = [{ id: match.ID, title: match.Title }]
            for (var j = 0; j < list.length; j++) {
                if (list[j].ID === match.ID) { continue }
                if (list[j].Title.indexOf(match.Title) === 0 && list[j].Title.indexOf("[Subset") !== -1) {
                    subsets.push({ id: list[j].ID, title: list[j].Title })
                }
            }

            // Persist under every member's own ID so offline loads can
            // restore this list no matter which one they load from cache.
            var serialized = JSON.stringify(subsets)
            for (var k = 0; k < subsets.length; k++) {
                api.memory.set("ra_subsets_" + subsets[k].id, serialized)
                trackCacheKey("ra_subsets_" + subsets[k].id)
            }

            onFound(match.ID)
        }

        if (gameListCache[consoleId]) {
            onGameList(gameListCache[consoleId])
            return
        }

        var url = "https://retroachievements.org/API/API_GetGameList.php"
                + "?y=" + themeSettings.raApiKey + "&i=" + consoleId + "&f=1"

        getJson(serial, url, function(data, stale) {
            gameListCache[consoleId] = data
            if (!stale) { onGameList(data) }
        }, onError)
    }

    function normalize(title) {
        return title.toLowerCase()
            .replace(/~.*?~/g, "")                             // ignore ~hack~ and ~homebrew~
            .replace(/smb.* - /g, "")                          // replace 'SMB -', 'SMB2 -', etc
            .replace(/\(.*?\)/g, "")                           // ignore ()
            .replace(/\[.*?\]/g, "")                           // ignore []
            .normalize("NFD").replace(/[̀-ͯ]/g, "")  // strip accents
            .replace(/[^a-z0-9]/g, "")                         // ignore punctuation
    }

    //--------------------------------------------------------------------
    // Cycles to the next/previous subset through the same entry point as the
    // base game. Steps from the last requested subset (not the displayed one)
    // so rapid presses keep advancing. Does nothing if there are no subsets.
    function switchSubset(direction) {
        if (subsetsList.length <= 1 || !currentGame) { return }

        var newIndex = pendingSubsetIndex + direction
        if (newIndex < 0) { newIndex = subsetsList.length - 1 }
        if (newIndex >= subsetsList.length) { newIndex = 0 }

        pendingSubsetIndex = newIndex
        fetchAchievementsForGame(currentGame, subsetsList[newIndex])
    }

    // Shared path to open achievements panel
    function applyGameData(gameId, data) {
        gameTitle = data.Title
        imageIcon = data.ImageIcon
        achievementsList = buildAchievementsList(data)

        // Subset list is persisted per game ID; fall back to just this game
        var list = [{ id: gameId, title: data.Title }]
        var stored = api.memory.get("ra_subsets_" + gameId)
        if (stored) {
            try { list = JSON.parse(stored) } catch (e) { }
        }

        // memory returns strings, JSON ids are numbers, so compare as strings
        var index = -1
        for (var i = 0; i < list.length; i++) {
            if (String(list[i].id) === String(gameId)) { index = i; break }
        }
        if (index === -1) {
            // Nothing stored, or a leftover list from a different game
            list = [{ id: gameId, title: data.Title }]
            index = 0
        }

        subsetsList = list
        currentSubsetIndex = index
        pendingSubsetIndex = index

        showStatus("stop")
        achievementsReady()
    }

    function buildAchievementsList(data) {
        var arr = []
        for (var id in data.Achievements) {
            arr.push(data.Achievements[id])
        }

        arr.sort(function(a, b) {
            if (a.DisplayOrder !== 0) {
                return (a.DisplayOrder || 0) - (b.DisplayOrder || 0)
            } else {
                return (a.ID || 0) - (b.ID || 0)
            }
        })
        return arr
    }

    //--------------------------------------------------------------------
    // GET + JSON parse. Calls exactly one of:
    //   onSuccess(data, stale)       stale = a newer fetchAchievementsForGame call
    //                                superseded this request; callers may still cache it
    //   onError(message, offline)    never called for stale requests
    function getJson(serial, url, onSuccess, onError) {
        var xhr = new XMLHttpRequest()
        xhr.open("GET", url)

        var finished = false
        var finish = function(data, message, offline) {
            if (finished) { return }
            finished = true

            var stale = serial !== requestSerial
            if (!message) {
                onSuccess(data, stale)
            } else if (!stale) {
                onError(message, offline)
            }
        }

        // A network failure reports status 0 and also fires onerror; finish() runs once
        var offlineMessage = "Offline - No cached achievements"

        xhr.onreadystatechange = function() {
            if (xhr.readyState !== XMLHttpRequest.DONE) { return }

            if (xhr.status === 0) {
                finish(null, offlineMessage, true)
                return
            }

            var data = null
            try { data = JSON.parse(xhr.responseText) } catch (e) { }

            // Prefer the API's own message, also for errors sent with HTTP 200
            var apiError = data && (data.message || data.Error)

            if (xhr.status !== 200 || apiError) {
                finish(null, "RetroAchievements error: " + (apiError ||
                       "Check your API key or username (HTTP " + xhr.status + ")"), false)
            } else if (data === null) {
                finish(null, "Invalid JSON response from server", false)
            } else {
                finish(data, null, false)
            }
        }

        xhr.onerror = function() { finish(null, offlineMessage, true) }

        xhr.send()
    }

    //--------------------------------------------------------------------
    // Show status message
    function showStatus(msg) {
        if (msg != 'stop') {
            statusMessage = msg
            statusVisible = true
            statusTimer.restart()
        } else {
            statusVisible = false
            statusTimer.stop()
        }
    }

    Timer {
        id: statusTimer
        interval: 2000
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
            font.pixelSize: achRoot.height / 22 + (themeSettings.mainFontSize - 20)

            color: themeData.colorTheme[theme].primary
            wrapMode: Text.WordWrap
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
