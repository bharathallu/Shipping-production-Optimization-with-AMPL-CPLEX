set STAT ordered;						# States
set SITE ordered;						# Sites (plants)
set CUST ordered;						# Customers
set INGR ordered;						# Ingredients
set PROD ordered;						# Productions


param PC {SITE} >=0;					
# PC(i) = Purchase cost of site i per year ($/year)
param Cap {SITE} >=0;					
# Cap(i) = Production capacity of site i per year (ton/year)
param SI {INGR,SITE} >=0;				
# SI(m,i) = Cost of shipping ingredient m to site i per year ($/ton)
param Dis {SITE,CUST} >=0;				
# Dis(i,j) = Distance of site i from customer j (mile)
param UnitShip >=0;						
# UnitShip = Unit cost of shipping products to customers per mile per ton ($/mile.ton)
param Dmd {PROD,CUST} >=0;				
# Dmd(n,j) = Demand of customer j for product n (ton/year)
param MR {INGR,PROD} >=0;				
# MR(m,n) = Mix ratio (i.e. % of ingredient m in product n)
param MaxSt >=1;						
# MaxSt = The maximum allowed number of states to have an operating site
param SS {SITE,STAT} >=0;				
# SS(i,s) = State-Site indicator matrix [ SS(i,s)=1 if site i is in state s, and SS(i,s)=0 otherwise ]			
param D >=0;							
# A very large number [ D >= max (sum of all demands , number of sites) ]


var X {INGR,SITE} >=0;					
# X(m,i) = Amount of ingredient m shipped to site i (ton/year)
var Y {PROD,SITE,CUST} >=0;				
# Y(n,i,j) = Amount of product n produced at site i and shipped to customer j (ton/year)
var W {SITE} binary;			
# W(i) = Site operation indicator [ W(i)=1 if site i is operating, and W(i)=0 otherwise ]
var Z {STAT} binary;			
# Z(s) = State operation indicator [ Z(s)=1 if state s has an operating site, and Z(s)=0 otherwise ]


minimize Total_Cost: 				
sum {i in SITE} PC[i]*W[i] + 
sum {m in INGR , i in SITE} SI[m,i]*X[m,i] + 
sum {n in PROD , i in SITE , j in CUST} UnitShip*Dis[i,j]*Y[n,i,j];
# Cost of expanding BestChip to the western US


subject to Capacity {i in SITE}: sum {n in PROD , j in CUST} Y[n,i,j] <= Cap [i];
# Sites (plants) cannot produce more than their capacities.
subject to Demand {n in PROD , j in CUST}: sum {i in SITE} Y[n,i,j] = Dmd[n,j];
# Sum of products from all sites to every customer should satisfy its demand for every product
subject to Availability {m in INGR , i in SITE}: sum {n in PROD} (MR[m,n]*sum {j in CUST} Y[n,i,j]) <= X[m,i];
# Production at every site is restricted to available ingredients in that site
subject to ForceSITE {i in SITE}: sum {n in PROD , j in CUST} Y[n,i,j] <= D*W[i];
# The sites with "operation indicator" of zero cannot to have production
subject to ForceSTATElb {s in STAT}: Z[s] <= sum {i in SITE} SS[i,s]*W[i];
# The states with "operation indicator" of one have to have at least one operating site
subject to ForceSTATEub {s in STAT}: sum {i in SITE} SS[i,s]*W[i] <= D*Z[s];
# The states with "operation indicator" of zero cannot have any operating site
subject to NumStates: sum {s in STAT} Z[s] <= MaxSt;
# The number of states with an operating site cannot be more than the maximum allowed