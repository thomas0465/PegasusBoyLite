import QtQuick 2.15

import "../Generic"
import "../Delegates"
import "../../Logger.js" as Logger

FocusScope {

    // property alias model: settingsListView.model
    property alias model: optionsRoot.settingModel

    Item {
        id: optionsRoot

        width: parent.width
        height: parent.height

        property var settingModel: []
        // property string settingType: ""

        Keys.onPressed: {
            if (optionsRoot.settingModel.type === "text") {
                if (api.keys.isAccept(event)) {
                    event.accepted = true
                    textInput.forceActiveFocus()
                    return
                }
                if (api.keys.isCancel(event)) {
                    event.accepted = true
                    themeSettings.saveSetting(optionsRoot.settingModel.id, textInput.text)
                    textInput.focus = false
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
                    topMargin: parent.height * 0.1
                    leftMargin: parent.width * 0.02
                    rightMargin: parent.width * 0.02
                }
                height: parent.height * 0.15

                color: themeData.colorTheme[theme].dark
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
                    color: themeData.colorTheme[theme].primary

                    onAccepted: {
                        // Enter/Return on an attached keyboard confirms and saves
                        themeSettings.saveSetting(optionsRoot.settingModel.id, text)
                        focus = false
                    }
                }
            }

            Text {
                anchors {
                    top: textInputBackground.bottom
                    topMargin: parent.height * 0.02
                    left: parent.left
                    leftMargin: parent.width * 0.02
                }

                text: textInput.activeFocus
                    ? "Type your text, then press Enter or Cancel to save"
                    : "Press Accept to edit, Cancel to save and exit"
                font.family: themeSettings.font.customFont
                font.pixelSize: parent.height * 0.05
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
