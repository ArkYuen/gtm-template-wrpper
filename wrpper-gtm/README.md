# Wrpper Influencer Attribution — GTM Tag Template

Automatically attribute influencer-driven conversions to the originating creator. One GTM tag install — no custom code required on the advertiser's site.

## What it does

When a visitor arrives via a creator's wrapped link, Wrpper drops a first-party `_wrp` cookie on your site. This GTM tag reads that cookie and sends conversion events (purchases, add to cart, checkouts) to your Wrpper account, which then routes them into your Meta, TikTok, and Google ad accounts as first-party CAPI events.

**The full chain:**
1. Creator shares a Wrpper link
2. Fan clicks → `_wrp` attribution cookie is dropped on the advertiser's site
3. Fan makes a purchase → Shopify/WooCommerce fires a `purchase` dataLayer event
4. This GTM tag catches it, reads the `_wrp` cookie, and sends it to Wrpper
5. Wrpper routes the conversion into the advertiser's Meta/TikTok/Google CAPI

## Setup

### 1. Add the template to GTM

Search "Wrpper" in the GTM Community Template Gallery, or import `template.tpl` directly.

### 2. Configure the tag

| Field | Value |
|---|---|
| **Publishable Key** | Your `sf_pub_...` key from Wrpper Dashboard → Settings → API Keys |
| **Organization ID** | Your org UUID from Wrpper Dashboard → Settings |
| **Event Type** | Leave as "Auto-detect" for most installs |

### 3. Set the trigger

**Recommended:** Fire on the "All Pages" trigger. The tag is smart enough to only send events when it detects a Wrpper attribution cookie — it won't fire on unattributed traffic.

For conversion-only installs: fire on your existing purchase/thank-you page trigger.

### 4. Publish

Save and publish your GTM container. That's it.

## Auto-detected events

The tag automatically maps standard ecommerce dataLayer events to Wrpper event types:

| dataLayer event | Wrpper event |
|---|---|
| `purchase`, `transaction`, `order_completed` | Conversion |
| `add_to_cart`, `addToCart` | Add to cart |
| `begin_checkout`, `checkout`, `initiate_checkout` | Begin checkout |
| `page_view`, `pageview`, `virtualPageview` | Page view |

Works with both **GA4 ecommerce** and **Universal Analytics ecommerce** dataLayer formats — no extra configuration needed for Shopify, WooCommerce, or most ecommerce platforms.

## Advanced

### Revenue / order data

The tag automatically reads `ecommerce.transaction_id`, `ecommerce.value`, and `ecommerce.currency` from the dataLayer. You can also override these manually in the "Conversion Data" section of the tag config.

### Debug mode

Enable "Debug Logging" in Advanced Settings to see Wrpper activity in the browser console during testing. Disable before going live.

### Custom events

Set Event Type to "Custom" and specify an event name to send any arbitrary event to Wrpper (e.g. `lead_form_submit`, `trial_started`).

## Requirements

- A Wrpper account at [wrpper.com](https://wrpper.com)
- Google Tag Manager installed on the advertiser's website
- The `wrp.js` pixel does NOT need to be separately installed — this GTM tag handles attribution directly

## Support

- Documentation: [wrpper.com/docs/gtm](https://wrpper.com/docs/gtm)
- Dashboard: [app.wrpper.com](https://app.wrpper.com)
