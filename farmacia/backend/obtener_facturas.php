<?php
session_start();
require_once __DIR__ . "/conexion.php";

header("Content-Type: application/json; charset=utf-8");

$sql = "SELECT f.*, c.nombre AS cliente_nombre
        FROM factura f
        LEFT JOIN cliente c ON f.id_cliente = c.id_cliente
        ORDER BY f.id_factura DESC";

$res = $conexion->query($sql);

$facturas = [];
while ($row = $res->fetch_assoc()) {
    $facturas[] = $row;
}

echo json_encode($facturas);
