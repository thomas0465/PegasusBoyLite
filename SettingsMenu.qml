import QtQuick 2.15
import QtGraphicalEffects 1.12
import QtMultimedia 5.9

import "Logger.js" as Logger
import "Components/Generic"
import "Components/Delegates"
import "Components/SubMenu"
import "Components/GamesMedia"
import "Components/Settings"

FocusScope {

	SoundEffect {
		id: navSound;
		source: 'assets/sound/click.wav';
		volume: .2;
	}

	SoundEffect {
		id: navSound2;
		source: 'assets/sound/click.wav';
		volume: .2;
	}

    Loader {
        id: settingsDataLoader
        sourceComponent: settingsDataComponent

        onStatusChanged: {
            if (status == Loader.Ready) {
                // initiate settings menu loader
                settingsMenuLoader.active = true
            }
        }
    }

    Component {
        id: settingsDataComponent

        SettingsOptionsModel {
            // id: settingsData
        }
    }
    property alias settingsData: settingsDataLoader.item
    property bool viewcreated:false

    Loader {
        id: settingsMenuLoader
        sourceComponent: settingsMenuComponent
        active: false

        focus: true

        width: parent.width
        height: parent.height

    }

    Component {
        id: settingsMenuComponent

        Item {
            id: settingsMenuRoot

            focus: true

            property alias collectionsMenuListView: collectionsMenuListView

            property bool settingsOptionsActive: false

            Keys.onPressed: {



                if (event.key == Qt.Key_Left &&  !settingsOptionsActive) {
                    event.accepted = true;
			viewcreated = false;
			if(collectionsMenuListView.listView.currentIndex > 0 && themeSettings.soundsmenu){
		    navSound.play();
			}
                    collectionsMenuListView.listView.decrementCurrentIndex();
	            viewcreated = true;
                    return;
                }
                
                if (event.key == Qt.Key_Right && !settingsOptionsActive) {
                    event.accepted = true;
			viewcreated = false;
			if(collectionsMenuListView.listView.currentIndex < 3 && themeSettings.soundsmenu){
		    navSound.play();
			}
                    collectionsMenuListView.listView.incrementCurrentIndex()
			viewcreated = true;
                    return;
                }

                if (api.keys.isAccept(event)) {
                    event.accepted = true;
                    if (settingsOptionsActive == false) {
                        settingsOptionsActive = true;
                        settingsOptions.forceActiveFocus();
                    }
                    else {
                        settingsOptionsActive = false;
                        settingsListView.forceActiveFocus();
                    }
                    return;
                }

                if (api.keys.isCancel(event)) {
                    event.accepted = true;
                    settingsOptionsActive = false;
                    settingsListView.forceActiveFocus();
                    return;
                }

            }

            SubMenu {
                id: collectionsMenuListView

                focus: false

                //width: (parent.width * (themeSettings.itemListWidth / 100))
		width:parent.width * .96
                
		height: parent.height * (themeSettings.subMenuHeight / 100)


                anchors.left: parent.left
               anchors.leftMargin: parent.width * 0.02

                model: settingsData.settingsListModel
		settingsview: true

            }

            //main left side settings list
            ItemList {
                id: settingsListView
                focus: settingsMenuRoot.focus
                rows: themeSettings.itemListRows

                anchors.top: collectionsMenuListView.bottom
                anchors.topMargin: parent.height * (themeSettings.subMenuMargin / 100)
                anchors.left: parent.left
                anchors.leftMargin: parent.width * 0.02
                anchors.bottom: parent.bottom

                width: parent.width * (themeSettings.itemListWidth / 100)

                model: collectionsMenuListView.model.get(collectionsMenuListView.currentIndex).settings
                delegate: settingsListDelegate.delegate
            }

            GamesListDelegate {
                id: settingsListDelegate
                rows: settingsListView.rows
                textName: "name"
            }

            Item {
                id: settingsInfo

                property int rows: 4



                anchors {
                    top: collectionsMenuListView.bottom
                    topMargin: parent.height * 0.02
                    left: settingsListView.right
                    leftMargin: parent.width * 0.02
                    bottom: settingsOptions.top 
                    bottomMargin: parent.height * 0.02
                    right: parent.right
                    rightMargin: parent.width * 0.02
                }

                Text {
                    id: settingsInfoDescription

                    anchors.fill: parent

                    font.family: themeSettings.font.customFont
                    font.pixelSize:parent.height  * 0.1
                    color: themeData.colorTheme[theme].primary

                    wrapMode: Text.WordWrap

                    text: {
			        //description
                        return settingsListView.model.get(settingsListView.currentIndex).description;
                    }
		            
                    onTextChanged: {
				        if(viewcreated && themeSettings.soundslist){navSound2.play()}
				    }
                }

                Text {
                    id: settingsInfoDefault

                    anchors.bottom: parent.bottom

                    font.family: themeSettings.font.customFont
                    font.pixelSize: parent.height * .08
                    color: themeData.colorTheme[theme].light


                    text: {
                        if (settingsListView.model.get(settingsListView.currentIndex).default !== ""){
                            return "Default: " +
                            settingsListView.model.get(settingsListView.currentIndex).default;
                        }else{
                            return ""
                        }

                    }

Component.onCompleted: viewcreated = true;
		

                }
            }

                    Timer {
        interval: 1000
        running: true
        repeat: true

        onTriggered: {
            var date = new Date();
            var options = {
                hour: "numeric",
                minute: "numeric",
            }
            t.text = date.toLocaleTimeString('en-US')
        }
    }


//Clock
        Rectangle {
            width: t.width + 2.5
            height:t.height + 3
            y:parent.height + 5

            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.02
            color: themeData.colorTheme[theme].background
            opacity: 1
            Text {
                id: t
                text: new Date().toLocaleTimeString('en-US')

                anchors.left: parent.left;
                anchors.bottom:parent.bottom;
                anchors.bottomMargin: 1.5 + themeSettings.footeroffset

                opacity: (themeSettings.showClock) ? 1 : 0
                font.family: themeSettings.font.customFont
                font.pointSize: themeSettings.footerfontsize
                color: themeData.colorTheme[theme].light;
            }  
        }

//battery

    Rectangle {
            width: t3.width + 2.5
            height:t3.height + 3
            y:parent.height + 5

            anchors.left: parent.left
            anchors.leftMargin: (parent.width * (themeSettings.itemListWidth / 100)) - (t3.width/1.2)

            color: themeData.colorTheme[theme].background
            opacity: 1
            Text {

                id: t3
                text: (api.device.batteryPercent * 100).toFixed(0) + "%";

                anchors.left: parent.left;
                anchors.bottom:parent.bottom;
                anchors.bottomMargin: 1.5 + themeSettings.footeroffset

                opacity: (themeSettings.showBattery) ? 1 : 0
                font.family: themeSettings.font.customFont
                font.pointSize: themeSettings.footerfontsize
                color: themeData.colorTheme[theme].light;
            }  
        }

                Rectangle {
            width: parent.width + 1000
            height: 2
            x: -100
            y: parent.height * (themeSettings.subMenuHeight / 100) + (parent.height * (themeSettings.subMenuMargin / 100)) - 2
            color: themeData.colorTheme[theme].light
        }

        Rectangle {
            width: (parent.width * (themeSettings.itemListWidth / 100)) + 13
            height: 2
            x: 0
            y: parent.height
            color: themeData.colorTheme[theme].light

            opacity: 0
            //opacity: (themeSettings.gamesListCounter || themeSettings.showClock || themeSettings.showBattery) ? 1 : 0
        }

            SettingsOptions {
                id: settingsOptions

                focus: false

                height: parent.height * 0.4

                anchors {
                    left: settingsListView.right
                    leftMargin: parent.width * 0.05
                    bottom: parent.bottom
                    right: parent.right
                    rightMargin: parent.width * 0.05
                }

                model: settingsListView.model.get(settingsListView.currentIndex)

            }

        }
    }
}
