

// sw-update.js
if ('serviceWorker' in navigator) {
    navigator.serviceWorker.addEventListener('controllerchange', () => {
        // When the new service worker takes control, reload the page
        window.location.reload();
    });

    navigator.serviceWorker.register('./service-worker.js')
        .then(reg => {
            // If there's an update waiting, tell it to activate immediately
            if (reg.waiting) {
                reg.waiting.postMessage({ type: 'SKIP_WAITING' });
            }

            // If a new worker is found, tell it to activate immediately
            reg.addEventListener('updatefound', () => {
                const newWorker = reg.installing;
                if (newWorker) {
                    newWorker.addEventListener('statechange', () => {
                        if (newWorker.state === 'installed' && navigator.serviceWorker.controller) {
                            newWorker.postMessage({ type: 'SKIP_WAITING' });
                        }
                    });
                }
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
