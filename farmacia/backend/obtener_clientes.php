<?php
session_start();
require_once __DIR__ . "/conexion.php";

header("Content-Type: application/json; charset=utf-8");

$sql = "SELECT * FROM cliente ORDER BY id_cliente DESC";
$res = $conexion->query($sql);

$clientes = [];
while ($row = $res->fetch_assoc()) {
    $clientes[] = $row;
}

echo json_encode($clientes);
