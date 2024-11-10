#ifndef CMAKE_PROJECT_TEMPLATE_GUI_MAINWINDOW_HPP
#define CMAKE_PROJECT_TEMPLATE_GUI_MAINWINDOW_HPP

#include <QMainWindow>

namespace GUI {
QT_BEGIN_NAMESPACE
namespace Ui { class MainWindow; }
QT_END_NAMESPACE

class MainWindow : public QMainWindow {
    Q_OBJECT
    
    Ui::MainWindow *m_ui{nullptr};
    
public:
    explicit MainWindow(QWidget *parent = nullptr) noexcept;

    MainWindow(const MainWindow &) = delete;
    MainWindow(MainWindow &&) = delete;

    MainWindow &operator=(const MainWindow &) = delete;
    MainWindow &operator=(MainWindow &&) = delete;
    
    ~MainWindow() noexcept override;
};
} // namespace GUI

#endif // CMAKE_PROJECT_TEMPLATE_GUI_MAINWINDOW_HPP
