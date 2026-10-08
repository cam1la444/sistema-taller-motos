-- Esquema mínimo para el login. El resto de tablas se agrega en este mismo archivo (o en 02_...).
IF DB_ID('Taller') IS NULL CREATE DATABASE Taller;
GO
USE Taller;
GO
IF OBJECT_ID('Usuarios') IS NULL
CREATE TABLE Usuarios (
    id_usuario    INT IDENTITY PRIMARY KEY,
    usuario       VARCHAR(30)  NOT NULL UNIQUE,
    nombre        VARCHAR(100) NOT NULL,
    password_hash VARCHAR(100) NOT NULL,
    rol           VARCHAR(20)  NOT NULL CHECK (rol IN ('Administrador','Vendedor','Bodega')),
    activo        BIT NOT NULL DEFAULT 1
);
GO
IF OBJECT_ID('Configuracion') IS NULL
BEGIN
    CREATE TABLE Configuracion (clave VARCHAR(30) PRIMARY KEY, valor VARCHAR(50) NOT NULL);
    INSERT INTO Configuracion VALUES ('IVA', '0.13');
END
GO
