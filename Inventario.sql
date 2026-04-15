CREATE DATABASE cinco;
use cinco;

CREATE TABLE rol (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50),
    descripcion VARCHAR(150)
);

CREATE TABLE usuario (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    correo VARCHAR(120) UNIQUE,
    clave VARCHAR(255),
    id_rol INT,
    estado TINYINT DEFAULT 1,
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol)
);

CREATE TABLE direccion (
    id_direccion INT AUTO_INCREMENT PRIMARY KEY,
    calle VARCHAR(120),
    avenida VARCHAR(120),
    sector VARCHAR(120),
    numero_casa VARCHAR(20),
    status TINYINT,
    id_usuario INT,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE modulo (
    id_modulo INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    descripcion VARCHAR(150)
);

CREATE TABLE pagina (
    id_pagina INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    url VARCHAR(150),
    descripcion VARCHAR(150)
);

CREATE TABLE rol_pagina (
    id_rol_pagina INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT,
    id_pagina INT,
    id_modulo INT,
    FOREIGN KEY (id_rol) REFERENCES rol(id_rol),
    FOREIGN KEY (id_pagina) REFERENCES pagina(id_pagina),
    FOREIGN KEY (id_modulo) REFERENCES modulo(id_modulo)
);


CREATE TABLE permiso (
    id_permiso INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL
);

CREATE TABLE rol_pagina_per (
    id_rol_pagina_per INT AUTO_INCREMENT PRIMARY KEY,
    id_rol_pagina INT,
    id_permiso INT,
    FOREIGN KEY (id_rol_pagina)
        REFERENCES rol_pagina(id_rol_pagina),
    FOREIGN KEY (id_permiso)
        REFERENCES permiso(id_permiso)
);



CREATE TABLE categoria (
    id_categoria INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(100),
    descripcion VARCHAR(150)
);

CREATE TABLE producto (
    id_producto INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120),
    id_categoria INT,
    descripcion VARCHAR(200),
    precio DECIMAL(10,2),
    stock INT DEFAULT 0,
    estado TINYINT DEFAULT 1,
    FOREIGN KEY (id_categoria) REFERENCES categoria(id_categoria)
);

CREATE TABLE proveedor (
    id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120),
    telefono VARCHAR(20),
    direccion VARCHAR(150),
    correo VARCHAR(120)
);

CREATE TABLE compra (
    id_compra INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    id_proveedor INT,
    total DECIMAL(10,2),
    id_usuario INT,
    FOREIGN KEY (id_proveedor) REFERENCES proveedor(id_proveedor),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE detalle_compra (
    id_detalle INT AUTO_INCREMENT PRIMARY KEY,
    id_compra INT,
    id_producto INT,
    cantidad INT,
    precio DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    FOREIGN KEY (id_compra) REFERENCES compra(id_compra),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

CREATE TABLE movimiento (
    id_movimiento INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATE,
    tipo ENUM('entrada','salida'),
    descripcion VARCHAR(150),
    id_usuario INT,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);

CREATE TABLE detalle_movimiento (
    id_detalle_mov INT AUTO_INCREMENT PRIMARY KEY,
    id_movimiento INT,
    id_producto INT,
    cantidad_inicio INT,
    cantidad_ingreso INT,
    cantidad_salida INT,
    cantidad_final INT,
    FOREIGN KEY (id_movimiento) REFERENCES movimiento(id_movimiento),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);


CREATE TABLE cliente (
    id_cliente INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(120),
    cedula VARCHAR(20) UNIQUE,
    telefono VARCHAR(20),
    correo VARCHAR(120),
    direccion VARCHAR(200),
    estado TINYINT DEFAULT 1
);

ALTER TABLE producto
ADD codigo VARCHAR(50) UNIQUE AFTER id_producto;


CREATE TABLE stock (
    id_stock INT AUTO_INCREMENT PRIMARY KEY,
    id_producto INT,
    cantidad_actual INT DEFAULT 0,
    punto_reorden INT DEFAULT 0,
    maximo INT DEFAULT 0,
    minimo INT DEFAULT 0,
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);

CREATE TABLE factura (
    id_factura INT AUTO_INCREMENT PRIMARY KEY,
    fecha DATETIME,
    id_cliente INT,
    id_usuario INT,
    total DECIMAL(10,2),
    tipo VARCHAR(20),        -- contado, crédito, etc.
    estado VARCHAR(20),      -- pagada, pendiente, anulada
    FOREIGN KEY (id_cliente) REFERENCES cliente(id_cliente),
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);


CREATE TABLE detalle_factura (
    id_detalle_factura INT AUTO_INCREMENT PRIMARY KEY,
    id_factura INT,
    id_producto INT,
    cantidad INT,
    precio DECIMAL(10,2),
    subtotal DECIMAL(10,2),
    FOREIGN KEY (id_factura) REFERENCES factura(id_factura),
    FOREIGN KEY (id_producto) REFERENCES producto(id_producto)
);


CREATE TABLE forma_pago (
    id_forma_pago INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50)        -- efectivo, punto, transferencia, móvil, etc.
);


CREATE TABLE factura_pago (
    id_factura_pago INT AUTO_INCREMENT PRIMARY KEY,
    id_factura INT,
    id_forma_pago INT,
    monto DECIMAL(10,2),
    referencia VARCHAR(100),
    FOREIGN KEY (id_factura) REFERENCES factura(id_factura),
    FOREIGN KEY (id_forma_pago) REFERENCES forma_pago(id_forma_pago)
);


CREATE TABLE auditoria (
    id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
    tabla_afectada VARCHAR(100),
    accion VARCHAR(20),           -- INSERT, UPDATE, DELETE
    id_usuario INT,
    fecha DATETIME,
    descripcion TEXT,
    FOREIGN KEY (id_usuario) REFERENCES usuario(id_usuario)
);



INSERT INTO rol (nombre, descripcion) VALUES
('Director', 'Máxima autoridad, acceso total al sistema'),
('Gerente', 'Supervisa compras, ventas y reportes'),
('Contador', 'Control financiero y registros contables'),
('Farmacéutico', 'Control de inventario y medicamentos'),
('Vendedor', 'Procesa ventas y atiende clientes');

INSERT INTO usuario (nombre, correo, clave, id_rol, estado) VALUES
('Luis Berti', 'director@cinco.com', '1234', 1, 1),
('María González', 'gerente@cinco.com', '1234', 2, 1),
('José Ramírez', 'contador@cinco.com', '1234', 3, 1),
('Ana Torres', 'farmaceutico@cinco.com', '1234', 4, 1),
('Carlos Pérez', 'vendedor@cinco.com', '1234', 5, 1);

INSERT INTO direccion (calle, avenida, sector, numero_casa, status, id_usuario) VALUES
('Calle 1', 'Av 2', 'Centro', '12A', 1, 1),
('Calle 5', 'Av 10', 'La Lago', '45B', 1, 2),
('Calle 8', 'Av 15', 'Milagro', '23C', 1, 3),
('Calle 3', 'Av 4', 'Bella Vista', '9D', 1, 4),
('Calle 7', 'Av 20', 'Delicias', '17E', 1, 5);


INSERT INTO modulo (nombre, descripcion) VALUES
('Inventario', 'Gestión de productos y stock'),
('Ventas', 'Facturación y clientes'),
('Compras', 'Registro de compras y proveedores'),
('Seguridad', 'Control de roles y permisos');


INSERT INTO pagina (nombre, url, descripcion) VALUES
('Productos', '/productos', 'Gestión de productos'),
('Clientes', '/clientes', 'Gestión de clientes'),
('Facturación', '/facturas', 'Procesar ventas'),
('Proveedores', '/proveedores', 'Gestión de proveedores'),
('Usuarios', '/usuarios', 'Administración de usuarios');


-- Director: acceso total
INSERT INTO rol_pagina (id_rol, id_pagina, id_modulo) VALUES
(1, 1, 1), (1, 2, 2), (1, 3, 2), (1, 4, 3), (1, 5, 4);

-- Gerente: inventario, compras, ventas
INSERT INTO rol_pagina (id_rol, id_pagina, id_modulo) VALUES
(2, 1, 1), (2, 3, 2), (2, 4, 3);

-- Contador: clientes, facturas, proveedores
INSERT INTO rol_pagina (id_rol, id_pagina, id_modulo) VALUES
(3, 2, 2), (3, 3, 2), (3, 4, 3);

-- Farmacéutico: inventario
INSERT INTO rol_pagina (id_rol, id_pagina, id_modulo) VALUES
(4, 1, 1);

-- Vendedor: clientes y facturación
INSERT INTO rol_pagina (id_rol, id_pagina, id_modulo) VALUES
(5, 2, 2), (5, 3, 2);


INSERT INTO permiso (nombre) VALUES
('ver'),
('crear'),
('editar'),
('eliminar');


-- Director: todo
INSERT INTO rol_pagina_per (id_rol_pagina, id_permiso)
SELECT id_rol_pagina, id_permiso FROM rol_pagina, permiso WHERE id_rol = 1;

-- Gerente: ver, crear, editar
INSERT INTO rol_pagina_per (id_rol_pagina, id_permiso)
SELECT id_rol_pagina, id_permiso FROM rol_pagina, permiso 
WHERE id_rol = 2 AND id_permiso IN (1,2,3);

-- Contador: ver, crear
INSERT INTO rol_pagina_per (id_rol_pagina, id_permiso)
SELECT id_rol_pagina, id_permiso FROM rol_pagina, permiso 
WHERE id_rol = 3 AND id_permiso IN (1,2);

-- Farmacéutico: ver, editar
INSERT INTO rol_pagina_per (id_rol_pagina, id_permiso)
SELECT id_rol_pagina, id_permiso FROM rol_pagina, permiso 
WHERE id_rol = 4 AND id_permiso IN (1,3);

-- Vendedor: ver, crear
INSERT INTO rol_pagina_per (id_rol_pagina, id_permiso)
SELECT id_rol_pagina, id_permiso FROM rol_pagina, permiso 
WHERE id_rol = 5 AND id_permiso IN (1,2);

INSERT INTO categoria (nombre, descripcion) VALUES
('Medicinas', 'Productos farmacéuticos'),
('Cuidado Personal', 'Higiene y cuidado personal'),
('Peluches', 'Línea de peluches de la farmacia');

INSERT INTO producto (nombre, id_categoria, descripcion, precio, stock, estado, codigo) VALUES
('Acetaminofén 500mg', 1, 'Analgésico', 3.50, 50, 1, 'MED001'),
('Ibuprofeno 400mg', 1, 'Antiinflamatorio', 4.20, 40, 1, 'MED002'),
('Amoxicilina 500mg', 1, 'Antibiótico', 8.50, 30, 1, 'MED003'),
('Loratadina 10mg', 1, 'Antialérgico', 5.00, 25, 1, 'MED004'),
('Omeprazol 20mg', 1, 'Protector gástrico', 6.00, 35, 1, 'MED005'),
('Metformina 850mg', 1, 'Antidiabético', 7.20, 20, 1, 'MED006'),
('Losartán 50mg', 1, 'Antihipertensivo', 6.80, 28, 1, 'MED007'),
('Azitromicina 500mg', 1, 'Antibiótico', 9.50, 18, 1, 'MED008'),
('Diclofenac 50mg', 1, 'Antiinflamatorio', 4.00, 32, 1, 'MED009'),
('Salbutamol Inhalador', 1, 'Broncodilatador', 12.00, 15, 1, 'MED010');

INSERT INTO producto (nombre, id_categoria, descripcion, precio, stock, estado, codigo) VALUES
('Shampoo Herbal', 2, 'Cuidado del cabello', 6.80, 25, 1, 'CP001'),
('Acondicionador Suave', 2, 'Hidratación capilar', 7.20, 20, 1, 'CP002'),
('Jabón Líquido Antibacterial', 2, 'Higiene personal', 5.50, 30, 1, 'CP003'),
('Crema Corporal Hidratante', 2, 'Hidratación profunda', 8.00, 18, 1, 'CP004'),
('Desodorante Roll-On', 2, 'Protección diaria', 4.80, 40, 1, 'CP005'),
('Gel Antibacterial 250ml', 2, 'Desinfección de manos', 3.50, 50, 1, 'CP006'),
('Talco Corporal', 2, 'Uso diario', 4.00, 22, 1, 'CP007'),
('Crema Dental Menta', 2, 'Higiene bucal', 3.20, 35, 1, 'CP008'),
('Enjuague Bucal 500ml', 2, 'Antiséptico bucal', 6.50, 15, 1, 'CP009'),
('Protector Solar SPF50', 2, 'Protección UV', 10.00, 12, 1, 'CP010');

INSERT INTO producto (nombre, id_categoria, descripcion, precio, stock, estado, codigo) VALUES
('Peluche Oso Panda', 3, 'Peluche suave tamaño mediano', 15.00, 20, 1, 'PEL001'),
('Peluche Unicornio', 3, 'Peluche rosado con cuerno dorado', 18.00, 15, 1, 'PEL002'),
('Peluche Perrito', 3, 'Peluche de perro marrón pequeño', 12.00, 25, 1, 'PEL003'),
('Peluche Gato Blanco', 3, 'Peluche de gato blanco con lazo', 14.00, 18, 1, 'PEL004'),
('Peluche Elefante Azul', 3, 'Peluche infantil color azul', 16.00, 10, 1, 'PEL005'),
('Peluche León Bebé', 3, 'Peluche de león pequeño', 13.50, 22, 1, 'PEL006'),
('Peluche Dinosaurio Verde', 3, 'Peluche de dinosaurio suave', 17.00, 14, 1, 'PEL007'),
('Peluche Conejito Rosa', 3, 'Peluche con orejas largas', 11.50, 30, 1, 'PEL008'),
('Peluche Tortuga Marina', 3, 'Peluche ecológico', 16.50, 12, 1, 'PEL009'),
('Peluche Dragón Rojo', 3, 'Peluche temático de fantasía', 19.00, 8, 1, 'PEL010');


INSERT INTO stock (id_producto, cantidad_actual, punto_reorden, maximo, minimo) VALUES
(1, 50, 5, 200, 10),
(2, 40, 5, 200, 10),
(3, 30, 5, 200, 10),
(4, 25, 5, 200, 10),
(5, 35, 5, 200, 10),
(6, 20, 5, 200, 10),
(7, 28, 5, 200, 10),
(8, 18, 5, 200, 10),
(9, 32, 5, 200, 10),
(10, 15, 5, 200, 10),

(11, 25, 5, 200, 10),
(12, 20, 5, 200, 10),
(13, 30, 5, 200, 10),
(14, 18, 5, 200, 10),
(15, 40, 5, 200, 10),
(16, 50, 5, 200, 10),
(17, 22, 5, 200, 10),
(18, 35, 5, 200, 10),
(19, 15, 5, 200, 10),
(20, 12, 5, 200, 10),

(21, 20, 5, 200, 10),
(22, 15, 5, 200, 10),
(23, 25, 5, 200, 10),
(24, 18, 5, 200, 10),
(25, 10, 5, 200, 10),
(26, 22, 5, 200, 10),
(27, 14, 5, 200, 10),
(28, 30, 5, 200, 10),
(29, 12, 5, 200, 10),
(30, 8, 5, 200, 10);

DELIMITER $$

CREATE TRIGGER trg_compra_actualiza_stock
AFTER INSERT ON detalle_compra
FOR EACH ROW
BEGIN
    UPDATE stock
    SET cantidad_actual = cantidad_actual + NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER trg_venta_actualiza_stock
AFTER INSERT ON detalle_factura
FOR EACH ROW
BEGIN
    UPDATE stock
    SET cantidad_actual = cantidad_actual - NEW.cantidad
    WHERE id_producto = NEW.id_producto;
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER trg_validar_stock_venta
BEFORE INSERT ON detalle_factura
FOR EACH ROW
BEGIN
    DECLARE v_stock INT;

    SELECT cantidad_actual INTO v_stock
    FROM stock
    WHERE id_producto = NEW.id_producto;

    IF v_stock < NEW.cantidad THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: Stock insuficiente para realizar la venta.';
    END IF;
END $$

DELIMITER ;


DELIMITER $$

CREATE TRIGGER trg_crear_movimiento_entrada
AFTER INSERT ON detalle_compra
FOR EACH ROW
BEGIN
    DECLARE v_stock_inicio INT;
    DECLARE v_id_mov INT;

    SELECT cantidad_actual INTO v_stock_inicio
    FROM stock
    WHERE id_producto = NEW.id_producto;

    INSERT INTO movimiento (fecha, tipo, descripcion, id_usuario)
    VALUES (
        NOW(),
        'entrada',
        'Entrada automática por compra',
        (SELECT id_usuario FROM compra WHERE id_compra = NEW.id_compra)
    );

    SET v_id_mov = LAST_INSERT_ID();

    INSERT INTO detalle_movimiento (
        id_movimiento, id_producto, cantidad_inicio, cantidad_ingreso, cantidad_salida, cantidad_final
    ) VALUES (
        v_id_mov,
        NEW.id_producto,
        v_stock_inicio,
        NEW.cantidad,
        0,
        v_stock_inicio + NEW.cantidad
    );
END $$

DELIMITER ;
DELIMITER $$

DELIMITER $$

DELIMITER $$

CREATE TRIGGER trg_crear_movimiento_salida
AFTER INSERT ON detalle_factura
FOR EACH ROW
BEGIN
    DECLARE v_primera_entrada INT;
    DECLARE v_id_mov INT;

    -- Obtener la PRIMERA entrada histórica del producto
    SELECT cantidad_ingreso
    INTO v_primera_entrada
    FROM detalle_movimiento
    WHERE id_producto = NEW.id_producto
      AND cantidad_ingreso > 0
    ORDER BY id_detalle_mov ASC
    LIMIT 1;

    -- Si no existe entrada previa, error
    IF v_primera_entrada IS NULL THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Error: No existe entrada previa para este producto.';
    END IF;

    -- Crear movimiento de salida
    INSERT INTO movimiento (fecha, tipo, descripcion, id_usuario)
    VALUES (
        NOW(),
        'salida',
        'Salida automática por venta',
        (SELECT id_usuario FROM factura WHERE id_factura = NEW.id_factura)
    );

    SET v_id_mov = LAST_INSERT_ID();

    -- Insertar detalle del movimiento
    INSERT INTO detalle_movimiento (
        id_movimiento, id_producto, cantidad_inicio, cantidad_ingreso, cantidad_salida, cantidad_final
    ) VALUES (
        v_id_mov,
        NEW.id_producto,
        v_primera_entrada,
        0,
        NEW.cantidad,
        v_primera_entrada - NEW.cantidad
    );
END $$

DELIMITER ;

INSERT INTO proveedor (nombre, telefono, direccion, correo) VALUES
('Laboratorios Farma', '04141234567', 'Zona Industrial', 'contacto@farma.com'),
('Distribuidora SaludPlus', '04241239876', 'Av Libertador', 'ventas@saludplus.com'),
('Importadora PelucheManía', '04129998877', 'Calle 23, Galpón 4', 'ventas@peluchemania.com');


INSERT INTO compra (fecha, id_proveedor, total, id_usuario) VALUES
('2026-04-01', 1, 850.00, 2),
('2026-04-03', 2, 620.00, 2),
('2026-04-05', 3, 900.00, 2);
INSERT INTO detalle_compra (id_compra, id_producto, cantidad, precio, subtotal) VALUES
(1, 1, 80, 3.00, 240.00),
(1, 2, 60, 3.50, 210.00),
(1, 3, 40, 7.00, 280.00),
(1, 4, 50, 4.00, 200.00),
(1, 5, 40, 5.00, 200.00),
(1, 6, 30, 6.00, 180.00),
(1, 7, 30, 5.50, 165.00),
(1, 8, 25, 8.00, 200.00),
(1, 9, 50, 3.00, 150.00),
(1, 10, 20, 10.00, 200.00);
INSERT INTO detalle_compra (id_compra, id_producto, cantidad, precio, subtotal) VALUES
(2, 11, 40, 5.00, 200.00),
(2, 12, 35, 5.50, 192.50),
(2, 13, 50, 3.00, 150.00),
(2, 14, 30, 6.00, 180.00),
(2, 15, 60, 3.50, 210.00),
(2, 16, 70, 2.50, 175.00),
(2, 17, 40, 3.00, 120.00),
(2, 18, 50, 2.50, 125.00),
(2, 19, 25, 5.00, 125.00),
(2, 20, 20, 8.00, 160.00);


INSERT INTO detalle_compra (id_compra, id_producto, cantidad, precio, subtotal) VALUES
(3, 21, 20, 10.00, 200.00),
(3, 22, 15, 12.00, 180.00),
(3, 23, 25, 8.00, 200.00),
(3, 24, 18, 9.00, 162.00),
(3, 25, 10, 12.00, 120.00),
(3, 26, 22, 9.00, 198.00),
(3, 27, 14, 11.00, 154.00),
(3, 28, 30, 7.00, 210.00),
(3, 29, 12, 10.00, 120.00),
(3, 30, 8, 13.00, 104.00);


INSERT INTO cliente (nombre, cedula, telefono, correo, direccion, estado) VALUES
('Luis Martínez', 'V12345678', '04161234567', 'luis.martinez@gmail.com', 'Av 5, Calle 12', 1),
('Carolina Rivas', 'V87654321', '04261239876', 'carolina.rivas@gmail.com', 'Sector Norte, Casa 22', 1),
('Pedro Suárez', 'V11223344', '04145556677', 'pedro.suarez@gmail.com', 'Calle 9, Casa 8', 1),
('María Torres', 'V33445566', '04129998877', 'maria.torres@gmail.com', 'Av 3, Edif. Sol, Apt 4B', 1),
('José Fernández', 'V55667788', '04248887766', 'jose.fernandez@gmail.com', 'Sector Las Lomas, Casa 14', 1),
('Ana González', 'V99887766', '04147894512', 'ana.gonzalez@gmail.com', 'Calle 14, Casa 7', 1),
('Carlos Pérez', 'V44556677', '04261234512', 'carlos.perez@gmail.com', 'Av 10, Residencias El Lago, Apt 2A', 1),
('Daniela Romero', 'V22334455', '04161239876', 'daniela.romero@gmail.com', 'Sector San Miguel, Casa 3', 1),
('Ricardo Mendoza', 'V77889911', '04129997744', 'ricardo.mendoza@gmail.com', 'Calle 2, Casa 11', 1),
('Sofía Navarro', 'V88990011', '04245556677', 'sofia.navarro@gmail.com', 'Urbanización Los Olivos, Casa 18', 1);


INSERT INTO factura (fecha, id_cliente, id_usuario, total, tipo, estado) VALUES
('2026-04-10 14:30:00', 1, 5, 25.00, 'contado', 'pagada'),
('2026-04-11 10:15:00', 2, 5, 32.00, 'contado', 'pagada'),
('2026-04-12 16:45:00', 3, 5, 45.00, 'contado', 'pagada'),
('2026-04-13 11:20:00', 4, 5, 18.00, 'contado', 'pagada'),
('2026-04-13 15:50:00', 5, 5, 22.00, 'contado', 'pagada'),
('2026-04-14 09:10:00', 6, 5, 40.00, 'contado', 'pagada'),
('2026-04-14 13:25:00', 7, 5, 55.00, 'contado', 'pagada'),
('2026-04-15 10:00:00', 8, 5, 16.00, 'contado', 'pagada'),
('2026-04-15 14:40:00', 9, 5, 28.00, 'contado', 'pagada'),
('2026-04-16 12:30:00', 10, 5, 60.00, 'contado', 'pagada');


INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio, subtotal) VALUES
(1, 1, 5, 3.50, 17.50),
(1, 13, 1, 3.00, 3.00),
(1, 23, 1, 8.00, 8.00);
INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio, subtotal) VALUES
(2, 5, 2, 5.00, 10.00),
(2, 18, 2, 2.50, 5.00),
(2, 21, 1, 10.00, 10.00);
INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio, subtotal) VALUES
(3, 22, 1, 12.00, 12.00),
(3, 24, 2, 9.00, 18.00),
(3, 10, 1, 10.00, 10.00);
INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio, subtotal) VALUES
(4, 9, 2, 3.00, 6.00),
(4, 12, 1, 5.50, 5.50),
(4, 28, 1, 7.00, 7.00);
INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio, subtotal) VALUES
(5, 4, 1, 4.00, 4.00),
(5, 17, 2, 3.00, 6.00),
(5, 23, 1, 8.00, 8.00);
INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio, subtotal) VALUES
(6, 3, 2, 7.00, 14.00),
(6, 15, 3, 3.50, 10.50),
(6, 27, 1, 11.00, 11.00);
INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio, subtotal) VALUES
(7, 8, 2, 8.00, 16.00),
(7, 20, 2, 8.00, 16.00),
(7, 30, 2, 13.00, 26.00);
INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio, subtotal) VALUES
(8, 2, 2, 4.20, 8.40),
(8, 18, 1, 2.50, 2.50),
(8, 21, 1, 10.00, 10.00);
INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio, subtotal) VALUES
(9, 6, 2, 6.00, 12.00),
(9, 14, 1, 6.00, 6.00),
(9, 28, 1, 7.00, 7.00);
INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio, subtotal) VALUES
(10, 22, 2, 12.00, 24.00),
(10, 25, 2, 12.00, 24.00),
(10, 11, 2, 6.00, 12.00);

INSERT INTO forma_pago (nombre) VALUES
('Efectivo'),
('Punto'),
('Transferencia'),
('Pago Móvil');


INSERT INTO factura_pago (id_factura, id_forma_pago, monto, referencia) VALUES
(1, 1, 25.00, 'EF-001'),   -- Efectivo
(2, 3, 32.00, 'TR-002'),   -- Transferencia
(3, 1, 45.00, 'EF-003'),   -- Efectivo
(4, 2, 18.00, 'PT-004'),   -- Punto
(5, 1, 22.00, 'EF-005'),   -- Efectivo
(6, 3, 40.00, 'TR-006'),   -- Transferencia
(7, 1, 55.00, 'EF-007'),   -- Efectivo
(8, 4, 16.00, 'PM-008'),   -- Pago Móvil
(9, 2, 28.00, 'PT-009'),   -- Punto
(10, 1, 60.00, 'EF-010');  -- Efectivo

DELIMITER $$

CREATE TRIGGER aud_producto_insert
AFTER INSERT ON producto
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES (
        'producto',
        'INSERT',
        (SELECT id_usuario FROM usuario LIMIT 1),
        NOW(),
        CONCAT('Se creó el producto: ', NEW.nombre)
    );
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER aud_producto_update
AFTER UPDATE ON producto
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES (
        'producto',
        'UPDATE',
        (SELECT id_usuario FROM usuario LIMIT 1),
        NOW(),
        CONCAT('Se actualizó el producto: ', NEW.nombre)
    );
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER aud_producto_delete
AFTER DELETE ON producto
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES (
        'producto',
        'DELETE',
        (SELECT id_usuario FROM usuario LIMIT 1),
        NOW(),
        CONCAT('Se eliminó el producto: ', OLD.nombre)
    );
END $$

DELIMITER ;

DELIMITER $$

CREATE TRIGGER aud_categoria_insert
AFTER INSERT ON categoria
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES ('categoria','INSERT',(SELECT id_usuario FROM usuario LIMIT 1),NOW(),
    CONCAT('Nueva categoría: ', NEW.nombre));
END $$

DELIMITER ;



DELIMITER $$

CREATE TRIGGER aud_proveedor_insert
AFTER INSERT ON proveedor
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES ('proveedor','INSERT',(SELECT id_usuario FROM usuario LIMIT 1),NOW(),
    CONCAT('Nuevo proveedor: ', NEW.nombre));
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER aud_compra_insert
AFTER INSERT ON compra
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES ('compra','INSERT',NEW.id_usuario,NOW(),
    CONCAT('Compra registrada ID: ', NEW.id_compra));
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER aud_detalle_compra_insert
AFTER INSERT ON detalle_compra
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES ('detalle_compra','INSERT',
    (SELECT id_usuario FROM compra WHERE id_compra = NEW.id_compra),
    NOW(),
    CONCAT('Detalle compra: producto ', NEW.id_producto, ' cantidad ', NEW.cantidad));
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER aud_cliente_insert
AFTER INSERT ON cliente
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES ('cliente','INSERT',(SELECT id_usuario FROM usuario LIMIT 1),NOW(),
    CONCAT('Nuevo cliente: ', NEW.nombre));
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER aud_factura_insert
AFTER INSERT ON factura
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES ('factura','INSERT',NEW.id_usuario,NOW(),
    CONCAT('Factura creada ID: ', NEW.id_factura));
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER aud_detalle_factura_insert
AFTER INSERT ON detalle_factura
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES ('detalle_factura','INSERT',
    (SELECT id_usuario FROM factura WHERE id_factura = NEW.id_factura),
    NOW(),
    CONCAT('Venta producto ', NEW.id_producto, ' cantidad ', NEW.cantidad));
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER aud_usuario_insert
AFTER INSERT ON usuario
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES ('usuario','INSERT',1,NOW(),
    CONCAT('Nuevo usuario: ', NEW.nombre));
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER aud_stock_update
AFTER UPDATE ON stock
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES ('stock','UPDATE',(SELECT id_usuario FROM usuario LIMIT 1),NOW(),
    CONCAT('Stock actualizado producto ', NEW.id_producto,
           ' de ', OLD.cantidad_actual, ' a ', NEW.cantidad_actual));
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER aud_movimiento_insert
AFTER INSERT ON movimiento
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES ('movimiento','INSERT',NEW.id_usuario,NOW(),
    CONCAT('Movimiento ', NEW.tipo, ' registrado ID: ', NEW.id_movimiento));
END $$

DELIMITER ;
DELIMITER $$

CREATE TRIGGER aud_detalle_movimiento_insert
AFTER INSERT ON detalle_movimiento
FOR EACH ROW
BEGIN
    INSERT INTO auditoria (tabla_afectada, accion, id_usuario, fecha, descripcion)
    VALUES ('detalle_movimiento','INSERT',
    (SELECT id_usuario FROM movimiento WHERE id_movimiento = NEW.id_movimiento),
    NOW(),
    CONCAT('Kardex producto ', NEW.id_producto,
           ' inicio ', NEW.cantidad_inicio,
           ' ingreso ', NEW.cantidad_ingreso,
           ' salida ', NEW.cantidad_salida,
           ' final ', NEW.cantidad_final));
END $$

DELIMITER ;
