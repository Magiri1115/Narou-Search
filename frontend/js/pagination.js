// pagination.js - ページネーション制御

export function renderPagination(currentPage, totalPages, onPageChange) {
  const container = document.getElementById("pagination");
  container.innerHTML = "";

  if (totalPages <= 1) {
    container.classList.add("hidden");
    return;
  }

  container.classList.remove("hidden");

  const prevBtn = document.createElement("button");
  prevBtn.textContent = "前へ";
  prevBtn.disabled = currentPage === 1;
  prevBtn.onclick = () => onPageChange(currentPage - 1);
  container.appendChild(prevBtn);

  for (let i = 1; i <= totalPages; i++) {
    const btn = document.createElement("button");
    btn.textContent = i;
    if (i === currentPage) btn.classList.add("active");
    btn.onclick = () => onPageChange(i);
    container.appendChild(btn);
  }

  const nextBtn = document.createElement("button");
  nextBtn.textContent = "次へ";
  nextBtn.disabled = currentPage === totalPages;
  nextBtn.onclick = () => onPageChange(currentPage + 1);
  container.appendChild(nextBtn);
}
