CREATE DATABASE farmacia_berti;
USE farmacia_berti;


CREATE TABLE Peluches (
  id_peluche INT AUTO_INCREMENT PRIMARY KEY,
  codigo VARCHAR(50) UNIQUE NOT NULL,
  nombre VARCHAR(100) NOT NULL,
  descripcion TEXT,
  precio_unitario DECIMAL(10,2),
  stock_actual INT,
  stock_minimo INT,
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado VARCHAR(20) DEFAULT 'activo'
);

CREATE TABLE Proveedores (
  id_proveedor INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  telefono VARCHAR(20),
  email VARCHAR(100),
  direccion TEXT,
  contacto VARCHAR(100)
);

CREATE TABLE Usuarios (
  id_usuario INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  rol VARCHAR(50),
  usuario VARCHAR(50) UNIQUE NOT NULL,
  contrasena VARCHAR(255) NOT NULL,
  estado VARCHAR(20) DEFAULT 'activo'
);

CREATE TABLE Clientes (
  id_cliente INT AUTO_INCREMENT PRIMARY KEY,
  nombre VARCHAR(100) NOT NULL,
  telefono VARCHAR(20),
  email VARCHAR(100),
  direccion TEXT,
  fecha_registro DATETIME DEFAULT CURRENT_TIMESTAMP,
  estado VARCHAR(20) DEFAULT 'activo'
);

CREATE TABLE Entradas (
  id_entrada INT AUTO_INCREMENT PRIMARY KEY,
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  proveedor_id INT,
  usuario_id INT,
  total DECIMAL(10,2),
  FOREIGN KEY (proveedor_id) REFERENCES Proveedores(id_proveedor),
  FOREIGN KEY (usuario_id) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE Detalle_Entradas (
  id_detalle_entrada INT AUTO_INCREMENT PRIMARY KEY,
  entrada_id INT,
  peluche_id INT,
  cantidad INT,
  precio_unitario DECIMAL(10,2),
  subtotal DECIMAL(10,2),
  FOREIGN KEY (entrada_id) REFERENCES Entradas(id_entrada),
  FOREIGN KEY (peluche_id) REFERENCES Peluches(id_peluche)
);

CREATE TABLE Ventas (
  id_venta INT AUTO_INCREMENT PRIMARY KEY,
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  cliente_id INT,
  usuario_id INT,
  total DECIMAL(10,2),
  FOREIGN KEY (cliente_id) REFERENCES Clientes(id_cliente),
  FOREIGN KEY (usuario_id) REFERENCES Usuarios(id_usuario)
);

CREATE TABLE Detalle_Ventas (
  id_detalle_venta INT AUTO_INCREMENT PRIMARY KEY,
  venta_id INT,
  peluche_id INT,
  cantidad INT,
  precio_unitario DECIMAL(10,2),
  subtotal DECIMAL(10,2),
  FOREIGN KEY (venta_id) REFERENCES Ventas(id_venta),
  FOREIGN KEY (peluche_id) REFERENCES Peluches(id_peluche)
);


CREATE TABLE Inventario_Historico (
  id_inventario INT AUTO_INCREMENT PRIMARY KEY,
  peluche_id INT,
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  stock_inicial INT,
  entradas INT,
  salidas INT,
  stock_final INT,
  FOREIGN KEY (peluche_id) REFERENCES Peluches(id_peluche)
);

CREATE TABLE Auditoria (
  id_auditoria INT AUTO_INCREMENT PRIMARY KEY,
  usuario_id INT,
  accion VARCHAR(50),
  tabla_afectada VARCHAR(50),
  fecha DATETIME DEFAULT CURRENT_TIMESTAMP,
  detalle TEXT,
  FOREIGN KEY (usuario_id) REFERENCES Usuarios(id_usuario)
);

ALTER TABLE Peluches
ADD CONSTRAINT chk_stock_no_negativo CHECK (stock_actual >= 0);

ALTER TABLE Detalle_Entradas
ADD CONSTRAINT chk_cantidad_entrada CHECK (cantidad > 0);

ALTER TABLE Detalle_Ventas
ADD CONSTRAINT chk_cantidad_venta CHECK (cantidad > 0);

ALTER TABLE Peluches
ADD CONSTRAINT chk_precio_peluche CHECK (precio_unitario >= 0);

ALTER TABLE Detalle_Entradas
ADD CONSTRAINT chk_precio_entrada CHECK (precio_unitario >= 0);

ALTER TABLE Detalle_Ventas
ADD CONSTRAINT chk_precio_venta CHECK (precio_unitario >= 0);


DELIMITER //
CREATE TRIGGER actualizar_stock_entrada
AFTER INSERT ON Detalle_Entradas
FOR EACH ROW
BEGIN
  UPDATE Peluches
  SET stock_actual = stock_actual + NEW.cantidad
  WHERE id_peluche = NEW.peluche_id;

  INSERT INTO Inventario_Historico (peluche_id, stock_inicial, entradas, salidas, stock_final)
  VALUES (
    NEW.peluche_id,
    (SELECT stock_actual - NEW.cantidad FROM Peluches WHERE id_peluche = NEW.peluche_id),
    NEW.cantidad,
    0,
    (SELECT stock_actual FROM Peluches WHERE id_peluche = NEW.peluche_id)
  );
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER actualizar_stock_venta
AFTER INSERT ON Detalle_Ventas
FOR EACH ROW
BEGIN
  UPDATE Peluches
  SET stock_actual = stock_actual - NEW.cantidad
  WHERE id_peluche = NEW.peluche_id;

  INSERT INTO Inventario_Historico (peluche_id, stock_inicial, entradas, salidas, stock_final)
  VALUES (
    NEW.peluche_id,
    (SELECT stock_actual + NEW.cantidad FROM Peluches WHERE id_peluche = NEW.peluche_id),
    0,
    NEW.cantidad,
    (SELECT stock_actual FROM Peluches WHERE id_peluche = NEW.peluche_id)
  );
END;
//
DELIMITER ;


DELIMITER //
CREATE TRIGGER auditoria_entrada
AFTER INSERT ON Entradas
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria (usuario_id, accion, tabla_afectada, detalle)
  VALUES (
    NEW.usuario_id,
    'INSERT',
    'Entradas',
    CONCAT('Entrada registrada con ID ', NEW.id_entrada, ' por usuario ', NEW.usuario_id)
  );
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER auditoria_venta
AFTER INSERT ON Ventas
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria (usuario_id, accion, tabla_afectada, detalle)
  VALUES (
    NEW.usuario_id,
    'INSERT',
    'Ventas',
    CONCAT('Venta registrada con ID ', NEW.id_venta, ' por usuario ', NEW.usuario_id)
  );
END;
//
DELIMITER ;

DELIMITER //
CREATE TRIGGER auditoria_detalle_venta
AFTER INSERT ON Detalle_Ventas
FOR EACH ROW
BEGIN
  INSERT INTO Auditoria (usuario_id, accion, tabla_afectada, detalle)
  VALUES (
    (SELECT usuario_id FROM Ventas WHERE id_venta = NEW.venta_id),
    'INSERT',
    'Detalle_Ventas',
    CONCAT('Detalle de venta ID ', NEW.id_detalle_venta, 
           ' agregado a venta ', NEW.venta_id, 
           ' con peluche ', NEW.peluche_id, 
           ' cantidad ', NEW.cantidad)
  );
END;
//
DELIMITER ;

INSERT INTO Peluches (codigo, nombre, descripcion, precio_unitario, stock_actual, stock_minimo)
VALUES
('PEL001', 'Oso de felpa', 'Peluche marrón de 30 cm', 12.50, 50, 5),
('PEL002', 'Conejo de felpa', 'Conejo blanco con orejas largas', 20.00, 30, 5),
('PEL003', 'Perro de felpa', 'Peluche de perro gris', 18.00, 40, 5),
('PEL004', 'Gato de felpa', 'Peluche de gato negro', 15.00, 25, 5);

INSERT INTO Proveedores (nombre, telefono, email, direccion, contacto)
VALUES
('Distribuidora Juguetilandia', '0414-1234567', 'ventas@juguetilandia.com', 'Av. Principal, Caracas', 'María Pérez'),
('Peluches Global', '0412-7654321', 'info@peluchesglobal.com', 'Calle Comercio, Valencia', 'José Ramírez');

INSERT INTO Usuarios (nombre, rol, usuario, contrasena)
VALUES
('Carlos Gómez', 'administrador', 'cgomez', '12345segura'),
('Ana Torres', 'vendedor', 'atorres', 'claveSegura'),
('Luis Fernández', 'inventarista', 'lfernandez', 'inv2026'),
('María López', 'administrador', 'mlopez', 'admin2026');

INSERT INTO Clientes (nombre, telefono, email, direccion)
VALUES
('Juan Rodríguez', '0412-9876543', 'juanr@gmail.com', 'Calle 10, Maracaibo'),
('María Pérez', '0414-1234567', 'maria.p@gmail.com', 'Av. Libertador, Caracas');


INSERT INTO Entradas (proveedor_id, usuario_id, total)
VALUES
(1, 1, 250.00),
(2, 3, 180.00);

INSERT INTO Detalle_Entradas (entrada_id, peluche_id, cantidad, precio_unitario, subtotal)
VALUES
(1, 1, 10, 12.50, 125.00),
(1, 2, 5, 20.00, 100.00),
(2, 3, 3, 18.00, 54.00);

INSERT INTO Ventas (cliente_id, usuario_id, total)
VALUES
(1, 2, 40.00),
(2, 2, 60.00);

INSERT INTO Detalle_Ventas (venta_id, peluche_id, cantidad, precio_unitario, subtotal)
VALUES
(1, 1, 2, 12.50, 25.00),
(1, 4, 1, 15.00, 15.00),
(2, 2, 2, 20.00, 40.00);
