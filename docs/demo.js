const button = document.querySelector('#play');
const grid = document.querySelector('.demo-grid');
const status = document.querySelector('#demo-status');
button.hidden = false;
button.addEventListener('click', () => {
  const switched = grid.classList.toggle('switched');
  button.textContent = switched ? 'Switch back' : 'Try the switch';
  status.textContent = `Both examples now show Desktop ${switched ? '2' : '1'}. This is an illustration, not a recording or speed test.`;
});
