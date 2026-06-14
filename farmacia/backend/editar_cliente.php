<?php
session_start();
require_once __DIR__ . "/conexion.php";

$id = $_POST["id_cliente"];
$nombre = $_POST["nombre"];
$cedula = $_POST["cedula"] ?? "";
$telefono = $_POST["telefono"] ?? "";
$direccion = $_POST["direccion"] ?? "";

$sql = "UPDATE cliente SET
        nombre='$nombre',
        cedula='$cedula',
        telefono='$telefono',
        direccion='$direccion'
        WHERE id_cliente=$id";

if ($conexion->query($sql)) {
    echo json_encode(["ok" => true]);
} else {
    echo json_encode(["ok" => false, "error" => $conexion->error]);
}
