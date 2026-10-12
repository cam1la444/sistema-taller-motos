"""Verificación de login con bcrypt. Responsable: A."""
import bcrypt
from core.database import consultar


def verificar_login(usuario, clave):
    """Devuelve el diccionario del usuario si las credenciales son válidas; si no, None."""
    filas = consultar(
        "SELECT UsuarioID, NombreCompleto, PasswordHash, Rol FROM Usuarios "
        "WHERE NombreUsuario = ? AND Activo = 1", (usuario,))
    if filas and bcrypt.checkpw(clave.encode(), filas[0]["PasswordHash"].encode()):
        return {k: filas[0][k] for k in ("UsuarioID", "NombreCompleto", "Rol")}
    return None
