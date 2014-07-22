* A quick note to remember the...
*    Kolmogorov-Smirnov test for equality of distribution functions

Syntax

* First plot your kdensity
kdensity write if female == 1, plot(kdensity write if female == 0) ///
	legend(label(1 "Females") label(2 "Males") rows(1))

* Then the test is...
ksmirnov write, by(female)


*See the following website...
* http://www.ats.ucla.edu/stat/stata/faq/eq_dist.htm
* Accessed 12/01/14 @9:39
