import { updateCommandButtons } from "flat_pack/tiptap/commands"

export function createTipTapUiBridge(controller) {
  const applyMenuVisibility = (visible) => {
    if (!controller.hasBubbleMenuTarget) return

    controller.bubbleMenuTarget.classList.toggle("hidden", !visible)
    controller.bubbleMenuTarget.classList.toggle("flex", visible)
    controller.bubbleMenuTarget.setAttribute("data-flat-pack--tiptap-ui-visible", String(visible))
  }

  return {
    mount() {
      if (controller.hasUiRootTarget) {
        controller.uiRootTarget.dataset.flatPackTiptapUiMounted = "true"
        controller.uiRootTarget.dataset.flatPackTiptapUiTheme = controller.config.ui?.theme || "flatpack"
        controller.uiRootTarget.dataset.flatPackTiptapUiMode = controller.config.ui?.mode || "adaptive"
      }

      applyMenuVisibility(false)
    },

    refresh(editor, { fallbackMode = false, disabled = false } = {}) {
      if (controller.hasToolbarTarget) {
        updateCommandButtons(controller.toolbarTarget, editor, { disabled })
      }

      if (controller.hasBubbleMenuTarget) {
        updateCommandButtons(controller.bubbleMenuTarget, editor, { disabled })
      }

      if (controller.hasFloatingMenuTarget) {
        updateCommandButtons(controller.floatingMenuTarget, editor, { disabled })
      }

      if (fallbackMode) {
        this.updateFallbackSelectionState()
      }
    },

    updateFallbackSelectionState() {
      if (!controller.hasBubbleMenuTarget) return

      const selection = window.getSelection()
      const selectedText = selection?.toString()?.trim()
      const withinEditor = selection?.anchorNode && controller.editorTarget.contains(selection.anchorNode)

      applyMenuVisibility(Boolean(withinEditor && selectedText))
    },

    setMode(mode) {
      if (!controller.hasUiRootTarget) return

      controller.uiRootTarget.dataset.flatPackTiptapUiRuntime = mode
    },

    destroy() {
      if (controller.hasUiRootTarget) {
        delete controller.uiRootTarget.dataset.flatPackTiptapUiMounted
      }
    }
  }
}
