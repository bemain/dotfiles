# Platform Deep Link Configuration

Native config so the OS hands `https://yourdomain.com/...` URLs to the app instead of the browser. Required in addition to the `go_router` setup — routing alone handles in-app navigation only.

Both platforms need two halves: app-side declaration, and a file hosted on the domain proving you control it. Deep links fail silently when only one half is present.

## Android

**`android/app/src/main/AndroidManifest.xml`** — inside the `<activity>` tag for `.MainActivity`:

```xml
<intent-filter android:autoVerify="true">
    <action android:name="android.intent.action.VIEW" />
    <category android:name="android.intent.category.DEFAULT" />
    <category android:name="android.intent.category.BROWSABLE" />
    <data android:scheme="http" android:host="yourdomain.com" />
    <data android:scheme="https" />
</intent-filter>
```

**Hosted at `https://yourdomain.com/.well-known/assetlinks.json`:**

```json
[{
  "relation": ["delegate_permission/common.handle_all_urls"],
  "target": {
    "namespace": "android_app",
    "package_name": "com.yourcompany.yourapp",
    "sha256_cert_fingerprints": ["YOUR_SHA256_FINGERPRINT"]
  }
}]
```

The fingerprint must match the signing key of the installed build. A debug build verifies against the debug keystore fingerprint, not the release one — list both during development.

**Verify:**

```bash
adb shell 'am start -a android.intent.action.VIEW \
  -c android.intent.category.BROWSABLE \
  -d "https://yourdomain.com/details/123"' com.yourcompany.yourapp
```

## iOS

**`ios/Runner/Info.plist`:**

```xml
<key>FlutterDeepLinkingEnabled</key>
<true/>
```

Set this to `<false/>` if you use a third-party deep link plugin such as `app_links` — both handlers active means the link is consumed twice or not at all.

**`ios/Runner/Runner.entitlements`:**

```xml
<key>com.apple.developer.associated-domains</key>
<array>
  <string>applinks:yourdomain.com</string>
</array>
```

**Hosted at `https://yourdomain.com/.well-known/apple-app-site-association`** — served as JSON with **no `.json` extension**, over HTTPS, with no redirects:

```json
{
  "applinks": {
    "apps": [],
    "details": [{
      "appIDs": ["TEAM_ID.com.yourcompany.yourapp"],
      "paths": ["*"],
      "components": [{"/": "/*"}]
    }]
  }
}
```

**Verify:**

```bash
xcrun simctl openurl booted https://yourdomain.com/details/123
```

iOS caches the association file at install time. After changing it, delete and reinstall the app — editing the hosted file alone will not take effect on an already-installed build.
