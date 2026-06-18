# firefox-policy-formula

A Salt formula with a SUSE Multi-Linux Manager / Uyuni form that manages the
system-wide Firefox enterprise policy file (`policies.json`) on client systems.

It is the "infrastructure as code" equivalent of the generating the policy
via a separate UI; instead of hand-editing JSON in a GUI, the policy
is structured pillar data, and Salt renders valid UTF-8 `policies.json`
idempotently across the whole fleet.

## What it does

On each assigned client, Firefox reads its policy from a distribution-independent
location on Linux: `/etc/firefox/policies/policies.json` (Firefox 60+). The
formula assembles the policy from the form values and writes that file via
`file.serialize`, so the JSON is always valid and never built by string
concatenation - no `curl`, no manual edits.

Covered policies (extend as needed): `DisableTelemetry`, `DisableFirefoxStudies`,
`DisableAppUpdate`, `DisablePocket`, `DisableFeedbackCommands`,
`DontCheckDefaultBrowser`, `NoDefaultBookmarks`, `BlockAboutConfig`,
`Certificates.ImportEnterpriseRoots`, first-run / post-update page suppression,
`Homepage`, `Bookmarks`, `ExtensionSettings`, `DNSOverHTTPS`, and `AIControls`
(the Firefox 149.0.2+ AI feature switches).

## Fallback location (second state)

By default the formula writes only the primary file. If you enable
`manage_distribution_fallback`, a second state (`distribution.sls`) writes a
byte-identical `policies.json` into the Firefox binary's distribution directory
(default `/usr/lib64/firefox/distribution/policies.json`, the SLES / openSUSE
install path). Both files share the same assembled policy dictionary via
`map.jinja`, so they can never drift; writing both is safe because the content
is identical regardless of which location a given Firefox build reads first.

## Layout

```
firefox-policy-formula/
|-- states/
|   |-- init.sls          # primary policies.json; pulls in distribution.sls when enabled
|   |-- distribution.sls  # fallback policies.json next to the Firefox binary
|   |-- map.jinja         # shared assembly: builds the policy dict + config from pillar
|-- metadata/
|   |-- form.yml          # the MLM/Uyuni form (maps to pillar firefox:...)
|   |-- metadata.yml      # formula description and UI grouping
|   |-- pillar.example    # example pillar matching the form output
|-- LICENSE
|-- README.md
```

Packaged as an RPM, the content installs to:

```
/usr/share/susemanager/formulas/states/firefox-policy/
/usr/share/susemanager/formulas/metadata/firefox-policy/
```

These are the same paths SUSE's own formulas use, so the formula appears in the
Web UI Formula Catalog automatically.

## Binary installation

Grab the RPMs from https://build.opensuse.org/project/show/home:mge1512:zoda/firefox-policy-formula

## Deploy into SUSE Multi-Linux Manager 5.1

The 5.x server is containerized; only declared volumes survive a container
re-creation. Two supported approaches:

### A. Derived server image (recommended - signed, upgrade-safe)

Build a thin image on top of the MLM server image that installs the signed RPM,
push it to your registry, and deploy/upgrade with `mgradm` using that image.
The formula then ships inside the image and survives container updates. This is
the same mechanism used to add custom CA certificates to the MLM server, and it
keeps the supply chain signed and reproducible.

### B. Copy into the running container (quick / lab)

From the container host:

```
tar -C /tmp -xzf firefox-policy-formula-0.2.1.tar.gz
mgrctl cp /tmp/firefox-policy-formula-0.2.1/states \
          server:/usr/share/susemanager/formulas/states/firefox-policy
mgrctl cp /tmp/firefox-policy-formula-0.2.1/metadata \
          server:/usr/share/susemanager/formulas/metadata/firefox-policy
mgrctl exec -- systemctl restart salt-master
```

Caveat: `/usr/share/...` lives in the image, not on a persistent volume, so
re-apply after a container update unless you use approach A. The documented
non-RPM alternative keeps metadata under `/srv/formula_metadata/firefox-policy/`
and states in a Salt file root; use that route if you prefer a persistent volume.
Check `mgrctl cp --help` for the exact copy syntax of your version.

## Use it

1. In the Web UI, open a System or a System Group, go to the **Formulas** tab,
   check **firefox-policy**, and save.
2. Open the new **Firefox-policy** subtab, set the values, and save.
3. Apply the highstate. The client writes `/etc/firefox/policies/policies.json`.
4. Verify on the client: open `about:policies` in Firefox; the active policies
   are listed there. Firefox must be restarted to pick up changes. The
   `policies.json` route is ignored if Firefox is already managed by Group Policy
   (Windows only - not relevant on Linux).

## Notes

- On SLES / openSUSE, keep `DisableAppUpdate` enabled: Firefox is updated through
  zypper, so the in-product updater should stay off.
- `Certificates.ImportEnterpriseRoots` makes Firefox trust the operating system
  certificate store, which is usually what you want with an enterprise or
  sovereign PKI.
- The Ubuntu Firefox snap reads the same `/etc/firefox/policies/` path but has its
  own quirks; on SLES/openSUSE (RPM `MozillaFirefox`) the path is the clean choice.
- `DNSOverHTTPS` can be set to `Enabled: false` with `Locked: true` to force name
  resolution through a sovereign / on-premise resolver instead of a DoH provider.
- `AIControls` lets you block individual Firefox AI features (sidebar chatbot,
  translations, smart tab groups, ...) fleet-wide; set a feature to "unset" in the
  form to leave it unmanaged. Requires Firefox 149.0.2+ (SmartWindow: 150+).
