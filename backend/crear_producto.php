<?php
require "conexion.php";
header("Content-Type: application/json");

$nombre        = $_POST["prod-nombre"] ?? "";
$descripcion   = $_POST["prod-descripcion"] ?? "";
$id_categoria  = $_POST["prod-categoria"] ?? 0;
$id_proveedor  = $_POST["prod-proveedor"] ?? null;
$codigo_barra  = $_POST["prod-codigo"] ?? null;
$fecha_venc    = $_POST["prod-vencimiento"] ?? null;
$precio_venta  = $_POST["prod-precio"] ?? 0;
$cantidad      = $_POST["prod-cantidad"] ?? 0;

// 1. Insertar producto
$stmt = $conexion->prepare(
    "INSERT INTO producto (nombre, descripcion, id_categoria, id_proveedor, codigo_barra, fecha_vencimiento, estado)
     VALUES (?,?,?,?,?,?,1)"
);
$stmt->bind_param("ssiiis", $nombre, $descripcion, $id_categoria, $id_proveedor, $codigo_barra, $fecha_venc);
$okProd = $stmt->execute();

if (!$okProd) {
    echo json_encode(["ok" => false, "error" => $stmt->error]);
    exit;
}

$id_producto = $conexion->insert_id;

// 2. Stock
$stmtS = $conexion->prepare(
    "INSERT INTO stock (id_producto, cantidad_actual, cantidad_minima, cantidad_maxima)
     VALUES (?,?,0,0)"
);
$stmtS->bind_param("ii", $id_producto, $cantidad);
$stmtS->execute();

// 3. Detalle producto (solo precio_venta, IVA genérico 0)
$now = date("Y-m-d H:i:s");
$stmtD = $conexion->prepare(
    "INSERT INTO detalle_producto (id_producto, precio_compra, precio_venta, utilidad, iva, id_impuesto, fecha_actualizacion)
     VALUES (?,?,?,?,?,?,?)"
);
$precio_compra = 0;
$utilidad      = 0;
$iva           = 0;
$id_impuesto   = 1; // puedes crear un IVA por defecto en tabla impuesto

$stmtD->bind_param(
    "iddddis",
    $id_producto,
    $precio_compra,
    $precio_venta,
    $utilidad,
    $iva,
    $id_impuesto,
    $now
);
$stmtD->execute();

echo json_encode(["ok" => true]);
