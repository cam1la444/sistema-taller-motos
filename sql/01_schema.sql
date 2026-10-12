-- ============================================================================
-- PROYECTO: SISTEMA DE GESTIÓN DE TALLER DE AUTOS Y MOTOS
-- ARCHIVO: sql/01_schema.sql
-- DESCRIPCIÓN: Estructura de base de datos adaptada a la división de trabajo
-- ============================================================================

IF NOT EXISTS (SELECT * FROM sys.databases WHERE name = 'Taller')
BEGIN
    CREATE DATABASE Taller;
END;
GO

USE Taller;
GO

-- ----------------------------------------------------------------------------
-- 1. TABLA DE CONFIGURACIÓN
-- Requerido por C para obtener el porcentaje de IVA dinámicamente
-- ----------------------------------------------------------------------------
IF OBJECT_ID('Configuracion', 'U') IS NOT NULL DROP TABLE Configuracion;
CREATE TABLE Configuracion (
    Clave VARCHAR(50) PRIMARY KEY,
    Valor VARCHAR(255) NOT NULL,
    Descripcion VARCHAR(255) NULL
);
GO

-- Inserción de valores iniciales (IVA del 13%)
INSERT INTO Configuracion (Clave, Valor, Descripcion) VALUES 
('IVA', '0.13', 'Porcentaje de impuesto sobre el valor agregado'),
('NombreEmpresa', 'Taller de Autos y Motos', 'Nombre comercial de la empresa');
GO

-- ----------------------------------------------------------------------------
-- 2. TABLA DE USUARIOS Y ROLES
-- Requerido por A para Login, Control de Acceso y Gestión de Usuarios
-- ----------------------------------------------------------------------------
IF OBJECT_ID('Usuarios', 'U') IS NOT NULL DROP TABLE Usuarios;
CREATE TABLE Usuarios (
    UsuarioID INT IDENTITY(1,1) PRIMARY KEY,
    NombreCompleto VARCHAR(100) NOT NULL,
    NombreUsuario VARCHAR(50) UNIQUE NOT NULL,
    PasswordHash VARCHAR(255) NOT NULL,
    Rol VARCHAR(20) NOT NULL CHECK (Rol IN ('Administrador', 'Vendedor', 'Mecanico', 'Bodega')),
    Activo BIT DEFAULT 1 NOT NULL,
    FechaCreacion DATETIME DEFAULT GETDATE()
);
GO

-- ----------------------------------------------------------------------------
-- 3. TABLA DE CLIENTES
-- Requerido por B para Vistas, Busqueda y Formularios de Clientes
-- ----------------------------------------------------------------------------
IF OBJECT_ID('Clientes', 'U') IS NOT NULL DROP TABLE Clientes;
CREATE TABLE Clientes (
    ClienteID INT IDENTITY(1,1) PRIMARY KEY,
    Codigo VARCHAR(20) UNIQUE NOT NULL, -- Ej: CLI-001
    TipoPersona VARCHAR(10) CHECK (TipoPersona IN ('Persona', 'Empresa')) DEFAULT 'Persona',
    Nombre VARCHAR(100) NOT NULL,
    DUI VARCHAR(10) UNIQUE NULL,       -- Con máscara 00000000-0
    NIT VARCHAR(20) NULL,
    Telefono VARCHAR(15) NULL,         -- Con máscara 0000-0000
    Correo VARCHAR(100) NULL,
    Departamento VARCHAR(50) NULL,
    Municipio VARCHAR(50) NULL,
    Direccion VARCHAR(250) NULL,
    Activo BIT DEFAULT 1 NOT NULL,
    FechaRegistro DATETIME DEFAULT GETDATE()
);
GO

-- ----------------------------------------------------------------------------
-- 4. TABLA DE VEHÍCULOS
-- Requerido por B para Vistas y Formularios (Autos y Motos)
-- ----------------------------------------------------------------------------
IF OBJECT_ID('Vehiculos', 'U') IS NOT NULL DROP TABLE Vehiculos;
CREATE TABLE Vehiculos (
    VehiculoID INT IDENTITY(1,1) PRIMARY KEY,
    ClienteID INT NOT NULL FOREIGN KEY REFERENCES Clientes(ClienteID),
    Placa VARCHAR(20) UNIQUE NOT NULL, -- Ej: P123-456 o M778-901
    TipoVehiculo VARCHAR(10) CHECK (TipoVehiculo IN ('Auto', 'Moto')) NOT NULL,
    Marca VARCHAR(50) NOT NULL,
    Modelo VARCHAR(50) NOT NULL,
    Anio INT NOT NULL CHECK (Anio >= 1900),
    Color VARCHAR(30) NULL,
    Kilometraje INT CHECK (Kilometraje >= 0) DEFAULT 0,
    -- Campos específicos por tipo de vehículo
    Puertas INT NULL,                  -- Solo para Auto (ej: 2, 4)
    Transmision VARCHAR(10) NULL,      -- Solo para Auto ('Man', 'Auto')
    Cilindraje VARCHAR(20) NULL,       -- Solo para Moto (ej: '125 cc')
    Activo BIT DEFAULT 1 NOT NULL
);
GO

-- ----------------------------------------------------------------------------
-- 5. TABLAS DE INVENTARIO (INSUMOS) Y SERVICIOS
-- Requerido por A para Gestión de Inventario y C para la selección en Ventas
-- ----------------------------------------------------------------------------
IF OBJECT_ID('Insumos', 'U') IS NOT NULL DROP TABLE Insumos;
CREATE TABLE Insumos (
    InsumoID INT IDENTITY(1,1) PRIMARY KEY,
    Codigo VARCHAR(20) UNIQUE NOT NULL, -- Ej: I-012
    Nombre VARCHAR(100) NOT NULL,
    Marca VARCHAR(50) NULL,
    Costo DECIMAL(10,2) CHECK (Costo >= 0) DEFAULT 0.00,
    PrecioVenta DECIMAL(10,2) CHECK (PrecioVenta >= 0) DEFAULT 0.00,
    Stock INT CHECK (Stock >= 0) DEFAULT 0,
    StockMinimo INT CHECK (StockMinimo >= 0) DEFAULT 5,
    Proveedor VARCHAR(100) NULL,
    Activo BIT DEFAULT 1 NOT NULL
);
GO

IF OBJECT_ID('Servicios', 'U') IS NOT NULL DROP TABLE Servicios;
CREATE TABLE Servicios (
    ServicioID INT IDENTITY(1,1) PRIMARY KEY,
    Codigo VARCHAR(20) UNIQUE NOT NULL, -- Ej: S-003
    Nombre VARCHAR(100) NOT NULL,
    Precio DECIMAL(10,2) CHECK (Precio >= 0) DEFAULT 0.00,
    Activo BIT DEFAULT 1 NOT NULL
);
GO

-- Movimientos para la opción "+ Entrada stock"
IF OBJECT_ID('EntradasStock', 'U') IS NOT NULL DROP TABLE EntradasStock;
CREATE TABLE EntradasStock (
    EntradaID INT IDENTITY(1,1) PRIMARY KEY,
    InsumoID INT NOT NULL FOREIGN KEY REFERENCES Insumos(InsumoID),
    Cantidad INT CHECK (Cantidad > 0) NOT NULL,
    CostoUnitario DECIMAL(10,2) CHECK (CostoUnitario >= 0) NOT NULL,
    Proveedor VARCHAR(100) NULL,
    Fecha DATETIME DEFAULT GETDATE(),
    UsuarioID INT NULL FOREIGN KEY REFERENCES Usuarios(UsuarioID)
);
GO

-- ----------------------------------------------------------------------------
-- 6. TABLA DE REGLAS DE DESCUENTO
-- Requerido por A y B para aplicar descuentos por cantidad o marca
-- ----------------------------------------------------------------------------
IF OBJECT_ID('ReglasDescuento', 'U') IS NOT NULL DROP TABLE ReglasDescuento;
CREATE TABLE ReglasDescuento (
    ReglaID INT IDENTITY(1,1) PRIMARY KEY,
    NombreRegla VARCHAR(100) NOT NULL,
    TipoAplicacion VARCHAR(20) CHECK (TipoAplicacion IN ('Cantidad', 'Marca', 'MontoTotal')) NOT NULL,
    ValorCriterio VARCHAR(50) NULL, -- Ej: 'Mobil', '5', '100'
    PorcentajeDescuento DECIMAL(5,2) CHECK (PorcentajeDescuento >= 0 AND PorcentajeDescuento <= 100) NOT NULL,
    Activa BIT DEFAULT 1 NOT NULL
);
GO

-- ----------------------------------------------------------------------------
-- 7. TABLAS DE FACTURACIÓN Y VENTAS
-- Requerido por C para el Punto de Venta, Múltiples Ventas y Facturas PDF
-- ----------------------------------------------------------------------------
IF OBJECT_ID('DetalleFactura', 'U') IS NOT NULL DROP TABLE DetalleFactura;
IF OBJECT_ID('Facturas', 'U') IS NOT NULL DROP TABLE Facturas;

CREATE TABLE Facturas (
    FacturaID INT IDENTITY(1,1) PRIMARY KEY,
    NumeroFactura VARCHAR(20) UNIQUE NOT NULL, -- Ej: FACTURA #0046
    ClienteID INT NOT NULL FOREIGN KEY REFERENCES Clientes(ClienteID),
    VehiculoID INT NULL FOREIGN KEY REFERENCES Vehiculos(VehiculoID),
    UsuarioID INT NOT NULL FOREIGN KEY REFERENCES Usuarios(UsuarioID),
    Fecha DATETIME DEFAULT GETDATE(),
    Subtotal DECIMAL(10,2) CHECK (Subtotal >= 0) DEFAULT 0.00,
    PorcentajeDescuento DECIMAL(5,2) DEFAULT 0.00,
    MontoDescuento DECIMAL(10,2) CHECK (MontoDescuento >= 0) DEFAULT 0.00,
    MontoIVA DECIMAL(10,2) CHECK (MontoIVA >= 0) DEFAULT 0.00,
    Total DECIMAL(10,2) CHECK (Total >= 0) DEFAULT 0.00,
    Estado VARCHAR(20) DEFAULT 'Completada' CHECK (Estado IN ('Completada', 'Anulada'))
);
GO

CREATE TABLE DetalleFactura (
    DetalleID INT IDENTITY(1,1) PRIMARY KEY,
    FacturaID INT NOT NULL FOREIGN KEY REFERENCES Facturas(FacturaID) ON DELETE CASCADE,
    TipoItem VARCHAR(10) CHECK (TipoItem IN ('Insumo', 'Servicio')) NOT NULL,
    InsumoID INT NULL FOREIGN KEY REFERENCES Insumos(InsumoID),
    ServicioID INT NULL FOREIGN KEY REFERENCES Servicios(ServicioID),
    Cantidad INT CHECK (Cantidad > 0) NOT NULL,
    PrecioUnitario DECIMAL(10,2) CHECK (PrecioUnitario >= 0) NOT NULL,
    SubtotalLinea AS (Cantidad * PrecioUnitario)
);
GO

-- ----------------------------------------------------------------------------
-- 8. VISTAS Y AUTOMATIZACIÓN (TRIGGERS Y PROCEDIMIENTOS)
-- ----------------------------------------------------------------------------

-- Vista para semáforo y alertas de Stock Bajo
IF OBJECT_ID('vw_StockBajo', 'V') IS NOT NULL DROP VIEW vw_StockBajo;
GO
CREATE VIEW vw_StockBajo AS
SELECT 
    InsumoID,
    Codigo,
    Nombre,
    Marca,
    Stock,
    StockMinimo,
    PrecioVenta,
    CASE 
        WHEN Stock = 0 THEN 'Agotado'
        WHEN Stock <= StockMinimo THEN 'Bajo'
        ELSE 'Normal'
    END AS EstadoStock
FROM Insumos
WHERE Stock <= StockMinimo AND Activo = 1;
GO

-- Trigger: Descuenta stock automáticamente al vender insumos
IF OBJECT_ID('trg_RestarStockVenta', 'TR') IS NOT NULL DROP TRIGGER trg_RestarStockVenta;
GO
CREATE TRIGGER trg_RestarStockVenta
ON DetalleFactura
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE I
    SET I.Stock = I.Stock - o.Cantidad
    FROM Insumos I
    INNER JOIN inserted o ON I.InsumoID = o.InsumoID
    WHERE o.TipoItem = 'Insumo';
END;
GO

-- Trigger: Incrementa stock automáticamente al registrar entrada
IF OBJECT_ID('trg_SumarStockEntrada', 'TR') IS NOT NULL DROP TRIGGER trg_SumarStockEntrada;
GO
CREATE TRIGGER trg_SumarStockEntrada
ON EntradasStock
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;

    UPDATE I
    SET I.Stock = I.Stock + o.Cantidad,
        I.Costo = o.CostoUnitario
    FROM Insumos I
    INNER JOIN inserted o ON I.InsumoID = o.InsumoID;
END;
GO

-- Procedimiento Almacenado: Reporte de Ventas del Día
IF OBJECT_ID('sp_ReporteVentasDia', 'P') IS NOT NULL DROP PROCEDURE sp_ReporteVentasDia;
GO
CREATE PROCEDURE sp_ReporteVentasDia
    @FechaConsulta DATE
AS
BEGIN
    SET NOCOUNT ON;

    SELECT 
        COUNT(FacturaID) AS CantidadTransacciones,
        ISNULL(SUM(Total), 0) AS TotalVendido,
        ISNULL(AVG(Total), 0) AS PromedioVenta,
        ISNULL(MAX(Total), 0) AS VentaMayor
    FROM Facturas
    WHERE CAST(Fecha AS DATE) = @FechaConsulta AND Estado = 'Completada';
END;
GO