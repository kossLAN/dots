import QtQuick
import QtQuick.Shapes
import qs

Rectangle {
	id: root
	property var checkState: Qt.Unchecked;
	implicitHeight: 18
	implicitWidth: 18
	radius: 4
	color: checkState == Qt.Checked ? ShellSettings.colors.active.highlight : ShellSettings.colors.active.mid

	Behavior on color {
		ColorAnimation {
			duration: 150
		}
	}

	Shape {
		visible: checkState == Qt.Checked
		anchors.fill: parent
		anchors.margins: 3
		layer.enabled: true
		layer.samples: 10

		ShapePath {
			strokeColor: ShellSettings.colors.active.highlightedText
			strokeWidth: 2
			capStyle: ShapePath.RoundCap
			joinStyle: ShapePath.RoundJoin
			fillColor: "transparent"

			startX: 0
			startY: parent.height * 0.5

			PathLine {
				x: parent.width * 0.35
				y: parent.height * 0.85
			}

			PathLine {
				x: parent.width
				y: 0
			}
		}
	}
}
