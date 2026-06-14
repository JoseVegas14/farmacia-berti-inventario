<?php
require "conexion.php";
require "middleware.php";
permitir(["administrador", "gerente"]);

header("Content-Type: application/json");

$id        = $_POST["id_proveedor"] ?? null;
$nombre    = $_POST["nombre"] ?? null;
$telefono  = $_POST["telefono"] ?? null;
$correo    = $_POST["correo"] ?? null;
$direccion = $_POST["direccion"] ?? null;

if (!$id || !$nombre || !$telefono || !$correo) {
    echo json_encode([
        "ok" => false,
        "error" => "Faltan datos obligatorios"
    ]);
    exit;
}

$sql = "UPDATE proveedor SET nombre=?, telefono=?, correo=?, direccion=? WHERE id_proveedor=?";
$stmt = $conexion->prepare($sql);
$stmt->bind_param("ssssi", $nombre, $telefono, $correo, $direccion, $id);

if ($stmt->execute()) {
    echo json_encode(["ok" => true]);
} else {
    echo json_encode(["ok" => false, "error" => $stmt->error]);
}
?>
