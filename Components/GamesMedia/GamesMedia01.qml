import QtQuick 2.15
import QtGraphicalEffects 1.12

import "../Settings"
import "../Achievements"

Item {

    required property var currentGame
    required property bool imagetype
    required property bool imagebigview
    required property int singleimageview
    required property bool enlargeBadge
    required property bool contentOpen

    property int marginoffset: (themeSettings.gamesListCounter || themeSettings.showClock || themeSettings.showBattery) ? themeSettings.footerfontsize + 5 : 0

    property var primary: (themeSettings.primaryAsset == "Title Screen") ? currentGame.assets.titlescreen : currentGame.assets.boxFront 
    property var secondary: (themeSettings.primaryAsset == "Title Screen") ? currentGame.assets.boxFront : currentGame.assets.titlescreen


    Image {
        id: gamesMediaScreenshot

        width: (singleimageview == 2) ? root.width: parent.width/1.05;
        height: (singleimageview == 2) ? root.height: (parent.height +marginoffset)/2;
        x:(singleimageview == 2) ? parent.width - (root.width): 0;
        y:(singleimageview == 2) ? -(root.height - marginoffset - parent.height - 12): parent.height/2 + 5 + (marginoffset/2);

        asynchronous: true
        fillMode: Image.PreserveAspectFit

        source: (imagetype) ? currentGame.assets.screenshot || currentGame.assets.background : currentGame.assets.background || currentGame.assets.screenshot
        opacity: (singleimageview == 1) ? 0: ((!enlargeBadge || !contentOpen) ? 1 : 0);

    }


    Image {
        id: gamesMediaTitle
        width: (singleimageview == 1) ? root.width: parent.width/1.05;
        height: (singleimageview == 1) ? root.height: (parent.height +marginoffset)/2;
        x:(singleimageview == 1) ? parent.width - (root.width): 0;
        y:(singleimageview == 1) ? -(root.height - marginoffset - parent.height - 12): 0

        asynchronous: true
        fillMode: Image.PreserveAspectFit
       	source: (imagetype) ? primary || secondary: secondary|| primary
        opacity: (singleimageview == 2) ? 0: 1;
    }



    //Text {
    //    text: (themeSettings.replacePar) ? currentGame.title.replace(/\(([^()]+)\)/g,""): currentGame.title
    //color: themeData.colorTheme[theme].primary;
    //    opacity:  (singleimageview == 0) ? 0: 1;
	//width: root.width / 2.1
    //    x: parent.width - ((root.width*.98))
	//y: parent.height - 17 + marginoffset
	//font.bold: true

    //style: Text.Outline; styleColor: "black" 
	//wrapMode:Text.WordWrap

	//fontSizeMode: Text.HorizontalFit
 	//font.pointSize: themeSettings.footerfontsize +5 
    //    font.family: themeSettings.font.customFont
    //}




}