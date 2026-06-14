<?php
require_once "conexion.php";

$id = $_GET["id_factura"] ?? 0;

$sql = "SELECT df.*, p.nombre AS producto_nombre
        FROM detalle_factura df
        INNER JOIN producto p ON df.id_producto = p.id_producto
        WHERE df.id_factura = $id";

$res = $conexion->query($sql);

$detalle = [];
while ($row = $res->fetch_assoc()) {
    $detalle[] = $row;
}

echo json_encode($detalle);
