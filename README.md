# AgriculturalSpaceSystem

What's in it:

Section 1 - crew config at the very top. Just edit num_women, num_men, and sim_days to change your scenario. Nothing else needs touching for basic runs.
Section 2 - all 5 diets hardcoded with ingredient masses summed per day. I extracted solid food mass from each day's ingredient list (water excluded since it's not payload mass). Days 8–14 are auto-expanded from the 7-day cycle.
Section 3 - fills in missing calorie data (most diets only annotated Day 1) using a 1800 kcal/day baseline scaled by mass. This is clearly flagged in the plots.
Section 4 (Sim 1) - per-diet figures showing women vs. men daily mass as grouped bar charts, plus an overlapping cumulative mass line graph and a calorie density comparison.
Section 5 (Sim 2) - a sorted total-mass bar chart, a printed ranking table in the console, a radar/spider chart comparing 4 metrics (low mass, calorie density, day-to-day consistency, calorie adequacy), and an overlapping area plot for daily mass across all diets.