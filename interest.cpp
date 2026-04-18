// VERSION 0.X1: 23/11/2025: removed <locale> and replaced main to mimic juros.c
//         0.X2: 17/04/2026: new method to create the interest object
//         0.X3: 18/04/2026: setQuant after ChatGPT and other minor changes; from long double to double
// 29/12/2025: ATTENTION: compile with -lm option to link math library (for pow function)

#include <math.h>	// pow
#include <iostream>	// std
#include <cstdlib>	// allocs

namespace jacknpoe {
//--------------------------- Interest class
	class Interest {
	protected:
		long Quant;		// number of payments (all payments with 0 will be considered a valid payment in cash)
		bool Compounded;		// compounded
		double Period;		// period fot the InterestRate (like 30 for a 30 days interest rate)
		double *Payments;		// payment days in periods like in days { 0, 30, 60, 90}
		double *Weights;		// payment weights (in any unit, value, apportionment...)
		void init( long quant, bool compounded, double period);
	public:
		Interest( long quant = 0, bool compounded = false, double period = 30.0);
		Interest( bool compounded, double period = 30.0);
		~Interest();
		bool setQuant( long quant);
		long getQuant( void);
		void setCompounded( bool compounded);
		bool getCompounded( void);
		bool setPeriod( double period);
		double getPeriod( void);
		bool setPayment( long index, double value);
		double getPayment( long index);
		bool setWeight( long index, double value);
		double getWeight( long index);
		double getTotalWeight( void);
		double InterestRateToIncrease( double interestrate);
		double IncreaseToInterestRate( double increase, char precision = 8,
		                                    short maxiterations = 100, double maxinterestrate = 50.0,
		                                    bool increaseasoriginalvalue = false);
	};

	void Interest::init( long quant, bool compounded, double period) {
		Payments = NULL;  Weights = NULL;  Quant = 0;
		setQuant( quant);  Compounded = compounded;  Period = period;
	}

	Interest::Interest( long quant, bool compounded, double period) { init( quant, compounded, period); }
	Interest::Interest( bool compounded, double period) { init( 0, compounded, period); }

    // before ChatGPT
	// bool Interest::setQuant( long quant) {
    //     double *newPayments; double *newWeights;
	//     if( quant < 0 ) return false;
    //     if( quant == Quant) return true;
    //     newPayments = (double *) std::realloc( Payments, sizeof(double) * quant);
    //     if( quant !=0 && newPayments == NULL) { Quant = 0; return false; }
    //     newWeights = (double *) std::realloc( Weights, sizeof(double) * quant);
    //     if( quant !=0 && newWeights == NULL) { if(newPayments != Payments) std::free( newPayments); Quant = 0; return false; }
    //     Payments = newPayments; Weights = newWeights;
    //     for( long index = Quant; index < quant; index++) { Payments[ index] = 0.0; Weights[ index] = 1.0; }
    //     Quant = quant; return true;
	// }

    // after ChatGPT
    bool Interest::setQuant(long quant) {
        if (quant < 0) return false; if (quant == Quant) return true;
        double* newPayments = (double*) std::realloc(Payments, sizeof(double) * quant);
        if (quant != 0 && newPayments == NULL) return false;
        double* newWeights = (double*) std::realloc(Weights, sizeof(double) * quant);
        if (quant != 0 && newWeights == NULL) { if (newPayments != Payments) std::free(newPayments); return false; }
        Payments = newPayments; Weights  = newWeights;
        for (long index = Quant; index < quant; index++) { Payments[index] = 0.0; Weights[index]  = 1.0; }
        Quant = quant; return true;
    }
	long Interest::getQuant( void) { return Quant; }

	void Interest::setCompounded( bool compounded) { Compounded = compounded; }
	bool Interest::getCompounded( void) { return Compounded; }

	bool Interest::setPeriod( double period) {
		if( period <= 0.0 ) return false;
		Period = period; return true;
	}
	double Interest::getPeriod( void) { return Period; }

	bool Interest::setPayment( long index, double value) {
		if( index < 0 || index >= Quant || value < 0.0) return false;
		Payments[ index] = value; return true;
	}
	double Interest::getPayment( long index) {
		if( index < 0 || index >= Quant) return 0.0; else return Payments[ index];
	}

	bool Interest::setWeight( long index, double value) {
		if( index < 0 || index >= Quant || value < 0) return false;
		Weights[ index] = value; return true;
	}
	double Interest::getWeight( long index) {
		if( index < 0 || index >= Quant) return 0.0; else return Weights[ index];
	}

	double Interest::getTotalWeight( void) {
		double accumulator = 0;
		for( long index = 0; index < Quant; index++) accumulator += Weights[ index];
		return accumulator;
	}

	double Interest::InterestRateToIncrease( double interestrate) {
		if( interestrate <= 0.0 || Quant < 1 ) return 0.0;   double total = getTotalWeight();
		if( total <= 0.0) return 0.0;   if( Period <= 0.0) return 0.0;
		double accumulator = 0.0;  // bool onlyzero = true;

		for( long index = 0; index < Quant; index++) {
			// if( Payments[ index] > 0.0 && Weights[ index] > 0) onlyzero = false;
			if( Compounded)	accumulator += Weights[ index] / pow( 1.0 + interestrate / 100.0, Payments[ index] / Period);  // compounded interest
			else accumulator += Weights[ index] / ( 1.0 + interestrate / 100.0 * Payments[ index] / Period);  // simple interest
		}
		// if( onlyzero) return 0;
		if( accumulator <= 0.0 ) return 0.0;
		return ( total / accumulator - 1.0 ) * 100.0;
	}

	double Interest::IncreaseToInterestRate( double increase, char precision, short maxiterations, double maxinterestrate, bool increaseasoriginalvalue)
	{
		double mininterestrate = 0.0, medinterestrate = maxinterestrate / 2.0, min_diff;
		if( maxiterations < 1 || Quant < 1) return 0.0;   if( precision < 1) return 0.0;
		double total = getTotalWeight();   if( total <= 0.0) return 0.0;
		if( Period <= 0.0) return 0.0;  if( increase <= 0.0) return 0.0;
		if( increaseasoriginalvalue) {
			increase = 100.0 * ( total / increase - 1.0 );	  if( increase <= 0) return 0.0;
		}
		min_diff = pow( 0.1, precision);
		for( short index = 0; index < maxiterations; index++) {
			if( ( maxinterestrate - mininterestrate ) < min_diff) break;		// the desired precision was reached
			if( InterestRateToIncrease( medinterestrate ) <= increase )
				mininterestrate = medinterestrate; else maxinterestrate = medinterestrate;
			medinterestrate = ( mininterestrate + maxinterestrate) / 2.0;
		}
		return medinterestrate;
	}

	Interest::~Interest() { std::free( Payments); std::free( Weights); }
}

using namespace jacknpoe;   // this code is awkward because, in reality, this file is a concatenation of a .h and a .cpp (from a library) and the main
int main() {
 	std::cout.precision(15);

	double totalWeight, calculatedIncrease, calculatedInterest;
	int index;

	// declares interest of type Interest, initializes the properties and allocates memory
	Interest interest(300000, true, 30.0);

	for(index = 0; index< interest.getQuant(); index++) {
		interest.setPayment(index, (index + 1) * interest.getPeriod());
		interest.setWeight(index, 1);
	}

    // calculates, stores, and prints the results
	totalWeight = interest.getTotalWeight();
	std::cout << "Total weight: " << totalWeight << std::endl;
	calculatedIncrease = interest.InterestRateToIncrease(3.0);
	std::cout << "Calculated increase: " << calculatedIncrease << std::endl;
	calculatedInterest = interest.IncreaseToInterestRate(calculatedIncrease, 15, 65, 50.0);
	std::cout << "Calculated interest: " << calculatedInterest << std::endl;

	return 0;
}
