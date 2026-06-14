<?php
require "conexion.php";
require "middleware.php";
permitir(["administrador", "gerente"]);

$nombre = $_POST["nombre"];
$telefono = $_POST["telefono"];
$correo = $_POST["correo"];
$direccion = $_POST["direccion"] ?? null;

$sql = "INSERT INTO proveedor (nombre, telefono, correo, direccion) VALUES (?, ?, ?, ?)";
$stmt = $conexion->prepare($sql);
$stmt->bind_param("ssss", $nombre, $telefono, $correo, $direccion);

if ($stmt->execute()) {
    echo json_encode(["ok" => true]);
} else {
    echo json_encode(["ok" => false, "error" => $stmt->error]);
}
?>