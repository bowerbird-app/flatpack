# frozen_string_literal: true

module ApplicationHelper
	CHAT_MESSAGE_STATES = %i[sent sending failed read].freeze

	def render_chat_demo_message(record, reveal_actions: false)
		body = chat_demo_message_body(record)
		attachments = chat_demo_message_attachments(record)

		raise ArgumentError, "body or attachments are required" if body.blank? && attachments.blank?

		direction = chat_demo_message_direction(record)
		sender_name = chat_demo_message_sender_name(record)

		content_tag(:div, **chat_demo_message_wrapper_attributes(record, direction, sender_name)) do
			render FlatPack::Chat::MessageGroup::Component.new(
				direction: direction,
				show_avatar: direction == :incoming,
				show_name: direction == :incoming,
				sender_name: sender_name
			) do |group|
				if direction == :incoming
					group.with_avatar do
						render FlatPack::Avatar::Component.new(
							name: sender_name,
							initials: chat_demo_message_initials(sender_name),
							size: :sm
						)
					end
				end

				group.with_message do
					render chat_demo_message_component_class(direction).new(
						**chat_demo_message_component_arguments(record, reveal_actions: reveal_actions)
					) do |message|
						message.with_meta do
							render FlatPack::Chat::MessageMeta::Component.new(
								timestamp: chat_demo_message_timestamp(record),
								state: chat_demo_message_state(record)
							)
						end

						render_chat_demo_message_attachments(message, attachments, direction)

						body.presence || " "
					end
				end
			end
		end
	end

	private

	def chat_demo_message_component_arguments(record, reveal_actions: false)
		arguments = {
			state: chat_demo_message_state(record),
			reveal_actions: reveal_actions
		}

		arguments[:timestamp] = chat_demo_message_timestamp(record) if reveal_actions
		arguments
	end

	def render_chat_demo_message_attachments(message, attachments, direction)
		image_attachments, file_attachments = attachments.partition { |attachment| attachment[:type] == :image }

		if image_attachments.many?
			message.with_media_attachment do
				render FlatPack::Carousel::Component.new(
					slides: image_attachments.map { |attachment| chat_demo_message_image_slide(attachment) },
					show_thumbs: true,
					show_controls: true,
					show_indicators: true,
					show_captions: false,
					aspect_ratio: "4/3",
					aria_label: chat_demo_message_gallery_label(direction),
					class: "overflow-hidden rounded-2xl"
				)
			end
		else
			image_attachments.each do |attachment|
				message.with_media_attachment do
					render FlatPack::Chat::Attachment::Component.new(**attachment)
				end
			end
		end

		file_attachments.each do |attachment|
			message.with_attachment do
				render FlatPack::Chat::Attachment::Component.new(**attachment)
			end
		end
	end

	def chat_demo_message_wrapper_attributes(record, direction, sender_name)
		attributes = {
			class: "transition-[margin] duration-base",
			data: {
				flat_pack_chat_record: true,
				flat_pack_chat_record_sender: sender_name,
				flat_pack_chat_record_direction: direction,
				pagination_cursor: chat_demo_message_cursor(record)
			}.compact
		}

		dom_id = chat_demo_message_dom_id(record)
		attributes[:id] = dom_id if dom_id.present?
		attributes
	end

	def chat_demo_message_component_class(direction)
		(direction == :outgoing) ? FlatPack::Chat::SentMessage::Component : FlatPack::Chat::ReceivedMessage::Component
	end

	def chat_demo_message_direction(record)
		outgoing = if record.respond_to?(:outgoing?)
			record.outgoing?
		else
			chat_demo_message_sender_name(record) == "You"
		end

		outgoing ? :outgoing : :incoming
	end

	def chat_demo_message_state(record)
		value = record.respond_to?(:state) ? record.state : nil
		state = value.to_s.presence&.to_sym

		CHAT_MESSAGE_STATES.include?(state) ? state : :sent
	end

	def chat_demo_message_body(record)
		return unless record.respond_to?(:body)

		record.body.to_s.strip.presence
	end

	def chat_demo_message_sender_name(record)
		return unless record.respond_to?(:sender_name)

		record.sender_name.to_s.presence
	end

	def chat_demo_message_timestamp(record)
		return unless record.respond_to?(:created_at)

		record.created_at
	end

	def chat_demo_message_cursor(record)
		return unless record.respond_to?(:id)

		record.id.presence
	end

	def chat_demo_message_dom_id(record)
		return unless record.respond_to?(:to_model)

		dom_id(record)
	end

	def chat_demo_message_initials(sender_name)
		sender_name.to_s.split.map { |part| part[0] }.join.first(2).upcase.presence || "?"
	end

	def chat_demo_message_attachments(record)
		return [] unless record.respond_to?(:chat_item_attachments)

		Array(record.chat_item_attachments).filter_map do |attachment|
			chat_demo_message_attachment_attributes(attachment)
		end
	end

	def chat_demo_message_attachment_attributes(attachment)
		{
			type: chat_demo_message_attachment_type(attachment),
			name: attachment.name,
			meta: attachment.respond_to?(:meta_label) ? attachment.meta_label : nil,
			href: nil,
			thumbnail_url: chat_demo_message_attachment_thumbnail_url(attachment)
		}.compact
	end

	def chat_demo_message_attachment_type(attachment)
		attachment.respond_to?(:kind) && attachment.kind.to_s == "image" ? :image : :file
	end

	def chat_demo_message_attachment_thumbnail_url(attachment)
		return unless attachment.respond_to?(:image?) && attachment.image?

		thumbnail_url = attachment.respond_to?(:thumbnail_url) ? attachment.thumbnail_url : nil
		thumbnail_url.presence || chat_demo_message_generated_thumbnail_url(attachment.name)
	end

	def chat_demo_message_generated_thumbnail_url(name)
		seed = ERB::Util.url_encode(name.to_s)
		"https://picsum.photos/seed/#{seed}/480/280"
	end

	def chat_demo_message_image_slide(attachment)
		{
			type: :image,
			src: attachment[:href].presence || attachment[:thumbnail_url],
			thumb_src: attachment[:thumbnail_url].presence,
			alt: attachment[:name].presence,
			lightbox: true
		}.compact
	end

	def chat_demo_message_gallery_label(direction)
		(direction == :outgoing) ? "Outgoing chat image gallery" : "Incoming chat image gallery"
	end
end
