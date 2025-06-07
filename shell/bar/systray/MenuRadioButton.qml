import QtQuick
import qs

Rectangle {
	id: root
	property var checkState: Qt.Unchecked;
	implicitHeight: 18
	implicitWidth: 18
	radius: width / 2
	color: checkState == Qt.Checked ? ShellSettings.colors.active.highlight : ShellSettings.colors.active.mid

	Behavior on color {
		ColorAnimation {
			duration: 150
		}
	}

	Rectangle {
		anchors.centerIn: parent
		visible: checkState == Qt.Checked
		width: parent.width * 0.4
		height: width
		radius: width / 2
		color: ShellSettings.colors.active.highlightedText
	}
}
