<?php
require "conexion.php";
require "middleware.php";
permitir(["administrador", "gerente"]);

if (!isset($_POST["id_producto"])) {
    echo json_encode(["ok" => false, "error" => "ID no proporcionado"]);
    exit;
}

$id = intval($_POST["id_producto"]);
$conexion->begin_transaction();

try {
    $tablas = ["detalle_factura", "detalle_compra", "movimiento", "stock", "detalle_producto"];
    foreach ($tablas as $tabla) {
        $stmt = $conexion->prepare("DELETE FROM $tabla WHERE id_producto = ?");
        $stmt->bind_param("i", $id);
        $stmt->execute();
        $stmt->close();
    }

    $stmt = $conexion->prepare("DELETE FROM producto WHERE id_producto = ?");
    $stmt->bind_param("i", $id);
    $stmt->execute();
    $stmt->close();

    $conexion->commit();
    echo json_encode(["ok" => true]);
} catch (Exception $e) {
    $conexion->rollback();
    echo json_encode(["ok" => false, "error" => $e->getMessage()]);
}
?>