import { application } from "controllers/application"
import TiptapController from "controllers/flat_pack/tiptap_controller"
import NestedMultiselectController from "controllers/nested_multiselect_controller"

// Eager load all controllers defined in the import map under controllers/**/*_controller
import { eagerLoadControllersFrom, lazyLoadControllersFrom } from "@hotwired/stimulus-loading"
eagerLoadControllersFrom("controllers", application)

// Rich-text demos rely on the engine's nested TipTap controller being available
// on first paint, so register it explicitly in the dummy app as well.
application.register("flat-pack--tiptap", TiptapController)
application.register("flat-pack--nested-multiselect", NestedMultiselectController)

// Lazy load FlatPack controllers on first use.
// FlatPack identifiers are namespaced (e.g. flat-pack--chat-sender),
// so lazy loading must start at "controllers" to avoid duplicate path segments.
lazyLoadControllersFrom("controllers", application)
