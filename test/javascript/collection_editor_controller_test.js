const test = require("node:test")
const assert = require("node:assert/strict")
const fs = require("node:fs")
const path = require("node:path")
const vm = require("node:vm")

function loadController(overrides = {}) {
  const filePath = path.join(__dirname, "..", "..", "app", "javascript", "flat_pack", "controllers", "collection_editor_controller.js")
  const source = fs.readFileSync(filePath, "utf8")
  const transformed = source
    .replace('import { Controller } from "@hotwired/stimulus"', "class Controller {}")
    .replace("export default class extends Controller", "class CollectionEditorController extends Controller") + "\nmodule.exports = CollectionEditorController\n"

  const context = {
    module: {exports: {}},
    exports: {},
    URL,
    URLSearchParams,
    AbortController,
    CustomEvent,
    window: {
      setTimeout(callback) { callback(); return 0 },
      clearTimeout() {},
      location: {origin: "http://example.test"}
    },
    document: {
      createElement() { return buildNode("div") },
      querySelector(selector) {
        if (selector === "meta[name='csrf-token']") return {content: "csrf-token"}
        return null
      }
    },
    ...overrides
  }

  vm.runInNewContext(transformed, context, {filename: filePath})
  return context.module.exports
}

function mark(node, attribute) {
  node.markers.add(attribute)
}

function buildNode(tag = "div") {
  const node = {
    tag,
    hidden: false,
    value: "",
    textContent: "",
    className: "",
    href: "",
    dataset: {},
    attrs: {},
    markers: new Set(),
    children: [],
    parentNode: null,
    events: [],
    focused: false,
    _html: "",
    setAttribute(name, value) { this.attrs[name] = String(value) },
    getAttribute(name) { return this.attrs[name] },
    removeAttribute(name) { delete this.attrs[name] },
    append(...nodes) {
      nodes.forEach((child) => {
        if (child.parentNode) {
          const index = child.parentNode.children.indexOf(child)
          if (index >= 0) child.parentNode.children.splice(index, 1)
        }
        child.parentNode = this
        this.children.push(child)
      })
    },
    replaceChildren() { this.children = [] },
    focus() { this.focused = true },
    remove() {
      if (!this.parentNode) return
      const index = this.parentNode.children.indexOf(this)
      if (index >= 0) this.parentNode.children.splice(index, 1)
      this.parentNode = null
    },
    closest(selector) {
      let current = this
      while (current) {
        if (matches(current, selector)) return current
        current = current.parentNode
      }
      return null
    },
    querySelector(selector) {
      return queryAll(this, selector)[0] || null
    },
    querySelectorAll(selector) {
      return queryAll(this, selector)
    },
    dispatchEvent(event) { this.events.push(event) },
    addEventListener() {},
    scrollIntoView() {}
  }

  Object.defineProperty(node, "innerHTML", {
    get() { return node._html },
    set(html) {
      node._html = html
      node.children = []
      if (!html.includes("data-collection-editor-row")) return
      const id = (html.match(/data-id="([^"]*)"/) || [])[1] || ""
      const row = buildRow({id})
      row.parentNode = node
      node.children.push(row)
    }
  })

  return node
}

function matches(node, selector) {
  const hiddenClause = selector.includes(":not([hidden])")
  const base = selector.replace(":not([hidden])", "")
  if (hiddenClause && node.hidden) return false
  if (base === "[role='option']" || base === '[role="option"]') return node.attrs.role === "option"
  const attribute = base.match(/^\[([^\]=]+)\]$/)
  if (!attribute) return false
  return node.markers.has(attribute[1])
}

function queryAll(root, selector) {
  const nodes = []
  const visit = (node) => {
    node.children.forEach((child) => {
      nodes.push(child)
      visit(child)
    })
  }
  visit(root)

  const parts = selector.split(/\s+/).filter(Boolean)
  return nodes.filter((node) => {
    if (!matches(node, parts[parts.length - 1])) return false
    let cursor = node.parentNode
    return parts.slice(0, -1).every((part) => {
      while (cursor) {
        if (matches(cursor, part)) {
          cursor = cursor.parentNode
          return true
        }
        cursor = cursor.parentNode
      }
      return false
    })
  })
}

function buildRow({id = "", persisted = false} = {}) {
  const row = buildNode("li")
  mark(row, "data-collection-editor-row")
  row.dataset.id = id
  row.dataset.persisted = persisted ? "true" : "false"
  row.dataset.searchParam = "q"
  row.dataset.createLabel = "Create"
  row.dataset.minSearchLength = "1"
  row.dataset.editUrlTemplate = "/people/:id/edit"

  const association = buildNode("input")
  mark(association, "data-collection-editor-association")
  const destroy = buildNode("input")
  mark(destroy, "data-collection-editor-destroy")
  const search = buildNode("input")
  mark(search, "data-collection-editor-search")
  const panel = buildNode("div")
  mark(panel, "data-collection-editor-panel")
  panel.hidden = true
  const summary = buildNode("div")
  mark(summary, "data-collection-editor-summary")
  summary.hidden = true
  const title = buildNode("p")
  mark(title, "data-collection-editor-title")
  const description = buildNode("p")
  mark(description, "data-collection-editor-description")
  const edit = buildNode("a")
  mark(edit, "data-collection-editor-edit")
  edit.hidden = true
  const change = buildNode("button")
  mark(change, "data-collection-editor-change")
  change.hidden = true
  const remove = buildNode("button")
  mark(remove, "data-collection-editor-remove")
  const handle = buildNode("button")
  mark(handle, "data-collection-editor-handle")
  const results = buildNode("div")
  mark(results, "data-collection-editor-results")
  const noResults = buildNode("p")
  mark(noResults, "data-collection-editor-no-results")
  noResults.hidden = true
  const searchError = buildNode("p")
  mark(searchError, "data-collection-editor-search-error")
  searchError.hidden = true
  const error = buildNode("p")
  mark(error, "data-collection-editor-create-error")
  error.hidden = true
  const fields = buildNode("div")
  mark(fields, "data-collection-editor-create-fields")
  fields.hidden = true
  const name = buildNode("input")
  mark(name, "data-create-field")
  mark(name, "data-fill-from-query")
  name.dataset.createField = "name"
  const email = buildNode("input")
  mark(email, "data-create-field")
  email.dataset.createField = "email"
  const label = buildNode("span")
  mark(label, "data-collection-editor-create-label")
  label.textContent = "Create"

  fields.append(name, email)
  summary.append(title, description, edit, change)
  panel.append(search, results, noResults, searchError, error, label, fields)
  row.append(association, destroy, panel, summary, remove, handle)
  return row
}

function harness(fetch) {
  const Controller = loadController({
    fetch,
    document: {
      createElement() { return buildNode("div") },
      querySelector(selector) {
        if (selector === "meta[name='csrf-token']") return {content: "csrf-token"}
        return null
      }
    }
  })
  const controller = new Controller()
  const element = buildNode("section")
  const list = buildNode("ul")
  const template = buildNode("template")
  const empty = buildNode("p")
  const addButton = buildNode("button")
  element.append(list, template, empty, addButton)
  controller.element = element
  controller.listTarget = list
  controller.templateTarget = template
  controller.emptyTarget = empty
  controller.addButtonTarget = addButton
  controller.hasListTarget = true
  controller.hasTemplateTarget = true
  controller.hasEmptyTarget = true
  controller.hasAddButtonTarget = true
  controller.templateIndexValue = "NEW_RECORD"
  template.innerHTML = '<li data-collection-editor-row="true" data-id="NEW_RECORD" data-persisted="false"></li>'
  return controller
}

test("add clones the template with a unique child index and focuses search", () => {
  const controller = harness()
  controller.add({preventDefault() {}})
  controller.add({preventDefault() {}})

  const rows = controller.listTarget.children
  assert.equal(rows.length, 2)
  rows.forEach((row) => {
    assert.match(row.dataset.id, /^\d+$/)
    assert.notEqual(row.dataset.id, "NEW_RECORD")
    assert.equal(row.querySelector("[data-collection-editor-search]").focused, true)
  })
  assert.notEqual(rows[0].dataset.id, rows[1].dataset.id)
  assert.equal(controller.emptyTarget.hidden, true)
})

test("remove marks a saved row for destruction and drops an unsaved row", () => {
  const controller = harness()
  const saved = buildRow({id: "12", persisted: true})
  const unsaved = buildRow({id: "new_1"})
  controller.listTarget.append(saved, unsaved)

  controller.remove({preventDefault() {}, target: saved})
  assert.equal(saved.querySelector("[data-collection-editor-destroy]").value, "1")
  assert.equal(saved.hidden, true)
  assert.equal(saved.dataset.collectionEditorDestroyed, "true")
  assert.equal(controller.listTarget.children.includes(saved), true)

  controller.remove({preventDefault() {}, target: unsaved})
  assert.equal(controller.listTarget.children.includes(unsaved), false)
  assert.equal(controller.addButtonTarget.focused, true)
})

test("local search selects a person and keeps the role field independent", async () => {
  const controller = harness()
  const row = buildRow()
  controller.listTarget.append(row)
  row.dataset.items = JSON.stringify([
    {id: "4", title: "Alice Chen", description: "alice@example.com"},
    {id: "8", title: "Daniel Lee", description: "daniel@example.com"}
  ])

  await controller.runSearch(row, "alice")
  const options = row.querySelectorAll("[data-collection-editor-results] [role='option']")
  assert.equal(options.length, 1)
  assert.equal(options[0].dataset.title, "Alice Chen")
  assert.equal(options[0].dataset.description, "alice@example.com")

  controller.searchKeydown({
    key: "Enter",
    preventDefault() {},
    target: row.querySelector("[data-collection-editor-search]")
  })

  assert.equal(row.querySelector("[data-collection-editor-association]").value, "4")
  assert.equal(row.querySelector("[data-collection-editor-title]").textContent, "Alice Chen")
  assert.equal(row.querySelector("[data-collection-editor-description]").textContent, "alice@example.com")
  assert.equal(row.querySelector("[data-collection-editor-description]").hidden, true)
  assert.equal(row.querySelector("[data-collection-editor-panel]").hidden, true)
  assert.equal(row.querySelector("[data-collection-editor-remove]").attrs["aria-label"], "Remove Alice Chen")
})

test("prompt create opens the fields and hides the prompt", () => {
  const controller = harness()
  const row = buildRow()
  const prompt = buildNode("button")
  mark(prompt, "data-collection-editor-create-button")
  row.querySelector("[data-collection-editor-panel]").append(prompt)
  controller.listTarget.append(row)
  row.querySelector("[data-collection-editor-search]").value = "Morgan Patel"

  controller.promptCreate({preventDefault() {}, target: prompt})

  assert.equal(row.querySelector("[data-collection-editor-create-fields]").hidden, false)
  assert.equal(prompt.hidden, true)
  assert.equal(row.querySelector("[data-fill-from-query]").value, "Morgan Patel")
})

test("create failure stays in the picker and does not set the association id", async () => {
  const calls = []
  const controller = harness(async (url, options) => {
    calls.push({url, options})
    return {ok: false, json: async () => ({ok: false, errors: ["Email can't be blank"]})}
  })
  const row = buildRow()
  row.dataset.createUrl = "/people"
  controller.listTarget.append(row)
  row.querySelector("[data-collection-editor-panel]").hidden = false
  row.querySelector("[data-fill-from-query]").value = "Morgan Patel"

  await controller.create({preventDefault() {}, target: row.querySelector("[data-collection-editor-search]")})

  assert.equal(calls.length, 1)
  assert.equal(calls[0].options.method, "POST")
  assert.match(calls[0].options.body, /name=Morgan\+Patel/)
  assert.equal(row.querySelector("[data-collection-editor-association]").value, "")
  assert.equal(row.querySelector("[data-collection-editor-create-error]").hidden, false)
  assert.match(row.querySelector("[data-collection-editor-create-error]").textContent, /Email can't be blank/)
  assert.equal(row.querySelector("[data-collection-editor-create-fields]").hidden, false)
  assert.equal(row.querySelector("[data-collection-editor-panel]").hidden, false)
})

test("create success writes the new person id and summary onto the join row", async () => {
  const controller = harness(async () => {
    return {
      ok: true,
      json: async () => ({ok: true, item: {id: "42", title: "Morgan Patel", description: "morgan@example.com"}})
    }
  })
  const row = buildRow()
  row.dataset.createUrl = "/people"
  controller.listTarget.append(row)
  const fields = row.querySelectorAll("[data-create-field]")
  fields[0].value = "Morgan Patel"
  fields[1].value = "morgan@example.com"

  await controller.create({preventDefault() {}, target: row})

  assert.equal(row.querySelector("[data-collection-editor-association]").value, "42")
  assert.equal(row.querySelector("[data-collection-editor-title]").textContent, "Morgan Patel")
  assert.equal(row.querySelector("[data-collection-editor-description]").textContent, "morgan@example.com")
  assert.equal(row.querySelector("[data-collection-editor-panel]").hidden, true)
  assert.equal(row.events[0].type, "collection-editor:selected")
  assert.equal(row.events[0].detail.id, "42")
})

test("enter with several matches does not select or open create", async () => {
  const controller = harness()
  const row = buildRow()
  row.dataset.createUrl = "/people"
  controller.listTarget.append(row)
  row.dataset.items = JSON.stringify([
    {id: "4", title: "Alice Chen", description: "alice@example.com"},
    {id: "5", title: "Alice Chen-Smith", description: "alice@studio.example"}
  ])

  await controller.runSearch(row, "alice")
  controller.searchKeydown({
    key: "Enter",
    preventDefault() {},
    target: row.querySelector("[data-collection-editor-search]")
  })

  assert.equal(row.querySelectorAll("[data-collection-editor-results] [role='option']").length, 2)
  assert.equal(row.querySelector("[data-collection-editor-association]").value, "")
  assert.equal(row.querySelector("[data-collection-editor-create-fields]").hidden, true)
})

test("enter with no matches opens create", async () => {
  const controller = harness()
  const row = buildRow()
  row.dataset.createUrl = "/people"
  controller.listTarget.append(row)

  await controller.runSearch(row, "morgan")
  assert.equal(row.querySelector("[data-collection-editor-results] [role='option']").textContent, "+ New")
  assert.equal(row.querySelectorAll("[data-collection-editor-results] [role='option']").length, 1)

  controller.searchKeydown({
    key: "Enter",
    preventDefault() {},
    target: row.querySelector("[data-collection-editor-search]")
  })

  assert.equal(row.querySelector("[data-collection-editor-association]").value, "")
  assert.equal(row.querySelector("[data-collection-editor-no-results]").hidden, false)
  assert.equal(row.querySelector("[data-collection-editor-create-fields]").hidden, false)
})

test("arrow keys point the combobox at the active result", async () => {
  const controller = harness()
  const row = buildRow()
  controller.listTarget.append(row)
  row.dataset.items = JSON.stringify([
    {id: "4", title: "Alice Chen", description: "alice@example.com"},
    {id: "5", title: "Alice Chen-Smith", description: "alice@studio.example"}
  ])

  await controller.runSearch(row, "alice")
  const input = row.querySelector("[data-collection-editor-search]")
  controller.searchKeydown({
    key: "ArrowDown",
    preventDefault() {},
    target: input
  })

  const options = row.querySelectorAll("[data-collection-editor-results] [role='option']")
  assert.equal(input.attrs["aria-activedescendant"], options[0].id)
  assert.equal(options[0].attrs["aria-selected"], "true")
  assert.equal(options[1].attrs["aria-selected"], "false")
})

test("search failure shows its own message", async () => {
  const controller = harness(async () => {
    throw new Error("offline")
  })
  const row = buildRow()
  row.dataset.searchUrl = "/people?q=alice"
  controller.listTarget.append(row)

  await controller.runSearch(row, "alice")

  assert.equal(row.querySelector("[data-collection-editor-search-error]").hidden, false)
  assert.equal(row.querySelector("[data-collection-editor-no-results]").hidden, true)
  assert.equal(row.querySelector("[data-collection-editor-association]").value, "")
})

test("create ignores a second submit while the first is in flight", async () => {
  let release
  const calls = []
  const controller = harness((url, options) => {
    calls.push({url, options})
    return new Promise((resolve) => {
      release = () => resolve({
        ok: true,
        json: async () => ({ok: true, item: {id: "42", title: "Morgan Patel", description: "morgan@example.com"}})
      })
    })
  })
  const row = buildRow()
  row.dataset.createUrl = "/people"
  controller.listTarget.append(row)

  const first = controller.create({preventDefault() {}, target: row})
  await controller.create({preventDefault() {}, target: row})
  assert.equal(calls.length, 1)
  release()
  await first
  assert.equal(row.querySelector("[data-collection-editor-association]").value, "42")
})

test("template index replacement leaves visible text alone", () => {
  const controller = harness()
  const html = '<label for="role_NEW_RECORD">Role</label><input name="project[project_people_attributes][NEW_RECORD][role]" id="role_NEW_RECORD" value="NEW_RECORD"><div data-results-id="fp-collection-editor-demo_project_project_people_attributes_NEW_RECORD_person_id-results"></div><p>Code NEW_RECORD</p>'
  const replaced = controller.replaceTemplateIndex(html, "NEW_RECORD", "42")

  assert.match(replaced, /name="project\[project_people_attributes\]\[42\]\[role\]"/)
  assert.match(replaced, /id="role_42"/)
  assert.match(replaced, /for="role_42"/)
  assert.match(replaced, /data-results-id="fp-collection-editor-demo_project_project_people_attributes_42_person_id-results"/)
  assert.match(replaced, /value="NEW_RECORD"/)
  assert.match(replaced, /<p>Code NEW_RECORD<\/p>/)
})

test("reorder announcement names the row and the position", () => {
  const controller = harness()
  const status = buildNode("p")
  controller.statusTarget = status
  controller.hasStatusTarget = true
  const row = buildRow({id: "12"})
  row.dataset.id = "12"
  row.querySelector("[data-collection-editor-title]").textContent = "Alice Chen"
  controller.listTarget.append(row)

  controller.announceReorder({detail: {id: "12", position: 2}})

  assert.equal(status.textContent, "Moved Alice Chen to position 2")
})
