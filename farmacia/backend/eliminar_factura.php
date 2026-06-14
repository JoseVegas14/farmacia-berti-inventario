<?php
require_once "conexion.php";

$id = $_POST["id_factura"];

$conexion->begin_transaction();

try {
    // Restaurar stock
    $res = $conexion->query("SELECT * FROM detalle_factura WHERE id_factura = $id");
    while ($row = $res->fetch_assoc()) {
        $conexion->query("UPDATE stock SET cantidad_actual = cantidad_actual + {$row['cantidad']}
                      WHERE id_producto = {$row['id_producto']}");
    }

    // Borrar detalle
    $conexion->query("DELETE FROM detalle_factura WHERE id_factura = $id");

    // Borrar factura
    $conexion->query("DELETE FROM factura WHERE id_factura = $id");

    $conexion->commit();
    echo json_encode(["ok" => true]);

} catch (Exception $e) {
    $conexion->rollback();
    echo json_encode(["ok" => false, "error" => $e->getMessage()]);
}
