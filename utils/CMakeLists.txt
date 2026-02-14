cmake_minimum_required(VERSION 3.16)

project(utils LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Gui Network)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INSTALL_RPATH "$ORIGIN")
set(CMAKE_AUTOMOC ON)
qt_policy(SET QTP0001 NEW)

# nix workaround
if (CMAKE_EXPORT_COMPILE_COMMANDS)
	set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
endif()

add_library(nixiutils SHARED utilsplugin.cpp clipboard.cpp clipboard.h cachedimage.cpp cachedimage.h)

target_link_libraries(nixiutils Qt6::Qml Qt6::Gui Qt6::Core Qt6::Network)

install(TARGETS nixiutils DESTINATION lib/qt-6/qml/NixiUtils)
install(FILES qmldir DESTINATION lib/qt-6/qml/NixiUtils)
