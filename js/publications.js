(() => {
  const root = document.querySelector('.publications');
  if (!root) return;
  const input = root.querySelector('#publication-filter');
  if (!input) return;
  root.querySelector('.publication-search').hidden = false;
  const years = [...root.querySelectorAll('.publication-year')];
  const entries = [...root.querySelectorAll('.publication-item')].map(element => ({
    element, text: element.textContent.toLowerCase().replace(/\s+/g, ' ')
  }));
  input.addEventListener('input', () => {
    const terms = input.value.trim().toLowerCase().split(/\s+/).filter(Boolean);
    entries.forEach(({element, text}) => { element.hidden = !terms.every(term => text.includes(term)); });
    years.forEach(year => {
      year.hidden = [...year.querySelectorAll('.publication-item')].every(item => item.hidden);
    });
    root.querySelector('.publication-empty').hidden = entries.some(({element}) => !element.hidden);
  });
})();
