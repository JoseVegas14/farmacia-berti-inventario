<?php
require "conexion.php";
require "middleware.php";

$sql = "SELECT id_proveedor, nombre, telefono, correo, direccion FROM proveedor ORDER BY nombre ASC";
$res = $conexion->query($sql);
$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}
echo json_encode($data);
?>