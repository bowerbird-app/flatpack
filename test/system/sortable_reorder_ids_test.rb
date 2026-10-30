# frozen_string_literal: true

require "test_helper"

class SortableReorderIdsTest < ActionDispatch::SystemTestCase
  parallelize(workers: 1)

  driven_by :selenium, using: :headless_chrome, screen_size: [1280, 800] do |options|
    options.add_argument("--no-sandbox")
    options.add_argument("--disable-dev-shm-usage")
    options.add_argument("--disable-gpu")
  end

  test "table and grid reorder send uuid ids intact and integer ids as strings" do
    visit "/demo/cards"

    payload = page.evaluate_async_script(<<~JS)
      const done = arguments[0]
      const tableUuids = [
        "6f1e1a4a-1c2b-4d3e-8f90-111111111111",
        "6f1e1a4a-1c2b-4d3e-8f90-222222222222"
      ]
      const gridUuids = [
        "6f1e1a4a-1c2b-4d3e-8f90-333333333333",
        "6f1e1a4a-1c2b-4d3e-8f90-444444444444"
      ]

      function mountSortable(identifier, targetName, ids) {
        const root = document.createElement("div")
        root.setAttribute("data-controller", identifier)
        root.setAttribute(`data-${identifier}-reorder-url-value`, "/demo/tables/reorder")
        root.setAttribute(`data-${identifier}-resource-value`, "demo_table_rows")
        root.setAttribute(`data-${identifier}-strategy-value`, "dense_integer")
        root.setAttribute(`data-${identifier}-version-value`, "1")
        root.setAttribute(`data-${identifier}-scope-value`, '{"list_key":"users"}')

        ids.forEach((id) => {
          const item = document.createElement("div")
          item.setAttribute(`data-${identifier}-target`, targetName)
          item.dataset.id = id
          root.appendChild(item)
        })

        document.body.appendChild(root)
        return root
      }

      function readController(element, identifier) {
        const application = window.Stimulus
        if (!application) return null
        return application.getControllerForElementAndIdentifier(element, identifier)
      }

      async function controllerFor(element, identifier) {
        const started = Date.now()
        while (Date.now() - started < 8000) {
          const controller = readController(element, identifier)
          if (controller) return controller
          await new Promise((resolve) => setTimeout(resolve, 50))
        }
        throw new Error("controller missing: " + identifier)
      }

      const calls = []
      const originalFetch = window.fetch
      window.fetch = (url, options) => {
        if (String(url).includes("/demo/tables/reorder")) {
          calls.push(JSON.parse(options.body))
        }
        return Promise.resolve({
          ok: true,
          json: async () => ({ok: true, version: "2"})
        })
      }

      async function send(identifier, targetName, ids) {
        const element = mountSortable(identifier, targetName, ids)
        const controller = await controllerFor(element, identifier)
        const items = [...element.querySelectorAll("[data-id]")]
        items[0].parentNode.insertBefore(items[1], items[0])
        await controller.saveOrder()
        return calls[calls.length - 1].reorder.items
      }

      async function sendIntegers(identifier) {
        const root = document.querySelector(`[data-controller="${identifier}"]`)
        const items = [...root.querySelectorAll("[data-id]")]
        items[0].dataset.id = "4"
        items[1].dataset.id = "7"
        await readController(root, identifier).saveOrder()
        return calls[calls.length - 1].reorder.items
      }

      ;(async () => {
        try {
          const tableUuid = await send("flat-pack--table-sortable", "row", tableUuids)
          const tableInteger = await sendIntegers("flat-pack--table-sortable")
          const gridUuid = await send("flat-pack--grid-sortable", "item", gridUuids)
          const gridInteger = await sendIntegers("flat-pack--grid-sortable")
          done({tableUuid, tableInteger, gridUuid, gridInteger})
        } catch (error) {
          done({error: error && error.stack ? error.stack : String(error)})
        } finally {
          window.fetch = originalFetch
        }
      })()
    JS

    assert_nil payload["error"], payload["error"].to_s
    assert_equal [
      {"id" => "6f1e1a4a-1c2b-4d3e-8f90-222222222222", "position" => 1},
      {"id" => "6f1e1a4a-1c2b-4d3e-8f90-111111111111", "position" => 2}
    ], payload["tableUuid"]
    assert_equal [
      {"id" => "4", "position" => 1},
      {"id" => "7", "position" => 2}
    ], payload["tableInteger"]
    assert_equal [
      {"id" => "6f1e1a4a-1c2b-4d3e-8f90-444444444444", "position" => 1},
      {"id" => "6f1e1a4a-1c2b-4d3e-8f90-333333333333", "position" => 2}
    ], payload["gridUuid"]
    assert_equal [
      {"id" => "4", "position" => 1},
      {"id" => "7", "position" => 2}
    ], payload["gridInteger"]
    assert payload["tableUuid"].all? { |item| item["id"].is_a?(String) }
    assert payload["tableInteger"].all? { |item| item["id"].is_a?(String) }
    assert payload["gridUuid"].all? { |item| item["id"].is_a?(String) }
    assert payload["gridInteger"].all? { |item| item["id"].is_a?(String) }
  end
end
