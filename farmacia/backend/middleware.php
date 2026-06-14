<?php
if (session_status() === PHP_SESSION_NONE) {
    session_start();
}

if (!isset($_SESSION["usuario"])) {
    http_response_code(401);
    echo json_encode(["error" => "No autorizado"]);
    exit;
}

function permitir($rolesPermitidos) {
    // Normalizar rol de sesión
    $rol = strtolower(trim($_SESSION["rol"]));

    // Normalizar roles permitidos
    $rolesPermitidos = array_map(fn($r) => strtolower(trim($r)), $rolesPermitidos);

    if (!in_array($rol, $rolesPermitidos)) {
        http_response_code(403);
        echo json_encode(["error" => "Acceso denegado"]);
        exit;
    }
}
?>
