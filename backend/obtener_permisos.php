<?php
session_start();
header('Content-Type: application/json');

if (isset($_SESSION["paginas"])) {
    echo json_encode([
        "ok" => true,
        "nombre" => $_SESSION["rol_nombre"],
        "paginas" => $_SESSION["paginas"]
    ]);
} else {
    echo json_encode([
        "ok" => false,
        "msg" => "No hay sesión activa"
    ]);
}
?>