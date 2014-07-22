

use `outdatadir'/$intdata2, clear
collapse (max) $dc_vlist [weight=farmsrepresented], by(year)
