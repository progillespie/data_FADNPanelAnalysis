/* This give the formula for totalouput in terms of its components.

    There is also an in complete listing of the variables used in the RICC
    documentation. This formula uses (somewhat) aggregated variables which
    are available in the Standard Results version of the FADN. At this time, 
    this is as far as we can break down total output. 

    The code from testto.do is also replicated here. This just checks that 
    the formula sums correctly. A less verbose way to accomplish that is to 
    run that file instead (virtually no commentary). 

    If count is 0 (or sufficiently low) then the sum is within an acceptable
    deviation tolerance (set in the if condition in the count command)  */


capture drop testto
capture drop df_testto

gen 	testto =                 		///
	cerealsvalue             	+	///------------
	sugarbeetvalue           	+	///
	fruitvalue               	+	///
	foragecropsvalue         	+	///
	proteincropsvalue        	+	///
	oilseedrapevalue         	+	///
	citrusfruitvalue         	+	/// totaloutputcrops
	othercropoutputvalue     	+	///
	energycropsvalue         	+	///
	industrialcropsvalue     	+	///
	wineandgrapesvalue       	+	///
	potatoesvalue            	+	///
	vegetablesandflowersvalue	+	///
	olivesandoliveoilvalue   	+	///------------
	pigmeat                  	+	///
	eggs	                 	+	///
	cowsmilkandmilkproducts  	+	///
	sheepandgoats            	+	/// totaloutputlivestock
	ewesandgoatsmilk         	+	///
	beefandveal              	+	///
	poultrymeat              	+	///
	otherlivestockandproducts	+	///------------
	otheroutput              
	
gen df_testto = totaloutput - testto
count if df_testto > 0.05 & df_testto < . 


qui summarize df_testto
di "The maximum difference between testto and totaloutput is `r(max)'."

/* Definitions from RICC 882 and RICC 1256

-----------------------------------------------------------------
Total output	totaloutput           	SE131 

	is defined as

  SE135 - SE206 + SE256 (see RICC 882)

SE135	totaloutputcrops    	
SE206	totaloutputlivestock    
SE256	otheroutput

which can be broken down as far as the formula given


-----------------------------------------------------------------


RICC 882 gives individual line items in the formulae for the 
  aggregate components above. These are not available in the 
  Standard Results version of the data, and even with our extended
  data, many items will be missing. I've summarised the definitions
  from a combination of RICC 882 and RICC 1256 for reference below. 



-----------------------------------------------------------------
-----------------------------------------------------------------
In RICC 882, sometimes the formula is given in terms of tables from 
 the FARM RETURN (RICC 1256). Then you must look up the table, variable
 category, and column heading (listed after the table). For output variable, 
 the calculation always follows the same basic formula. E.G. ...

... Total output crops and crop production	SE135
	
	is defined as

	[K120(7..10)..148(7..10)] - [K120(6)..148(6)] +
	[K150(7..10)..161(7..10)] - [K150(6)..161(6)]

	so thats these column headings

  ( 7) Sales                                       +
  ( 8) Farmhouse consumption and benefits in kind  +
  ( 9) Closing valuation                           +
  (10) Farm use                                    -
  ( 6) Opening valuation                           

	and you repeat this sum for each of these category  
	(means theres a variable for each category-column
	 combination)
-----------------------------------------------------------------
-----------------------------------------------------------------



Categories for Total output crops and crop production SE135
-----------------------------------------------------------------
120 Common wheat and spelt
121 Durum wheat
122 Rye (including meslin)
123 Barley
124 Oats
125 Summer cereal mixes
126 Grain maize
127 Rice
128 Other cereals
129 Dry pulses
130 Potatoes
131 Sugar beet
132 Herbaceous oil seeds crops
133 Hops
134 Tobacco
135 Other industrial crops
136 Open ground field scale
137 Open ground market garden
138 Under shelter
139 Mushrooms
140 Flowers and ornamental plants grown in the open
141 Flowers and ornamental plants grown under shelter
142 Grass seed
143 Other seed
144 Fodder roots and brassicas
145 Other fodder plants
146 Fallows and set aside
147 Temporary grass
148 Other arable crops
150 Permanent pasture
151 Rough grazing
152 Fruit and berry orchards
153 Citrus fruit orchards
154 Olive groves
155 Vines
156 Permanent crops grown under shelter
157 Nurseries
158 Other permanent crops
159 Growth of young plantations
160 Processed products from crops from holding and not separately mentioned 
161 Crop by-products



Categories for Total output livestock & livestock products SE206
-----------------------------------------------------------------
E51 Equines net sales
E52 Cattle net sales
E53 N/A (this line is missing from the FARM RETURN)
E54 Sheep net sales
E55 Goats net sales
E56 Pigs net sales
E57 Poultry net sales
E58 Other animals net sales
K162 Cow's milk
K163 Products of cow's milk
K164 Sheep's milk
K165 Goats' milk
K166 Wool 
K167 Products of sheep's milk
K168 Products of goat's milk
K169 Hen's eggs
K170 Other animal products
K171 Contract rearing
K313 Honey and products of beekeeping
 (J) Change in value of cattle
 (L) Change in value of pigs
 (M) Change in value of sheep and goats
 (P) Change in value of equines
 (K) Change in value of poultry
 (N) Change in value of livestock (other animals,e.g. beehives, rabbits,etc)



Categories for Other output SE256
-----------------------------------------------------------------
149 Land ready for sowing, leased to third parties
172 Receipts from occasional letting of fodder areas
173 Woodland area
174 Sales of felled timber
175 Sales of standing timber
176 Other forestry products (Includes cork, pine, resin)
177 Contract work for others 
178 Interest on liquid assets
179 Farm tourism
180 Receipts relating to previous accounting year
181 Other products and receipts
 


*/




*/
