/****************************************************************************
**
** Copyright (c) 2011 Nokia Corporation and/or its subsidiary(-ies).
** All rights reserved.
** Contact: Yoann Lopes (yoann.lopes@nokia.com)
**
** This file is part of the MeeSpot project.
**
** Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions
** are met:
**
** Redistributions of source code must retain the above copyright notice,
** this list of conditions and the following disclaimer.
**
** Redistributions in binary form must reproduce the above copyright
** notice, this list of conditions and the following disclaimer in the
** documentation and/or other materials provided with the distribution.
**
** Neither the name of Nokia Corporation and its Subsidiary(-ies) nor the names of its
** contributors may be used to endorse or promote products derived from
** this software without specific prior written permission.
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS
** FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** HOLDER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED
** TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
** PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
** LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
** NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
** SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
**
** If you have questions regarding the use of this file, please contact
** Nokia at qt-info@nokia.com.
**
****************************************************************************/


import QtQuick 2.0
import Sailfish.Silica 1.0
import QtSpotify 1.0

Page {
    id: tracklistPage
    property variant playlist

    Component.onCompleted: playlist.trackFilter = ""

    /*    TrackMenu {
        id: menu
        deleteVisible: playlist && spotifySession.user ? (playlist.type != SpotifyPlaylist.Starred && spotifySession.user.canModifyPlaylist(playlist))
                                                       : false
        markSeenVisible: playlist && playlist.type == SpotifyPlaylist.Inbox
    }*/

    Component {
        id: trackDelegate
        TrackDelegate {
            name: searchField.text.length > 0 ? Theme.highlightText(modelData.name, searchField.text, Theme.highlightColor) : modelData.name
            artistAndAlbum: (searchField.text.length > 0 ? Theme.highlightText(modelData.artists, searchField.text, Theme.highlightColor) : modelData.artists)
                            + " | "
                            + (searchField.text.length > 0 ? Theme.highlightText(modelData.album, searchField.text, Theme.highlightColor) : modelData.album)
            duration: modelData.duration
            highlighted: modelData.isCurrentPlayingTrack
            starred: modelData.isStarred
            available: modelData.isAvailable
            enabled: !spotifySession.offlineMode || available
            onClicked: {
                modelData.play()
            }
//            onPressAndHold: { menu.track = modelData; menu.open(); }
        }
    }

    Component {
        id: inboxDelegate
        InboxTrackDelegate {
            name: searchField.text.length > 0 ? Theme.highlightText(modelData.name, searchField.text, Theme.highlightColor) : modelData.name
            artistAndAlbum: (searchField.text.length > 0 ? Theme.highlightText(modelData.artists, searchField.text, Theme.highlightColor) : modelData.artists)
                            + " | "
                            + (searchField.text.length > 0 ? Theme.highlightText(modelData.album, searchField.text, Theme.highlightColor) : modelData.album)
            creatorAndDate: (searchField.text.length > 0 ? Theme.highlightText(modelData.creator, searchField.text, Theme.highlightColor) : modelData.creator)
                            + " | " + Qt.formatDateTime(modelData.creationDate)
            duration: modelData.duration
            highlighted: modelData.isCurrentPlayingTrack
            starred: modelData.isStarred
            available: modelData.isAvailable
            enabled: !spotifySession.offlineMode || available
            onClicked: {
                modelData.play()
            }
            seen: modelData.seen
//            onPressAndHold: { menu.track = modelData; menu.open(); }
        }
    }

    onPlaylistChanged: {
        tracks.delegate = playlist.type == SpotifyPlaylist.Inbox ? inboxDelegate : trackDelegate
        tracks.positionViewAtBeginning();
    }

    SilicaFlickable {
        anchors.fill: parent
        clip: true
        pressDelay: 0

        PageHeader {
            id: header
            title: (playlist.type == SpotifyPlaylist.Playlist ? playlist.name
                                                              : (playlist.type == SpotifyPlaylist.Starred ? "Starred"
                                                                                                          : "Inbox"))
        }

        SearchField {
            id: searchField
            anchors.top: header.bottom
            width: parent.width
            height: 0
            opacity: 0
            focus: false
            placeholderText: qsTr("Search tracks")
            inputMethodHints: Qt.ImhNoAutoUppercase | Qt.ImhNoPredictiveText
            Keys.onReturnPressed: { tracks.focus = true }

            onTextChanged: playlist.trackFilter = text.trim()

            states: State {
                name: "visible"
                when: tracks.showSearchField
                PropertyChanges {
                    target: searchField
                    height: 100
                }
                PropertyChanges {
                    target: searchField
                    opacity: 1
                }
                PropertyChanges {
                    target: searchField
                    focus: true
                }
            }

            transitions: [
                Transition {
                    from: "visible"; to: ""
                    SequentialAnimation {
                        NumberAnimation {
                            properties: "opacity"
                            duration: 200
                        }
                        NumberAnimation {
                            properties: "height"
                            duration: 300
                        }
                    }
                },
                Transition {
                    from: ""; to: "visible"
                    SequentialAnimation {
                        NumberAnimation {
                            properties: "height"
                            duration: 100
                        }
                        NumberAnimation {
                            properties: "opacity"
                            duration: 200
                        }
                    }
                }
            ]
        }

        SilicaListView {
            id: tracks
            width: parent.width
            anchors.top: searchField.bottom
            anchors.bottom: parent.bottom

            property bool showSearchField: atYBeginning
            property bool _movementFromBeginning: false

            Component.onCompleted: tracks.positionViewAtBeginning();

            VerticalScrollDecorator {}

            clip: true
            pressDelay: 0
            cacheBuffer: 3000
            highlightMoveDuration: 1
            model: playlist.tracks

            header: Column {
                width: parent.width

                TextSwitch {
                    id: offlineSwitch
                    width: parent.width
                    text: qsTr("Available offline")
                    property bool completed: false;
                    onCheckedChanged: {
                        if(completed) {
                            console.log("Offline changed");
                            playlist.availableOffline = !playlist.availableOffline;
                        }
                    }
                    checked: playlist.availableOffline
                    Component.onCompleted: {
                        completed = true;
                    }
                }
            }
        }

        Connections {
            target: playlist
            onPlaylistDestroyed: {
                playlistsTab.pop(null);
            }
        }
    }
}
