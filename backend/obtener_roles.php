<?php
require "conexion.php";
header("Content-Type: application/json");

$sql = "SELECT id_rol, nombre FROM rol";
$res = $conexion->query($sql);
$data = [];

while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
