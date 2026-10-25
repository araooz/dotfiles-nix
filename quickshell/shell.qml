import QtQuick
import Quickshell
import Quickshell.Io

// Panel lateral (Wi-Fi + notificaciones) y popups de notificaciones.
//   qs ipc call panel toggle      abrir/cerrar el panel (Super+A, waybar)
//   qs ipc call notifs toggleDnd  no molestar (click derecho en la campana)
ShellRoot {
	Panel {
		id: panel
	}

	Popups {}

	IpcHandler {
		target: "panel"

		function toggle(): void {
			panel.open = !panel.open;
		}
		function open(): void {
			panel.open = true;
		}
		function close(): void {
			panel.open = false;
		}
	}

	IpcHandler {
		target: "notifs"

		function toggleDnd(): void {
			Notifs.dnd = !Notifs.dnd;
		}
		function clear(): void {
			Notifs.clearAll();
		}
	}
}
