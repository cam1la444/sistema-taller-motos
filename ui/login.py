"""Pantalla de inicio de sesión. Responsable: A."""
import ttkbootstrap as ttk
from core import session
from core.auth import verificar_login

MAX_INTENTOS = 3
SEGUNDOS_BLOQUEO = 30


class LoginFrame(ttk.Frame):
    def __init__(self, master, al_ingresar):
        super().__init__(master)
        self.al_ingresar = al_ingresar
        self.intentos = 0

        caja = ttk.Frame(self, padding=30)
        caja.place(relx=0.5, rely=0.5, anchor="center")
        ttk.Label(caja, text="Taller Pro", font=("", 24, "bold")).pack()
        ttk.Label(caja, text="Inicie sesión para continuar").pack(pady=(0, 20))

        self.var_usuario = ttk.StringVar()
        self.var_clave = ttk.StringVar()
        ttk.Label(caja, text="Usuario").pack(anchor="w")
        self.ent_usuario = ttk.Entry(caja, textvariable=self.var_usuario, width=30)
        self.ent_usuario.pack(pady=(0, 10))
        ttk.Label(caja, text="Contraseña").pack(anchor="w")
        ent_clave = ttk.Entry(caja, textvariable=self.var_clave, show="•", width=30)
        ent_clave.pack(pady=(0, 10))

        self.lbl_error = ttk.Label(caja, text="", bootstyle="danger")
        self.lbl_error.pack(pady=(0, 10))
        self.btn = ttk.Button(caja, text="Ingresar", command=self.ingresar, width=28)
        self.btn.pack()

        self.ent_usuario.focus()
        self.ent_usuario.bind("<Return>", lambda e: ent_clave.focus())
        ent_clave.bind("<Return>", lambda e: self.ingresar())

    def ingresar(self):
        usuario, clave = self.var_usuario.get().strip(), self.var_clave.get()
        if not usuario or not clave:
            self.lbl_error.config(text="Escriba usuario y contraseña")
            return
        try:
            datos = verificar_login(usuario, clave)
        except Exception as e:
            print("Error de BD:", e)
            self.lbl_error.config(text="No se pudo conectar a la base de datos")
            return
        if datos:
            session.iniciar(datos)
            self.al_ingresar()
            return
        self.intentos += 1
        if self.intentos >= MAX_INTENTOS:
            self.bloquear(SEGUNDOS_BLOQUEO)
        else:
            self.lbl_error.config(
                text=f"Datos incorrectos. Intentos restantes: {MAX_INTENTOS - self.intentos}")

    def bloquear(self, segundos):
        """Deshabilita el botón y cuenta hacia atrás sin congelar la ventana."""
        if segundos > 0:
            self.btn.config(state="disabled")
            self.lbl_error.config(text=f"Demasiados intentos. Espere {segundos} s")
            self.after(1000, lambda: self.bloquear(segundos - 1))
        else:
            self.intentos = 0
            self.btn.config(state="normal")
            self.lbl_error.config(text="")
