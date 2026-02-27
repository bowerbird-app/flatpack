import { application } from "controllers/application"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom, lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Lazy load FlatPack controllers on first use.
// FlatPack identifiers are namespaced (e.g. flat-pack--chat-sender),
// so lazy loading must start at "controllers" to avoid duplicate path segments.
lazyLoadControllersFrom("controllers", application)
