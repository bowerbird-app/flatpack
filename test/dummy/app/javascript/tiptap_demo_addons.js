import { Image } from "@tiptap/extension-image"
import { registerTiptapAddon } from "flat_pack/tiptap/addon_registry"

registerTiptapAddon("tiptap-image", {
  extensions: ({ addonOptions }) => [
    Image.configure({
      inline: false,
      allowBase64: false,
      ...addonOptions,
    }),
  ],
})
