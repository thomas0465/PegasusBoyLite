import QtQuick 2.15
import QtMultimedia 5.9

import "../Scrollbar"
import "Logger.js" as Logger

// Right-side popup listing RetroAchievements for the currently open game.

FocusScope {
    id: achievementsPanelRoot

    property alias listView: listView
    property alias fetcher: fetcher

	SoundEffect {
		id: navSound;
		source: '../../assets/sound/click.wav';
		volume: .2;
	}

    signal closed()

    property bool contentOpen: false
    property bool achloading: false
    property bool enlargeBadge: false
    property int lastRAIndex: 0

    // true between a page key's press and its release (see Keys.onReleased)
    property bool pageDownPressed: false   // used by prev page
    property bool pageUpPressed: false     // used by next page

    property real headerBottomY: Math.max(gameIcon.y + gameIcon.height, panelTitleBox.y + panelTitleBox.height)

    Component.onCompleted: {
        var saved = api.memory.get("lastRAIndex")
        if (saved !== undefined) {
            lastRAIndex = saved
        }
    }

    onLastRAIndexChanged: {
        api.memory.set("lastRAIndex", lastRAIndex)
    }

    width: parent.width * (themeSettings.itemListWidth / 100) + (parent.width * 0.02)

    height: parent.height
    
    anchors.left: parent.left
    anchors.leftMargin: parent.width * 0.02
    anchors.top: collectionsMenuLoader.bottom
    anchors.bottom:parent.bottom

    // Jump 10 achievements down (or up). The target is worked out first, scrolled to the
    // middle of the list, and only then selected, so the list has nothing left to snap to.
    // Already at the end (and list wrap enabled): wraps to the other end instead.
    function pageJump(down, canWrap) {
        var last = listView.count - 1
        var wrap = themeSettings.listwrap && canWrap
        var cur = listView.currentIndex
        var target

        if (down) {
            target = (cur === last && wrap) ? 0 : Math.min(last, cur + 5)
        } else {
            target = (cur === 0 && wrap) ? last : Math.max(0, cur - 5)
        }

        listView.positionViewAtIndex(target, ListView.Center)
        listView.currentIndex = target
        lastRAIndex = target
        if (themeSettings.soundslist) {
            navSound.play()
        }
    }

    function open(game) {
        achloading = true
        fetcher.fetchAchievementsForGame(game)
    }

    function close() {
        contentOpen = false
        achloading = false
        closed()
    }

    Achievements {
        id: fetcher
        anchors.fill: parent
        z: 999

        // Online refresh that changed the data: swapping the list model resets the
        // view to the top (and would overwrite lastRAIndex with 0), so save the
        // position before the swap and put it back right after, in the same frame.
        property int savedIndex: 0
        property real savedContentY: 0

        onAchievementsRefreshing: {
            savedIndex = listView.currentIndex
            savedContentY = listView.contentY
        }

        onAchievementsRefreshed: {
            listView.currentIndex = Math.min(savedIndex, listView.count - 1)
            listView.contentY = savedContentY
        }

        onAchievementsReady: {
            var maxIndex = fetcher.achievementsList.length - 1

            if(achievementsPanelRoot.lastRAIndex > maxIndex){
                listView.currentIndex = maxIndex
            }else{
                listView.currentIndex = achievementsPanelRoot.lastRAIndex
            }

            achievementsPanelRoot.contentOpen = true
            achievementsPanelRoot.achloading = false
            achievementsPanelRoot.forceActiveFocus()
        }
        onAchievementsError: {
            achievementsPanelRoot.achloading = false
            closed()
            
        }

        
    }

    Keys.onReleased: {
        // A trigger (e.g. L2) can lose its first press; if the release arrives without
        // a matching press, run the jump now.
        if (contentOpen && api.keys.isPrevPage(event)) {
            event.accepted = true
            if (!pageDownPressed) { pageJump(false, false) }
            pageDownPressed = false
            return
        }

        if (contentOpen && api.keys.isNextPage(event)) {
            event.accepted = true
            if (!pageUpPressed) { pageJump(true, false) }
            pageUpPressed = false
            return
        }

        if (!contentOpen) { return }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Up) {
            event.accepted = true
            if (listView.currentIndex === 0 && themeSettings.listwrap) {
                listView.currentIndex = listView.count - 1
            } else {
                listView.decrementCurrentIndex()
            }
            achievementsPanelRoot.lastRAIndex = listView.currentIndex 
            if(themeSettings.soundslist){
                navSound.play();
            }
            return
        }

        if (event.key === Qt.Key_Down) {
            event.accepted = true
            if (listView.currentIndex === listView.count - 1 && themeSettings.listwrap) {
                listView.currentIndex = 0
            } else {
                listView.incrementCurrentIndex()
            }

                   achievementsPanelRoot.lastRAIndex = listView.currentIndex 
            if(themeSettings.soundslist){
                navSound.play();
            }
            return
        }
         
         
        //close panel
        if (api.keys.isPageUp(event)) {
            event.accepted = true
            achievementsPanelRoot.close()
            return
        }

        // enlarge current ach image, and hide screenshot
        if (api.keys.isDetails(event)) {
            event.accepted = true;
            enlargeBadge = !enlargeBadge
            return
        }

        //return to main list
        if (api.keys.isAccept(event)) {
            event.accepted = true;
            achievementsPanelRoot.close()
            return
        }

        if (api.keys.isCancel(event)) {
            event.accepted = true;
            achievementsPanelRoot.close()
            return
        }

        if (event.key == Qt.Key_Left) {
            event.accepted = true
            fetcher.switchSubset(-1)
            return
        }

        if (event.key == Qt.Key_Right) {
            event.accepted = true
            fetcher.switchSubset(1)
            return
        }

        if (api.keys.isFilters(event)) {
            event.accepted = true;
            return
        }

        // previous page: down 10
        if (api.keys.isPrevPage(event)) {
            event.accepted = true
            pageDownPressed = true
            pageJump(false, !event.isAutoRepeat)
            return
        }

        // scroll page down: up 10
        if (api.keys.isNextPage(event)) {
            event.accepted = true
            pageUpPressed = true
            pageJump(true, !event.isAutoRepeat)
            return
        }

        if (api.keys.isPageUp(event)) {
            //allow going to settings directly
            achievementsPanelRoot.close()
            return
        }
    }

    Image {
        id: gameIcon
        visible: contentOpen

        width: achievementsPanelRoot.height/themeSettings.itemListRows * 1.5
        height: achievementsPanelRoot.height/themeSettings.itemListRows * 1.5

        anchors {
            top: parent.top
            topMargin: parent.height * 0.01
            left: scrollbar.left
            //leftMargin: parent.width * 0.014
        }

        source: "https://media.retroachievements.org" + fetcher.imageIcon
        //onStatusChanged: {
        //        if (status === Image.Error)
        //        source =  "../../assets/images/2.png"
        //                        }
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true

        //Rectangle {
        //    property int bw: Math.max(Math.round(parent.width * 0.002), 2)
        //    width: Math.ceil(parent.paintedWidth) + bw * 2 - 3
        //    height: Math.ceil(parent.paintedHeight) + bw * 2 - 3
        //    x: Math.round((parent.width - width) / 2)
        //    y: Math.round((parent.height - height) / 2 )
        //    color: "transparent"
        //    border.color: themeData.colorTheme[theme].primary
        //    border.width: bw
        //    opacity: themeSettings.imageBorder 
        //}
    }


    //-------------------------------------------------
    //Game achievements unlocked, divider, and total achievements
    Text {
        id: panelTitleNumBottom
        visible: contentOpen

        anchors {
            right: parent.right
            leftMargin: parent.width * 0.04
            rightMargin: parent.width * 0.06
            bottom: gameIcon.bottom
            bottomMargin: gameIcon.height * 0.15
        }

        text:fetcher.achievementsTotal
        wrapMode: Text.WordWrap
        font.family: themeSettings.font.customFont
        font.pixelSize: achievementsPanelRoot.height/themeSettings.itemListRows * 0.31 + 5 + ( themeSettings.mainFontSize - 20) 
        font.bold: false
        color: themeData.colorTheme[theme].light
    }

    Text {
        id: panelTitleNumTop
        visible: contentOpen

        anchors {
            top: gameIcon.top
            topMargin: gameIcon.height * 0.15
            horizontalCenter: panelTitleNumBottom.horizontalCenter
        }

        text: fetcher.achievementsUnlocked
        wrapMode: Text.WordWrap
        font.family: themeSettings.font.customFont
        font.pixelSize: achievementsPanelRoot.height/themeSettings.itemListRows * 0.31 + 5 + ( themeSettings.mainFontSize - 20) 
        font.bold: false
        color: themeData.colorTheme[theme].light
    }

    Rectangle{
        id:panelTitleNumDivider

        visible: contentOpen

        width: panelTitleNumBottom.width
        height: gameIcon.height/40
        anchors {
            verticalCenter: gameIcon.verticalCenter
            horizontalCenter: panelTitleNumBottom.horizontalCenter
        }

        color: themeData.colorTheme[theme].light
        rotation: 0
        transformOrigin: Item.Center

    }

    //subset dot indicators
    Row {
        id: subsetDots
        visible: contentOpen && fetcher.subsetsList.length > 1
        spacing: parent.height * 0.025

        anchors {
            bottom: panelTitleBox.bottom
            bottomMargin: (panelTitle.overflows ? -achievementsPanelRoot.height* 0.0015: - achievementsPanelRoot.height * 0.015)
            left: panelTitleBox.left
            leftMargin: gameIcon.height * 0.03
            //horizontalCenter: parent.horizontalCenter
    }

    Repeater {
            model: fetcher.subsetsList.length

            Rectangle {
                width: gameIcon.width * .1
                height: gameIcon.width * .1
                radius: gameIcon.width * .05
                color: index === fetcher.currentSubsetIndex
                    ? themeData.colorTheme[theme].primary
                    : themeData.colorTheme[theme].light
                opacity: index === fetcher.currentSubsetIndex ? 1 : (themeData.colorTheme[theme].primary === themeData.colorTheme[theme].light ? 0.5 : 1 ) 
            }
        }
    }

Rectangle{
    id: panelTitleBox
    color: "transparent"
        anchors {
            top: gameIcon.top
            right: panelTitleNumBottom.left
            left: gameIcon.right
            leftMargin: parent.width * 0.025
            rightMargin: parent.width * 0.025
            topMargin: -parent.height * 0.005
            //verticalCenter: gameIcon.verticalCenter
        }

        property real dotsRowHeight: gameIcon.width * 0.1
        property real normalHeight: fetcher.subsetsList.length > 1 ? (gameIcon.height - dotsRowHeight) : gameIcon.height
        height: Math.max(normalHeight, (fetcher.subsetsList.length > 1 ? panelTitle.contentHeight * 1.1 : panelTitle.contentHeight *.95))


    Text {
        id: panelTitle
        visible: contentOpen

        property bool overflows: panelTitle.implicitHeight > panelTitleBox.normalHeight

        anchors {
            left: parent.left
            right: parent.right
        }

        states: [
            State {
                name: "centered"
                when: !panelTitle.overflows
                AnchorChanges {
                    target: panelTitle
                    anchors.verticalCenter: panelTitleBox.verticalCenter
                    anchors.top: undefined
                }
            },
            State {
                name: "top"
                when: panelTitle.overflows
                AnchorChanges {
                    target: panelTitle
                    anchors.top: parent.top 
                    anchors.verticalCenter: undefined
                }
            }
        ]

        text:fetcher.gameTitle.replace(/~.*?~/g, "").replace(/^( *)[ ]/g,"")
        wrapMode: Text.WordWrap
        font.family: themeSettings.font.customFont
        font.pixelSize: achievementsPanelRoot.height/themeSettings.itemListRows * 0.5 + ( themeSettings.mainFontSize - 20)
        font.bold: false
        color: themeData.colorTheme[theme].primary
    }
}



    Scrollbar {
        id: scrollbar
        visibleArea: listView.visibleArea
        visible: contentOpen

        anchors {
            left: parent.left
            right: listView.left
            rightMargin: parent.width * 0.005
            top: listView.top
            bottom: parent.bottom
        }

    }

    //Rectangle{
    //    id: splitBar
    //    visible: contentOpen
    //    width: parent.width * .955
    //    height: 2
    //    color: themeData.colorTheme[theme].primary
    //    //opacity: themeSettings.transparent ? 0.5 : 1
    //    z: 999
    //    anchors{
    //        left: parent.left
    //        top:listView.top
    //        //topMargin: -parent.height * 0.01
    //    }
    //}




    ListView {
        id: listView
        visible: contentOpen

        anchors {
            left: parent.left
            right: parent.right
            leftMargin: parent.width * 0.04
            rightMargin: parent.width * 0.045
        }

        y: achievementsPanelRoot.headerBottomY + parent.height * 0.02
        height: parent.height - y

        clip: true
        model: fetcher.achievementsList
        delegate: achievementDelegate

        onCurrentIndexChanged: {
            achievementsPanelRoot.lastRAIndex = currentIndex
        }


        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: height * 0.3
        preferredHighlightEnd: height * 0.7
        highlightMoveDuration: 0
    }


    // Enlarged badge. Same no-flash logic as the games media: a new badge loads in a
    // hidden second Image and is swapped in only once it has finished, so the previous
    // badge stays on screen until then (Null/Error also count as finished).
    Item {
        id: currentBadgeImage

        visible: enlargeBadge && contentOpen

        width: parent.height/3
        height: parent.height/3
            x: parent.width + (root.width - parent.width - width - (parent.width * 0.08)) / 2

            y:parent.height - parent.height/2.5;

        property var currentAchievement: fetcher.achievementsList.length > 0
            ? fetcher.achievementsList[listView.currentIndex]
            : null

        property string source: currentAchievement
            ? "https://media.retroachievements.org/Badge/" + currentAchievement.BadgeName + ".png"
            : ""

        property var shown: badgeA      // layer currently on screen
        property var pending: null      // layer a new source is loading into

        function settle() {
            if (pending !== null && pending.status !== Image.Loading) {
                var old = shown
                shown = pending
                pending = null
                old.source = ""
            }
        }

        onSourceChanged: {
            pending = (shown === badgeA) ? badgeB : badgeA
            pending.source = source
            settle()
        }

        Image {
            id: badgeA
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            visible: currentBadgeImage.shown === badgeA
            onStatusChanged: currentBadgeImage.settle()
        }

        Image {
            id: badgeB
            anchors.fill: parent
            fillMode: Image.PreserveAspectFit
            asynchronous: true
            smooth: true
            visible: currentBadgeImage.shown === badgeB
            onStatusChanged: currentBadgeImage.settle()
        }
    }

    Component {
        id: achievementDelegate


        Rectangle {
            id: delegateRoot

            width: ListView.view.width
            height: Math.max(
                
                achievementsPanelRoot.height/themeSettings.itemListRows + achievementsPanelRoot.height * 0.022, 
            
                achTitle.implicitHeight + achDesc.implicitHeight + achievementsPanelRoot.height * 0.02 + 5
            )

            property bool unlocked: !!modelData.DateEarned
            property string badgeUrl: "https://media.retroachievements.org/Badge/"
                + modelData.BadgeName + (unlocked ? ".png" : "_lock.png")

            color: {
                var c;
                if (ListView.isCurrentItem) {
                       c = themeData.colorTheme[theme].primary 
                } else {
                    return "transparent";
                }

                // Converts "#RRGGBB" to "#80RRGGBB" (80 in hex is 50% opacity)
                var hex = c.toString();
                if (hex.indexOf("#") === 0 && themeSettings.transparent) {
                    if (hex.length === 7) return "#80" + hex.substring(1); // #RRGGBB -> #80RRGGBB
                    if (hex.length === 9) return "#80" + hex.substring(3); // Replace existing alpha
                }
                
                return c;
            }

            Image {
                id: badgeImage

                width: achievementsPanelRoot.height/themeSettings.itemListRows
                height: achievementsPanelRoot.height/themeSettings.itemListRows

                anchors {
                    top: parent.top
                    topMargin:  achievementsPanelRoot.height/themeSettings.itemListRows * .1
                    //verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: parent.width * 0.01
                }

                source: delegateRoot.badgeUrl
                //offline fallback
                onStatusChanged: {
                    if (status === Image.Error)
                    source = delegateRoot.unlocked ?  "../../assets/images/1.png" :  "../../assets/images/2.png"
                }

                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true

                //    Rectangle {
                //        property int bw: Math.max(Math.round(parent.width * 0.002), 2)
                //        width: Math.ceil(parent.paintedWidth) + bw * 2 - 3
                //        height: Math.ceil(parent.paintedHeight) + bw * 2 - 3
                //        x: Math.round((parent.width - width) / 2)
                //        y: Math.round((parent.height - height) / 2 )
                //        color: "transparent"
                //        border.color: themeData.colorTheme[theme].primary
                //        border.width: bw
                //        opacity: themeSettings.imageBorder 
                //   }
            }

            Text {
                id: pointsText

                anchors {
                    top: parent.top
                    topMargin: parent.width * 0.015
		    //verticalCenter: badgeImage.verticalCenter
                    right: parent.right
                    rightMargin: parent.width * 0.02
                }

                text:modelData.Points 
                font.family: themeSettings.font.customFont
                font.pixelSize: achievementsPanelRoot.height/themeSettings.itemListRows * 0.31 + ( themeSettings.mainFontSize - 20)
                font.bold: false

                color: unlocked ? 

                    (delegateRoot.ListView.isCurrentItem ?
                        themeData.colorTheme[theme].background
                        : themeData.colorTheme[theme].primary
                    )
                :
                    (delegateRoot.ListView.isCurrentItem ?
                        themeData.colorTheme[theme].background
                        : themeData.colorTheme[theme].light
                    )
            }

            Text {
                id: achTitle

                anchors {
                    top: parent.top
                    topMargin: parent.width * 0.015
                    left: badgeImage.right
                    right: pointsText.left
                    leftMargin: parent.width * 0.02
                    rightMargin: parent.width * 0.02
                }

                text: (themeSettings.missableIndicator && String(modelData.type || modelData.Type || "").toLowerCase().indexOf("missable") !== -1 ? "[m] " : "") + modelData.Title
                wrapMode: Text.WordWrap
                font.family: themeSettings.font.customFont
                font.pixelSize: achievementsPanelRoot.height/themeSettings.itemListRows * 0.4 + ( themeSettings.mainFontSize - 20)
                font.bold: false
                
                color: unlocked ? 
                
                    (delegateRoot.ListView.isCurrentItem ?
                        themeData.colorTheme[theme].background
                        : themeData.colorTheme[theme].primary
                    )
                :
                    (delegateRoot.ListView.isCurrentItem ?
                        themeData.colorTheme[theme].background
                        : themeData.colorTheme[theme].light
                    )
            }

            Text {
                id: achDesc

                anchors {
                    top: achTitle.bottom
                    topMargin: parent.height * 0.02
                    //bottomMargin: parent.height * 0.01
                    left: badgeImage.right
                    right: pointsText.left
                    leftMargin: parent.width * 0.05
                    rightMargin: parent.width * 0.02
                }

                text: modelData.Description
                wrapMode: Text.WordWrap
                font.family: themeSettings.font.customFont
                font.pixelSize:  achievementsPanelRoot.height/themeSettings.itemListRows * 0.31 + ( themeSettings.mainFontSize - 20)
                color: unlocked ? 
                    (delegateRoot.ListView.isCurrentItem ?
                        themeData.colorTheme[theme].background
                        : themeData.colorTheme[theme].primary
                    )
                :
                    (delegateRoot.ListView.isCurrentItem ?
                        themeData.colorTheme[theme].background
                        : themeData.colorTheme[theme].light
                    )
            }
        }

        
    }




}
