<?php
require "conexion.php";
require "middleware.php";
permitir(["administrador", "gerente"]);

$nombre = $_POST["nombre"];
$usuario = $_POST["usuario"];
$contrasena = password_hash($_POST["contrasena"], PASSWORD_BCRYPT);
$rol = intval($_POST["rol"]);

$sql = "INSERT INTO usuario (nombre, usuario, contrasena, id_rol, estado) VALUES (?, ?, ?, ?, 1)";
$stmt = $conexion->prepare($sql);
$stmt->bind_param("sssi", $nombre, $usuario, $contrasena, $rol);

if ($stmt->execute()) {
    echo json_encode(["ok" => true]);
} else {
    echo json_encode(["ok" => false, "error" => $stmt->error]);
}
?>