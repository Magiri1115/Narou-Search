import { fetchWorks, formatDate, showError, hideError } from "./utils.js";
import { renderPagination } from "./pagination.js";

const form = document.getElementById("search-form");
// 🔽 検索フォーム内の要素を取得
const qEl = document.getElementById("query");          // キーワード入力欄
const fromEl = document.getElementById("year-from");   // 開始年入力欄
const toEl = document.getElementById("year-to");       // 終了年入力欄
const clearBtn = document.getElementById("clear-btn"); // クリアボタン
const metaEl = document.getElementById("meta");        // 件数などを表示する要素
const paginationEl = document.getElementById("pagination"); // ページネーション表示用

const resultsTable = document.getElementById("results-table");
const resultsBody = document.getElementById("results-body");

let currentPage = 1;
let lastQuery = null;
const PAGE_SIZE = 10; // バックエンドと合わせる

async function fetchSearch(params) {
  const qs = buildQuery(params);
  const url = `http://localhost:8000/search?${qs}`;
  const res = await fetch(url, {
    headers: {
      'Accept': 'application/json'
    }
  });
  if (!res.ok) throw new Error(`Search failed: ${res.status}`);
  return res.json();
}

function renderResults(data) {
  // data expected: { total: int, page: int, per_page: int, results: [{ncode,title,writer,general_firstup}] }
  resultsBody.innerHTML = '';
  if (!data || !Array.isArray(data.results) || data.results.length === 0) {
    metaEl.textContent = '該当なし';
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

  // ページネーションの描画
  const totalPages = Math.ceil(data.total / (data.per_page || PAGE_SIZE));
  renderPagination(paginationEl, data.page, totalPages, (page) => {
    handleSearch(page);
  });
}

function getSearchParams(page = 1) {
  return {
    keyword: qEl.value.trim() || undefined,
    year_from: fromEl.value.trim() || undefined,
    year_to: toEl.value.trim() || undefined,
    page: page,
    limit: PAGE_SIZE,
  };
}

async function handleSearch(page = 1) {
  const params = getSearchParams(page);
  const currentQuery = JSON.stringify(params);

  // 前回と同じクエリかつ同じページならスキップ
  if (lastQuery === currentQuery) return;
  lastQuery = currentQuery;
  currentPage = page;

  resultsBody.innerHTML = '<tr><td colspan="3" class="small-muted">検索中...</td></tr>';
  metaEl.textContent = '';
  paginationEl.innerHTML = '';

  try {
    const data = await fetchSearch(params);
    renderResults(data);
  } catch (error) {
    console.error('検索エラー:', error);
    resultsBody.innerHTML = '<tr><td colspan="3" class="small-muted">エラーが発生しました。</td></tr>';
    metaEl.textContent = '';
  }
}

// フォームの送信イベント
form.addEventListener('submit', (e) => {
  e.preventDefault();
  handleSearch(1); // 常に1ページ目から検索開始
});

// クリアボタンのイベント
clearBtn.addEventListener('click', () => {
  qEl.value = '';
  fromEl.value = '';
  toEl.value = '';
  handleSearch(1);
});
