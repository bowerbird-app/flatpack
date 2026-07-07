# Security Policy

## Supported Versions

We take security seriously and provide security updates for the following versions:

| Version | Supported          |
| ------- | ------------------ |
| 1.x.x   | :white_check_mark: |
| < 1.0   | :x:                |

## Security Principles

FlatPack is built with security as a core principle. Our security approach focuses on four key pillars:

### 1. Injection Protection

**Protection Mechanisms:**
- **Rails Auto-Escaping**: All component templates use standard Rails auto-escaping to prevent XSS attacks
- **Attribute Sanitization**: The `FlatPack::AttributeSanitizer` utility validates all user-provided attributes
- **URL Validation**: All URLs (for buttons, links) are validated against a whitelist of safe protocols (http, https, mailto, tel)
- **Dangerous Attribute Filtering**: HTML event handlers (onclick, onmouseover, etc.) are automatically filtered out

**Blocked Protocols:**
- `javascript:` - Completely blocked to prevent script injection
- `data:` - Blocked to prevent data URL script execution
- `vbscript:` - Blocked to prevent VBScript execution

### 2. Logic Isolation

**Protection Mechanisms:**
- **Isolated Namespace**: All components are properly namespaced under `FlatPack::`
- **No Database Queries**: Components strictly forbid direct ActiveRecord queries
- **Primitive Data Only**: Components accept only Value Objects or primitives to prevent mass assignment risks

### 3. JavaScript Safety

**Protection Mechanisms:**
- **Stimulus Controllers**: All JavaScript interactions use Stimulus controllers
- **Importmaps**: No build step required, avoiding npm supply chain risks
- **CSP Compatible**: No `eval()` or `unsafe-inline` scripts required
- **No Inline Scripts**: All JavaScript is properly organized in separate files

### 4. Supply Chain Security

**Protection Mechanisms:**
- **Minimal Dependencies**: Only essential runtime dependencies (Rails, ViewComponent, tailwind_merge)
- **Automated Scanning**: GitHub Actions run Brakeman and Bundler-Audit on every push
- **Version Pinning**: Development dependencies pinned to specific versions
- **Regular Audits**: Weekly automated security audits via GitHub Actions

## Safe HTML Handling in Slots

When passing rich content to components, always use the sidecar pattern with blocks to ensure Rails handles escaping:

```ruby
# SAFE - Rails handles the buffer safely
<%= render FlatPack::CardComponent.new do |card| %>
  <% card.body do %>
    <p>This is <strong>Safe</strong> HTML handled by Rails.</p>
  <% end %>
<% end %>

# UNSAFE - Never do this
<%= render FlatPack::CardComponent.new(body: "<script>alert('xss')</script>".html_safe) %>
```

## Security Best Practices for Users

When using FlatPack components in your application:

### 1. Always validate user input

Even though FlatPack sanitizes attributes, you should still validate user input at the controller level:

```ruby
# Good
def create
  @user = User.new(user_params)
  if @user.save
    # ...
  end
end

private

def user_params
  params.require(:user).permit(:name, :email)
end
```

### 2. Use content_tag or tag helpers

For dynamic attributes, use Rails helpers instead of string interpolation:

```ruby
# Good
content_tag :div, "Content", class: dynamic_class

# Avoid
"<div class='#{dynamic_class}'>Content</div>".html_safe
```

### 3. Enable Content Security Policy

Configure a strict CSP in your Rails application:

```ruby
# config/initializers/content_security_policy.rb
Rails.application.config.content_security_policy do |policy|
  policy.default_src :self
  policy.script_src  :self
  policy.style_src   :self
end
```

FlatPack components are fully compatible with strict CSP policies.

### 4. Keep dependencies updated

Regularly update FlatPack and all other gems:

```bash
bundle update flat_pack
bundle audit check
```

### 5. Regular Security Audits

Run security audits on your application:

```bash
# Install security tools
gem install brakeman bundler-audit

# Run audits
brakeman --no-pager
bundle-audit check
```

## Security Testing

FlatPack includes comprehensive security testing:

- **Attribute Sanitization Tests**: Verify dangerous attributes are filtered
- **URL Validation Tests**: Verify unsafe URLs are rejected
- **XSS Prevention Tests**: Verify proper escaping in templates
- **Integration Tests**: Verify components behave safely in real applications

## Security Updates

Security updates are released as soon as possible after a vulnerability is confirmed:

1. **Critical Vulnerabilities**: Patched within 24-48 hours
2. **High Severity**: Patched within 7 days
3. **Medium/Low Severity**: Patched in next regular release

All security updates are clearly marked in the [CHANGELOG.md](CHANGELOG.md) with the `[SECURITY]` prefix.

## Hall of Fame

We'd like to thank the following individuals for responsibly disclosing security vulnerabilities:

*No reports yet - but we appreciate your vigilance!*
