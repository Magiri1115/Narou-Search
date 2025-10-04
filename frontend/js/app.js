import { fetchWorks, formatDate, showError, hideError } from "./utils.js";
import { renderPagination } from "./pagination.js";

const form = document.getElementById("search-form");
const resultsTable = document.getElementById("results-table");
const resultsBody = document.getElementById("results-body");

let currentPage = 1;
let currentQuery = {};
let totalResults = 0;
const perPage = 10;

// 検索実行
async function search(page = 1) {
  hideError();
  resultsBody.innerHTML = "";

  const params = {
    query: currentQuery.query,
    from: currentQuery.from,
    to: currentQuery.to,
    page: page,
    per_page: perPage,
    sort: currentQuery.sort,
  };

  try {
    const data = await fetchWorks(params);

    if (!data.results || data.results.length === 0) {
      showError("該当する作品が見つかりません。");
      resultsTable.classList.add("hidden");
      return;
    }

    resultsTable.classList.remove("hidden");

    data.results.forEach((w) => {
      const tr = document.createElement("tr");

      // タイトルリンク
      const titleTd = document.createElement("td");
      const titleLink = document.createElement("a");
      titleLink.href = `https://ncode.syosetu.com/${w.ncode}/`;
      titleLink.target = "_blank";
      titleLink.textContent = w.title;
      titleTd.appendChild(titleLink);

      // 著者リンク
      const writerTd = document.createElement("td");
      const writerLink = document.createElement("a");
      writerLink.href = "#";
      writerLink.textContent = w.writer;
      writerLink.onclick = (e) => {
        e.preventDefault();
        document.getElementById("query").value = w.writer;
        document.getElementById("sort").value = "date_desc"; // 初期化
        handleSearch();
      };
      writerTd.appendChild(writerLink);

      // 公開日
      const dateTd = document.createElement("td");
      dateTd.textContent = formatDate(w.general_firstup);

      tr.appendChild(titleTd);
      tr.appendChild(writerTd);
      tr.appendChild(dateTd);
      resultsBody.appendChild(tr);
    });

    totalResults = data.total;
    const totalPages = Math.ceil(totalResults / perPage);
    renderPagination(page, totalPages, (p) => {
      currentPage = p;
      search(p);
    });
  } catch (e) {
    showError(e.message);
  }
}

// フォーム送信イベント
function handleSearch(e) {
  if (e) e.preventDefault();
  currentPage = 1;

  currentQuery = {
    query: document.getElementById("query").value.trim(),
    from: document.getElementById("from").value,
    to: document.getElementById("to").value,
    sort: document.getElementById("sort").value,
  };

  search(1);
}

form.addEventListener("submit", handleSearch);
