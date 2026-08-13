import QtQuick 2.15

Item {

    required property int rows

    property alias delegate: gamesListDelegate

    property string textName: "title"

    Component {
        id: gamesListDelegate


        Rectangle {
            id: gamesListRect

            property int rows: 1

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
                    leftMargin: parent.width * 0.02
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

            Text {
                id: gamesListText

                anchors.left: gamesListFavorite.right
                anchors.leftMargin: parent.width * 0.02
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
