pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Bluetooth

// Modulo Bluetooth del panel
ColumnLayout {
	id: root

	// el panel esta abierto (al cerrarlo se deja de buscar)
	property bool active: false
	// esta seccion tiene la seleccion del teclado
	property bool focused: false

	readonly property var adapter: Bluetooth.defaultAdapter
	readonly property bool btOn: adapter?.enabled ?? false
	readonly property bool discovering: adapter?.discovering ?? false
	// conectados, luego emparejados, luego los encontrados al buscar (solo con nombre)
	readonly property var devices: (adapter?.devices.values ?? []).filter(d => d.paired || (discovering && d.deviceName !== "")).sort((a, b) => (b.connected - a.connected) || (b.paired - a.paired) || a.name.localeCompare(b.name))
	readonly property var connectedNames: devices.filter(d => d.connected).map(d => d.name)

	// seleccion por direccion: no salta cuando la lista se reordena
	property string selected: ""
	readonly property int selectedIndex: devices.findIndex(d => d.address === selected)
	readonly property var selectedDev: selectedIndex >= 0 ? devices[selectedIndex] : null
	property string error: ""

	signal wantFocus

	spacing: 10

	onActiveChanged: {
		if (active) {
			selected = devices[0]?.address ?? "";
			Qt.callLater(list.positionViewAtBeginning);
		} else {
			error = "";
			if (adapter && discovering)
				adapter.discovering = false;
		}
	}
	onDevicesChanged: if (devices.findIndex(d => d.address === selected) < 0) selected = devices[0]?.address ?? ""
	onSelectedIndexChanged: if (selectedIndex >= 0) list.positionViewAtIndex(selectedIndex, ListView.Contain)

	function activate(dev) {
		error = "";
		if (!dev || dev.pairing || dev.state === BluetoothDeviceState.Connecting || dev.state === BluetoothDeviceState.Disconnecting)
			return;
		selected = dev.address;
		if (dev.connected)
			dev.disconnect();
		else if (dev.paired)
			dev.connect();
		else
			dev.pair(); // al emparejar: confiar y conectar (ver Connections del delegate)
	}

	function forget(dev) {
		if (dev && dev.paired)
			dev.forget();
	}

	// ---------- teclado ----------
	function move(delta) {
		if (devices.length === 0)
			return;
		const i = selectedIndex < 0 ? 0 : Math.max(0, Math.min(devices.length - 1, selectedIndex + delta));
		selected = devices[i].address;
	}
	function activateSelected() {
		activate(selectedDev);
	}
	function forgetSelected() {
		forget(selectedDev);
	}
	function toggleScan() {
		if (adapter && btOn)
			adapter.discovering = !adapter.discovering;
	}
	function toggleBluetooth() {
		if (adapter)
			adapter.enabled = !adapter.enabled;
	}

	Timer {
		id: errorClear
		interval: 8000
		onTriggered: root.error = ""
	}
	onErrorChanged: if (error !== "") errorClear.restart()

	// ---------- cabecera ----------
	RowLayout {
		Layout.fillWidth: true
		Layout.leftMargin: 4
		Layout.rightMargin: 4
		spacing: 12

		Rectangle {
			implicitWidth: 40
			implicitHeight: 40
			radius: 20
			color: root.btOn ? Colors.accent : Colors.surface

			Text {
				anchors.centerIn: parent
				text: !root.btOn ? Icons.btOff : root.connectedNames.length > 0 ? Icons.btConnected : Icons.bt
				color: root.btOn ? Colors.bg : Colors.muted
				font.family: Colors.font
				font.pixelSize: 20
			}
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 0

			Text {
				text: "Bluetooth"
				color: root.focused ? Colors.accent : Colors.fg
				font.family: Colors.font
				font.pixelSize: 18
				font.bold: true
			}
			Text {
				Layout.fillWidth: true
				text: !root.adapter ? "Sin adaptador" : !root.btOn ? "Apagado" : root.discovering ? "Buscando dispositivos…" : root.connectedNames.length > 0 ? root.connectedNames.join(", ") : "Sin conexión"
				color: root.connectedNames.length > 0 && !root.discovering ? Colors.fg : Colors.muted
				font.family: Colors.font
				font.pixelSize: 12
				elide: Text.ElideRight
			}
		}

		IconButton {
			visible: root.btOn
			icon: Icons.refresh
			spinning: root.discovering
			onClicked: root.toggleScan()
		}

		Switch {
			checked: root.btOn
			onToggled: root.toggleBluetooth()
		}
	}

	// ---------- dispositivos ----------
	ListView {
		id: list
		Layout.fillWidth: true
		Layout.preferredHeight: Math.min(contentHeight, 206)
		visible: root.btOn
		clip: true
		spacing: 2
		boundsBehavior: Flickable.StopAtBounds
		model: ScriptModel {
			values: root.devices
			objectProp: "address"
		}

		delegate: Rectangle {
			id: row

			required property var modelData
			readonly property var dev: modelData
			readonly property bool isSelected: root.focused && root.selected === dev?.address
			readonly property bool busy: (dev?.pairing || dev?.state === BluetoothDeviceState.Connecting || dev?.state === BluetoothDeviceState.Disconnecting) ?? false

			width: ListView.view.width
			implicitHeight: 40
			radius: 12
			color: dev?.connected ? Qt.alpha(Colors.accent, isSelected ? 0.22 : 0.14) : isSelected ? Colors.surface : "transparent"
			border.width: isSelected ? 2 : 0
			border.color: Colors.accent

			// emparejado nuevo: confiar (reconexion automatica) y conectar
			Connections {
				target: row.dev
				function onPairedChanged() {
					if (row.dev?.paired) {
						row.dev.trusted = true;
						row.dev.connect();
					}
				}
				function onPairingChanged() {
					if (!row.dev?.pairing && !row.dev?.paired)
						root.error = `${row.dev?.name}: no se pudo emparejar`;
				}
			}

			MouseArea {
				id: rowArea
				anchors.fill: parent
				hoverEnabled: true
				cursorShape: Qt.PointingHandCursor
				onPositionChanged: mouse => {
					if (!Pointer.moved(rowArea, mouse))
						return;
					root.selected = row.dev?.address;
					root.wantFocus();
				}
				onClicked: root.activate(row.dev)
			}

			RowLayout {
				anchors.fill: parent
				anchors.leftMargin: 12
				anchors.rightMargin: 8
				spacing: 10

				Text {
					text: Icons.device(row.dev?.icon ?? "")
					color: row.dev?.connected ? Colors.accent : row.dev?.paired ? Colors.fg : Colors.muted
					font.family: Colors.font
					font.pixelSize: 17
				}
				Text {
					Layout.fillWidth: true
					text: row.dev?.name
					color: row.dev?.connected ? Colors.accent : row.dev?.paired ? Colors.fg : Colors.muted
					font.family: Colors.font
					font.pixelSize: 13
					font.bold: row.dev?.connected
					elide: Text.ElideRight
				}
				Text {
					visible: row.dev?.batteryAvailable && !forgetBtn.visible
					text: Icons.battery(row.dev?.battery ?? 0) + " " + Math.round(row.dev?.battery * 100) + "%"
					color: row.dev?.battery <= 0.15 ? Colors.red : Colors.muted
					font.family: Colors.font
					font.pixelSize: 11
				}
				Text {
					visible: !forgetBtn.visible
					text: row.dev?.pairing ? "emparejando…" : row.dev?.state === BluetoothDeviceState.Connecting ? "conectando…" : row.dev?.state === BluetoothDeviceState.Disconnecting ? "desconectando…" : row.dev?.connected ? "conectado" : row.dev?.paired ? "" : "nuevo"
					color: row.dev?.connected || row.busy ? Colors.accent : Colors.muted
					font.family: Colors.font
					font.pixelSize: 11
				}
				// olvidar dispositivo emparejado (raton encima o seleccionado)
				IconButton {
					id: forgetBtn
					visible: row.dev?.paired && (rowArea.containsMouse || hovered || row.isSelected)
					icon: Icons.trash
					size: 26
					danger: true
					onClicked: root.forget(row.dev)
				}
			}
		}
	}

	Text {
		Layout.fillWidth: true
		Layout.leftMargin: 4
		visible: root.error !== ""
		text: root.error
		color: Colors.red
		font.family: Colors.font
		font.pixelSize: 12
		wrapMode: Text.Wrap
	}

	Text {
		Layout.fillWidth: true
		Layout.leftMargin: 4
		visible: root.btOn && root.devices.length === 0
		text: root.discovering ? "Buscando dispositivos…" : "Sin dispositivos emparejados"
		color: Colors.muted
		font.family: Colors.font
		font.pixelSize: 12
	}
}
