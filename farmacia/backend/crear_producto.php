<?php
require "conexion.php";
require "middleware.php";
permitir(["administrador", "gerente"]);

header("Content-Type: application/json");

// DATOS DEL PRODUCTO
$nombre     = $_POST["nombre"] ?? null;
$descripcion = $_POST["descripcion"] ?? null;
$id_categoria = $_POST["id_categoria"] ?? null;
$id_proveedor = $_POST["id_proveedor"] ?? null;
$codigo     = $_POST["codigo_barra"] ?? null;
$vencimiento = $_POST["fecha_vencimiento"] ?? null;

// DATOS DEL DETALLE
$precio_compra = $_POST["precio_compra"] ?? null;
$precio_venta  = $_POST["precio_venta"] ?? null;
$utilidad      = $_POST["utilidad"] ?? null;
$iva           = $_POST["iva"] ?? null;
$id_impuesto   = $_POST["id_impuesto"] ?? null;

if (!$nombre || !$id_categoria || !$precio_venta || !$precio_compra) {
    echo json_encode(["ok" => false, "error" => "Faltan datos obligatorios"]);
    exit;
}

// 1️⃣ INSERTAR PRODUCTO
$sql1 = "INSERT INTO producto 
(nombre, descripcion, id_categoria, id_proveedor, codigo_barra, fecha_vencimiento, estado)
VALUES (?, ?, ?, ?, ?, ?, 1)";

$stmt1 = $conexion->prepare($sql1);
$stmt1->bind_param("ssisss", $nombre, $descripcion, $id_categoria, $id_proveedor, $codigo, $vencimiento);

if (!$stmt1->execute()) {
    echo json_encode(["ok" => false, "error" => $stmt1->error]);
    exit;
}

$id_producto = $stmt1->insert_id;

// 2️⃣ INSERTAR DETALLE DEL PRODUCTO
$sql2 = "INSERT INTO detalle_producto
(id_producto, precio_compra, precio_venta, utilidad, iva, id_impuesto, fecha_actualizacion)
VALUES (?, ?, ?, ?, ?, ?, NOW())";

$stmt2 = $conexion->prepare($sql2);
$stmt2->bind_param("iddddi", $id_producto, $precio_compra, $precio_venta, $utilidad, $iva, $id_impuesto);

if ($stmt2->execute()) {
    echo json_encode(["ok" => true]);
} else {
    echo json_encode(["ok" => false, "error" => $stmt2->error]);
}
?>
