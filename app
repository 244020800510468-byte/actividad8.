(function () {
  "use strict";

  /** @type {{ id: string, name: string, detail: string, price: number }[]} */
  let products = [];

  const form = document.getElementById("product-form");
  const nameInput = document.getElementById("product-name");
  const detailInput = document.getElementById("product-detail");
  const valueInput = document.getElementById("product-value");
  const grid = document.getElementById("product-grid");
  const emptyState = document.getElementById("empty-state");
  const countEl = document.getElementById("product-count");

  const errName = document.getElementById("error-name");
  const errDetail = document.getElementById("error-detail");
  const errValue = document.getElementById("error-value");

  const currencyFormatter = new Intl.NumberFormat("es", {
    style: "currency",
    currency: "USD",
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });

  const numberDisplayFormatter = new Intl.NumberFormat("es", {
    minimumFractionDigits: 2,
    maximumFractionDigits: 2,
  });

  function parseCurrencyInput(raw) {
    if (raw == null || String(raw).trim() === "") return NaN;
    let s = String(raw).trim().replace(/\s/g, "");
    s = s.replace(/[^\d.,-]/g, "");
    const lastComma = s.lastIndexOf(",");
    const lastDot = s.lastIndexOf(".");
    let normalized = s;
    if (lastComma > lastDot) {
      normalized = s.replace(/\./g, "").replace(",", ".");
    } else if (lastDot > lastComma) {
      normalized = s.replace(/,/g, "");
    } else if (lastComma >= 0) {
      normalized = s.replace(",", ".");
    }
    const n = parseFloat(normalized);
    return Number.isFinite(n) ? n : NaN;
  }

  valueInput.addEventListener("blur", function () {
    const n = parseCurrencyInput(valueInput.value);
    if (Number.isFinite(n) && n >= 0) {
      valueInput.value = numberDisplayFormatter.format(n);
    }
  });

  function clearErrors() {
    errName.textContent = "";
    errDetail.textContent = "";
    errValue.textContent = "";
    nameInput.classList.remove("form__input--invalid");
    detailInput.classList.remove("form__input--invalid");
    valueInput.classList.remove("form__input--invalid");
  }

  function validate() {
    clearErrors();
    let ok = true;
    const name = nameInput.value.trim();
    const detail = detailInput.value.trim();
    const price = parseCurrencyInput(valueInput.value);

    if (!name) {
      errName.textContent = "Indica el nombre del producto.";
      nameInput.classList.add("form__input--invalid");
      ok = false;
    }
    if (!detail) {
      errDetail.textContent = "Añade una descripción.";
      detailInput.classList.add("form__input--invalid");
      ok = false;
    }
    if (valueInput.value.trim() === "" || !Number.isFinite(price) || price < 0) {
      errValue.textContent = "Introduce un valor numérico válido (≥ 0).";
      valueInput.classList.add("form__input--invalid");
      ok = false;
    }
    return ok ? { name, detail, price } : null;
  }

  function updateEmptyState() {
    const empty = products.length === 0;
    emptyState.hidden = !empty;
    grid.hidden = empty;
    const n = products.length;
    countEl.textContent = n === 1 ? "1 producto" : `${n} productos`;
  }

  function escapeHtml(s) {
    const div = document.createElement("div");
    div.textContent = s;
    return div.innerHTML;
  }

  function render() {
    grid.innerHTML = "";
    products.forEach(function (p) {
      const article = document.createElement("article");
      article.className = "product-card";
      article.setAttribute("data-id", p.id);
      article.innerHTML =
        '<div class="product-card__header">' +
        "<h3 class=\"product-card__name\">" +
        escapeHtml(p.name) +
        "</h3>" +
        "</div>" +
        '<p class="product-card__desc">' +
        escapeHtml(p.detail) +
        "</p>" +
        '<div class="product-card__footer">' +
        '<span class="product-card__price">' +
        '<i class="fa-solid fa-tag" aria-hidden="true"></i>' +
        escapeHtml(currencyFormatter.format(p.price)) +
        "</span>" +
        '<button type="button" class="btn btn--danger btn--delete" data-id="' +
        escapeHtml(p.id) +
        '" aria-label="Eliminar ' +
        escapeHtml(p.name) +
        '">' +
        '<i class="fa-solid fa-trash-can" aria-hidden="true"></i> Quitar' +
        "</button>" +
        "</div>";
      grid.appendChild(article);
    });

    grid.querySelectorAll(".btn--delete").forEach(function (btn) {
      btn.addEventListener("click", function () {
        const id = btn.getAttribute("data-id");
        products = products.filter(function (x) {
          return x.id !== id;
        });
        render();
        updateEmptyState();
      });
    });

    updateEmptyState();
  }

  form.addEventListener("submit", function (e) {
    e.preventDefault();
    const data = validate();
    if (!data) return;

    products.push({
      id: crypto.randomUUID ? crypto.randomUUID() : String(Date.now()) + Math.random(),
      name: data.name,
      detail: data.detail,
      price: data.price,
    });

    nameInput.value = "";
    detailInput.value = "";
    valueInput.value = "";
    clearErrors();

    render();
  });

  updateEmptyState();
})();
