import QtQuick 2.15

import "../Generic"
import "../Delegates"
import "../../Logger.js" as Logger

FocusScope {
    id: root

    // property alias model: settingsListView.model
    property alias model: optionsRoot.settingModel

    onActiveFocusChanged: {
        // Explicit, self-healing focus routing. settingsListView's own
        // "focus: true" binding gets permanently destroyed the first time
        // textInput.forceActiveFocus() steals focus away from it (Qt
        // imperatively overwrites the binding to make room, which severs
        // it for good) - so we can't rely on that default anymore. Always
        // decide where focus goes explicitly instead.
        if (!activeFocus) { return }

        if (optionsRoot.settingModel.type === "text") {
            textInput.forceActiveFocus()
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
        // property string settingType: ""

        Keys.onPressed: {
            if (optionsRoot.settingModel.type === "text") {
                if (api.keys.isAccept(event) && !textInput.activeFocus) {
                    
                    textInput.forceActiveFocus()
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
                themeSettings.saveSetting(optionsRoot.settingModel.id, settingsListView.model[settingsListView.currentIndex], optionsRoot.settingModel.type);
            }
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
            visible: optionsRoot.settingModel.type !== "text"

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
                var value = themeSettings[optionsRoot.settingModel.id];
                if (optionsRoot.settingModel.type == "bool") {
                    value = (value) ? "Enable" : "Disable"
                }
                Logger.debug("SettingsOptions:setIndex:value:"+ value);
                var index = utils.findIndexByValue(model, value);
                //if (index >= 0 || index !== undefined) { currentIndex = index };
                settingsListView.currentIndex = index;
            }

            // Component.onCompleted: setIndex()
            //onModelChanged: {
            onSettingIdChanged: {
                Logger.debug("SettingsOptions:onModelChanged:initiated");
                Logger.debug("SettingsOptions:onModelChanged:id:" + optionsRoot.settingModel.id);
                setIndex();
            }

            onModelChanged: {
                Logger.info("SettingsOptions:onModelChanged:model:" + model.count);
            }
        }

        SettingsOptionsDelegate {
            id: settingsOptionsDelegate
            rows: settingsListView.rows
            textName: ""
        }

        // ---- Free text entry (username/API key/etc.) --------------------
        // Requires a physical/attached keyboard, or a platform on-screen
        // keyboard that pops up automatically when a TextInput gets focus.
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
                color: (!textInput.activeFocus && optionsRoot.settingModel.name == 'API Key') ? themeData.colorTheme[theme].light : themeData.colorTheme[theme].background

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

                    // Saves continuously as you type, instead of depending
                    // on catching a specific "commit" event (Return key,
                    // editingFinished, etc.) - those depend on how input is
                    // actually delivered on a given platform, and Android's
                    // on-screen controls don't appear to trigger them the
                    // same way a gamepad does. This guarantees whatever is
                    // currently displayed is always what's saved,
                    // regardless of platform-specific input quirks.
                    onTextChanged: {
                        themeSettings.saveSetting(optionsRoot.settingModel.id, text)
                    }

                    // Snapshot the value the instant editing starts, so
                    // Cancel has something meaningful to revert to - since
                    // live-saving means themeSettings itself is no longer
                    // a safe "last saved" reference once typing begins.
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
                    ? "Input text, press Enter to save, and Cancel to cancel"
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
                            list.push(optionsRoot.settingModel.options.get(i).value)
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
                name: ""
            }
        ]

        onStateChanged: Logger.info("settingOptions:state:" + state)

    }


}
