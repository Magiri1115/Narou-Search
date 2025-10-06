// pagination.js — ページネーション制御

/**
 * renderPagination(containerEl, currentPage, totalPages, onPageClick)
 * - currentPage: 1-based
 */
export function renderPagination(containerEl, currentPage, totalPages, onPageClick) {
  containerEl.innerHTML = '';
  if (totalPages <= 1) return;

  const createBtn = (label, page, cls = '') => {
    const b = document.createElement('button');
    b.className = 'page-btn ' + cls;
    b.textContent = label;
    b.disabled = page === currentPage || page < 1 || page > totalPages;
    b.addEventListener('click', () => onPageClick(page));
    return b;
  };

  // Prev
  containerEl.appendChild(createBtn('前へ', currentPage - 1));

  // show up to 7 page buttons with window
  const windowSize = 7;
  let start = Math.max(1, currentPage - Math.floor(windowSize / 2));
  let end = Math.min(totalPages, start + windowSize - 1);
  if (end - start + 1 < windowSize) {
    start = Math.max(1, end - windowSize + 1);
  }

  if (start > 1) {
    containerEl.appendChild(createBtn('1', 1));
    if (start > 2) {
      const ell = document.createElement('span');
      ell.textContent = '...';
      ell.style.padding = '6px';
      containerEl.appendChild(ell);
    }
  }

  for (let p = start; p <= end; p++) {
    const cls = p === currentPage ? 'active' : '';
    containerEl.appendChild(createBtn(String(p), p, cls));
  }

  if (end < totalPages) {
    if (end < totalPages - 1) {
      const ell = document.createElement('span');
      ell.textContent = '...';
      ell.style.padding = '6px';
      containerEl.appendChild(ell);
    }
    containerEl.appendChild(createBtn(String(totalPages), totalPages));
  }

  // Next
  containerEl.appendChild(createBtn('次へ', currentPage + 1));
}