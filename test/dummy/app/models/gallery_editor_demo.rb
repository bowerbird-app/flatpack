# frozen_string_literal: true

# In-memory photos for the navigable modal demo. Nothing is saved.
class GalleryEditorDemo
  MODAL_ID = "gallery-editor"

  PHOTOGRAPHERS = {
    "mira" => {
      id: "mira",
      name: "Mira Chen",
      bio: "Shoots harbours at blue hour. Based in Wellington."
    },
    "jonah" => {
      id: "jonah",
      name: "Jonah Hale",
      bio: "Prefers quiet interiors and long exposures."
    }
  }.freeze

  IMAGES = [
    {
      id: "harbour",
      caption: "Harbour at dusk",
      alt: "Boats tied up under a violet sky",
      src: "/masonry/harbour.svg",
      photographer_id: "mira"
    },
    {
      id: "jetty",
      caption: "Jetty notes",
      alt: "A wooden jetty stretching into still water",
      src: "/masonry/jetty.svg",
      photographer_id: "mira"
    },
    {
      id: "loft",
      caption: "Studio loft",
      alt: "A sunlit loft with a wide window",
      src: "/masonry/loft.svg",
      photographer_id: "jonah"
    }
  ].freeze

  def self.images
    IMAGES
  end

  def self.image(id)
    IMAGES.find { |image| image[:id] == id.to_s }
  end

  def self.photographer(id)
    PHOTOGRAPHERS[id.to_s]
  end
end
