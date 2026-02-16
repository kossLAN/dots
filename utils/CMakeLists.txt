cmake_minimum_required(VERSION 3.16)

project(utils LANGUAGES CXX)

find_package(Qt6 REQUIRED COMPONENTS Core Qml Gui Network Quick)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_INSTALL_RPATH "$ORIGIN")
set(CMAKE_AUTOMOC ON)
qt_policy(SET QTP0001 NEW)

# nix workaround
if (CMAKE_EXPORT_COMPILE_COMMANDS)
	set(CMAKE_CXX_STANDARD_INCLUDE_DIRECTORIES ${CMAKE_CXX_IMPLICIT_INCLUDE_DIRECTORIES})
endif()

# MicroTeX
find_library(MICROTEX_LIBRARY NAMES LaTeX clatexmath microtex REQUIRED)
find_path(MICROTEX_INCLUDE_DIR NAMES "microtex/latex.h" REQUIRED)
find_package(PkgConfig REQUIRED)
pkg_check_modules(TINYXML2 REQUIRED tinyxml2)

add_library(nixiutils SHARED
	utilsplugin.cpp
	clipboard.cpp clipboard.h
	cachedimage.cpp cachedimage.h
	latexrenderer.cpp latexrenderer.h
)

target_include_directories(nixiutils PRIVATE ${MICROTEX_INCLUDE_DIR} ${MICROTEX_INCLUDE_DIR}/microtex)
target_link_libraries(nixiutils Qt6::Qml Qt6::Gui Qt6::Core Qt6::Network Qt6::Quick ${MICROTEX_LIBRARY} ${TINYXML2_LIBRARIES})
target_compile_definitions(nixiutils PRIVATE BUILD_QT)

if (MICROTEX_RES_DIR)
	target_compile_definitions(nixiutils PRIVATE MICROTEX_RES_DIR="${MICROTEX_RES_DIR}")
endif()

install(TARGETS nixiutils DESTINATION lib/qt-6/qml/NixiUtils)
install(FILES qmldir DESTINATION lib/qt-6/qml/NixiUtils)
