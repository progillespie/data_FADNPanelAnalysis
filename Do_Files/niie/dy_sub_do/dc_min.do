

use `outdatadir'/$intdata2, clear
collapse (min) $dc_vlist [weight=farmsrepresented], by(year)
