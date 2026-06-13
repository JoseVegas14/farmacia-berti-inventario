<?php
require "conexion.php";
require "middleware.php";
permitir(["administrador", "gerente"]);

$id = intval($_POST["id_proveedor"]);
$nombre = $_POST["nombre"];
$telefono = $_POST["telefono"];
$correo = $_POST["correo"];
$direccion = $_POST["direccion"];

$sql = "UPDATE proveedor SET nombre=?, telefono=?, correo=?, direccion=? WHERE id_proveedor=?";
$stmt = $conexion->prepare($sql);
$stmt->bind_param("ssssi", $nombre, $telefono, $correo, $direccion, $id);

if ($stmt->execute()) {
    echo json_encode(["ok" => true]);
} else {
    echo json_encode(["ok" => false, "error" => $stmt->error]);
}
?>