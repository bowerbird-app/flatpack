// Theme Initialization Script
// Place this inline in <head> to prevent flash of wrong theme
// 
// Usage in layout:
// <script><%= File.read(Rails.root.join("app/javascript/flat_pack/theme_init.js")) %></script>
//
// Or as inline script:
// <script>
//   (function() {
//     const theme = localStorage.getItem('flatpack-theme') || 'auto';
//     const isDark = theme === 'dark' || 
//       (theme === 'auto' && matchMedia('(prefers-color-scheme: dark)').matches);
//     document.documentElement.classList.add(isDark ? 'dark' : 'light');
//   })();
// </script>

(function() {
  // Get saved theme preference or default to 'auto'
  const theme = localStorage.getItem('flatpack-theme') || 'auto';
  
  // Determine if dark mode should be applied
  const isDark = theme === 'dark' || 
    (theme === 'auto' && matchMedia('(prefers-color-scheme: dark)').matches);
  
  // Apply theme class immediately to prevent flash
  document.documentElement.classList.add(isDark ? 'dark' : 'light');
})();
