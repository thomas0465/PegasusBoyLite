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



FocusScope {
    id: root

	SoundEffect {
		id: navSound;
		source: '../../assets/sound/click.wav';
		volume: .2;
	}

    signal closed()

    property bool contentOpen: false

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
            root.contentOpen = true
            root.forceActiveFocus()
        }
        onAchievementsError: {
            root.contentOpen = false
        }
    }

    Keys.onReleased: {
        if (!contentOpen) { return }

        if (api.keys.isPageUp(event)) {
            event.accepted = true
            root.close()
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
            event.accepted = true;
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
        id: panelTitle
        visible: contentOpen

        anchors {
            top: parent.top
            topMargin: parent.height * 0.03
            left: parent.left
            right: parent.right
            leftMargin: parent.width * 0.05
            rightMargin: parent.width * 0.05
        }

        text: fetcher.gameTitle + "  (" + fetcher.achievementsUnlocked + "/" + fetcher.achievementsTotal + ")"
        wrapMode: Text.WordWrap
        font.family: themeSettings.font.customFont
        font.pixelSize: root.height/themeSettings.itemListRows * 0.4 + 5 + ( themeSettings.mainFontSize - 20) 
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

        }
        

        clip: true
        model: fetcher.achievementsList
        delegate: achievementDelegate

        highlightRangeMode: ListView.ApplyRange
        preferredHighlightBegin: height * 0.3
        preferredHighlightEnd: height * 0.7
        highlightMoveDuration: 0
    }

    Component {
        id: achievementDelegate

        Rectangle {
            id: delegateRoot

            width: ListView.view.width
            height: root.height/themeSettings.itemListRows

            property bool unlocked: !!modelData.DateEarned
            property string badgeUrl: "https://media.retroachievements.org/Badge/"
                + modelData.BadgeName + ".png"
                //(unlocked ? ".png" : "_lock.png")

            color: ListView.isCurrentItem ? themeData.colorTheme[theme].primary : "transparent"

            Image {
                id: badgeImage

                width: parent.height * .8
                height: parent.height * .8

                anchors {
                    top: parent.top
                    topMargin: 8
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
                font.pixelSize: 20 + (themeSettings.mainFontSize - 20)
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
                    right: parent.right
                    leftMargin: 10
                    rightMargin: 10
                }

                text: modelData.Title 
                wrapMode: Text.WordWrap
                font.family: themeSettings.font.customFont
                font.pixelSize: parent.height * 0.4 + ( themeSettings.mainFontSize - 20)
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
                    right: parent.right
                    leftMargin: 10
                    rightMargin: 10
                }

                text: modelData.Description
                wrapMode: Text.WordWrap
                font.family: themeSettings.font.customFont
                font.pixelSize:  parent.height * 0.2 + ( themeSettings.mainFontSize - 20)
                color: delegateRoot.ListView.isCurrentItem
                    ? themeData.colorTheme[theme].background
                    : themeData.colorTheme[theme].light
            }
        }

        
    }


}
