if ('serviceWorker' in navigator) {
  navigator.serviceWorker.register('/service-worker.js').then(registration => {
    // Check if there's an update waiting
    if (registration.waiting) {
      notifyUpdate(registration);
    }

    // Listen for new workers
    registration.addEventListener('updatefound', () => {
      const newWorker = registration.installing;
      newWorker.addEventListener('statechange', () => {
        if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
          notifyUpdate(registration);
        }
      });
    });
  });
}

function notifyUpdate(registration) {
  // Create a simple banner
  const banner = document.createElement('div');
  banner.style.cssText = `
    position: fixed; bottom: 0; left: 0; right: 0;
    background: #ffc107; color: #000; padding: 10px;
    text-align: center; font-weight: bold; z-index: 9999;
  `;
  banner.textContent = 'A new version is available. Tap to update.';
  banner.addEventListener('click', () => {
    registration.waiting.postMessage({ type: 'SKIP_WAITING' });
    window.location.reload();
  });
  document.body.appendChild(banner);
}
