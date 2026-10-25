pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Wayland

// Notificaciones emergentes (arriba a la derecha)
PanelWindow {
	id: win

	visible: Notifs.popups.length > 0
	anchors {
		top: true
		right: true
	}
	margins {
		top: 10
		right: 10
	}
	exclusionMode: ExclusionMode.Normal
	exclusiveZone: 0
	implicitWidth: 400
	implicitHeight: Math.max(1, column.implicitHeight)
	color: "transparent"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.namespace: "quickshell-popups"
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.None

	Column {
		id: column
		width: parent.width
		spacing: 8

		Repeater {
			model: ScriptModel {
				values: Notifs.popups
			}

			NotifCard {
				id: popupCard

				required property var modelData
				readonly property int timeout: Notifs.timeoutFor(modelData) * 1000
				property real remaining: 1

				notif: modelData
				popup: true
				width: column.width
				onActivated: Notifs.hidePopup(modelData)
				onClickedPlain: Notifs.hidePopup(modelData)

				// barra de tiempo restante
				Rectangle {
					visible: popupCard.timeout > 0
					anchors {
						left: parent.left
						bottom: parent.bottom
						leftMargin: 12
						bottomMargin: 8
					}
					height: 2
					radius: 1
					width: (parent.width - 24) * popupCard.remaining
					color: Qt.alpha(Colors.accent, 0.6)
				}

				NumberAnimation on remaining {
					running: popupCard.timeout > 0
					paused: running && popupCard.hovered
					from: 1
					to: 0
					duration: popupCard.timeout
					onFinished: {
						Notifs.hidePopup(popupCard.modelData);
						if (popupCard.modelData.transient)
							popupCard.modelData.expire();
					}
				}

				opacity: 0
				Component.onCompleted: opacity = 1
				Behavior on opacity {
					NumberAnimation {
						duration: 150
					}
				}
			}
		}
	}
}
