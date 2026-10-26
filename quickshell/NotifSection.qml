pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell

// Historial de notificaciones del panel
ColumnLayout {
	id: root

	// esta seccion tiene la seleccion del teclado
	property bool focused: false

	// grupos por app, el de la notificacion mas nueva primero:
	// [{ app, notifs: [mas nueva primero] }]
	readonly property var groups: {
		const byApp = new Map();
		const out = [];
		for (const n of [...Notifs.list].reverse()) {
			const app = root.appOf(n);
			let g = byApp.get(app);
			if (!g) {
				g = { app, notifs: [] };
				byApp.set(app, g);
				out.push(g);
			}
			g.notifs.push(n);
		}
		return out;
	}
	readonly property var groupByApp: {
		const m = {};
		for (const g of groups)
			m[g.app] = g;
		return m;
	}
	// apps desplegadas: { app: true }
	property var expanded: ({})

	// filas visibles: cabecera de grupo (si la app tiene varias) + sus tarjetas.
	// Plegado solo se ve la mas nueva. Los datos se leen de groupByApp por clave.
	readonly property var rows: {
		const out = [];
		for (const g of groups) {
			if (g.notifs.length > 1)
				out.push({ key: "g:" + g.app, app: g.app, header: true });
			const shown = g.notifs.length > 1 && !expanded[g.app] ? g.notifs.slice(0, 1) : g.notifs;
			for (const n of shown)
				out.push({ key: "n:" + n.id, notif: n });
		}
		return out;
	}

	// seleccion por clave: no salta cuando llegan notificaciones nuevas
	property string selected: ""
	property int selectedAction: -1
	readonly property int selectedIndex: rows.findIndex(r => r.key === selected)
	// ultima posicion, para elegir la vecina si la seleccionada desaparece
	property int lastIndex: 0

	signal wantFocus
	// se uso una accion: el panel se cierra
	signal acted

	spacing: 10

	function appOf(n) {
		return n.appName || "Otras";
	}

	onRowsChanged: {
		if (rows.length === 0)
			selected = "";
		else if (rows.findIndex(r => r.key === selected) < 0) // selectedIndex puede no estar actualizado aun
			selected = rows[Math.min(lastIndex, rows.length - 1)].key;
	}
	onSelectedIndexChanged: {
		if (selectedIndex >= 0) {
			lastIndex = selectedIndex;
			list.positionViewAtIndex(selectedIndex, ListView.Contain);
		}
	}
	onSelectedChanged: selectedAction = -1
	onFocusedChanged: if (focused && selected === "") selected = rows[0]?.key ?? ""

	function toggleGroup(app) {
		const e = Object.assign({}, expanded);
		if (e[app])
			delete e[app];
		else
			e[app] = true;
		expanded = e;
		selected = "g:" + app;
	}
	function dismissGroup(app) {
		for (const n of (groupByApp[app]?.notifs ?? []).slice())
			n.dismiss();
	}

	// ---------- teclado ----------
	function move(delta) {
		if (rows.length === 0)
			return;
		const i = selectedIndex < 0 ? 0 : Math.max(0, Math.min(rows.length - 1, selectedIndex + delta));
		selected = rows[i].key;
	}
	function moveAction(delta) {
		const row = list.itemAtIndex(selectedIndex);
		if (!row || row.isHeader)
			return;
		selectedAction = Math.max(-1, Math.min(row.content.buttons.length - 1, selectedAction + delta));
	}
	function activateSelected() {
		const row = list.itemAtIndex(selectedIndex);
		if (!row)
			return;
		if (row.isHeader)
			toggleGroup(row.modelData.app);
		else
			row.content.invoke(selectedAction);
	}
	function dismissSelected() {
		const r = rows[selectedIndex];
		if (!r)
			return;
		if (r.header)
			dismissGroup(r.app);
		else
			r.notif.dismiss();
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
			values: root.rows
			objectProp: "key"
		}

		delegate: Item {
			id: row

			required property var modelData
			readonly property bool isHeader: modelData.header === true
			readonly property bool isSelected: root.focused && root.selected === modelData.key
			// tarjetas dentro de un grupo, un poco metidas
			readonly property bool grouped: !isHeader && (root.groupByApp[root.appOf(modelData.notif)]?.notifs.length ?? 0) > 1
			readonly property var content: loader.item

			width: ListView.view.width
			implicitHeight: loader.item?.implicitHeight ?? 0

			Loader {
				id: loader
				x: row.grouped ? 14 : 0
				width: parent.width - x
				sourceComponent: row.isHeader ? headerComponent : cardComponent
			}

			Component {
				id: cardComponent

				NotifCard {
					notif: row.modelData.notif
					selected: row.isSelected
					selectedAction: selected ? root.selectedAction : -1
					onPointed: {
						root.selected = row.modelData.key;
						root.wantFocus();
					}
					onActivated: root.acted()
				}
			}

			Component {
				id: headerComponent

				GroupHeader {
					app: row.modelData.app
					count: root.groupByApp[app]?.notifs.length ?? 0
					open: !!root.expanded[app]
					selected: row.isSelected
					onPointed: {
						root.selected = row.modelData.key;
						root.wantFocus();
					}
					onToggled: root.toggleGroup(app)
					onDismissed: root.dismissGroup(app)
				}
			}
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

	component GroupHeader: Rectangle {
		id: header

		property string app
		property int count
		property bool open
		property bool selected

		signal toggled
		signal dismissed
		signal pointed

		implicitHeight: 34
		radius: 12
		color: selected || headerArea.containsMouse ? Colors.surface : "transparent"
		border.width: selected ? 2 : 0
		border.color: Colors.accent

		MouseArea {
			id: headerArea
			anchors.fill: parent
			hoverEnabled: true
			cursorShape: Qt.PointingHandCursor
			onPositionChanged: mouse => {
				if (Pointer.moved(headerArea, mouse))
					header.pointed();
			}
			onClicked: header.toggled()
		}

		RowLayout {
			anchors.fill: parent
			anchors.leftMargin: 10
			anchors.rightMargin: 6
			spacing: 8

			Text {
				text: header.open ? Icons.chevronDown : Icons.chevronRight
				color: Colors.accent
				font.family: Colors.font
				font.pixelSize: 16
			}
			Text {
				text: header.app
				color: Colors.fg
				font.family: Colors.font
				font.pixelSize: 13
				font.bold: true
			}
			Rectangle {
				implicitWidth: countText.implicitWidth + 14
				implicitHeight: 20
				radius: 10
				color: Qt.alpha(Colors.accent, 0.2)

				Text {
					id: countText
					anchors.centerIn: parent
					text: header.count
					color: Colors.accent
					font.family: Colors.font
					font.pixelSize: 11
					font.bold: true
				}
			}
			Item {
				Layout.fillWidth: true
			}
			Text {
				visible: !dismissBtn.visible
				text: header.open ? "ocultar" : `+${header.count - 1} más`
				color: Colors.muted
				font.family: Colors.font
				font.pixelSize: 11
			}
			// descartar todo el grupo
			IconButton {
				id: dismissBtn
				visible: header.selected || headerArea.containsMouse || hovered
				icon: Icons.close
				size: 24
				danger: true
				onClicked: header.dismissed()
			}
		}
	}
}
