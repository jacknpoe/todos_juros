#include <math.h>
#include <iostream>
#include <cstdlib>
#include <cstdio>
#include <locale>

namespace jacknpoe {
//--------------------------- Interest class
	class Interest {
	protected:
		short Quant;		// number of payments (all payments with 0 will be considered a valid payment in cash)
		bool Compounded;		// compounded (InterestRate², InterestRate³)
		short Period;		// period fot the InterestRate (like 30 for a 30 days interest rate)
		short *Payments;		// payment days in periods like in days { 0, 30, 60, 90}
		long double *Weights;		// payment weights (in any unit, value, apportionment...)
		void init( short quant, bool compounded, short period);
	public:
		Interest( short quant = 0, bool compounded = false, short period = 30);
		Interest( bool compounded, short period = 30);
		~Interest();
		bool setQuant( short quant);
		short getQuant( void);
		void setCompounded( bool compounded);
		bool getCompounded( void);
		bool setPeriod( short period);
		short getPeriod( void);
		bool setPayment( short index, short value);
		short getPayment( short index);
		bool setWeight( short index, long double value);
		long double getWeight( short index);
		long double getTotalWeight( void);
		long double InterestRateToIncrease( long double interestrate);
		long double IncreaseToInterestRate( long double increase, char precision = 8, 
		                                    short maxiterations = 100, long double maxinterestrate = 50,
		                                    bool increaseasoriginalvalue = false);
	};

	void Interest::init( short quant, bool compounded, short period) {
		Payments = NULL;  Weights = NULL;  Quant = 0;
		setQuant( quant);  Compounded = compounded;  Period = period;
	}

	Interest::Interest( short quant, bool compounded, short period) { init( quant, compounded, period); }
	Interest::Interest( bool compounded, short period) { init( 0, compounded, period); }

	bool Interest::setQuant( short quant) {
		if( quant < 0 ) return false; if( quant == Quant) return true;
		Payments = (short *) std::realloc( Payments, sizeof( short) * quant);
		if( quant !=0 and Payments == NULL) { Quant = 0; return false; }
		Weights = (long double *) std::realloc( Weights, sizeof( long double) * quant);
		if( quant !=0 and Weights == NULL) { std::free( Payments); Payments = NULL; Quant = 0; return false; }
		for( short index = Quant; index < quant; index++) { Payments[ index] = 0; Weights[ index] = 1; }
		Quant = quant; return true;
	}
	short Interest::getQuant( void) { return Quant; }

	void Interest::setCompounded( bool compounded) { Compounded = compounded; }
	bool Interest::getCompounded( void) { return Compounded; }

	bool Interest::setPeriod( short period) {
		if( period < 1 ) return false;
		Period = period; return true;
	}
	short Interest::getPeriod( void) { return Period; }

	bool Interest::setPayment( short index, short value) {
		if( index < 0 or index >= Quant or value < 0) return false;
		Payments[ index] = value; return true;
	}
	short Interest::getPayment( short index) { 
		if( index < 0 or index >= Quant) return 0; else return Payments[ index];
	}

	bool Interest::setWeight( short index, long double value) {
		if( index < 0 or index >= Quant or value < 0) return false;
		Weights[ index] = value; return true;
	}
	long double Interest::getWeight( short index) { 
		if( index < 0 or index >= Quant) return 0; else return Weights[ index];
	}

	long double Interest::getTotalWeight( void) {
		long double accumulator = 0;
		for( short index = 0; index < Quant; index++) accumulator += Weights[ index];
		return accumulator;
	}

	long double Interest::InterestRateToIncrease( long double interestrate) {
		if( interestrate <= 0 or Quant == 0 ) return 0;   long double total = getTotalWeight();
		if( total == 0) return 0;   if( Period <= 0) return 0;
		long double accumulator = 0;   bool onlyzero = true;

		for( short index = 0; index < Quant; index++) {
			if( Payments[ index] > 0 and Weights[ index] > 0) onlyzero = false;
			if( Compounded)	accumulator += Weights[ index] / pow( 1 + interestrate / 100, Payments[ index] / Period);  // compounded interest
				else accumulator += Weights[ index] / ( 1 + interestrate / 100 * Payments[ index] / Period);  // simple interest
		}
		if( onlyzero) return 0;
		return ( total / accumulator - 1 ) * 100;
	}

	long double Interest::IncreaseToInterestRate( long double increase, char precision, short maxiterations, long double maxinterestrate, bool increaseasoriginalvalue)
	{		
		long double mininterestrate = 0, medinterestrate, min_diff;
		if( maxiterations < 1 or Quant == 0) return 0;   if( precision < 1) return 0;
		long double total = getTotalWeight();   if( total == 0) return 0;
		if( Period <= 0) return 0;  if( increase <= 0) return 0;
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
	Interest interest;

	setlocale( LC_ALL, "");		// equal caracters in prompt
 	std::cout.precision(9);

	short payments, temp, period, option;
	long double increase, interestrate, total, temp_ld;

	
	while( true) {
		std::cout << "——————————————————————————————————\n";
		std::cout << "| Choose an option               |\n";
		std::cout << "——————————————————————————————————\n\n";
		std::cout << "     1. Interest Rate to Increase.\n\n";
		std::cout << "     2. Increase to Interest Rate.\n\n";
		std::cout << "Others. Exit.\n\n\n";

		std::cin >> option;
		std::cout << "\n";
		if( option != 1 and option != 2) {
			break;
		}

		std::cout << "\n";
		
		std::cout << "Number of payments: ";
		std::cin >> payments;
	
		if( payments < 1) {
			std::cout << "You must provide at least one payment.\n\n";
			system( "PAUSE");
			std::cout << "\n\n";
			continue;
		}
		interest.setQuant( payments);
	
		std::cout << "Interest rate relating to (example: 30 days, 1 month): ";
		std::cin >> period;
	
		if( period < 1) {
			std::cout << "Interest rate must relating to at least one period.\n\n";
			system( "PAUSE");
			std::cout << "\n\n";
			continue;
		}
		interest.setPeriod( period);
	
		for( short index = 0; index < payments; index++) {
			std::cout << "Payment " << index + 1 << ": ";
			std::cin >> temp;
			interest.setPayment( index, temp);

			std::cout << "Weight " << index + 1 << ": ";
			std::cin >> temp_ld;
			interest.setWeight( index, temp_ld);
		}
	
		if( option == 1)
		{
			std::cout << "\nFull cash value: ";
			std::cin >> total;

			std::cout << "Interest rate: ";
			std::cin >> interestrate;
		
			interest.setCompounded( false);	// simple interest
			increase = interest.InterestRateToIncrease( interestrate);
			std::cout << "\n\nSIMPLE INTEREST";
			std::cout << "\nIncrease: " << increase << "%, payment value: " << total * ( 1 + increase / 100) / payments;
			std::cout << ", total paid: " << total * ( 1 + increase / 100);
		
			interest.setCompounded( true);	// compound interest
			increase = interest.InterestRateToIncrease( interestrate);
			std::cout << "\n\nCOMPOUND INTEREST";
			std::cout << "\nIncrease: " << increase << "%, payment value: " << total * ( 1 + increase / 100) / payments;
			std::cout << ", total paid: " << total * ( 1 + increase / 100);
		}
			else
		{
			std::cout << "\nIncrease: ";
			std::cin >> increase;

			interest.setCompounded( false);
			interestrate = interest.IncreaseToInterestRate( increase);
			std::cout << "\n\nSIMPLE INTEREST: " << interestrate;
		
			interest.setCompounded( true);
			interestrate = interest.IncreaseToInterestRate( increase);
			std::cout << "\n\nCOMPOUND INTEREST: " << interestrate;
		}

		std::cout << "\n\n";
		system( "PAUSE");
		std::cout << "\n\n";
	}
	std::cout << "\n\n"; exit( 0);
}

//
//----------------------------------
//| Choose an option               |
//----------------------------------
//     1. Interest Rate to Increase.
//     2. Increase to Interest Rate.
//Others. Exit.

//2

//Number of payments: 3
//Interest rate relating to (example: 30 days, 1 month): 30
//Payment 1: 30
//Weight 1: 1
//Payment 2: 60
//Weight 2: 1
//Payment 3: 90
//Weight 3: 1

//Increase: 20

//SIMPLE INTEREST: 10.2936087
//COMPOUND INTEREST: 9.70102574

//----------------------------------
//| Choose an option               |
//----------------------------------
//     1. Interest Rate to Increase.
//     2. Increase to Interest Rate.
//Others. Exit.

//1

//Number of payments: 2
//Interest rate relating to (example: 30 days, 1 month): 1
//Payment 1: 1
//Weight 1: 1
//Payment 2: 2
//Weight 2: 1

//Full cash value: 1000
//Interest rate: 5

//SIMPLE INTEREST
//Increase: 7.44186047%, payment value: 537.209302, total paid: 1074.4186

//COMPOUND INTEREST
//Increase: 7.56097561%, payment value: 537.804878, total paid: 1075.60976
