const CACHE = 'balance-sheet-cache-v2';
const ASSETS = [
    './',
    './balance-sheet.html',
    './manifest.json',
    // icons may be added here if present
];

self.addEventListener('install', (event) => {
    event.waitUntil(
        caches.open(CACHE).then((cache) => cache.addAll(ASSETS))
    );
});

self.addEventListener('fetch', (event) => {
    const req = event.request;
    if (req.method !== 'GET') return;
    event.respondWith(
        caches.match(req).then((cached) => {
            return (
                cached ||
                fetch(req)
                    .then((resp) => {
                        const clone = resp.clone();
                        caches.open(CACHE).then((cache) => cache.put(req, clone));
                        return resp;
                    })
                    .catch(() => caches.match('./balance-sheet.html'))
            );
        })
    );
});

self.addEventListener('activate', (event) => {
    event.waitUntil(
        caches.keys().then((names) =>
            Promise.all(names.map((n) => (n === CACHE ? undefined : caches.delete(n))))
        )
    );
});