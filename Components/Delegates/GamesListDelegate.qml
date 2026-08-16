import QtQuick 2.15

Item {

    required property int rows

    property alias delegate: gamesListDelegate

    property string textName: "title"

    property var titleOverrides: ({})

    Component {
        id: gamesListDelegate


        Rectangle {
            id: gamesListRect

            property int rows: 1

            //check if current game has cached achievements 
            property bool hasCachedAchievements: {
                var searchTitle = titleOverrides[model[textName]] || model[textName]
                var gameId = api.memory.get("ra_gameid_" + searchTitle)
                if (!gameId) { return false }
                return !!api.memory.get("ra_cache_" + gameId)
            }

            width: ListView.view.width
            height: ListView.view.height / ListView.view.rows

            color: {
                if (activeFocus) 
                { return ListView.isCurrentItem ? 
                    themeData.colorTheme[theme].primary : themeData.colorTheme[theme].background };
                
                return ListView.isCurrentItem ?
                    themeData.colorTheme[theme].light :  "transparent" ;
            }

            Rectangle {
                id: gamesListFavorite

                width: height
                height: gamesListText.font.pixelSize * 0.7

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: hasCachedAchievements && themeSettings.cacheIndicator ? parent.width * 0.01 : parent.width * 0.02
                }

                color: {
                    if (activeFocus) 
                        { return gamesListRect.ListView.isCurrentItem ? 
                            themeData.colorTheme[theme].background : 
                            themeData.colorTheme[theme].primary };

                        gamesListRect.ListView.isCurrentItem ?  
                            themeData.colorTheme[theme].background : 
                            themeData.colorTheme[theme].light;
                }
                visible: model.favorite !== undefined && model.favorite

            }

            //indicator for cached achievements
            Rectangle {
                id: cachedAchievementsDot
                visible: hasCachedAchievements && themeSettings.cacheIndicator

                width: gamesListText.font.pixelSize * 0.1
                height: gamesListText.font.pixelSize * 0.7

                anchors {
                    verticalCenter: parent.verticalCenter
                    //verticalCenterOffset: 10
                    //horizontalCenter: gamesListFavorite.horizontalCenter
                    left: parent.left
                    leftMargin: parent.width * 0.065
                }

                color: gamesListRect.ListView.isCurrentItem
                    ? 
                        (model.favorite !== undefined && model.favorite ? 
                            themeData.colorTheme[theme].background :
                            themeData.colorTheme[theme].background
                        )
                    : (model.favorite !== undefined && model.favorite ? 
                            themeData.colorTheme[theme].light :
                            themeData.colorTheme[theme].light
                        )
            }

            Text {
                id: gamesListText

                anchors.left: gamesListFavorite.right
                anchors.leftMargin: parent.width * 0.025
                anchors.right: gamesListRect.right
                anchors.rightMargin: parent.width * 0
                
                anchors.verticalCenter: parent.verticalCenter

                font.family: themeSettings.font.customFont
                font.pixelSize: parent.height * 0.4 + ( themeSettings.mainFontSize - 20)

		        wrapMode:(themeSettings.wordwrap) ? Text.WordWrap: Text.NoWrap

                color: gamesListRect.ListView.isCurrentItem ? themeData.colorTheme[theme].background : themeData.colorTheme[theme].primary


                text: (themeSettings.replacePar) ? 
                    (themeSettings.replaceBrac ? 
                        model[textName].replace(/\(([^()]+)\)/g,"").replace(/\[[^\]]+\]/g,"")
                        : model[textName].replace(/\(([^()]+)\)/g,"")
                    )
                        :
                     (themeSettings.replaceBrac ? 
                        model[textName].replace(/\[[^\]]+\]/g,"")
                        : model[textName]
                     )                
            }
            
        }
    }
}
