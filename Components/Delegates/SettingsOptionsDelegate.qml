import QtQuick 2.15

Item {
    required property int rows
    property alias delegate: settingsOptionDelegate
    property string textName: "name"


    Component {
        id: settingsOptionDelegate

        Rectangle {
            id: settingsListRect
            property int rows: 1

            width: ListView.view.width
            height: ListView.view.height / ListView.view.rows

            color: {
                if (activeFocus) { return  ListView.isCurrentItem ? themeData.colorTheme[theme].primary : "transparent"}
                return ListView.isCurrentItem ? themeData.colorTheme[theme].secondary : "transparent"
            }

            Text {
                id: settingsNameText

                width: parent.width

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: (font.pixelSize * 0.7) + parent.width * 0.04
                }


                font.family: themeSettings.font.customFont
                font.pixelSize: parent.height * 0.4

                elide: Text.ElideRight
                color: settingsListRect.ListView.isCurrentItem ? themeData.colorTheme[theme].background : themeData.colorTheme[theme].primary

                text: modelData
            }

        }

    }
}
