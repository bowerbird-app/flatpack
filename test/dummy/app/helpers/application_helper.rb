# frozen_string_literal: true

module ApplicationHelper
  def render_chat_demo_message(item, reveal_actions: true)
    direction = item.outgoing? ? :outgoing : :incoming

    content_tag(
      :div,
      id: dom_id(item),
      class: "transition-[margin] duration-base",
      data: {
        flat_pack_chat_record: true,
        flat_pack_chat_record_sender: item.sender_name,
        flat_pack_chat_record_direction: direction,
        pagination_cursor: item.id
      }
    ) do
      render FlatPack::Chat::MessageGroup::Component.new(
        direction: direction,
        show_avatar: !item.outgoing?,
        show_name: !item.outgoing?,
        sender_name: item.sender_name
      ) do |group|
        if direction == :incoming
          group.avatar do
            render FlatPack::Avatar::Component.new(name: item.sender_name, size: :sm)
          end
        end

        group.message do
          render chat_demo_message_component_class(direction).new(
            state: item.state.to_sym,
            reveal_actions: (direction == :outgoing) ? reveal_actions : false
          ) do |message|
            item.chat_item_attachments.each do |attachment|
              if attachment.image? && attachment.thumbnail_url.present?
                message.media_attachment do
                  render FlatPack::Chat::Attachment::Component.new(
                    type: :image,
                    name: attachment.name,
                    thumbnail_url: attachment.thumbnail_url,
                    href: attachment.thumbnail_url
                  )
                end
              else
                message.attachment do
                  render FlatPack::Chat::Attachment::Component.new(
                    type: attachment.kind.to_sym,
                    name: attachment.name,
                    meta: attachment.meta_label,
                    href: chat_demo_attachment_href(attachment),
                    thumbnail_url: attachment.thumbnail_url
                  )
                end
              end
            end

            message.meta do
              render FlatPack::Chat::MessageMeta::Component.new(
                timestamp: chat_demo_message_timestamp(item),
                state: item.state.to_sym
              )
            end

            item.body.presence || " "
          end
        end
      end
    end
  end

  private

  def chat_demo_message_component_class(direction)
    (direction == :outgoing) ? FlatPack::Chat::SentMessage::Component : FlatPack::Chat::ReceivedMessage::Component
  end

  def chat_demo_message_timestamp(item)
    item.submitted_at || item.created_at
  end

  def chat_demo_attachment_href(attachment)
    chat_demo_downloads_by_filename[attachment.name]
  end

  def chat_demo_downloads_by_filename
    @chat_demo_downloads_by_filename ||= PagesController::DEMO_CHAT_FILE_DOWNLOADS.to_h do |slug, file|
      [file.fetch(:filename), demo_chat_file_download_path(slug: slug)]
    end
  end
end
