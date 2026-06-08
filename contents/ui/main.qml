/*
 KWin - the KDE window manager
 This file is part of the KDE project.

 SPDX-FileCopyrightText: 2011 Martin Gräßlin <mgraesslin@kde.org>

 SPDX-License-Identifier: GPL-2.0-or-later
 */
import QtQuick 2.15
import QtQuick.Layouts 1.15
import org.kde.plasma.core as PlasmaCore
import org.kde.kirigami 2.20 as Kirigami
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.kwin 3.0 as KWin

KWin.TabBoxSwitcher {
    id: tabBox

    currentIndex: icons.currentIndex

    PlasmaCore.Dialog {
        location: PlasmaCore.Types.Floating
        visible: tabBox.visible
        flags: Qt.X11BypassWindowManagerHint
        backgroundHints: PlasmaCore.Types.NoBackground
        x: tabBox.screenGeometry.x + tabBox.screenGeometry.width * 0.5 - bgRect.width * 0.5
        y: tabBox.screenGeometry.y + tabBox.screenGeometry.height * 0.5 - bgRect.height * 0.8

        mainItem: Item {
            id: bgRect

            readonly property int hPadding: Kirigami.Units.largeSpacing * 2
            readonly property int vPadding: Kirigami.Units.largeSpacing * 2
            readonly property int innerWidth: Math.min(
                Math.max(icons.delegateWidth, icons.implicitWidth),
                tabBox.screenGeometry.width * 0.9
            )

            width: innerWidth + hPadding * 2
            height: icons.delegateHeight + vPadding * 2

            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0.16, 0.16, 0.16, 0.7)
                radius: 20
                border.width: 0
            }

            ColumnLayout {
                id: dialogMainItem
                spacing: 0
                anchors {
                    fill: parent
                    leftMargin: bgRect.hPadding
                    rightMargin: bgRect.hPadding
                    topMargin: bgRect.vPadding
                    bottomMargin: bgRect.vPadding
                }

                ListView {
                    id: icons

                    readonly property int iconSize: Kirigami.Units.iconSizes.huge * 1.5
                    // Extra horizontal padding per item so icons breathe
                    readonly property int delegateWidth: iconSize + Kirigami.Units.largeSpacing * 4
                    // Extra vertical room for label below
                    readonly property int delegateHeight: iconSize + Kirigami.Units.largeSpacing * 4

                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: tabBox.screenGeometry.width * 0.9

                    implicitWidth: contentWidth
                    implicitHeight: delegateHeight

                    focus: true
                    orientation: ListView.Horizontal

                    model: tabBox.model

                    delegate: Item {
                        width: icons.delegateWidth
                        height: icons.delegateHeight

                        // macOS-style selection highlight: rounded rect behind the icon
                        Rectangle {
                            id: selectionRect
                            anchors.centerIn: parent
                            width: icons.iconSize + Kirigami.Units.largeSpacing * 2
                            height: icons.iconSize + Kirigami.Units.largeSpacing * 2
                            radius: 14
                            color: Qt.rgba(1, 1, 1, 0.18)
                            visible: index === icons.currentIndex
                        }

                        Kirigami.Icon {
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                top: parent.top
                                topMargin: Kirigami.Units.largeSpacing
                            }

                            width: icons.iconSize
                            height: icons.iconSize

                            source: model.icon

                            // macOS-style: select on mouse hover
                            HoverHandler {
                                onHoveredChanged: {
                                    if (hovered) {
                                        icons.currentIndex = index;
                                    }
                                }
                            }

                            // Click to activate directly
                            TapHandler {
                                onSingleTapped: {
                                    icons.model.activate(index);
                                }
                            }
                        }

                        PlasmaComponents3.Label {
                            id: textItem
                            width: parent.width - Kirigami.Units.smallSpacing * 2
                            text: {
                                var program = (model.caption).split('—')[1]
                                return (program) ? program.trim() : (model.caption).split('-').pop().trim()
                            }
                            height: paintedHeight
                            horizontalAlignment: Text.AlignHCenter
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideRight
                            // White text, bolder when selected — like macOS
                            color: "white"
                            font.weight: icons.currentIndex === index ? Font.Medium : Font.Normal
                            font.pixelSize: Kirigami.Units.gridUnit * 0.75
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                bottom: parent.bottom
                                bottomMargin: Kirigami.Units.smallSpacing
                            }
                        }
                    }

                    // Remove the Plasma SVG highlight — we use our own Rectangle above
                    highlight: Item {}

                    highlightMoveDuration: 0
                    highlightResizeDuration: 0
                    boundsBehavior: Flickable.StopAtBounds
                }

                Connections {
                    target: tabBox
                    function onCurrentIndexChanged() {
                        icons.currentIndex = tabBox.currentIndex;
                    }
                }

                /*
                * Key navigation on outer item for two reasons:
                * @li we have to emit the change signal
                * @li on multiple invocation it does not work on the list view. Focus seems to be lost.
                **/
                Keys.onPressed: event => {
                    if (event.key == Qt.Key_Left) {
                        icons.decrementCurrentIndex();
                    } else if (event.key == Qt.Key_Right) {
                        icons.incrementCurrentIndex();
                    }
                }
            }
        }
    }
}
