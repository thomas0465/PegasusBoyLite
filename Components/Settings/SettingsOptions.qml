import QtQuick 2.15

import "../Generic"
import "../Delegates"
import "../../Logger.js" as Logger

FocusScope {
    id: root

    signal exit()

    // property alias model: settingsListView.model
    property alias model: optionsRoot.settingModel

    onActiveFocusChanged: {
        if (!activeFocus) { return }

        if (optionsRoot.settingModel.type === "text") {
            textInput.forceActiveFocus()
        } else if (optionsRoot.settingModel.type === "action") {
            // No list or text field to delegate to - optionsRoot itself
            //optionsRoot.forceActiveFocus()
            settingsListView.forceActiveFocus()
        } else {
            settingsListView.forceActiveFocus()
        }
    }

    Item {
        id: optionsRoot

        width: parent.width
        height: parent.height

        property var settingModel: []
        property string editSnapshot: ""
        property string actionFeedback: ""
        // property string settingType: ""

        Keys.onReleased: {
            if (optionsRoot.settingModel.type === "action") {
                if (api.keys.isAccept(event)) {
                    runAction(optionsRoot.settingModel.id)
                        settingsOptionsActive = true;
                        settingsListView.forceActiveFocus();
                }
                return
            }
        }

        Keys.onPressed: {

            if (optionsRoot.settingModel.type === "text") {
                if (api.keys.isAccept(event) && !textInput.activeFocus) {
                    
                    textInput.forceActiveFocus()
                    root.exit()
                    return
                }

                if (api.keys.isAccept(event) && textInput.activeFocus) {
                    themeSettings.saveSetting(optionsRoot.settingModel.id, textInput.text)
                    textInput.focus = false
                    return
                }

                if (api.keys.isCancel(event)) {
                    textInput.text = optionsRoot.editSnapshot
                    themeSettings.saveSetting(optionsRoot.settingModel.id, optionsRoot.editSnapshot)
                    textInput.focus = false
                    // No event.accepted - cancel button action goes up to SettingsMenu.qml's cancel action
                    return
                }
                return
            }

            if (api.keys.isAccept(event)) {
                //event.accepted = true
                actionFeedback = ""
                var valueToSave = settingsListView.model[settingsListView.currentIndex];

                if (optionsRoot.settingModel.type === "list") {
                    valueToSave = optionsRoot.settingModel.options.get(settingsListView.currentIndex).value;
                }

                themeSettings.saveSetting(optionsRoot.settingModel.id, valueToSave, optionsRoot.settingModel.type);
            }
        }

        // Dispatch table for "action"-type settings. Add more ids here as
        // more actions are needed.
        function runAction(id) {
            if (id === "clearRACache") {
                clearRACache()
            }
        }

        // Clears every RetroAchievements cache entry directly via
        // api.memory, using the key scheme from Achievements.qml
        function clearRACache() {
            var stored = api.memory.get("ra_cache_index")
            var keys = []
            if (stored) {
                try { keys = JSON.parse(stored) } catch (e) { keys = [] }
            }

            for (var i = 0; i < keys.length; i++) {
                api.memory.set(keys[i], "")
            }
            api.memory.set("ra_cache_index", JSON.stringify([]))

            optionsRoot.actionFeedback = "Cleared " + keys.length + " cached entries, press Enter to return"
        }

        // Component.onCompleted: {
        //     state = settingModel.type;
        // }

        onSettingModelChanged: {
            // settingsListView.model = settingModel.options;
            // settingType = settingModel.type;
            if (settingModel !== undefined) { 
                state = settingModel.type
                Logger.debug("SettingsOptions:onSettingModelChanged:state:" + state)

                if (settingModel.type === "text") {
                    textInput.text = themeSettings[settingModel.id] || ""
                }
            };
            
            // Logger.info("Setting type: " + settingModel.type);
        }

        ItemList {
            id: settingsListView
            focus: true
            visible: optionsRoot.settingModel.type !== "text" && optionsRoot.settingModel.type !== "action"

            width: parent.width
            height: parent.height
            anchors.fill: parent
            rows: 4
            model: []
            delegate: settingsOptionsDelegate.delegate

            property string settingId: ""

            function setIndex() {
                Logger.debug("SettingsOptions:setIndex:model:" + model);
                if (model === undefined || model == [] || optionsRoot.settingModel == []) { return }

                var currentValue = themeSettings[optionsRoot.settingModel.id];

                if (optionsRoot.settingModel.type === "list") {
                    var opts = optionsRoot.settingModel.options
                    var listIndex = 0
                    for (var i = 0; i < opts.count; ++i) {
                        if (opts.get(i).value === currentValue) {
                            listIndex = i
                            break
                        }
                    }
                    settingsListView.currentIndex = listIndex
                    return
                }

                var value = currentValue;
                if (optionsRoot.settingModel.type == "bool") {
                    value = (value) ? "Enable" : "Disable"
                }
                //Logger.debug("SettingsOptions:setIndex:value:"+ value);
                var index = utils.findIndexByValue(model, value);
                //if (index >= 0 || index !== undefined) { currentIndex = index };
                settingsListView.currentIndex = index;
            }

            // Component.onCompleted: setIndex()
            //onModelChanged: {
            onSettingIdChanged: {
                //Logger.debug("SettingsOptions:onModelChanged:initiated");
                //Logger.debug("SettingsOptions:onModelChanged:id:" + optionsRoot.settingModel.id);
                setIndex();
            }

            //onModelChanged: {
            //    Logger.info("SettingsOptions:onModelChanged:model:" + model.count);
            //}
        }

        SettingsOptionsDelegate {
            id: settingsOptionsDelegate
            rows: settingsListView.rows
            textName: ""
        }

        //action box
        Item {
            id: actionBox
            visible: optionsRoot.settingModel.type === "action"
            anchors.fill: parent

            Text {
                anchors {
                    top: parent.top
                    topMargin: parent.height * -0.7
                    left: parent.left
                    leftMargin: parent.width * -0.05
                    right: parent.right
                    rightMargin: parent.width * 0.02
                }
                wrapMode: Text.WordWrap

                text: optionsRoot.actionFeedback !== ""
                    ? optionsRoot.actionFeedback
                    : "Press Enter to run"
                font.family: themeSettings.font.customFont
                font.pixelSize: parent.height * 0.11
                color: optionsRoot.actionFeedback !== ""
                    ? themeData.colorTheme[theme].primary
                    : themeData.colorTheme[theme].light
            }
        }

        // ---- text entry  --------------------
        Item {
            id: textEntryBox
            visible: optionsRoot.settingModel.type === "text"
            anchors.fill: parent

            Rectangle {
                id: textInputBackground

                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    topMargin: parent.height * -0.7
                    leftMargin: parent.width * -0.05
                    rightMargin: parent.width * 0.02
                }
                height: parent.height * 0.2

                //white out input when on API key and not inputting
                color: (!textInput.activeFocus && optionsRoot.settingModel.name == 'API Key'&& themeSettings.raApiKey !== "") ? themeData.colorTheme[theme].light : themeData.colorTheme[theme].background

                border.width: 1
                border.color: textInput.activeFocus ? themeData.colorTheme[theme].primary : themeData.colorTheme[theme].light

                TextInput {
                    id: textInput

                    anchors.fill: parent
                    anchors.margins: parent.height * 0.15
                    verticalAlignment: TextInput.AlignVCenter

                    clip: true
                    font.family: themeSettings.font.customFont
                    font.pixelSize: parent.height * 0.5
                    color: (!textInput.activeFocus && optionsRoot.settingModel.name == 'API Key') ? themeData.colorTheme[theme].light : themeData.colorTheme[theme].primary

                    // Saves continuously as you type
                    // regardless of platform-specific input quirks.
                    onTextChanged: {
                        themeSettings.saveSetting(optionsRoot.settingModel.id, text)
                    }

                    // Snapshot the value the instant editing starts, so
                    // Cancel has something to revert to
                    onActiveFocusChanged: {
                        if (activeFocus) {
                            optionsRoot.editSnapshot = text
                        }
                    }
                }
            }

            Text {
                anchors {
                    top: textInputBackground.bottom
                    topMargin: parent.height * 0.02
                    left: parent.left
                    leftMargin: parent.width * -0.05
                    right: parent.right
                    rightMargin: parent.width * 0.02
                }
                
                wrapMode: Text.WordWrap

                text: textInput.activeFocus
                    ? "Input text, press Enter to save or Cancel to cancel"
                    : "Press Enter to begin inputting text"
                font.family: themeSettings.font.customFont
                font.pixelSize: parent.height * 0.08
                color: themeData.colorTheme[theme].light
                
            }
        }

        states: [
            State {
                name: "list"
                // when: settingType == "list"
                PropertyChanges {
                    target: settingsListView
                    model: {
                        const list = []
                        for(var i=0; i < optionsRoot.settingModel.options.count; ++i) {
                            var opt = optionsRoot.settingModel.options.get(i)
                            // Show "label" if the option defines one 
                            list.push(opt.label !== undefined ? opt.label : opt.value)
                        }
                        return list
                    }
                }
                PropertyChanges {
                    target: settingsListView
                    settingId: optionsRoot.settingModel.id
                }
            },
            State {
                name: "range"
                // when: settingType == "range"
                PropertyChanges {
                    target: settingsListView
                    model: utils.generateRangeModel(optionsRoot.settingModel.min, optionsRoot.settingModel.max, optionsRoot.settingModel.step)
                }
                PropertyChanges {
                    target: settingsListView
                    settingId: optionsRoot.settingModel.id
                }
            },
            State {
                name: "bool"
                // when: settingType == "bool"
                PropertyChanges {
                    target: settingsListView
                    model: ["Enable", "Disable"]
                }
                PropertyChanges {
                    target: settingsListView
                    settingId: optionsRoot.settingModel.id
                }
            },
            State {
                name: "text"
                // No ItemList model needed - textEntryBox handles everything.
            },
            State {
                name: "action"
                // No ItemList model needed - actionBox handles everything.
            },
            State {
                name: ""
            }
        ]

        onStateChanged: Logger.info("settingOptions:state:" + state)

    }


}
