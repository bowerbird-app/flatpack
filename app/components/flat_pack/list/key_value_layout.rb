# frozen_string_literal: true

module FlatPack
  module List
    # Column tracks: icon, key, the gap, the value, trailing.
    # Subgrid on each row keeps icons and keys in those columns.
    # Tailwind CSS scanning requires these classes to be present as string literals.
    # DO NOT REMOVE - These duplicates ensure CSS generation:
    # "m-0" "grid" "grid-cols-1" "min-w-0" "flex" "flex-col" "flex-1" "items-start" "self-start"
    # "gap-1" "gap-2" "gap-3" "gap-y-1" "gap-y-3" "gap-0"
    # "col-span-full" "col-span-2" "col-start-4" "grid-cols-subgrid" "hidden" "me-2" "ms-3"
    # "mt-0.5" "break-words" "font-medium" "flex-shrink-0" "py-4" "px-4"
    # "rounded-[var(--radius-sm)]"
    # "text-[var(--surface-content-color)]" "text-[var(--surface-muted-content-color)]"
    # "grid-cols-[max-content_var(--fp-list-key-width)_var(--stack-gap-md)_minmax(0,1fr)_max-content]"
    # "sm:grid" "sm:grid-cols-subgrid" "sm:col-span-full" "sm:col-span-2" "sm:col-start-4"
    # "sm:items-start" "sm:gap-0" "sm:me-2" "sm:ms-3" "sm:block"
    # "sm:grid-cols-[max-content_var(--fp-list-key-width)_var(--stack-gap-md)_minmax(0,1fr)_max-content]"
    # "md:grid" "md:grid-cols-subgrid" "md:col-span-full" "md:col-span-2" "md:col-start-4"
    # "md:items-start" "md:gap-0" "md:me-2" "md:ms-3" "md:block"
    # "md:grid-cols-[max-content_var(--fp-list-key-width)_var(--stack-gap-md)_minmax(0,1fr)_max-content]"
    # "lg:grid" "lg:grid-cols-subgrid" "lg:col-span-full" "lg:col-span-2" "lg:col-start-4"
    # "lg:items-start" "lg:gap-0" "lg:me-2" "lg:ms-3" "lg:block"
    # "lg:grid-cols-[max-content_var(--fp-list-key-width)_var(--stack-gap-md)_minmax(0,1fr)_max-content]"
    module KeyValueLayout
      # Full literals. Interpolation hides the variant from the Tailwind scan.
      LIST_TRACKS = "grid-cols-[max-content_var(--fp-list-key-width)_var(--stack-gap-md)_minmax(0,1fr)_max-content]"
      LIST_TRACKS_SM =
        "sm:grid-cols-[max-content_var(--fp-list-key-width)_var(--stack-gap-md)_minmax(0,1fr)_max-content]"
      LIST_TRACKS_MD =
        "md:grid-cols-[max-content_var(--fp-list-key-width)_var(--stack-gap-md)_minmax(0,1fr)_max-content]"
      LIST_TRACKS_LG =
        "lg:grid-cols-[max-content_var(--fp-list-key-width)_var(--stack-gap-md)_minmax(0,1fr)_max-content]"

      LIST_CLASSES = {
        base: "m-0 grid #{LIST_TRACKS}",
        sm: "m-0 grid grid-cols-1 #{LIST_TRACKS_SM}",
        md: "m-0 grid grid-cols-1 #{LIST_TRACKS_MD}",
        lg: "m-0 grid grid-cols-1 #{LIST_TRACKS_LG}"
      }.freeze

      ROW_CLASSES = {
        base: "grid min-w-0 grid-cols-subgrid col-span-full items-start",
        sm: "flex min-w-0 flex-col gap-1 sm:grid sm:grid-cols-subgrid sm:col-span-full sm:items-start sm:gap-0",
        md: "flex min-w-0 flex-col gap-1 md:grid md:grid-cols-subgrid md:col-span-full md:items-start md:gap-0",
        lg: "flex min-w-0 flex-col gap-1 lg:grid lg:grid-cols-subgrid lg:col-span-full lg:items-start lg:gap-0"
      }.freeze

      TERM_CLASSES = {
        base: "m-0 grid grid-cols-subgrid col-span-2 items-start",
        sm: "m-0 flex items-start gap-2 sm:grid sm:grid-cols-subgrid sm:col-span-2 sm:items-start sm:gap-0",
        md: "m-0 flex items-start gap-2 md:grid md:grid-cols-subgrid md:col-span-2 md:items-start md:gap-0",
        lg: "m-0 flex items-start gap-2 lg:grid lg:grid-cols-subgrid lg:col-span-2 lg:items-start lg:gap-0"
      }.freeze

      DETAILS_CLASSES = {
        base: "m-0 grid min-w-0 grid-cols-subgrid col-start-4 col-span-2 items-start",
        sm: "m-0 flex min-w-0 items-start gap-3 sm:grid sm:grid-cols-subgrid " \
            "sm:col-start-4 sm:col-span-2 sm:items-start sm:gap-0",
        md: "m-0 flex min-w-0 items-start gap-3 md:grid md:grid-cols-subgrid " \
            "md:col-start-4 md:col-span-2 md:items-start md:gap-0",
        lg: "m-0 flex min-w-0 items-start gap-3 lg:grid lg:grid-cols-subgrid " \
            "lg:col-start-4 lg:col-span-2 lg:items-start lg:gap-0"
      }.freeze

      ICON_MARGIN_CLASSES = {
        base: "me-2",
        sm: "sm:me-2",
        md: "md:me-2",
        lg: "lg:me-2"
      }.freeze

      EMPTY_ICON_SLOT_CLASSES = {
        base: nil,
        sm: "hidden sm:block",
        md: "hidden md:block",
        lg: "hidden lg:block"
      }.freeze

      TRAILING_CLASSES = {
        base: "flat-pack-list-key-value-trailing flex-shrink-0 ms-3",
        sm: "flat-pack-list-key-value-trailing flex-shrink-0 sm:ms-3",
        md: "flat-pack-list-key-value-trailing flex-shrink-0 md:ms-3",
        lg: "flat-pack-list-key-value-trailing flex-shrink-0 lg:ms-3"
      }.freeze

      class << self
        def list_classes_for(stack_below)
          LIST_CLASSES.fetch(column_key(stack_below))
        end

        def row_classes_for(stack_below)
          ROW_CLASSES.fetch(column_key(stack_below))
        end

        def term_classes_for(stack_below)
          TERM_CLASSES.fetch(column_key(stack_below))
        end

        def details_classes_for(stack_below)
          DETAILS_CLASSES.fetch(column_key(stack_below))
        end

        def icon_margin_class_for(stack_below)
          ICON_MARGIN_CLASSES.fetch(column_key(stack_below))
        end

        def empty_icon_slot_class_for(stack_below)
          EMPTY_ICON_SLOT_CLASSES.fetch(column_key(stack_below))
        end

        def trailing_classes_for(stack_below)
          TRAILING_CLASSES.fetch(column_key(stack_below))
        end

        private

        def column_key(stack_below)
          stack_below || :base
        end
      end
    end
  end
end
