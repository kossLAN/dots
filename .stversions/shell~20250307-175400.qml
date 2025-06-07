//@ pragma UseQApplication

import Quickshell 
import QtQuick 
import "bar" as Bar
import "launcher" as Launcher

ShellRoot {
  Component.onCompleted: [Launcher.Controller.init()] 

  Variants {
    model: Quickshell.screens;

    Scope {
      property var modelData; 
      
      Bar.Bar {
        screen: modelData;
      } 
    }
  }

  ReloadPopup {}
}
