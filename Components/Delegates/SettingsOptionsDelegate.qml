import QtQuick 2.15

Item {
    id: settingsOptionsDelegateRoot
    required property int rows
    property alias delegate: settingsOptionDelegate
    property string textName: "name"
    property var settingModel // Received from optionsRoot.settingModel

    Component {
        id: settingsOptionDelegate

        Rectangle {
            id: settingsListRect
            property int rows: 1

            width: ListView.view.width
            height: ListView.view.height / ListView.view.rows

            color: {
                if (activeFocus) { return ListView.isCurrentItem ? themeData.colorTheme[theme].primary : "transparent" }
                return ListView.isCurrentItem ? themeData.colorTheme[theme].secondary : "transparent"
            }

            function getColorValue() {
                if (!settingModel || !settingModel.options) return "transparent"
                var opt = settingModel.options.get(index)
                if (settingModel.id === "theme") {
                    var themeName = opt.value
                    if (themeData && themeData.colorTheme && themeData.colorTheme[themeName]) {
                        return themeData.colorTheme[themeName].light
                    }
                }

                return opt.value
            }


            function isColorSetting() {
                if (!settingModel || !settingModel.id) return false
                // Check if setting ID is a color setting or contains "Color"
                return settingModel.id === "backgroundColor" || 
                       settingModel.id === "backgroundGradientColor" || 
                       settingModel.id === "theme" ||
                       settingModel.id === "shaderHillsFadeColor"
            }

            // Color Swatch Preview
            Rectangle {
                id: colorPreview
                width: parent.height * 0.5
                height: parent.height * 0.5
                radius: 0
                anchors {
                    verticalCenter: parent.verticalCenter
                    left: parent.left
                    leftMargin: parent.width * 0.02
                }

                // Only render preview if the current setting is a color setting
                visible: isColorSetting()
                color:{
                    
                    if(getColorValue() === "transparent"){
                        return themeData.colorTheme[theme].background 
                    }
                    return getColorValue()
                    }
                border.width: 1
                border.color: "#ffffff"
            }

            // Dynamically load font per item when on the fontInput setting
            FontLoader {
                id: customFont2

                source: "../../assets/fonts/" + settingModel.options.get(index).value + ".ttf" 

                onStatusChanged: {
                    var ttfPath = "../../assets/fonts/" + settingModel.options.get(index).value + ".ttf"
                    
                    if (status === FontLoader.Error && source == ttfPath) {
                        source = "../../assets/fonts/" + settingModel.options.get(index).value + ".otf"
                    }
                }
            }

            Text {
                id: settingsNameText

                width: parent.width

                anchors {
                    verticalCenter: parent.verticalCenter
                    left: colorPreview.visible ? colorPreview.right : parent.left
                    leftMargin: colorPreview.visible ? parent.width * 0.03 : (font.pixelSize * 0.7) + parent.width * 0.04
                }

                font.family: {
                    if (settingModel.id === "fontInput") {
                        return customFont2.name
                    }
                    return themeSettings.font.customFont
                }
                font.pixelSize: parent.height * 0.4

                elide: Text.ElideRight
                color: settingsListRect.ListView.isCurrentItem ? themeData.colorTheme[theme].background : themeData.colorTheme[theme].primary

                text: modelData
            }
        }
    }
}