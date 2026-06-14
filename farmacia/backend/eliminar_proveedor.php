<?php
require "conexion.php";
require "middleware.php";
permitir(["administrador"]);

$id = intval($_POST["id_proveedor"]);

$sql = "DELETE FROM proveedor WHERE id_proveedor=?";
$stmt = $conexion->prepare($sql);
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["ok" => true]);
} else {
    echo json_encode(["ok" => false, "error" => $stmt->error]);
}
?>