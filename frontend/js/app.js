// app.js — メインの検索処理と結果描画
import { formatDate, buildQuery, esc } from './utils.js';
import { renderPagination } from './pagination.js';

let form, resultsTable, resultsBody, qEl, fromEl, toEl, sortEl, metaEl, paginationEl, clearBtn;
let lastQuery = null;
const PAGE_SIZE = 10; // バックエンドと合わせる

// DOMが読み込まれた後に初期化
function initializeApp() {
  form = document.getElementById("search-form");
  resultsTable = document.getElementById("results-table");
  resultsBody = document.getElementById("results-body");
  qEl = document.getElementById("query");
  fromEl = document.getElementById("from");
  toEl = document.getElementById("to");
  sortEl = document.getElementById("sort");
  metaEl = document.getElementById("error-message");
  paginationEl = document.getElementById("pagination");
  clearBtn = document.getElementById("clear-btn");

  // イベントリスナーを登録
  if (form) {
    form.addEventListener('submit', (e) => {
      e.preventDefault();
      handleSearch(1);
    });
  }

  if (clearBtn) {
    clearBtn.addEventListener('click', () => {
      qEl.value = '';
      fromEl.value = '';
      toEl.value = '';
      handleSearch(1);
    });
  }
}

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
  metaEl.textContent = '';
  metaEl.classList.add('hidden');

  if (!data || !Array.isArray(data.results) || data.results.length === 0) {
    resultsTable.classList.add('hidden');
    metaEl.textContent = '該当する作品が見つかりませんでした。';
    metaEl.classList.remove('hidden');
    paginationEl.innerHTML = '';
    paginationEl.classList.add('hidden');
    return;
  }

    resultsTable.classList.remove("hidden");

    data.results.forEach((w) => {
      const tr = document.createElement("tr");

    const titleTd = document.createElement('td');
    const a = document.createElement('a');
    a.href = `https://ncode.syosetu.com/${encodeURIComponent(w.ncode)}/`;
    a.target = '_blank';
    a.rel = 'noopener noreferrer';
    a.innerHTML = esc(w.title);
    titleTd.appendChild(a);

    const writerTd = document.createElement('td');
    const wa = document.createElement('a');
    wa.href = '#';
    wa.dataset.writer = w.writer;
    wa.textContent = w.writer;
    wa.addEventListener('click', (e) => {
      e.preventDefault();
      // 著者名クリックでその著者の作品一覧を表示（キーワードを作者名にして再検索）
      qEl.value = w.writer; // 検索フォームに作者名を設定
      handleSearch(1); // ページをリセットして再検索
    });
    writerTd.appendChild(wa);

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
    sort: sortEl.value || undefined,
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

  resultsBody.innerHTML = '<tr><td colspan="3" class="small-muted">検索中...</td></tr>';
  metaEl.textContent = '';
  paginationEl.innerHTML = '';

  try {
    const data = await fetchSearch(params);
    renderResults(data);
  } catch (error) {
    console.error('検索エラー:', error);
    resultsTable.classList.add('hidden');
    paginationEl.classList.add('hidden');
    metaEl.textContent = `エラーが発生しました: ${error.message}`;
    metaEl.classList.remove('hidden');
  }
}

// DOMが読み込まれたら初期化
if (document.readyState === 'loading') {
  document.addEventListener('DOMContentLoaded', initializeApp);
} else {
  initializeApp();
}
