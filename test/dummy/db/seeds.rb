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
    {sender_name: "Mina Cho", body: "I pushed the homepage copy updates. Can someone review?", state: "read"},
    {sender_name: "You", body: "Reviewed. Tone is solid — can you also add a shorter hero variant for mobile?", state: "read"},
    {sender_name: "Sam Lee", body: "I added both hero lengths and updated CTA spacing.", state: "read"},
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
    {sender_name: "Alex Rivera", body: "Launch window reminder: 3:00 PM with rollback checkpoint at 3:30.", state: "read"}
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

def seed_articles!
  return unless Article.table_exists?
  return if Article.exists?

  articles = [
    {
      title: "Getting Started with FlatPack",
      body: <<~HTML
                <h1>Getting Started with FlatPack</h1>
                <p>FlatPack is a Rails UI component library built on <strong>ViewComponent</strong> and <strong>Tailwind CSS 4</strong>. This guide walks you through the essentials so you can ship polished interfaces quickly.</p>
        
                <h2>Installation</h2>
                <p>Add FlatPack to your <code>Gemfile</code> and run the install generator:</p>
                <pre><code>bundle add flat_pack
        rails generate flat_pack:install</code></pre>
                <p>The generator wires up Tailwind, Stimulus, and Importmap automatically.</p>
        
                <h2>Your First Component</h2>
                <p>Render a button in any view:</p>
                <pre><code>&lt;%= render FlatPack::Button::Component.new(text: "Click me", style: :primary) %&gt;</code></pre>
        
                <h2>Design Tokens</h2>
                <p>All colours, shadows, and radii are CSS custom properties. Override them per-theme in your Tailwind file:</p>
                <ul>
                  <li><code>--color-primary</code> — brand accent colour</li>
                  <li><code>--radius-md</code> — default border radius</li>
                  <li><code>--surface-border-color</code> — separator and border tint</li>
                </ul>
        
                <blockquote>Pro tip: use the dark-mode token set by toggling the <code>dark</code> class on <code>&lt;html&gt;</code> — no extra configuration needed.</blockquote>
        
                <h2>Further Reading</h2>
                <p>Explore all components in the <a href="/docs">component docs</a> or jump straight to the <a href="/articles">demo articles</a> to see the Content Editor in action.</p>
      HTML
    },
    {
      title: "Typography in the Content Editor",
      body: <<~HTML
        <h1>Typography in the Content Editor</h1>
        <p>The <strong>Content Editor</strong> component ships with a full typographic reset so your content looks great out of the box — even after Tailwind Preflight removes browser defaults.</p>

        <h2>Headings</h2>
        <p>All six heading levels are supported. Select text and pick H1, H2, or H3 from the balloon toolbar.</p>
        <h3>Heading 3 — section title</h3>
        <p>Use heading 3 for sub-sections within a topic. Headings carry <code>font-weight: 700</code> and tightened <code>line-height: 1.3</code>.</p>

        <h2>Inline Formatting</h2>
        <p>The toolbar exposes the most common inline marks:</p>
        <ul>
          <li><strong>Bold</strong> — emphasise key terms</li>
          <li><em>Italic</em> — titles, foreign words, or gentle stress</li>
          <li><u>Underline</u> — use sparingly; readers associate underline with links</li>
          <li><s>Strikethrough</s> — show removed or deprecated items</li>
        </ul>

        <h2>Block Elements</h2>
        <p>Beyond paragraphs you can insert:</p>
        <ol>
          <li>Ordered lists for sequential steps</li>
          <li>Unordered lists for non-sequential items</li>
          <li>Blockquotes for pulled quotes or callouts</li>
        </ol>

        <blockquote>Good typography is invisible. Bad typography is everywhere. — Beatrice Warde</blockquote>

        <h2>Links</h2>
        <p>Select any text, press the link button in the toolbar, and enter a URL. To edit an existing link, select it and press the link button again. To remove it, clear the URL field and confirm.</p>
        <p>Learn more in the <a href="https://developer.mozilla.org/en-US/docs/Web/HTML/Element/a">MDN anchor element docs</a>.</p>
      HTML
    },
    {
      title: "Working with Images",
      body: <<~HTML
        <h1>Working with Images</h1>
        <p>The Content Editor supports inline image uploads when an <code>upload_url</code> is provided. Images are uploaded via a secure <code>POST</code> request and inserted at the cursor position — no page reload needed.</p>

        <h2>How It Works</h2>
        <ol>
          <li>Click the image icon in the balloon toolbar.</li>
          <li>A file picker opens — select any <code>image/*</code> file.</li>
          <li>The editor uploads the file and inserts the returned URL immediately.</li>
        </ol>

        <h2>Server Requirements</h2>
        <p>Your upload endpoint must:</p>
        <ul>
          <li>Accept a multipart <code>POST</code> with a <code>file</code> field.</li>
          <li>Return <code>{ "url": "https://..." }</code> JSON on success.</li>
          <li>Return a non-2xx status with <code>{ "error": "..." }</code> on failure.</li>
        </ul>

        <blockquote>Always validate file type and size server-side. The browser's <code>accept="image/*"</code> is a hint, not a security control.</blockquote>

        <h2>Linking Images</h2>
        <p>Click any inserted image to reveal the balloon toolbar. Press the link button to wrap the image in an anchor, or to edit or remove an existing link. This lets you turn screenshots into navigable diagrams.</p>

        <h2>Responsive Images</h2>
        <p>The content editor stylesheet automatically constrains images to <code>max-width: 100%</code> with <code>height: auto</code>, so they reflow correctly on every screen size without any extra markup.</p>
      HTML
    },
    {
      title: "Content Editor Reference",
      body: <<~HTML
                <h1>Content Editor — Full Reference</h1>
                <p>This article exercises every toolbar option available in <code>FlatPack::ContentEditor::Component</code>.</p>
        
                <h2>Text Formatting</h2>
                <p>Inline marks: <strong>bold</strong>, <em>italic</em>, <u>underline</u>, <s>strikethrough</s>. Use <em>Clear Formatting</em> to strip all marks from a selection at once.</p>
        
                <h2>Headings</h2>
                <h1>Heading 1 — top-level title</h1>
                <h2>Heading 2 — major section</h2>
                <h3>Heading 3 — sub-section</h3>
        
                <h2>Lists</h2>
                <p>Unordered list:</p>
                <ul>
                  <li>Apples</li>
                  <li>Oranges</li>
                  <li>Bananas</li>
                </ul>
                <p>Ordered list:</p>
                <ol>
                  <li>Enable editing by clicking <strong>Edit</strong>.</li>
                  <li>Select text and pick a format from the balloon toolbar.</li>
                  <li>Click <strong>Save</strong> to persist changes.</li>
                </ol>
        
                <h2>Blockquote</h2>
                <blockquote>Any sufficiently advanced technology is indistinguishable from magic. — Arthur C. Clarke</blockquote>
        
                <h2>Links</h2>
                <p>Visit the <a href="https://github.com/bowerbird-app/flatpack">FlatPack repository on GitHub</a> for source code and issue tracking. You can also link to <a href="/articles">other articles</a> in the dummy app.</p>
        
                <h2>Code</h2>
                <p>Inline code: <code>render FlatPack::ContentEditor::Component.new(update_url: article_path(@article))</code>.</p>
                <pre><code>&lt;%= render FlatPack::ContentEditor::Component.new(
          update_url: article_path(@article),
          upload_url: article_upload_image_path(@article),
          field_name: "article[body]",
          field_format_name: "article[body_format]"
        ) do %&gt;
          &lt;%= raw @article.body %&gt;
        &lt;% end %&gt;</code></pre>
        
                <h2>Horizontal Rule</h2>
                <hr>
                <p>A horizontal rule above separates major content regions.</p>
      HTML
    }
  ]

  timestamp = Time.current
  articles.each do |attrs|
    Article.create!(attrs.merge(body_format: "html", created_at: timestamp, updated_at: timestamp))
  end
  puts "- Article: created #{Article.count} rows"
end

seed_dummy_data!
seed_demo_table_rows!
seed_demo_comments!
seed_chat_data!
seed_articles!

# Seed demo login user
def seed_demo_user!
  return unless User.table_exists?
  return if User.exists?(email: "demo@example.com")

  User.create!(
    email: "demo@example.com",
    password: "password123",
    password_confirmation: "password123"
  )
  puts "- User: created demo@example.com (password: password123)"
end

seed_demo_user!

puts "Seeding complete."
