import QtQuick 2.15
import SortFilterProxyModel 0.2
import QtMultimedia 5.9

import "Logger.js" as Logger

Item {
    id: rootWindow

        function lightenColor(color, amount) {
            // amount: 0.0 = unchanged, 1.0 = pure white
            return Qt.rgba(
                color.r + (1.0 - color.r) * amount,
                color.g + (1.0 - color.g) * amount,
                color.b + (1.0 - color.b) * amount,
                color.a
            )
        }

        property color backgroundMainColor: themeSettings.backgroundColor == "transparent" ? themeData.colorTheme[theme].background : themeSettings.backgroundColor

        property color resolvedBottomColor: themeSettings.backgroundGradientColor == "transparent" ?
                        backgroundMainColor : themeSettings.backgroundGradientColor

        property color resolvedTopColorBase: themeSettings.backgroundColor == "transparent" ?
                        backgroundMainColor  : themeSettings.backgroundColor

        property color resolvedTopColor: (resolvedTopColorBase === resolvedBottomColor)
            ? lightenColor(resolvedTopColorBase, 0.1)
            : resolvedTopColorBase

        HillsShaderEffect {
            anchors.fill: parent
            opacity: themeSettings.shaderEnable && themeSettings.shaderHillsEnable? 1 : 0
            rotation: themeSettings.shaderHillsInvert ? 180 : 0

            bottomColor: resolvedBottomColor
            topColor: resolvedTopColor
            Rectangle{
                anchors.fill: parent
                color: "#414141ff"
                opacity: 0.2
            }
           
        }



    SoundEffect {
        id: forSound;
        source: 'assets/sound/click.wav';
        volume: .15;
    }

    Keys.onPressed: {

        if (api.keys.isNextPage(event)) {
            event.accepted = true
            if(menuLoader.item.currentIndex == 0){
                menuItem.menuListView.incrementCurrentIndex()
                if((themeSettings.soundsmenu)){
                    forSound.play();
                }
     	    
            }else if(menuLoader.item.currentIndex >= 0){
                menuItem.menuListView.decrementCurrentIndex()
                if((themeSettings.soundsmenu)){
                    forSound.play();
                }
            }
            return
        }

        if (api.keys.isPrevPage(event)) {
            event.accepted = true
            if(menuLoader.item.currentIndex == 0){
                //menuItem.menuListView.incrementCurrentIndex()
                //if((themeSettings.soundsmenu)){
                //    forSound.play();
                //}
     	    
            }else if(menuLoader.item.currentIndex >= 0){
                menuItem.menuListView.decrementCurrentIndex()
                if((themeSettings.soundsmenu)){
                    forSound.play();
                }
            }
            return
        }
    }

    Gradient {
        id: backgroundGradient
        GradientStop { position: themeSettings.backgroundGradientInvert ? 0 : 1
                        ; color: themeSettings.backgroundGradientColor}
        GradientStop { position: themeSettings.backgroundGradientInvert ? 1 : 0
                        ; color: themeSettings.backgroundColor == "transparent" ? themeData.colorTheme[theme].background : themeSettings.backgroundColor}
    }


    Rectangle {
        id: background
        width: parent.width
        height: parent.height
        color: backgroundMainColor
        gradient: themeSettings.backgroundGradientColor == "transparent" ? null: backgroundGradient
        opacity: themeSettings.shaderEnable && themeSettings.shaderHillsEnable? 0 : 1
    }

    property alias menuItem: menuLoader.item
    Loader {
        id: menuLoader
        focus: false
        width: parent.width
        height: 0
        sourceComponent: menuComponent
        y: themeSettings.menuadjust      
        asynchronous: true
    }

    Component {
        id: menuComponent
        Menu {
            id: menu
            focus: menuLoader.focus
            currentIndex: themeSettings["menuIndex_main"]
        }
    }

    Loader {
        id: subHeaderLoader
        focus: false
    }

    property alias contentItem: contentLoader.item
    Loader {
        id: contentLoader
        focus: true
        sourceComponent: collectionsMenu
        asynchronous: true
        anchors {
            top: menuLoader.bottom
            bottomMargin: (themeSettings.gamesListCounter || themeSettings.showClock || themeSettings.showBattery) ? themeSettings.footerfontsize + 3 + (parent.height * 0.03) : parent.height * 0.03 
            bottom: parent.bottom 
            left: parent.left
            right: parent.right
        }
    }

    Component {
        id: collectionsMenu

        Item {
            anchors.fill: parent.fill

            Loader {
                id: collectionsMenuModelLoader
                sourceComponent: collectionsMenuProxyModel
                active: true

                onStatusChanged: {
                    if (collectionsMenuModelLoader.status == Loader.Ready) {
                        gamesListMenuLoader.active = true
                    }
                }
            }

            Component {
                id: collectionsMenuProxyModel

                SortFilterProxyModel {
                    sourceModel: themeData.collectionsListModel
                    delayed: false
                    sorters: [
                        RoleSorter {
                            roleName: "sortBy"
                        }
                    ]
                }
            }

            Loader {
                id: gamesListMenuLoader
                anchors.fill: parent
                focus: contentLoader.focus
                active: false
                sourceComponent: gamesListMenu
            }

            Component {
                id:gamesListMenu

                GamesListMenu {
                    focus: gamesListMenuLoader.focus
                    subMenuEnable: true
                    subMenuModel: collectionsMenuModelLoader.item
                    subMenuIndex: themeSettings.menuIndex_subMenu
                    gamesListModel: currentCollection.games
                    menuName: rootWindow.state
                }
            }
        }
    }

    property int size
    property bool showall

    Component {
        id: settingsMenu

        SettingsMenu {
            focus: contentLoader.focus

            Component.onCompleted:{
                size = themeSettings.menusize
                showall = themeSettings.collectionAllGames
            }
        }
    }

    states: [
        State {
            name: "games"
            when: menuItem.currentIndex == 0
            changes: [
                PropertyChanges {
                    target: contentLoader
                    sourceComponent: collectionsMenu
                }
            ]
        },
        State {
            name: "settings"
            when: menuItem.currentIndex == 1
            PropertyChanges {
                target: contentLoader
                sourceComponent: settingsMenu
            }
        }
    ]

    onStateChanged: {
        if (menuItem !== null) {
            themeSettings["menuIndex_main"] = menuItem.currentIndex;
        }
    }

    Component.onCompleted: {
        if (menuItem !== null) {
            menuItem.currentIndex = themeSettings["menuIndex_main"];
        }
    }
}