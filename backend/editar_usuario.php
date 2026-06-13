<?php
require "conexion.php";
require "middleware.php";
permitir(["administrador", "gerente"]);

$id = intval($_POST["id_usuario"]);
$nombre = $_POST["nombre"];
$usuario = $_POST["usuario"];
$rol = intval($_POST["rol"]);
$estado = intval($_POST["estado"]);

if (!empty($_POST["contrasena"])) {
    $contrasena = password_hash($_POST["contrasena"], PASSWORD_BCRYPT);
    $sql = "UPDATE usuario SET nombre=?, usuario=?, contrasena=?, id_rol=?, estado=? WHERE id_usuario=?";
    $stmt = $conexion->prepare($sql);
    $stmt->bind_param("sssiii", $nombre, $usuario, $contrasena, $rol, $estado, $id);
} else {
    $sql = "UPDATE usuario SET nombre=?, usuario=?, id_rol=?, estado=? WHERE id_usuario=?";
    $stmt = $conexion->prepare($sql);
    $stmt->bind_param("ssiii", $nombre, $usuario, $rol, $estado, $id);
}

if ($stmt->execute()) {
    echo json_encode(["ok" => true]);
} else {
    echo json_encode(["ok" => false, "error" => $stmt->error]);
}
?>