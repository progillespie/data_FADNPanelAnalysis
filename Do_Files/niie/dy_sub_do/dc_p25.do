

use `outdatadir'/$intdata2, clear
collapse (p25) $dc_vlist [weight=farmsrepresented], by(year)
