% ==========================================
% EXPERT SYSTEM RULES - Inference Engine
% ==========================================

:- consult('food_db.pl').

% ==========================================
% MAIN RECOMMENDATION PREDICATE
% ==========================================

% recommend(MinPrice, MaxPrice, CalorieLevel, MealType, Cuisine, Categories, SpiceLevel, PrepTime, VegetarianOnly, FoodID, FoodName, Price)
recommend(MinPrice, MaxPrice, CalorieLevel, MealType, Cuisine, Categories, SpiceLevel, PrepTime, VegetarianOnly, FoodID, FoodName, Price, Calories, FoodCategories, Spice, Prep, Protein, Trending) :-
    food(FoodID, FoodName, Price, Calories, MealTypes, FoodCuisine, FoodCategories, Spice, Prep, Available, Trending, Protein),
    
    % Rule 1: Availability Check
    Available = yes,
    
    % Rule 2: Price Range Constraint
    Price >= MinPrice,
    Price =< MaxPrice,
    
    % Rule 3: Calorie Level Matching (if specified)
    (CalorieLevel = any ; Calories = CalorieLevel),
    
    % Rule 4: Meal Type Matching (if specified)
    (MealType = any ; member(MealType, MealTypes)),
    
    % Rule 5: Cuisine Type Matching (if specified)
    (Cuisine = any ; FoodCuisine = Cuisine),
    
    % Rule 6: Food Categories Matching (if specified)
    (Categories = [] ; has_matching_category(Categories, FoodCategories)),
    
    % Rule 7: Spice Level Matching (if specified)
    (SpiceLevel = any ; Spice = SpiceLevel),
    
    % Rule 8: Preparation Time Matching (if specified)
    (PrepTime = any ; Prep = PrepTime),
    
    % Rule 9: Vegetarian Constraint
    (VegetarianOnly = no ; is_vegetarian(FoodCategories)).


% ==========================================
% HELPER PREDICATES
% ==========================================

% Check if at least one category matches
has_matching_category(UserCategories, FoodCategories) :-
    member(Category, UserCategories),
    member(Category, FoodCategories), !.

% Check if food is vegetarian (doesn't contain non_veg)
is_vegetarian(Categories) :-
    \+ member(non_veg, Categories).

% Get all recommendations and return as list
get_all_recommendations(MinPrice, MaxPrice, CalorieLevel, MealType, Cuisine, Categories, SpiceLevel, PrepTime, VegetarianOnly, Results) :-
    findall(
        food_result(FoodID, FoodName, Price, Calories, FoodCategories, Spice, Prep, Protein, Trending),
        recommend(MinPrice, MaxPrice, CalorieLevel, MealType, Cuisine, Categories, SpiceLevel, PrepTime, VegetarianOnly, FoodID, FoodName, Price, Calories, FoodCategories, Spice, Prep, Protein, Trending),
        Results
    ).

% Sort results by trending first, then by price
sort_recommendations(Results, SortedResults) :-
    sort_by_trending_and_price(Results, SortedResults).

sort_by_trending_and_price(Results, Sorted) :-
    predsort(compare_food_items, Results, Sorted).

compare_food_items(Order, food_result(_, _, Price1, _, _, _, _, _, Trending1), food_result(_, _, Price2, _, _, _, _, _, Trending2)) :-
    (   Trending1 = yes, Trending2 = no
    ->  Order = (<)
    ;   Trending1 = no, Trending2 = yes
    ->  Order = (>)
    ;   compare(Order, Price1, Price2)
    ).


% ==========================================
% QUERY INTERFACE FOR WEB API
% ==========================================

% Main query predicate that returns JSON-ready results
query_recommendations(MinPrice, MaxPrice, CalorieLevel, MealType, Cuisine, Categories, SpiceLevel, PrepTime, VegetarianOnly, JsonResults) :-
    get_all_recommendations(MinPrice, MaxPrice, CalorieLevel, MealType, Cuisine, Categories, SpiceLevel, PrepTime, VegetarianOnly, Results),
    sort_recommendations(Results, SortedResults),
    format_results_as_json(SortedResults, JsonResults).

% Format results as JSON structure
format_results_as_json([], []).
format_results_as_json([food_result(ID, Name, Price, Calories, Categories, Spice, Prep, Protein, Trending)|Rest], [json([id=ID, name=Name, price=Price, calories=Calories, categories=Categories, spice=Spice, prep=Prep, protein=Protein, trending=Trending])|JsonRest]) :-
    format_results_as_json(Rest, JsonRest).


% ==========================================
% EXPLANATION SYSTEM (Optional Enhancement)
% ==========================================

% Explain why a food item was recommended
explain_recommendation(FoodID, MinPrice, MaxPrice, CalorieLevel, MealType, Cuisine, Categories, SpiceLevel, PrepTime, VegetarianOnly) :-
    food(FoodID, FoodName, Price, Calories, MealTypes, FoodCuisine, FoodCategories, Spice, Prep, Available, Trending, Protein),
    format('Food: ~w~n', [FoodName]),
    format('Explanation:~n', []),
    format('  ✓ Available: ~w~n', [Available]),
    format('  ✓ Price ৳~w is within your budget (৳~w - ৳~w)~n', [Price, MinPrice, MaxPrice]),
    (CalorieLevel \= any -> format('  ✓ Calorie level (~w) matches your preference~n', [Calories]) ; true),
    (MealType \= any -> format('  ✓ Suitable for ~w~n', [MealType]) ; true),
    (Cuisine \= any -> format('  ✓ ~w cuisine as requested~n', [FoodCuisine]) ; true),
    (Categories \= [] -> format('  ✓ Matches your category preferences~n', []) ; true),
    (SpiceLevel \= any -> format('  ✓ Spice level (~w) matches~n', [Spice]) ; true),
    (PrepTime \= any -> format('  ✓ Preparation time (~w) matches~n', [Prep]) ; true),
    (VegetarianOnly = yes -> format('  ✓ Vegetarian dish~n', []) ; true),
    (Trending = yes -> format('  ⭐ This is a TRENDING item!~n', []) ; true),
    format('  📊 Nutritional Info: ~wg protein~n', [Protein]).


% ==========================================
% EXAMPLE QUERIES (For Testing)
% ==========================================

% Example 1: Budget-friendly vegetarian lunch
test_query_1 :-
    query_recommendations(0, 200, any, lunch, any, [vegetarian], any, any, yes, Results),
    length(Results, Count),
    format('Found ~w vegetarian lunch items under ৳200:~n', [Count]),
    print_results(Results).

% Example 2: High protein, non-veg dinner
test_query_2 :-
    query_recommendations(200, 500, any, dinner, any, [non_veg], any, any, no, Results),
    length(Results, Count),
    format('Found ~w non-veg dinner items (৳200-৳500):~n', [Count]),
    print_results(Results).

% Example 3: Quick spicy snacks
test_query_3 :-
    query_recommendations(0, 300, any, snacks, any, [spicy], any, quick, no, Results),
    length(Results, Count),
    format('Found ~w quick spicy snacks:~n', [Count]),
    print_results(Results).

% Example 4: Indian cuisine with medium spice
test_query_4 :-
    query_recommendations(0, 400, any, any, indian, [], medium, any, no, Results),
    length(Results, Count),
    format('Found ~w Indian dishes with medium spice:~n', [Count]),
    print_results(Results).

% Helper to print results
print_results([]).
print_results([json(Item)|Rest]) :-
    member(name=Name, Item),
    member(price=Price, Item),
    member(trending=Trending, Item),
    (Trending = yes -> TrendingMark = ' ⭐' ; TrendingMark = ''),
    format('  - ~w (৳~w)~w~n', [Name, Price, TrendingMark]),
    print_results(Rest).