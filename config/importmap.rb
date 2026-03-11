# frozen_string_literal: true

# Configure importmap for FlatPack components
pin_all_from File.expand_path("../app/javascript/flat_pack/controllers", __dir__), under: "controllers/flat_pack", to: "flat_pack/controllers", preload: false

# Third-party dependencies
pin "apexcharts", to: "https://cdn.jsdelivr.net/npm/apexcharts@3.45.1/dist/apexcharts.esm.js"
pin "@tiptap/core", to: "https://esm.sh/@tiptap/core?bundle"
pin "@tiptap/starter-kit", to: "https://esm.sh/@tiptap/starter-kit?bundle"
pin "@tiptap/extension-placeholder", to: "https://esm.sh/@tiptap/extension-placeholder?bundle"
pin "@tiptap/extension-character-count", to: "https://esm.sh/@tiptap/extension-character-count?bundle"
pin "@tiptap/extension-link", to: "https://esm.sh/@tiptap/extension-link?bundle"
pin "@tiptap/extension-underline", to: "https://esm.sh/@tiptap/extension-underline?bundle"
pin "@tiptap/extension-highlight", to: "https://esm.sh/@tiptap/extension-highlight?bundle"
pin "@tiptap/extension-text-style", to: "https://esm.sh/@tiptap/extension-text-style?bundle"
pin "@tiptap/extension-color", to: "https://esm.sh/@tiptap/extension-color?bundle"
pin "@tiptap/extension-text-align", to: "https://esm.sh/@tiptap/extension-text-align?bundle"
pin "@tiptap/extension-bubble-menu", to: "https://esm.sh/@tiptap/extension-bubble-menu?bundle"
pin "@tiptap/extension-floating-menu", to: "https://esm.sh/@tiptap/extension-floating-menu?bundle"
pin "@tiptap/extension-task-list", to: "https://esm.sh/@tiptap/extension-task-list?bundle"
pin "@tiptap/extension-task-item", to: "https://esm.sh/@tiptap/extension-task-item?bundle"
pin "@tiptap/extension-image", to: "https://esm.sh/@tiptap/extension-image?bundle"
pin "@tiptap/extension-table", to: "https://esm.sh/@tiptap/extension-table?bundle"
pin "@tiptap/extension-table-row", to: "https://esm.sh/@tiptap/extension-table-row?bundle"
pin "@tiptap/extension-table-header", to: "https://esm.sh/@tiptap/extension-table-header?bundle"
pin "@tiptap/extension-table-cell", to: "https://esm.sh/@tiptap/extension-table-cell?bundle"
