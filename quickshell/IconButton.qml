import QtQuick

// Boton redondo con un icono Nerd Font
Rectangle {
	id: btn

	property string icon
	property int size: 32
	property bool danger: false
	property bool accent: false
	property bool spinning: false
	readonly property alias hovered: area.containsMouse

	signal clicked

	implicitWidth: size
	implicitHeight: size
	radius: size / 2
	color: area.containsMouse ? (danger ? Colors.red : Colors.accent) : (accent ? Qt.alpha(Colors.accent, 0.2) : Colors.surface)

	Behavior on color {
		ColorAnimation {
			duration: 100
		}
	}

	Text {
		anchors.centerIn: parent
		text: btn.icon
		color: area.containsMouse ? Colors.bg : (btn.accent ? Colors.accent : Colors.fg)
		font.family: Colors.font
		font.pixelSize: Math.round(btn.size * 0.5)

		RotationAnimation on rotation {
			running: btn.spinning
			loops: Animation.Infinite
			from: 0
			to: 360
			duration: 800
			onRunningChanged: if (!running) parent.rotation = 0
		}
	}

	MouseArea {
		id: area
		anchors.fill: parent
		hoverEnabled: true
		cursorShape: Qt.PointingHandCursor
		onClicked: btn.clicked()
	}
}
