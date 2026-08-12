import QtQuick 2.15
import QtMultimedia 5.9

import "../Scrollbar"

// Right-side popup listing RetroAchievements for the currently open game.
// Takes over dpad input while open; Cancel closes it and returns focus
// to games list
//
// open(game) starts the fetch but does NOT show the panel or take focus
// immediately - it only opens once Achievements.qml reports success via
// its achievementsReady signal. On achievementsError, the panel stays
// closed and Achievements.qml's own error banner (rendered inside this
// component, so it's visible regardless of contentOpen) shows the reason.


FocusScope {
    id: achievementsPanelRoot

    property alias listView: listView

	SoundEffect {
		id: navSound;
		source: '../../assets/sound/click.wav';
		volume: .2;
	}

    signal closed()

    property bool contentOpen: false
    property bool enlargeBadge: false
    property int lastRAIndex: 0

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

    function open(game) {
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
            var maxIndex = fetcher.achievementsList.length - 1

            if(achievementsPanelRoot.lastRAIndex > maxIndex){
                listView.currentIndex = maxIndex
            }else{
                listView.currentIndex = achievementsPanelRoot.lastRAIndex
            }

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

        if (api.keys.isCancel(event)) {
            event.accepted = true;
            enlargeBadge = !enlargeBadge
            return
        }

        if (api.keys.isAccept(event)) {
            event.accepted = true;
            achievementsPanelRoot.close()
            return
        }

        if (event.key === Qt.Key_Right) {
            achievementsPanelRoot.close()
            return
        }

        if (event.key === Qt.Key_Left) {
            achievementsPanelRoot.close()
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
        color: "transparent"
        opacity: contentOpen ? 1 : 0
        visible: opacity > 0
        Behavior on opacity { NumberAnimation { duration: 150 } }
    }

    Image {
        id: gameIcon
        visible: contentOpen

        width: achievementsPanelRoot.height/themeSettings.itemListRows * 1.2
        height: achievementsPanelRoot.height/themeSettings.itemListRows * 1.2

        anchors {
            top: parent.top
            topMargin: parent.height * 0.03
            left: parent.left
            leftMargin: parent.width * 0.051
        }

        source: "https://media.retroachievements.org" + fetcher.imageIcon
        fillMode: Image.PreserveAspectFit
        asynchronous: true
        smooth: true
    }

        
    Text {
        id: panelTitleNum
        visible: contentOpen

        anchors {
            top: parent.top
            topMargin: parent.height * 0.03
            right: parent.right
            leftMargin: parent.width * 0.04
            rightMargin: parent.width * 0.045
            
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
            left: gameIcon.right
            right: panelTitleNum.left
            leftMargin: parent.width * 0.01
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
            rightMargin: parent.width * 0.005
            top: parent.top
            bottom: parent.bottom
        }

    }




    ListView {
        id: listView
        visible: contentOpen

        anchors {
            top: panelTitle.bottom
            topMargin: parent.height * 0.09
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: parent.width * 0.04
            rightMargin: parent.width * 0.04

        }
        

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


Image {
    id: currentBadgeImage

    visible: enlargeBadge && contentOpen ? 1 : 0

    width: parent.height/3
    height: parent.height/3
        x: parent.width + (root.width - parent.width - width - (parent.width * 0.08)) / 2

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
                    leftMargin: parent.width * 0.01
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
                        themeData.colorTheme[theme].background
                        : themeData.colorTheme[theme].light
                    )
            }

            Text {
                id: achTitle

                anchors {
                    top: parent.top
                    topMargin: parent.width * 0.02
                    left: badgeImage.right
                    right: pointsText.left
                    leftMargin: parent.width * 0.02
                    rightMargin: parent.width * 0.02
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
                        themeData.colorTheme[theme].background
                        : themeData.colorTheme[theme].light
                    )
            }

            Text {
                id: achDesc

                anchors {
                    top: achTitle.bottom
                    left: badgeImage.right
                    right: pointsText.left
                    leftMargin: parent.width * 0.04
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
