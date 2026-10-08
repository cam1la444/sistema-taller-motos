# Taller Pro — Sistema de gestión de taller de autos y motos

## Instalación
1. `pip install -r requirements.txt`  (Linux además: `sudo apt install python3-tk unixodbc-dev` y el driver `msodbcsql18`)
2. Copie `config.ini.example` a `config.ini` y ponga sus datos de SQL Server.
3. Ejecute `sql/01_schema.sql` en SQL Server y luego `python tools/crear_admin.py`.
4. `python main.py` (usuario `admin`, clave `admin123`).

## Quién edita qué
| Responsable | Archivos |
|---|---|
| A | core/database.py, session.py, auth.py, ui/login.py, main_window.py, inventario.py, reportes.py, usuarios.py |
| B | core/validators.py, ui/clientes.py, ui/vehiculos.py |
| C | ui/ventas.py, ui/ordenes.py |
Regla: solo edite sus archivos. Si necesita un cambio en el de otro, pídaselo.
