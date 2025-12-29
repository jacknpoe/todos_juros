// 23/11/2025: removed <locale> and replaced main to mimic juros.c
// 29/12/2025: ATTENTION: compile with -lm option to link math library (for pow function)

#include <math.h>	// pow
#include <iostream>	// std
#include <cstdlib>	// allocs

namespace jacknpoe {
//--------------------------- Interest class
	class Interest {
	protected:
		short Quant;		// number of payments (all payments with 0 will be considered a valid payment in cash)
		bool Compounded;		// compounded
		long double Period;		// period fot the InterestRate (like 30 for a 30 days interest rate)
		long double *Payments;		// payment days in periods like in days { 0, 30, 60, 90}
		long double *Weights;		// payment weights (in any unit, value, apportionment...)
		void init( short quant, bool compounded, long double period);
	public:
		Interest( short quant = 0, bool compounded = false, long double period = 30.0);
		Interest( bool compounded, long double period = 30.0);
		~Interest();
		bool setQuant( short quant);
		short getQuant( void);
		void setCompounded( bool compounded);
		bool getCompounded( void);
		bool setPeriod( long double period);
		long double getPeriod( void);
		bool setPayment( short index, long double value);
		long double getPayment( short index);
		bool setWeight( short index, long double value);
		long double getWeight( short index);
		long double getTotalWeight( void);
		long double InterestRateToIncrease( long double interestrate);
		long double IncreaseToInterestRate( long double increase, char precision = 8,
		                                    short maxiterations = 100, long double maxinterestrate = 50,
		                                    bool increaseasoriginalvalue = false);
	};

	void Interest::init( short quant, bool compounded, long double period) {
		Payments = NULL;  Weights = NULL;  Quant = 0;
		setQuant( quant);  Compounded = compounded;  Period = period;
	}

	Interest::Interest( short quant, bool compounded, long double period) { init( quant, compounded, period); }
	Interest::Interest( bool compounded, long double period) { init( 0, compounded, period); }

	bool Interest::setQuant( short quant) {
		if( quant < 0 ) return false; if( quant == Quant) return true;
		Payments = (long double *) std::realloc( Payments, sizeof(long double) * quant);
		if( quant !=0 && Payments == NULL) { Quant = 0; return false; }
		Weights = (long double *) std::realloc( Weights, sizeof( long double) * quant);
		if( quant !=0 && Weights == NULL) { std::free( Payments); Payments = NULL; Quant = 0; return false; }
		for( short index = Quant; index < quant; index++) { Payments[ index] = 0; Weights[ index] = 1; }
		Quant = quant; return true;
	}
	short Interest::getQuant( void) { return Quant; }

	void Interest::setCompounded( bool compounded) { Compounded = compounded; }
	bool Interest::getCompounded( void) { return Compounded; }

	bool Interest::setPeriod( long double period) {
		if( period <= 0.0 ) return false;
		Period = period; return true;
	}
	long double Interest::getPeriod( void) { return Period; }

	bool Interest::setPayment( short index, long double value) {
		if( index < 0 || index >= Quant || value < 0.0) return false;
		Payments[ index] = value; return true;
	}
	long double Interest::getPayment( short index) {
		if( index < 0 || index >= Quant) return 0; else return Payments[ index];
	}

	bool Interest::setWeight( short index, long double value) {
		if( index < 0 || index >= Quant || value < 0) return false;
		Weights[ index] = value; return true;
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
		long double accumulator = 0;  // bool onlyzero = true;

		for( short index = 0; index < Quant; index++) {
			// if( Payments[ index] > 0.0 && Weights[ index] > 0) onlyzero = false;
			if( Compounded)	accumulator += Weights[ index] / pow( 1 + interestrate / 100, Payments[ index] / Period);  // compounded interest
				else accumulator += Weights[ index] / ( 1 + interestrate / 100 * Payments[ index] / Period);  // simple interest
		}
		// if( onlyzero) return 0;
		if( accumulator <= 0 ) return 0;
		return ( total / accumulator - 1 ) * 100;
	}

	long double Interest::IncreaseToInterestRate( long double increase, char precision, short maxiterations, long double maxinterestrate, bool increaseasoriginalvalue)
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

	Interest::~Interest() { std::free( Payments); std::free( Weights); }
}

using namespace jacknpoe;   // this code is awkward because, in reality, this file is a concatenation of a .h and a .cpp (from a library) and the main
int main() {
 	std::cout.precision(15);

	long double totalWeight, calculatedIncrease, calculatedInterest;
	int index;

	// declares interest of type Interest, initializes the properties and allocates memory
	Interest interest = Interest(3, true, 30.0);

	for(index = 0; index< interest.getQuant(); index++) {
		interest.setPayment(index, (index + 1) * interest.getPeriod());
		interest.setWeight(index, 1);
	}

    // calculates, stores, and prints the results
	totalWeight = interest.getTotalWeight();
	std::cout << "Total weight: " << totalWeight << std::endl;
	calculatedIncrease = interest.InterestRateToIncrease(3.0);
	std::cout << "Calculated increase: " << calculatedIncrease << std::endl;
	calculatedInterest = interest.IncreaseToInterestRate(calculatedIncrease, 15, 100, 50.0);
	std::cout << "Calculated interest: " << calculatedInterest << std::endl;

	return 0;
}

