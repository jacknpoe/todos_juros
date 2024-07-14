// Version: 0.1: 14/07/2024: starter, without much knowledge about Arduino

#include <math.h>
#include <stdlib.h>

//--------------------------- Interest class
class Interest {
protected:
  short Quant;		// number of payments (all payments with 0 will be considered a valid payment in cash)
  bool Compounded;		// compounded
  double Period;		// period fot the InterestRate (like 30 for a 30 days interest rate)
  double *Payments;		// payment days in periods like in days { 0, 30, 60, 90}
  double *Weights;		// payment weights (in any unit, value, apportionment...)
  void init( short quant, bool compounded, double period);
public:
  Interest( short quant = 0, bool compounded = false, double period = 30.0);
  Interest( bool compounded, double period = 30.0);
  ~Interest();
  bool setQuant( short quant);
  short getQuant( void);
  void setCompounded( bool compounded);
  bool getCompounded( void);
  bool setPeriod( double period);
  double getPeriod( void);
  bool setPayment( short index, double value);
  double getPayment( short index);
  bool setWeight( short index, double value);
  double getWeight( short index);
  double getTotalWeight( void);
  double InterestRateToIncrease( double interestrate);
  double IncreaseToInterestRate( double increase, char precision = 8, short maxiterations = 100, double maxinterestrate = 50.0, bool increaseasoriginalvalue = false);
};

// initializer
void Interest::init( short quant, bool compounded, double period) {
  Payments = NULL;  Weights = NULL;  Quant = 0;
  setQuant( quant);  Compounded = compounded;  Period = period;
}

// constructors
Interest::Interest( short quant, bool compounded, double period) { init( quant, compounded, period); }
Interest::Interest( bool compounded, double period) { init( 0, compounded, period); }

// set and get quant / setQuant is special because of the allocs
bool Interest::setQuant( short quant) {
  if( quant < 0 ) return false; if( quant == Quant) return true;
  Payments = (double *) realloc( Payments, sizeof(double) * quant);
  if( quant !=0 && Payments == NULL) { Quant = 0; return false; }
  Weights = (double *) realloc( Weights, sizeof( double) * quant);
  if( quant !=0 && Weights == NULL) { free( Payments); Payments = NULL; Quant = 0; return false; }
  for( short index = Quant; index < quant; index++) { Payments[ index] = 0; Weights[ index] = 1; }
  Quant = quant; return true;
}
short Interest::getQuant( void) { return Quant; }

// set and get compounded
void Interest::setCompounded( bool compounded) { Compounded = compounded; }
bool Interest::getCompounded( void) { return Compounded; }

// set and get period
bool Interest::setPeriod( double period) {
  if( period <= 0.0 ) return false;
  Period = period; return true;
}
double Interest::getPeriod( void) { return Period; }

// set and get payment
bool Interest::setPayment( short index, double value) {
  if( index < 0 || index >= Quant || value < 0.0) return false;
  Payments[ index] = value; return true;
}
double Interest::getPayment( short index) {
  if( index < 0 || index >= Quant) return 0; else return Payments[ index];
}

// set and get weight
bool Interest::setWeight( short index, double value) {
  if( index < 0 || index >= Quant || value < 0.0) return false;
  Weights[ index] = value; return true;
}
double Interest::getWeight( short index) {
  if( index < 0 || index >= Quant) return 0; else return Weights[ index];
}

// calc the sum of Weights[]
double Interest::getTotalWeight( void) {
  double accumulator = 0;
  for( short index = 0; index < Quant; index++) accumulator += Weights[ index];
  return accumulator;
}

// calc interest rate from increase
double Interest::InterestRateToIncrease( double interestrate) {
  if( interestrate <= 0 || Quant == 0 ) return 0.0;   double total = getTotalWeight();
  if( total <= 0) return 0.0;   if( Period <= 0.0) return 0;
  double accumulator = 0.0;

  for( short index = 0; index < Quant; index++) {
    if( Compounded)	accumulator += Weights[ index] / pow( 1.0 + interestrate / 100.0, Payments[ index] / Period);  // compounded interest
      else accumulator += Weights[ index] / ( 1.0 + interestrate / 100.0 * Payments[ index] / Period);  // simple interest
  }
  if( accumulator <= 0.0 ) return 0.0;
  return ( total / accumulator - 1.0 ) * 100.0;
}

// calc increase from interest rate
double Interest::IncreaseToInterestRate( double increase, char precision, short maxiterations, double maxinterestrate, bool increaseasoriginalvalue)
{
  double mininterestrate = 0.0, medinterestrate, min_diff;
  if( maxiterations < 1 || Quant == 0) return 0.0;   if( precision < 1) return 0.0;
  double total = getTotalWeight();   if( total <= 0.0) return 0.0;
  if( Period <= 0.0) return 0;  if( increase <= 0) return 0.0;
  if( increaseasoriginalvalue) {
    increase = 100.0 * ( total / increase - 1.0 );	  if( increase <= 0.0) return 0.0;
  }
  min_diff = pow( 0.1, precision);
  for( short index = 0; index < maxiterations; index++) {
    medinterestrate = ( mininterestrate + maxinterestrate) / 2.0;
    if( ( maxinterestrate - mininterestrate ) < min_diff) break;		// the desired precision was reached
    if( InterestRateToIncrease( medinterestrate ) <= increase )
      mininterestrate = medinterestrate; else maxinterestrate = medinterestrate;
  }
  return medinterestrate;
}

// destructor may free
Interest::~Interest() { free( Payments); free( Weights); }

void setup() {
  // object from class Interest and variables to keep the calcs
  Interest interest;
  double weight, increase, interestrate;

  // set the basic values
  interest.setQuant( 3);
  interest.setCompounded( true);
  interest.setPeriod( 30.0);
  for( short index = 0; index < 3; index++) {
    interest.setPayment( index, (index + 1.0) * 30.0);
    interest.setWeight( index, 1.0);
  }

  // calculate and keep the functions results
  weight = interest.getTotalWeight();
  increase = interest.InterestRateToIncrease( 3.0);
  interestrate = interest.IncreaseToInterestRate( increase, 15);

  // print the results
  Serial.print( "Total weight = ");
  Serial.println( weight, 15);
  Serial.print( "Increase = ");
  Serial.println( increase, 15);
  Serial.print( "Interest rate = ");
  Serial.println( interestrate, 15);
}

void loop() {
  // put your main code here, to run repeatedly:
}
