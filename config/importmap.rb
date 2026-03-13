# frozen_string_literal: true

# Configure importmap for FlatPack components
pin_all_from File.expand_path("../app/javascript/flat_pack/controllers", __dir__), under: "controllers/flat_pack", to: "flat_pack/controllers", preload: false
pin_all_from File.expand_path("../app/javascript/flat_pack/tiptap", __dir__), under: "flat_pack/tiptap", to: "flat_pack/tiptap", preload: false

# Heroicons curated subset — served as a local JS module, no gem required
pin "flat_pack/heroicons", to: "flat_pack/heroicons.js", preload: false

# Third-party dependencies
pin "apexcharts", to: "https://cdn.jsdelivr.net/npm/apexcharts@3.45.1/dist/apexcharts.esm.js"

# ── TipTap Rich Text Editor ───────────────────────────────────────────────────
# All packages are pinned from esm.sh. Using consistent versions ensures that
# shared ProseMirror state (prosemirror-state, prosemirror-view, etc.) is
# deduplicated via the browser module cache.
#
# Minimal preset: @tiptap/core, starter-kit, bubble-menu, placeholder,
#   character-count, link, underline, text-align
# Content preset: + highlight, text-style, color, typography, image,
#   code-block-lowlight, task-list, task-item, table extensions
# Full preset:    + subscript, superscript, font-family, mention, youtube,
#   audio, details, trailing-node, unique-id, focus, list-keymap,
#   collaboration, collaboration-cursor, drag-handle
#   (some may require TipTap Pro — see docs/components/inputs.md)
#
# ── Framework-specific TipTap wrappers ───────────────────────────────────────
# @tiptap-ui/react and @tiptap-ui/vue (Drag Handle React / Vue etc.) are NOT
# pinned. FlatPack uses the vanilla @tiptap/extension-drag-handle directly.
# React/Vue wrappers are not applicable to a Rails + Stimulus integration.

# Version must match what esm.sh resolves for internal ^range imports.
# To find the correct value: curl -s 'https://esm.sh/@tiptap/core@^2.x.x' | head -1
TIPTAP_VERSION = "2.27.2"

# Core
pin "@tiptap/core", to: "https://esm.sh/@tiptap/core@#{TIPTAP_VERSION}"
pin "@tiptap/starter-kit", to: "https://esm.sh/@tiptap/starter-kit@#{TIPTAP_VERSION}"

# Menus (vanilla JS positioning via TipTap's extension system)
pin "@tiptap/extension-bubble-menu", to: "https://esm.sh/@tiptap/extension-bubble-menu@#{TIPTAP_VERSION}"
pin "@tiptap/extension-floating-menu", to: "https://esm.sh/@tiptap/extension-floating-menu@#{TIPTAP_VERSION}"

# Minimal preset extensions
pin "@tiptap/extension-placeholder", to: "https://esm.sh/@tiptap/extension-placeholder@#{TIPTAP_VERSION}"
pin "@tiptap/extension-character-count", to: "https://esm.sh/@tiptap/extension-character-count@#{TIPTAP_VERSION}"
pin "@tiptap/extension-link", to: "https://esm.sh/@tiptap/extension-link@#{TIPTAP_VERSION}"
pin "@tiptap/extension-underline", to: "https://esm.sh/@tiptap/extension-underline@#{TIPTAP_VERSION}"
pin "@tiptap/extension-text-align", to: "https://esm.sh/@tiptap/extension-text-align@#{TIPTAP_VERSION}"

# lowlight — syntax highlighting for CodeBlockLowlight (content/full presets)
pin "lowlight", to: "https://esm.sh/lowlight@3"

# Content preset extensions
pin "@tiptap/extension-highlight", to: "https://esm.sh/@tiptap/extension-highlight@#{TIPTAP_VERSION}"
pin "@tiptap/extension-text-style", to: "https://esm.sh/@tiptap/extension-text-style@#{TIPTAP_VERSION}"
pin "@tiptap/extension-color", to: "https://esm.sh/@tiptap/extension-color@#{TIPTAP_VERSION}"
pin "@tiptap/extension-typography", to: "https://esm.sh/@tiptap/extension-typography@#{TIPTAP_VERSION}"
pin "@tiptap/extension-image", to: "https://esm.sh/@tiptap/extension-image@#{TIPTAP_VERSION}"
pin "@tiptap/extension-code-block-lowlight", to: "https://esm.sh/@tiptap/extension-code-block-lowlight@#{TIPTAP_VERSION}"
pin "@tiptap/extension-task-list", to: "https://esm.sh/@tiptap/extension-task-list@#{TIPTAP_VERSION}"
pin "@tiptap/extension-task-item", to: "https://esm.sh/@tiptap/extension-task-item@#{TIPTAP_VERSION}"
pin "@tiptap/extension-table", to: "https://esm.sh/@tiptap/extension-table@#{TIPTAP_VERSION}"
pin "@tiptap/extension-table-row", to: "https://esm.sh/@tiptap/extension-table-row@#{TIPTAP_VERSION}"
pin "@tiptap/extension-table-cell", to: "https://esm.sh/@tiptap/extension-table-cell@#{TIPTAP_VERSION}"
pin "@tiptap/extension-table-header", to: "https://esm.sh/@tiptap/extension-table-header@#{TIPTAP_VERSION}"

# Full preset extensions
pin "@tiptap/extension-subscript", to: "https://esm.sh/@tiptap/extension-subscript@#{TIPTAP_VERSION}"
pin "@tiptap/extension-superscript", to: "https://esm.sh/@tiptap/extension-superscript@#{TIPTAP_VERSION}"
pin "@tiptap/extension-font-family", to: "https://esm.sh/@tiptap/extension-font-family@#{TIPTAP_VERSION}"
pin "@tiptap/extension-mention", to: "https://esm.sh/@tiptap/extension-mention@#{TIPTAP_VERSION}"
pin "@tiptap/extension-youtube", to: "https://esm.sh/@tiptap/extension-youtube@#{TIPTAP_VERSION}"
pin "@tiptap/extension-details", to: "https://esm.sh/@tiptap/extension-details@#{TIPTAP_VERSION}"
pin "@tiptap/extension-details-content", to: "https://esm.sh/@tiptap/extension-details-content@#{TIPTAP_VERSION}"
pin "@tiptap/extension-details-summary", to: "https://esm.sh/@tiptap/extension-details-summary@#{TIPTAP_VERSION}"
pin "@tiptap/extension-unique-id", to: "https://esm.sh/@tiptap/extension-unique-id@#{TIPTAP_VERSION}"
pin "@tiptap/extension-focus", to: "https://esm.sh/@tiptap/extension-focus@#{TIPTAP_VERSION}"
pin "@tiptap/extension-list-keymap", to: "https://esm.sh/@tiptap/extension-list-keymap@#{TIPTAP_VERSION}"
pin "@tiptap/extension-collaboration", to: "https://esm.sh/@tiptap/extension-collaboration@#{TIPTAP_VERSION}"
pin "@tiptap/extension-collaboration-cursor", to: "https://esm.sh/@tiptap/extension-collaboration-cursor@#{TIPTAP_VERSION}"
pin "@tiptap/extension-drag-handle", to: "https://esm.sh/@tiptap/extension-drag-handle@#{TIPTAP_VERSION}"
# Optional / Pro packages (loaded dynamically; gracefully skipped if unavailable)
pin "@tiptap/extension-mathematics", to: "https://esm.sh/@tiptap/extension-mathematics@#{TIPTAP_VERSION}"
pin "@tiptap/extension-emoji", to: "https://esm.sh/@tiptap/extension-emoji@#{TIPTAP_VERSION}"
pin "@tiptap/extension-invisible-characters", to: "https://esm.sh/@tiptap/extension-invisible-characters@#{TIPTAP_VERSION}"
pin "@tiptap/extension-table-of-contents", to: "https://esm.sh/@tiptap/extension-table-of-contents@#{TIPTAP_VERSION}"
# Twitch embeds (may not be published as a standalone @tiptap package;
# implement via custom extension if needed — see docs/components/inputs.md)
# pin "@tiptap/extension-twitch", to: ...
