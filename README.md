# Space Diet Simulation — MATLAB Script
### `diet_simulation.m`

---

## Overview

This script simulates how much food mass is needed to sustain a crew over a mission of configurable length, across 5 candidate space diets. It answers the core project question:

> **How much mass is needed to sustain people for a certain amount of time, depending on diet?**

Two simulations are run:
- **Sim 1** — Per-diet breakdown of daily food mass and calorie density, with male/female separation
- **Sim 2** — Cross-diet comparison, total mass ranking, and a multi-metric radar chart

---

## Quick Start

1. Open `diet_simulation.m` in MATLAB
2. Edit the three variables at the top of **Section 1** — `num_women`, `num_men`, and `sim_days`
3. Hit **Run**. All figures and console output generate automatically.

The three config variables are:

    num_women   = 3;    % number of women in crew
    num_men     = 3;    % number of men in crew
    sim_days    = 14;   % mission duration in days

---

## The 5 Diets

| # | Sheet Name | Objective |
|---|------------|-----------|
| 1 | Diet 1 (Min Sunlight) | Minimize sunlight dependency |
| 2 | Diet 2 (Max O2) | Maximize O2 consumption |
| 3 | Diet 3 (Max CO2) | Maximize CO2 consumption |
| 4 | Diet 4 (Min Water) | Minimize water usage |
| 5 | Diet 5 (Min Space) | Minimize storage space |

All diets are based on 14-day meal plans from `Diet_Ideas.xlsx`. Days 8–14 repeat days 1–7 cyclically, as specified in the Excel sheets.

---

## How Male vs. Female Is Handled

The Excel sheets specify: *"Multiply women's diet by 1.5 for men."*

This multiplier is applied uniformly across all diets via the `MALE_MULTIPLIER` constant in Section 1. Crew-level totals combine both groups:

```
crew daily mass = (num_women × women's mass) + (num_men × men's mass)
```

To use sex-specific multipliers per diet in the future, replace `MALE_MULTIPLIER` with a per-diet array.

---

## How Calories Are Calculated

Calories are computed ingredient-by-ingredient using nutritional data from `Overall_Data_Collection.xlsx`. Each ingredient's mass (in grams) is multiplied by its kcal/100g value from the food database defined in Section 2 of the script.

Confirmed calorie targets from the Dietary Requirements sheet:
- **Women: 2000 kcal/day**
- **Men: 2600 kcal/day**

The male mass multiplier is set to **1.3** (2600/2000) to match these targets, replacing the previous rough 1.5× estimate.

Section 4 acts as a safety net — if any day still has zero calories after the ingredient-level calculation (e.g. a food with no database entry), it fills in a mass-scaled estimate using the 2000 kcal/day women's target. This is flagged on the calorie density plot.

---

## Outputs

### Figures (one per diet + 4 comparison figures)

| Figure | Description |
|--------|-------------|
| Per-diet bar charts (×5) | Daily food mass per person, women vs. men grouped bars |
| Cumulative mass overlap | All 5 diets on one line chart, crew total mass over time |
| Calorie density overlap | kcal per kg of food mass per day, all diets |
| Total mass bar chart | Diets ranked by total mission mass (sorted low to high) |
| Radar chart | Normalized comparison across 4 metrics (see below) |
| Daily mass area plot | All diets overlaid as filled area chart |

### Radar Chart Metrics

The radar chart scores each diet on 4 normalized axes (1.0 = best):

| Metric | What it measures |
|--------|-----------------|
| Low Mass | Total food mass — lower is better |
| Cal Density | Calories per kg of food — higher is better |
| Consistency | Day-to-day variability in mass — lower variance is better |
| Cal Adequacy | How close average intake is to 2000 kcal/person/day target |

### Console Output

A ranked table is printed to the MATLAB console showing each diet's total mass, average daily mass, average daily calories, and calorie density — sorted from lightest to heaviest.

---

## Code Structure

| Section | What it does |
|---------|-------------|
| 1 | Crew configuration — **edit this to change scenarios** |
| 2 | Food nutrition database — kcal/100g and macros from Overall_Data_Collection.xlsx |
| 3 | Diet meal plan data — ingredient masses and per-ingredient calorie calculations |
| 4 | Safety net for any remaining zero-calorie days (mass-scaled fallback) |
| 5 | Expand 7-day plans to full `sim_days` length |
| 6 | Compute crew-level totals and summary stats |
| 7 | Color and style definitions |
| Sim 1A | Per-diet grouped bar charts (M/F) |
| Sim 1B | Cumulative mass overlap line chart |
| Sim 1C | Calorie density overlap line chart |
| Sim 2A | Total mass ranked bar chart |
| Sim 2B | Ranked summary table (console) |
| Sim 2C | Radar chart |
| Sim 2D | Daily mass area overlap chart |

---

## Adding a New Diet

1. Copy the `d1` block in Section 2
2. Rename it (e.g. `d6`) and fill in `name`, `objective`, `mass_f`, and `kcal_f`
3. Add it to the diet array:
   ```matlab
   diets = [d1, d2, d3, d4, d5, d6];
   ```
4. Add a color row to `diet_colors` in Section 6
5. Everything else (expansion, estimation, plots, ranking) updates automatically

---

## Known Limitations

- **Diet 3 (Max CO2)** has the least quantified ingredient data — microgreen salad quantities were listed by food type only, not by mass. Those meals use conservative estimates based on the primary CO2-consuming ingredients (spirulina, chlorella, mushrooms).
- Water is excluded from food mass calculations (not payload mass in a closed-loop system).
- Crickets have no data sheet in `Overall_Data_Collection.xlsx` yet. The script uses standard dried cricket nutritional values (430 kcal/100g, 65g protein) as a placeholder — update `foods.crickets` in Section 2 when your team adds the sheet.
- Turkey's Tail and Cordyceps mushrooms are noted as medicinal in the data sheet and are not included in any calorie calculations.
- The 1.3× male mass multiplier is derived from the 2600/2000 kcal ratio and applied uniformly. Real metabolic needs vary by activity level, body weight, and mission phase.

---

## Data Sources

**`Diet_Ideas.xlsx`** — 5 sheets, one per diet, each containing a 14-day meal plan with ingredient lists and masses. Created as part of a space nutrition project exploring sustainable closed-loop diet options.

**`Overall_Data_Collection.xlsx`** — Nutritional database with one sheet per food ingredient. Contains per-100g values for calories, protein, fat, carbs, vitamins, and minerals, plus space-relevant environmental data (CO2 consumed/produced, O2 produced/consumed, water requirements, sunlight requirements, space growth notes). Sheets include:

- Dietary Requirements (confirmed calorie targets: 2000 kcal/day women, 2600 kcal/day men)
- Spirulina, Chlorella, Chia Seeds, Mealworms, Crickets, Astaxanthin
- Oyster Mushrooms, Lion's Mane Mushroom
- Turkey's Tail Mushroom, Cordyceps Mushroom (medicinal only, not in diet calculations)

Calorie values in the simulation are computed ingredient-by-ingredient using this database rather than from annotated meal totals.