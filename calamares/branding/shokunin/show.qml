/*
 * Calamares slideshow placeholder.
 *
 * Shown while packages are being installed. Real content (screenshots,
 * "what's new" highlights) drops in later. For scaffolding, one slide
 * with a title and tagline.
 *
 * Reference: https://github.com/calamares/calamares/wiki/Branding-Guide
 */

import QtQuick 2.5;
import calamares.slideshow 1.0;

Presentation
{
    id: presentation

    Timer {
        interval: 8000
        running: presentation.activatedInCalamares
        repeat: true
        onTriggered: presentation.goToNextSlide()
    }

    Slide {
        Text {
            anchors.centerIn: parent
            font.pixelSize: 32
            text: "Shokunin"
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.verticalCenter
            anchors.topMargin: 40
            font.pixelSize: 18
            text: qsTr("The chef picks. You eat well.")
        }
    }

    // TODO: add more slides — Quickshell screenshot, keybinds cheat
    // sheet, where to find docs, how to update.
}
