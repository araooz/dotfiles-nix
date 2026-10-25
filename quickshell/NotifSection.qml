pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

// Historial de notificaciones del panel
ColumnLayout {
	id: root

	// esta seccion tiene la seleccion del teclado
	property bool focused: false

	// mas nuevas arriba
	readonly property var items: [...Notifs.list].reverse()
	// seleccion por objeto: no salta cuando llegan notificaciones nuevas
	property var selected: null
	property int selectedAction: -1
	readonly property int selectedIndex: items.indexOf(selected)
	// ultima posicion, para elegir la vecina si la seleccionada desaparece
	property int lastIndex: 0

	signal wantFocus
	// se uso una accion: el panel se cierra
	signal acted

	spacing: 10

	onItemsChanged: {
		if (items.length === 0)
			selected = null;
		else if (items.indexOf(selected) < 0) // selectedIndex puede no estar actualizado aun
			selected = items[Math.min(lastIndex, items.length - 1)];
	}
	onSelectedIndexChanged: {
		if (selectedIndex >= 0) {
			lastIndex = selectedIndex;
			list.positionViewAtIndex(selectedIndex, ListView.Contain);
		}
	}
	onSelectedChanged: selectedAction = -1
	onFocusedChanged: if (focused && !selected) selected = items[0] ?? null

	// ---------- teclado ----------
	function move(delta) {
		if (items.length === 0)
			return;
		const i = selectedIndex < 0 ? 0 : Math.max(0, Math.min(items.length - 1, selectedIndex + delta));
		selected = items[i];
	}
	function moveAction(delta) {
		const card = list.itemAtIndex(selectedIndex);
		if (!card)
			return;
		selectedAction = Math.max(-1, Math.min(card.buttons.length - 1, selectedAction + delta));
	}
	function activateSelected() {
		const card = list.itemAtIndex(selectedIndex);
		if (card)
			card.invoke(selectedAction);
	}
	function dismissSelected() {
		selected?.dismiss();
	}

	RowLayout {
		Layout.fillWidth: true
		Layout.leftMargin: 4
		Layout.rightMargin: 4
		spacing: 12

		Rectangle {
			implicitWidth: 40
			implicitHeight: 40
			radius: 20
			color: Notifs.dnd ? Colors.surface : Colors.accent

			Text {
				anchors.centerIn: parent
				text: Notifs.dnd ? Icons.bellOff : Icons.bell
				color: Notifs.dnd ? Colors.muted : Colors.bg
				font.family: Colors.font
				font.pixelSize: 20
			}
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 0

			Text {
				text: "Notificaciones"
				color: root.focused ? Colors.accent : Colors.fg
				font.family: Colors.font
				font.pixelSize: 18
				font.bold: true
			}
			Text {
				text: Notifs.dnd ? "No molestar" : Notifs.list.length === 0 ? "Nada nuevo" : Notifs.list.length === 1 ? "1 notificación" : `${Notifs.list.length} notificaciones`
				color: Colors.muted
				font.family: Colors.font
				font.pixelSize: 12
			}
		}

		// limpiar todo
		Rectangle {
			visible: Notifs.list.length > 0
			implicitWidth: clearText.implicitWidth + 24
			implicitHeight: 28
			radius: 14
			color: clearArea.containsMouse ? Colors.red : Colors.surface

			Text {
				id: clearText
				anchors.centerIn: parent
				text: "Limpiar"
				color: clearArea.containsMouse ? Colors.bg : Colors.fg
				font.family: Colors.font
				font.pixelSize: 12
			}
			MouseArea {
				id: clearArea
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onClicked: Notifs.clearAll()
			}
		}

		// no molestar
		Switch {
			checked: Notifs.dnd
			onToggled: Notifs.dnd = !Notifs.dnd
		}
	}

	ListView {
		id: list
		Layout.fillWidth: true
		Layout.fillHeight: true
		clip: true
		spacing: 8
		boundsBehavior: Flickable.StopAtBounds
		model: ScriptModel {
			values: root.items
		}

		delegate: NotifCard {
			required property var modelData
			notif: modelData
			width: ListView.view.width
			selected: root.focused && root.selected === modelData
			selectedAction: selected ? root.selectedAction : -1
			onPointed: {
				root.selected = modelData;
				root.wantFocus();
			}
			onActivated: root.acted()
		}

		add: Transition {
			NumberAnimation {
				property: "opacity"
				from: 0
				to: 1
				duration: 150
			}
		}
		displaced: Transition {
			NumberAnimation {
				property: "y"
				duration: 150
				easing.type: Easing.OutCubic
			}
		}

		Text {
			anchors.centerIn: parent
			visible: Notifs.list.length === 0
			text: Icons.bell + "\nSin notificaciones"
			horizontalAlignment: Text.AlignHCenter
			color: Colors.overlay
			font.family: Colors.font
			font.pixelSize: 14
		}
	}
}
