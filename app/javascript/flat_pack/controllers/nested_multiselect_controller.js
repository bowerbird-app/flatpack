import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static values = {
    options: Array,
    selected: Array,
    inputName: String
  }

  connect() {
    this.instanceId ||= Math.random().toString(36).slice(2)
    this.selected = new Set(this.selectedValue || [])
    this.normalizeSelectedValues()
    this.render()
  }

  render() {
    const container = document.createElement("div")
    container.className = "space-y-3 rounded-[var(--radius-lg)] border border-[var(--surface-border-color)] bg-[var(--surface-background-color)] p-4 text-[var(--surface-content-color)]"

    this.normalizedOptions().forEach((parent) => {
      container.appendChild(this.renderParent(parent))
    })

    this.hiddenInputsElement = document.createElement("div")
    this.hiddenInputsElement.hidden = true

    this.element.replaceChildren(container, this.hiddenInputsElement)
    this.updateHiddenInputs()
  }

  renderParent(parent) {
    const wrapper = document.createElement("div")
    wrapper.className = "space-y-2"

    wrapper.appendChild(this.renderCheckboxRow({
      id: parent.id,
      label: parent.label,
      checked: this.isParentChecked(parent),
      indeterminate: this.isParentIndeterminate(parent),
      classes: "font-medium",
      onChange: (event) => {
        this.setParentSelected(parent, event.currentTarget.checked)
        this.render()
      },
      dataset: { parentId: parent.id }
    }))

    if (parent.children.length > 0) {
      const childWrapper = document.createElement("div")
      childWrapper.className = "ml-6 space-y-2 border-l border-[var(--surface-border-color)] pl-4"

      parent.children.forEach((child) => {
        childWrapper.appendChild(this.renderCheckboxRow({
          id: child.id,
          label: child.label,
          checked: this.selected.has(child.id),
          classes: "text-sm",
          onChange: (event) => {
            this.setChildSelected(parent, child, event.currentTarget.checked)
            this.render()
          },
          dataset: { parentId: parent.id, childId: child.id }
        }))
      })

      wrapper.appendChild(childWrapper)
    }

    return wrapper
  }

  renderCheckboxRow({ id, label, checked, indeterminate = false, classes, onChange, dataset }) {
    const labelElement = document.createElement("label")
    labelElement.className = `flex cursor-pointer items-center gap-2 rounded-[var(--radius-md)] px-2 py-1.5 transition-colors hover:bg-[var(--surface-muted-background-color)] ${classes}`
    labelElement.htmlFor = this.checkboxId(id)

    const checkbox = document.createElement("input")
    checkbox.id = this.checkboxId(id)
    checkbox.type = "checkbox"
    checkbox.checked = checked
    checkbox.indeterminate = indeterminate
    checkbox.className = "h-4 w-4 rounded border-[var(--surface-border-color)] text-[var(--color-primary)] accent-[var(--color-primary)] focus:ring-2 focus:ring-inset focus:ring-[var(--color-primary)] focus:ring-offset-2"
    Object.entries(dataset).forEach(([key, value]) => {
      checkbox.dataset[key] = value
    })
    checkbox.addEventListener("change", onChange)

    const text = document.createElement("span")
    text.textContent = label

    labelElement.appendChild(checkbox)
    labelElement.appendChild(text)

    return labelElement
  }

  setParentSelected(parent, checked) {
    if (checked) {
      this.selected.add(parent.id)
      parent.children.forEach((child) => this.selected.add(child.id))
      return
    }

    this.selected.delete(parent.id)
    parent.children.forEach((child) => this.selected.delete(child.id))
  }

  setChildSelected(parent, child, checked) {
    if (checked) {
      this.selected.add(child.id)
    } else {
      this.selected.delete(child.id)
    }

    this.syncParentSelection(parent)
  }

  syncParentSelection(parent) {
    if (parent.children.length === 0) {
      return
    }

    if (parent.children.every((child) => this.selected.has(child.id))) {
      this.selected.add(parent.id)
    } else {
      this.selected.delete(parent.id)
    }
  }

  normalizeSelectedValues() {
    this.normalizedOptions().forEach((parent) => {
      if (this.selected.has(parent.id)) {
        parent.children.forEach((child) => this.selected.add(child.id))
      }

      this.syncParentSelection(parent)
    })
  }

  updateHiddenInputs() {
    if (!this.hiddenInputsElement || !this.hasInputNameValue) {
      return
    }

    this.hiddenInputsElement.replaceChildren()
    this.selectedValues().forEach((value) => {
      const input = document.createElement("input")
      input.type = "hidden"
      input.name = this.inputNameValue
      input.value = value
      this.hiddenInputsElement.appendChild(input)
    })
  }

  isParentChecked(parent) {
    if (parent.children.length === 0) {
      return this.selected.has(parent.id)
    }

    return parent.children.every((child) => this.selected.has(child.id))
  }

  isParentIndeterminate(parent) {
    if (parent.children.length === 0) {
      return false
    }

    const selectedChildren = parent.children.filter((child) => this.selected.has(child.id))
    return selectedChildren.length > 0 && selectedChildren.length < parent.children.length
  }

  selectedValues() {
    const orderedValues = []

    this.normalizedOptions().forEach((parent) => {
      if (this.selected.has(parent.id)) {
        orderedValues.push(parent.id)
      }

      parent.children.forEach((child) => {
        if (this.selected.has(child.id)) {
          orderedValues.push(child.id)
        }
      })
    })

    this.selected.forEach((value) => {
      if (!orderedValues.includes(value)) {
        orderedValues.push(value)
      }
    })

    return orderedValues
  }

  normalizedOptions() {
    const options = this.hasOptionsValue ? this.optionsValue : []

    if (!Array.isArray(options)) {
      return []
    }

    return options.map((parent) => {
      const id = String(parent?.id || "")
      const children = Array.isArray(parent?.children) ? parent.children : []

      return {
        id,
        label: String(parent?.label || id),
        children: children.map((child) => {
          const childId = String(child?.id || "")

          return {
            id: childId,
            label: String(child?.label || childId)
          }
        }).filter((child) => child.id !== "")
      }
    }).filter((parent) => parent.id !== "")
  }

  checkboxId(id) {
    return `flat-pack-nested-multiselect-${this.instanceId}-${id.replaceAll(/[^a-zA-Z0-9_-]/g, "-")}`
  }
}
