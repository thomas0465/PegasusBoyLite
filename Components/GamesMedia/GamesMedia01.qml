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

    // Image that never blanks when its source changes: the new source loads in a hidden
    // second Image, and the old picture stays on screen until the swap. Null/Error also
    // count as finished, so a game with no image correctly shows nothing.
    component StableImage: Item {
        id: si

        property url source
        property var current: imgA

        readonly property real paintedWidth: current.paintedWidth
        readonly property real paintedHeight: current.paintedHeight
        readonly property int status: current.status

        // Fired whenever a new source is requested or a layer's load state changes;
        // the parent decides when to swap so several images can change together.
        signal activity()

        // The layer a new source is currently loading into (null when nothing is pending).
        property var pending: null

        // true when nothing is waiting, or the pending layer has finished (Ready/Null/Error)
        function isReady() {
            return pending === null || pending.status !== Image.Loading
        }

        // show the pending layer (if any) and release the old one
        function commit() {
            if (pending !== null) {
                var old = current
                current = pending
                pending = null
                old.source = ""
            }
        }

        onSourceChanged: {
            pending = (current === imgA) ? imgB : imgA
            pending.source = source
            activity()
        }

        Image {
            id: imgA
            anchors.fill: parent
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            visible: si.current === imgA
        }
        Image {
            id: imgB
            anchors.fill: parent
            asynchronous: true
            fillMode: Image.PreserveAspectFit
            visible: si.current === imgB
        }

        Connections {
            target: imgA
            function onStatusChanged() { si.activity() }
        }
        Connections {
            target: imgB
            function onStatusChanged() { si.activity() }
        }
    }


    // Swap both images in together, only once both have finished loading.
    // (interval 0: lets both sources register their change before checking, so a cached
    //  image that finishes instantly can't swap alone)
    Timer {
        id: swapTimer
        interval: 0
        onTriggered: {
            if (gamesMediaScreenshot.isReady() && gamesMediaTitle.isReady()) {
                gamesMediaScreenshot.commit()
                gamesMediaTitle.commit()
            }
        }
    }

    StableImage {
        id: gamesMediaScreenshot
        onActivity: swapTimer.restart()

        width: (singleimageview == 2) ? root.width: parent.width/1.05;
        height: (singleimageview == 2) ? root.height: (parent.height +marginoffset)/2
        x: (singleimageview == 2) ? parent.width - (root.width): 0;
        y: (singleimageview == 2) ? -(root.height - marginoffset - parent.height - 23): parent.height/2 + 5 + (marginoffset/2);


        source: (imagetype) ? currentGame.assets.screenshot || currentGame.assets.background : currentGame.assets.background || currentGame.assets.screenshot
        opacity: (singleimageview == 1) ? 0: ((!enlargeBadge || !contentOpen) ? 1 : 0);

    Rectangle {
        property int bw: Math.max(Math.round(parent.width * 0.002), 2)

        // Sit the frame *outside* the painted image so the border never
        // paints over the top/bottom rows of pixels.
        width: Math.ceil(parent.paintedWidth) + bw * 2 - 3
        height: Math.ceil(parent.paintedHeight) + bw * 2 - 3
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2)
        color: "transparent"
        border.color: themeData.colorTheme[theme].primary
        border.width: bw

        visible: parent.status === Image.Ready
        opacity: themeSettings.imageBorder && singleimageview == 0 ? 1 : 0
    }

    }


    StableImage {
        id: gamesMediaTitle
        onActivity: swapTimer.restart()
        width: (singleimageview == 1) ? root.width: parent.width/1.05;
        height: (singleimageview == 1) ? root.height: (parent.height +marginoffset)/2
        x: (singleimageview == 1) ? parent.width - (root.width): 0;
        y: (singleimageview == 1) ? -(root.height - marginoffset - parent.height - 23): -5

       	source: (imagetype) ? primary || secondary: secondary|| primary
        opacity: (singleimageview == 2) ? 0: 1;

    Rectangle {
        property int bw: Math.max(Math.round(parent.width * 0.002), 2)

        width: Math.ceil(parent.paintedWidth) + bw * 2 - 3
        height: Math.ceil(parent.paintedHeight) + bw * 2 - 3
        x: Math.round((parent.width - width) / 2)
        y: Math.round((parent.height - height) / 2 )
        color: "transparent"
        border.color: themeData.colorTheme[theme].primary
        border.width: bw

        visible: parent.status === Image.Ready
        opacity: themeSettings.imageBorder && singleimageview == 0 ? 1 : 0
    }
    }


    //Game name text
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