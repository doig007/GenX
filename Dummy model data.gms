
table TechDataTable(Tech,*)
                 Type    UC   Dispatchable        InvestmentCost  FOMCost   VOMCost   FuelCost    StartupCost     CO2EmissionRate   pmin    Availability    RampUpRate   RampDownRate   MinUpTime    MinDownTime
Coal             1       0    1                   2000            0         1         30          0               0                 0       1.0             0            0              0            0
CCGT             1       0    1                   1000            0         2         50          0               0                 0       1.0             0            0              0            0
Solar            2       0    0                   1200            0         0         0           0               0                 0       0.3             0            0              0            0
OnshoreWind      2       0    0                   1400            0         0         0           0               0                 0       0.3             0            0              0            0
;

table TechDataTable2(Tech,Zones,*)
                         ExistingCap     MaxNewCap       UnitSize
Coal.Zone1               500             0               0
CCGT.Zone1               300             1000            0
Solar.Zone1              100             1000            0
OnshoreWind.Zone1        200             1000            0
;

parameters tDemand(Times,Zones)  / 1.zone1 = 1000,
                                   2.zone1 = 1000,
                                   3.zone1 = 1000,
                                   4.zone1 = 1000,
                                   5.zone1 = 1000,
                                   6.zone1 = 1000,
                                   7.zone1 = 1000,
                                   8.zone1 = 1000,
                                   9.zone1 = 1000,
                                   10.zone1 = 1000,
                                   11.zone1 = 1000,
                                   12.zone1 = 1000,
                                   13.zone1 = 1000,
                                   14.zone1 = 1000,
                                   15.zone1 = 1000,
                                   16.zone1 = 1000,
                                   17.zone1 = 1000,
                                   18.zone1 = 1000,
                                   19.zone1 = 1000,
                                   20.zone1 = 1000,
                                   21.zone1 = 1000,
                                   22.zone1 = 1000,
                                   23.zone1 = 1000,
                                   24.zone1 = 1000  /;


parameters tMap_LineZone(Lines,Zones)     /       Line1.Zone1 = 1,
                                                 Line1.Zone2 = -1        /;


Table LineDataTable(Lines,*)
                 OriginZone      DestZone      LineCapacity      LineExpansionMax        LineVoltage     LineResistance  LineLossRate
Line1            1               2             1000              1000                    400000          0               0.01
;

Table ZoneDataTable(Zones,*)
                 TZone           DZone
Zone1            1               0
Zone2            0               1
;



Map_DZones(Zones) = ZoneDataTable(Zones,'DZone');
Map_TZones(Zones) = ZoneDataTable(Zones,'TZone');

ReserveTypesDown('ResDown') = yes;
ReserveTypesDown('FreqDown') = yes;
ReserveTypesUp('ResUp') = yes;
ReserveTypesUp('FreqUp') = yes;

TZones('Zone1') = yes;
DZones('Zone2') = yes;


Parameter TechType(Tech) "Temporary parameter for holding technology type"
          TechUC(Tech) "Temporary parameter for holding Unit Commitment classification"
          TechDispatchable(Tech) "Temporary parameter for holding Dispatchable classification"
;

TechType(Tech) = TechDataTable(Tech,'Type');
TechUC(Tech) = TechDataTable(Tech,'UC');
TechDispatchable(Tech) = TechDataTable(Tech,'Dispatchable');

InvestmentCost(Tech,Zones) = TechDataTable(Tech,'InvestmentCost');
FOMCost(Tech,Zones) = TechDataTable(Tech,'FOMCost');
VOMCost(Tech,Zones) = TechDataTable(Tech,'VOMCost');
FuelCost(Tech,Zones) = TechDataTable(Tech,'FuelCost');
StartupCost(Tech,Zones) = TechDataTable(Tech,'StartupCost');
CO2EmissionRate(Tech,Zones) = TechDataTable(Tech,'CO2EmissionRate');
pmin(Tech,Zones) = TechDataTable(Tech,'pmin');
Availability(Tech,Times,Zones) = TechDataTable(Tech,'Availability');
RampUpRate(Tech,Zones) = TechDataTable(Tech,'RampUpRate');
RampDownRate(Tech,Zones) = TechDataTable(Tech,'RampDownRate');
MinUpTime(Tech,Zones) = TechDataTable(Tech,'MinUpTime');
MinDownTime(Tech,Zones) = TechDataTable(Tech,'MinDownTime');

MaxNewCap(Tech,Zones) = TechDataTable2(Tech,Zones,'MaxNewCap');
ExistingCap(Tech,Zones) = TechDataTable2(Tech,Zones,'ExistingCap');
UnitSize(Tech,Zones) = TechDataTable2(Tech,Zones,'UnitSize');

Demand(Times,Zones) = tDemand(Times,Zones);

Map_LineZone(Lines,Zones) = tMap_LineZone(Lines,Zones);
LineCapacity(Lines) = LineDataTable(Lines,'LineCapacity');
LineExpansionMax(Lines) = LineDataTable(Lines,'LineExpansionMax');
LineVoltage(Lines) = LineDataTable(Lines,'LineVoltage');
LineResistance(Lines) = LineDataTable(Lines,'LineResistance');
LineLossRate(Lines) =  LineDataTable(Lines,'LineLossRate'); 


ReserveConfig = 1;
IntegerModel = 0;
LineLossConfig = 0;

NACCHeatEfficiency(Tech,Zones) = 1;
NACCPeakBaseRatio(Tech,Zones) = 1;


ReserveMaxContribution(ReserveTypes,Tech,Zones) = 0;
ReserveRequirement(ReserveTypes) = 0;
ReserveRequirementVRE(ReserveTypes) = 0;
ReserveUnmetCost(ReserveTypes) = 0;
LineExpansionCost(Lines) = 100000;
DistZoneReinforcementCost(Zones) = 100000;




HydroInitialLevel(Tech,Zones) = 1;


StorageEfficiencyDischarge(Tech,Zones) = 1;
StorageEfficiencyCharge(Tech,Zones) = 1;
StorageLossRate(Tech,Zones) = 0;
StoragePowerEnergyRatio(Tech,Zones) = 100;
DSMRatio(Tech,Zones) = 1;
DSMTimePeriods(Tech,Zones) = 24;


HeatDemand(Times,Zones) = 0;
HeatPrice(Zones) = 0;
CostCurtailedDemand(Segments) = 0;
PriceResponse(Segments) = 1;


CO2MaxRate(Zones) = 0;
QualifyingREMin(Zones) = 0;

LinesEligibleReinforcement(Lines)=no;
