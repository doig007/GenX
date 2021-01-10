
$onInline

sets     Times "Hours" /1*24/
         Zones "Zones" /Zone1,Zone2/
         Lines "Lines" /Line1/
         Tech "Technologies" /CCGT,Coal,AdvNuclear,Solar,OnshoreWind,Hydro,DR,Battery/
         ReserveTypes "Types of reserve or frequency" /ResUp,ResDown,FreqUp,FreqDown/
         Segments "Consumer segments" /Consumer1/;

sets     PiecewiseSeg "Segments used in piecewise approximation of quadratic functions" /1*4/;

sets     Thermal(Tech) "Thermal resources"
         RE(Tech) "Renewable resources"
         Storage(Tech) "Storage resources"
         DR(Tech) "Demand response resources"
         AdvNuclear(Tech) "Advanced nuclear resources"
         HeatStorage(Tech) "Heat storage resources"
         Hydro(Tech) "Hydro reservoir resources";

* Define further subsets, n.b. all defined wrt to Tech so that subsets members can be defined later (avoid GAMS error) *
sets     DispatchableRE(Tech) "Dispatchable renewable resources"
         NonDispatchableRE(Tech) "Non-dispatchable renewable resources"
         UC(Tech) "Thermal resources subject to unit commitment"
         NonUC(Tech) "Thermal resources not subject to unit commitment"
         UCAdvNuclear(Tech) "Advanced nuclear resources subject to unit commitment"
         NonUCAdvNuclear(Tech) "Advanced nuclear resources not subject to unit commitment";

* Define calculated subsets used for readability of equations
sets     NotAdvNuclear(Tech) "Tech not Advanced nuclear"
         NotHeatStorage(Tech) "Tech not Heat storage"
         NotStorage(Tech) "Tech not storage"
         NonUCReserves(Tech) "Tech with non UC constraints for reserves"
         NonDR(Tech) "Tech that is not DR"
         GenTech(Tech) "Tech not Storage or HeatStorage or DR"
         NonUCTotal(Tech);

sets     ReserveTypesDown(ReserveTypes)
         ReserveTypesUp(ReserveTypes);

sets     TZones(Zones) "Transmission zones"
         DZones(Zones) "Distribution zones"
         LinesEligibleReinforcement(Lines) "Transmission lines lines eligible for reinforcement"
         LinesNotEligibleReinforcement(Lines);

sets     PW(Times) "Peak withdrawal hours in distribution zones"
         PI(Times) "Peak injection hours in distribution zones";

alias    (Times,TimesDummy);
alias    (Tech,TechDummy);
alias    (Zones,ZonesDummy);
alias    (DZones,DZonesDummy);

positive variables
         InstCap(Tech,Zones) "Installed capacity of technology y in zone z [MW]"
         RetCap(Tech,Zones) "Retired capacity of technology y from existing capacity in zone z [MW]"
         EnergyInjected(Tech,Times,Zones) "Energy injected into the grid by technology y at hour t in zone z [MWh]"
         EnergyWithdrawn(Tech,Times,Zones) "Energy withdrawn from the grid by technology y at hour t in zone z [MWh]"
         StoredEnergy(Tech,Times,Zones) "Stored energy level of technology y at end of hour t in zone z [MWh]"
         CurtailedEnergy(Segments,Times,Zones) "Non-served energy/curtailed demand from the price-responsive demand segment s at hour t in zone z [MWh]"
         LineExpansion(Lines) "Expansion of transmission capacity in line l [MW]";

variables
         LineLoss(Lines,Times) "Losses in line l at hour t [MWh]"
         PowerFlow(Lines,Times) "Power flow in line l at hour t [MWh]"
         BusAngle(Zones,Times) "Bus angle of zone/bus z at hour t [rad]"
         LineLossModel(Lines,Times) "Chosen model for line losses";

positive variables
         PowerFlowAbsPositive(Lines,Times) "Power flow absolute value auxiliary variable for line l [MW] at time t in positive domain"
         PowerFlowAbsNegative(Lines,Times) "Power flow absolute value auxiliary variable for line l [MW] at time t in negative domain"
         PowerFlowAbs(Lines,Times) "Power flow absolute value variable for line l [MW] at time t"
         LineLossSlopePos(PiecewiseSeg,Lines)
         LineLossSlopeNeg(PiecewiseSeg,Lines)
         LineLossQuadraticPos(PiecewiseSeg,Lines,Times) "Segment m of piecewise approximation of quadratic transmission losses function for line l at time t [MW] in positive domain"
         LineLossQuadraticNeg(PiecewiseSeg,Lines,Times) "Segment m of piecewise approximation of quadratic transmission losses function for line l at time t [MW] in negative domain"
         LineLossQuadraticMax(PiecewiseSeg,Lines)
         LineLossQuadraticPosZero(Lines,Times)
         LineLossQuadraticNegZero(Lines,Times);

binary variables
         LineLossActivationPositive(PiecewiseSeg,Lines,Times) "Activation variable for segment m of piecewise approximation of quadratic transmission losses function for line l at time t in positive domain"
         LineLossActivationNegative(PiecewiseSeg,Lines,Times) "Activation variable for segment m of piecewise approximation of quadratic transmission losses function for line l at time t in negative domain";

semiint variables
         GenClusterCommitment(Tech,Times,Zones) "Commitment state of generator cluster y at hour t in zone z"
         GenClusterStartup(Tech,Times,Zones) "Startup events of generator cluster y at hour t in zone z"
         GenClusterShutdown(Tech,Times,Zones) "Shutdown events of generator cluster y at hour t in zone z";

positive variables
         HeatSold(Tech,Times,Zones) "Heat from storage sold by technology y at hour t in zone z [MWh]"
         HeatUsed(Tech,Times,Zones) "Heat from storage used for generation by technology y at hour t in zone z [MWh]"
         HeatNGUsed(Tech,Times,Zones) "Heat from natural gas combustion used for generation by technology y at hour t in zone z [MWh]";

positive variables
         ReserveContrib(ReserveTypes,Tech,Zones,Times) "Reserves contribution [MW] from technology y in zone z at time t"
         ReserveContribCharge(ReserveTypes,Tech,Zones,Times) "Reserves contribution [MW] from storage technology y during charging process in zone z at time t"
         ReserveContribDischarge(ReserveTypes,Tech,Zones,Times) "Reserves contribution [MW] from storage technology y during discharging process in zone z at time t"
         ReserveUnmet(ReserveTypes,Times) "Unmet reserves [MW] in time t";

* Distribution network loss variables
positive variables
         LineLossZone(Zones,Times) "Losses within distribution zone z at hour t [MWh]"
         LineLossZoneQuadraticPos(PiecewiseSeg,Zones,Times) "Segment m for piecewise approximation of quadratic term in distribution losses function for zone z at time t [MW] in the positive domain"
         LineLossZoneQuadraticNeg(PiecewiseSeg,Zones,Times) "Segment m for piecewise approximation of quadratic term in distribution losses function for zone z at time t [MW] in the negative domain"
         PowerWithdrawalMargin(Zones,Times) "Power withdrawal margin gained via optimal dispatch of distributed resources in distribution zone z [MW] at hour t"
         PowerInjectionMargin(Zones,Times) "Power injection margin gained via optimal dispatch of distributed resources in distribution zone z [MW] at hour t"
         PowerWithdrawalMarginSegment(PiecewiseSeg,Zones,Times) "Segment m for linear approximation of network withdrawal margin gained from optimal dispatch of distributed resources in zone z at hour t";

positive variables
         DistributionZoneWithdrawalReinforcement(Zones) "New power withdrawal network capacity added to distribution zone z [MW]"
         DistributionZoneInjectionReinforcement(Zones) "New power injection network capacity added to distribution zone z [MW]";



* Variables calculated for convenience
positive variables
         AnnualDemand(Zones) "Variable for convenience of holding calculated annual demand by zone"
         ReserveRequirementUnit(ReserveTypes,Zones,Times)
         LineLossZoneSlopePos(PiecewiseSeg,Zones)
         LineLossZoneSlopeNeg(PiecewiseSeg,Zones)
         DistributionZoneWithdrawal(Zones,Times)
         DistributionZoneInjection(Zones,Times);




Variables Z "Objective function variable";

parameters
         LineLossConfig
         ReserveConfig "Operating reserve model config: 1 = Max Potential Unit Size; 2 = Max of Potential Unit Size or Line Size; 3 = Max of Actual Unit Size or Line Size; 4 = Max of Committed Unit Size or Line Size"
         IntegerModel "Determines whether the model is run as MIP family: 1=MIP; 0=LP/NLP";

sets
         ModelOptions "Dummy variable to sum across model options" /1*4/;

************************
parameters
         Demand(Times,Zones) "Electricity demand at hour t in zone z [MWh]"
         HeatDemand(Times,Zones) "Heat demand at hour t in zone z [MWh]"

         CostCurtailedDemand(Segments) "Cost of non-served energy/demand curtailment for price-responsive demand segment s [$/MWh]"
         PriceResponse(Segments) "Size of price-responsive demand segment s as a fraction of the hourly zonal demand [%]"
         HeatPrice(Zones) "Heat price in zone z [$/MWh]"

         MaxNewCap(Tech,Zones) "Maximum new capacity of technology y in zone z [MW]"
         ExistingCap(Tech,Zones) "Existing installed capacity of technology y in zone z [MW]"
         UnitSize(Tech,Zones) "Unit size of technology y in zone z [MW]"

         InvestmentCost(Tech,Zones) "Investment cost (annual amortization of total construction cost) for technology y in zone z [$/MW-yr]"
         FOMCost(Tech,Zones) "Fixed O&M cost of technology y in zone z [$/MW-yr]"
         VOMCost(Tech,Zones) "Variable O&M cost of technology y in zone z [$/MWh]"
         FuelCost(Tech,Zones) "Fuel cost of technology y in zone z [$/MWh]"
         StartupCost(Tech,Zones) "Startup cost of technology y in zone z [$/startup]"
         CO2EmissionRate(Tech,Zones) "CO2 emissions per unit energy produced by technology y in zone z [tons/MWh]"
         pmin(Tech,Zones) "Minimum stable power output per unit of installed capacity for technology y in zone z [%]"
         Availability(Tech,Times,Zones) "Maximum available generation per unit of installed capacity during hour t for technology y in zone z [%]"
         RampUpRate(Tech,Zones) "Maximum ramp-up rate per time step as percentage of installed capacity of technology y in zone z [%/hr]"
         RampDownRate(Tech,Zones) "Maximum ramp-down rate per time step as percentage of installed capacity of technology y in zone z [%/hr]"
         MinUpTime(Tech,Zones) "Minimum uptime for thermal generator type y in zone z before new shutdown [hours]"
         MinDownTime(Tech,Zones) "Minimum downtime or thermal generator type y in zone z before new restart [hours]"

         NACCHeatEfficiency(Tech,Zones) "Heat to electricity conversion efficiency for NACC technology y in zone z [%]"
         NACCPeakBaseRatio(Tech,Zones) "Peak to base generation ratio of for NACC technology y in zone z [%]"

         StorageLossRate(Tech,Zones) "Self discharge rate per hour per unit of installed capacity for storage technology y in zone z [%]"
         StorageEfficiencyCharge(Tech,Zones) "Single-trip efficiency of storage charging/demand deferral for technology y in zone z [%]"
         StorageEfficiencyDischarge(Tech,Zones) "Single-trip efficiency of storage discharging/demand satisfaction for technology y in zone z [%]"
         StoragePowerEnergyRatio(Tech,Zones) "Power to energy ratio of storage technology y in zone z [MW/MWh]"

         DSMRatio(Tech,Zones) "Maximum percentage of hourly demand that can be shifted by technology y in zone z [%]"
         DSMTimePeriods(Tech,Zones) "Time periods over which demand can be deferred using demand-side management technology y in zone z before demand must be satisfied [hours]"

         HydroInitialLevel(Tech,Zones) "Initial level of hydro reservoir y in zone z [%]"

         Map_LineZone(Lines,Zones) "Topology of the network, for line l: map = 1 for zone z of origin, -1 for zone z of destination, 0 otherwise"
         Map_ZoneZone(Zones,ZonesDummy) "Set of distribution zones downstream of each distribution zone z: d = 1 for zone d if z = d or if there is a path from z to d and d is at a lower voltage than z, 0 otherwise."
         Map_DZones(Zones) "Identify which Zones are Distribution Zones"
         Map_TZones(Zones) "Identify which Zones are Transmission Zones"

         LineCapacity(Lines) "Transmission capacity of line l [MW]"
         LineVoltage(Lines) "Transmission voltage of line l [kV]"
         LineResistance(Lines) "Transmission resistance of line l [Ohms]"
         LineLossRate(Lines) "Linear transmission losses per unit of power flow across line l [p.u.]"
         LineMaxAngleDiff(Lines) "Maximum angle difference of line l [rad]"

         LineExpansionMax(Lines) "Maximum power flow capacity reinforcement for line l [MW]"
         LineExpansionCost(Lines) "Transmission power flow reinforcement cost for line l [$/MW]"
         DistZoneReinforcementCost(Zones) "Distribution network reinforcement cost for zone z [$/MW]"


         CO2MaxRate(Zones) "CO2 emissions constraint for zone z [tons/MWh]"

         ReserveMaxContribution(ReserveTypes,Tech,Zones) "Max contribution of capacity to reserves [p.u.] for technology y in zone z"
         ReserveRequirement(ReserveTypes) "Reserves requirement as a function of hourly load [%]"
         ReserveRequirementVRE(ReserveTypes) "Reserves requirement as a function of hourly variable renewable resource availability[%]"
         ReserveUnmetCost(ReserveTypes) "Penalty for unmet reserve requirement [$/MW]"

         QualifyingREMin(Zones) "Minimum penetration of qualifying renewable energy resources required in zone z [%]"



         LossZoneQuadCoefficient(Zones) "Within zone distribution loss coefficient for quadratic term of polynomial function for losses due to net withdrawals in zone z"
         LossZoneLinearWithdrawalCoefficient(Zones) "Within zone distribution loss coefficient for linear term of polynomial function for losses due to aggregate withdrawals in zone z"
         LossZoneLinearInjectionCoefficient(Zones) "Within zone distribution loss coefficient for linear term of polynomial function for losses due to aggregate injections in zone z"
         LossZoneIntercept(Zones) "Within zone distribution loss intercept coefficient for polynomial function for losses in zone z"

         DistributionZoneMaxInjection(Zones) "Maximum aggregate power injection possible in distribution zone z [MW]"
         DistributionZoneMaxWithdrawal(Zones) "Maximum aggregate power withdrawal possible in distribution zone z [MW]"
         DistributionZoneMaxInjectionReinforcement(Zones) "Maximum distribution network aggregate injection capacity reinforcement for zone z [MW]"
         DistributionZoneMaxWithdrawalReinforcement(Zones) "Maximum distribution network aggregate withdrawal capacity reinforcement for zone z [MW]"
;


Equations
         ObjFunctionLP     "Objective function without integer variables (1)"
         ObjFunctionMIP    "Objective function with integer variables (1)"

** Investment decision constraints
         c_NewCap(Tech,Zones) "(2)"
         c_RetireCap(Tech,Zones) "(3)"
** CO2 emissions constraints
         c_MaxEmissionsZone(Zones) "(4)"
         c_MaxEmissionsGlobal "(5)"
** Minimum renewable energy mandate constraints
         c_QualifyingREZone(Zones) "(6)"
         c_QualifyingREGlobal "(7)"
** Demand balanace constraint
         c_DemandBalance(Zones,Times) "(8)"
         /* Equation 9 not needed if line reinforcement variable is fixed to zero for those not eligible  */
         c_LineCapacity(Lines,Times) "(10)"
         c_LineCapacityB(Lines,Times) "(10b)"
         c_MaxLineExpansion(Lines) "(11)"
         c_PowerFlow(Lines,Times) "(12)"
         c_BusAngleMax(Lines,Times) "(13)a"
         c_BusAngleMin(Lines,Times) "(13)b"
         /* Equation 14 not needed if reference bus angle is fixed to zero */
** Transmission network related constraints (15-29)
         c_LineLossModel(Lines,Times) "(15)"
         c_PowerFlowComponents(Lines,Times) "(16)"
         c_PowerFlowAbs(Lines,Times) "(17)"
         c_PowerFlowMaxPos(Lines,Times) "(18)"
         c_PowerFlowMaxNeg(Lines,Times) "(19)"
         calc_LineLoss(Lines,Times) "(20)a"
         calc_LineLossSlopePos(PiecewiseSeg,Lines) "(20)b"
         calc_LineLossSlopeNeg(PiecewiseSeg,Lines) "(20)c"
         calc_LineLossQuadraticMax(PiecewiseSeg,Lines) "(21)a"
         c_LineLossQuadraticPos(PiecewiseSeg,Lines,Times) "(21)b"
         c_LineLossQuadraticNeg(PiecewiseSeg,Lines,Times) "(21)c"
         c_LineLossSlopePos(Lines,Times) "(22)"
         c_LineLossSlopeNeg(Lines,Times) "(23)"
         c_LineLossSegmentPos(PiecewiseSeg,Lines,Times) "(24)"
         c_LineLossSegmentNeg(PiecewiseSeg,Lines,Times) "(25)"
         c_LineLossSegmentPos2(PiecewiseSeg,Lines,Times) "(26)"
         c_LineLossSegmentNeg2(PiecewiseSeg,Lines,Times) "(27)"


** Unit commitment constraints (30-39)
         c_GenClusterCommitment(Tech,Times,Zones) "(30) modified"
         c_GenClusterStartup(Tech,Times,Zones) "(31) modified"
         c_GenClusterShutdown(Tech,Times,Zones) "(31) modified"
         c_InterTemp(Tech,Times,Zones) "(33)"
         c_Pmin(Tech,Times,Zones) "(34)"
         c_Pmax(Tech,Times,Zones) "(35)"
         c_RampDown(Tech,Times,Zones) "(36)"
         c_RampUp(Tech,Times,Zones) "(37)"
         c_MinUpTime(Tech,Times,Zones) "(38)"
         c_MinDownTime(Tech,Times,Zones) "(39)"
** Constraints for other thermal (40-43)
         c_RampDownNonUC(Tech,Times,Zones) "(40)"
         c_RampUpNonUC(Tech,Times,Zones) "(41)"
         c_PminNonUC(Tech,Times,Zones) "(42)"
         c_PmaxNonUC(Tech,Times,Zones) "(43)"
** Renewable technologies operational constraints (44-45)
         c_PmaxDisp(Tech,Times,Zones) "(44)"
         c_PmaxNonDisp(Tech,Times,Zones) "(45)"
         /* Potential to combine equations 35,43,44,45 */
** Storage resources operational constraints (46-52)
         c_StorageIntertemp(Tech,Times,Zones) "(46)"
         c_StorageCapacity(Tech,Times,Zones) "(47)"
         c_StorageChargeRate(Tech,Times,Zones) "(48)"
         c_StorageCharge(Tech,Times,Zones) "(49)"
         c_StorageDischargeRate(Tech,Times,Zones) "(50)"
         c_StorageDischarge(Tech,Times,Zones) "(51)"
         c_StoragePower(Tech,Times,Zones) "(52)"
** Demand-side management constraints (53-55)
         c_DRIntertemp(Tech,Times,Zones) "(53) - identical to Eq. 46, with 100% eff"
         c_DRCapacity(Tech,Times,Zones) "(54)"
         c_DRTimePeriods(Tech,Times,Zones) "(55)"
** Demand response constraint (56)
         c_PriceResponse(Segments,Times,Zones) "(56)"
** NACC operational constraints (57-60)
         c_PmaxNonUCAdvNuclear(Tech,Times,Zones) "(57) - identical to Eq. 43, 100% availability"
         c_AdvNuclearPeak(Tech,TechDummy,Times,Zones) "(58)"
         c_PmaxAdvNuclearUC(Tech,Times,Zones) "(59) - identical to Eq. 35"
         c_AdvNuclearHeatUC(Tech,TechDummy,Times,Zones) "(60)"
** Heat storage operational constraints (61-69)
         c_HeatStorageIntertemp(Tech,Times,Zones) "(61) - identical to Eq. 46"
         c_HeatStorageCapacity(Tech,Times,Zones) "(62) - identical to Eq. 47"
         c_HeatStorageChargeRate(Tech,Times,Zones) "(63) - identical to Eq. 48"
         c_HeatStorageCharge(Tech,Times,Zones) "(64) - identical to Eq. 49"
         c_HeatStorageDischargeRate(Tech,Times,Zones) "(65) - identical to Eq. 50"
         c_HeatStorageDischarge(Tech,Times,Zones) "(66) - identical to Eq. 51"
         c_HeatStoragePower(Tech,Times,Zones) "(67) - identical to Eq. 52"
         c_HeatStorageBalance(Tech,Times,Zones) "(68)"
         c_HeatStorageDemand(Times,Zones) "(69)"
** Hydro reservoir resources operational constraints (70-75)
         c_HydroIntertemp(Tech,Times,Zones) "(70) - similar to Eq. 46"
         c_HydroLevelStart(Tech,Zones) "(71)"
         c_HydroCapacity(Tech,Times,Zones) "(72) - similar to Eq. 47"
         c_HydroDischargeRate(Tech,Times,Zones) "(73) - identical to Eq. 50/65"
         c_HydroDischarge(Tech,Times,Zones) "(74) - identical to Eq. 51/66"
         c_HydroPmin(Tech,Times,Zones) "(75) - identical to Eq. 42 etc."
** Operating reserves related constraints (76-117)
         c_ReserveRequirements(ReserveTypes,Times) "(76)-(80)"
         c_ReserveContributionsUC(ReserveTypes,Tech,Zones,Times) "(81)-(84)"
         c_ReserveContributionsNonUC(ReserveTypes,Tech,Zones,Times) "(85)-(88)"
         c_ReserveContributionsStorage(ReserveTypes,Tech,Zones,Times) "(89)-(92)"
         c_ReserveContributionsUCPmin(Tech,Zones,Times) "(93)"
         c_ReserveContributionsUCPmax(Tech,Zones,Times) "(94)"
         c_ReserveContributionsThermalPmin(Tech,Zones,Times) "(95)"
         c_ReserveContributionsThermalPmax(Tech,Zones,Times) "(96)"
         c_ReserveContributionsDispatchableREPmin(Tech,Zones,Times) "(97)"
         c_ReserveContributionsDispatchableREPmax(Tech,Zones,Times) "(98)"
         c_ReserveContributionsStorageChargeEff(Tech,Zones,Times) "(99)"
         c_ReserveContributionsStorageChargeJoint(Tech,Zones,Times) "(100)"
         c_ReserveContributionsStorageChargePmin(Tech,Zones,Times) "(101)"
         c_ReserveContributionsStorageDischargeEff(Tech,Zones,Times) "(102)"
         c_ReserveContributionsStorageDischargeJoint(Tech,Zones,Times) "(103)"
         c_ReserveContributionsStorageDischargePmin(Tech,Zones,Times) "(104)"
         c_ReserveContributionsStorageJoint(Tech,Zones,Times) "(105)"
         c_ReserveContributionsHydroDischargeEff(Tech,Zones,Times) "(106)"
         c_ReserveContributionsHydroPmax(Tech,Zones,Times) "(107)"
         c_ReserveContributionsHydroPmin(Tech,Zones,Times) "(108)"
         c_ReserveContributionsUCAdvNuclear(ReserveTypes,Tech,Zones,Times) "(109)-(112)"
         c_ReserveContributionsUCAdvNuclearHeatPmax(Tech,TechDummy,Zones,Times) "(113)"
         c_ReserveContributionsUCAdvNuclearHeatPmin(Tech,TechDummy,Zones,Times) "(114)"
         c_ReserveContributionsHeatStorageChargeEff(Tech,Zones,Times) "(115) - identical to Eq. 99"
         c_ReserveContributionsHeatStorageChargeJoint(Tech,Zones,Times) "(116)"
         c_ReserveContributionsHeatStoragePmin(Tech,Zones,Times) "(117)"
** Distribution network related constraints (118-136)
         calc_LineLossZone(Zones,Times) "(118)"
         calc_LineLossZoneSlopePos(PiecewiseSeg,Zones) "(118)a"
         calc_LineLossZoneSlopeNeg(PiecewiseSeg,Zones) "(118)b"
         calc_DistributionZoneWithdrawal(Zones,Times)  "(118)c"
         calc_DistributionZoneInjection(Zones,Times)   "(118)d"

         c_LineLossZoneQuadraticPos(PiecewiseSeg,Zones,Times) "(119)"
         c_LineLossZoneQuadraticNeg(PiecewiseSeg,Zones,Times) "(120)"

** Integrality constraints (137-160)

         /* Eq. 136 -- see limits */
         /* Eq. 137, 138 positive capacity variables */

         /* Eq. 142 positive variables */
         /* Eq. 143 -- see limits */
         /* Eq. 144,145,146 positive variables */
         /* Eq. 147 -- see limits */
         /* Eq. 148 -- see limits */
         /* Eq. 150 -- see limits */
         /* Eq. 151 positive variables */
         /* Eq. 152 -- see limits */
         /* Eq. 153 positive capacity variables */
         /* Eq. 154 -- see limits */
         /* Eq. 155 positive capacity variables */

         calc_ReserveRequirementUnit(ReserveTypes,Zones,Times) "Equation for convenience of calculating reserve requirements based upon model config"
         calc_AnnualDemand(Zones) "Equation for convenience of calculating the total demand"
;

ObjFunctionMIP..
         Z =e=   sum((Zones,Tech),               InvestmentCost(Tech,Zones) * InstCap(Tech,Zones) + FOMCost(Tech,Zones) * (ExistingCap(Tech,Zones) + InstCap(Tech,Zones) - RetCap(Tech,Zones)))
                 + sum((Zones,Tech,Times),      (VOMCost(Tech,Zones) + FuelCost(Tech,Zones))*EnergyInjected(Tech,Times,Zones) + VOMCost(Tech,Zones)*EnergyWithdrawn(Tech,Times,Zones) + HeatPrice(Zones)*HeatNGUsed(Tech,Times,Zones) )
                 + sum((Zones,Times,Segments),   CostCurtailedDemand(Segments) * CurtailedEnergy(Segments,Times,Zones))
                 + sum((Zones,Tech,Times),       StartupCost(Tech,Zones) * GenClusterStartup(Tech,Times,Zones))
                 - sum((Zones,Tech,Times),       HeatPrice(Zones) * HeatSold(Tech,Times,Zones))
                 + sum((ReserveTypes,Times),     ReserveUnmet(ReserveTypes,Times) * ReserveUnmetCost(ReserveTypes))
                 + sum(LinesEligibleReinforcement, LineExpansionCost(LinesEligibleReinforcement) * LineExpansion(LinesEligibleReinforcement))
                 + sum(DZones,                   DistZoneReinforcementCost(DZones) * (DistributionZoneWithdrawalReinforcement(DZones)+ DistributionZoneInjectionReinforcement(DZones)));

ObjFunctionLP..
         Z =e=   sum((Zones,Tech),               InvestmentCost(Tech,Zones) * InstCap(Tech,Zones) + FOMCost(Tech,Zones) * (ExistingCap(Tech,Zones) + InstCap(Tech,Zones) - RetCap(Tech,Zones)))
                 + sum((Zones,Tech,Times),      (VOMCost(Tech,Zones) + FuelCost(Tech,Zones))*EnergyInjected(Tech,Times,Zones) + VOMCost(Tech,Zones)*EnergyWithdrawn(Tech,Times,Zones) + HeatPrice(Zones)*HeatNGUsed(Tech,Times,Zones) )
                 + sum((Zones,Times,Segments),   CostCurtailedDemand(Segments) * CurtailedEnergy(Segments,Times,Zones))
                 - sum((Zones,Tech,Times),       HeatPrice(Zones) * HeatSold(Tech,Times,Zones))
                 + sum((ReserveTypes,Times),     ReserveUnmet(ReserveTypes,Times) * ReserveUnmetCost(ReserveTypes))
                 + sum(LinesEligibleReinforcement, LineExpansionCost(LinesEligibleReinforcement) * LineExpansion(LinesEligibleReinforcement))
                 + sum(DZones,                   DistZoneReinforcementCost(DZones) * (DistributionZoneWithdrawalReinforcement(DZones)+ DistributionZoneInjectionReinforcement(DZones)));

c_NewCap(Tech,Zones)$(MaxNewCap(Tech,Zones))..
          InstCap(Tech,Zones) =l=  MaxNewCap(Tech,Zones);

c_RetireCap(Tech,Zones)..
          RetCap(Tech,Zones) =l=  ExistingCap(Tech,Zones);

c_MaxEmissionsZone(Zones)$(CO2MaxRate(Zones))..
          sum((Tech,Times), CO2EmissionRate(Tech,Zones)*(EnergyInjected(Tech,Times,Zones) + EnergyWithdrawn(Tech,Times,Zones))) =l=  CO2MaxRate(Zones) * AnnualDemand(Zones);

c_MaxEmissionsGlobal$(sum(Zones,CO2MaxRate(Zones)))..
          sum((Tech,Times,Zones), CO2EmissionRate(Tech,Zones)*(EnergyInjected(Tech,Times,Zones) + EnergyWithdrawn(Tech,Times,Zones))) =l=  sum(Zones,CO2MaxRate(Zones) * AnnualDemand(Zones));

c_QualifyingREZone(Zones)$(QualifyingREMin(Zones))..
         sum((RE,Times),EnergyInjected(RE,Times,Zones)) =g= QualifyingREMin(Zones)* AnnualDemand(Zones);

c_QualifyingREGlobal$(sum(zones,QualifyingREMin(Zones)))..
         sum((Zones,RE,Times),EnergyInjected(RE,Times,Zones)) =g= sum(zones,QualifyingREMin(Zones)* AnnualDemand(Zones));

c_DemandBalance(Zones,Times)..
         sum(Thermal,EnergyInjected(Thermal,Times,Zones)) + sum(RE,EnergyInjected(RE,Times,Zones)) + sum(Hydro,EnergyInjected(Hydro,Times,Zones))
         + sum(Storage,EnergyInjected(Storage,Times,Zones) - EnergyWithdrawn(Storage,Times,Zones))
         + sum(DR,-EnergyInjected(DR,Times,Zones) + EnergyWithdrawn(DR,Times,Zones))
         - sum(HeatStorage,EnergyWithdrawn(HeatStorage,Times,Zones))
         + sum(AdvNuclear,EnergyInjected(AdvNuclear,Times,Zones) + NACCHeatEfficiency(AdvNuclear,Zones)*(HeatUsed(AdvNuclear,Times,Zones)+HeatNGUsed(AdvNuclear,Times,Zones)))
         + sum(Segments,CurtailedEnergy(Segments,Times,Zones))
         - sum(Lines, Map_LineZone(Lines,Zones)*PowerFlow(Lines,Times))
         - 0.5 * sum(Lines, abs(Map_LineZone(Lines,Zones)) * LineLossModel(Lines,Times))
         - LineLossZone(Zones,Times)
         =e= Demand(Times,Zones);


c_LineCapacity(Lines,Times)..
         PowerFlow(Lines,Times) =l= LineCapacity(Lines) + LineExpansion(Lines);
         /* Fixed line capacity */

c_LineCapacityB(Lines,Times)..
         PowerFlow(Lines,Times) =g= - (LineCapacity(Lines) + LineExpansion(Lines));

c_MaxLineExpansion(LinesEligibleReinforcement)$(LineExpansionMax(LinesEligibleReinforcement))..
         LineExpansion(LinesEligibleReinforcement) =l= LineExpansionMax(LinesEligibleReinforcement);

c_PowerFlow(Lines,Times)..
         PowerFlow(Lines,Times) =e= LineVoltage(Lines)**2 / LineResistance(Lines) * sum(Zones,Map_LineZone(Lines,Zones)*BusAngle(Zones,Times));

c_BusAngleMax(Lines,Times)..
         sum(Zones,Map_LineZone(Lines,Zones)*BusAngle(Zones,Times)) =l= LineMaxAngleDiff(Lines);

c_BusAngleMin(Lines,Times)..
         sum(Zones,Map_LineZone(Lines,Zones)*BusAngle(Zones,Times)) =g= - LineMaxAngleDiff(Lines);

** Transmission loss constraints (15)
c_LineLossModel(Lines,Times)..
         LineLossModel(Lines,Times) =e=   0$(LineLossConfig=0)
                                      + (LineLossRate(Lines) * PowerFlowAbs(Lines,Times))$(LineLossConfig=1)
                                      + LineLoss(Lines,Times)$(LineLossConfig=2);

c_PowerFlowComponents(Lines,Times)..
         PowerFlow(Lines,Times) =e= PowerFlowAbsPositive(Lines,Times) - PowerFlowAbsNegative(Lines,Times);

c_PowerFlowAbs(Lines,Times)..
         PowerFlowAbs(Lines,Times) =e= PowerFlowAbsPositive(Lines,Times) + PowerFlowAbsNegative(Lines,Times);

c_PowerFlowMaxPos(Lines,Times)..
         PowerFlowAbsPositive(Lines,Times) =l= LineCapacity(Lines) + LineExpansion(Lines);

c_PowerFlowMaxNeg(Lines,Times)..
         PowerFlowAbsNegative(Lines,Times) =l= LineCapacity(Lines) + LineExpansion(Lines);


calc_LineLoss(Lines,Times)..
         LineLoss(Lines,Times) =e= LineResistance(Lines) / LineVoltage(Lines)**2 * sum(PiecewiseSeg,LineLossSlopePos(PiecewiseSeg,Lines)*LineLossQuadraticPos(PiecewiseSeg,Lines,Times) + LineLossSlopeNeg(PiecewiseSeg,Lines) * LineLossQuadraticNeg(PiecewiseSeg,Lines,Times) );

calc_LineLossSlopePos(PiecewiseSeg,Lines)..
         LineLossSlopePos(PiecewiseSeg,Lines) =e= (2 + 4 * sqrt(2) * (ord(PiecewiseSeg) - 1)) / (1 + sqrt(2) * (2 * card(PiecewiseSeg) - 1)) * (LineCapacity(Lines) + LineExpansion(Lines));

calc_LineLossSlopeNeg(PiecewiseSeg,Lines)..
         LineLossSlopeNeg(PiecewiseSeg,Lines) =e= (2 + 4 * sqrt(2) * (ord(PiecewiseSeg) - 1)) / (1 + sqrt(2) * (2 * card(PiecewiseSeg) - 1)) * (LineCapacity(Lines) + LineExpansion(Lines));

calc_LineLossQuadraticMax(PiecewiseSeg,Lines)..
         LineLossQuadraticMax(PiecewiseSeg,Lines) =e= ((1 + sqrt(2))$(ord(PiecewiseSeg)=1) + (2 * sqrt(2))$(ord(PiecewiseSeg)>1)) / (1 + sqrt(2) * (2 * card(PiecewiseSeg) - 1)) * ( LineCapacity(Lines) + LineExpansion(Lines)) ;

c_LineLossQuadraticPos(PiecewiseSeg,Lines,Times)..
         LineLossQuadraticPos(PiecewiseSeg,Lines,Times) =l= LineLossQuadraticMax(PiecewiseSeg,Lines);

c_LineLossQuadraticNeg(PiecewiseSeg,Lines,Times)..
         LineLossQuadraticNeg(PiecewiseSeg,Lines,Times) =l= LineLossQuadraticMax(PiecewiseSeg,Lines);

c_LineLossSlopePos(Lines,Times)..
         sum(PiecewiseSeg,LineLossQuadraticPos(PiecewiseSeg,Lines,Times)) - LineLossQuadraticPosZero(Lines,Times) =e= PowerFlow(Lines,Times);

c_LineLossSlopeNeg(Lines,Times)..
         sum(PiecewiseSeg,LineLossQuadraticNeg(PiecewiseSeg,Lines,Times)) - LineLossQuadraticNegZero(Lines,Times) =e= - PowerFlow(Lines,Times);

c_LineLossSegmentPos(PiecewiseSeg,Lines,Times)..
         LineLossQuadraticPos(PiecewiseSeg,Lines,Times) =l= LineLossQuadraticMax(PiecewiseSeg,Lines) * LineLossActivationPositive(PiecewiseSeg,Lines,Times);

c_LineLossSegmentNeg(PiecewiseSeg,Lines,Times)..
         LineLossQuadraticNeg(PiecewiseSeg,Lines,Times) =l= LineLossQuadraticMax(PiecewiseSeg,Lines) * LineLossActivationNegative(PiecewiseSeg,Lines,Times);

c_LineLossSegmentPos2(PiecewiseSeg,Lines,Times)..
         LineLossQuadraticPos(PiecewiseSeg,Lines,Times) =g= LineLossActivationPositive(PiecewiseSeg + 1,Lines,Times) * LineLossQuadraticMax(PiecewiseSeg,Lines);

c_LineLossSegmentNeg2(PiecewiseSeg,Lines,Times)..
         LineLossQuadraticNeg(PiecewiseSeg,Lines,Times) =g= LineLossActivationNegative(PiecewiseSeg + 1,Lines,Times) * LineLossQuadraticMax(PiecewiseSeg,Lines);




** Unit commitment constraints (30-39)

c_GenClusterCommitment(UC,Times,Zones)..
         GenClusterCommitment(UC,Times,Zones) =l= (ExistingCap(UC,Zones) + InstCap(UC,Zones) - RetCap(UC,Zones)) / UnitSize(UC,Zones);

c_GenClusterStartup(UC,Times,Zones)..
         GenClusterStartup(UC,Times,Zones) =l= (ExistingCap(UC,Zones) + InstCap(UC,Zones) - RetCap(UC,Zones)) / UnitSize(UC,Zones);

c_GenClusterShutdown(UC,Times,Zones)..
         GenClusterShutdown(UC,Times,Zones) =l= (ExistingCap(UC,Zones) + InstCap(UC,Zones) - RetCap(UC,Zones)) / UnitSize(UC,Zones);

c_InterTemp(UC,Times,Zones)..
         GenClusterCommitment(UC,Times,Zones) =e= GenClusterCommitment(UC,Times - 1,Zones) + GenClusterStartup(UC,Times,Zones) - GenClusterShutdown(UC,Times,Zones);

c_Pmin(UC,Times,Zones)..
         EnergyInjected(UC,Times,Zones) =g= pmin(UC,Zones) * UnitSize(UC,Zones) * GenClusterCommitment(UC,Times,Zones);

c_Pmax(UC,Times,Zones)..
         EnergyInjected(UC,Times,Zones) =l= Availability(UC,Times,Zones) * UnitSize(UC,Zones) * GenClusterCommitment(UC,Times,Zones);

c_RampDown(UC,Times,Zones)..
         EnergyInjected(UC,Times-1,Zones) - EnergyInjected(UC,Times,Zones) =l= RampDownRate(UC,Zones) * UnitSize(UC,Zones) * (GenClusterCommitment(UC,Times,Zones) - GenClusterStartup(UC,Times,Zones))
                                                                                 - pmin(UC,Zones) * UnitSize(UC,Zones) * GenClusterStartup(UC,Times,Zones)
                                                                                 + min( Availability(UC,Times,Zones), max(pmin(UC,Zones),RampDownRate(UC,Zones))) * UnitSize(UC,Zones) * GenClusterShutdown(UC,Times,Zones);

c_RampUp(UC,Times,Zones)..
         EnergyInjected(UC,Times,Zones) - EnergyInjected(UC,Times-1,Zones) =l= RampUpRate(UC,Zones) * UnitSize(UC,Zones) * (GenClusterCommitment(UC,Times,Zones) - GenClusterStartup(UC,Times,Zones))
                                                                                 - pmin(UC,Zones) * UnitSize(UC,Zones) * GenClusterShutdown(UC,Times,Zones)
                                                                                 + min( Availability(UC,Times,Zones), max(pmin(UC,Zones),RampUpRate(UC,Zones))) * UnitSize(UC,Zones) * GenClusterStartup(UC,Times,Zones);

c_MinUpTime(UC,Times,Zones)..
         GenClusterCommitment(UC,Times,Zones) =g= sum(TimesDummy$(ord(TimesDummy)<=ord(Times)and ord(TimesDummy)>=(ord(Times)-MinUpTime(UC,Zones))), GenClusterStartup(UC,TimesDummy,Zones));

c_MinDownTime(UC,Times,Zones)..
         (ExistingCap(UC,Zones) + InstCap(UC,Zones) - RetCap(UC,Zones)) / UnitSize(UC,Zones) - GenClusterCommitment(UC,Times,Zones) =g=
                 sum(TimesDummy$(ord(TimesDummy)<=ord(Times)and ord(TimesDummy)>=(ord(Times)-MinUpTime(UC,Zones))), GenClusterStartup(UC,TimesDummy,Zones));

c_RampDownNonUC(NonUC,Times,Zones)..
         EnergyInjected(NonUC,Times-1,Zones) - EnergyInjected(NonUC,Times,Zones) =l= RampDownRate(NonUC,Zones) * (ExistingCap(NonUC,Zones) + InstCap(NonUC,Zones) - RetCap(NonUC,Zones));

c_RampUpNonUC(NonUC,Times,Zones)..
         EnergyInjected(NonUC,Times,Zones) - EnergyInjected(NonUC,Times-1,Zones) =l= RampUpRate(NonUC,Zones) * (ExistingCap(NonUC,Zones) + InstCap(NonUC,Zones) - RetCap(NonUC,Zones));

c_PminNonUC(NonUC,Times,Zones)..
         EnergyInjected(NonUC,Times,Zones) =g=  pmin(NonUC,Zones) * (ExistingCap(NonUC,Zones) + InstCap(NonUC,Zones) - RetCap(NonUC,Zones));

c_PmaxNonUC(NonUC,Times,Zones)..
         EnergyInjected(NonUC,Times,Zones) =l=  Availability(NonUC,Times,Zones) * (ExistingCap(NonUC,Zones) + InstCap(NonUC,Zones) - RetCap(NonUC,Zones));

c_PmaxDisp(DispatchableRE,Times,Zones)..
         EnergyInjected(DispatchableRE,Times,Zones) =l=  Availability(DispatchableRE,Times,Zones) * (ExistingCap(DispatchableRE,Zones) + InstCap(DispatchableRE,Zones) - RetCap(DispatchableRE,Zones));

c_PmaxNonDisp(NonDispatchableRE,Times,Zones)..
         EnergyInjected(NonDispatchableRE,Times,Zones) =l= Availability(NondispatchableRE,Times,Zones) * (ExistingCap(NonDispatchableRE,Zones) + InstCap(NonDispatchableRE,Zones) - RetCap(NonDispatchableRE,Zones));

c_StorageIntertemp(Storage,Times,Zones)..
         StoredEnergy(Storage,Times,Zones) =e= StoredEnergy(Storage,Times - 1,Zones) - (EnergyInjected(Storage,Times,Zones) / StorageEfficiencyDischarge(Storage,Zones))
                                                 + ( StorageEfficiencyCharge(Storage,Zones) *  EnergyWithdrawn(Storage,Times,Zones) )
                                                 - ( StorageLossRate(Storage,Zones) * StoredEnergy(Storage,Times,Zones) );

c_StorageCapacity(Storage,Times,Zones)..
         StoredEnergy(Storage,Times,Zones) =l= (ExistingCap(Storage,Zones) + InstCap(Storage,Zones) - RetCap(Storage,Zones)) / StoragePowerEnergyRatio(Storage,Zones);

c_StorageChargeRate(Storage,Times,Zones)..
         EnergyWithdrawn(Storage,Times,Zones) =l= (ExistingCap(Storage,Zones) + InstCap(Storage,Zones) - RetCap(Storage,Zones)) / StorageEfficiencyCharge(Storage,Zones);

c_StorageCharge(Storage,Times,Zones)..
         EnergyWithdrawn(Storage,Times,Zones) =l= (ExistingCap(Storage,Zones) + InstCap(Storage,Zones) - RetCap(Storage,Zones)) / StoragePowerEnergyRatio(Storage,Zones) - StoredEnergy(Storage,Times,Zones) ;

c_StorageDischargeRate(Storage,Times,Zones)..
         EnergyInjected(Storage,Times,Zones) =l= StorageEfficiencyDischarge(Storage,Zones) * (ExistingCap(Storage,Zones) + InstCap(Storage,Zones) - RetCap(Storage,Zones));

c_StorageDischarge(Storage,Times,Zones)..
         EnergyInjected(Storage,Times,Zones) =l= StoredEnergy(Storage,Times,Zones);

c_StoragePower(Storage,Times,Zones)..
         (EnergyInjected(Storage,Times,Zones) / StorageEfficiencyDischarge(Storage,Zones)) + (StorageEfficiencyCharge(Storage,Zones) * EnergyWithdrawn(Storage,Times,Zones)) =l=
                 ExistingCap(Storage,Zones) + InstCap(Storage,Zones) - RetCap(Storage,Zones);

** Demand Response constraints (53-56)
c_DRIntertemp(DR,Times,Zones)..
         StoredEnergy(DR,Times,Zones) =e= StoredEnergy(DR,Times - 1,Zones) - EnergyInjected(DR,Times,Zones) - EnergyWithdrawn(DR,Times,Zones);

c_DRCapacity(DR,Times,Zones)..
         EnergyWithdrawn(DR,Times,Zones) =l= DSMRatio(DR,Zones) * Demand(Times,Zones);

c_DRTimePeriods(DR,Times,Zones)..
         sum(TimesDummy$(ord(TimesDummy)>=ord(Times)+1 and ord(TimesDummy)<=ord(Times)+DSMTimePeriods(DR,Zones)), EnergyInjected(DR,TimesDummy,Zones)) =g= StoredEnergy(DR,Times,Zones);

c_PriceResponse(Segments,Times,Zones)..
         CurtailedEnergy(Segments,Times, Zones) =l= PriceResponse(Segments) * Demand(Times,Zones);

** NACC operational constraints (57-60)
c_PmaxNonUCAdvNuclear(NonUCAdvNuclear,Times,Zones)..
         EnergyInjected(NonUCAdvNuclear,Times,Zones) =l=  ExistingCap(NonUCAdvNuclear,Zones) + InstCap(NonUCAdvNuclear,Zones) - RetCap(NonUCAdvNuclear,Zones);

c_AdvNuclearPeak(NonUCAdvNuclear,HeatStorage,Times,Zones)..
         HeatUsed(HeatStorage,Times,Zones) + HeatNGUsed(NonUCAdvNuclear,Times,Zones) =l= NACCPeakBaseRatio(NonUCAdvNuclear,Zones) * (ExistingCap(NonUCAdvNuclear,Zones) + InstCap(NonUCAdvNuclear,Zones) - RetCap(NonUCAdvNuclear,Zones));

c_PmaxAdvNuclearUC(UCAdvNuclear,Times,Zones)..
         EnergyInjected(UCAdvNuclear,Times,Zones) =e= Availability(UCAdvNuclear,Times,Zones) * UnitSize(UCAdvNuclear,Zones) * GenClusterCommitment(UCAdvNuclear,Times,Zones);

c_AdvNuclearHeatUC(UCAdvNuclear,HeatStorage,Times,Zones)..
         HeatUsed(HeatStorage,Times,Zones) + HeatNGUsed(UCAdvNuclear,Times,Zones) =l= NACCPeakBaseRatio(UCAdvNuclear,Zones) * UnitSize(UCAdvNuclear,Zones) * GenClusterCommitment(UCAdvNuclear,Times,Zones);

c_HeatStorageIntertemp(HeatStorage,Times,Zones)..
         StoredEnergy(HeatStorage,Times,Zones) =e= StoredEnergy(HeatStorage,Times - 1,Zones) - (EnergyInjected(HeatStorage,Times,Zones) / StorageEfficiencyDischarge(HeatStorage,Zones))
                                                 + ( StorageEfficiencyCharge(HeatStorage,Zones) *  EnergyWithdrawn(HeatStorage,Times,Zones) )
                                                 - ( StorageLossRate(HeatStorage,Zones) * StoredEnergy(HeatStorage,Times,Zones) );

** Heat storage operational constraints (61-69)
c_HeatStorageCapacity(HeatStorage,Times,Zones)..
         StoredEnergy(HeatStorage,Times,Zones) =l= (ExistingCap(HeatStorage,Zones) + InstCap(HeatStorage,Zones) - RetCap(HeatStorage,Zones)) / StoragePowerEnergyRatio(HeatStorage,Zones);

c_HeatStorageChargeRate(HeatStorage,Times,Zones)..
         EnergyWithdrawn(HeatStorage,Times,Zones) =l= (ExistingCap(HeatStorage,Zones) + InstCap(HeatStorage,Zones) - RetCap(HeatStorage,Zones)) / StorageEfficiencyCharge(HeatStorage,Zones);

c_HeatStorageCharge(HeatStorage,Times,Zones)..
         EnergyWithdrawn(HeatStorage,Times,Zones) =l= (ExistingCap(HeatStorage,Zones) + InstCap(HeatStorage,Zones) - RetCap(HeatStorage,Zones)) / StoragePowerEnergyRatio(HeatStorage,Zones) - StoredEnergy(HeatStorage,Times,Zones) ;

c_HeatStorageDischargeRate(HeatStorage,Times,Zones)..
         EnergyInjected(HeatStorage,Times,Zones) =l= StorageEfficiencyDischarge(HeatStorage,Zones) * (ExistingCap(HeatStorage,Zones) + InstCap(HeatStorage,Zones) - RetCap(HeatStorage,Zones));

c_HeatStorageDischarge(HeatStorage,Times,Zones)..
         EnergyInjected(HeatStorage,Times,Zones) =l= StoredEnergy(HeatStorage,Times,Zones);

c_HeatStoragePower(HeatStorage,Times,Zones)..
         (EnergyInjected(HeatStorage,Times,Zones) / StorageEfficiencyDischarge(HeatStorage,Zones)) + (StorageEfficiencyCharge(HeatStorage,Zones) * EnergyWithdrawn(HeatStorage,Times,Zones)) =l=
                 ExistingCap(HeatStorage,Zones) + InstCap(HeatStorage,Zones) - RetCap(HeatStorage,Zones);

c_HeatStorageBalance(HeatStorage,Times,Zones)..
         HeatSold(HeatStorage,Times,Zones) + HeatUsed(HeatStorage,Times,Zones) =e= EnergyInjected(HeatStorage,Times,Zones);

c_HeatStorageDemand(Times,Zones)..
         sum(HeatStorage,HeatSold(HeatStorage,Times,Zones)) =l= HeatDemand(Times,Zones);

c_HydroIntertemp(Hydro,Times,Zones)..
         StoredEnergy(Hydro,Times,Zones) =e= StoredEnergy(Hydro,Times-1,Zones) - (EnergyInjected(Hydro,Times,Zones) / StorageEfficiencyDischarge(Hydro,Zones))
                                                 + (Availability(Hydro,Times,Zones) * (ExistingCap(Hydro,Zones) + InstCap(Hydro,Zones) - RetCap(Hydro,Zones)) / StoragePowerEnergyRatio(Hydro,Zones)  );

c_HydroLevelStart(Hydro,Zones)..
         sum(Times$(ord(Times)=1),StoredEnergy(Hydro,Times,Zones)) =e= HydroInitialLevel(Hydro,Zones) * (ExistingCap(Hydro,Zones) + InstCap(Hydro,Zones) - RetCap(Hydro,Zones)) / StoragePowerEnergyRatio(Hydro,Zones);

c_HydroCapacity(Hydro,Times,Zones)..
         StoredEnergy(Hydro,Times,Zones) =l= (ExistingCap(Hydro,Zones) + InstCap(Hydro,Zones) - RetCap(Hydro,Zones)) / StoragePowerEnergyRatio(Hydro,Zones);

c_HydroDischargeRate(Hydro,Times,Zones)..
         EnergyInjected(Hydro,Times,Zones) =l= StorageEfficiencyDischarge(Hydro,Zones) * (ExistingCap(Hydro,Zones) + InstCap(Hydro,Zones) - RetCap(Hydro,Zones));

c_HydroDischarge(Hydro,Times,Zones)..
         EnergyInjected(Hydro,Times,Zones) =l= StoredEnergy(Hydro,Times,Zones);

c_HydroPmin(Hydro,Times,Zones)..
         EnergyInjected(Hydro,Times,Zones) =g=  pmin(Hydro,Zones) * (ExistingCap(Hydro,Zones) + InstCap(Hydro,Zones) - RetCap(Hydro,Zones));

c_ReserveRequirements(ReserveTypes,Times)..
** Only covers installed capacity **
          ReserveRequirement(ReserveTypes) * sum(Zones,Demand(Times,Zones)) + ReserveRequirementVRE(ReserveTypes) * sum((Zones,RE),InstCap(RE,Zones) * Availability(RE,Times,Zones))
                 =l= sum((Tech,Zones), ReserveContrib(ReserveTypes,Tech,Zones,Times)) + ReserveUnmet(ReserveTypes,Times);

c_ReserveContributionsUC(ReserveTypes,UC,Zones,Times)..
         ReserveContrib(ReserveTypes,UC,Zones,Times) =l= ReserveMaxContribution(ReserveTypes,UC,Zones) * UnitSize(UC,Zones)* GenClusterCommitment(UC,Times,Zones);

c_ReserveContributionsNonUC(ReserveTypes,NonUCReserves,Zones,Times)..
         ReserveContrib(ReserveTypes,NonUCReserves,Zones,Times) =l= ReserveMaxContribution(ReserveTypes,NonUCReserves,Zones) * Availability(NonUCReserves,Times,Zones) * ( ExistingCap(NonUCReserves,Zones) + InstCap(NonUCReserves,Zones) - RetCap(NonUCReserves,Zones));

c_ReserveContributionsStorage(ReserveTypes,Storage,Zones,Times)..
         ReserveContrib(ReserveTypes,Storage,Zones,Times) =e= ReserveContribCharge(ReserveTypes,Storage,Zones,Times) + ReserveContribDischarge(ReserveTypes,Storage,Zones,Times);

c_ReserveContributionsUCPmin(UC,Zones,Times)..
         EnergyInjected(UC,Times,Zones) - sum(ReserveTypesDown,ReserveContrib(ReserveTypesDown,UC,Zones,Times)) =g=
                 pmin(UC,Zones) * UnitSize(UC,Zones) * GenClusterCommitment(UC,Times,Zones);

c_ReserveContributionsUCPmax(UC,Zones,Times)..
         EnergyInjected(UC,Times,Zones) + sum(ReserveTypesUp,ReserveContrib(ReserveTypesUp,UC,Zones,Times)) =l=
                 Availability(UC,Times,Zones) * UnitSize(UC,Zones) * GenClusterCommitment(UC,Times,Zones);

c_ReserveContributionsThermalPmin(Thermal,Zones,Times)..
         EnergyInjected(Thermal,Times,Zones) - sum(ReserveTypesDown,ReserveContrib(ReserveTypesDown,Thermal,Zones,Times)) =g=
                 pmin(Thermal,Zones) * ( ExistingCap(Thermal,Zones) + InstCap(Thermal,Zones) - RetCap(Thermal,Zones));

c_ReserveContributionsThermalPmax(Thermal,Zones,Times)..
         EnergyInjected(Thermal,Times,Zones) + sum(ReserveTypesUp,ReserveContrib(ReserveTypesUp,Thermal,Zones,Times)) =l=
                 Availability(Thermal,Times,Zones) * ( ExistingCap(Thermal,Zones) + InstCap(Thermal,Zones) - RetCap(Thermal,Zones));

c_ReserveContributionsDispatchableREPmin(DispatchableRE,Zones,Times)..
         EnergyInjected(DispatchableRE,Times,Zones) - sum(ReserveTypesDown,ReserveContrib(ReserveTypesDown,DispatchableRE,Zones,Times)) =g= 0;

c_ReserveContributionsDispatchableREPmax(DispatchableRE,Zones,Times)..
          EnergyInjected(DispatchableRE,Times,Zones) + sum(ReserveTypesUp,ReserveContrib(ReserveTypesUp,DispatchableRE,Zones,Times)) =l=
                 Availability(DispatchableRE,Times,Zones) * ( ExistingCap(DispatchableRE,Zones) + InstCap(DispatchableRE,Zones) - RetCap(DispatchableRE,Zones));

c_ReserveContributionsStorageChargeEff(Storage,Zones,Times)..
          EnergyWithdrawn(Storage,Times,Zones) + sum(ReserveTypesDown,ReserveContribCharge(ReserveTypesDown,Storage,Zones,Times)) =l=
                 ( ExistingCap(Storage,Zones) + InstCap(Storage,Zones) - RetCap(Storage,Zones)) / StorageEfficiencyCharge(Storage,Zones);

c_ReserveContributionsStorageChargeJoint(Storage,Zones,Times)..
          EnergyWithdrawn(Storage,Times,Zones) + sum(ReserveTypesDown,ReserveContribCharge(ReserveTypesDown,Storage,Zones,Times)) =l=
                 ( ExistingCap(Storage,Zones) + InstCap(Storage,Zones) - RetCap(Storage,Zones)) / StoragePowerEnergyRatio(Storage,Zones) - StoredEnergy(Storage,Times,Zones);

c_ReserveContributionsStorageChargePmin(Storage,Zones,Times)..
          EnergyWithdrawn(Storage,Times,Zones) - sum(ReserveTypesUp,ReserveContribCharge(ReserveTypesUp,Storage,Zones,Times)) =g= 0;

c_ReserveContributionsStorageDischargeEff(Storage,Zones,Times)..
          EnergyInjected(Storage,Times,Zones) + sum(ReserveTypesUp,ReserveContribCharge(ReserveTypesUp,Storage,Zones,Times)) =l=
                 StorageEfficiencyDischarge(Storage,Zones) * ( ExistingCap(Storage,Zones) + InstCap(Storage,Zones) - RetCap(Storage,Zones));

c_ReserveContributionsStorageDischargeJoint(Storage,Zones,Times)..
          EnergyInjected(Storage,Times,Zones) + sum(ReserveTypesUp,ReserveContribCharge(ReserveTypesUp,Storage,Zones,Times)) =l= StoredEnergy(Storage,Times,Zones);

c_ReserveContributionsStorageDischargePmin(Storage,Zones,Times)..
          EnergyInjected(Storage,Times,Zones) - sum(ReserveTypesDown,ReserveContribCharge(ReserveTypesDown,Storage,Zones,Times)) =g= 0;

c_ReserveContributionsStorageJoint(Storage,Zones,Times)..
          (EnergyInjected(Storage,Times,Zones) + sum(ReserveTypesUp,ReserveContribDischarge(ReserveTypesUp,Storage,Zones,Times))) / StorageEfficiencyDischarge(Storage,Zones)
                 + StorageEfficiencyCharge(Storage,Zones) * (EnergyWithdrawn(Storage,Times,Zones) + sum(ReserveTypesDown,ReserveContribCharge(ReserveTypesDown,Storage,Zones,Times)))
                 =l= ExistingCap(Storage,Zones) + InstCap(Storage,Zones) - RetCap(Storage,Zones);

c_ReserveContributionsHydroDischargeEff(Hydro,Zones,Times)..
          EnergyInjected(Hydro,Times,Zones) + sum(ReserveTypesUp,ReserveContrib(ReserveTypesUp,Hydro,Zones,Times))
                 =l= StorageEfficiencyDischarge(Hydro,Zones) *(ExistingCap(Hydro,Zones) + InstCap(Hydro,Zones) - RetCap(Hydro,Zones));

c_ReserveContributionsHydroPmax(Hydro,Zones,Times)..
          EnergyInjected(Hydro,Times,Zones) + sum(ReserveTypesUp,ReserveContrib(ReserveTypesUp,Hydro,Zones,Times)) =l= StoredEnergy(Hydro,Times,Zones);

c_ReserveContributionsHydroPmin(Hydro,Zones,Times)..
          EnergyInjected(Hydro,Times,Zones) - sum(ReserveTypesDown,ReserveContrib(ReserveTypesDown,Hydro,Zones,Times)) =g= 0;

c_ReserveContributionsUCAdvNuclear(ReserveTypes,UCAdvNuclear,Zones,Times)..
          ReserveContrib(ReserveTypes,UCAdvNuclear,Zones,Times) =l= ReserveMaxContribution(ReserveTypes,UCAdvNuclear,Zones) * NACCHeatEfficiency(UCAdvNuclear,Zones) * NACCPeakBaseRatio(UCAdvNuclear,Zones)
                 * UnitSize(UCAdvNuclear,Zones)* GenClusterCommitment(UCAdvNuclear,Times,Zones);

c_ReserveContributionsUCAdvNuclearHeatPmin(UCAdvNuclear,HeatStorage,Zones,Times)..
         HeatUsed(HeatStorage,Times,Zones) + HeatNGUsed(UCAdvNuclear,Times,Zones) - sum(ReserveTypesDown,ReserveContrib(ReserveTypesDown,UCAdvNuclear,Zones,Times)) / NACCHeatEfficiency(UCAdvNuclear,Zones) =g= 0;

c_ReserveContributionsUCAdvNuclearHeatPmax(UCAdvNuclear,HeatStorage,Zones,Times)..
         HeatUsed(HeatStorage,Times,Zones) + HeatNGUsed(UCAdvNuclear,Times,Zones) + sum(ReserveTypesUp,ReserveContrib(ReserveTypesUp,UCAdvNuclear,Zones,Times)) / NACCHeatEfficiency(UCAdvNuclear,Zones) =l= NACCPeakBaseRatio(UCAdvNuclear,Zones) * UnitSize(UCAdvNuclear,Zones) * GenClusterCommitment(UCAdvNuclear,Times,Zones);

c_ReserveContributionsHeatStorageChargeEff(HeatStorage,Zones,Times)..
         EnergyWithdrawn(HeatStorage,Times,Zones) + sum(ReserveTypesDown,ReserveContrib(ReserveTypesDown,HeatStorage,Zones,Times)) =l=
                 ( ExistingCap(HeatStorage,Zones) + InstCap(HeatStorage,Zones) - RetCap(HeatStorage,Zones)) / StorageEfficiencyCharge(HeatStorage,Zones);


c_ReserveContributionsHeatStorageChargeJoint(HeatStorage,Zones,Times)..
         EnergyWithdrawn(HeatStorage,Times,Zones) + sum(ReserveTypesDown,ReserveContribCharge(ReserveTypesDown,HeatStorage,Zones,Times)) =l=
                 ( ExistingCap(HeatStorage,Zones) + InstCap(HeatStorage,Zones) - RetCap(HeatStorage,Zones)) / StoragePowerEnergyRatio(HeatStorage,Zones) - StoredEnergy(HeatStorage,Times,Zones);

c_ReserveContributionsHeatStoragePmin(HeatStorage,Zones,Times)..
          EnergyWithdrawn(HeatStorage,Times,Zones) - sum(ReserveTypesUp,ReserveContrib(ReserveTypesUp,HeatStorage,Zones,Times)) =g= 0;



calc_LineLossZone(DZones,Times)..
         LineLossZone(DZones,Times) =e= LossZoneQuadCoefficient(DZones) * sum(PiecewiseSeg,LineLossZoneSlopePos(PiecewiseSeg,DZones)*LineLossZoneQuadraticPos(PiecewiseSeg,DZones,Times) + LineLossZoneSlopeNeg(PiecewiseSeg,DZones) * LineLossZoneQuadraticNeg(PiecewiseSeg,DZones,Times) )
                                         + LossZoneLinearWithdrawalCoefficient(DZones) * DistributionZoneWithdrawal(DZones,Times)
                                         + LossZoneLinearInjectionCoefficient(DZones) * DistributionZoneInjection(DZones,Times)
                                         + LossZoneIntercept(DZones);

calc_LineLossZoneSlopePos(PiecewiseSeg,DZones)..
         LineLossZoneSlopePos(PiecewiseSeg,DZones) =e= (2 + 4 * sqrt(2) * (ord(PiecewiseSeg) - 1)) / (1 + sqrt(2) * (2 * card(PiecewiseSeg) - 1)) * (DistributionZoneMaxInjection(DZones) + DistributionZoneMaxInjectionReinforcement(DZones));

calc_LineLossZoneSlopeNeg(PiecewiseSeg,DZones)..
         LineLossZoneSlopeNeg(PiecewiseSeg,DZones) =e= (2 + 4 * sqrt(2) * (ord(PiecewiseSeg) - 1)) / (1 + sqrt(2) * (2 * card(PiecewiseSeg) - 1)) * (DistributionZoneMaxWithdrawal(DZones) + DistributionZoneWithdrawalReinforcement(DZones));

calc_DistributionZoneWithdrawal(DZones,Times)..
         DistributionZoneWithdrawal(DZones,Times) =e=  sum(DZonesDummy, Map_ZoneZone(DZones,DZonesDummy) * ( Demand(Times,DZonesDummy) + sum(Storage,EnergyWithdrawn(Storage,Times,DZonesDummy)) + sum(HeatStorage,EnergyWithdrawn(HeatStorage,Times,DZonesDummy))
                                                 + sum(DR,EnergyInjected(DR,Times,DZonesDummy)) ));

calc_DistributionZoneInjection(DZones,Times)..
         DistributionZoneInjection(DZones,Times) =e= sum(NonDR,EnergyInjected(NonDR,Times,DZones));

c_LineLossZoneQuadraticPos(PiecewiseSeg,DZones,Times)..
         LineLossZoneQuadraticPos(PiecewiseSeg,DZones,Times) =l=  ((1 + sqrt(2))*(ord(PiecewiseSeg)=1) + (2 * sqrt(2))*(ord(PiecewiseSeg)>1)) / (1 + sqrt(2) * (2 * card(PiecewiseSeg) - 1)) * ( DistributionZoneInjectionReinforcement(DZones) + DistributionZoneMaxInjectionReinforcement(DZones));

c_LineLossZoneQuadraticNeg(PiecewiseSeg,DZones,Times)..
         LineLossZoneQuadraticNeg(PiecewiseSeg,DZones,Times) =l= ((1 + sqrt(2))*(ord(PiecewiseSeg)=1) + (2 * sqrt(2))*(ord(PiecewiseSeg)>1)) / (1 + sqrt(2) * (2 * card(PiecewiseSeg) - 1)) * ( DistributionZoneWithdrawalReinforcement(DZones) + DistributionZoneMaxWithdrawalReinforcement(DZones));


calc_ReserveRequirementUnit(ReserveTypes,Zones,Times)..
         ReserveRequirementUnit(ReserveTypes,Zones,Times) =e= sum(ModelOptions$(ord(ModelOptions)=ReserveConfig),
                             (ord(ModelOptions)=1) * smax(Tech,UnitSize(Tech,Zones))
                         +   (ord(ModelOptions)=2) * max(smax(Tech,UnitSize(Tech,Zones)),smax(Lines,LineCapacity(Lines)))
                         +   (ord(ModelOptions)=3) * max(smax(Tech$(ExistingCap(Tech,Zones)>0),UnitSize(Tech,Zones)),smax(Lines,LineCapacity(Lines)))
                         +   (ord(ModelOptions)=4) * max(smax(Tech$(EnergyInjected(Tech,Times,Zones)>0),UnitSize(Tech,Zones)),smax(Lines,LineCapacity(Lines)))
                         );

calc_AnnualDemand(Zones)..
         AnnualDemand(Zones) =e= sum(Times,Demand(Times,Zones));


*************************************************************************************************************************************************************************
*** IMPORT DATA ****

$include "Dummy model data"





*** DEFINE SETS BASED ON IMPORTED DATA ***

Thermal(Tech)    = yes$(TechType(Tech) = 1);
RE(Tech)         = yes$(TechType(Tech) = 2);
Storage(Tech)    = yes$(TechType(Tech) = 3);
DR(Tech)         = yes$(TechType(Tech) = 4);
AdvNuclear(Tech) = yes$(TechType(Tech) = 5);
HeatStorage(Tech)= yes$(TechType(Tech) = 6);
Hydro(Tech)      = yes$(TechType(Tech) = 7);

DispatchableRE(Tech) = yes$(TechDispatchable(Tech)=1 and TechType(Tech) = 2);
NonDispatchableRE(Tech) = yes$(TechDispatchable(Tech)=0 and TechType(Tech) = 2);
UC(Tech) = yes$(TechUC(Tech)=1 and TechType(Tech)=1);
UCAdvNuclear(Tech) = yes$(TechUC(Tech)=1 and TechType(Tech)=5);







*** CALC DYNAMIC SETS ****
LinesNotEligibleReinforcement(Lines) = not LinesEligibleReinforcement(Lines);
NonUC(Tech) = Thermal(Tech) - UC(Tech);
NonUCAdvNuclear(Tech) = AdvNuclear(Tech) - UCAdvNuclear(Tech);
NotStorage(Tech) = Tech(Tech) - Storage(Tech) - Hydro(Tech) - HeatStorage(Tech) - DR(Tech);
NotAdvNuclear(Tech) = not AdvNuclear(Tech);
NotHeatStorage(Tech) = not HeatStorage(Tech);
NonUCReserves(Tech) = Tech(Tech) - UC(Tech) - DR(Tech) - NonUC(Tech) - NonDispatchableRE(Tech);             /* not UC or ND or DR */
NonDR(Tech) = not DR(Tech);
GenTech(Tech) = Tech(Tech) - Storage(Tech) - HeatStorage(Tech) - DR(Tech);
NonUCTotal(Tech) = NonUC(Tech) + NonUCAdvNuclear(Tech) + DR(Tech) + NonDispatchableRE(Tech) + Storage(Tech) + HeatStorage(Tech);



*** FIXED VARIABLE CONSTRAINTS ****
* Eq 14
BusAngle.fx(Zones,Times)$(ord(Zones)=1)=0;


* Eq 136
PowerInjectionMargin.fx(Zones,Times)=0;

* Eq 143
LineExpansion.fx(LinesNotEligibleReinforcement)=0;

* Eq 147
EnergyWithdrawn.fx(GenTech,Times,Zones)=0;

* Eq 148
StoredEnergy.fx(NotStorage,Times,Zones)=0;

* Eq 150
GenClusterCommitment.fx(NonUCTotal,Times,Zones)=0;
GenClusterStartup.fx(NonUCTotal,Times,Zones)=0;
GenClusterShutdown.fx(NonUCTotal,Times,Zones)=0;


* Eq 152
HeatSold.fx(NotHeatStorage,Times,Zones)=0;
HeatUsed.fx(NotHeatStorage,Times,Zones)=0;

* Eq 154
HeatNGUsed.fx(NotAdvNuclear,Times,Zones) = 0;



Model    GenX_LP_ObjFun "Dummy model with LP objective function" / ObjFunctionLP /
         GenX_MIP_ObjFun "Dummy model with MIP objective function" / ObjFunctionMIP /
         GenX_MIP_UCFun "Dummy model with unit commitment constraints"
                 /       c_GenClusterCommitment,
                         c_GenClusterStartup
                         c_GenClusterShutdown
                         c_InterTemp
                         c_Pmin
                         c_Pmax
                         c_RampDown
                         c_RampUp
                         c_MinUpTime
                         c_MinDownTime
                         c_PmaxAdvNuclearUC
                         c_AdvNuclearHeatUC
                         c_ReserveContributionsUC
                         c_ReserveContributionsUCPmin
                         c_ReserveContributionsUCPmax
                         c_ReserveContributionsUCAdvNuclear
                         c_ReserveContributionsUCAdvNuclearHeatPmin
                         c_ReserveContributionsUCAdvNuclearHeatPmax
                /


         GenX_LP "LP model" /All - ObjFunctionMIP - GenX_MIP_UCFun /
         GenX_MIP "MIP model" /All - ObjFunctionLP /

;
Solve GenX_LP using LP minimizing Z ;
