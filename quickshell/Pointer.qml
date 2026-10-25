pragma Singleton

import QtQuick
import Quickshell

// Distingue un movimiento real del raton de cuando el contenido se desplaza
// debajo de un raton quieto (Qt manda eventos de hover en ambos casos).
Singleton {
	property real x: NaN
	property real y: NaN

	function reset() {
		x = NaN;
		y = NaN;
	}

	// mouse: el evento de un MouseArea; item: ese MouseArea
	function moved(item, mouse) {
		const p = item.mapToItem(null, mouse.x, mouse.y);
		const real = !isNaN(x) && (Math.abs(p.x - x) > 1 || Math.abs(p.y - y) > 1);
		x = p.x;
		y = p.y;
		return real;
	}
}
