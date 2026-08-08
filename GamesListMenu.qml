import QtQuick 2.15
import SortFilterProxyModel 0.2
import QtGraphicalEffects 1.12
import QtMultimedia 5.9

import "Logger.js" as Logger
import "Components/Delegates"
import "Components/Generic"
import "Components/SubMenu"
import "Components/GamesMedia"

FocusScope {
    property alias gamesListModel: collectionsMenuRoot.gamesListModel
    property alias subMenuModel: collectionsMenuRoot.subMenuModel
    property alias subMenuEnable: collectionsMenuRoot.subMenuEnable

    property alias collectionsMenuListView: collectionsMenuRoot.collectionsMenuListView
    property alias subMenuIndex: collectionsMenuRoot.subMenuIndex

    property alias menuName: collectionsMenuRoot.menuName

    property alias filterOnlyFavorites: collectionsMenuRoot.filterOnlyFavorites
    property alias filterByDate: collectionsMenuRoot.filterByDate
    
    property alias currentCollection: collectionsMenuRoot.currentCollection

    property bool imagetype2:true
    property bool imagebigview2:true
    property int singleimageview2: 0

    property bool pagecreated: false
    property bool viewcreated:false

    property bool favFilter: false
    property bool recentFilter: false
    property bool setplace: true

    property bool keyup: true
    

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

	SoundEffect {
		id: favSound;
		source: 'assets/sound/favo.wav';
		volume: .6 ;
	}

    Item {

        id: collectionsMenuRoot
        width: parent.width
        height: parent.height

        property alias collectionsMenuListView: collectionsMenuLoader.item
        property alias gamesListView: gamesListLoader.item
        
        required property string menuName

        required property bool subMenuEnable
        property var subMenuModel: []
        property int subMenuIndex: 0
	    property int place: 0
        property int placeCollection: 0
        property int subplace: 0

        required property var gamesListModel

        property bool filterOnlyFavorites: false
        property bool filterByDate: false

        property var currentCollection: {
            return subMenuModel.get(collectionsMenuLoader.item.currentIndex)
//return subMenuModel.get(subMenuModel.mapToSource(collectionsMenuLoader.item.currentIndex));
        }

        property var currentGame: { 
            return gamesListModel.get(gamesListModelLoader.item.mapToSource(gamesListLoader.item.currentIndex))
        }


        Keys.onPressed: {
            // A weird issue where when you launch a game it spams auto repeat when Pegasus loads back
            if (event.isAutoRepeat) {
                return
            }

            //wrap from top to bottom
            if (event.key == Qt.Key_Up && subMenuEnable && themeSettings.listwrap) {
		        event.accepted = true;
                gamesListLoader.item.currentIndex = gamesListModelLoader.item.count - 1
                return;
            }

            if (event.key == Qt.Key_Down && subMenuEnable && themeSettings.listwrap) {
		        event.accepted = true;
                gamesListLoader.item.currentIndex = 0
                return;
            }

            //change collections
            if (event.key == Qt.Key_Left && subMenuEnable) {
		        event.accepted = true;
                if (collectionsMenuLoader.item.listView.currentIndex - 1 >= 0) {
		            viewcreated = false
                    pagecreated = true
                    collectionsMenuLoader.item.listView.decrementCurrentIndex();

                    if(gamesListLoader.item.currentIndex >= 0 && setplace){
                        place = gamesListLoader.item.currentIndex
                    }

                    if(currentCollection.name == "♥ Favorites"){
                        favFilter = true
                    }
                    if(currentCollection.name != "♥ Favorites"){
                        favFilter = false
                    }

                    if(currentCollection.name == "Recent"){
                        recentFilter = true
                    }
                    if(currentCollection.name != "Recent"){
                        recentFilter = false
                    }

                    // Hacky force refresh of game media
                    gamesMediaLoader.active = false
                    gamesMediaLoader.active = true
                    gamesListLoader.active = false
                    gamesListLoader.active = true

                    gamesListLoader.item.currentIndex = place;

                    if(place >= gamesListModelLoader.item.count -1) {
                        gamesListLoader.item.currentIndex = gamesListModelLoader.item.count -1

                        setplace = false
                    }

                    viewcreated = true
                    
                    
                    Logger.debug("GamesListMenu:keys:left:currentSubMenu:" + currentCollection.name)
                    if(themeSettings.soundsmenu){
                        navSound.play();
                    }
                }	


		
                return;
            }
            
            if (event.key == Qt.Key_Right && subMenuEnable) {
                event.accepted = true;
                if (collectionsMenuLoader.item.listView.currentIndex + 1 < collectionsMenuLoader.item.listView.count) {
                    viewcreated = false
                    pagecreated = true

                    collectionsMenuLoader.item.listView.incrementCurrentIndex();
                        
                    if(gamesListLoader.item.currentIndex > 0 && setplace){
                        place = gamesListLoader.item.currentIndex
                    }

                    if(currentCollection.name == "♥ Favorites"){
                        favFilter = true
                    }
                    if(currentCollection.name != "♥ Favorites"){
                        favFilter = false
                    }

                    if(currentCollection.name == "Recent"){
                        recentFilter = true
                    }
                    if(currentCollection.name != "Recent"){
                        recentFilter = false
                    }
    
                    // Hacky force refresh of game media
                    gamesMediaLoader.active = false
                    gamesMediaLoader.active = true
                    gamesListLoader.active = false
                    gamesListLoader.active = true

                    gamesListLoader.item.currentIndex = place;
                    if(place > gamesListModelLoader.item.count -1) {
                        gamesListLoader.item.currentIndex = gamesListModelLoader.item.count -1

                        setplace = false
                    }

                    viewcreated = true

                    Logger.debug("GamesListMenu:keys:right:currentSubMenu:" + currentCollection.name)
                    if(themeSettings.soundsmenu){
                        navSound.play();
                    }
                }
		
                return;
            }

            //switch images
            if (api.keys.isDetails(event)) {
                event.accepted = true;
                if(keyup){
                    if(imagetype2){
                        imagetype2 = false;  
                    }else{
                        imagetype2 = true;
                    }
                }
                keyup = false
                return;
	       }

            //enlarge images
            if (api.keys.isCancel(event)) {
                event.accepted = true;
                 if(keyup){
                    if(singleimageview2 == 0){
                        singleimageview2 = 1;
                    }else if(singleimageview2 == 1){
                        singleimageview2 = 2;
                    }else if(singleimageview2 == 2){
                        singleimageview2 = 0;
                    }
                }
                keyup = false
                return;
		    }

            

            //favorite game
            if (api.keys.isFilters(event)) {
                event.accepted = true;
                if(keyup){
                    if(themeSettings.soundsmenu){
                        favSound.play();
                    }
                    gamesListModel.get(gamesListModelLoader.item.mapToSource(gamesListLoader.item.currentIndex)).favorite =
                        !gamesListModel.get(gamesListModelLoader.item.mapToSource(gamesListLoader.item.currentIndex)).favorite  
                    if(collectionsMenuLoader.item.listView.currentIndex == 0){
                    gamesMediaLoader.active = false
                    gamesMediaLoader.active = true
                    }
                } 
                keyup = false
                return;
            }
	    
            //launch game
            if (api.keys.isAccept(event)) {
                event.accepted = true;
                Logger.info("GamesListMenu:keys:accept:launchingGame:" + currentGame.title);
                currentGame.launch();
                return;
            }


            /////////////
            if (api.keys.isPrevPage(event)) {
                event.accepted = true;

                //go to favs from other collection
                if(collectionsMenuLoader.item.listView.currentIndex != 0){
                    viewcreated = false
                    pagecreated = true
                    favFilter = true
                    recentFilter = false


                    if(gamesListLoader.item.currentIndex >= 0 && setplace){
                        place = gamesListLoader.item.currentIndex
                    
                    }

                    placeCollection = collectionsMenuLoader.item.listView.currentIndex

                    collectionsMenuLoader.item.listView.currentIndex = 0

                    gamesMediaLoader.active = false
                    gamesMediaLoader.active = true
                    
                    gamesListLoader.item.currentIndex = place;

                    if(place > gamesListModelLoader.item.count -1) {
                        gamesListLoader.item.currentIndex = gamesListModelLoader.item.count -1
                event.accepted = true;

                        setplace = false
                    }
                
                    viewcreated = true
                    if(themeSettings.soundsmenu){
                        navSound.play();
                    }

                //go from favs to other collection
                }else{
                    viewcreated = false
                    pagecreated = true
                    favFilter = false
                    
                    if(placeCollection == 1 && themeSettings.lastPlayedDays > 0){
                        recentFilter = true
                    }else{
                        recentFilter = false
                    }

                    if(gamesListLoader.item.currentIndex >= 0 && setplace){
                        place = gamesListLoader.item.currentIndex
                    
                    }

                    collectionsMenuLoader.item.listView.currentIndex = placeCollection

                    gamesMediaLoader.active = false
                    gamesMediaLoader.active = true
                    
                    gamesListLoader.item.currentIndex = place;

                    if(place > gamesListModelLoader.item.count -1) {
                        gamesListLoader.item.currentIndex = gamesListModelLoader.item.count -1
                event.accepted = true;

                        setplace = false
                    }
                
                    viewcreated = true
                    if(themeSettings.soundsmenu){
                        navSound.play();
                    }

                }   
	            return
            
            }
        }

 Keys.onReleased: {
            if (api.keys.isPageUp(event)) {
                event.accepted = true;
                var count = gamesListLoader.item.model.count;
                var index = gamesListLoader.item.currentIndex - 10;
                if (index < 0) {index = 0;}
                gamesListLoader.item.currentIndex = index;
                return;
            }

            if (api.keys.isPageDown(event)) {
                event.accepted = true;
                var count = gamesListLoader.item.model.count;
                var index = gamesListLoader.item.currentIndex + 10;
                if (index >= count) {index = count - 1;}
                gamesListLoader.item.currentIndex = index;
                return;
            }

            //prevent autorepeat
            if (api.keys.isCancel(event) || api.keys.isDetails(event) || api.keys.isFilters(event)){
                keyup = true
                return;
            }
}

        Loader {
            id: collectionsMenuLoader
            sourceComponent: collectionsMenuListView
            active: subMenuEnable

            width: parent.width * .96
            height: (subMenuEnable) ? parent.height * (themeSettings.subMenuHeight / 100) : parent.height * (themeSettings.subMenuEmptyHeight / 100)
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.02

            onStatusChanged: {
                if (collectionsMenuLoader.status == Loader.Ready) {
                    Logger.info("GamesListMenu:collectionsMenuLoader:LoaderReady")

                    Logger.info("GamesListMenu:collectionsMenuListView:onCompleted:index:" + item.model.get(themeSettings["menuIndex_subMenu"]).name)

                    let index = 0
                    if (item.model.get(themeSettings["menuIndex_subMenu"]).name === themeSettings["menuIndex_subMenu_name"]) {
                        index = themeSettings["menuIndex_subMenu"]
                    }
                    item.moveIndex(index)
                    
                    if(currentCollection.name == "♥ Favorites"){
                        favFilter = true
                    }
                    if(currentCollection.name != "♥ Favorites"){
                        favFilter = false
                    }

                    if(currentCollection.name == "Recent"){
                        recentFilter = true
                    }
                    if(currentCollection.name != "Recent"){
                        recentFilter = false
                    }
                    
                    gamesListModelLoader.active = true

                }
            }
        }


        Component {
            id: collectionsMenuListView

            SubMenu {
                focus: false
                opacity: (viewcreated)? 1 : 0
                model: subMenuModel

                
                textName: {
                    if (themeSettings.collectionShortNames) { return "shortName"};
                        return "name";
                    }
                

                Component.onDestruction: {
                    themeSettings["menuIndex_subMenu_name"] = collectionsMenuRoot.currentCollection.name; 
                    themeSettings["menuIndex_subMenu"] = currentIndex; 
                }

                Component.onCompleted: {
                    Logger.info("GamesListMenu:collectionsMenuListView:onCompleted")
                }
                
                
                
            }
        }

        Loader {
            id: gamesListModelLoader
            sourceComponent: gamesListProxyModel
            active: subMenuEnable ? false : true

            onStatusChanged: {
                if (gamesListModelLoader.status == Loader.Ready) {
                    Logger.info("GamesListMenu:gamesListModelLoader:LoaderReady")
                    gamesListLoader.active = true
                }

            }
        }


        Component {
            id: gamesListProxyModel
            SortFilterProxyModel {
                sourceModel: gamesListModel

                delayed: false
                filters: [
                    ValueFilter {
                        enabled: (collectionsMenuRoot.filterOnlyFavorites || favFilter)
                        roleName: "favorite"
                        value: true
                    },
                    RangeFilter {
                        enabled: (collectionsMenuRoot.filterByDate || recentFilter)
                        roleName: "playCount"
                        minimumValue: 1
                    },
                    ExpressionFilter {
                        enabled: (collectionsMenuRoot.filterByDate || recentFilter) 
                        expression: {
                            var dateOffset = (24 * 60 * 60 * 1000) * themeSettings.lastPlayedDays;
                            var myDate = new Date();
                            myDate.setTime(myDate.getTime() - dateOffset);
                            return (modelData.lastPlayed > myDate ? true : false);
                        }
                    }
                ]
                proxyRoles: [
                    ExpressionRole {
                        name: "lastPlayedEpoch"
                        expression: model.lastPlayed.getTime()
                    }
                ]
                sorters: [
                    RoleSorter {
                        enabled: (!collectionsMenuRoot.filterByDate && !recentFilter)
                        roleName: "sortBy"
                    },
                    FilterSorter {
                        enabled: themeSettings.gamesFavoritesOnTop && (!collectionsMenuRoot.filterByDate && !recentFilter)
                        priority: 1000
                        filters: [
                            ValueFilter {
                                roleName: "favorite"
                                value: true
                            }
                        ]
                    },
                    RoleSorter {
                        enabled: (collectionsMenuRoot.filterByDate || recentFilter)
                        roleName: "lastPlayedEpoch"
                        sortOrder: Qt.DescendingOrder
                    }
                ]

                onModelReset: {
                    Logger.info("GamesListMenu:gamesListProxyModel:modelReset")
                }

                onLayoutChanged: {
                    Logger.info("GamesListMenu:gamesListProxyModel:layoutChanged")
                }

                Component.onCompleted: {
                    Logger.info("GamesListMenu:gamesListProxyModel:onComplete")
                }

            }
        }

        Loader {
            id: gamesListLoader

            focus: true
            sourceComponent: gamesListView
            active: false
           
            anchors.top: collectionsMenuLoader.bottom
            anchors.topMargin: parent.height * (themeSettings.subMenuMargin / 100)
            anchors.left: parent.left
            anchors.leftMargin: parent.width * 0.02
            anchors.bottom:parent.bottom

            width: parent.width * (themeSettings.itemListWidth / 100)

        }

        Component {
            id: gamesListView
            ItemList {
                focus: true

                rows: themeSettings.itemListRows

                model: gamesListModelLoader.item
                delegate: gamesListDelegate.delegate

                Component.onCompleted: {
                    //const isGame = (element) => element.title === themeSettings["menuIndex_gamesList_name"]
                    //let index = utils.findModelIndex(gamesListView.model, isGame); 
                    let index = 0;
                    Logger.info("GamesListMenu:gamesListView:onCompleted:modelAtIndex:" + model.get(themeSettings["menuIndex_gamesList"]).title)
                    if (model.get(themeSettings["menuIndex_gamesList"]).title === themeSettings["menuIndex_gamesList_name"]) {
                        index = themeSettings["menuIndex_gamesList"]
                    }
                    Logger.info("GameListMenu:gameListView:onCompleted:savedIndex:" + index);
                    moveIndex(index);

                    
                    if(!pagecreated){
                        viewcreated = true
                    }
			
                }

               onCurrentIndexChanged:{Logger.info("gamesListView:modelEpoch:" + model.get(currentIndex).lastPlayedEpoch)
		
	        if(viewcreated && themeSettings.soundslist && keyup){
                navSound2.play()
            }

	        if(viewcreated && keyup){
                setplace = true
            }
 		}


                Component.onDestruction: { 
                    Logger.debug("GamesListMenu:gamesListView:currentGame:" + collectionsMenuRoot.currentGame.title) 
                    themeSettings["menuIndex_gamesList_name"] = collectionsMenuRoot.currentGame.title
                    themeSettings["menuIndex_gamesList"] = currentIndex
                }

            }
        }

        GamesListDelegate {
            id: gamesListDelegate
            rows: gamesListLoader.item.rows
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
                anchors.bottomMargin: 1.5

                opacity: (themeSettings.showClock) ? 1 : 0
                font.family: "HackRegular"
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
                anchors.bottomMargin: 1.5

                opacity: (themeSettings.showBattery) ? 1 : 0
                font.family: "HackRegular"
                font.pointSize: themeSettings.footerfontsize
                color: themeData.colorTheme[theme].light;
            }  
        }


//counter
    Rectangle {
            width: t2.width + 2.5
            height:t2.height + 3
            y:parent.height + 5

            anchors.left: parent.left
            anchors.leftMargin: (themeSettings.showBattery) ? (parent.width * (themeSettings.itemListWidth / 100)) - (t2.width/1.2) - t3.width - 2.5 - 10:  (parent.width * (themeSettings.itemListWidth / 100)) - (t2.width/1.2)

            color: themeData.colorTheme[theme].background
            opacity: 1
            Text {

                id: t2
                text: (gamesListLoader.item.currentIndex + 1) + "/" + gamesListModelLoader.item.count

                anchors.left: parent.left;
                anchors.bottom:parent.bottom;
                anchors.bottomMargin: 1.5

                opacity: (themeSettings.gamesListCounter) ? 1 : 0
                font.family: "HackRegular"
                font.pointSize: themeSettings.footerfontsize
                color: themeData.colorTheme[theme].light;
            }  
        }

        	//collections scroll bar
        Rectangle {

            width: 8
            height: (subMenuEnable) ? parent.height * (themeSettings.subMenuHeight / 100) + (parent.height * (themeSettings.subMenuMargin / 100)) : 0

            anchors {
            top: parent.top
            left: parent.left
            leftMargin: parent.width * 0.02
            }


            opacity: 1
            color: themeData.colorTheme[theme].background

            Rectangle {

                width: 8
                height: Math.round(parent.height * .3)

                y: ((parent.height - (parent.height * .3)) * ((collectionsMenuLoader.item.currentIndex + 1) /  (collectionsMenuLoader.item.listView.count)));

                opacity: (themeSettings.collectionscroll && collectionsMenuLoader.item.listView.count - 1 >= themeSettings.subMenuColumns) ? 1: 0;
                color: (viewcreated) ? themeData.colorTheme[theme].light: themeData.colorTheme[theme].background
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
        //    opacity: (themeSettings.gamesListCounter || themeSettings.showClock || themeSettings.showBattery) ? 1 : 0
        }


	//for image big view, darken the background by 85%, do not darken the submenu
        Rectangle {
        id: mediabackground
	    opacity:  (singleimageview2 == 0) ? 0 : 0.85
        width: root.width
	    height: root.height
	    x: 0
	    //y:(subMenuEnable) ? parent.height * (themeSettings.subMenuHeight / 100) + (parent.height * (themeSettings.subMenuMargin / 100)) : parent.height * (themeSettings.subMenuEmptyHeight / 100)
        y:0
	    color: themeData.colorTheme[theme].background
        }



        Loader {
            id: gamesMediaLoader
            sourceComponent: gamesMedia
            asynchronous: true
            visible: gamesListLoader.item.model.count > 0
            active: gamesListLoader.status == Loader.Ready
            
            anchors.top: collectionsMenuLoader.bottom
            anchors.topMargin: parent.height * 0.02
            anchors.right: parent.right
            anchors.left: gamesListLoader.right
            anchors.leftMargin: parent.width * 0.02
            anchors.bottom: parent.bottom
        }
	    
        Component {
            id: gamesMedia
            GamesMedia01 {
          	currentGame: gamesListLoader.item.model.get(gamesListLoader.item.currentIndex); 
		        imagetype: imagetype2;
                imagebigview: imagebigview2;
                singleimageview: singleimageview2;
        	}
        }

        Component.onCompleted: {
            Logger.info("GamesListMenu:collectionsMenuRoot:onComplete")
        }

    }



}
