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

Staff Admin requires the current root to be **Admin**. The root switcher (`all_workspaces`) lists Studio Workspace, Docs Workspace, and Admin. Hitting `/admin` (or an admin screen) while a workspace is selected returns an empty `403` (`head :forbidden`) — that looks like a blank page. From `/studio`, **Registered apps** switches the current root to Admin and opens `/admin/screens/oauth_clients`. Use the root switcher for other Admin entry points.

`ApplicationController` skips `authenticate_user!` for the public catalog and keeps the FlatPack `application` layout there. Authenticated Recording Studio screens use `recording_studio/default_layout`.

## Signup and login

Users owns auth screens (`recording_studio_user_auth_for :users`). OTP is off in the dummy initializer for a simpler password demo.

After sign-in or sign-up, the host sends people to `/studio` (not the public demo root). That page lists **Connected apps** for the signed-in user (empty until someone Connects). From there: Registered apps (switches to Admin, then the OauthClient list), or back to `/demo`. The full Connected apps screen also lives at `/recording_studio_oauth/connected_apps`.

Seed accounts after `bin/rails db:seed`:

- `admin@admin.com` / `Password` — workspace admin + Admin root access
- `demo@example.com` / `password123` — legacy FlatPack demo user

## OAuth Connect (Slack-style)

1. Sign in as `admin@admin.com`.
2. From `/studio`, open **Registered apps** (or switch the root switcher to Admin and open `/admin`).
3. Create or use the seeded public client **Seed MCP App**.
4. Start Connect at the OAuth engine authorize URL with that `client_id`, a registered redirect URI, and PKCE S256.
5. Pick a workspace Access row (Studio starts Connected; Docs starts as Reconnect).
6. Exchange the code at `/recording_studio_api/oauth/token` (token endpoint stays on the API mount).
7. Call MCP at `/recording_studio_mcp` with `Authorization: Bearer <access_token>`.

Discovery aliases:

- `/.well-known/oauth-authorization-server`
- `/.well-known/oauth-protected-resource`

## Recordables

Host models: `Workspace`, `Folder`, `Page`, `AdminRoot`, plus Users `People` / `Profile` and Site Settings / Attachable types. See `config/initializers/recording_studio.rb`.

## FlatPack component catalog API

Host-only. These routes live in the dummy initializer and are stripped from the vendored gem snapshot.

The public named API registers **only** these endpoints — not Workspace, Folder, Page, or `ping`. The public API would otherwise mirror every host recordable type; the dummy prepends a registry-only rule so HTTP, OpenAPI, and MCP share an empty type list. Catalog access is the Bearer HTTP routes below (and OpenAPI under `/recording_studio_api`).

MCP tools (`list` / `describe` / …) still only wrap registered recordable types. With none registered, `tools/list` keeps those tool names but the `type` enum is empty — reconnect ChatGPT after deploy so it drops Workspace / Folder / Page. Catalog MCP tools are not wired yet; call the HTTP routes with a Bearer token.

- `GET /recording_studio_api/api/v1/flatpack/components`
- `GET /recording_studio_api/api/v1/flatpack/components/:name`

Send a Bearer token. The gem builds the JSON with `FlatPack::ComponentCatalog.list` and `.show(name)`. The dummy maps an unknown name to `RecordingStudioApi::NotFoundError` (404). There is no catalog recordable and no Accessible check on a fake recording.

Name accepts `Button::Component`, `Button--Component`, or a `FlatPack::` prefix. `Workspace` / `Folder` / `Page` remain host models for Admin, OAuth Connect roots, and the root switcher — they are not API resources on this dummy.

## Local setup

```bash
cd test/dummy
bundle install
bin/rails db:prepare db:seed
bin/rails server
```

Database defaults: Postgres on localhost, user/password `postgres`/`postgres`, DBs `flatpack_dummy_development` and `flatpack_dummy_test`.

## Tunnel (ChatGPT / external MCP)

Development allows `*.trycloudflare.com`. Cloudflare sends `X-Forwarded-Proto: https`, so OAuth discovery stays on `https://` through the tunnel. Do not turn on blanket `assume_ssl` in development — that forces `https://127.0.0.1` and breaks local sign-in.

```bash
cd test/dummy
bin/rails server
cloudflared tunnel --url http://127.0.0.1:3000
```

Use the printed `https://….trycloudflare.com` URL:

- MCP: `https://….trycloudflare.com/recording_studio_mcp`
- Discovery: `https://….trycloudflare.com/.well-known/oauth-authorization-server`

Register the ChatGPT redirect on the OauthClient (`https://chatgpt.com/connector_platform_oauth_redirect`, or the exact URL ChatGPT shows). This stack does not do DCR — use a pre-registered public client. From Registered apps, use the row **Edit** action to change redirect URLs on an existing app.

Connect authorize screens turn Turbo off so Authorize can full-page redirect to the client callback. If Authorize looks stuck with a CORS/`Failed to fetch` error in the console, hard-refresh the authorize page (or restart Connect from ChatGPT) after that host fix.
