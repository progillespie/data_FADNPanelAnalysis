

use `outdatadir'/$intdata2, clear
collapse (p75) $dc_vlist [weight=farmsrepresented], by(year)
