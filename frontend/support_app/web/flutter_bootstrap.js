// Flutter web bootstrap configuration
// This prevents external font loading and uses system fonts

(function () {
    'use strict';

    // Prevent external font loading
    const originalFetch = window.fetch;
    window.fetch = function (url, options) {
        if (typeof url === 'string' &&
            (url.includes('fonts.gstatic.com') || url.includes('www.gstatic.com'))) {
            console.log('Blocking external font request:', url);
            return Promise.reject(new Error('External font loading blocked'));
        }
        return originalFetch(url, options);
    };

    // Override font loading
    if (window.FontFace) {
        const originalFontFace = window.FontFace;
        window.FontFace = function (family, source, descriptors) {
            if (source.includes('fonts.gstatic.com') || source.includes('www.gstatic.com')) {
                console.log('Blocking external font:', family, source);
                // Return a mock font that uses system fonts
                return new originalFontFace(family, 'local("system-ui")', descriptors);
            }
            return new originalFontFace(family, source, descriptors);
        };
    }

    // Load Flutter
    var scriptTag = document.createElement('script');
    scriptTag.src = 'main.dart.js';
    scriptTag.type = 'application/javascript';
    document.body.appendChild(scriptTag);
})();
