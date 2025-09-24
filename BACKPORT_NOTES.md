### Disabled
- testmode support removed (testmode.o) due to absent cfg80211 testmode APIs on SteamOS 6.11/mac80211 base.

### Added Shared Headers
- spectral_common.h
- testmode_i.h

### Module Signing
Not signed by default (taints kernel). Optional local signing supported via MOK workflow.
