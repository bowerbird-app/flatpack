# frozen_string_literal: true

puts "Seeding dummy app data..."

def seed_dummy_data!
  return unless DummyDatum.table_exists?
  return if DummyDatum.exists?

  timestamp = Time.current
  rows = [
    {name: "Avery Stone", email: "avery.stone@example.com", status: "active", category: "engineering", views_count: 1_250, published_at: 2.days.ago},
    {name: "Jordan Miles", email: "jordan.miles@example.com", status: "inactive", category: "marketing", views_count: 840, published_at: 6.days.ago},
    {name: "Priya Nair", email: "priya.nair@example.com", status: "pending", category: "product", views_count: 1_910, published_at: 1.day.ago},
    {name: "Noah Kim", email: "noah.kim@example.com", status: "archived", category: "sales", views_count: 430, published_at: 12.days.ago},
    {name: "Riley Chen", email: "riley.chen@example.com", status: "active", category: "support", views_count: 2_210, published_at: 4.days.ago},
    {name: "Mina Park", email: "mina.park@example.com", status: "active", category: "engineering", views_count: 3_105, published_at: 8.hours.ago},
    {name: "Alex Carter", email: "alex.carter@example.com", status: "pending", category: "product", views_count: 1_090, published_at: 3.days.ago},
    {name: "Sam Rivera", email: "sam.rivera@example.com", status: "inactive", category: "marketing", views_count: 760, published_at: 9.days.ago},
    {name: "Diana Prince", email: "diana.prince@example.com", status: "active", category: "sales", views_count: 1_540, published_at: 30.hours.ago},
    {name: "Charlie Brown", email: "charlie.brown@example.com", status: "archived", category: "support", views_count: 320, published_at: 18.days.ago}
  ]

  insert_rows = rows.each_with_index.map do |row, index|
    row.merge(position: index + 1, created_at: timestamp, updated_at: timestamp)
  end

  DummyDatum.insert_all!(insert_rows)
  puts "- DummyDatum: created #{insert_rows.size} rows"
end

def seed_demo_table_rows!
  return unless DemoTableRow.table_exists?
  return if DemoTableRow.where(list_key: DemoTableRow::DEFAULT_LIST_KEY).exists?

  timestamp = Time.current
  rows = [
    {name: "Backlog grooming", status: "pending", priority: "low"},
    {name: "Design QA", status: "active", priority: "high"},
    {name: "API integration", status: "active", priority: "medium"},
    {name: "Release checklist", status: "inactive", priority: "medium"},
    {name: "Retrospective prep", status: "pending", priority: "low"}
  ]

  insert_rows = rows.each_with_index.map do |row, index|
    {
      list_key: DemoTableRow::DEFAULT_LIST_KEY,
      name: row[:name],
      status: row[:status],
      priority: row[:priority],
      position: index + 1,
      created_at: timestamp,
      updated_at: timestamp
    }
  end

  DemoTableRow.insert_all!(insert_rows)
  puts "- DemoTableRow: created #{insert_rows.size} rows"
end

def seed_demo_comments!
  return unless DemoComment.table_exists?
  return if DemoComment.exists?

  alice = DemoComment.create!(
    author_name: "Alice Johnson",
    author_meta: "Software Engineer",
    body: "This is a really great feature! I've been waiting for something like this."
  )

  bob = DemoComment.create!(
    author_name: "Bob Smith",
    body: "I agree. This will save us a lot of time."
  )

  DemoComment.create!(
    parent_comment: alice,
    author_name: "Charlie Brown",
    body: "Same here. Can we also add a quick start guide?"
  )

  DemoComment.create!(
    parent_comment: bob,
    author_name: "Diana Prince",
    body: "Good call. I can draft the first pass this week."
  )

  puts "- DemoComment: created #{DemoComment.count} rows"
end

def seed_chat_items_for_group!(group, timeline, offset_minutes: 0)
  return if group.chat_items.exists?

  now = Time.current
  timeline.each_with_index do |entry, index|
    minutes_ago = (timeline.length - index) + offset_minutes

    item = group.chat_items.build(
      sender_name: entry.fetch(:sender_name),
      body: entry[:body],
      state: entry.fetch(:state),
      submitted_at: nil,
      created_at: now - minutes_ago.minutes,
      updated_at: now - minutes_ago.minutes
    )

    Array(entry[:attachments]).each_with_index do |attachment, attachment_index|
      item.chat_item_attachments.build(
        kind: attachment.fetch(:kind),
        name: attachment.fetch(:name),
        content_type: attachment[:content_type],
        byte_size: attachment[:byte_size],
        position: attachment_index,
        metadata: attachment[:metadata] || {}
      )
    end

    item.save!
  end
end

def seed_chat_data!
  return unless ChatGroup.table_exists? && ChatItem.table_exists? && ChatItemAttachment.table_exists?

  design_team_timeline = [
    {sender_name: "Mina", body: "I pushed the homepage copy updates. Can someone review?", state: "read"},
    {sender_name: "You", body: "Reviewed. Tone is solid — can you also add a shorter hero variant for mobile?", state: "read"},
    {sender_name: "Sam", body: "I added both hero lengths and updated CTA spacing.", state: "read"},
    {
      sender_name: "You",
      body: nil,
      state: "read",
      attachments: [
        {
          kind: "image",
          name: "hero-mobile-1.png",
          content_type: "image/png",
          byte_size: 182_300,
          metadata: {thumbnail_url: "https://images.unsplash.com/photo-1460925895917-afdab827c52f?w=320&h=200&fit=crop"}
        },
        {
          kind: "image",
          name: "hero-mobile-2.png",
          content_type: "image/png",
          byte_size: 194_100,
          metadata: {thumbnail_url: "https://images.unsplash.com/photo-1518773553398-650c184e0bb3?w=320&h=200&fit=crop"}
        }
      ]
    },
    {sender_name: "Alex", body: "Launch window reminder: 3:00 PM with rollback checkpoint at 3:30.", state: "read"}
  ]

  product_updates_timeline = [
    {sender_name: "Priya", body: "Roadmap draft is up with two candidate launch windows.", state: "read"},
    {sender_name: "You", body: "Please tag blockers by priority before tomorrow standup.", state: "read"},
    {sender_name: "Noah", body: "Done. Added risk notes for onboarding copy and billing events.", state: "read"}
  ]

  launch_ops_timeline = [
    {sender_name: "Jordan", body: "Status page template is ready for launch-day updates.", state: "read"},
    {sender_name: "You", body: "Great. Keep incident contact list pinned in this chat group.", state: "read"},
    {
      sender_name: "Riley",
      body: "On-call schedule confirmed through the weekend.",
      state: "read",
      attachments: [
        {
          kind: "file",
          name: "oncall-schedule.pdf",
          content_type: "application/pdf",
          byte_size: 96_800
        }
      ]
    }
  ]

  seed_chat_items_for_group!(
    ChatGroup.find_or_create_by!(name: "Design Team"),
    design_team_timeline,
    offset_minutes: 0
  )

  seed_chat_items_for_group!(
    ChatGroup.find_or_create_by!(name: "Product Updates"),
    product_updates_timeline,
    offset_minutes: 45
  )

  seed_chat_items_for_group!(
    ChatGroup.find_or_create_by!(name: "Launch Ops"),
    launch_ops_timeline,
    offset_minutes: 90
  )

  puts "- ChatGroup: #{ChatGroup.count} groups"
  puts "- ChatItem: #{ChatItem.count} rows"
  puts "- ChatItemAttachment: #{ChatItemAttachment.count} rows"
end

seed_dummy_data!
seed_demo_table_rows!
seed_demo_comments!
seed_chat_data!

puts "Seeding complete."
