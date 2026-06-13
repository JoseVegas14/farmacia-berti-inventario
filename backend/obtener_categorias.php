<?php
require "conexion.php";
require "middleware.php";

$sql = "SELECT id_categoria, nombre FROM categoria ORDER BY nombre ASC";
$res = $conexion->query($sql);
$data = [];
while ($row = $res->fetch_assoc()) {
    $data[] = $row;
}
echo json_encode($data);
?>