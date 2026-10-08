"""Ventana principal: menú lateral según rol. Responsable: A.
Para agregar una pantalla nueva: créela en ui/ y añádala a MODULOS y a core/session.PERMISOS."""
import ttkbootstrap as ttk
from core import session
from ui.clientes import ClientesFrame
from ui.vehiculos import VehiculosFrame
from ui.ordenes import OrdenesFrame
from ui.ventas import VentasFrame
from ui.inventario import InventarioFrame
from ui.reportes import ReportesFrame
from ui.usuarios import UsuariosFrame


class InicioFrame(ttk.Frame):
    def __init__(self, master):
        super().__init__(master, padding=20)
        ttk.Label(self, text="Inicio", font=("", 20, "bold")).pack(anchor="w")
        ttk.Label(self, text=f"Bienvenido, {session.usuario_actual['nombre']}").pack(anchor="w", pady=10)
        # TODO (A): tarjetas con ventas de hoy, transacciones y stock bajo

    def al_mostrar(self):
        pass


# (clave, texto del menú, clase de la pantalla)
MODULOS = [
    ("inicio", "Inicio", InicioFrame),
    ("clientes", "Clientes", ClientesFrame),
    ("vehiculos", "Vehículos", VehiculosFrame),
    ("ordenes", "Órdenes", OrdenesFrame),
    ("ventas", "Ventas", VentasFrame),
    ("inventario", "Inventario", InventarioFrame),
    ("reportes", "Reportes", ReportesFrame),
    ("usuarios", "Usuarios", UsuariosFrame),
]


class MainWindow(ttk.Frame):
    def __init__(self, master, al_cerrar_sesion):
        super().__init__(master)
        self.pack(fill="both", expand=True)
        self.pantallas = {}      # pantallas ya creadas (se crean al abrirlas la primera vez)
        self.pantalla_actual = None

        menu = ttk.Frame(self, padding=12, bootstyle="secondary")
        menu.pack(side="left", fill="y")
        ttk.Label(menu, text="Taller Pro", font=("", 16, "bold"), bootstyle="inverse-secondary").pack(pady=(0, 4))
        u = session.usuario_actual
        ttk.Label(menu, text=f"{u['nombre']}\n{u['rol']}", bootstyle="inverse-secondary").pack(pady=(0, 16))

        for clave, texto, clase in MODULOS:
            if session.tiene_acceso(clave):          # el rol decide qué botones existen
                ttk.Button(menu, text=texto, width=18, bootstyle="secondary",
                           command=lambda c=clave, k=clase: self.mostrar(c, k)).pack(pady=2)
        ttk.Button(menu, text="Cerrar sesión", width=18, bootstyle="danger-outline",
                   command=al_cerrar_sesion).pack(side="bottom")

        self.contenido = ttk.Frame(self)
        self.contenido.pack(side="right", fill="both", expand=True)
        self.mostrar("inicio", InicioFrame)

    def mostrar(self, clave, clase):
        if self.pantalla_actual:
            self.pantalla_actual.pack_forget()
        if clave not in self.pantallas:
            self.pantallas[clave] = clase(self.contenido)
        self.pantalla_actual = self.pantallas[clave]
        self.pantalla_actual.pack(fill="both", expand=True)
        self.pantalla_actual.al_mostrar()
