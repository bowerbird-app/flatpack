# Email Template Example

## Purpose
Provide a ready-to-use transactional email composition that combines `EmailCard`, `EmailButton`, and `EmailFooterLinks`.

## When to use
Use Email Template Example as a reference composition when assembling full transactional email bodies from FlatPack's email-safe primitives.

## Class
- Primary: `FlatPack::EmailTemplateExample::Component`

## Props
None.

## Slots
None.

## Variants
None.

## Example
```erb
<%= render FlatPack::EmailTemplateExample::Component.new %>
```

## Accessibility
- Uses semantic heading and paragraph text in the composed template body.
- Uses real anchor links for all call-to-action and footer destinations.

## Dependencies
- FlatPack install generator setup (`rails generate flat_pack:install`).
- Composes `FlatPack::EmailCard::Component`, `FlatPack::EmailButton::Component`, and `FlatPack::EmailFooterLinks::Component`.
