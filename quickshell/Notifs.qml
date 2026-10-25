pragma Singleton
pragma ComponentBehavior: Bound

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

// Servidor de notificaciones (reemplaza a swaync)
Singleton {
	id: root

	// se guarda en ~/.local/state/quickshell/.../notifs.json y sobrevive a reinicios
	property alias dnd: saved.dnd
	property bool panelOpen: false

	// mas antiguas primero (orden de llegada)
	readonly property var list: server.trackedNotifications.values
	// popups visibles, la mas nueva primero
	property var popups: []
	// id -> hora de llegada (ms)
	property var times: ({})
	// reloj para los "hace 5 min"
	property real now: Date.now()

	Timer {
		interval: 30000
		running: true
		repeat: true
		onTriggered: root.now = Date.now()
	}

	FileView {
		path: Quickshell.statePath("notifs.json")
		onAdapterUpdated: writeAdapter()
		// primera vez: crear el fichero con los valores por defecto
		onLoadFailed: error => {
			if (error === FileViewError.FileNotFound)
				writeAdapter();
		}

		JsonAdapter {
			id: saved
			property bool dnd: false
		}
	}

	NotificationServer {
		id: server
		keepOnReload: true
		persistenceSupported: true
		bodySupported: true
		bodyMarkupSupported: true
		bodyHyperlinksSupported: true
		actionsSupported: true
		imageSupported: true

		onNotification: n => {
			n.tracked = true;
			root.times[n.id] = Date.now();
			root.now = Date.now();
			if (!root.dnd && !root.panelOpen)
				root.popups = [n, ...root.popups.filter(p => p !== n)];
			n.closed.connect(() => root.hidePopup(n));
		}
	}

	function hidePopup(n) {
		popups = popups.filter(p => p !== n);
	}

	// segundos que dura el popup (0 = hasta cerrarlo)
	function timeoutFor(n) {
		if (n.urgency === NotificationUrgency.Critical)
			return 0;
		if (n.expireTimeout > 0)
			return n.expireTimeout;
		return n.urgency === NotificationUrgency.Low ? 3 : 6;
	}

	function clearAll() {
		for (const n of list.slice())
			n.dismiss();
	}

	function ago(id) {
		const t = times[id];
		if (!t)
			return "";
		const m = Math.floor((now - t) / 60000);
		if (m < 1)
			return "ahora";
		if (m < 60)
			return `hace ${m} min`;
		const h = Math.floor(m / 60);
		return h < 24 ? `hace ${h} h` : `hace ${Math.floor(h / 24)} d`;
	}

	onPanelOpenChanged: if (panelOpen) popups = []

	// estado para el icono de la campana en waybar (custom/notification, signal 8)
	readonly property string state: (dnd ? "dnd-" : "") + (list.length > 0 ? "notification" : "none")
	readonly property string status: JSON.stringify({
		text: "",
		alt: state,
		class: state
	})
	onStatusChanged: writeStatus()
	Component.onCompleted: writeStatus()

	function writeStatus() {
		Quickshell.execDetached(["sh", "-c", 'printf "%s\\n" "$1" > "$XDG_RUNTIME_DIR/qs-notifs.json"; pkill -RTMIN+8 waybar', "sh", status]);
	}
}
