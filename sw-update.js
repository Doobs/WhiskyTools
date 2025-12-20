

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




