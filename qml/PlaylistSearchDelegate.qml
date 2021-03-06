 
import QtQuick 2.0
import Sailfish.Silica 1.0
import QtSpotify 1.0

BackgroundItem {
    id: listItem

    property variant listModel
    property string title: model.name
    property string iconSource: "image://theme/icon-m-sounds"

    height: Theme.itemSizeSmall
    width: parent.width

    onClicked: {
        pageStack.push(Qt.resolvedUrl("TracklistPage.qml"),
                       { "playlist": listModel.playlist(index),
                           "offlineSwitchVisible": false});
    }

    Row {
        anchors.left: parent.left
        anchors.leftMargin: Theme.horizontalPageMargin
        anchors.verticalCenter: parent.verticalCenter
        anchors.right: parent.right
        anchors.rightMargin: Theme.horizontalPageMargin
        spacing: Theme.paddingLarge

        Image {
            id: playlistImg
            anchors.verticalCenter: parent.verticalCenter
            source: listItem.highlighted ? (listItem.iconSource + "?" + Theme.highlightColor) : listItem.iconSource
            width: Theme.iconSizeMedium
            height: width
        }

        Label {
            width: parent.width - playlistImg.width
            anchors.verticalCenter: parent.verticalCenter
            text: title
            color: listItem.highlighted ? Theme.highlightColor : Theme.primaryColor
            truncationMode: TruncationMode.Fade
        }
    }
}
