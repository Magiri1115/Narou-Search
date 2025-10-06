// utils.js - 共通ユーティリティ関数群

export const API_BASE_URL = "https://api.example.com/search";

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
