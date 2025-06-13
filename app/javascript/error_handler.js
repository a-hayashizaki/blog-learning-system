// Comprehensive error handler to suppress CSS injection errors from browser extensions or external scripts
(function() {
  'use strict';
  
  // Override console.error to filter out known third-party errors
  const originalConsoleError = console.error;
  console.error = function(...args) {
    const errorString = args.join(' ');
    if (errorString.includes('insertRule') || 
        errorString.includes('content.js') ||
        errorString.includes('Cannot read properties of null') ||
        errorString.includes('message port closed') ||
        errorString.includes('runtime.lastError')) {
      console.warn('Suppressed third-party error:', errorString);
      return;
    }
    originalConsoleError.apply(console, args);
  };
  
  // Global error handler
  window.addEventListener('error', function(event) {
    if (event.error && event.error.message) {
      const message = event.error.message;
      if (message.includes('insertRule') || 
          message.includes('content.js') ||
          event.filename && event.filename.includes('content.js')) {
        console.warn('Suppressed CSS error from external source:', message);
        event.preventDefault();
        event.stopPropagation();
        return false;
      }
    }
  }, true);
  
  // Handle unhandled promise rejections
  window.addEventListener('unhandledrejection', function(event) {
    if (event.reason && event.reason.message) {
      const message = event.reason.message;
      if (message.includes('insertRule') || message.includes('content.js')) {
        console.warn('Suppressed promise rejection from external source:', message);
        event.preventDefault();
      }
    }
  });
  
  // Additional protection for DOM manipulation
  const originalCreateElement = document.createElement;
  document.createElement = function(tagName) {
    const element = originalCreateElement.call(this, tagName);
    if (tagName.toLowerCase() === 'style') {
      const originalSheet = Object.getOwnPropertyDescriptor(HTMLStyleElement.prototype, 'sheet');
      if (originalSheet) {
        Object.defineProperty(element, 'sheet', {
          get: function() {
            try {
              return originalSheet.get.call(this);
            } catch (e) {
              console.warn('Suppressed stylesheet access error:', e.message);
              return null;
            }
          }
        });
      }
    }
    return element;
  };
})();