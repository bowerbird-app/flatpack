# Recording Studio on the FlatPack dummy

The deployable app in `test/dummy` is still the FlatPack component catalog. It also hosts a thin Recording Studio stack so API, OAuth Connect, and MCP can be exercised against the same process.

## Gems

Pinned in `test/dummy/Gemfile.common`:

- `recording_studio`
- `recording_studio_accessible`
- `recording_studio_user`
- `recording_studio_attachable`
- `recording_studio_site_settings`
- `recording_studio_admin`
- `recording_studio_api`
- `recording_studio_oauth`
- `recording_studio_mcp`
- `recording_studio_root_switchable`

Recording Studio host gems need Ruby `>= 3.3`. Postgres and Redis must be running.

## Public catalog vs gated host paths

Open without login:

- `/`, `/demo`, `/demo/*`
- `/themes`, `/pages/hero*`, `/mobile*`
- `/flat_pack`, `/up`, static assets

Gated (sign in or bearer token):

- `/users/*` profile screens after login; `/users/sign_in` and `/users/sign_up` stay public via Users auth controllers
- `/studio` (signed-in host home)
- `/admin` (Admin root + OauthClient registry)
- `/recording_studio_oauth` Connect
- `/recording_studio_api` resource server
- `/recording_studio_mcp` MCP endpoint

Staff Admin requires the current root to be **Admin**. The root switcher (`all_workspaces`) lists Studio Workspace, Docs Workspace, and Admin. Open Admin while a workspace is selected and Admin returns an empty `403` (`head :forbidden`) — that looks like a blank page. Switch to Admin first, then open `/admin` or `/admin/sections/oauth_apps`.

`ApplicationController` skips `authenticate_user!` for the public catalog and keeps the FlatPack `application` layout there. Authenticated Recording Studio screens use `recording_studio/default_layout`.

## Signup and login

Users owns auth screens (`recording_studio_user_auth_for :users`). OTP is off in the dummy initializer for a simpler password demo.

After sign-in or sign-up, the host sends people to `/studio` (not the public demo root). That page lists **Connected apps** for the signed-in user (empty until someone Connects). From there: Registered apps (admin), or back to `/demo`. The full Connected apps screen also lives at `/recording_studio_oauth/connected_apps`.

Seed accounts after `bin/rails db:seed`:

- `admin@admin.com` / `Password` — workspace admin + Admin root access
- `demo@example.com` / `password123` — legacy FlatPack demo user

## OAuth Connect (Slack-style)

1. Sign in as `admin@admin.com`.
2. Switch the current root to **Admin**.
3. Open Admin (`/admin`) and open **Registered apps**.
4. Create or use the seeded public client **Seed MCP App**.
5. Start Connect at the OAuth engine authorize URL with that `client_id`, a registered redirect URI, and PKCE S256.
6. Pick a workspace Access row (Studio starts Connected; Docs starts as Reconnect).
7. Exchange the code at `/recording_studio_api/oauth/token` (token endpoint stays on the API mount).
8. Call MCP at `/recording_studio_mcp` with `Authorization: Bearer <access_token>`.

Discovery aliases:

- `/.well-known/oauth-authorization-server`
- `/.well-known/oauth-protected-resource`

## Recordables

Host models: `Workspace`, `Folder`, `Page`, `AdminRoot`, plus Users `People` / `Profile` and Site Settings / Attachable types. See `config/initializers/recording_studio.rb`.

## Local setup

```bash
cd test/dummy
bundle install
bin/rails db:prepare db:seed
bin/rails server
```

Database defaults: Postgres on localhost, user/password `postgres`/`postgres`, DBs `flatpack_dummy_development` and `flatpack_dummy_test`.
