cmake_minimum_required(VERSION 3.18)
project(AetherBoot LANGUAGES CXX)

set(CMAKE_CXX_STANDARD 20)
set(CMAKE_AUTOMOC ON)
set(CMAKE_AUTORCC ON)
set(CMAKE_AUTOUIC ON)

find_package(Qt6 REQUIRED COMPONENTS Core Gui Qml Quick QuickControls2)

add_executable(aetherboot
    src/main.cpp
    src/backend/EFIScanner.cpp
    src/backend/BootEntry.cpp
    src/backend/BootHandler.cpp
    qml/qml.qrc
)

target_include_directories(aetherboot PRIVATE src src/backend)

target_link_libraries(aetherboot
    Qt6::Core
    Qt6::Gui
    Qt6::Qml
    Qt6::Quick
    Qt6::QuickControls2
)