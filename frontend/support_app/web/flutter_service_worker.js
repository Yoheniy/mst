// This is a service worker for the Flutter web app.
// It intercepts network requests and caches resources for offline use.

const CACHE_NAME = 'flutter-app-cache-v1';
const urlsToCache = [
    './',
    './index.html',
    './flutter_bootstrap.js',
    './main.dart.js',
    './manifest.json'
];

// Install event - cache resources
self.addEventListener('install', event => {
    event.waitUntil(
        caches.open(CACHE_NAME)
            .then(cache => cache.addAll(urlsToCache))
    );
});

// Fetch event - serve from cache, prevent external font loading
self.addEventListener('fetch', event => {
    // Block external font requests
    if (event.request.url.includes('fonts.gstatic.com') ||
        event.request.url.includes('www.gstatic.com')) {
        event.respondWith(new Response('', { status: 404 }));
        return;
    }

    event.respondWith(
        caches.match(event.request)
            .then(response => {
                // Return cached version or fetch from network
                return response || fetch(event.request);
            })
    );
});

// Activate event - clean up old caches
self.addEventListener('activate', event => {
    event.waitUntil(
        caches.keys().then(cacheNames => {
            return Promise.all(
                cacheNames.map(cacheName => {
                    if (cacheName !== CACHE_NAME) {
                        return caches.delete(cacheName);
                    }
                })
            );
        })
    );
});
