// utils.js — 汎用関数

/** 安全に日付 (YYYY-MM-DD) にフォーマット */
export function formatDate(iso) {
  if (!iso) return "-";
  const d = new Date(iso);
  if (isNaN(d)) return iso;
  return d.toISOString().slice(0, 10);
}

/** build query params from an object */
export function buildQuery(params) {
  const qp = new URLSearchParams();
  Object.keys(params).forEach(k => {
    const v = params[k];
    if (v === undefined || v === null || v === "") return;
    qp.append(k, String(v));
  });
  return qp.toString();
}

/** Escape text for inserting into DOM as text */
export function esc(s) {
  const d = document.createTextNode(s);
  const span = document.createElement('span');
  span.appendChild(d);
  return span.innerHTML;
}