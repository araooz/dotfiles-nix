import QtQuick

// Interruptor on/off
Rectangle {
	id: sw

	property bool checked: false

	signal toggled

	implicitWidth: 44
	implicitHeight: 24
	radius: 12
	color: checked ? Colors.accent : Colors.surface
	border.width: checked ? 0 : 1
	border.color: Colors.overlay

	Behavior on color {
		ColorAnimation {
			duration: 150
		}
	}

	Rectangle {
		width: 18
		height: 18
		radius: 9
		anchors.verticalCenter: parent.verticalCenter
		x: sw.checked ? sw.width - width - 3 : 3
		color: sw.checked ? Colors.bg : Colors.muted

		Behavior on x {
			NumberAnimation {
				duration: 150
				easing.type: Easing.OutCubic
			}
		}
	}

	MouseArea {
		anchors.fill: parent
		cursorShape: Qt.PointingHandCursor
		onClicked: sw.toggled()
	}
}
