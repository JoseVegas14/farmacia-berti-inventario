<?php
require "conexion.php";
header("Content-Type: application/json");

$id_producto   = $_POST["id_producto"] ?? 0;
$nombre        = $_POST["prod-nombre"] ?? "";
$descripcion   = $_POST["prod-descripcion"] ?? "";
$id_categoria  = $_POST["prod-categoria"] ?? 0;
$id_proveedor  = $_POST["prod-proveedor"] ?? null;
$codigo_barra  = $_POST["prod-codigo"] ?? null;
$fecha_venc    = $_POST["prod-vencimiento"] ?? null;
$precio_venta  = $_POST["prod-precio"] ?? 0;
$cantidad      = $_POST["prod-cantidad"] ?? 0;

$stmt = $conexion->prepare(
    "UPDATE producto
     SET nombre = ?, descripcion = ?, id_categoria = ?, id_proveedor = ?, codigo_barra = ?, fecha_vencimiento = ?
     WHERE id_producto = ?"
);
$stmt->bind_param("ssiiisi", $nombre, $descripcion, $id_categoria, $id_proveedor, $codigo_barra, $fecha_venc, $id_producto);
$ok = $stmt->execute();

if (!$ok) {
    echo json_encode(["ok" => false, "error" => $stmt->error]);
    exit;
}

// stock
$stmtS = $conexion->prepare(
    "UPDATE stock SET cantidad_actual = ? WHERE id_producto = ?"
);
$stmtS->bind_param("ii", $cantidad, $id_producto);
$stmtS->execute();

// detalle_producto
$now = date("Y-m-d H:i:s");
$stmtD = $conexion->prepare(
    "UPDATE detalle_producto
     SET precio_venta = ?, fecha_actualizacion = ?
     WHERE id_producto = ?"
);
$stmtD->bind_param("dsi", $precio_venta, $now, $id_producto);
$stmtD->execute();

echo json_encode(["ok" => true]);
