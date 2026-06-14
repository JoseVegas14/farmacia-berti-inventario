<?php
require "conexion.php";
require "middleware.php";
permitir(["administrador", "gerente"]);

header("Content-Type: application/json");

// CAPTURAR CAMPOS DE FORMA SEGURA
$id         = $_POST["id_usuario"] ?? null;
$nombre     = $_POST["nombre"] ?? null;
$usuario    = $_POST["usuario"] ?? null;
$contrasena = $_POST["contrasena"] ?? null;
$rol        = $_POST["rol"] ?? null;
$estado     = $_POST["estado"] ?? 1; // SI NO VIENE, ASUMIMOS ACTIVO

if (!$id || !$nombre || !$usuario || !$rol) {
    echo json_encode([
        "ok" => false,
        "error" => "Faltan datos obligatorios"
    ]);
    exit;
}

// SI VIENE CONTRASEÑA, SE ACTUALIZA. SI NO, SE DEJA IGUAL.
if ($contrasena) {
    $hash = password_hash($contrasena, PASSWORD_DEFAULT);
    $sql = "UPDATE usuario SET nombre=?, usuario=?, contrasena=?, id_rol=?, estado=? WHERE id_usuario=?";
    $stmt = $conexion->prepare($sql);
    $stmt->bind_param("sssiii", $nombre, $usuario, $hash, $rol, $estado, $id);
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
