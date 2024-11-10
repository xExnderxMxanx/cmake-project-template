#include <QApplication>

#include "MainWindow.hpp"

#undef main // Undefine main to avoid conflict

int main(int argc, char *argv[]) {
    QApplication app(argc, argv);
    
    GUI::MainWindow window;
    window.show();
    
    return QApplication::exec();
}