<?php
require "conexion.php";
require "middleware.php";

$sql = "SELECT * FROM cliente";
$result = $conexion->query($sql);
$clientes = [];
while ($row = $result->fetch_assoc()) {
    $clientes[] = $row;
}
echo json_encode($clientes);
?>