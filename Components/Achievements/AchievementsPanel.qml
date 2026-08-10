import QtQuick 2.15
import QtMultimedia 5.9

import "../Scrollbar"

// Right-side popup listing RetroAchievements for the currently open game.
// Takes over dpad input while open; Cancel closes it and returns focus
// to whatever previously had it.
//
// open(game) starts the fetch but does NOT show the panel or take focus
// immediately - it only opens once Achievements.qml reports success via
// its achievementsReady signal. On achievementsError, the panel stays
// closed and Achievements.qml's own error banner (rendered inside this
// component, so it's visible regardless of contentOpen) shows the reason.
//
// Usage (from GamesListMenu.qml's collectionsMenuRoot):
//   AchievementsPanel {
//       id: achievementsPanel
//       z: 1000
//       onClosed: gamesListLoader.item.forceActiveFocus()
//   }
//
//   Keys.onPressed: {
//       if (api.keys.isPageUp(event)) {
//           event.accepted = true
//           achievementsPanel.open(currentGame)
//           return
//       }
//   }


//TODO: maybe? Add wrap to top and bottom of list, add remember what place you were in when loading list


FocusScope {
    id: achievementsPanelRoot

	SoundEffect {
		id: navSound;
		source: '../../assets/sound/click.wav';
		volume: .2;
	}

    signal closed()

    property bool contentOpen: false
    property bool enlargeBadge: false

    width: parent.width * (themeSettings.itemListWidth / 100) + (parent.width * 0.02)

    height: parent.height
    
    anchors.left: parent.left
    anchors.leftMargin: parent.width * 0.02
    anchors.top: collectionsMenuLoader.bottom
    anchors.bottom:parent.bottom

    function open(game) {
        listView.currentIndex = 0
        fetcher.fetchAchievementsForGame(game)
    }

    function close() {
        contentOpen = false
        closed()
    }

    Achievements {
        id: fetcher
        anchors.fill: parent

        onAchievementsReady: {
            achievementsPanelRoot.contentOpen = true
            achievementsPanelRoot.forceActiveFocus()
        }
        onAchievementsError: {
            achievementsPanelRoot.contentOpen = false
        }
    }

    Keys.onReleased: {
        if (!contentOpen) { return }

        if (api.keys.isPageUp(event)) {
            event.accepted = true
            achievementsPanelRoot.close()
            return
        }
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Up) {
            event.accepted = true
            listView.decrementCurrentIndex()
            if(themeSettings.soundslist){
                navSound.play();
            }
            return
        }

        if (event.key === Qt.Key_Down) {
            event.accepted = true
            listView.incrementCurrentIndex()
            if(themeSettings.soundslist){
                navSound.play();
            }
            return
        }

        if (api.keys.isCancel(event)) {
            event.accepted = true;
            enlargeBadge = !enlargeBadge
            return
        }

        if (api.keys.isAccept(event)) {
            event.accepted = true;
            return
        }

        if (event.key === Qt.Key_Right) {
            event.accepted = true
            return
        }

        if (event.key === Qt.Key_Left) {
            event.accepted = true
            return
        }

        if (api.keys.isFilters(event)) {
            event.accepted = true;
            return
        }

        if (api.keys.isPrevPage(event)) {
            event.accepted = true;
            return
        }

        if (api.keys.isNextPage(event)) {
            //allow going to settings directly
            achievementsPanelRoot.close()
            return
        }
    }

    Rectangle {
        anchors.fill: parent
        color: themeData.colorTheme[theme].background
        opacity: contentOpen ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

        
    Text {
        id: panelTitleNum
        visible: contentOpen

        anchors {
            top: parent.top
            topMargin: parent.height * 0.03
            right: parent.right
            leftMargin: 20
            rightMargin: parent.width * 0.04
            
        }

        text: fetcher.achievementsUnlocked + "/" + fetcher.achievementsTotal
        wrapMode: Text.WordWrap
        font.family: themeSettings.font.customFont
        font.pixelSize: achievementsPanelRoot.height/themeSettings.itemListRows * 0.4 + ( themeSettings.mainFontSize - 20) 
        font.bold: true
        color: themeData.colorTheme[theme].light


    }

    Text {
        id: panelTitle
        visible: contentOpen

        anchors {
            top: parent.top
            topMargin: parent.height * 0.03
            left: parent.left
            right: panelTitleNum.left
            leftMargin: parent.width * 0.05
        }

        text: fetcher.gameTitle.replace(/~.*?~/g, "")  
        wrapMode: Text.WordWrap
        font.family: themeSettings.font.customFont
        font.pixelSize: achievementsPanelRoot.height/themeSettings.itemListRows * 0.4 + 5 + ( themeSettings.mainFontSize - 20) 
        font.bold: true
        color: themeData.colorTheme[theme].primary
    }



    Scrollbar {
        id: scrollbar
        visibleArea: listView.visibleArea
        visible: contentOpen

        anchors {
            left: parent.left
            right: listView.left
            rightMargin: 4
            top: parent.top
            bottom: parent.bottom
        }

    }




    ListView {
        id: listView
        visible: contentOpen

        anchors {
            top: panelTitle.bottom
            topMargin: parent.height * 0.02
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: parent.width * 0.04
            rightMargin: parent.width * 0.04

        }
        

        clip: true
        model: fetcher.achievementsList
        delegate: achievementDelegate

        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: height * 0.3
        preferredHighlightEnd: height * 0.7
        highlightMoveDuration: 0
    }

    Rectangle {
        id:currentAchBackground
        visible: enlargeBadge && contentOpen ? 1 : 0
        z:-100

        width: root.width
        height: parent.height/1.89
        x: (root.width * (themeSettings.itemListWidth / 100) + (parent.width * 0.02))
        y:parent.height/1.89;
        color: themeData.colorTheme[theme].background

    }

Image {
    id: currentBadgeImage

    visible: enlargeBadge && contentOpen ? 1 : 0

    width: parent.height/3
    height: parent.height/3
        x: parent.width + (root.width - parent.width - width) / 2

        y:parent.height - parent.height/2.5;

    property var currentAchievement: fetcher.achievementsList.length > 0
        ? fetcher.achievementsList[listView.currentIndex]
        : null

    source: currentAchievement
        ? "https://media.retroachievements.org/Badge/" + currentAchievement.BadgeName + ".png"
        : ""

    fillMode: Image.PreserveAspectFit
    asynchronous: true
    smooth: true
}

    Component {
        id: achievementDelegate


        Rectangle {
            id: delegateRoot

            width: ListView.view.width
            height: Math.max(achievementsPanelRoot.height/themeSettings.itemListRows + 18, achTitle.implicitHeight + achDesc.implicitHeight + 23)

            property bool unlocked: !!modelData.DateEarned
            property string badgeUrl: "https://media.retroachievements.org/Badge/"
                + modelData.BadgeName + (unlocked ? ".png" : "_lock.png")

            color: ListView.isCurrentItem ? themeData.colorTheme[theme].primary : "transparent"


            Image {
                id: badgeImage

                width: achievementsPanelRoot.height/themeSettings.itemListRows
                height: achievementsPanelRoot.height/themeSettings.itemListRows

                anchors {
                    top: parent.top
                    topMargin:  achievementsPanelRoot.height/themeSettings.itemListRows * .1
                    left: parent.left
                    leftMargin: 10
                }

                source: delegateRoot.badgeUrl
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
            }

            Text {
                id: pointsText

                anchors {
                    top: parent.top
                    topMargin: 8
                    right: parent.right
                    rightMargin: 10
                }

                text: modelData.Points 
                font.family: themeSettings.font.customFont
                font.pixelSize: achievementsPanelRoot.height/themeSettings.itemListRows * 0.4 + ( themeSettings.mainFontSize - 20)
                font.bold: true

                color: unlocked ? 

                    (delegateRoot.ListView.isCurrentItem ?
                        themeData.colorTheme[theme].background
                        : themeData.colorTheme[theme].primary
                    )
                :
                    (delegateRoot.ListView.isCurrentItem ?
                        themeData.colorTheme[theme].light
                        : themeData.colorTheme[theme].light
                    )
            }

            Text {
                id: achTitle

                anchors {
                    top: parent.top
                    topMargin: 8
                    left: badgeImage.right
                    right: pointsText.left
                    leftMargin: 10
                    rightMargin: 10
                }

                text: modelData.Title
                wrapMode: Text.WordWrap
                font.family: themeSettings.font.customFont
                font.pixelSize: achievementsPanelRoot.height/themeSettings.itemListRows * 0.4 + ( themeSettings.mainFontSize - 20)
                font.bold: true
                
                color: unlocked ? 
                
                    (delegateRoot.ListView.isCurrentItem ?
                        themeData.colorTheme[theme].background
                        : themeData.colorTheme[theme].primary
                    )
                :
                    (delegateRoot.ListView.isCurrentItem ?
                        themeData.colorTheme[theme].light
                        : themeData.colorTheme[theme].light
                    )
            }

            Text {
                id: achDesc

                anchors {
                    top: achTitle.bottom
                    left: badgeImage.right
                    right: pointsText.left
                    leftMargin: 10
                    rightMargin: 10
                }

                text: modelData.Description
                wrapMode: Text.WordWrap
                font.family: themeSettings.font.customFont
                font.pixelSize:  achievementsPanelRoot.height/themeSettings.itemListRows * 0.3 + ( themeSettings.mainFontSize - 20)
                color: delegateRoot.ListView.isCurrentItem
                    ? themeData.colorTheme[theme].light
                    : themeData.colorTheme[theme].light
            }
        }

        
    }


}
