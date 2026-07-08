# 📚 Technical Documentation — WEEE Sorting Center Digital Twin

## Table of Contents
1. [Model Architecture](#architecture)
2. [Complete List of 57 Attributes](#attributes)
3. [Simulation Parameters](#parameters)
4. [KPIs and Calculation Formulas](#kpis)

---

## 1. Model Architecture {#architecture}

The model consists of 8 interconnected Simulink blocks, each representing
a physical stage of the WEEE treatment process.

```
Source_WEEE → Bloc_Dismantling → Bloc_Crushing → Bloc_Sorting
            → Bloc_MaterialSeparation → Bloc_Hydrometallurgy
            → Equipment_Failures (Stateflow) → KPI Dashboard
```

---

## 2. Complete List of 57 Attributes {#attributes}

Each WEEE entity in the SimEvents model carries **57 attributes** that
characterize it throughout the process. These attributes are declared in
the **Entity type** tab of the `Generateur_DEEE` block and updated at
each process stage.

---

### 🔵 Group 1 — Identification and Classification (4 attributes)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 1 | `categorie` | int (1-4) | 0 | REP category: 1=LHA, 2=SHA, 3=Screens, 4=ICT | Generateur_DEEE |
| 2 | `masse` | double [t] | 0 | Current entity mass [tonnes] | Generateur_DEEE |
| 3 | `valorisable` | int (1-2) | 1 | Valorization status: 1=valorizable, 2=rejected | Server_LHA/SHA/SCR/ICT |
| 4 | `tps_service` | double [h] | 0 | Service duration in current Server [h] | All Servers |

---

### 🟢 Group 2 — Material Composition (5 attributes)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 5 | `masse_fe` | double [t] | 0 | Ferrous metal mass in entity [t] | Generateur_DEEE |
| 6 | `masse_nfe` | double [t] | 0 | Non-ferrous metal mass (Cu, Al) [t] | Generateur_DEEE |
| 7 | `masse_plastique` | double [t] | 0 | Plastics mass [t] | Generateur_DEEE |
| 8 | `masse_verre` | double [t] | 0 | Glass mass [t] | Generateur_DEEE |
| 9 | `masse_autre` | double [t] | 0 | Other materials mass (PCBs, cables) [t] | Generateur_DEEE |

> **Calibration source**: ADEME National WEEE Registry 2020 — average mass
> composition per REP category

---

### 🟡 Group 3 — Dominant Fraction and Separation Routing (2 attributes)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 10 | `fraction_dominante` | int (1-5) | 1 | Dominant mass fraction: 1=Fe, 2=NFe, 3=Plas, 4=Glass, 5=Other | Generateur_DEEE |
| 11 | `masse_recuperee` | double [t] | 0 | Mass recovered after physical separation [t] | Server_Magnetic/Eddy/Optical/Densimetric |

---

### 🔴 Group 4 — Precious Metals (6 attributes)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 12 | `masse_Cu` | double [kg] | 0 | Copper mass in entity [kg] | Generateur_DEEE |
| 13 | `masse_Au` | double [g] | 0 | Gold mass in entity [g] | Generateur_DEEE |
| 14 | `masse_Ag` | double [g] | 0 | Silver mass in entity [g] | Generateur_DEEE |
| 15 | `masse_Cu_init` | double [kg] | 0 | Initial Cu mass before hydromet [kg] | Generateur_DEEE |
| 16 | `masse_Au_init` | double [g] | 0 | Initial Au mass before hydromet [g] | Generateur_DEEE |
| 17 | `masse_Ag_init` | double [g] | 0 | Initial Ag mass before hydromet [g] | Generateur_DEEE |

> **Calibration source**: ADEME Critical Metals Prospective 2022
> Grades: Cu=12-28 kg/t, Au=0.8-12 g/t, Ag=40-350 g/t per category

---

### 🟠 Group 5 — Economic Value (1 attribute)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 18 | `valeur_euro` | double [€] | 0 | Estimated market value of metals [€] — LME 2024 prices | Generateur_DEEE / Server_Electrolysis |

> **Formula**: `valeur_euro = masse_Cu × 8.5 + masse_Au × 60 + masse_Ag × 0.8`
> **Source**: LME (London Metal Exchange) average prices 2024

---

### 🔵 Group 6 — Crushing and Granulometry (3 attributes)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 19 | `granulometrie` | double [mm] | 0 | Current fragment granulometry [mm] | Server_Dismantling / Server_Crusher1 / Server_Crusher2 |
| 20 | `grain_route` | int (1-2) | 1 | Screen routing: 1=passing, 2=oversize recirculation | Server_Screen1 / Server_Screen2 |
| 21 | `nb_passages` | int | 0 | Number of crusher passes (anti-infinite loop) | Server_Crusher1 / Server_Crusher2 |

---

### 🟣 Group 7 — Dismantling and Depollution (4 attributes)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 22 | `dangereux` | int (0-1) | 0 | Hazardous substances present: 0=no, 1=yes | Server_Depollution |
| 23 | `masse_bat` | double [kg] | 0 | Battery mass extracted during depollution [kg] | Server_Depollution |
| 24 | `masse_Hg` | double [g] | 0 | Mercury mass extracted (fluorescent screens) [g] | Server_Depollution |
| 25 | `route_depollution` | int (1-2) | 2 | Switch_Danger routing: 1=hazardous, 2=safe | Server_Depollution |

> **Hazard probabilities by category**: LHA=15%, SHA=8%, SCR=20%, ICT=12%
> **Source**: WEEE Regulation — Directive 2012/19/EU

---

### 🟤 Group 8 — Material Separation KPIs (12 attributes)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 26 | `purete_Fe` | double [0-1] | 0 | Ferrous fraction purity from magnetic separator | Server_Magnetic |
| 27 | `rendement_Fe` | double [0-1] | 0 | Fe recovery yield = mass_recov / mass_input | Server_Magnetic |
| 28 | `pertes_Fe` | double [t] | 0 | Fe losses in residues [t] | Server_Magnetic |
| 29 | `purete_NFe` | double [0-1] | 0 | NFe fraction purity from eddy current | Server_EddyCurrent |
| 30 | `rendement_NFe` | double [0-1] | 0 | NFe recovery yield | Server_EddyCurrent |
| 31 | `pertes_NFe` | double [t] | 0 | NFe losses in residues [t] | Server_EddyCurrent |
| 32 | `purete_Plas` | double [0-1] | 0 | Plastics fraction purity from optical sorting | Server_Optical |
| 33 | `rendement_Plas` | double [0-1] | 0 | Plastics recovery yield | Server_Optical |
| 34 | `pertes_Plas` | double [t] | 0 | Plastics losses in residues [t] | Server_Optical |
| 35 | `purete_Verre` | double [0-1] | 0 | Glass fraction purity from densimetric | Server_Densimetric |
| 36 | `rendement_Verre` | double [0-1] | 0 | Glass recovery yield | Server_Densimetric |
| 37 | `pertes_Verre` | double [t] | 0 | Glass losses in residues [t] | Server_Densimetric |

---

### 🔵 Group 9 — Hydrometallurgy Yields (3 attributes)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 38 | `rendement_Cu` | double [%] | 0 | Global Cu recovery yield = (masse_Cu_final / masse_Cu_init) × 100 | Server_Electrolysis |
| 39 | `rendement_Au` | double [%] | 0 | Global Au recovery yield | Server_Electrolysis |
| 40 | `rendement_Ag` | double [%] | 0 | Global Ag recovery yield | Server_Electrolysis |

---

### 🟡 Group 10 — Energy Balance (4 attributes)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 41 | `energie_lixiv` | double [kWh] | 0 | Energy consumed during leaching [kWh] | Server_Leaching |
| 42 | `energie_precip` | double [kWh] | 0 | Energy consumed during precipitation [kWh] | Server_Precipitation |
| 43 | `energie_electro` | double [kWh] | 0 | Energy consumed during electrolysis [kWh] | Server_Electrolysis |
| 44 | `energie_totale` | double [kWh] | 0 | Total hydromet energy = leach + precip + electro [kWh] | Server_Electrolysis |

---

### 🟢 Group 11 — Global Process Energy Balance (4 attributes)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 45 | `energie_broyage` | double [kWh] | 0 | Crushers 1+2 + conveyors energy [kWh] | Server_Crusher1 / Server_Crusher2 |
| 46 | `energie_tri` | double [kWh] | 0 | Sorting stations + sorting conveyor energy [kWh] | Server_LHA/SHA/SCR/ICT |
| 47 | `energie_separation` | double [kWh] | 0 | Physical separators energy [kWh] | Server_Magnetic/Eddy/Optical |
| 48 | `energie_totale_process` | double [kWh] | 0 | Total process energy [kWh] | Server_Electrolysis |

---

### 🔴 Group 12 — Thermal Modeling (2 attributes)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 49 | `temp_cuve` | double [°C] | 20 | Temperature reached in leaching tank [°C] | Server_Leaching |
| 50 | `eta_lixiv_reel` | double [0-1] | 0 | Leaching yield corrected by temperature (simplified Arrhenius) | Server_Leaching |

> **Thermal model**: T(t) = T_target - (T_target - T_ambient) × exp(-t/τ)
> with T_target=70°C, T_ambient=20°C, τ=2h

---

### 🟠 Group 13 — Acid Effluent Management (3 attributes)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 51 | `volume_effluent` | double [L] | 0 | Acid effluent volume produced [liters] | Server_Leaching |
| 52 | `conc_acide` | double [mol/L] | 0 | Residual acid concentration at output [mol/L] | Server_Leaching / Server_Precipitation |
| 53 | `pH_effluent` | double | 0 | Effluent pH at each stage | Server_Leaching / Server_Precipitation / Server_Electrolysis |

---

### 🟣 Group 14 — Heat Recovery (2 attributes)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 54 | `chaleur_recuperee` | double [kWh] | 0 | Total heat recovered (3 sources) [kWh] | Server_Leaching / Server_Precipitation / Server_Electrolysis |
| 55 | `energie_lixiv_nette` | double [kWh] | 0 | Net leaching energy after recovery [kWh] | Server_Leaching |

---

### 🔵 Group 15 — Recovery Rate (1 attribute)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 56 | `taux_recuperation` | double [%] | 0 | Heat recovery rate = Q_recov / Q_gross × 100 | Server_Leaching |

---

### 🟤 Group 16 — Gross Leaching Energy (1 attribute)

| # | Attribute | Type | Initial Value | Role | Assigning Block |
|---|-----------|------|--------------|------|----------------|
| 57 | `energie_lixiv_brute` | double [kWh] | 0 | Leaching energy before heat recovery [kWh] | Server_Leaching |

---

## 3. Summary by Group

| Group | Attributes | Domain |
|-------|-----------|--------|
| Identification | 4 | Category, mass, routing |
| Material composition | 5 | Fe, NFe, Plastic, Glass, Other |
| Dominant fraction | 2 | Separation routing |
| Precious metals | 6 | Cu, Au, Ag — initial and current |
| Economic value | 1 | EUR — LME 2024 prices |
| Crushing | 3 | Granulometry, passes, routing |
| Dismantling | 4 | Hazard, batteries, mercury, routing |
| Separation KPIs | 12 | Purity, yield, losses × 4 processes |
| Hydromet yields | 3 | Cu, Au, Ag — global yield |
| Hydromet energy | 4 | Leaching, precipitation, electrolysis, total |
| Process energy | 4 | Crushing, sorting, separation, total |
| Thermal | 2 | Tank temperature, corrected yield |
| Effluents | 3 | Volume, concentration, pH |
| Heat recovery | 2 | Recovered heat, net energy |
| Recovery rate | 1 | Global % recovery |
| Gross energy | 1 | Reference before recovery |
| **TOTAL** | **57** | |

---

## 4. KPIs and Calculation Formulas {#kpis}

| KPI | Formula | Target |
|-----|---------|--------|
| Capture rate | N_valorized / (N_valorized + N_rejected) × 100 | 91% |
| OEE | Availability × Performance × Quality | 75% |
| Availability | t_service / (t_service + t_failure + t_maintenance) | 96.8% |
| Cu yield | masse_Cu_final / masse_Cu_init × 100 | 84.5% |
| Heat recovery | Q_recovered / Q_gross × 100 | — |
| Net energy | Gross_energy - Recovered_heat | 850 kWh/t |

---

*Documentation for the WEEE Digital Twin project*
*Author: Fabrice TSAMO NGUESOP — github.com/fabrice-py/DEEE-Digital-Twin*
