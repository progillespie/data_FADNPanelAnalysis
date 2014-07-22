
capture macro drop dc_ha_vlist
global dc_ha_vlist ""
foreach var of global $dc_vlist{
	capture drop `var'_ha
	gen `var'_ha = `var'/fsizuaa
	global dc_ha_vlist "$dc_ha_vlist `var'_ha"
}

collapse (mean) $dc_ha_vlist [weight=farmsrepresented], by(year)
