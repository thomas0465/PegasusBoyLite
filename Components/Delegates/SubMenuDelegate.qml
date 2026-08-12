import QtQuick 2.15
import "../../Logger.js" as Logger

Item {

    property alias delegate: subMenuDelegate
    property string textName: "name"

    Component {
        id: subMenuDelegate

        // property alias textName: subMenuTextRect.textName

        Item {
            id: subMenuTextRect



            width: ListView.view.width / ListView.view.columns
            height: ListView.view.height

            Text {
                id: subMenuText
                text: model[textName]


                font.family: themeSettings.font.customFont
                font.pixelSize: subMenuListView.fontSize
                //font.bold:  subMenuTextRect.ListView.isCurrentItem ? true: false
                opacity:  subMenuTextRect.ListView.isCurrentItem ? 1: (themeData.colorTheme[theme].light == themeData.colorTheme[theme].primary) ? .5 : 1
                color: subMenuTextRect.ListView.isCurrentItem ? 
                    themeData.colorTheme[theme].primary 
                    : themeData.colorTheme[theme].light
                font.capitalization: Font.AllUppercase
		        
                //{

                    //default 1, opacity of options further than 1 away, then opacity of options exactly 1 away from selected option
                    //if (Math.abs(subMenuTextRect.ListView.view.currentIndex - index) > 1) {
                    //    return 0.5;
                    //}
                    //if (Math.abs(subMenuTextRect.ListView.view.currentIndex - index) === 1) {
                    //    return 0.5;
                    //}
                    //return 1.5;
                //}

                anchors {
                    // bottom: parent.bottom
                    //horizontalCenter: parent.horizontalCenter
                    centerIn: parent
                }

            }

        }

    }

}
