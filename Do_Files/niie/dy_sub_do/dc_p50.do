

use `outdatadir'/$intdata2, clear
collapse (p50) $dc_vlist [weight=farmsrepresented], by(year)
