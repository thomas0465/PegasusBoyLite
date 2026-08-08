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

		verticalAlignment: Text.AlignCenter; 

                font.family: themeSettings.font.customFont
                font.pixelSize: subMenuListView.fontSize
                font.bold:  subMenuTextRect.ListView.isCurrentItem ? true: false
                color: subMenuTextRect.ListView.isCurrentItem ? themeData.colorTheme[theme].primary : themeData.colorTheme[theme].light
                //color: themeData.colorTheme[theme].primary
                font.capitalization: Font.AllUppercase
                
opacity: 1
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
