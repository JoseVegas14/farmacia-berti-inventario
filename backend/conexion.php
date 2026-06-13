<?php
$host = "localhost";
$user = "root";
$pass = "";
$db   = "farmacia";

$conexion = new mysqli($host, $user, $pass, $db);

if ($conexion->connect_error) {
    die(json_encode(["ok" => false, "error" => "Error de conexión: " . $conexion->connect_error]));
}

$conexion->set_charset("utf8");
?>