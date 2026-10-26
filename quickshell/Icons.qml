pragma Singleton

import QtQuick
import Quickshell

// Iconos Nerd Font por codigo (asi no se rompen al copiar/pegar)
Singleton {
	function g(cp) { return String.fromCodePoint(cp); }

	readonly property string wifi: g(0xF05A9)
	readonly property string wifiOff: g(0xF05AA)
	readonly property string wifiNone: g(0xF092E)
	readonly property string refresh: g(0xF0453)
	readonly property string lock: g(0xF033E)
	readonly property string saved: g(0xF0193)
	readonly property string trash: g(0xF01B4)
	readonly property string eye: g(0xF0208)
	readonly property string eyeOff: g(0xF0209)
	readonly property string close: g(0xF0156)
	readonly property string bell: g(0xF009A)
	readonly property string bellOff: g(0xF009B)
	readonly property string check: g(0xF012C)
	readonly property string chevronDown: g(0xF0140)
	readonly property string chevronRight: g(0xF0142)

	readonly property string bt: g(0xF00AF)
	readonly property string btOff: g(0xF00B2)
	readonly property string btConnected: g(0xF00B1)

	// icono freedesktop de BlueZ (audio-headset, input-mouse...) -> glifo
	function device(icon) {
		if (icon.startsWith("audio-head") || icon === "audio-headphones")
			return g(0xF02CB); // auriculares
		if (icon.startsWith("audio"))
			return g(0xF04C3); // altavoz
		if (icon === "input-mouse")
			return g(0xF037D);
		if (icon === "input-keyboard")
			return g(0xF030C);
		if (icon === "input-gaming")
			return g(0xF0297);
		if (icon.startsWith("phone"))
			return g(0xF011C);
		if (icon === "computer")
			return g(0xF0322);
		return bt;
	}

	// level: 0..1 (mismos iconos que la bateria de waybar)
	readonly property var batteryLevels: [g(0xF008E), g(0xF007A), g(0xF007B), g(0xF007C), g(0xF007D), g(0xF007E), g(0xF007F), g(0xF0080), g(0xF0081), g(0xF0082), g(0xF0079)]
	function battery(level) {
		return batteryLevels[Math.max(0, Math.min(10, Math.round(level * 10)))];
	}

	readonly property var signalOpen: [g(0xF092F), g(0xF091F), g(0xF0922), g(0xF0925), g(0xF0928)]
	readonly property var signalLocked: [g(0xF092C), g(0xF0921), g(0xF0924), g(0xF0927), g(0xF092A)]

	// strength: 0..1
	function signal(strength, locked) {
		const i = Math.min(4, Math.floor(strength * 5));
		return (locked ? signalLocked : signalOpen)[i];
	}
}
