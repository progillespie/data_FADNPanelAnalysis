********************************************************
*       Patrick R. Gillespie                            
*       Walsh Fellow                    
*	FADN_IGM/sub_do/countrylabels.do
********************************************************
*   Creates value labels.
********************************************************




********************************************************
*  country 
********************************************************
*   creates 2 character, 3 character, and full name value 
*   labels for countries, and a numeric var countrycode
*   to attach it to. The variable country is unchanged.
********************************************************


*first create countrycode
label define ms2 1 "BE" 2 "BG" 3 "CY" 4 "CZ" 5 "DK" 6 "DE" 7 "ES" 8 "EE" 9 "FR" 10 "HU" 11 "IT" 12 "LT" 13 "LU" 14 "LV" 15 "NL" 16 "AT" 17 "PL" 18 "PT" 19 "FI" 20 "RO" 21 "SE" 22 "SK" 23 "SI" 24 "UK" 25 "IE"
label save ms2 using sub_do/ms2, replace


label define ms3 1 "BEL" 2 "BGR" 3 "CYP" 4 "CZE" 5 "DAN" 6 "DEU" 7 "ESP" 8 "EST" 9 "FRA" 10 "HUN" 11 "ITA" 12 "LTU" 13 "LUX" 14 "LVA" 15 "NED" 16 "OST" 17 "POL" 18 "POR" 19 "SUO" 20 "ROU" 21 "SVE" 22 "SVK" 23 "SVN" 24 "UKI" 25 "IRE"
label save ms3 using sub_do/ms3, replace


label define msname 1 "Belgium" 2 "Bulgaria" 3 "Cyprus" 4 "CzechRepublic" 5 "Denmark" 6 "Germany" 7 "Spain" 8 "Estonia" 9 "France" 10 "Hungary" 11 "Italy" 12 "Lithuania" 13 "Luxembourg" 14 "Latvia" 15 "Netherlands" 16 "Austria" 17 "Poland" 18 "Portugal" 19 "Finland" 20 "Romania" 21 "Sweden" 22 "Slovakia" 23 "Slovenia" 24 "UnitedKingdom" 25 "Ireland"
label save msname using sub_do/msname, replace


gen 	countrycode = .
replace countrycode = 1 if country== "BEL"
replace countrycode = 2 if country=="BGR"
replace countrycode = 3 if country=="CYP"
replace countrycode = 4 if country=="CZE"
replace countrycode = 5 if country=="DAN"
replace countrycode = 6 if country=="DEU"
replace countrycode = 7 if country=="ESP"
replace countrycode = 8 if country=="EST"
replace countrycode = 9 if country=="FRA"
replace countrycode = 10 if country=="HUN"
replace countrycode = 11 if country=="ITA"
replace countrycode = 12 if country=="LTU"
replace countrycode = 13 if country=="LUX"
replace countrycode = 14 if country=="LVA"
replace countrycode = 15 if country=="NED"
replace countrycode = 16 if country=="OST"
replace countrycode = 17 if country=="POL"
replace countrycode = 18 if country=="POR"
replace countrycode = 19 if country=="SUO"
replace countrycode = 20 if country=="ROU"
replace countrycode = 21 if country=="SVE"
replace countrycode = 22 if country=="SVK"
replace countrycode = 23 if country=="SVN"
replace countrycode = 24 if country=="UKI"
replace countrycode = 25 if country=="IRE"


* then label it
label values countrycode $countrylabels




********************************************************
* year
********************************************************
label define yy 1999 "'99" 2000 "'00" 2001 "'01" 2002 "'02" 2003 "'03" 2004 "'04" 2005 "'05" 2006 "'06" 2007 "'07"
label values year yy




********************************************************
* altitudezone
********************************************************
label define altitudezone 1 "< 300 m" 2 "300 - 600 m" 3 "> 600 m" 4 "data not available"
capture label value altitudezone altitudezone




********************************************************
* FADN regions
********************************************************
* source: http://ec.europa.eu/agriculture/rica/reference_en.cfm#bview

* Belgium
label define region 340	"Belgium"
label define region 341	"Vlaanderen", add
label define region 342	"BruxellesBrussel", add
label define region 343	"Wallonie", add


* Bulgaria
label define region 831	"Severozapaden", add
label define region 832	"Severen tsentralen", add
label define region 833	"Severoiztochen", add
label define region 834	"Yugozapaden", add
label define region 835	"Yuzhentsentralen", add
label define region 836	"Yugoiztochen", add


* Czech Republic
label define region 745	"CzechRepublic", add


* Denmark 
label define region 370	"Denmark ", add


* Germany
label define region 10	"SchleswigHolstein", add
label define region 20	"Hamburg", add
label define region 30	"Niedersachsen", add
label define region 40	"Bremen", add
label define region 50	"NordrheinWestfalen", add
label define region 60	"Hessen", add
label define region 70	"RheinlandPfalz", add
label define region 80	"BadenWürttemberg", add
label define region 90	"Bayern", add
label define region 100	"Saarland", add
label define region 110	"Berlin", add
label define region 112	"Brandenburg", add
label define region 113	"MecklenburgVorpommern", add
label define region 114	"Sachsen", add
label define region 115	"SachsenAnhalt", add
label define region 116	"Thueringen", add


* Estonia
label define region 755	"Estonia", add


* Ireland
label define region 380	"Ireland", add


* Greece
label define region 450	"MakedoniaThraki", add
label define region 460	"IpirosPeloponissosNissiIoniou", add
label define region 470	"Thessalia", add
label define region 480	"StereaEllasNissiEgaeouKriti", add


* Spain
label define region 500	"Galicia", add
label define region 505	"Asturias", add
label define region 510	"Cantabria", add
label define region 515	"PaisVasco", add
label define region 520	"Navarra", add
label define region 525	"LaRioja", add
label define region 530	"Aragón", add
label define region 535	"Cataluna", add
label define region 540	"Baleares", add
label define region 545	"CastillaLeón", add
label define region 550	"Madrid", add
label define region 555	"CastillaLaMancha", add
label define region 560	"ComunidadValenciana", add
label define region 565	"Murcia", add
label define region 570	"Extremadura", add
label define region 575	"Andalucia", add
label define region 580	"Canarias", add


* France
label define region 121	"ÎledeFrance", add
label define region 131	"ChampagneArdenne", add
label define region 132	"Picardie", add
label define region 133	"HauteNormandie", add
label define region 134	"Centre", add
label define region 135	"BasseNormandie", add
label define region 136	"Bourgogne", add
label define region 141	"NordPasdeCalais", add
label define region 151	"Lorraine", add
label define region 152	"Alsace", add
label define region 153	"FrancheComté", add
label define region 162	"PaysdelaLoire", add
label define region 163	"Bretagne", add
label define region 164	"PoitouCharentes", add
label define region 182	"Aquitaine", add
label define region 183	"MidiPyrénées", add
label define region 184	"Limousin", add
label define region 192	"RhônesAlpes", add
label define region 193	"Auvergne", add
label define region 201	"LanguedocRoussillon", add
label define region 203	"ProvenceAlpesCôte d'Azur", add
label define region 204	"Corse", add
label define region 205	"Guadeloupe", add
label define region 206	"Martinique", add
label define region 207	"LaRéunion", add


* Italy
label define region 221	"Valled'Aoste", add
label define region 222	"Piemonte", add
label define region 230	"Lombardia", add
label define region 241	"Trentino", add
label define region 242	"AltoAdige", add
label define region 243	"Veneto", add
label define region 244	"FriuliVenezia", add
label define region 250	"Liguria", add
label define region 260	"EmiliaRomagna", add
label define region 270	"Toscana", add
label define region 281	"Marche", add
label define region 282	"Umbria", add
label define region 291	"Lazio", add
label define region 292	"Abruzzo", add
label define region 301	"Molise", add
label define region 302	"Campania", add
label define region 303	"Calabria", add
label define region 311	"Puglia", add
label define region 312	"Basilicata", add
label define region 320	"Sicilia", add
label define region 330	"Sardegna", add


* Cyprus
label define region 740	"Cyprus", add


* Latvia
label define region 770	"Latvia", add


* Lithuania 
label define region 775	"Lithuania ", add


* Luxembourg
label define region 350	"Luxembourg", add


* Hungary
label define region 760	"KözépMagyarország", add
label define region 761	"KözépDunántúl", add
label define region 762	"NyugatDunántúl", add
label define region 763	"DélDunántúl", add
label define region 764	"ÉszakMagyarország", add
label define region 765	"ÉszakAlföld", add
label define region 766	"DélAlföld", add
label define region 767	"Alföld", add
label define region 768	"Dunántúl", add


* Malta
label define region 780	"Malta", add


* The Netherlands
label define region 360	"The Netherlands", add


* Austria
label define region 660	"Austria", add


* Poland
label define region 785	"Pomorze and Mazury", add
label define region 790	"Wielkopolska and Slask", add
label define region 795	"Mazowsze and Podlasie", add
label define region 800	"Malopolska and Pogórze", add


* Portugal
label define region 610	"EntreDouro e Minho/Beira litoral", add
label define region 615	"NorteeCentro", add
label define region 620	"TrasosMontes/Beira interior", add
label define region 630	"RibatejoeOeste", add
label define region 640	"AlentejoedoAlgarve", add
label define region 650	"Açores", add


* Romania
label define region 840	"NordEst", add
label define region 841	"SudEst", add
label define region 842	"SudMuntenia", add
label define region 843	"SudVestOltenia", add
label define region 844	"Vest", add
label define region 845	"NordVest", add
label define region 846	"Centru", add
label define region 847	"BucurestiIlfov", add


* Slovenia
label define region 820	"Slovenia ", add


* Slovakia
label define region 810	"Slovakia", add


* Finland
label define region 670	"EtelaSuomi", add
label define region 680	"SisaSuomi", add
label define region 690	"Pohjanmaa", add
label define region 700	"PohjoisSuomi", add


* Sweden
label define region 710	"Slattbygdslan", add
label define region 720	"Skogsochmellanbygdslan", add
label define region 730	"Laninorra", add


* United Kingdom
label define region 411	"EnglandNorth", add
label define region 412	"EnglandEast", add
label define region 413	"EnglandWest", add
label define region 421	"Wales", add
label define region 431	"Scotland", add
label define region 441	"NorthernIreland", add
label value region region

