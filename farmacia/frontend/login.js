document.getElementById("form-login").addEventListener("submit", async (e) => {
  e.preventDefault();

  const usuario = document.getElementById("login-usuario").value.trim();
  const contrasena = document.getElementById("login-pass").value.trim();

  const formData = new FormData();
  formData.append("usuario", usuario);
  formData.append("contrasena", contrasena);

  try {
    const res = await fetch("../backend/login.php", {
      method: "POST",
      body: formData
    });

    const data = await res.json();

    if (!data.ok) {
      showError(data.msg);
      return;
    }

    // Guardar datos del usuario
    localStorage.setItem("usuarioActual", JSON.stringify(data));
    localStorage.setItem("paginas_usuario", JSON.stringify(data.paginas));

    // Animación de salida
    const card = document.querySelector(".login-card");
    card.classList.add("fade-out");

    setTimeout(() => {
      window.location.href = "index.html";
    }, 600);

  } catch (error) {
    showError("Error de conexión con el servidor");
  }
});

function showError(msg) {
  const alertBox = document.createElement("div");
  alertBox.className = "alert-box";
  alertBox.textContent = msg;

  document.body.appendChild(alertBox);

  setTimeout(() => {
    alertBox.classList.add("hide");
    setTimeout(() => alertBox.remove(), 300);
  }, 2500);
}
