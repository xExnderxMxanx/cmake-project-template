#include "MainWindow.hpp"
#include "ui_MainWindow.h"

namespace GUI {
MainWindow::MainWindow(QWidget *parent) noexcept :
    QMainWindow(parent), m_ui(new Ui::MainWindow) {
    this->m_ui->setupUi(this);
}

MainWindow::~MainWindow() noexcept {
    delete this->m_ui;
}
} // namespace GUI
 