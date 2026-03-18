___TERMS_OF_SERVICE___

By creating or modifying this file you agree to Google Tag Manager's Community
Template Gallery Developer Terms of Service available at
https://developers.google.com/tag-manager/gallery-tos (or such other URL as
Google may provide), as modified from time to time.

___INFO___

{
  "displayName": "Wrpper Influencer Attribution",
  "description": "Automatically attributes influencer-driven conversions to the originating creator. Reads the Wrpper click cookie and sends conversion events (purchase, add_to_cart, begin_checkout) to your Wrpper account — no custom code required. One install, full attribution.",
  "categories": ["AFFILIATE_MARKETING", "ATTRIBUTION", "ADVERTISING"],
  "id": "cvt_wrpper_influencer_attribution",
  "type": "TAG",
  "version": 1,
  "securityGroups": [],
  "containerContexts": ["WEB"],
  "tosUrl": "https://wrpper.com/terms",
  "privacyPolicyUrl": "https://wrpper.com/privacy"
}

___TEMPLATE_PARAMETERS___

[
  {
    "type": "TEXT",
    "name": "publishableKey",
    "displayName": "Publishable Key",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "Your Wrpper publishable key (starts with sf_pub_). Find this in your Wrpper dashboard under Settings → API Keys.",
    "placeholder": "sf_pub_xxxxxxxxxxxxxxxxxxxx"
  },
  {
    "type": "TEXT",
    "name": "orgId",
    "displayName": "Organization ID",
    "simpleValueType": true,
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ],
    "help": "Your Wrpper Organization ID (UUID format). Find this in your Wrpper dashboard under Settings.",
    "placeholder": "xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
  },
  {
    "type": "TEXT",
    "name": "apiEndpoint",
    "displayName": "API Endpoint",
    "simpleValueType": true,
    "defaultValue": "https://api.wrpper.com",
    "help": "Leave as default unless you have a custom endpoint.",
    "valueValidators": [
      {
        "type": "NON_EMPTY"
      }
    ]
  },
  {
    "type": "SELECT",
    "name": "eventType",
    "displayName": "Event Type",
    "selectItems": [
      {
        "value": "auto",
        "displayValue": "Auto-detect from dataLayer (recommended)"
      },
      {
        "value": "conversion",
        "displayValue": "Conversion / Purchase"
      },
      {
        "value": "add_to_cart",
        "displayValue": "Add to Cart"
      },
      {
        "value": "begin_checkout",
        "displayValue": "Begin Checkout"
      },
      {
        "value": "pageview",
        "displayValue": "Page View"
      },
      {
        "value": "custom",
        "displayValue": "Custom Event"
      }
    ],
    "simpleValueType": true,
    "defaultValue": "auto",
    "help": "Auto-detect reads the event name from the dataLayer automatically. Use a specific type if you want to fire this tag on a single event only."
  },
  {
    "type": "TEXT",
    "name": "customEventName",
    "displayName": "Custom Event Name",
    "simpleValueType": true,
    "enablingConditions": [
      {
        "paramName": "eventType",
        "paramValue": "custom",
        "type": "EQUALS"
      }
    ],
    "help": "The name of the custom event to send to Wrpper.",
    "placeholder": "e.g. lead_form_submit"
  },
  {
    "type": "GROUP",
    "name": "conversionData",
    "displayName": "Conversion Data (optional)",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "TEXT",
        "name": "orderId",
        "displayName": "Order ID",
        "simpleValueType": true,
        "help": "The order or transaction ID. Use a dataLayer variable, e.g. {{dlv - ecommerce.purchase.actionField.id}}",
        "placeholder": "{{Order ID variable}}"
      },
      {
        "type": "TEXT",
        "name": "revenueValue",
        "displayName": "Revenue Value (in cents)",
        "simpleValueType": true,
        "help": "Order value in cents (e.g. 4999 for $49.99). Use a dataLayer variable.",
        "placeholder": "{{Revenue variable}}"
      },
      {
        "type": "TEXT",
        "name": "currency",
        "displayName": "Currency",
        "simpleValueType": true,
        "defaultValue": "USD",
        "help": "3-letter ISO currency code."
      }
    ]
  },
  {
    "type": "GROUP",
    "name": "advancedSettings",
    "displayName": "Advanced Settings",
    "groupStyle": "ZIPPY_CLOSED",
    "subParams": [
      {
        "type": "TEXT",
        "name": "cookieName",
        "displayName": "Click Cookie Name",
        "simpleValueType": true,
        "defaultValue": "_wrp",
        "help": "The cookie name Wrpper uses to store click attribution. Leave as default unless instructed otherwise."
      },
      {
        "type": "TEXT",
        "name": "clickParam",
        "displayName": "URL Click Parameter",
        "simpleValueType": true,
        "defaultValue": "inf_click_id",
        "help": "The URL parameter that carries the influencer click ID. Leave as default."
      },
      {
        "type": "CHECKBOX",
        "name": "debugMode",
        "displayName": "Enable Debug Logging",
        "simpleValueType": true,
        "defaultValue": false,
        "help": "When enabled, logs Wrpper activity to the browser console. Disable in production."
      }
    ]
  }
]

___SANDBOXED_JS_FOR_WEB_TEMPLATE___

// Wrpper Influencer Attribution Tag — GTM Community Template
// Sends influencer-attributed conversion events to the Wrpper API.
// Reads the _wrp first-party cookie for click attribution.

var sendHttpRequest = require('sendHttpRequest');
var getCookieValues = require('getCookieValues');
var getUrl = require('getUrl');
var parseUrl = require('parseUrl');
var getQueryParameters = require('getQueryParameters');
var JSON = require('JSON');
var Math = require('Math');
var logToConsole = require('logToConsole');
var makeString = require('makeString');
var makeNumber = require('makeNumber');
var getTimestampMillis = require('getTimestampMillis');
var generateRandom = require('generateRandom');
var copyFromDataLayer = require('copyFromDataLayer');

// --- Config ---
var publishableKey = data.publishableKey;
var orgId = data.orgId;
var apiEndpoint = data.apiEndpoint || 'https://api.wrpper.com';
var cookieName = data.cookieName || '_wrp';
var clickParam = data.clickParam || 'inf_click_id';
var debugMode = data.debugMode || false;

function log(msg, obj) {
  if (debugMode) {
    if (obj) {
      logToConsole('[Wrpper] ' + msg, obj);
    } else {
      logToConsole('[Wrpper] ' + msg);
    }
  }
}

// --- Read click ID from cookie or URL param ---
function getClickId() {
  // 1. Try the _wrp cookie first (return visits)
  var cookieValues = getCookieValues(cookieName);
  if (cookieValues && cookieValues.length > 0) {
    var cookieVal = cookieValues[0];
    // Cookie stores JSON: {"click_id":"...","ts":...}
    // Try parsing, fall back to raw value for legacy format
    try {
      var parsed = JSON.parse(cookieVal);
      if (parsed && parsed.click_id) {
        log('Click ID from cookie', parsed.click_id);
        return parsed.click_id;
      }
    } catch(e) {
      // Raw value
      log('Click ID from cookie (raw)', cookieVal);
      return cookieVal;
    }
  }

  // 2. Fall back to URL param (first visit, cookie not yet set)
  var clickId = getQueryParameters(clickParam);
  if (clickId) {
    log('Click ID from URL param', clickId);
    return clickId;
  }

  log('No click ID found — event will be sent without attribution');
  return null;
}

// --- Determine event type ---
function resolveEventType() {
  var configured = data.eventType || 'auto';

  if (configured !== 'auto') {
    return configured;
  }

  // Auto-detect from dataLayer event name
  var dlEvent = copyFromDataLayer('event');
  if (!dlEvent) return 'pageview';

  var eventMap = {
    'purchase': 'conversion',
    'transaction': 'conversion',
    'order_completed': 'conversion',
    'checkout_complete': 'conversion',
    'add_to_cart': 'add_to_cart',
    'addToCart': 'add_to_cart',
    'begin_checkout': 'begin_checkout',
    'checkout': 'begin_checkout',
    'initiate_checkout': 'begin_checkout',
    'page_view': 'pageview',
    'pageview': 'pageview',
    'virtualPageview': 'pageview'
  };

  var mapped = eventMap[dlEvent];
  if (mapped) {
    log('Auto-detected event type', mapped + ' (from dataLayer event: ' + dlEvent + ')');
    return mapped;
  }

  // Pass through unknown events as custom
  log('Unknown dataLayer event, sending as custom', dlEvent);
  return 'custom';
}

// --- Extract ecommerce data from dataLayer ---
function getEcommerceData() {
  // Support both GA4 ecommerce and UA ecommerce formats
  var ecommerce = copyFromDataLayer('ecommerce');

  var orderId = data.orderId || '';
  var revenue = data.revenueValue || '';
  var currency = data.currency || 'USD';

  if (ecommerce) {
    // GA4 format
    if (ecommerce.transaction_id) {
      orderId = orderId || makeString(ecommerce.transaction_id);
    }
    if (ecommerce.value) {
      // GA4 sends value in dollars — convert to cents
      revenue = revenue || makeString(Math.round(makeNumber(ecommerce.value) * 100));
    }
    if (ecommerce.currency) {
      currency = ecommerce.currency;
    }

    // UA format
    if (ecommerce.purchase && ecommerce.purchase.actionField) {
      var af = ecommerce.purchase.actionField;
      orderId = orderId || makeString(af.id || '');
      if (af.revenue) {
        revenue = revenue || makeString(Math.round(makeNumber(af.revenue) * 100));
      }
    }
  }

  return {
    order_id: orderId,
    revenue_cents: revenue ? makeNumber(revenue) : null,
    currency: currency
  };
}

// --- Build event payload ---
function buildPayload(eventType, clickId) {
  var ecom = getEcommerceData();
  var eventId = makeString(getTimestampMillis()) + '_' + makeString(generateRandom(100000, 999999));

  var payload = {
    inf_click_id: clickId || '',
    organization_id: orgId,
    event_id: eventId,
    event_type: eventType,
    page_url: getUrl(),
    timestamp: getTimestampMillis()
  };

  if (eventType === 'conversion') {
    if (ecom.order_id) payload.order_id = ecom.order_id;
    if (ecom.revenue_cents) payload.revenue_cents = ecom.revenue_cents;
    payload.currency = ecom.currency;
  }

  if (eventType === 'add_to_cart' || eventType === 'begin_checkout') {
    if (ecom.revenue_cents) payload.value_cents = ecom.revenue_cents;
    payload.currency = ecom.currency;
  }

  if (eventType === 'custom') {
    payload.event_name = data.customEventName || copyFromDataLayer('event') || 'custom';
  }

  return payload;
}

// --- Send event to Wrpper API ---
function sendEvent(eventType, clickId) {
  var payload = buildPayload(eventType, clickId);
  var url;

  var endpointMap = {
    'conversion': '/v1/events/conversion',
    'add_to_cart': '/v1/events/custom',
    'begin_checkout': '/v1/events/custom',
    'pageview': '/v1/events/pageview',
    'session': '/v1/events/session',
    'custom': '/v1/events/custom'
  };

  // add_to_cart and begin_checkout go to custom with event_name set
  if (eventType === 'add_to_cart' || eventType === 'begin_checkout') {
    payload.event_name = eventType;
  }

  url = apiEndpoint + (endpointMap[eventType] || '/v1/events/custom');

  log('Sending event', {type: eventType, url: url, payload: payload});

  sendHttpRequest(
    url,
    function(statusCode) {
      if (statusCode >= 200 && statusCode < 300) {
        log('Event sent successfully', {status: statusCode, type: eventType});
        data.gtmOnSuccess();
      } else {
        log('Event send failed', {status: statusCode, type: eventType});
        data.gtmOnFailure();
      }
    },
    {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ' + publishableKey,
        'X-Wrpper-Source': 'gtm-template'
      }
    },
    JSON.stringify(payload)
  );
}

// --- Main ---
if (!publishableKey || !orgId) {
  log('Missing publishableKey or orgId — tag inactive');
  data.gtmOnFailure();
  return;
}

var clickId = getClickId();
var eventType = resolveEventType();

// Only send if we have attribution OR it's an explicit non-auto event
// (don't fire pageviews for every visitor, only attributed ones)
var isExplicitEvent = data.eventType && data.eventType !== 'auto';
var isConversionEvent = eventType === 'conversion' || eventType === 'add_to_cart' || eventType === 'begin_checkout';

if (clickId || isExplicitEvent || isConversionEvent) {
  sendEvent(eventType, clickId);
} else {
  log('No attribution and no explicit event config — skipping');
  data.gtmOnSuccess();
}


___WEB_PERMISSIONS___

[
  {
    "instance": {
      "key": {
        "publicId": "send_http",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedUrls",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "urls",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "https://api.wrpper.com/"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_cookies",
        "versionId": "1"
      },
      "param": [
        {
          "key": "cookieAccess",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "cookieNames",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "_wrp"
              }
            ]
          }
        }
      ]
    },
    "clientAnnotations": {
      "isEditedByUser": true
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "get_url",
        "versionId": "1"
      },
      "param": [
        {
          "key": "urlParts",
          "value": {
            "type": 1,
            "string": "any"
          }
        },
        {
          "key": "queriesAllowed",
          "value": {
            "type": 1,
            "string": "any"
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "read_data_layer",
        "versionId": "1"
      },
      "param": [
        {
          "key": "allowedKeys",
          "value": {
            "type": 1,
            "string": "specific"
          }
        },
        {
          "key": "keyPatterns",
          "value": {
            "type": 2,
            "listItem": [
              {
                "type": 1,
                "string": "event"
              },
              {
                "type": 1,
                "string": "ecommerce"
              },
              {
                "type": 1,
                "string": "ecommerce.*"
              }
            ]
          }
        }
      ]
    },
    "isRequired": true
  },
  {
    "instance": {
      "key": {
        "publicId": "logging",
        "versionId": "1"
      },
      "param": [
        {
          "key": "environments",
          "value": {
            "type": 1,
            "string": "debug"
          }
        }
      ]
    },
    "isRequired": true
  }
]

___NOTES___

Created by Wrpper (https://wrpper.com).
Influencer attribution tracking — from click to conversion.
