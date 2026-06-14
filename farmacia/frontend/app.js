/* ========================================
   SISTEMA DE INVENTARIO - FRONTEND (CORREGIDO)
======================================== */

// 1. LEER SESIÓN DEL LOCALSTORAGE ANTES DE INICIAR LÓGICAS
const sesion = JSON.parse(localStorage.getItem("usuarioActual"));
if (!sesion) {
  window.location.href = "login.html";
}

let productos = [];
let proveedores = [];
let usuarios = [];
let facturas = [];
let clientes = [];


const roles = {
  administrador: {
    acceso: ["dashboard", "productos", "stock", "facturas", "proveedores", "clientes", "usuarios"],
    puedeEliminar: ["gerente", "vendedor", "almacenista"]
  },
  gerente: {
    acceso: ["dashboard", "productos", "stock", "facturas", "proveedores", "clientes", "usuarios"],
    puedeEliminar: ["vendedor", "almacenista"]
  },
  vendedor: {
    acceso: ["dashboard", "productos", "clientes"],
    puedeEliminar: []
  },
  almacenista: {
    acceso: ["dashboard", "stock"],
    puedeEliminar: []
  }
};

const $ = (id) => document.getElementById(id);
const rolUsuario = (sesion.rol || "").trim().toLowerCase();

// Inyectar Perfil Real (con null-checks)
if ($("side-nombre")) $("side-nombre").textContent = sesion.nombre || "";
if ($("side-rol")) $("side-rol").textContent = (sesion.rol || "").toUpperCase();
if ($("top-usuario")) $("top-usuario").textContent = `Usuario: ${sesion.usuario || ""}`;

const avatarImg = document.querySelector(".sidebar-user-img");
if (avatarImg) {
  avatarImg.src = `https://ui-avatars.com/api/?name=${encodeURIComponent(
    sesion.nombre || "Usuario"
  )}&background=2563eb&color=fff`;
}

/* -------------------------------------------
   PERMISOS POR ROL / PÁGINAS
--------------------------------------------*/
function aplicarPermisos() {
  const paginasPermitidas = JSON.parse(localStorage.getItem("paginas_usuario")) || [];

  if (paginasPermitidas.length === 0) {
    paginasPermitidas.push("dashboard");
  }

  document.querySelectorAll(".sidebar-nav .nav-item").forEach((btn) => {
    const section = btn.dataset.section;
    if (section && !paginasPermitidas.includes(section.toLowerCase().trim())) {
      btn.style.display = "none";
    } else {
      btn.style.display = "block";
    }
  });

  document.querySelectorAll(".section").forEach((sec) => {
    const sectionId = sec.id;
    if (sectionId && !paginasPermitidas.includes(sectionId.toLowerCase().trim())) {
      sec.style.display = "none";
    }
  });
}

/* -------------------------------
   MANEJO DE VISTAS
--------------------------------*/
function cambiarSeccion(targetSectionId) {
  const permisos = roles[rolUsuario];
  if (!permisos || !permisos.acceso.includes(targetSectionId)) return;

  document.querySelectorAll(".section").forEach((sec) => {
    sec.classList.remove("visible");
    if (sec.id === targetSectionId) {
      sec.classList.add("visible");
    }
  });

  document.querySelectorAll(".nav-item").forEach((btn) => {
    btn.classList.remove("active");
    if (btn.dataset.section === targetSectionId) {
      btn.classList.add("active");
    }
  });

  if ($("section-title")) {
    $("section-title").textContent = targetSectionId.toUpperCase();
  }
}

/* -------------------------------
   MÓDULO: PRODUCTOS
--------------------------------*/
async function cargarProductos() {
  try {
    const res = await fetch("../backend/obtener_productos.php");
    productos = await res.json();
  } catch (e) {
    console.error("Error al obtener productos", e);
  }
}

function renderProductos() {
  const tbody = $("tabla-productos");
  if (!tbody) return;
  tbody.innerHTML = "";
  productos.forEach((p) => {
    tbody.innerHTML += `
      <tr>
        <td>${p.id_producto ?? ""}</td>
        <td>${p.nombre ?? ""}</td>
        <td>${p.categoria ?? "Sin categoría"}</td>
        <td>${p.proveedor ?? "Sin proveedor"}</td>
        <td>$${parseFloat(p.precio_venta ?? 0).toFixed(2)}</td>
        <td>${p.cantidad_actual ?? 0}</td>
        <td>${p.estado == 1 ? "Activo" : "Inactivo"}</td>
        <td>
          <button class="action-btn edit" onclick="abrirEditarProducto(${p.id_producto})">✏️</button>
          <button class="action-btn delete" onclick="eliminarProducto(${p.id_producto})">🗑️</button>
        </td>
      </tr>
    `;
  });
}

function renderStock() {
  const tbody = $("tabla-stock");
  if (!tbody) return;
  tbody.innerHTML = "";
  productos.forEach((p) => {
    tbody.innerHTML += `
      <tr>
        <td>${p.nombre ?? ""}</td>
        <td><strong>${p.cantidad_actual ?? 0}</strong></td>
        <td>${p.cantidad_minima ?? 0}</td>
        <td>${p.cantidad_maxima ?? 0}</td>
        <td>${p.estado == 1 ? "OK" : "Inactivo"}</td>
      </tr>
    `;
  });
}

async function cargarSelectsProducto() {
  const selectCat = $("prod-categoria");
  const selectProv = $("prod-proveedor");

  if (selectCat) {
    const r1 = await fetch("../backend/obtener_categorias.php");
    const cats = await r1.json();
    selectCat.innerHTML = cats
      .map((c) => `<option value="${c.id_categoria}">${c.nombre}</option>`)
      .join("");
  }
  if (selectProv) {
    const r2 = await fetch("../backend/obtener_proveedores.php");
    const provs = await r2.json();
    selectProv.innerHTML = provs
      .map((p) => `<option value="${p.id_proveedor}">${p.nombre}</option>`)
      .join("");
  }
}

async function crearProducto(e) {
  e.preventDefault();
  const form = $("form-producto");
  if (!form) return;
  const formData = new FormData(form);
  const res = await fetch("../backend/crear_producto.php", {
    method: "POST",
    body: formData,
      credentials: "include"
  });
  const data = await res.json();
  if (data.ok) {
    $("modal-producto").classList.remove("visible");
    await cargarProductos();
    renderProductos();
    renderStock();
    renderDashboard();
  } else {
    alert("Error: " + (data.error || "Error al crear producto"));
  }
}


async function cargarSelectImpuestos() {
  const selectImp = $("prod-impuesto");
  const res = await fetch("../backend/obtener_impuestos.php", {
    credentials: "include"
  });
  const impuestos = await res.json();
  selectImp.innerHTML = impuestos
    .map(i => `<option value="${i.id_impuesto}">${i.nombre}</option>`)
    .join("");
}


async function abrirEditarProducto(id) {
  const p = productos.find((prod) => prod.id_producto == id);
  if (!p) return;

  if ($("modal-title")) $("modal-title").textContent = "Editar Producto";
  if ($("prod-nombre")) $("prod-nombre").value = p.nombre ?? "";
  if ($("prod-descripcion")) $("prod-descripcion").value = p.descripcion ?? "";
  if ($("prod-categoria")) $("prod-categoria").value = p.id_categoria ?? "";
  if ($("prod-proveedor")) $("prod-proveedor").value = p.id_proveedor ?? "";
  if ($("prod-precio")) $("prod-precio").value = p.precio_venta ?? "";
  if ($("prod-cantidad")) $("prod-cantidad").value = p.cantidad_actual ?? "";
  if ($("prod-codigo")) $("prod-codigo").value = p.codigo_barra ?? "";
  if ($("prod-vencimiento")) $("prod-vencimiento").value = p.fecha_vencimiento || "";

  const form = $("form-producto");
  if (!form) return;

  form.onsubmit = async (e) => {
    e.preventDefault();
    const fData = new FormData(form);
    fData.append("id_producto", id);
    const res = await fetch("../backend/editar_producto.php", {
      method: "POST",
      body: fData,
      credentials: "include"
    });
    const data = await res.json();
    if (data.ok) {
      $("modal-producto").classList.remove("visible");
      await cargarProductos();
      renderProductos();
      renderStock();
      renderDashboard();
    } else {
      alert(data.error || "Error al editar producto");
    }
  };

  $("modal-producto").classList.add("visible");
}

async function eliminarProducto(id) {
  if (!confirm("¿Seguro que deseas eliminar este producto y sus datos asociados?")) return;
  const fData = new FormData();
  fData.append("id_producto", id);
  const res = await fetch("../backend/eliminar_producto.php", {
    method: "POST",
    body: fData,
    credentials: "include"
  });
  const data = await res.json();
  if (data.ok) {
    await cargarProductos();
    renderProductos();
    renderStock();
    renderDashboard();
  } else {
    alert(data.error || "Error al eliminar producto");
  }
}

/* -------------------------------
   MÓDULO: PROVEEDORES
--------------------------------*/
async function cargarProveedores() {
  try {
    const res = await fetch("../backend/obtener_proveedores.php", {
      credentials: "include"
    });

    if (!res.ok) {
      console.error("Error al obtener proveedores:", res.status);
      proveedores = [];
      return;
    }

    proveedores = await res.json();
  } catch (e) {
    console.error("Error al obtener proveedores", e);
  }
}


function renderProveedores() {
  const tbody = $("tabla-proveedores");
  if (!tbody) return;
  tbody.innerHTML = "";
  proveedores.forEach((p) => {
    tbody.innerHTML += `
      <tr>
        <td>${p.nombre}</td>
        <td>${p.telefono}</td>
        <td>${p.correo}</td>
        <td>${p.direccion ?? ""}</td>
        <td>
          <button class="action-btn edit" onclick="abrirEditarProveedor(${p.id_proveedor})">✏️</button>
          <button class="action-btn delete" onclick="eliminarProveedor(${p.id_proveedor})">🗑️</button>
        </td>
      </tr>
    `;
  });
}




async function abrirEditarProveedor(id) {
  const p = proveedores.find((prov) => prov.id_proveedor == id);
  if (!p) return;

  if ($("prov-nombre")) $("prov-nombre").value = p.nombre ?? "";
  if ($("prov-telefono")) $("prov-telefono").value = p.telefono ?? "";
  if ($("prov-correo")) $("prov-correo").value = p.correo ?? "";
  if ($("prov-direccion")) $("prov-direccion").value = p.direccion ?? "";

  const form = $("form-proveedor");
  if (!form) return;

  form.onsubmit = async (e) => {
    e.preventDefault();
    const fData = new FormData(form);
    fData.append("id_proveedor", id);
    const res = await fetch("../backend/editar_proveedor.php", {
  method: "POST",
  body: fData,
  credentials: "include"
});

    const data = await res.json();
    if (data.ok) {
      $("modal-proveedor").classList.remove("visible");
      await cargarProveedores();
      renderProveedores();
      renderDashboard();
    } else {
      alert(data.error || "Error al editar proveedor");
    }
  };

  $("modal-proveedor").classList.add("visible");
}

async function eliminarProveedor(id) {
  if (!confirm("¿Eliminar proveedor?")) return;
  const fData = new FormData();
  fData.append("id_proveedor", id);
  const res = await fetch("../backend/eliminar_proveedor.php", {
  method: "POST",
  body: fData,
  credentials: "include"
});

  const data = await res.json();
  if (data.ok) {
    await cargarProveedores();
    renderProveedores();
    renderDashboard();
  } else {
    alert(data.error || "Error al eliminar proveedor");
  }
}



/* -------------------------------
   MÓDULO: FACTURAS
--------------------------------*/
async function cargarFacturas() {
  try {
    const res = await fetch("../backend/obtener_facturas.php", {
      credentials: "include"
    });
    facturas = await res.json();
  } catch (e) {
    console.error("Error al obtener facturas", e);
    facturas = [];
  }
}

function renderFacturas() {
  const tbody = $("tabla-facturas");
  if (!tbody) return;

  tbody.innerHTML = facturas.map(f => `
    <tr>
      <td>${f.numero_factura}</td>
      <td>${f.cliente_nombre || ""}</td>
      <td>${f.fecha_emision}</td>
      <td>${parseFloat(f.subtotal).toFixed(2)}</td>
      <td>${parseFloat(f.impuesto).toFixed(2)}</td>
      <td>${parseFloat(f.total).toFixed(2)}</td>
      <td>
        <button class="action-btn edit" onclick="abrirEditarFactura(${f.id_factura})">✏️</button>
        <button class="action-btn delete" onclick="eliminarFactura(${f.id_factura})">🗑️</button>
      </td>
    </tr>
  `).join("");
}

async function abrirEditarFactura(id) {
  const f = facturas.find(x => x.id_factura == id);
  if (!f) return;

  const form = $("form-factura");
  if (!form) return;
  form.reset();

  $("fact-id").value = f.id_factura;
  $("fact-numero").value = f.numero_factura;
  $("fact-metodo").value = f.metodo_pago || "";
  $("fact-observaciones").value = f.observaciones || "";
  $("fact-cliente").value = f.id_cliente || "";

  const res = await fetch("../backend/obtener_detalle_factura.php?id_factura=" + id, {
    credentials: "include"
  });
  const detalle = await res.json();

  const tbody = $("fact-detalle-body");
  tbody.innerHTML = "";

  detalle.forEach((d, idx) => {
    const row = document.createElement("tr");
    row.innerHTML = `
      <td>${d.producto_nombre}</td>
      <td>${d.cantidad}</td>
      <td>${parseFloat(d.precio_unitario).toFixed(2)}</td>
      <td>${parseFloat(d.subtotal).toFixed(2)}</td>
    `;
    tbody.appendChild(row);
  });

  $("fact-subtotal").textContent = parseFloat(f.subtotal).toFixed(2);
  $("fact-impuesto").textContent = parseFloat(f.impuesto).toFixed(2);
  $("fact-total").textContent = parseFloat(f.total).toFixed(2);

  $("modal-factura-title").textContent = "Detalle de factura";
  $("modal-factura").classList.add("visible");
}

async function eliminarFactura(id) {
  if (!confirm("¿Eliminar esta factura?")) return;

  const fData = new FormData();
  fData.append("id_factura", id);

  const res = await fetch("../backend/eliminar_factura.php", {
    method: "POST",
    body: fData,
    credentials: "include"
  });

  const data = await res.json();

  if (data.ok) {
    await cargarFacturas();
    renderFacturas();
    renderDashboard();
  } else {
    alert(data.error || "Error al eliminar factura");
  }
}

/* -------------------------------
   MÓDULO: USUARIOS
--------------------------------*/
async function cargarUsuarios() {
  try {
    const res = await fetch("../backend/obtener_usuarios.php", {
      credentials: "include"
    });

    if (!res.ok) {
      console.error("Error al obtener usuarios:", res.status);
      usuarios = [];
      return;
    }

    usuarios = await res.json();
  } catch (e) {
    console.error("Error al obtener usuarios", e);
  }
}


function renderUsuarios() {
  const tbody = $("tabla-usuarios");
  if (!tbody) return;
  tbody.innerHTML = "";
  usuarios.forEach((u) => {
    tbody.innerHTML += `
      <tr>
        <td>${u.nombre}</td>
        <td>${(u.rol || "").toUpperCase()}</td>
        <td>${u.usuario}</td>
        <td>
          <button class="action-btn edit" onclick="abrirEditarUsuario(${u.id_usuario})">✏️</button>
          <button class="action-btn delete" onclick="eliminarUsuario(${u.id_usuario})">🗑️</button>
        </td>
      </tr>
    `;
  });
}

async function cargarSelectRoles() {
  const selectRol = $("user-rol");
  if (!selectRol) return;
  const res = await fetch("../backend/obtener_roles.php");
  const rolesBD = await res.json();
  selectRol.innerHTML = rolesBD
    .map((r) => `<option value="${r.id_rol}">${r.nombre}</option>`)
    .join("");
}

async function abrirEditarUsuario(id) {
  const u = usuarios.find((user) => user.id_usuario == id);
  if (!u) return;

  if ($("modal-user-title")) $("modal-user-title").textContent = "Editar Usuario";
  if ($("user-nombre")) $("user-nombre").value = u.nombre ?? "";
  if ($("user-usuario")) $("user-usuario").value = u.usuario ?? "";
  if ($("user-rol")) $("user-rol").value = u.id_rol ?? "";
  if ($("user-estado")) $("user-estado").value = u.estado ?? "";
  if ($("user-contrasena")) $("user-contrasena").value = "";

  const form = $("form-usuario");
  if (!form) return;

  form.onsubmit = async (e) => {
    e.preventDefault();
    const fData = new FormData(form);
    fData.append("id_usuario", id);
    const res = await fetch("../backend/editar_usuario.php", {
      method: "POST",
      body: fData,
      credentials: "include"
    });
    const data = await res.json();
    if (data.ok) {
      $("modal-usuario").classList.remove("visible");
      await cargarUsuarios();
      renderUsuarios();
    } else {
      alert(data.error || "Error al editar usuario");
    }
  };

  $("modal-usuario").classList.add("visible");
}

async function eliminarUsuario(id) {
  if (!confirm("¿Eliminar este usuario de forma permanente?")) return;
  const fData = new FormData();
  fData.append("id_usuario", id);
  const res = await fetch("../backend/eliminar_usuario.php", {
    method: "POST",
    body: fData,
    credentials: "include"
  });
  const data = await res.json();
  if (data.ok) {
    await cargarUsuarios();
    renderUsuarios();
  } else {
    alert(data.error || "Error al eliminar usuario");
  }
}

/* -------------------------------
   DASHBOARD METRICS
--------------------------------*/
function renderDashboard() {
  if ($("card-productos")) $("card-productos").textContent = productos.length;

  if ($("card-stock")) {
    const totalStock = productos.reduce((acc, p) => {
      const cantidad = parseInt(p.cantidad_actual ?? 0, 10);
      return acc + (isNaN(cantidad) ? 0 : cantidad);
    }, 0);
    $("card-stock").textContent = totalStock;
  }

  if ($("card-facturas")) $("card-facturas").textContent = facturas.length;
  if ($("card-proveedores")) $("card-proveedores").textContent = proveedores.length;
}


/* -------------------------------
   MÓDULO: CLIENTES
--------------------------------*/
async function cargarClientes() {
  try {
    const res = await fetch("../backend/obtener_clientes.php", {
      credentials: "include"
    });
    clientes = await res.json();
  } catch (e) {
    console.error("Error al obtener clientes", e);
    clientes = [];
  }
}

function renderClientes() {
  const tbody = $("tabla-clientes");
  if (!tbody) return;

  tbody.innerHTML = clientes.map(c => `
    <tr>
      <td>${c.nombre}</td>
      <td>${c.cedula || ""}</td>
      <td>${c.telefono || ""}</td>
      <td>${c.direccion || ""}</td>
    </tr>
  `).join("");
}


/* -------------------------------
   EVENTOS DE INTERFAZ Y MODALES
--------------------------------*/
function setupEventListeners() {
  document.querySelectorAll(".sidebar-nav .nav-item").forEach((btn) => {
    btn.addEventListener("click", () => cambiarSeccion(btn.dataset.section));
  });

  if ($("sidebar-user")) {
    $("sidebar-user").addEventListener("click", () => {
      if ($("user-dropdown")) {
        $("user-dropdown").classList.toggle("visible");
      }
    });
  }

  if ($("btn-logout")) {
    $("btn-logout").addEventListener("click", () => {
      localStorage.removeItem("usuarioActual");
      window.location.href = "login.html";
    });
  }

  if ($("btn-nuevo-producto")) {
    $("btn-nuevo-producto").addEventListener("click", () => {
      const form = $("form-producto");
      if (!form) return;
      form.reset();
      if ($("modal-title")) $("modal-title").textContent = "Nuevo producto";
      form.onsubmit = crearProducto;
      $("modal-producto").classList.add("visible");
    });
  }

  if ($("btn-nuevo-proveedor")) {
    $("btn-nuevo-proveedor").addEventListener("click", () => {
      const form = $("form-proveedor");
      if (!form) return;
      form.reset();
      if ($("modal-prov-title")) $("modal-prov-title").textContent = "Nuevo proveedor";
      form.onsubmit = async (e) => {
        e.preventDefault();
        const fData = new FormData(form);
        const res = await fetch("../backend/crear_proveedor.php", {
          method: "POST",
          body: fData,
        });
        const data = await res.json();
        if (data.ok) {
          $("modal-proveedor").classList.remove("visible");
          await cargarProveedores();
          renderProveedores();
          renderDashboard();
        } else {
          alert(data.error || "Error al crear proveedor");
        }
      };
      $("modal-proveedor").classList.add("visible");
    });
  }

  if ($("btn-nuevo-usuario")) {
    $("btn-nuevo-usuario").addEventListener("click", () => {
      const form = $("form-usuario");
      if (!form) return;
      form.reset();
      if ($("modal-user-title")) $("modal-user-title").textContent = "Nuevo usuario";
      form.onsubmit = async (e) => {
        e.preventDefault();
        const fData = new FormData(form);
        const res = await fetch("../backend/crear_usuario.php", {
          method: "POST",
          body: fData,
        });
        const data = await res.json();
        if (data.ok) {
          $("modal-usuario").classList.remove("visible");
          await cargarUsuarios();
          renderUsuarios();
        } else {
          alert(data.error || "Error al crear usuario");
        }
      };
      $("modal-usuario").classList.add("visible");
    });
  }

  if ($("btn-cancelar")) {
    $("btn-cancelar").onclick = () => $("modal-producto").classList.remove("visible");
  }
  if ($("btn-cancelar-prov")) {
    $("btn-cancelar-prov").onclick = () => $("modal-proveedor").classList.remove("visible");
  }



// Abrir modal cliente
if ($("btn-nuevo-cliente")) {
  $("btn-nuevo-cliente").addEventListener("click", () => {
    const form = $("form-cliente");
    form.reset();
    $("cliente-id").value = "";
    $("modal-cliente-title").textContent = "Nuevo cliente";
    $("modal-cliente").classList.add("visible");
  });
}

// Cerrar modal cliente
if ($("btn-cancelar-cliente")) {
  $("btn-cancelar-cliente").onclick = () =>
    $("modal-cliente").classList.remove("visible");
}



    if ($("btn-nueva-factura")) {
    $("btn-nueva-factura").addEventListener("click", async () => {
      const form = $("form-factura");
      if (!form) return;
      form.reset();

      $("fact-id").value = "";
      $("fact-detalle-body").innerHTML = "";
      $("fact-subtotal").textContent = "0.00";
      $("fact-impuesto").textContent = "0.00";
      $("fact-total").textContent = "0.00";

      await cargarFacturas();
      await cargarProductos();

      $("modal-factura-title").textContent = "Nueva factura";
      $("modal-factura").classList.add("visible");
    });
  }

  if ($("btn-cancelar-factura")) {
    $("btn-cancelar-factura").onclick = () => {
      $("modal-factura").classList.remove("visible");
    };
  }

}



if ($("form-cliente")) {
  $("form-cliente").addEventListener("submit", async (e) => {
    e.preventDefault();

    const fData = new FormData(e.target);

    const id = $("cliente-id").value;
    const url = id
      ? "../backend/editar_cliente.php"
      : "../backend/crear_cliente.php";

    const res = await fetch(url, {
      method: "POST",
      body: fData,
      credentials: "include"
    });

    const data = await res.json();

    if (data.ok) {
      $("modal-cliente").classList.remove("visible");
      await cargarClientes();
      renderClientes();
    } else {
      alert(data.error || "Error al guardar cliente");
    }
  });
}



if ($("form-factura")) {
  $("form-factura").addEventListener("submit", async (e) => {
    e.preventDefault();

    const form = e.target;
    const fData = new FormData(form);

    const res = await fetch("../backend/crear_factura.php", {
      method: "POST",
      body: fData,
      credentials: "include"
    });

    const data = await res.json();

    if (data.ok) {
      $("modal-factura").classList.remove("visible");
      await cargarFacturas();
      renderFacturas();
      renderDashboard();
    } else {
      alert(data.error || "Error al guardar factura");
    }
  });
}

/* -------------------------------
   INICIALIZACIÓN FINAL
--------------------------------*/
async function init() {
  setupEventListeners();

  await cargarProveedores();
  renderProveedores();

  await cargarProductos();
  renderProductos();
  renderStock();

  await cargarSelectsProducto();


  await cargarFacturas();
  renderFacturas();

   await cargarClientes();
  renderClientes();

  if (rolUsuario === "administrador" || rolUsuario === "gerente") {
    await cargarUsuarios();
    renderUsuarios();
    await cargarSelectRoles();
  }

  renderDashboard();
}


document.addEventListener("DOMContentLoaded", init);