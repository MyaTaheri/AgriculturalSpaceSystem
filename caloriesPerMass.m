%% ==========================================================================
%  SPACE DIET SIMULATION
%  Mass needed to sustain a crew over time across 5 diets
%
%  Simulations:
%    SIM 1 - Calories per mass over time (per diet, M/F breakdown)
%    SIM 2 - Cross-diet comparison + ranking
%
%  Data Sources:
%    Diet_Ideas.xlsx            - 5 diets, 14-day meal plans, ingredient masses
%    Overall_Data_Collection.xlsx - per-food nutritional data (kcal/100g,
%                                   macros, CO2, O2, water, sunlight)
%
%  Calorie targets: 2000 kcal/day women, 2600 kcal/day men
%    (from Dietary Requirements sheet in Overall_Data_Collection.xlsx)
%  Men's food mass = Women's x 1.3 (scaled to match 2600/2000 = 1.3 ratio)
%  Days 8-14 repeat Days 1-7 cyclically
% ==========================================================================

clear; clc; close all;

%% ==========================================================================
%  SECTION 1: CREW CONFIGURATION (edit these!)
% ==========================================================================

num_women   = 3;       % number of women in crew
num_men     = 3;       % number of men in crew
sim_days    = 14;      % simulation duration in days (multiples of 14 recommended)

%  Male calorie multiplier: 2600/2000 = 1.3
%  (from Dietary Requirements sheet in Overall_Data_Collection.xlsx)
MALE_MULTIPLIER = 1.3;

%% ==========================================================================
%  SECTION 2: FOOD NUTRITION DATABASE
%  Source: Overall_Data_Collection.xlsx
%  kcal_per_100g = calories per 100g dry/edible mass
%  Serving sizes normalized to per-100g for easy scaling.
%
%  Calorie targets (from Dietary Requirements sheet):
%    Women: 2000 kcal/day    Men: 2600 kcal/day
%
%  Foods with no kcal data use 0 and fall back to mass-scaled estimate
%  in Section 3. Turkey's tail and Cordyceps are medicinal, not dietary.
% ==========================================================================

% food.name         = display name
% food.kcal_100g    = kcal per 100g
% food.protein_100g = g protein per 100g (for future macro tracking)
% food.fat_100g     = g fat per 100g
% food.carb_100g    = g carbs per 100g

foods.spirulina        = struct('name','Spirulina',       'kcal_100g',290, 'protein_100g',60,  'fat_100g',8,    'carb_100g',24);
foods.chlorella        = struct('name','Chlorella',        'kcal_100g',410, 'protein_100g',55,  'fat_100g',12,   'carb_100g',23);
foods.chia             = struct('name','Chia Seeds',       'kcal_100g',490, 'protein_100g',17,  'fat_100g',31,   'carb_100g',42); % 140 kcal/oz = ~490/100g
foods.mealworms        = struct('name','Mealworms (dried)','kcal_100g',510, 'protein_100g',53,  'fat_100g',28,   'carb_100g',7);
foods.oyster_mushroom  = struct('name','Oyster Mushrooms', 'kcal_100g',33,  'protein_100g',2.9, 'fat_100g',0.19, 'carb_100g',6.94);
foods.lions_mane       = struct('name','Lions Mane',       'kcal_100g',35,  'protein_100g',2.5, 'fat_100g',0.26, 'carb_100g',7.59);
foods.crickets         = struct('name','Crickets (dried)', 'kcal_100g',430, 'protein_100g',65,  'fat_100g',13,   'carb_100g',5);  % standard dried cricket nutrition
foods.astaxanthin      = struct('name','Astaxanthin Supp', 'kcal_100g',15,  'protein_100g',0,   'fat_100g',0,    'carb_100g',0);  % supplement, negligible

% Helper: compute kcal given ingredient mass (g) and food struct
% Usage: kcal_ingredient(foods.spirulina, 20)  -> kcal from 20g spirulina
kcal_ingredient = @(food, mass_g) (mass_g / 100) * food.kcal_100g;

%% ==========================================================================
%  SECTION 3: DIET MEAL PLAN DATA
%  Each diet has 7 unique days (days 8-14 repeat days 1-7).
%  Mass per day = total food mass in grams (solid ingredients only, excl. water).
%  Calories per day = calculated from ingredient masses using food database above.
%
%  Format: diets(d).name        - diet label
%          diets(d).objective   - what was optimized
%          diets(d).mass_f(day) - total solid food mass (g) for women, per day
%          diets(d).kcal_f(day) - calories (kcal) for women, per day
%
%  Ingredient masses from Diet_Ideas.xlsx.
%  Calories computed per ingredient using Overall_Data_Collection.xlsx data.
%  Where a food has no entry in the database, 0 is used and estimated in Section 4.
% ==========================================================================

% ---- DIET 1: Minimize Sunlight ----
d1.name      = 'Diet 1: Min Sunlight';
d1.objective = 'Minimize Sunlight';
% Women - 7 unique days (solid mass in grams, water excluded)
d1.mass_f = [
    30+10+5 + 150+100+20+10+40 + 80+100+100+10 + 20+5;   % Day 1
    15+10+20 + 40+150+20 + 80+200 + 0;                   % Day 2
    40+5 + 200+20+10 + 70+150+10 + 0;                    % Day 3
    20+20 + 50+100+10 + 30+20+100 + 0;                   % Day 4
    20+20 + 25+15+100 + 80+200 + 0;                      % Day 5
    25+15 + 60+150 + 70+200 + 0;                         % Day 6
    35+10 + 200+30 + 90+150 + 0;                         % Day 7
];
% Calories calculated from ingredient masses using food database
% Day 1: Breakfast(chia 30g, spirulina 10g, chlorella 5g)
%        Lunch(oyster 150g, lions_mane 100g, spirulina 20g, chlorella 10g, crickets 40g)
%        Dinner(mealworms 80g, oyster 100g, lions_mane 100g, spirulina 10g)
%        Snack(chia 20g, spirulina 5g)
d1.kcal_f = [
    kcal_ingredient(foods.chia,30)+kcal_ingredient(foods.spirulina,10)+kcal_ingredient(foods.chlorella,5) + ...
    kcal_ingredient(foods.oyster_mushroom,150)+kcal_ingredient(foods.lions_mane,100)+kcal_ingredient(foods.spirulina,20)+kcal_ingredient(foods.chlorella,10)+kcal_ingredient(foods.crickets,40) + ...
    kcal_ingredient(foods.mealworms,80)+kcal_ingredient(foods.oyster_mushroom,100)+kcal_ingredient(foods.lions_mane,100)+kcal_ingredient(foods.spirulina,10) + ...
    kcal_ingredient(foods.chia,20)+kcal_ingredient(foods.spirulina,5);   % Day 1

    kcal_ingredient(foods.chia,15)+kcal_ingredient(foods.spirulina,10)+kcal_ingredient(foods.chlorella,20) + ...
    kcal_ingredient(foods.crickets,40)+kcal_ingredient(foods.oyster_mushroom,150)+kcal_ingredient(foods.spirulina,20) + ...
    kcal_ingredient(foods.mealworms,80)+kcal_ingredient(foods.lions_mane,200);   % Day 2

    kcal_ingredient(foods.chia,40)+kcal_ingredient(foods.spirulina,5) + ...
    kcal_ingredient(foods.oyster_mushroom,200)+kcal_ingredient(foods.spirulina,20)+kcal_ingredient(foods.chlorella,10) + ...
    kcal_ingredient(foods.mealworms,70)+kcal_ingredient(foods.lions_mane,150)+kcal_ingredient(foods.spirulina,10);   % Day 3

    kcal_ingredient(foods.chia,20)+kcal_ingredient(foods.chlorella,20) + ...
    kcal_ingredient(foods.crickets,50)+kcal_ingredient(foods.oyster_mushroom,100)+kcal_ingredient(foods.spirulina,10) + ...
    kcal_ingredient(foods.mealworms,30)+kcal_ingredient(foods.chlorella,20)+kcal_ingredient(foods.lions_mane,100);   % Day 4

    kcal_ingredient(foods.chia,20)+kcal_ingredient(foods.spirulina,20) + ...
    kcal_ingredient(foods.chia,25)+kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.oyster_mushroom,100) + ...
    kcal_ingredient(foods.mealworms,80)+kcal_ingredient(foods.lions_mane,200);   % Day 5

    kcal_ingredient(foods.chia,25)+kcal_ingredient(foods.spirulina,15) + ...
    kcal_ingredient(foods.crickets,60)+kcal_ingredient(foods.oyster_mushroom,150) + ...
    kcal_ingredient(foods.mealworms,70)+kcal_ingredient(foods.lions_mane,200);   % Day 6

    kcal_ingredient(foods.chia,35)+kcal_ingredient(foods.spirulina,10) + ...
    kcal_ingredient(foods.oyster_mushroom,200)+kcal_ingredient(foods.chlorella,30) + ...
    kcal_ingredient(foods.mealworms,90)+kcal_ingredient(foods.lions_mane,150);   % Day 7
];

% ---- DIET 2: Maximize O2 Consumption ----
d2.name      = 'Diet 2: Max O2';
d2.objective = 'Maximize O2 Consumption';
d2.mass_f = [
    25+10+5 + 150+100+40 + 70+15+50 + 0;                     % Day 1
    15+20 + 150+150+40 + 60+15+30 + 0;                       % Day 2
    15+10+50+20 + 15+100+150+100 + 60+100+10+100 + 0;        % Day 3
    20+10+100+50 + 15+120+150+5 + 80+10+100+5 + 0;           % Day 4
    15+20+150 + 15+10+60+60+80 + 70+100+5+10 + 0;            % Day 5
    15+100+15 + 15+75+75+5 + 80+100+10 + 0;                  % Day 6
    15+50+15 + 15+100+100+5 + 80+10+80+100 + 0;              % Day 7
];
% Diet 2 is heavy in spirulina, chlorella, mushrooms, crickets, mealworms
d2.kcal_f = [
    kcal_ingredient(foods.chia,25)+kcal_ingredient(foods.spirulina,10)+kcal_ingredient(foods.chlorella,5) + ...
    kcal_ingredient(foods.oyster_mushroom,150)+kcal_ingredient(foods.lions_mane,100)+kcal_ingredient(foods.crickets,40) + ...
    kcal_ingredient(foods.mealworms,70)+kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.chlorella,50);   % Day 1

    kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.chlorella,20) + ...
    kcal_ingredient(foods.oyster_mushroom,150)+kcal_ingredient(foods.lions_mane,150)+kcal_ingredient(foods.crickets,40) + ...
    kcal_ingredient(foods.mealworms,60)+kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.chlorella,30);   % Day 2

    kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.chlorella,10)+kcal_ingredient(foods.chia,50)+kcal_ingredient(foods.crickets,20) + ...
    kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.oyster_mushroom,100)+kcal_ingredient(foods.lions_mane,150)+kcal_ingredient(foods.chlorella,100) + ...
    kcal_ingredient(foods.mealworms,60)+kcal_ingredient(foods.spirulina,100)+kcal_ingredient(foods.chlorella,10)+kcal_ingredient(foods.chia,100);   % Day 3

    kcal_ingredient(foods.spirulina,20)+kcal_ingredient(foods.chlorella,10)+kcal_ingredient(foods.oyster_mushroom,100)+kcal_ingredient(foods.chia,50) + ...
    kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.lions_mane,120)+kcal_ingredient(foods.oyster_mushroom,150)+kcal_ingredient(foods.chlorella,5) + ...
    kcal_ingredient(foods.mealworms,80)+kcal_ingredient(foods.spirulina,10)+kcal_ingredient(foods.lions_mane,100)+kcal_ingredient(foods.chlorella,5);   % Day 4

    kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.chlorella,20)+kcal_ingredient(foods.oyster_mushroom,150) + ...
    kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.chlorella,10)+kcal_ingredient(foods.crickets,60)+kcal_ingredient(foods.lions_mane,60)+kcal_ingredient(foods.mealworms,80) + ...
    kcal_ingredient(foods.mealworms,70)+kcal_ingredient(foods.oyster_mushroom,100)+kcal_ingredient(foods.spirulina,5)+kcal_ingredient(foods.chlorella,10);   % Day 5

    kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.oyster_mushroom,100)+kcal_ingredient(foods.chlorella,15) + ...
    kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.lions_mane,75)+kcal_ingredient(foods.oyster_mushroom,75)+kcal_ingredient(foods.chlorella,5) + ...
    kcal_ingredient(foods.mealworms,80)+kcal_ingredient(foods.spirulina,100)+kcal_ingredient(foods.chlorella,10);   % Day 6

    kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.chia,50)+kcal_ingredient(foods.chlorella,15) + ...
    kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.oyster_mushroom,100)+kcal_ingredient(foods.lions_mane,100)+kcal_ingredient(foods.chlorella,5) + ...
    kcal_ingredient(foods.mealworms,80)+kcal_ingredient(foods.spirulina,10)+kcal_ingredient(foods.lions_mane,80)+kcal_ingredient(foods.oyster_mushroom,100);   % Day 7
];

% ---- DIET 3: Maximize CO2 Consumption ----
d3.name      = 'Diet 3: Max CO2';
d3.objective = 'Maximize CO2 Consumption';
% Note: this diet had the least quantified ingredient masses in the Excel sheet.
% Spirulina and chlorella are the primary CO2 consumers; mushrooms fill bulk.
d3.mass_f = [
    100+30 + 100+100 + 0;   % Day 1: spirulina 100g, chlorella 30g, mushrooms 100+100g
    100+30 + 100+100 + 0;   % Day 2
    100+30 + 100+100 + 0;   % Day 3
    100+30 + 100+100 + 0;   % Day 4
    100+30 + 100+100 + 0;   % Day 5
    100+30 + 100+100 + 0;   % Day 6
    100+30 + 100+100 + 0;   % Day 7
];
d3_day = kcal_ingredient(foods.spirulina,100)+kcal_ingredient(foods.chlorella,30) + ...
         kcal_ingredient(foods.oyster_mushroom,100)+kcal_ingredient(foods.lions_mane,100);
d3.kcal_f = repmat(d3_day, 1, 7);

% ---- DIET 4: Minimize Water ----
d4.name      = 'Diet 4: Min Water';
d4.objective = 'Minimize Water';
d4.mass_f = [
    30+10+5 + 50+80+20+10 + 80+80+10 + 20+5;    % Day 1
    20+10+20 + 60+80 + 90+10 + 0;                % Day 2
    40+5 + 25+10+70 + 70+80+10 + 30;             % Day 3
    20+20 + 60+80+10 + 30+20+80 + 0;             % Day 4
    20+20 + 25+15+80 + 90 + 30;                  % Day 5
    25+15 + 70+80 + 80+100 + 0;                  % Day 6
    35+10 + 100+30 + 100 + 30;                   % Day 7
];
% Diet 4 uses same foods as Diet 1 but with lower water-content ingredients
d4.kcal_f = [
    kcal_ingredient(foods.chia,30)+kcal_ingredient(foods.spirulina,10)+kcal_ingredient(foods.chlorella,5) + ...
    kcal_ingredient(foods.crickets,50)+kcal_ingredient(foods.mealworms,80)+kcal_ingredient(foods.spirulina,20)+kcal_ingredient(foods.chlorella,10) + ...
    kcal_ingredient(foods.mealworms,80)+kcal_ingredient(foods.oyster_mushroom,80)+kcal_ingredient(foods.spirulina,10) + ...
    kcal_ingredient(foods.chia,20)+kcal_ingredient(foods.spirulina,5);   % Day 1

    kcal_ingredient(foods.chia,20)+kcal_ingredient(foods.spirulina,10)+kcal_ingredient(foods.chlorella,20) + ...
    kcal_ingredient(foods.crickets,60)+kcal_ingredient(foods.mealworms,80) + ...
    kcal_ingredient(foods.mealworms,90)+kcal_ingredient(foods.spirulina,10);   % Day 2

    kcal_ingredient(foods.chia,40)+kcal_ingredient(foods.spirulina,5) + ...
    kcal_ingredient(foods.chia,25)+kcal_ingredient(foods.spirulina,10)+kcal_ingredient(foods.mealworms,70) + ...
    kcal_ingredient(foods.mealworms,70)+kcal_ingredient(foods.oyster_mushroom,80)+kcal_ingredient(foods.spirulina,10) + ...
    kcal_ingredient(foods.chia,30);   % Day 3

    kcal_ingredient(foods.chia,20)+kcal_ingredient(foods.chlorella,20) + ...
    kcal_ingredient(foods.crickets,60)+kcal_ingredient(foods.mealworms,80)+kcal_ingredient(foods.spirulina,10) + ...
    kcal_ingredient(foods.mealworms,30)+kcal_ingredient(foods.chlorella,20)+kcal_ingredient(foods.oyster_mushroom,80);   % Day 4

    kcal_ingredient(foods.chia,20)+kcal_ingredient(foods.spirulina,20) + ...
    kcal_ingredient(foods.chia,25)+kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.mealworms,80) + ...
    kcal_ingredient(foods.mealworms,90) + kcal_ingredient(foods.chia,30);   % Day 5

    kcal_ingredient(foods.chia,25)+kcal_ingredient(foods.spirulina,15) + ...
    kcal_ingredient(foods.crickets,70)+kcal_ingredient(foods.mealworms,80) + ...
    kcal_ingredient(foods.mealworms,80)+kcal_ingredient(foods.oyster_mushroom,100);   % Day 6

    kcal_ingredient(foods.chia,35)+kcal_ingredient(foods.spirulina,10) + ...
    kcal_ingredient(foods.mealworms,100)+kcal_ingredient(foods.chia,30) + ...
    kcal_ingredient(foods.mealworms,100) + kcal_ingredient(foods.chia,30);   % Day 7
];

% ---- DIET 5: Minimize Space ----
d5.name      = 'Diet 5: Min Space';
d5.objective = 'Minimize Space';
d5.mass_f = [
    30+10+5 + 50+60+15+10 + 80+10+10 + 20+5;         % Day 1
    20+10+10 + 60+8+15 + 90+60+5 + 25+3;              % Day 2
    40+8 + 70+8+20+10 + 70+60+10 + 30;                % Day 3
    20+8+5+15 + 60+70+10 + 80+25+15 + 20+5;           % Day 4
    20+5+20 + 65+70+10 + 75+8+10+10 + 5+20;           % Day 5
    8+20+15 + 70+8+50+10 + 80+80+8 + 25+3;            % Day 6
    35+5+10 + 40+30+8+5+25+10 + 100+15+5 + 30;        % Day 7
];
% Diet 5 prioritizes compact, calorie-dense foods: mealworms, crickets, spirulina, chia
d5.kcal_f = [
    kcal_ingredient(foods.chia,30)+kcal_ingredient(foods.spirulina,10)+kcal_ingredient(foods.chlorella,5) + ...
    kcal_ingredient(foods.crickets,50)+kcal_ingredient(foods.oyster_mushroom,60)+kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.chlorella,10) + ...
    kcal_ingredient(foods.mealworms,80)+kcal_ingredient(foods.spirulina,10)+kcal_ingredient(foods.chlorella,10) + ...
    kcal_ingredient(foods.chia,20)+kcal_ingredient(foods.spirulina,5);   % Day 1

    kcal_ingredient(foods.chia,20)+kcal_ingredient(foods.spirulina,10)+kcal_ingredient(foods.chlorella,10) + ...
    kcal_ingredient(foods.crickets,60)+kcal_ingredient(foods.spirulina,8)+kcal_ingredient(foods.chlorella,15) + ...
    kcal_ingredient(foods.mealworms,90)+kcal_ingredient(foods.oyster_mushroom,60)+kcal_ingredient(foods.spirulina,5) + ...
    kcal_ingredient(foods.chia,25)+kcal_ingredient(foods.spirulina,3);   % Day 2

    kcal_ingredient(foods.chia,40)+kcal_ingredient(foods.spirulina,8) + ...
    kcal_ingredient(foods.mealworms,70)+kcal_ingredient(foods.spirulina,8)+kcal_ingredient(foods.chlorella,20)+kcal_ingredient(foods.crickets,10) + ...
    kcal_ingredient(foods.mealworms,70)+kcal_ingredient(foods.oyster_mushroom,60)+kcal_ingredient(foods.spirulina,10) + ...
    kcal_ingredient(foods.chia,30);   % Day 3

    kcal_ingredient(foods.chia,20)+kcal_ingredient(foods.spirulina,8)+kcal_ingredient(foods.chlorella,5)+kcal_ingredient(foods.crickets,15) + ...
    kcal_ingredient(foods.crickets,60)+kcal_ingredient(foods.mealworms,70)+kcal_ingredient(foods.spirulina,10) + ...
    kcal_ingredient(foods.mealworms,80)+kcal_ingredient(foods.chia,25)+kcal_ingredient(foods.spirulina,15) + ...
    kcal_ingredient(foods.chia,20)+kcal_ingredient(foods.spirulina,5);   % Day 4

    kcal_ingredient(foods.chia,20)+kcal_ingredient(foods.spirulina,5)+kcal_ingredient(foods.chlorella,20) + ...
    kcal_ingredient(foods.crickets,65)+kcal_ingredient(foods.mealworms,70)+kcal_ingredient(foods.spirulina,10) + ...
    kcal_ingredient(foods.mealworms,75)+kcal_ingredient(foods.spirulina,8)+kcal_ingredient(foods.chlorella,10)+kcal_ingredient(foods.crickets,10) + ...
    kcal_ingredient(foods.spirulina,5)+kcal_ingredient(foods.chia,20);   % Day 5

    kcal_ingredient(foods.spirulina,8)+kcal_ingredient(foods.chia,20)+kcal_ingredient(foods.chlorella,15) + ...
    kcal_ingredient(foods.mealworms,70)+kcal_ingredient(foods.spirulina,8)+kcal_ingredient(foods.crickets,50)+kcal_ingredient(foods.chlorella,10) + ...
    kcal_ingredient(foods.mealworms,80)+kcal_ingredient(foods.oyster_mushroom,80)+kcal_ingredient(foods.spirulina,8) + ...
    kcal_ingredient(foods.chia,25)+kcal_ingredient(foods.spirulina,3);   % Day 6

    kcal_ingredient(foods.chia,35)+kcal_ingredient(foods.spirulina,5)+kcal_ingredient(foods.chlorella,10) + ...
    kcal_ingredient(foods.crickets,40)+kcal_ingredient(foods.mealworms,30)+kcal_ingredient(foods.spirulina,8)+kcal_ingredient(foods.chlorella,5)+kcal_ingredient(foods.chia,25)+kcal_ingredient(foods.crickets,10) + ...
    kcal_ingredient(foods.mealworms,100)+kcal_ingredient(foods.spirulina,15)+kcal_ingredient(foods.chlorella,5) + ...
    kcal_ingredient(foods.chia,30);   % Day 7
];

%  Collect all diets into array
diets = [d1, d2, d3, d4, d5];
num_diets = numel(diets);

%% ==========================================================================
%  SECTION 4: FILL ANY REMAINING ZERO CALORIES
%  All diets now use ingredient-level calorie calculations from the food
%  database. This section is a safety net for any days that still have 0
%  (e.g. foods not in the database). Uses confirmed targets from
%  Overall_Data_Collection.xlsx: 2000 kcal/day women, 2600 kcal/day men.
% ==========================================================================

TARGET_KCAL_F = 2000;   % kcal/day women  (from Dietary Requirements sheet)
TARGET_KCAL_M = 2600;   % kcal/day men    (from Dietary Requirements sheet)

for d = 1:num_diets
    ref_mass = mean(diets(d).mass_f);
    for day = 1:7
        if diets(d).kcal_f(day) == 0
            scale = diets(d).mass_f(day) / ref_mass;
            diets(d).kcal_f(day) = round(TARGET_KCAL_F * scale);
        end
    end
end

%% ==========================================================================
%  SECTION 5: EXPAND TO SIM_DAYS (days 8-14 repeat days 1-7)
% ==========================================================================

for d = 1:num_diets
    mass_7  = diets(d).mass_f;
    kcal_7  = diets(d).kcal_f;
    
    mass_full = zeros(1, sim_days);
    kcal_full = zeros(1, sim_days);
    
    for day = 1:sim_days
        idx = mod(day-1, 7) + 1;
        mass_full(day) = mass_7(idx);
        kcal_full(day) = kcal_7(idx);
    end
    
    diets(d).mass_f_full  = mass_full;           % women daily mass (g)
    diets(d).mass_m_full  = mass_full * MALE_MULTIPLIER;  % men daily mass (g)
    diets(d).kcal_f_full  = kcal_full;
    diets(d).kcal_m_full  = kcal_full * MALE_MULTIPLIER;
end

%% ==========================================================================
%  SECTION 6: CREW-LEVEL TOTALS
% ==========================================================================

days_vec = 1:sim_days;

for d = 1:num_diets
    % Daily crew food mass (kg)
    diets(d).crew_daily_mass_kg = ...
        (num_women .* diets(d).mass_f_full + num_men .* diets(d).mass_m_full) / 1000;
    
    % Cumulative crew food mass (kg)
    diets(d).crew_cumul_mass_kg = cumsum(diets(d).crew_daily_mass_kg);
    
    % Daily crew calories
    diets(d).crew_daily_kcal = ...
        num_women .* diets(d).kcal_f_full + num_men .* diets(d).kcal_m_full;
    
    % Calorie density: kcal per kg of food mass
    diets(d).kcal_per_kg = diets(d).crew_daily_kcal ./ diets(d).crew_daily_mass_kg;
    
    % Summary stats
    diets(d).total_mass_kg      = diets(d).crew_cumul_mass_kg(end);
    diets(d).avg_daily_mass_kg  = mean(diets(d).crew_daily_mass_kg);
    diets(d).avg_kcal_per_kg    = mean(diets(d).kcal_per_kg);
    diets(d).avg_daily_kcal     = mean(diets(d).crew_daily_kcal);
end

%% ==========================================================================
%  SECTION 7: COLORS & STYLE
% ==========================================================================

diet_colors = [
    0.12, 0.47, 0.71;   % Diet 1 - blue
    0.20, 0.63, 0.17;   % Diet 2 - green
    0.89, 0.10, 0.11;   % Diet 3 - red
    0.99, 0.55, 0.24;   % Diet 4 - orange
    0.42, 0.24, 0.60;   % Diet 5 - purple
];

diet_labels = {diets.name};

%% ==========================================================================
%%  SIM 1A: Daily Food Mass Per Person (Women vs Men), one figure per diet
% ==========================================================================

fprintf('\n===== SIM 1: PER-DIET BREAKDOWN =====\n');

for d = 1:num_diets
    figure('Name', diets(d).name, 'NumberTitle', 'off', ...
           'Position', [100, 100, 900, 500]);
    
    bar_data = [diets(d).mass_f_full; diets(d).mass_m_full]' / 1000;  % kg per person
    
    b = bar(days_vec, bar_data, 'grouped');
    b(1).FaceColor = [0.30, 0.55, 0.85];
    b(2).FaceColor = [0.85, 0.40, 0.30];
    
    xlabel('Day');
    ylabel('Food Mass per Person (kg/day)');
    title([diets(d).name, ' — Daily Food Mass by Gender'], 'FontSize', 13, 'FontWeight', 'bold');
    legend({'Women', 'Men'}, 'Location', 'northeast');
    grid on; box on;
    
    annotation('textbox', [0.13, 0.01, 0.8, 0.04], ...
        'String', sprintf('Objective: %s  |  Crew: %d women, %d men  |  Male multiplier: %.1fx', ...
        diets(d).objective, num_women, num_men, MALE_MULTIPLIER), ...
        'EdgeColor', 'none', 'FontSize', 8, 'Color', [0.4 0.4 0.4], ...
        'HorizontalAlignment', 'center');
    
    fprintf('%s: avg %.2f kg/person/day (F), %.2f kg/person/day (M)\n', ...
        diets(d).name, mean(diets(d).mass_f_full)/1000, mean(diets(d).mass_m_full)/1000);
end

%% ==========================================================================
%%  SIM 1B: Cumulative Crew Mass Over Time — All Diets Overlapping
% ==========================================================================

figure('Name', 'Cumulative Mass Comparison', 'NumberTitle', 'off', ...
       'Position', [150, 150, 950, 550]);

hold on;
for d = 1:num_diets
    plot(days_vec, diets(d).crew_cumul_mass_kg, ...
        'Color', diet_colors(d,:), 'LineWidth', 2.5, ...
        'DisplayName', diets(d).name);
end
hold off;

xlabel('Day');
ylabel('Cumulative Food Mass (kg)');
title(sprintf('Cumulative Crew Food Mass Over %d Days', sim_days), ...
    'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'northwest', 'FontSize', 10);
grid on; box on;

annotation('textbox', [0.13, 0.01, 0.8, 0.04], ...
    'String', sprintf('Crew: %d women + %d men = %d people  |  Male multiplier: %.1fx', ...
    num_women, num_men, num_women+num_men, MALE_MULTIPLIER), ...
    'EdgeColor', 'none', 'FontSize', 8, 'Color', [0.4 0.4 0.4], ...
    'HorizontalAlignment', 'center');

%% ==========================================================================
%%  SIM 1C: Calorie Density Over Time — All Diets Overlapping
% ==========================================================================

figure('Name', 'Calorie Density Comparison', 'NumberTitle', 'off', ...
       'Position', [200, 200, 950, 550]);

hold on;
for d = 1:num_diets
    plot(days_vec, diets(d).kcal_per_kg, ...
        'Color', diet_colors(d,:), 'LineWidth', 2.5, ...
        'DisplayName', diets(d).name);
end
hold off;

xlabel('Day');
ylabel('Calorie Density (kcal / kg food)');
title('Calorie Density Per Day — All Diets', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'northeast', 'FontSize', 10);
grid on; box on;

annotation('textbox', [0.13, 0.01, 0.8, 0.04], ...
    'String', 'Note: Days with missing calorie data use mass-scaled estimates from 1800 kcal/day baseline', ...
    'EdgeColor', 'none', 'FontSize', 8, 'Color', [0.55 0.35 0.00], ...
    'HorizontalAlignment', 'center');

%% ==========================================================================
%%  SIM 2A: Bar Chart — Total Mass Required Over Mission
% ==========================================================================

figure('Name', 'Diet Comparison: Total Mass', 'NumberTitle', 'off', ...
       'Position', [250, 250, 800, 500]);

total_masses = [diets.total_mass_kg];
[sorted_masses, sort_idx] = sort(total_masses, 'ascend');
sorted_labels = diet_labels(sort_idx);
sorted_colors = diet_colors(sort_idx, :);

b = bar(sorted_masses, 'FaceColor', 'flat');
for i = 1:num_diets
    b.CData(i,:) = sorted_colors(i,:);
end
set(gca, 'XTickLabel', sorted_labels, 'XTick', 1:num_diets, 'FontSize', 9);
xtickangle(20);
ylabel(sprintf('Total Food Mass (kg) over %d days', sim_days));
title(sprintf('Total Crew Food Mass by Diet — %d Days, %d People', sim_days, num_women+num_men), ...
    'FontSize', 13, 'FontWeight', 'bold');
grid on; box on;

% Value labels on bars
for i = 1:num_diets
    text(i, sorted_masses(i) + 0.5, sprintf('%.1f kg', sorted_masses(i)), ...
        'HorizontalAlignment', 'center', 'FontSize', 9, 'FontWeight', 'bold');
end

%% ==========================================================================
%%  SIM 2B: Diet Ranking Table (printed to console)
% ==========================================================================

fprintf('\n===== SIM 2: DIET RANKING (least to most total mass) =====\n');
fprintf('%-5s  %-30s  %-12s  %-18s  %-18s  %-18s\n', ...
    'Rank', 'Diet', 'Total (kg)', 'Avg kg/day (crew)', 'Avg kcal/day', 'kcal/kg');
fprintf('%s\n', repmat('-', 1, 95));

for i = 1:num_diets
    d = sort_idx(i);
    fprintf('%-5d  %-30s  %-12.2f  %-18.2f  %-18.0f  %-18.1f\n', ...
        i, ...
        diets(d).name, ...
        diets(d).total_mass_kg, ...
        diets(d).avg_daily_mass_kg, ...
        diets(d).avg_daily_kcal, ...
        diets(d).avg_kcal_per_kg);
end

%% ==========================================================================
%%  SIM 2C: Radar / Spider Chart — Multi-metric diet comparison
%   Metrics (all normalized 0-1, 1 = best):
%     1. Low total mass (1 = lightest)
%     2. High calorie density (1 = most kcal/kg)
%     3. Low daily variability (1 = most consistent)
%     4. Calorie adequacy (1 = closest to 2000 kcal/person/day target)
% ==========================================================================

total_crew = num_women + num_men;
TARGET_KCAL_PER_PERSON = TARGET_KCAL_F;

metrics = zeros(num_diets, 4);
for d = 1:num_diets
    metrics(d,1) = diets(d).total_mass_kg;
    metrics(d,2) = diets(d).avg_kcal_per_kg;
    metrics(d,3) = std(diets(d).crew_daily_mass_kg);  % lower = better
    metrics(d,4) = abs(diets(d).avg_daily_kcal/total_crew - TARGET_KCAL_PER_PERSON);  % lower = better
end

% Normalize: for mass and variability, invert (lower is better)
norm_metrics = zeros(num_diets, 4);
norm_metrics(:,1) = 1 - (metrics(:,1) - min(metrics(:,1))) ./ (max(metrics(:,1)) - min(metrics(:,1)) + eps);
norm_metrics(:,2) = (metrics(:,2) - min(metrics(:,2))) ./ (max(metrics(:,2)) - min(metrics(:,2)) + eps);
norm_metrics(:,3) = 1 - (metrics(:,3) - min(metrics(:,3))) ./ (max(metrics(:,3)) - min(metrics(:,3)) + eps);
norm_metrics(:,4) = 1 - (metrics(:,4) - min(metrics(:,4))) ./ (max(metrics(:,4)) - min(metrics(:,4)) + eps);

metric_labels = {'Low Mass', 'Cal Density', 'Consistency', 'Cal Adequacy'};
num_metrics = 4;
angles = linspace(0, 2*pi, num_metrics+1);
angles(end) = [];  % remove duplicate last

figure('Name', 'Diet Radar Chart', 'NumberTitle', 'off', ...
       'Position', [300, 300, 700, 600]);

ax = axes;
hold on;

% Draw grid circles
for r = 0.25:0.25:1.0
    th = linspace(0, 2*pi, 200);
    plot(r*cos(th), r*sin(th), 'Color', [0.8 0.8 0.8], 'LineWidth', 0.5);
end

% Draw axes
for k = 1:num_metrics
    plot([0, cos(angles(k))], [0, sin(angles(k))], 'Color', [0.7 0.7 0.7], 'LineWidth', 0.8);
    text(1.15*cos(angles(k)), 1.15*sin(angles(k)), metric_labels{k}, ...
        'HorizontalAlignment', 'center', 'FontSize', 10, 'FontWeight', 'bold');
end

% Plot each diet
for d = 1:num_diets
    vals = [norm_metrics(d,:), norm_metrics(d,1)];
    ang  = [angles, angles(1)];
    x = vals .* cos(ang);
    y = vals .* sin(ang);
    plot(x, y, 'Color', diet_colors(d,:), 'LineWidth', 2, 'DisplayName', diets(d).name);
    fill(x, y, diet_colors(d,:), 'FaceAlpha', 0.08, 'EdgeColor', 'none', 'HandleVisibility', 'off');
end

axis equal; axis off;
title('Diet Comparison — Normalized Multi-Metric Radar', 'FontSize', 13, 'FontWeight', 'bold');
% Grab only the line objects (not fills or grid lines) for the legend
all_lines = findobj(ax, 'Type', 'line');
diet_lines = flip(all_lines(1:num_diets));  % flip to restore diet order
legend(diet_lines, diet_labels, 'Location', 'southoutside', 'NumColumns', 3, 'FontSize', 9);
hold off;

%% ==========================================================================
%%  SIM 2D: Stacked area — daily crew mass by diet (overlapping area plot)
% ==========================================================================

figure('Name', 'Daily Mass Overlap All Diets', 'NumberTitle', 'off', ...
       'Position', [350, 100, 950, 500]);

hold on;
for d = 1:num_diets
    area(days_vec, diets(d).crew_daily_mass_kg, ...
        'FaceColor', diet_colors(d,:), 'FaceAlpha', 0.25, ...
        'EdgeColor', diet_colors(d,:), 'LineWidth', 1.8, ...
        'DisplayName', diets(d).name);
end
hold off;

xlabel('Day');
ylabel('Daily Crew Food Mass (kg)');
title('Daily Crew Food Mass — All Diets Overlaid', 'FontSize', 14, 'FontWeight', 'bold');
legend('Location', 'northeast', 'FontSize', 10);
grid on; box on;

%% ==========================================================================
%%  DONE
% ==========================================================================

fprintf('\n===== SIMULATION COMPLETE =====\n');
fprintf('Crew:      %d women + %d men (%d total)\n', num_women, num_men, num_women+num_men);
fprintf('Duration:  %d days\n', sim_days);
fprintf('Figures generated: %d\n', num_diets + 4);
fprintf('\nTo change crew size or duration, edit Section 1 at the top.\n');
fprintf('To add a new diet, follow the format in Section 2.\n');