<?php
session_start();
header("Content-Type: application/json");
require "conexion.php";

if (!isset($_POST["usuario"]) || !isset($_POST["contrasena"])) {
    echo json_encode([
        "ok" => false,
        "msg" => "No se recibieron datos"
    ]);
    exit;
}

$usuario = $_POST["usuario"];
$clave   = $_POST["contrasena"];

$sql = "SELECT 
            u.id_usuario,
            u.nombre,
            u.usuario,
            u.contrasena,
            u.id_rol,
            u.estado,
            r.nombre AS rol
        FROM usuario u
        INNER JOIN rol r ON u.id_rol = r.id_rol
        WHERE u.usuario = ?
        LIMIT 1";

$stmt = $conexion->prepare($sql);
$stmt->bind_param("s", $usuario);
$stmt->execute();
$result = $stmt->get_result();

if ($result->num_rows === 1) {

    $row = $result->fetch_assoc();

    if ($row["estado"] == 0) {
        echo json_encode(["ok" => false, "msg" => "Usuario inactivo"]);
        exit;
    }

    $hash = $row["contrasena"];
    $loginCorrecto = false;

    if (password_verify($clave, $hash)) {
        $loginCorrecto = true;
    } elseif ($clave === $hash) {
        $loginCorrecto = true;
    }

    if ($loginCorrecto) {

        // PÁGINAS PERMITIDAS POR ROL
        $paginas = [];

        switch (strtolower($row["rol"])) {
            case "administrador":
                $paginas = ["dashboard","productos","stock","facturas","proveedores","clientes","usuarios"];
                break;
            case "gerente":
                $paginas = ["dashboard","productos","stock","facturas","proveedores","clientes"];
                break;
            case "vendedor":
                $paginas = ["dashboard","productos","clientes","facturas"];
                break;
            case "almacenista":
                $paginas = ["dashboard","stock"];
                break;
        }

        echo json_encode([
            "ok" => true,
            "msg" => "Acceso concedido",
            "rol" => $row["rol"],
            "nombre" => $row["nombre"],
            "usuario" => $row["usuario"],
            "paginas" => $paginas
        ]);
        exit;
    }
}

echo json_encode(["ok" => false, "msg" => "Credenciales incorrectas"]);
?>
