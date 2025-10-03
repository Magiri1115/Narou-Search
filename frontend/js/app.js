// app.js — メインの検索処理と結果描画
import { formatDate, buildQuery, esc } from './utils.js';
import { renderPagination } from './pagination.js';

const form = document.getElementById('search-form');
const qEl = document.getElementById('q');
const fromEl = document.getElementById('from');
const toEl = document.getElementById('to');
const resultsBody = document.getElementById('results-body');
const metaEl = document.getElementById('meta');
const paginationEl = document.getElementById('pagination');
const clearBtn = document.getElementById('clear-btn');

let currentPage = 1;
let lastQuery = null;
const PAGE_SIZE = 10; // バックエンドと合わせる

async function fetchSearch(params) {
  const qs = buildQuery(params);
  const url = `/search?${qs}`; // フロントは環境に合わせてプロキシ/絶対URLに変更可
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

  metaEl.textContent = `全 ${data.total} 件 — 表示 ${data.results.length} 件 (ページ ${data.page})`;

  for (const w of data.results) {
    const tr = document.createElement('tr');

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

    const dateTd = document.createElement('td');
    dateTd.textContent = formatDate(w.general_firstup);

    tr.appendChild(titleTd);
    tr.appendChild(writerTd);
    tr.appendChild(dateTd);
    resultsBody.appendChild(tr);
  }

  // ページネーションの描画
  const totalPages = Math.ceil(data.total / (data.per_page || PAGE_SIZE));
  renderPagination(paginationEl, data.page, totalPages, (page) => {
    handleSearch(page);
  });
}

function getSearchParams(page = 1) {
  return {
    q: qEl.value.trim() || undefined,
    from: fromEl.value.trim() || undefined,
    to: toEl.value.trim() || undefined,
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
