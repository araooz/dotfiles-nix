import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Hyprland

// Barra lateral: Wi-Fi arriba y notificaciones debajo.
// Toma el teclado en cuanto se abre y lo suelta al cerrarse.
PanelWindow {
	id: panel

	property bool open: false
	property real shown: open ? 1 : 0
	// seccion con la seleccion del teclado, en orden de Tab
	readonly property var sections: ["wifi", "bt", "notifs"]
	property string section: "wifi"
	// hay un campo de texto abierto (contraseña o filtro del wifi)
	readonly property bool typing: wifi.expanded !== "" || wifi.filtering

	Behavior on shown {
		NumberAnimation {
			duration: 180
			easing.type: Easing.OutCubic
		}
	}

	visible: shown > 0
	anchors {
		top: true
		right: true
		bottom: true
	}
	margins {
		top: 10
		right: 10
		bottom: 10
	}
	exclusionMode: ExclusionMode.Normal
	exclusiveZone: 0
	implicitWidth: 420
	color: "transparent"
	WlrLayershell.layer: WlrLayer.Overlay
	WlrLayershell.namespace: "quickshell-panel"
	WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None

	onOpenChanged: {
		Notifs.panelOpen = open;
		if (open) {
			Pointer.reset();
			section = "wifi";
			keys.forceActiveFocus();
		}
	}

	// click fuera del panel lo cierra
	HyprlandFocusGrab {
		windows: [panel]
		active: panel.open
		onCleared: panel.open = false
	}

	function switchSection(delta) {
		wifi.expanded = "";
		wifi.closeFilter();
		const i = sections.indexOf(section);
		section = sections[(i + delta + sections.length) % sections.length];
		keys.forceActiveFocus();
	}

	// atajos; las teclas que no usan los campos de texto tambien llegan aqui
	function handleKey(event) {
		const k = event.key;
		const ctrl = event.modifiers & Qt.ControlModifier;
		const shift = event.modifiers & Qt.ShiftModifier;
		const sec = section === "wifi" ? wifi : section === "bt" ? bt : notifs;

		if (ctrl) {
			if (k === Qt.Key_R && section === "bt")
				bt.toggleScan();
			else if (k === Qt.Key_R)
				wifi.rescan();
			else if (k === Qt.Key_W)
				wifi.toggleWifi();
			else if (k === Qt.Key_B)
				bt.toggleBluetooth();
			else if (k === Qt.Key_D)
				Notifs.dnd = !Notifs.dnd;
			else
				return;
		} else if (k === Qt.Key_Escape) {
			open = false;
		} else if (k === Qt.Key_Tab || k === Qt.Key_Backtab) {
			// en wayland Shift+Tab puede llegar como Tab con Shift
			switchSection(k === Qt.Key_Backtab || shift ? -1 : 1);
		} else if (k === Qt.Key_Down || k === Qt.Key_J) {
			sec.move(1);
		} else if (k === Qt.Key_Up || k === Qt.Key_K) {
			sec.move(-1);
		} else if (k === Qt.Key_PageDown) {
			sec.move(5);
		} else if (k === Qt.Key_PageUp) {
			sec.move(-5);
		} else if (k === Qt.Key_End) {
			sec.move(1000);
		} else if (k === Qt.Key_Home) {
			sec.move(-1000);
		} else if (k === Qt.Key_Return || k === Qt.Key_Enter) {
			sec.activateSelected();
		} else if (k === Qt.Key_Delete) {
			if (section === "wifi")
				wifi.forgetSelected();
			else if (section === "bt")
				bt.forgetSelected();
			else if (shift)
				Notifs.clearAll();
			else
				notifs.dismissSelected();
		} else if (section === "notifs" && (k === Qt.Key_Left || k === Qt.Key_H)) {
			notifs.moveAction(-1);
		} else if (section === "notifs" && (k === Qt.Key_Right || k === Qt.Key_L)) {
			notifs.moveAction(1);
		} else if (k === Qt.Key_Slash) {
			section = "wifi";
			wifi.openFilter();
		} else {
			return;
		}
		event.accepted = true;
	}

	component Separator: Rectangle {
		Layout.fillWidth: true
		Layout.leftMargin: 4
		Layout.rightMargin: 4
		implicitHeight: 1
		color: Colors.overlay
	}

	Rectangle {
		id: keys

		anchors.fill: parent
		color: Colors.bg
		border.width: 2
		border.color: Qt.alpha(Colors.accent, 0.5)
		radius: 20
		opacity: panel.shown
		transform: Translate {
			x: (1 - panel.shown) * 40
		}

		focus: true
		Keys.onPressed: event => panel.handleKey(event)

		ColumnLayout {
			anchors.fill: parent
			anchors.margins: 14
			spacing: 14

			WifiSection {
				id: wifi
				Layout.fillWidth: true
				active: panel.open
				focused: panel.section === "wifi"
				onWantFocus: panel.section = "wifi"
				onReleased: keys.forceActiveFocus()
			}

			Separator {}

			BluetoothSection {
				id: bt
				Layout.fillWidth: true
				active: panel.open
				focused: panel.section === "bt"
				onWantFocus: {
					// no robar el teclado a un campo de texto abierto
					if (!panel.typing)
						panel.section = "bt";
				}
			}

			Separator {}

			NotifSection {
				id: notifs
				Layout.fillWidth: true
				Layout.fillHeight: true
				focused: panel.section === "notifs"
				onWantFocus: {
					if (!panel.typing)
						panel.section = "notifs";
				}
				onActed: panel.open = false
			}

			// ---------- ayuda de atajos ----------
			Text {
				Layout.fillWidth: true
				Layout.leftMargin: 4
				Layout.rightMargin: 4
				horizontalAlignment: Text.AlignHCenter
				wrapMode: Text.Wrap
				textFormat: Text.StyledText
				color: Colors.muted
				font.family: Colors.font
				font.pixelSize: 11
				lineHeight: 1.3

				function k(key, what) {
					// &nbsp; para que un atajo nunca se parta entre dos lineas
					return `<font color="${Colors.fg}"><b>${key}</b></font>&nbsp;${what.replace(/ /g, "&nbsp;")}`;
				}
				text: {
					const sep = "&nbsp;&nbsp; ";
					if (wifi.filtering)
						return [k("↑↓", "mover"), k("⏎", "conectar"), k("Esc", "salir")].join(sep);
					if (wifi.expanded !== "")
						return [k("⏎", "conectar"), k("^H", "ver contraseña"), k("Esc", "cancelar")].join(sep);
					if (panel.section === "wifi")
						return [k("↑↓", "mover"), k("⏎", "conectar"), k("Supr", "olvidar"), k("/", "buscar"), k("^R", "escanear"), k("^W", "wifi"), k("Tab", "bluetooth")].join(sep);
					if (panel.section === "bt")
						return [k("↑↓", "mover"), k("⏎", "conectar"), k("Supr", "olvidar"), k("^R", "buscar nuevos"), k("^B", "bluetooth"), k("Tab", "notificaciones")].join(sep);
					return [k("↑↓", "mover"), k("←→", "acciones"), k("⏎", "abrir"), k("Supr", "descartar"), k("⇧Supr", "limpiar"), k("^D", "no molestar"), k("Tab", "wifi")].join(sep);
				}
			}
		}
	}
}
