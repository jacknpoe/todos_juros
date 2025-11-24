// Version 0.1: 03/02/2025
//         0.2: replaced main to mimic juros.c

#include <math.h>
#include <iostream.h>
#include <stdlib.h>
#include <stdio.h>

//--------------------------- Interest class
class Interest {
protected:
	short Quant;		// number of payments (all payments with 0 will be considered a valid payment in cash)
	short Compounded;		// compounded
	long double Period;		// period fot the InterestRate (like 30 for a 30 days interest rate)
	long double *Payments;		// payment days in periods like in days { 0, 30, 60, 90}
	long double *Weights;		// payment weights (in any unit, value, apportionment...)
	void init( short quant, short compounded, long double period);
public:
	Interest( short quant = 0, short compounded = 0, long double period = 30.0);
	Interest( short compounded, long double period = 30.0);
	~Interest();
	short setQuant( short quant);
	short getQuant( void);
	void setCompounded( short compounded);
	short getCompounded( void);
	short setPeriod( long double period);
	long double getPeriod( void);
	short setPayment( short index, long double value);
	long double getPayment( short index);
	short setWeight( short index, long double value);
	long double getWeight( short index);
	long double getTotalWeight( void);
	long double InterestRateToIncrease( long double interestrate);
	long double IncreaseToInterestRate( long double increase, char precision = 8,
										short maxiterations = 100, long double maxinterestrate = 50,
										short increaseasoriginalvalue = 0);
};

void Interest::init( short quant, short compounded, long double period) {
	Payments = 0;  Weights = 0;  Quant = 0;
	setQuant( quant);  Compounded = compounded;  Period = period;
}

Interest::Interest( short quant, short compounded, long double period) { init( quant, compounded, period); }
Interest::Interest( short compounded, long double period) { init( 0, compounded, period); }

short Interest::setQuant( short quant) {
	if( quant < 0 ) return 0; if( quant == Quant) return 1;
	Payments = (long double *) realloc( Payments, sizeof(long double) * quant);
	if( quant !=0 && Payments == 0) { Quant = 0; return 0; }
	Weights = (long double *) realloc( Weights, sizeof( long double) * quant);
	if( quant !=0 && Weights == 0) { free( Payments); Payments = 0; Quant = 0; return 0; }
	for( short index = Quant; index < quant; index++) { Payments[ index] = 0; Weights[ index] = 1; }
	Quant = quant; return 1;
}
short Interest::getQuant( void) { return Quant; }

void Interest::setCompounded( short compounded) { Compounded = compounded; }
short Interest::getCompounded( void) { return Compounded; }

short Interest::setPeriod( long double period) {
	if( period <= 0.0 ) return 0;
	Period = period; return 1;
}
long double Interest::getPeriod( void) { return Period; }

short Interest::setPayment( short index, long double value) {
	if( index < 0 || index >= Quant || value < 0.0) return 0;
	Payments[ index] = value; return 1;
}
long double Interest::getPayment( short index) {
	if( index < 0 || index >= Quant) return 0; else return Payments[ index];
}

short Interest::setWeight( short index, long double value) {
	if( index < 0 || index >= Quant || value < 0) return 0;
	Weights[ index] = value; return 1;
}
long double Interest::getWeight( short index) {
	if( index < 0 || index >= Quant) return 0; else return Weights[ index];
}

long double Interest::getTotalWeight( void) {
	long double accumulator = 0;
	for( short index = 0; index < Quant; index++) accumulator += Weights[ index];
	return accumulator;
}

long double Interest::InterestRateToIncrease( long double interestrate) {
	if( interestrate <= 0 || Quant == 0 ) return 0;   long double total = getTotalWeight();
	if( total == 0) return 0;   if( Period <= 0.0) return 0;
	long double accumulator = 0;

	for( short index = 0; index < Quant; index++) {
		if( Compounded)	accumulator += Weights[ index] / pow( 1 + interestrate / 100, Payments[ index] / Period);  // compounded interest
			else accumulator += Weights[ index] / ( 1 + interestrate / 100 * Payments[ index] / Period);  // simple interest
	}
	if( accumulator <= 0 ) return 0;
	return ( total / accumulator - 1 ) * 100;
}

long double Interest::IncreaseToInterestRate( long double increase, char precision, short maxiterations, long double maxinterestrate, short increaseasoriginalvalue)
{
	long double mininterestrate = 0, medinterestrate, min_diff;
	if( maxiterations < 1 || Quant == 0) return 0;   if( precision < 1) return 0;
	long double total = getTotalWeight();   if( total == 0) return 0;
	if( Period <= 0.0) return 0;  if( increase <= 0) return 0;
	if( increaseasoriginalvalue) {
		increase = 100 * ( total / increase - 1 );	  if( increase <= 0) return 0;
	}
	min_diff = pow( 0.1, precision);
	for( short index = 0; index < maxiterations; index++) {
		medinterestrate = ( mininterestrate + maxinterestrate) / 2;
		if( ( maxinterestrate - mininterestrate ) < min_diff) break;		// the desired precision was reached
		if( InterestRateToIncrease( medinterestrate ) <= increase )
			mininterestrate = medinterestrate; else maxinterestrate = medinterestrate;
	}
	return medinterestrate;
}

Interest::~Interest() { free( Payments); free( Weights); }

int main() {
	cout.precision(15);

	long double totalWeight, calculatedIncrease, calculatedInterest;
	int index;

	// declares interest of type Interest, initializes the properties and allocates memory
	Interest interest = Interest(3, 1, 30.0);

	for(index = 0; index< interest.getQuant(); index++) {
		interest.setPayment(index, (index + 1) * interest.getPeriod());
		interest.setWeight(index, 1);
	}

    // calculates, stores, and prints the results
	totalWeight = interest.getTotalWeight();
	cout << "Total weight: " << totalWeight << "\n";
	calculatedIncrease = interest.InterestRateToIncrease(3.0);
	cout << "Calculated increase: " << calculatedIncrease << "\n";
	calculatedInterest = interest.IncreaseToInterestRate(calculatedIncrease, 15, 100, 50.0);
	cout << "Calculated interest: " << calculatedInterest << "\n";

	return 0;
}
