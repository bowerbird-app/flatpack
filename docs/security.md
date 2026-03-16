# Security Guide

FlatPack is designed with security as a core principle. This guide explains the security features built into the gem and best practices for using components securely.

## Security Pillars

FlatPack's security approach is based on four key pillars:

| Pillar | Protection Mechanism | Why It Matters |
|--------|---------------------|----------------|
| **Injection Protection** | Rails Auto-Escaping + AttributeSanitizer | Prevents attackers from injecting `<script>` tags through component attributes |
| **Logic Isolation** | Isolated Namespace & No ActiveRecord | Prevents the gem from accidentally accessing or leaking data from the host app's database |
| **JavaScript Safety** | Stimulus + Importmaps | Avoids `eval()` and `unsafe-inline` scripts, making it fully compatible with strict CSP headers |
| **Supply Chain Security** | Brakeman + GitHub Actions | Ensures that every update to the gem is scanned for new vulnerabilities before release |

## XSS Prevention

### 1. Automatic Attribute Sanitization

All components automatically sanitize HTML attributes to prevent XSS attacks. The `FlatPack::AttributeSanitizer` removes dangerous event handlers:

```ruby
# Dangerous attributes are automatically filtered
<%= render FlatPack::Button::Component.new(
  text: "Click me",
  onclick: "alert('xss')"  # This will be filtered out
) %>
```

**Blocked Attributes:**
- Event handlers: `onclick`, `onload`, `onerror`, `onmouseover`, etc.
- All `on*` attributes are automatically removed

### 2. URL Validation

All URLs (for buttons, links) are validated against a whitelist of safe protocols:

```ruby
# Safe URLs - these work
<%= render FlatPack::Button::Component.new(text: "Visit", url: "https://example.com") %>
<%= render FlatPack::Button::Component.new(text: "Email", url: "mailto:test@example.com") %>
<%= render FlatPack::Button::Component.new(text: "Call", url: "tel:+1234567890") %>
<%= render FlatPack::Button::Component.new(text: "Page", url: "/relative/path") %>

# Unsafe URLs - these are blocked
<%= render FlatPack::Button::Component.new(text: "XSS", url: "javascript:alert('xss')") %>
# => ArgumentError: Unsafe URL detected
```

**Allowed Protocols:**
- `http://` and `https://` - Standard web links
- `mailto:` - Email links
- `tel:` - Phone links
- Relative URLs (`/path`, `./path`, `#anchor`)

**Blocked Protocols:**
- `javascript:` - Prevents script injection
- `data:` - Prevents data URL attacks
- `vbscript:` - Prevents VBScript execution
- `ftp://` and other non-standard protocols

### 3. Template Escaping

All component templates use Rails' standard auto-escaping:

```erb
<%# Safe - Rails automatically escapes -->
<%= content_tag :div, user_input %>

<%# Avoid - Never use html_safe with user input %>
<%= user_input.html_safe %>
```

### 4. Safe HTML Slots

When passing rich HTML content to components, use the sidecar pattern with blocks:

```ruby
# SAFE - Rails handles the buffer safely
<%= render FlatPack::Card::Component.new do |card| %>
  <% card.body do %>
    <p>This is <strong>Safe</strong> HTML handled by Rails.</p>
  <% end %>
<% end %>

# UNSAFE - Never do this
<%= render FlatPack::Card::Component.new(
  body: "<p>User input: #{params[:content]}</p>".html_safe
) %>
```

## Component Security Guidelines

### 1. No Database Queries

Components **strictly forbid** direct ActiveRecord queries. This prevents:
- N+1 query problems
- Accidental data leaks
- Performance issues

```ruby
# BAD - Never query the database in a component
class MyComponent < FlatPack::BaseComponent
  def initialize
    @users = User.all  # ❌ Don't do this
  end
end

# GOOD - Pass data from the controller
class MyController < ApplicationController
  def index
    @users = User.all
    # Pass @users to the view/component
  end
end
```

### 2. Primitive Data Only

Components should only accept primitives or Value Objects, not ActiveRecord models directly:

```ruby
# RISKY - Exposing entire model
<%= render MyComponent.new(user: @user) %>

# BETTER - Pass only needed attributes
<%= render MyComponent.new(
  name: @user.name,
  email: @user.email
) %>

# BEST - Use a presenter/view model
<%= render MyComponent.new(user: UserPresenter.new(@user)) %>
```

This prevents:
- Mass assignment vulnerabilities
- Accidental exposure of sensitive attributes
- Tight coupling to database models

### 3. Content Security Policy (CSP) Compatibility

FlatPack components are fully compatible with strict CSP policies:

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.script_src  :self
  policy.style_src   :self
  
  # No need for 'unsafe-inline' or 'unsafe-eval'
end
```

**Why FlatPack is CSP-friendly:**
- ✅ No inline `<script>` tags
- ✅ No `eval()` calls
- ✅ All JavaScript in separate files via Stimulus
- ✅ All styles in CSS files

## Supply Chain Security

### 1. Minimal Dependencies

FlatPack has only **3 runtime dependencies**:
- `rails` (~> 8.0)
- `view_component` (~> 3.0)
- `tailwind_merge` (~> 0.13)

This minimizes supply chain attack surface.

### 2. Automated Security Scanning

Every push to the repository triggers automated security scans:

```yaml
# .github/workflows/security.yml
- Brakeman (static analysis)
- Bundle-Audit (dependency vulnerabilities)
- Dependency Review (on PRs)
```

### 3. Security Updates

We take security seriously:
- **Critical vulnerabilities**: Patched within 24-48 hours
- **High severity**: Patched within 7 days
- **Medium/Low severity**: Patched in next regular release

## API Reference

### FlatPack::AttributeSanitizer

Utility class for sanitizing component attributes.

#### `sanitize_url(url)`

Validates a URL and returns it if safe, `nil` otherwise.

```ruby
FlatPack::AttributeSanitizer.sanitize_url("https://example.com")
# => "https://example.com"

FlatPack::AttributeSanitizer.sanitize_url("javascript:alert('xss')")
# => nil
```

#### `sanitize_attributes(attributes)`

Filters dangerous HTML attributes from a hash.

```ruby
attrs = { id: "btn", onclick: "alert('xss')", class: "button" }
FlatPack::AttributeSanitizer.sanitize_attributes(attrs)
# => { id: "btn", class: "button" }
```

#### `validate_href!(href)`

Validates a URL and raises an error if unsafe.

```ruby
FlatPack::AttributeSanitizer.validate_href!("https://example.com")
# => "https://example.com"

FlatPack::AttributeSanitizer.validate_href!("javascript:alert('xss')")
# => ArgumentError: Unsafe URL detected
```

### FlatPack::Link::Component

Secure link component with built-in URL validation.

```ruby
<%= render FlatPack::Link::Component.new(
  href: "https://example.com",
  target: "_blank"  # Automatically adds rel="noopener noreferrer"
) do %>
  Visit Example
<% end %>
```

**Parameters:**
- `href` (required) - URL validated against safe protocols
- `method` - HTTP method for the link
- `target` - Link target (e.g., `_blank`)
- All standard system arguments (class, data, aria, etc.)

## Best Practices

### 1. Always Validate User Input

Even though FlatPack sanitizes attributes, validate user input at the controller level:

```ruby
class UsersController < ApplicationController
  def create
    @user = User.new(user_params)
    # ...
  end

  private

  def user_params
    params.require(:user).permit(:name, :email)  # Whitelist approach
  end
end
```

### 2. Use Content Helpers

For dynamic attributes, use Rails helpers instead of string interpolation:

```ruby
# GOOD
content_tag :div, "Content", class: dynamic_class

# BAD
"<div class='#{dynamic_class}'>Content</div>".html_safe
```

### 3. Regular Security Audits

Run security audits on your application regularly:

```bash
# Install security tools
gem install brakeman bundler-audit

# Run audits
brakeman --no-pager
bundle-audit check
```

### 4. Keep Dependencies Updated

Regularly update FlatPack and all dependencies:

```bash
bundle update flat_pack
bundle audit check
```

### 5. Enable Security Headers

Configure security headers in your Rails application:

```ruby
# config/application.rb
config.action_dispatch.default_headers.merge!(
  'X-Frame-Options' => 'SAMEORIGIN',
  'X-Content-Type-Options' => 'nosniff',
  'X-XSS-Protection' => '1; mode=block'
)
```

## Reporting Vulnerabilities

If you discover a security vulnerability, please **DO NOT** open a public GitHub issue.

See our [Security Policy](../SECURITY.md) for full details on responsible disclosure.

## Security Testing

FlatPack includes comprehensive security tests:

```bash
# Run all tests
bundle exec rake test

# Run only security tests
bundle exec ruby -Itest test/lib/flat_pack/attribute_sanitizer_test.rb
```

## Common Pitfalls

### ❌ Don't Bypass Sanitization

```ruby
# BAD - Bypassing sanitization
<%= tag.a href: user_input.html_safe %>

# GOOD - Let FlatPack validate
<%= render FlatPack::Link::Component.new(href: user_input) do
  Link Text
<% end %>
```

### ❌ Don't Use html_safe with User Input

```ruby
# BAD
<%= user_input.html_safe %>

# GOOD
<%= user_input %>  # Rails auto-escapes
```

### ❌ Don't Query Database in Components

```ruby
# BAD
class MyComponent < FlatPack::BaseComponent
  def posts
    Post.all
  end
end

# GOOD - Pass data from controller
<%= render MyComponent.new(posts: @posts) %>
```

## Displaying TipTap HTML Output

When using the TipTap rich text editor with the default `:html` format, always sanitize stored content before rendering it:

```ruby
# Safe — run stored HTML through the allowlist sanitizer
<%= raw FlatPack::RichTextSanitizer.sanitize(@post.body) %>
```

**Never** use `raw()` or `html_safe` directly on stored TipTap HTML without sanitizing first:

```ruby
# UNSAFE — do not do this
<%= raw @post.body %>
<%= @post.body.html_safe %>
```

### What the sanitizer allows

`FlatPack::RichTextSanitizer` maintains an allowlist of tags and attributes needed by TipTap extensions:

| Attribute | Element | Why |
|-----------|---------|-----|
| `data-color` | `mark` | Highlight multicolor stores the colour value here |
| `style` | `mark`, `span`, `p`, headings | Color, BackgroundColor, TextAlign emit inline styles |
| `data-type` | `ul` | TaskList sets `data-type="taskList"` |
| `data-checked` | `li` | TaskItem stores checked state |
| `data-colwidth` | `th`, `td` | Table resizable column widths |
| `class` | `code` | CodeBlockLowlight sets `language-*` class |
| `colspan`, `rowspan` | `th`, `td` | Standard table spanning |

### Using JSON format for lossless round-trips

If you need to preserve all TipTap document structure (e.g. for re-editing without loss), opt in to `:json` format:

```ruby
<%= render FlatPack::TextArea::Component.new(
  name: "body",
  rich_text: true,
  rich_text_options: { format: :json }
) %>
```

JSON-format values are TipTap document JSON and should be parsed with `JSON.parse` rather than rendered directly as HTML.

## Chat Components

The Chat component system follows the same security baseline as all other FlatPack components plus some chat-specific considerations.

### XSS Protection

- All components inherit from `FlatPack::BaseComponent`, which runs attributes through `FlatPack::AttributeSanitizer`.
- Content rendering uses Rails' `safe_join` and standard escaping — no dangerous HTML interpolation.

### Attachment URLs

`Chat::Attachment::Component` accepts an `href` prop. Sanitization is handled by BaseComponent, but applications should also validate attachment URLs server-side and use signed URLs for sensitive files.

### JavaScript (Stimulus)

- `chat_scroll_controller.js` — safe DOM manipulation via Stimulus targets; no `eval()` or `innerHTML` writes.

### Recommendations for Applications

1. **Sanitize message content** before rendering user-generated text:

   ```ruby
   <%= sanitize(@message.body, tags: %w[p br strong em]) %>
   ```

2. **Validate file uploads** server-side — check MIME type, size, and scan for malware.

3. **Authenticate real-time connections** (WebSockets/Action Cable) and rate-limit message sending.

4. **Use HTTPS** for all communication; consider end-to-end encryption for sensitive content.

## Input Components (NumberInput, DateInput, FileInput)

### XSS Prevention

All three components use `merge_attributes` which routes through `FlatPack::AttributeSanitizer`. No `.html_safe` is used on user-provided data; all HTML is generated with Rails content helpers.

### File Upload Security (FileInput)

`FileInput` blocks 18 dangerous file extensions at component initialisation time:

| Category | Extensions |
|----------|-----------|
| Windows executables | `.exe`, `.bat`, `.cmd`, `.scr`, `.com`, `.pif`, `.msi` |
| Scripts | `.sh`, `.vbs`, `.js`, `.ps1`, `.psm1`, `.hta` |
| Package files | `.jar`, `.app`, `.deb`, `.rpm`, `.apk` |

Passing any of these in the `accept` parameter raises `ArgumentError`. Client-side file-size validation provides UX feedback; server-side validation is **always required** in addition.

### NumberInput Validation

The `step` parameter must be a positive number; invalid values raise `ArgumentError`.

### DateInput

Date values are formatted via `strftime` — no unsafe date parsing from user input.

### Production Recommendations

- **Always validate file types and sizes on the server** — client-side checks are UX, not security.
- Scan uploaded files for malware before storing.
- Sanitize uploaded file names; store files outside the web root.
- Implement proper access controls for uploaded files.

## Security Implementation Notes

### Files

| File | Purpose |
|------|---------|
| `lib/flat_pack/attribute_sanitizer.rb` | Core URL and attribute validation (whitelist-based protocol check, dangerous-attribute filter, HTML entity-encoded attack detection). |
| `app/components/flat_pack/link/component.rb` | Secure link component; auto-adds `rel="noopener noreferrer"` for external links. |
| `app/components/flat_pack/base_component.rb` | `sanitize_args` method so every component inherits automatic attribute filtering. |
| `.github/workflows/security.yml` | Automated Brakeman + bundler-audit scans on every push; weekly scheduled scan. |

### Historical Fixes

| Vulnerability | Fix |
|---------------|-----|
| URL parsing bypass via `split(':')` | Replaced with robust regex `/\A([a-z][a-z0-9+.-]*):/i` |
| Silent URL rejection | Changed to explicit `ArgumentError` with generic message (no sensitive data leaked) |
| HTML entity bypass (`javascript&colon;`) | Added detection of entity-encoded colons |
| Overly broad entity detection | Narrowed pattern to colon entities only |

## Additional Resources

- [OWASP XSS Prevention Cheat Sheet](https://cheatsheetseries.owasp.org/cheatsheets/Cross_Site_Scripting_Prevention_Cheat_Sheet.html)
- [Rails Security Guide](https://guides.rubyonrails.org/security.html)
- [Content Security Policy Reference](https://content-security-policy.com/)
- [FlatPack Security Policy](../SECURITY.md)
