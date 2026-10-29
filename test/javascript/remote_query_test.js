const test = require('node:test')
const assert = require('node:assert/strict')
const fs = require('node:fs')
const path = require('node:path')
const vm = require('node:vm')

function loadHelper() {
  const filePath = path.join(__dirname, '..', '..', 'app', 'javascript', 'flat_pack', 'remote_query.js')
  const source = fs.readFileSync(filePath, 'utf8')
    .replace('export function createRemoteQuery', 'function createRemoteQuery')
  const hooks = {
    fetch: async () => {
      throw new Error('fetch was not stubbed')
    }
  }
  const context = {
    module: { exports: {} },
    setTimeout,
    clearTimeout,
    URL,
    AbortController,
    window: { location: { origin: 'http://example.test' } },
    fetch: (...args) => hooks.fetch(...args)
  }
  vm.runInNewContext(`${source}\nmodule.exports = { createRemoteQuery }\n`, context, { filename: filePath })
  return { createRemoteQuery: context.module.exports.createRemoteQuery, hooks }
}

test('debounce runs only the latest call', async () => {
  const { createRemoteQuery } = loadHelper()
  const remote = createRemoteQuery()
  const ran = []

  remote.debounce(30, () => ran.push('first'))
  remote.debounce(30, () => ran.push('second'))
  await new Promise((resolve) => setTimeout(resolve, 80))

  assert.deepEqual(ran, ['second'])
})

test('fetch aborts the previous request and sends one JSON GET', async () => {
  const { createRemoteQuery, hooks } = loadHelper()
  const remote = createRemoteQuery()
  const calls = []
  let releaseFirst
  const firstStarted = new Promise((resolve) => {
    releaseFirst = resolve
  })

  hooks.fetch = (url, options) => {
    calls.push({ url, options })
    if (calls.length === 1) {
      releaseFirst()
      return new Promise((resolve, reject) => {
        options.signal.addEventListener('abort', () => {
          const error = new Error('aborted')
          error.name = 'AbortError'
          reject(error)
        })
      })
    }

    return Promise.resolve({ ok: true })
  }

  const pending = remote.fetch('/search', { query: 'a', param: 'q' })
  await firstStarted
  let aborted = false
  pending.catch((error) => {
    aborted = error.name === 'AbortError'
  })

  const response = await remote.fetch('/search', {
    query: 'ab',
    param: 'q',
    params: { kinds: 'image' }
  })
  await new Promise((resolve) => setImmediate(resolve))

  assert.equal(aborted, true)
  assert.equal(calls.length, 2)
  assert.equal(calls[1].url, 'http://example.test/search?q=ab&kinds=image')
  assert.equal(calls[1].options.method, 'GET')
  assert.equal(calls[1].options.headers.Accept, 'application/json')
  assert.equal(response.ok, true)
})

test('stop drops a pending debounce and aborts the request', async () => {
  const { createRemoteQuery, hooks } = loadHelper()
  const remote = createRemoteQuery()
  let ran = false
  remote.debounce(50, () => {
    ran = true
  })

  let aborted = false
  hooks.fetch = (url, options) => {
    return new Promise((resolve, reject) => {
      options.signal.addEventListener('abort', () => {
        const error = new Error('aborted')
        error.name = 'AbortError'
        aborted = true
        reject(error)
      })
    })
  }
  const pending = remote.fetch('/search', { query: 'a' })
  remote.stop()
  await pending.catch(() => {})
  await new Promise((resolve) => setTimeout(resolve, 80))

  assert.equal(ran, false)
  assert.equal(aborted, true)
})
