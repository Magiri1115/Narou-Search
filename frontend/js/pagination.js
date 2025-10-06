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

  // Prev arrow
  containerEl.appendChild(createBtn('←', currentPage - 1));

  // Show up to 5 page buttons, starting from the lowest page in the current range
  const maxButtons = 5;
  let start = currentPage;
  let end = Math.min(totalPages, start + maxButtons - 1);

  // If we're near the end and can't show 5 buttons, adjust start
  if (end - start + 1 < maxButtons) {
    start = Math.max(1, end - maxButtons + 1);
  }

  for (let p = start; p <= end; p++) {
    const cls = p === currentPage ? 'active' : '';
    containerEl.appendChild(createBtn(String(p), p, cls));
  }

  // Next arrow
  containerEl.appendChild(createBtn('→', currentPage + 1));
}