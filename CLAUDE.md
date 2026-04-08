# CLAUDE.md — Wrpper GTM Community Template

This file is the standing context for every Claude Code session on this codebase.

---

## What This Is

A **Google Tag Manager Community Template** that lets advertisers attribute
influencer-driven conversions with one GTM tag — no custom code required.

The tag reads the `_wrp` first-party cookie (dropped by Wrpper's redirect flow)
and sends conversion events to `api.wrpper.com`, which then fans them out to
Meta CAPI, TikTok, Snapchat, LinkedIn, Reddit, Pinterest, and GA4.

---

## How It Works

```
Creator shares Wrpper link → fan clicks → redirect drops _wrp cookie
→ fan browses advertiser site → dataLayer fires purchase/add_to_cart/etc.
→ this GTM tag reads _wrp cookie → sends event to Wrpper API
→ backend routes to advertiser's ad platforms via CAPI
```

---

## File Structure

```
template.tpl       # The GTM template — config, sandboxed JS, permissions, tests
metadata.yaml      # Version tracking for GTM gallery
README.md          # Setup instructions for advertisers
LICENSE            # Apache 2.0
```

**`template.tpl` sections:**
- `___INFO___` — tag metadata (name: `wrpper_v3.02`, categories: affiliate/attribution/advertising)
- `___TEMPLATE_PARAMETERS___` — user-facing config fields (publishable key, org ID, event type, etc.)
- `___SANDBOXED_JS_FOR_WEB_TEMPLATE___` — the actual tag logic
- `___WEB_PERMISSIONS___` — GTM sandbox permissions (send_pixel, get_cookies, get_url, read_data_layer, logging)
- `___TESTS___` — two test scenarios

---

## Tag Config Fields

| Field | Required | Default | Notes |
|---|---|---|---|
| Publishable Key | Yes | — | `sf_pub_*` from Wrpper dashboard |
| Organization ID | Yes | — | UUID from Wrpper dashboard |
| API Endpoint | Yes | `https://api.wrpper.com` | Change only for custom deployments |
| Event Type | Yes | `auto` | Auto-detect from dataLayer, or explicit (conversion, add_to_cart, begin_checkout, pageview, custom) |
| Custom Event Name | If custom | — | Only shown when Event Type = custom |
| Order ID | No | — | From dataLayer or manual override |
| Revenue Value | No | — | In cents (4999 = $49.99) |
| Currency | No | `USD` | ISO 3-letter code |
| Click Cookie Name | No | `_wrp` | Don't change unless told to |
| URL Click Parameter | No | `inf_click_id` | Don't change unless told to |
| Debug Logging | No | `false` | Console logging for testing |

---

## Event Detection

Auto-detect maps these dataLayer events:

| dataLayer event | Wrpper event type | API endpoint |
|---|---|---|
| `purchase`, `transaction`, `order_completed` | `conversion` | `/v1/events/conversion` |
| `add_to_cart`, `addToCart` | `add_to_cart` | `/v1/events/custom` |
| `begin_checkout`, `checkout`, `initiate_checkout` | `begin_checkout` | `/v1/events/custom` |
| `page_view`, `pageview`, `virtualPageview` | `pageview` | `/v1/events/pageview` |

Supports both GA4 and Universal Analytics ecommerce dataLayer formats.

---

## What's DONE

- Tag template with all config fields and sandboxed JS
- Auto-detection of ecommerce events from dataLayer
- Cookie reading (`_wrp`) and URL param fallback (`inf_click_id`)
- Ecommerce data extraction (order ID, revenue, currency) from both GA4 and UA formats
- Event routing to correct Wrpper API endpoints
- Debug logging mode
- Two test scenarios
- GTM sandbox permissions properly scoped
- README with setup instructions

---

## REMAINING TASKS

### TASK 1: Publish to GTM Community Gallery
**Priority: HIGH — currently manual import only**

The template works but hasn't been submitted to Google's Community Template Gallery.

**What to do:**
1. Follow Google's submission process: https://developers.google.com/tag-manager/templates/gallery
2. Ensure `metadata.yaml` has the correct SHA for the latest commit
3. The template must pass Google's automated review
4. After approval, advertisers can find it by searching "Wrpper" in GTM

**Note:** This is a manual process, not a code change.

---

### TASK 2: Add Support for wrp.js Pixel Events
**Priority: MEDIUM — alternative to GTM-only flow**

Currently the tag sends events directly to the Wrpper API via `sendPixel`.
Some advertisers may want the tag to load `wrp.js` instead, which handles
cookie management, session tracking, and heartbeat pings natively.

**What to do:**
1. Add a config option: "Integration Mode" — `api` (current default) vs `pixel`
2. In `pixel` mode, inject `wrp.js` via `injectScript` permission instead of `sendPixel`
3. Configure wrp.js with the publishable key and org ID
4. Let wrp.js handle event detection and firing
5. Add `inject_script` permission for `https://api.wrpper.com/static/wrp.js`

---

### TASK 3: Add Refund Event Support
**Priority: LOW — edge case**

The backend supports refund events (`/v1/events/refund`) but the GTM tag
doesn't detect or send them.

**What to do:**
1. Add `refund` to the Event Type selector
2. Map dataLayer events `refund`, `order_refunded` → refund
3. Extract `original_order_id` and `refund_amount_cents` from ecommerce data
4. Send to `/v1/events/refund`

---

## Companion Repos

- **Backend:** `github.com/ArkYuen/wrpper` (private) — FastAPI API at `api.wrpper.com`
- **Frontend:** `github.com/ArkYuen/wrpper-app` — React dashboard at `app.wrpper.com`

Both have their own CLAUDE.md files with detailed task lists.

---

## Rules

1. **Do not modify the `___INFO___` section** without updating `metadata.yaml`
2. **Test changes in GTM preview mode** before committing
3. **Keep sandboxed JS simple** — no external libraries, only GTM sandbox APIs
4. **All API calls go to `api.wrpper.com`** — update `___WEB_PERMISSIONS___` if adding new domains
5. **Revenue is always in cents** — the backend expects cents, not dollars
