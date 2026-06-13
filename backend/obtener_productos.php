<?php
require "conexion.php";

$sql = "SELECT 
            p.id_producto,
            p.nombre,
            p.descripcion,
            p.id_categoria,
            c.nombre AS categoria,
            p.id_proveedor,
            pr.nombre AS proveedor,
            p.codigo_barra,
            p.fecha_vencimiento,
            p.estado,
            s.cantidad_actual,
            s.cantidad_minima,
            s.cantidad_maxima,
            d.precio_venta
        FROM producto p
        LEFT JOIN categoria c ON p.id_categoria = c.id_categoria
        LEFT JOIN proveedor pr ON p.id_proveedor = pr.id_proveedor
        LEFT JOIN stock s ON p.id_producto = s.id_producto
        LEFT JOIN detalle_producto d ON p.id_producto = d.id_producto";

$res = $conexion->query($sql);
$data = [];

while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

header("Content-Type: application/json");
echo json_encode($data);
