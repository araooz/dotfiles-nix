pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Io
import Quickshell.Networking

// Modulo Wi-Fi del panel
ColumnLayout {
	id: root

	// el panel esta abierto
	property bool active: false
	// esta seccion tiene la seleccion del teclado
	property bool focused: false

	readonly property var dev: Networking.devices.values.find(d => d.type === DeviceType.Wifi) ?? null
	readonly property bool wifiOn: Networking.wifiEnabled
	readonly property var allNetworks: dev ? dev.networks.values.filter(n => n.name !== "").sort((a, b) => (b.connected - a.connected) || (b.signalStrength - a.signalStrength)) : []
	readonly property var networks: filter === "" ? allNetworks : allNetworks.filter(n => n.name.toLowerCase().includes(filter.toLowerCase()))
	readonly property var current: allNetworks.find(n => n.connected) ?? null

	// seleccion por nombre: no salta cuando la lista se reordena por la señal
	property string selected: ""
	readonly property int selectedIndex: networks.findIndex(n => n.name === selected)
	readonly property var selectedNet: selectedIndex >= 0 ? networks[selectedIndex] : null

	// red con el campo de contraseña abierto
	property string expanded: ""
	property string error: ""
	property string ip: ""
	property bool filtering: false
	property string filter: ""

	// el campo de texto (contraseña o filtro) suelta el teclado
	signal released
	// el usuario pide ir a esta seccion (raton o "/")
	signal wantFocus

	spacing: 10

	// escanear solo con el panel abierto y sin conexion, o tras un ^R manual
	readonly property bool shouldScan: active && wifiOn && (current === null || scanSpin.running)

	Binding {
		when: root.dev !== null
		target: root.dev
		property: "scannerEnabled"
		value: root.shouldScan
	}

	onActiveChanged: {
		if (active) {
			refreshIp();
			selected = current?.name ?? networks[0]?.name ?? "";
			// cuando la ventana ya es visible; si no, la lista ignora el reposicionado
			Qt.callLater(list.positionViewAtBeginning);
		} else {
			expanded = "";
			error = "";
			closeFilter();
		}
	}
	onCurrentChanged: ipDelay.restart()
	// al cerrarse el campo de contraseña el teclado vuelve a la lista
	onExpandedChanged: if (expanded === "") released()
	// si la red seleccionada desaparece, seleccionar la primera
	onNetworksChanged: if (selectedIndex < 0) selected = networks[0]?.name ?? ""
	onSelectedIndexChanged: if (selectedIndex >= 0) list.positionViewAtIndex(selectedIndex, ListView.Contain)

	function refreshIp() {
		if (dev && current)
			ipProc.running = true;
		else
			ip = "";
	}

	function secured(net) {
		return !!net && net.security !== WifiSecurityType.Open && net.security !== WifiSecurityType.Owe;
	}

	function activate(net) {
		error = "";
		if (!net || net.stateChanging)
			return;
		selected = net.name;
		if (net.connected) {
			net.disconnect();
		} else if (net.known || !secured(net)) {
			expanded = "";
			net.connect();
		} else {
			expanded = expanded === net.name ? "" : net.name;
		}
	}

	function forget(net) {
		if (!net || !net.known)
			return;
		if (expanded === net.name)
			expanded = "";
		net.forget();
	}

	// ---------- teclado ----------
	function move(delta) {
		if (networks.length === 0)
			return;
		const i = selectedIndex < 0 ? 0 : Math.max(0, Math.min(networks.length - 1, selectedIndex + delta));
		selected = networks[i].name;
	}
	function activateSelected() {
		activate(selectedNet);
	}
	function forgetSelected() {
		forget(selectedNet);
	}
	// escaneo manual: el escaner se enciende mientras dura scanSpin
	function rescan() {
		if (wifiOn)
			scanSpin.restart();
	}
	function toggleWifi() {
		Networking.wifiEnabled = !Networking.wifiEnabled;
	}
	function openFilter() {
		if (!wifiOn)
			return;
		expanded = "";
		filtering = true;
		filterInput.forceActiveFocus();
	}
	function closeFilter() {
		filtering = false;
		filter = "";
		filterInput.text = "";
	}

	Timer {
		id: ipDelay
		interval: 1500
		onTriggered: root.refreshIp()
	}
	Timer {
		id: scanSpin
		interval: 8000
	}
	Timer {
		id: errorClear
		interval: 8000
		onTriggered: root.error = ""
	}
	onErrorChanged: if (error !== "") errorClear.restart()

	Process {
		id: ipProc
		command: ["nmcli", "-g", "IP4.ADDRESS", "device", "show", root.dev?.name ?? ""]
		stdout: StdioCollector {
			onStreamFinished: root.ip = text.split("\n")[0].split("/")[0]
		}
	}

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
			color: root.wifiOn ? Colors.accent : Colors.surface

			Text {
				anchors.centerIn: parent
				text: root.wifiOn ? (root.current ? Icons.wifi : Icons.wifiNone) : Icons.wifiOff
				color: root.wifiOn ? Colors.bg : Colors.muted
				font.family: Colors.font
				font.pixelSize: 20
			}
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 0

			Text {
				text: "Wi-Fi"
				color: root.focused ? Colors.accent : Colors.fg
				font.family: Colors.font
				font.pixelSize: 18
				font.bold: true
			}
			Text {
				Layout.fillWidth: true
				text: !root.wifiOn ? "Apagado" : root.current ? root.current.name + (root.ip ? "  ·  " + root.ip : "") : "Sin conexión"
				color: root.current ? Colors.fg : Colors.muted
				font.family: Colors.font
				font.pixelSize: 12
				elide: Text.ElideRight
			}
		}

		IconButton {
			visible: root.wifiOn
			icon: Icons.refresh
			spinning: scanSpin.running
			onClicked: root.rescan()
		}

		Switch {
			checked: root.wifiOn
			onToggled: root.toggleWifi()
		}
	}

	// ---------- filtro (/) ----------
	Rectangle {
		Layout.fillWidth: true
		visible: root.filtering
		implicitHeight: 36
		radius: 12
		color: Colors.surface
		border.width: 1
		border.color: filterInput.activeFocus ? Colors.accent : Colors.overlay

		RowLayout {
			anchors.fill: parent
			anchors.leftMargin: 12
			anchors.rightMargin: 12
			spacing: 8

			Text {
				text: "/"
				color: Colors.accent
				font.family: Colors.font
				font.pixelSize: 14
				font.bold: true
			}
			TextInput {
				id: filterInput
				Layout.fillWidth: true
				color: Colors.fg
				selectionColor: Colors.accent
				selectedTextColor: Colors.bg
				font.family: Colors.font
				font.pixelSize: 13
				clip: true

				Text {
					anchors.verticalCenter: parent.verticalCenter
					visible: filterInput.text === ""
					text: "Buscar red…"
					color: Colors.muted
					font: filterInput.font
				}

				onTextChanged: {
					root.filter = text;
					root.selected = root.networks[0]?.name ?? "";
				}
				Keys.onPressed: event => {
					if (event.key === Qt.Key_Up) {
						root.move(-1);
					} else if (event.key === Qt.Key_Down) {
						root.move(1);
					} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
						// conectar a la seleccionada y volver a la lista
						const net = root.selectedNet;
						root.closeFilter();
						root.released();
						root.activate(net);
					} else if (event.key === Qt.Key_Escape) {
						root.closeFilter();
						root.released();
					} else {
						return;
					}
					event.accepted = true;
				}
			}
		}
	}

	// ---------- lista de redes ----------
	ListView {
		id: list
		Layout.fillWidth: true
		Layout.preferredHeight: Math.min(contentHeight, 5 * 42) // 5 redes visibles, el resto con scroll
		visible: root.wifiOn
		clip: true
		spacing: 2
		boundsBehavior: Flickable.StopAtBounds
		model: ScriptModel {
			values: root.networks
			objectProp: "name"
		}

		delegate: ColumnLayout {
			id: row

			required property var modelData
			readonly property var net: modelData
			readonly property bool locked: root.secured(net)
			readonly property bool open: root.expanded === net?.name
			readonly property bool busy: (net?.stateChanging || net?.state === ConnectionState.Connecting) ?? false
			readonly property bool isSelected: root.focused && root.selected === net?.name

			width: ListView.view.width
			spacing: 4

			Connections {
				target: row.net
				function onConnectionFailed(reason) {
					const why = {
						[ConnectionFailReason.NoSecrets]: "contraseña incorrecta",
						[ConnectionFailReason.WifiAuthTimeout]: "tiempo de espera agotado",
						[ConnectionFailReason.WifiNetworkLost]: "se perdió la red"
					}[reason] ?? "no se pudo conectar";
					root.error = `${row.net?.name}: ${why}`;
					if (row.locked && reason === ConnectionFailReason.NoSecrets)
						root.expanded = row.net?.name;
				}
			}

			Rectangle {
				Layout.fillWidth: true
				implicitHeight: 40
				radius: 12
				color: row.net?.connected ? Qt.alpha(Colors.accent, row.isSelected ? 0.22 : 0.14) : row.isSelected || row.open ? Colors.surface : "transparent"
				border.width: row.isSelected ? 2 : 0
				border.color: Colors.accent

				MouseArea {
					id: rowArea
					anchors.fill: parent
					hoverEnabled: true
					cursorShape: Qt.PointingHandCursor
					// solo al mover el raton, no cuando la lista se desplaza debajo
					onPositionChanged: mouse => {
						if (!Pointer.moved(rowArea, mouse))
							return;
						root.selected = row.net?.name;
						root.wantFocus();
					}
					onClicked: root.activate(row.net)
				}

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 12
					anchors.rightMargin: 8
					spacing: 10

					Text {
						text: Icons.signal(row.net?.signalStrength ?? 0, row.locked)
						color: row.net?.connected ? Colors.accent : Colors.fg
						font.family: Colors.font
						font.pixelSize: 17
					}
					Text {
						Layout.fillWidth: true
						text: row.net?.name ?? ""
						color: row.net?.connected ? Colors.accent : Colors.fg
						font.family: Colors.font
						font.pixelSize: 13
						font.bold: !!row.net?.connected
						elide: Text.ElideRight
					}
					Text {
						visible: !!(row.net?.known && !row.net?.connected && !forgetBtn.visible)
						text: Icons.saved
						color: Colors.muted
						font.family: Colors.font
						font.pixelSize: 13
					}
					Text {
						visible: !forgetBtn.visible
						text: row.busy ? "conectando…" : row.net?.connected ? "conectado" : Math.round(row.net?.signalStrength * 100) + "%"
						color: row.net?.connected || row.busy ? Colors.accent : Colors.muted
						font.family: Colors.font
						font.pixelSize: 11
					}
					// olvidar red guardada (raton encima o seleccionada)
					IconButton {
						id: forgetBtn
						visible: !!(row.net?.known && (rowArea.containsMouse || hovered || row.isSelected))
						icon: Icons.trash
						size: 26
						danger: true
						onClicked: root.forget(row.net)
					}
				}
			}

			// ---------- contraseña ----------
			Rectangle {
				Layout.fillWidth: true
				Layout.bottomMargin: 4
				visible: row.open
				implicitHeight: 40
				radius: 12
				color: Colors.surface
				border.width: 1
				border.color: pass.activeFocus ? Colors.accent : Colors.overlay

				onVisibleChanged: if (visible) {
					pass.text = "";
					pass.forceActiveFocus();
				}

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 12
					anchors.rightMargin: 6
					spacing: 8

					Text {
						text: Icons.lock
						color: Colors.accent
						font.family: Colors.font
						font.pixelSize: 15
					}
					TextInput {
						id: pass
						Layout.fillWidth: true
						color: Colors.fg
						selectionColor: Colors.accent
						selectedTextColor: Colors.bg
						font.family: Colors.font
						font.pixelSize: 13
						echoMode: showPass.shown ? TextInput.Normal : TextInput.Password
						clip: true

						Text {
							anchors.verticalCenter: parent.verticalCenter
							visible: pass.text === ""
							text: "Contraseña"
							color: Colors.muted
							font: pass.font
						}

						onAccepted: {
							if (text === "")
								return;
							root.error = "";
							row.net?.connectWithPsk(text);
							root.expanded = "";
						}
						Keys.onPressed: event => {
							if (event.key === Qt.Key_Escape) {
								root.expanded = "";
							} else if (event.key === Qt.Key_H && event.modifiers & Qt.ControlModifier) {
								showPass.shown = !showPass.shown;
							} else {
								return;
							}
							event.accepted = true;
						}
					}
					IconButton {
						id: showPass
						property bool shown: false
						icon: shown ? Icons.eyeOff : Icons.eye
						size: 28
						onClicked: shown = !shown
					}
					IconButton {
						icon: Icons.check
						size: 28
						accent: true
						onClicked: pass.accepted()
					}
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
		visible: root.wifiOn && root.networks.length === 0
		text: root.filter !== "" ? "Ninguna red coincide" : "Buscando redes…"
		color: Colors.muted
		font.family: Colors.font
		font.pixelSize: 12
	}
}
