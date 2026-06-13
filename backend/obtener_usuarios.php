<?php
require "conexion.php";
header("Content-Type: application/json");

$sql = "SELECT 
            u.id_usuario,
            u.nombre,
            u.usuario,
            u.id_rol,
            u.estado,
            r.nombre AS rol
        FROM usuario u
        INNER JOIN rol r ON u.id_rol = r.id_rol";

$res = $conexion->query($sql);
$data = [];

while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}

echo json_encode($data);
