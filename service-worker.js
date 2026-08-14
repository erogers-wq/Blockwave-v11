/* =============================================================
   Blockwave service worker — SELF-UNINSTALLING
   -------------------------------------------------------------
   A previously cached build was preventing updates from being
   seen. This version does the opposite of caching: it clears
   every cache, unregisters itself, and reloads open tabs so the
   fresh page is fetched from the server.

   Offline play can be restored later once things are stable.
   ============================================================= */
self.addEventListener("install", () => self.skipWaiting());

self.addEventListener("activate", event => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.map(k => caches.delete(k)));
    await self.registration.unregister();
    const clients = await self.clients.matchAll({ type: "window" });
    clients.forEach(c => c.navigate(c.url));      // pull the new page in
  })());
});

// Never serve from cache while this build is live.
self.addEventListener("fetch", event => {
  event.respondWith(fetch(event.request));
});
