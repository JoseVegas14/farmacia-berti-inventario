<?php
require "conexion.php";
require "middleware.php";
permitir(["administrador"]);

$id = intval($_POST["id_usuario"]);

$sql = "DELETE FROM usuario WHERE id_usuario=?";
$stmt = $conexion->prepare($sql);
$stmt->bind_param("i", $id);

if ($stmt->execute()) {
    echo json_encode(["ok" => true]);
} else {
    echo json_encode(["ok" => false, "error" => $stmt->error]);
}
?>