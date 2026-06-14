<?php
session_start();
require_once __DIR__ . "/conexion.php";

$nombre = $_POST["nombre"];
$cedula = $_POST["cedula"] ?? "";
$telefono = $_POST["telefono"] ?? "";
$direccion = $_POST["direccion"] ?? "";

$sql = "INSERT INTO cliente (nombre, cedula, telefono, direccion)
        VALUES ('$nombre', '$cedula', '$telefono', '$direccion')";

if ($conexion->query($sql)) {
    echo json_encode(["ok" => true]);
} else {
    echo json_encode(["ok" => false, "error" => $conexion->error]);
}
