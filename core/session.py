"""Usuario que inició sesión y permisos por rol. Responsable: A."""

# Qué pantallas ve cada rol (las claves son las de MODULOS en ui/main_window.py)
PERMISOS = {
    "Administrador": ["inicio", "clientes", "vehiculos", "ordenes", "ventas",
                      "inventario", "reportes", "usuarios"],
    "Vendedor":      ["inicio", "clientes", "vehiculos", "ordenes", "ventas"],
    "Bodega":        ["inicio", "inventario"],
}

usuario_actual = None   # diccionario: id_usuario, nombre, rol


def iniciar(usuario):
    global usuario_actual
    usuario_actual = usuario


def cerrar():
    global usuario_actual
    usuario_actual = None


def tiene_acceso(clave_modulo):
    """True si el rol del usuario actual puede abrir ese módulo."""
    if usuario_actual is None:
        return False
    return clave_modulo in PERMISOS.get(usuario_actual["rol"], [])
