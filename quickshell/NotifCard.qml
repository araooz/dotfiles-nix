pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications

// Tarjeta de una notificacion (panel y popups)
Rectangle {
	id: card

	required property Notification notif
	property bool popup: false
	// seleccion del teclado: la tarjeta y cual de sus botones (-1 = ninguno)
	property bool selected: false
	property int selectedAction: -1
	readonly property bool critical: notif.urgency === NotificationUrgency.Critical
	readonly property var defaultAction: notif.actions.find(a => a.identifier === "default") ?? null
	readonly property var buttons: notif.actions.filter(a => a.identifier !== "default")
	readonly property string imageSource: {
		if (notif.image)
			return notif.image;
		const icon = notif.appIcon;
		if (!icon)
			return "";
		if (icon.startsWith("/"))
			return "file://" + icon;
		if (icon.includes("://"))
			return icon;
		return Quickshell.iconPath(icon, true);
	}
	readonly property alias hovered: hover.containsMouse

	// ejecuta un boton (index) o la accion principal (-1); false si no hay accion
	function invoke(index) {
		const action = index >= 0 ? buttons[index] : defaultAction;
		if (!action)
			return false;
		action.invoke();
		activated();
		return true;
	}

	signal activated
	// el raton se movio encima (para sincronizar la seleccion)
	signal pointed
	// click en una tarjeta sin accion principal
	signal clickedPlain

	implicitHeight: content.implicitHeight + (popup ? 30 : 24)
	radius: 16
	color: hover.containsMouse || selected ? Colors.surface : (popup ? Colors.bg : Colors.bgAlt)
	border.width: selected && critical ? 3 : 2
	border.color: critical ? Colors.red : selected ? Colors.accent : Qt.alpha(Colors.accent, popup ? 0.5 : 0.25)

	Behavior on color {
		ColorAnimation {
			duration: 120
		}
	}

	MouseArea {
		id: hover
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: card.defaultAction ? Qt.PointingHandCursor : Qt.ArrowCursor
		onPositionChanged: mouse => {
			if (Pointer.moved(hover, mouse))
				card.pointed();
		}
		onClicked: {
			if (!card.invoke(-1))
				card.clickedPlain();
		}
	}

	RowLayout {
		id: content
		anchors {
			left: parent.left
			right: parent.right
			top: parent.top
			margins: 12
		}
		spacing: 12

		Image {
			Layout.alignment: Qt.AlignTop
			Layout.preferredWidth: 42
			Layout.preferredHeight: 42
			visible: card.imageSource !== "" && status === Image.Ready
			source: card.imageSource
			sourceSize: Qt.size(84, 84)
			fillMode: Image.PreserveAspectCrop
			asynchronous: true
			smooth: true
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 3

			RowLayout {
				Layout.fillWidth: true
				spacing: 8

				Text {
					Layout.fillWidth: true
					text: card.notif.summary || card.notif.appName
					color: card.critical ? Colors.red : Colors.accent
					font.family: Colors.font
					font.pixelSize: 14
					font.bold: true
					elide: Text.ElideRight
				}
				Text {
					visible: !closeBtn.visible
					text: Notifs.ago(card.notif.id)
					color: Colors.muted
					font.family: Colors.font
					font.pixelSize: 11
				}
				// cerrar (solo al pasar el raton para no tapar la hora)
				Rectangle {
					id: closeBtn
					visible: card.hovered || closeArea.containsMouse
					implicitWidth: 22
					implicitHeight: 22
					radius: 11
					color: closeArea.containsMouse ? Colors.red : Colors.overlay

					Text {
						anchors.centerIn: parent
						text: Icons.close
						color: closeArea.containsMouse ? Colors.bg : Colors.fg
						font.family: Colors.font
						font.pixelSize: 13
					}
					MouseArea {
						id: closeArea
						anchors.fill: parent
						hoverEnabled: true
						cursorShape: Qt.PointingHandCursor
						onClicked: card.notif.dismiss()
					}
				}
			}

			Text {
				Layout.fillWidth: true
				visible: text !== ""
				text: card.notif.body
				color: Colors.fg
				font.family: Colors.font
				font.pixelSize: 13
				textFormat: Text.StyledText
				wrapMode: Text.Wrap
				maximumLineCount: card.popup ? 4 : 6
				elide: Text.ElideRight
				onLinkActivated: link => Qt.openUrlExternally(link)
			}

			Text {
				visible: card.notif.appName !== "" && card.notif.summary !== ""
				text: card.notif.appName
				color: Colors.muted
				font.family: Colors.font
				font.pixelSize: 11
			}

			Flow {
				Layout.fillWidth: true
				Layout.topMargin: 4
				visible: card.buttons.length > 0
				spacing: 6

				Repeater {
					model: card.buttons

					Rectangle {
						id: actionBtn
						required property var modelData
						required property int index
						readonly property bool lit: actionArea.containsMouse || (card.selected && card.selectedAction === index)
						implicitWidth: actionText.implicitWidth + 24
						implicitHeight: 28
						radius: 14
						color: lit ? Colors.accent : Colors.overlay

						Text {
							id: actionText
							anchors.centerIn: parent
							text: actionBtn.modelData.text
							color: actionBtn.lit ? Colors.bg : Colors.fg
							font.family: Colors.font
							font.pixelSize: 12
						}
						MouseArea {
							id: actionArea
							anchors.fill: parent
							hoverEnabled: true
							cursorShape: Qt.PointingHandCursor
							onClicked: {
								actionBtn.modelData.invoke();
								card.activated();
							}
						}
					}
				}
			}
		}
	}
}
