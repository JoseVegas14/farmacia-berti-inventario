<?php
require_once "conexion.php";

$numero = $_POST["numero_factura"];
$id_cliente = $_POST["id_cliente"] ?: "NULL";
$id_usuario = $_SESSION["id_usuario"] ?? 1; // fallback
$metodo = $_POST["metodo_pago"] ?? "";
$obs = $_POST["observaciones"] ?? "";
$subtotal = $_POST["subtotal"];
$impuesto = $_POST["impuesto"];
$total = $_POST["total"];

$conexion->begin_transaction();

try {
    // Insertar factura
    $sql = "INSERT INTO factura (numero_factura, id_cliente, id_usuario, fecha_emision, subtotal, impuesto, total, metodo_pago, observaciones)
            VALUES ('$numero', $id_cliente, $id_usuario, NOW(), $subtotal, $impuesto, $total, '$metodo', '$obs')";
    $conexion->query($sql);

    $id_factura = $conexion->insert_id;

    // Insertar detalle
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
