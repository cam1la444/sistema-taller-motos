"""Punto de entrada. Solo arranca la app; la lógica vive en core/ y ui/.
Ejecutar:  python main.py   (en Linux: python3 main.py)"""
import ttkbootstrap as ttk
from core import session
from ui.login import LoginFrame
from ui.main_window import MainWindow

app = ttk.Window(title="Taller Pro", themename="darkly", size=(1100, 650), minsize=(900, 550))


def limpiar():
    for w in app.winfo_children():
        w.destroy()


def mostrar_login():
    limpiar()
    LoginFrame(app, al_ingresar=mostrar_principal).pack(fill="both", expand=True)


def mostrar_principal():
    limpiar()
    MainWindow(app, al_cerrar_sesion=cerrar_sesion)


def cerrar_sesion():
    session.cerrar()
    mostrar_login()


mostrar_login()
app.mainloop()
