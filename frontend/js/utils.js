// utils.js - 共通ユーティリティ関数群

export const API_BASE_URL = "http://localhost:8000";

// 日付フォーマット（YYYY-MM-DD）
export function formatDate(dateStr) {
  if (!dateStr) return "";
  return dateStr.split("T")[0];
}

// エラーメッセージを表示
export function showError(message) {
  const errorBox = document.getElementById("error-message");
  errorBox.textContent = message;
  errorBox.classList.remove("hidden");
}

// エラーを隠す
export function hideError() {
  document.getElementById("error-message").classList.add("hidden");
}

// HTMLエスケープ
export function esc(str) {
  if (!str) return "";
  return String(str)
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}

// クエリパラメータをURLエンコードされた文字列に変換
export function buildQuery(params) {
  const parts = [];
  for (const key in params) {
    if (params[key] !== undefined && params[key] !== null && params[key] !== "") {
      parts.push(`${encodeURIComponent(key)}=${encodeURIComponent(params[key])}`);
    }
  }
  return parts.join("&");
}

// API リクエスト生成
export async function fetchWorks(params) {
  const url = new URL(API_BASE_URL);
  Object.keys(params).forEach((k) => {
    if (params[k]) url.searchParams.append(k, params[k]);
  });

  try {
    const res = await fetch(url);
    if (!res.ok) throw new Error(`HTTP ${res.status}`);
    return await res.json();
  } catch (e) {
    console.error("fetch error:", e);
    throw new Error("データ取得に失敗しました。");
  }
}
