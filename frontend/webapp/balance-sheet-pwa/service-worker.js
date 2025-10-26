const CACHE = 'balance-sheet-cache-v2';
const ASSETS = [ './', './balance-sheet.html', './manifest.json' ];

self.addEventListener('install', (event) => {
  event.waitUntil(caches.open(CACHE).then((c) => c.addAll(ASSETS)));
});

self.addEventListener('fetch', (event) => {
  const req = event.request; if (req.method !== 'GET') return;
  event.respondWith(
    caches.match(req).then((cached) => cached || fetch(req).then((resp) => {
      const clone = resp.clone(); caches.open(CACHE).then((c) => c.put(req, clone)); return resp;
    }).catch(() => caches.match('./balance-sheet.html')))
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(caches.keys().then((keys) => Promise.all(keys.map(k => k===CACHE?undefined:caches.delete(k)))));
});