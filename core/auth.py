"""Verificación de login con bcrypt. Responsable: A."""
import bcrypt
from core.database import consultar


def verificar_login(usuario, clave):
    """Devuelve el diccionario del usuario si las credenciales son válidas; si no, None."""
    filas = consultar(
        "SELECT id_usuario, nombre, password_hash, rol FROM Usuarios "
        "WHERE usuario = ? AND activo = 1", (usuario,))
    if filas and bcrypt.checkpw(clave.encode(), filas[0]["password_hash"].encode()):
        return {k: filas[0][k] for k in ("id_usuario", "nombre", "rol")}
    return None
