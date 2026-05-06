const registeredAddons = new Map()

function normalizeAddonName(name) {
  return typeof name === "string" ? name : String(name)
}

function normalizeAddonDescriptor(addon) {
  if (typeof addon === "string") {
    return { name: addon, options: {} }
  }

  if (addon && typeof addon === "object") {
    return {
      name: normalizeAddonName(addon.name),
      options: addon.options || {},
    }
  }

  return null
}

function normalizeList(value) {
  if (value == null) return []
  return Array.isArray(value) ? value.filter(Boolean) : [value]
}

async function resolveContribution(definition, key, context) {
  const value = definition?.[key]
  if (typeof value === "function") {
    return normalizeList(await value(context))
  }

  return normalizeList(value)
}

export function registerTiptapAddon(name, definition) {
  const addonName = normalizeAddonName(name)

  if (!addonName) {
    throw new Error("FlatPack TipTap addons require a non-empty name")
  }

  if (!definition || typeof definition !== "object") {
    throw new Error(`FlatPack TipTap addon \"${addonName}\" must be registered with an object definition`)
  }

  registeredAddons.set(addonName, definition)
  return definition
}

export function unregisterTiptapAddon(name) {
  registeredAddons.delete(normalizeAddonName(name))
}

export function getRegisteredTiptapAddon(name) {
  return registeredAddons.get(normalizeAddonName(name)) || null
}

export function listRegisteredTiptapAddons() {
  return Array.from(registeredAddons.keys())
}

export async function resolveTiptapAddons(config) {
  const rawAddons = Array.isArray(config?.opts?.addons) ? config.opts.addons : []
  const descriptors = rawAddons
    .map(normalizeAddonDescriptor)
    .filter(Boolean)

  const resolved = {
    descriptors,
    extensions: [],
    toolbarTools: [],
    bubbleMenuTools: [],
  }

  for (const descriptor of descriptors) {
    const definition = getRegisteredTiptapAddon(descriptor.name)

    if (!definition) {
      console.warn(`[FlatPack TipTap] Requested addon \"${descriptor.name}\" is not registered.`)
      continue
    }

    const context = {
      ...config,
      addon: descriptor,
      addonName: descriptor.name,
      addonOptions: descriptor.options || {},
    }

    if (typeof definition.enabled === "function" && definition.enabled(context) === false) {
      continue
    }

    resolved.extensions.push(...await resolveContribution(definition, "extensions", context))
    resolved.toolbarTools.push(...await resolveContribution(definition, "toolbarTools", context))
    resolved.bubbleMenuTools.push(...await resolveContribution(definition, "bubbleMenuTools", context))
  }

  return resolved
}
