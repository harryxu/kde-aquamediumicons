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

            // ── Background: dark semi-transparent panel ───────────────────
            Rectangle {
                anchors.fill: parent
                color: Qt.rgba(0.15, 0.15, 0.15, 0.88)
                radius: 20
                border.width: 0
            }

            // ── Content ───────────────────────────────────────────────────
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

                    // Horizontal space per item
                    readonly property int delegateWidth: iconSize + Kirigami.Units.largeSpacing * 4

                    // Vertical space: icon + gap + label
                    //   largeSpacing (top pad) + iconSize + largeSpacing*2 (gap) + labelHeight + largeSpacing (bottom pad)
                    //   Using largeSpacing*5 gives comfortable room
                    readonly property int delegateHeight: iconSize + Kirigami.Units.largeSpacing * 5

                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: tabBox.screenGeometry.width * 0.9

                    implicitWidth: contentWidth
                    implicitHeight: delegateHeight

                    focus: true
                    orientation: ListView.Horizontal

                    model: tabBox.model

                    delegate: Item {
                        id: delegateItem
                        width: icons.delegateWidth
                        height: icons.delegateHeight

                        // ── Selection highlight ───────────────────────────
                        // Strictly wraps the icon only — 3px padding on each side.
                        // Icon sits at y=largeSpacing, so highlight top = largeSpacing-3.
                        // Highlight bottom = largeSpacing + iconSize + 3, well above the label.
                        Rectangle {
                            id: selectionRect
                            anchors.horizontalCenter: parent.horizontalCenter
                            y: Kirigami.Units.largeSpacing - 3
                            width: icons.iconSize + 6
                            height: icons.iconSize + 6
                            radius: 14
                            color: Qt.rgba(1, 1, 1, 0.18)
                            visible: index === icons.currentIndex
                        }

                        // ── App icon ─────────────────────────────────────
                        Kirigami.Icon {
                            id: appIcon
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

                        // ── App label ────────────────────────────────────
                        // Anchored to bottom, with increased top gap from the icon.
                        // The gap between icon bottom and label top is:
                        //   delegateHeight - largeSpacing - iconSize - largeSpacing*2 - labelHeight
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
                            color: "white"
                            font.weight: icons.currentIndex === index ? Font.Medium : Font.Normal
                            font.pixelSize: Kirigami.Units.gridUnit * 0.75
                            anchors {
                                horizontalCenter: parent.horizontalCenter
                                // Increased bottom margin keeps text well below the highlight
                                bottom: parent.bottom
                                bottomMargin: Kirigami.Units.largeSpacing
                            }
                        }
                    }

                    // No Plasma SVG highlight — using our own Rectangle
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
