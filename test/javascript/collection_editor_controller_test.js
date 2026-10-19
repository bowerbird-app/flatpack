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
    .replace(
      'import { flatPackCopy } from "flat_pack/copy"',
      "const flatPackCopy = (key) => ({'collection_editor.already_joined': 'This image is already on this page', 'collection_editor.create_failed': 'Could not create the record', 'collection_editor.load_failed': 'Could not load the record', 'collection_editor.save_failed': 'Could not save the record'})[key] || key"
    )
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
  const classes = new Set()
  const node = {
    tag,
    id: "",
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
    classList: {
      add(...names) { names.forEach((name) => classes.add(name)) },
      remove(...names) { names.forEach((name) => classes.delete(name)) },
      contains(name) { return classes.has(name) },
      toggle(name, force) {
        const has = classes.has(name)
        const should = force === undefined ? !has : Boolean(force)
        if (should) classes.add(name)
        else classes.delete(name)
        return should
      }
    },
    setAttribute(name, value) {
      this.attrs[name] = String(value)
      if (name === "id") this.id = String(value)
    },
    getAttribute(name) { return this.attrs[name] },
    removeAttribute(name) { delete this.attrs[name] },
    contains(other) {
      let current = other
      while (current) {
        if (current === this) return true
        current = current.parentNode
      }
      return false
    },
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
    appendChild(child) {
      this.append(child)
      return child
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

  Object.defineProperty(node, "parentElement", {
    get() { return node.parentNode }
  })

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
  if (base === node.tag) return true
  if (base === "[role='option']" || base === '[role="option"]') return node.attrs.role === "option"
  const equals = base.match(/^\[([^\]=]+)=["']([^"']*)["']\]$/)
  if (equals) {
    const [, name, value] = equals
    if (node.attrs[name] === value) return true
    if (name.startsWith("data-")) {
      const key = name.slice(5).replace(/-([a-z])/g, (_, letter) => letter.toUpperCase())
      return node.dataset[key] === value
    }
    return false
  }
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

function findById(node, id) {
  if (!node) return null
  if (node.id === id || node.attrs?.id === id) return node

  for (const child of node.children || []) {
    const found = findById(child, id)
    if (found) return found
  }

  return null
}

function harness(fetch) {
  const page = {
    createElement() { return buildNode("div") },
    querySelector(selector) {
      if (selector === "meta[name='csrf-token']") return {content: "csrf-token"}
      return null
    },
    getElementById(id) {
      return findById(page.body, id)
    },
    body: null
  }
  page.body = buildNode("body")
  const Controller = loadController({
    fetch,
    document: page
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

test("prompt create opens the modal instead of the cell", () => {
  const controller = harness()
  const row = buildRow()
  const fields = row.querySelector("[data-collection-editor-create-fields]")
  const error = row.querySelector("[data-collection-editor-create-error]")
  const modal = buildNode("div")
  mark(modal, "data-collection-editor-create-modal")
  modal.id = "create-modal"
  modal.classList.add("hidden")
  modal.append(fields, error)
  const entity = buildNode("div")
  mark(entity, "data-create-modal-id")
  entity.setAttribute("data-create-modal-id", "create-modal")
  row.append(entity, modal)
  controller.listTarget.append(row)
  row.querySelector("[data-collection-editor-search]").value = "Morgan Patel"

  controller.promptCreate({preventDefault() {}, target: row.querySelector("[data-collection-editor-search]")})

  assert.equal(modal.parentNode.tag, "body")
  assert.equal(modal.classList.contains("hidden"), false)
  assert.equal(modal.classList.contains("flex"), true)
  assert.equal(fields.hidden, true)
  assert.equal(fields.querySelector("[data-fill-from-query]").value, "Morgan Patel")
  assert.equal(fields.querySelector("[data-create-field]").focused, true)
  assert.equal(row.contains(modal), false)
})

function attachCreateModal(row, id = "create-modal") {
  const fields = row.querySelector("[data-collection-editor-create-fields]")
  const error = row.querySelector("[data-collection-editor-create-error]")
  const modal = buildNode("div")
  mark(modal, "data-collection-editor-create-modal")
  modal.id = id
  modal.classList.add("hidden")
  modal.append(fields, error)
  const entity = buildNode("div")
  mark(entity, "data-create-modal-id")
  entity.setAttribute("data-create-modal-id", id)
  const submit = buildNode("button")
  mark(submit, "data-collection-editor-create-submit")
  modal.append(submit)
  row.append(entity, modal)
  return {modal, fields, error, submit, entity}
}

test("create failure stays in the modal and does not set the association id", async () => {
  const controller = harness(async () => {
    return {ok: false, json: async () => ({ok: false, errors: ["Email can't be blank"]})}
  })
  const row = buildRow()
  row.dataset.createUrl = "/people"
  const {modal, error} = attachCreateModal(row)
  controller.listTarget.append(row)
  controller.promptCreate({preventDefault() {}, target: row})

  await controller.create({preventDefault() {}, target: modal.querySelector("[data-collection-editor-create-submit]")})

  assert.equal(row.querySelector("[data-collection-editor-association]").value, "")
  assert.equal(error.hidden, false)
  assert.match(error.textContent, /Email can't be blank/)
  assert.equal(modal.classList.contains("flex"), true)
  assert.equal(modal.classList.contains("hidden"), false)
  assert.equal(modal.parentNode.tag, "body")
})

test("create success closes the modal and restores it to the row", async () => {
  const controller = harness(async () => {
    return {
      ok: true,
      json: async () => ({ok: true, item: {id: "42", title: "Morgan Patel", description: "morgan@example.com"}})
    }
  })
  const row = buildRow()
  row.dataset.createUrl = "/people"
  const {modal, fields, submit} = attachCreateModal(row)
  controller.listTarget.append(row)
  const inputs = fields.querySelectorAll("[data-create-field]")
  inputs[0].value = "Morgan Patel"
  inputs[1].value = "morgan@example.com"
  controller.promptCreate({preventDefault() {}, target: row})

  await controller.submitCreate({preventDefault() {}, target: submit})

  assert.equal(row.querySelector("[data-collection-editor-association]").value, "42")
  assert.equal(row.querySelector("[data-collection-editor-title]").textContent, "Morgan Patel")
  assert.equal(modal.classList.contains("hidden"), true)
  assert.equal(modal.classList.contains("flex"), false)
  assert.equal(row.contains(modal), true)
})

test("edit loads the person and save patches every chip with that id", async () => {
  const calls = []
  const controller = harness(async (url, options = {}) => {
    calls.push({url, method: options.method, body: options.body})
    if (options.method === "GET") {
      return {
        ok: true,
        json: async () => ({
          item: {id: "4", title: "Alice Chen", description: "alice@example.com"},
          fields: {name: "Alice Chen", email: "alice@example.com"}
        })
      }
    }
    return {
      ok: true,
      json: async () => ({ok: true, item: {id: "4", title: "Alice Chen-Smith", description: "alice@studio.example"}})
    }
  })
  const row = buildRow({id: "12", persisted: true})
  const other = buildRow({id: "13", persisted: true})
  row.dataset.updateUrl = "/people/:id"
  row.dataset.editTitle = "Edit Person"
  row.dataset.createTitle = "New Person"
  row.dataset.editLabel = "Edit"
  row.dataset.updateLabel = "Save"
  other.dataset.editLabel = "Edit"
  row.querySelector("[data-collection-editor-association]").value = "4"
  other.querySelector("[data-collection-editor-association]").value = "4"
  other.querySelector("[data-collection-editor-title]").textContent = "Alice Chen"
  const role = buildNode("select")
  role.value = "Designer"
  row.append(role)
  const {modal, submit} = attachCreateModal(row)
  const heading = buildNode("h2")
  mark(heading, "data-collection-editor-modal-title")
  heading.textContent = "New Person"
  const submitLabel = buildNode("span")
  submitLabel.textContent = "Create"
  submit.append(submitLabel)
  modal.append(heading)
  controller.listTarget.append(row, other)

  await controller.edit({preventDefault() {}, target: row.querySelector("[data-collection-editor-edit]")})

  assert.equal(calls[0].method, "GET")
  assert.equal(calls[0].url, "/people/4")
  const inputs = modal.querySelectorAll("[data-create-field]")
  assert.equal(inputs[0].value, "Alice Chen")
  assert.equal(inputs[1].value, "alice@example.com")
  assert.equal(heading.textContent, "Edit Person")
  assert.equal(submitLabel.textContent, "Save")
  assert.equal(modal.classList.contains("flex"), true)
  assert.equal(role.value, "Designer")

  inputs[0].value = "Alice Chen-Smith"
  inputs[1].value = "alice@studio.example"
  await controller.submitCreate({preventDefault() {}, target: submit})

  assert.equal(calls[1].method, "PATCH")
  assert.equal(calls[1].url, "/people/4")
  assert.match(calls[1].body, /name=Alice\+Chen-Smith/)
  assert.match(calls[1].body, /email=alice%40studio\.example/)
  assert.doesNotMatch(calls[1].body, /(^|&)q=/)
  assert.equal(row.querySelector("[data-collection-editor-association]").value, "4")
  assert.equal(row.querySelector("[data-collection-editor-title]").textContent, "Alice Chen-Smith")
  assert.equal(other.querySelector("[data-collection-editor-title]").textContent, "Alice Chen-Smith")
  assert.equal(row.querySelector("[data-collection-editor-edit]").attrs["aria-label"], "Edit Alice Chen-Smith")
  assert.equal(other.querySelector("[data-collection-editor-edit]").attrs["aria-label"], "Edit Alice Chen-Smith")
  assert.equal(role.value, "Designer")
  assert.equal(row.events.some((event) => event.type === "collection-editor:updated"), true)
  assert.equal(row.events.some((event) => event.type === "collection-editor:selected"), false)
  assert.equal(modal.classList.contains("hidden"), true)
})

test("edit save keeps the modal open when the person is invalid", async () => {
  const calls = []
  const controller = harness(async (url, options = {}) => {
    calls.push({url, method: options.method})
    if (options.method === "GET") {
      return {ok: true, json: async () => ({fields: {name: "Alice Chen", email: "alice@example.com"}})}
    }
    return {ok: false, json: async () => ({ok: false, errors: ["Email is invalid"]})}
  })
  const row = buildRow({id: "12", persisted: true})
  row.dataset.updateUrl = "/people/:id"
  row.dataset.editTitle = "Edit Person"
  row.querySelector("[data-collection-editor-association]").value = "4"
  row.querySelector("[data-collection-editor-title]").textContent = "Alice Chen"
  const {modal, error} = attachCreateModal(row)
  controller.listTarget.append(row)

  await controller.edit({preventDefault() {}, target: row})
  await controller.update({preventDefault() {}, target: modal})

  assert.equal(calls.map((call) => call.method).join(","), "GET,PATCH")
  assert.equal(row.querySelector("[data-collection-editor-association]").value, "4")
  assert.equal(row.querySelector("[data-collection-editor-title]").textContent, "Alice Chen")
  assert.equal(error.hidden, false)
  assert.match(error.textContent, /Email is invalid/)
  assert.equal(modal.classList.contains("flex"), true)
})

test("opening create after edit drops the loaded person and ignores a late load", async () => {
  let release
  const pending = new Promise((resolve) => {
    release = resolve
  })
  const calls = []
  const controller = harness((url, options = {}) => {
    calls.push(options.method || "GET")
    return pending
  })
  const row = buildRow({id: "12", persisted: true})
  row.dataset.updateUrl = "/people/:id"
  row.dataset.editTitle = "Edit Person"
  row.dataset.createTitle = "New Person"
  row.dataset.createLabel = "Create"
  row.querySelector("[data-collection-editor-association]").value = "4"
  row.querySelector("[data-collection-editor-search]").value = "Morgan Patel"
  const {modal, fields} = attachCreateModal(row)
  const heading = buildNode("h2")
  mark(heading, "data-collection-editor-modal-title")
  heading.textContent = "New Person"
  const submitLabel = buildNode("span")
  submitLabel.textContent = "Create"
  const submit = modal.querySelector("[data-collection-editor-create-submit]")
  submit.append(submitLabel)
  modal.append(heading)
  controller.listTarget.append(row)

  const editPromise = controller.edit({preventDefault() {}, target: row})
  assert.equal(submit.disabled, true)
  controller.promptCreate({preventDefault() {}, target: row})
  release({
    ok: true,
    json: async () => ({fields: {name: "Alice Chen", email: "alice@example.com"}})
  })
  await editPromise

  const inputs = fields.querySelectorAll("[data-create-field]")
  assert.equal(inputs[0].value, "Morgan Patel")
  assert.equal(inputs[1].value, "")
  assert.equal(heading.textContent, "New Person")
  assert.equal(submitLabel.textContent, "Create")
  assert.equal(submit.disabled, false)
  assert.equal(row.dataset.editorMode, "create")
  assert.deepEqual(calls, ["GET"])
  assert.equal(modal.classList.contains("flex"), true)
})

test("edit stays in the modal when the person cannot be loaded", async () => {
  const calls = []
  const controller = harness(async (url, options = {}) => {
    calls.push(options.method)
    return {ok: false, json: async () => ({ok: false, errors: ["Not found"]})}
  })
  const row = buildRow({id: "12", persisted: true})
  row.dataset.updateUrl = "/people/:id"
  row.querySelector("[data-collection-editor-association]").value = "4"
  const {modal, error} = attachCreateModal(row)
  controller.listTarget.append(row)

  await controller.edit({preventDefault() {}, target: row})
  await controller.submitCreate({preventDefault() {}, target: modal})

  assert.deepEqual(calls, ["GET"])
  assert.equal(error.hidden, false)
  assert.match(error.textContent, /Not found/)
  assert.equal(modal.classList.contains("flex"), true)
  assert.equal(modal.querySelector("[data-create-field]").value, "")
})

test("removing a row discards its portaled modal", () => {
  const controller = harness()
  const row = buildRow()
  const {modal} = attachCreateModal(row)
  controller.listTarget.append(row)
  controller.promptCreate({preventDefault() {}, target: row})
  assert.equal(modal.parentNode.tag, "body")

  controller.remove({preventDefault() {}, target: row})

  assert.equal(modal.parentNode, null)
  assert.equal(controller.listTarget.children.includes(row), false)
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
  const html = '<label for="role_NEW_RECORD">Role</label><input name="project[project_people_attributes][NEW_RECORD][role]" id="role_NEW_RECORD" value="NEW_RECORD"><div data-results-id="fp-collection-editor-demo_project_project_people_attributes_NEW_RECORD_person_id-results" data-create-modal-id="fp-collection-editor-demo_project_project_people_attributes_NEW_RECORD_person_id-create" data-library-modal-id="fp-collection-editor-demo_project_gallery_images_attributes_NEW_RECORD_image_id-library"></div><p>Code NEW_RECORD</p>'
  const replaced = controller.replaceTemplateIndex(html, "NEW_RECORD", "42")

  assert.match(replaced, /name="project\[project_people_attributes\]\[42\]\[role\]"/)
  assert.match(replaced, /id="role_42"/)
  assert.match(replaced, /for="role_42"/)
  assert.match(replaced, /data-results-id="fp-collection-editor-demo_project_project_people_attributes_42_person_id-results"/)
  assert.match(replaced, /data-create-modal-id="fp-collection-editor-demo_project_project_people_attributes_42_person_id-create"/)
  assert.match(replaced, /data-library-modal-id="fp-collection-editor-demo_project_gallery_images_attributes_42_image_id-library"/)
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

function attachImage(row, {modalId = "library-modal"} = {}) {
  const image = buildNode("div")
  mark(image, "data-collection-editor-image")
  mark(image, "data-library-modal-id")
  image.setAttribute("data-library-modal-id", modalId)

  const choose = buildNode("button")
  mark(choose, "data-collection-editor-image-choose")
  const placeholder = buildNode("span")
  mark(placeholder, "data-collection-editor-image-placeholder")
  const preview = buildNode("img")
  mark(preview, "data-collection-editor-image-preview")
  preview.hidden = true
  choose.append(placeholder, preview)

  const modal = buildNode("div")
  mark(modal, "data-collection-editor-library-modal")
  modal.id = modalId
  modal.classList.add("hidden")
  const search = buildNode("input")
  mark(search, "data-collection-editor-library-search")
  const empty = buildNode("p")
  mark(empty, "data-collection-editor-library-empty")
  empty.hidden = true
  const error = buildNode("p")
  mark(error, "data-collection-editor-library-error")
  error.hidden = true
  const grid = buildNode("div")
  mark(grid, "data-collection-editor-library")
  const create = buildNode("button")
  create.textContent = "+ New"
  modal.append(search, empty, error, grid, create)
  image.append(choose, modal)
  row.append(image)
  return {image, choose, placeholder, preview, modal, search, empty, error, grid, create}
}

test("choosing a library image sets the join id and thumbnail", async () => {
  const calls = []
  const controller = harness(async (url) => {
    calls.push(url)
    return {
      ok: true,
      json: async () => ({
        items: [{id: "9", title: "North window", description: "A north-facing window", thumbnail_url: "data:image/svg+xml,north"}]
      })
    }
  })
  const row = buildRow()
  row.dataset.searchUrl = "http://example.test/images"
  row.dataset.searchParam = "q"
  row.dataset.editLabel = "Edit"
  const {choose, placeholder, preview, modal, grid} = attachImage(row)
  controller.listTarget.append(row)

  await controller.loadLibrary(row, "north")

  assert.equal(calls[0], "http://example.test/images?q=north")
  assert.equal(grid.children.length, 1)
  assert.equal(grid.children[0].dataset.id, "9")
  assert.equal(grid.children[0].dataset.thumbnailUrl, "data:image/svg+xml,north")
  assert.equal(grid.children[0].children.at(-1).textContent, "North window")

  controller.applySelection(row, grid.children[0].dataset)

  assert.equal(row.querySelector("[data-collection-editor-association]").value, "9")
  assert.equal(preview.src, "data:image/svg+xml,north")
  assert.equal(preview.hidden, false)
  assert.equal(placeholder.hidden, true)
  assert.equal(choose.attrs["aria-label"], "Edit North window")
  assert.equal(choose.focused, true)
  assert.equal(modal.classList.contains("hidden"), true)
  assert.equal(row.events[0].detail.thumbnailUrl, "data:image/svg+xml,north")
})

test("choosing an image that is already joined focuses that row", () => {
  const controller = harness()
  const status = buildNode("p")
  controller.statusTarget = status
  controller.hasStatusTarget = true
  const joined = buildRow({id: "1", persisted: true})
  const incoming = buildRow({id: "2"})
  joined.dataset.editLabel = "Edit"
  const existing = attachImage(joined)
  const next = attachImage(incoming, {modalId: "library-modal-2"})
  joined.querySelector("[data-collection-editor-association]").value = "9"
  controller.listTarget.append(joined, incoming)
  controller.openLibrary({preventDefault() {}, target: next.choose})

  controller.applySelection(incoming, {id: "9", title: "North window", thumbnailUrl: "data:image/svg+xml,north"})

  assert.equal(incoming.querySelector("[data-collection-editor-association]").value, "")
  assert.equal(next.preview.hidden, true)
  assert.equal(existing.choose.focused, true)
  assert.equal(status.textContent, "This image is already on this page")
  assert.equal(next.modal.classList.contains("hidden"), true)
  assert.equal(incoming.events.length, 0)
})

test("a filled thumbnail with update_url loads the library record", async () => {
  const calls = []
  const controller = harness(async (url, options = {}) => {
    calls.push({url, method: options.method})
    return {
      ok: true,
      json: async () => ({
        item: {id: "9", title: "North window", thumbnail_url: "data:image/svg+xml,north"},
        fields: {name: "North window", alt_text: "A north-facing window"}
      })
    }
  })
  const row = buildRow({id: "3", persisted: true})
  row.dataset.updateUrl = "/images/:id"
  row.dataset.editTitle = "Edit Image"
  row.querySelector("[data-collection-editor-association]").value = "9"
  const {choose} = attachImage(row)
  const {modal, submit} = attachCreateModal(row, "image-create")
  const heading = buildNode("h2")
  mark(heading, "data-collection-editor-modal-title")
  modal.append(heading)
  const submitLabel = buildNode("span")
  submit.append(submitLabel)
  controller.listTarget.append(row)

  await controller.openImage({preventDefault() {}, target: choose})

  assert.equal(calls[0].method, "GET")
  assert.equal(calls[0].url, "/images/9")
  assert.equal(heading.textContent, "Edit Image")
  assert.equal(modal.querySelector("[data-create-field]").value, "North window")
})

test("an empty thumbnail opens the library and new creates from that search", () => {
  const controller = harness()
  const row = buildRow()
  row.dataset.items = JSON.stringify([
    {id: "4", title: "Lens", thumbnail_url: "data:image/svg+xml,lens"},
    {id: "5", title: "Night set", thumbnail_url: "data:image/svg+xml,night"}
  ])
  const {choose, modal, search, grid, create} = attachImage(row)
  controller.listTarget.append(row)

  controller.openImage({preventDefault() {}, target: choose})

  assert.equal(modal.parentNode.tag, "body")
  assert.equal(modal.classList.contains("flex"), true)
  assert.equal(grid.children.length, 2)
  assert.equal(search.focused, true)

  search.value = "Lens"
  controller.createFromLibrary({preventDefault() {}, target: create})

  assert.equal(modal.classList.contains("hidden"), true)
  assert.equal(row.contains(modal), true)
  assert.equal(row.querySelector("[data-fill-from-query]").value, "Lens")
  assert.equal(row.querySelector("[data-collection-editor-create-fields]").hidden, false)
})

test("library search enter does not submit the parent form", () => {
  const controller = harness()
  const row = buildRow()
  attachImage(row)
  controller.listTarget.append(row)
  let prevented = false

  controller.searchLibraryKeydown({
    key: "Enter",
    preventDefault() { prevented = true },
    target: row.querySelector("[data-collection-editor-library-search]")
  })

  assert.equal(prevented, true)
})
