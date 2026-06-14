<?php
require_once "conexion.php";

$id_factura = $_POST["id_factura"];
$numero = $_POST["numero_factura"];
$id_cliente = $_POST["id_cliente"] ?: "NULL";
$metodo = $_POST["metodo_pago"] ?? "";
$obs = $_POST["observaciones"] ?? "";
$subtotal = $_POST["subtotal"];
$impuesto = $_POST["impuesto"];
$total = $_POST["total"];

$conexion->begin_transaction();

try {
    // Actualizar factura
    $sql = "UPDATE factura SET
            numero_factura = '$numero',
            id_cliente = $id_cliente,
            subtotal = $subtotal,
            impuesto = $impuesto,
            total = $total,
            metodo_pago = '$metodo',
            observaciones = '$obs'
            WHERE id_factura = $id_factura";
    $conexion->query($sql);

    // Restaurar stock previo
    $res = $conexion->query("SELECT * FROM detalle_factura WHERE id_factura = $id_factura");
    while ($row = $res->fetch_assoc()) {
        $conexion->query("UPDATE stock SET cantidad_actual = cantidad_actual + {$row['cantidad']}
                      WHERE id_producto = {$row['id_producto']}");
    }

    // Borrar detalle previo
    $conexion->query("DELETE FROM detalle_factura WHERE id_factura = $id_factura");

    // Insertar nuevo detalle
    foreach ($_POST as $key => $value) {
        if (strpos($key, "items") === 0) {
            foreach ($value as $item) {
                $id_producto = $item["id_producto"];
                $cantidad = $item["cantidad"];
                $precio = $item["precio_unitario"];
                $sub = $cantidad * $precio;

                $sql2 = "INSERT INTO detalle_factura (id_factura, id_producto, cantidad, precio_unitario, subtotal)
                         VALUES ($id_factura, $id_producto, $cantidad, $precio, $sub)";
                $conexion->query($sql2);

                // Descontar stock
                $conexion->query("UPDATE stock SET cantidad_actual = cantidad_actual - $cantidad WHERE id_producto = $id_producto");
            }
        }
    }

    $conexion->commit();
    echo json_encode(["ok" => true]);

} catch (Exception $e) {
    $conexion->rollback();
    echo json_encode(["ok" => false, "error" => $e->getMessage()]);
}
