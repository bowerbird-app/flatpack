# frozen_string_literal: true

module FlatPack
  module CopyHelper
    # For `<html <%= tag.attributes(data: flat_pack_copy_data) %>>`.
    # Sets `data-fp-copy` so kit JavaScript can read the current locale.
    def flat_pack_copy_data
      {fp_copy: FlatPack::Copy.js_payload.to_json}
    end
  end
end
