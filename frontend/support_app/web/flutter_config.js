// Flutter web configuration
// This prevents external font loading and uses system fonts

window.flutterConfiguration = {
    // Disable external font loading
    fontLoading: {
      googleFonts: false,
      systemFonts: true
    },
    
    // Use system fonts
    fonts: {
      default: 'system-ui, -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif'
    },
    
    // Prevent external requests
    network: {
      blockExternalFonts: true,
      allowedDomains: ['localhost', '127.0.0.1']
    }
  };
  
  // Override fetch to block external font requests
  const originalFetch = window.fetch;
  window.fetch = function(url, options) {
    if (typeof url === 'string' && 
        (url.includes('fonts.gstatic.com') || url.includes('www.gstatic.com'))) {
      console.log('Blocking external font request:', url);
      return Promise.reject(new Error('External font loading blocked'));
    }
    return originalFetch(url, options);
  };
  
  // Override FontFace constructor
  if (window.FontFace) {
    const originalFontFace = window.FontFace;
    window.FontFace = function(family, source, descriptors) {
      if (source.includes('fonts.gstatic.com') || source.includes('www.gstatic.com')) {
        console.log('Blocking external font:', family, source);
        // Return a mock font that uses system fonts
        return new originalFontFace(family, 'local("system-ui")', descriptors);
      }
      return new originalFontFace(family, source, descriptors);
    };
  }