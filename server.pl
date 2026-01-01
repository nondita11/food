% ==========================================
% HTTP SERVER FOR FOOD RECOMMENDATION SYSTEM
% ==========================================

:- use_module(library(http/thread_httpd)).
:- use_module(library(http/http_dispatch)).
:- use_module(library(http/http_parameters)).
:- use_module(library(http/http_json)).
:- use_module(library(http/http_cors)).
:- use_module(library(http/http_header)).
:- use_module(library(http/http_files)).
:- consult('rules.pl').

% Set the document root to the current directory
:- prolog_load_context(directory, Dir), asserta(user:file_search_path(document_root, Dir)).

% ==========================================
% HTTP ROUTE HANDLERS
% ==========================================

% Define routes
:- http_handler(root(app), serve_frontend, []).
:- http_handler(root(.), api_info_page, []).
:- http_handler(root(recommend), handle_recommendation, [methods([post, options])]).
:- http_handler(root(explain), handle_explanation, [methods([post, options])]).
:- http_handler(root('style.css'), http_reply_file(document_root('style.css'), []), []).
:- http_handler(root('script.js'), http_reply_file(document_root('script.js'), []), []).

% Serve the frontend HTML
serve_frontend(Request) :-
    http_reply_file(document_root('index.html'), [], Request).

% API information page
api_info_page(_Request) :-
    format('Content-type: text/html~n~n'),
    format('<html><head><title>Food Recommendation API</title></head><body>'),
    format('<h1>Smart Food Recommendation Expert System API</h1>'),
    format('<h2>✅ Server is Running!</h2>'),
    format('<h3>Endpoints:</h3>'),
    format('<ul>'),
    format('<li><b>POST /recommend</b> - Get food recommendations</li>'),
    format('<li><b>POST /explain</b> - Get explanation for a recommendation</li>'),
    format('</ul>'),
    format('<h2>Example POST to /recommend:</h2>'),
    format('<pre>'),
    format('{~n'),
    format('  "minPrice": 0,~n'),
    format('  "maxPrice": 500,~n'),
    format('  "calorieLevel": "any",~n'),
    format('  "mealType": "lunch",~n'),
    format('  "cuisine": "any",~n'),
    format('  "categories": ["spicy"],~n'),
    format('  "spiceLevel": "medium",~n'),
    format('  "prepTime": "any",~n'),
    format('  "vegetarianOnly": false~n'),
    format('}'),
    format('</pre>'),
    format('<h3>🎯 <a href="/app" style="color: #007acc; text-decoration: none;">Access Frontend UI →</a></h3>'),
    format('<h3>Server is running on port 5000</h3>'),
    format('</body></html>').

% Handle CORS preflight - integrated into main handlers
% OPTIONS requests handled within handle_recommendation and handle_explanation

cors_headers :-
    format('Access-Control-Allow-Origin: *~n'),
    format('Access-Control-Allow-Methods: GET, POST, OPTIONS~n'),
    format('Access-Control-Allow-Headers: Content-Type~n').

% Handle recommendation request
handle_recommendation(Request) :-
    % Check if this is a CORS preflight request
    memberchk(method(options), Request),
    !,
    cors_headers,
    format('Content-Length: 0~n'),
    format('~n').

handle_recommendation(Request) :-
    % Set CORS headers
    cors_headers,
    
    % Read JSON input
    http_read_json_dict(Request, JsonIn),
    
    % Extract parameters with defaults
    get_dict_default(minPrice, JsonIn, MinPrice, 0),
    get_dict_default(maxPrice, JsonIn, MaxPrice, 10000),
    get_dict_default(calorieLevel, JsonIn, CalorieLevelStr, "any"),
    get_dict_default(mealType, JsonIn, MealTypeStr, "any"),
    get_dict_default(cuisine, JsonIn, CuisineStr, "any"),
    get_dict_default(categories, JsonIn, CategoriesList, []),
    get_dict_default(spiceLevel, JsonIn, SpiceLevelStr, "any"),
    get_dict_default(prepTime, JsonIn, PrepTimeStr, "any"),
    get_dict_default(vegetarianOnly, JsonIn, VegetarianOnlyBool, false),
    
    % Convert strings to atoms
    atom_string(CalorieLevel, CalorieLevelStr),
    atom_string(MealType, MealTypeStr),
    atom_string(Cuisine, CuisineStr),
    atom_string(SpiceLevel, SpiceLevelStr),
    atom_string(PrepTime, PrepTimeStr),
    
    % Convert categories list
    convert_categories(CategoriesList, Categories),
    
    % Convert boolean to yes/no
    (VegetarianOnlyBool = true -> VegetarianOnly = yes ; VegetarianOnly = no),
    
    % Get recommendations
    query_recommendations(MinPrice, MaxPrice, CalorieLevel, MealType, Cuisine, Categories, SpiceLevel, PrepTime, VegetarianOnly, Results),
    
    % Convert results to proper JSON format
    convert_results_to_dict(Results, ResultsDict),
    
    % Send response with CORS headers
    reply_json_dict(_{
        success: true,
        count: ResultsDict.length,
        recommendations: ResultsDict.items
    }).

% Handle explanation request
handle_explanation(Request) :-
    % Check if this is a CORS preflight request
    memberchk(method(options), Request),
    !,
    cors_headers,
    format('Content-Length: 0~n'),
    format('~n').

handle_explanation(Request) :-
    % Set CORS headers
    cors_headers,
    
    http_read_json_dict(Request, JsonIn),
    
    get_dict_default(foodId, JsonIn, FoodID, 1),
    get_dict_default(minPrice, JsonIn, MinPrice, 0),
    get_dict_default(maxPrice, JsonIn, MaxPrice, 10000),
    get_dict_default(calorieLevel, JsonIn, CalorieLevelStr, "any"),
    get_dict_default(mealType, JsonIn, MealTypeStr, "any"),
    get_dict_default(cuisine, JsonIn, CuisineStr, "any"),
    get_dict_default(categories, JsonIn, CategoriesList, []),
    get_dict_default(spiceLevel, JsonIn, SpiceLevelStr, "any"),
    get_dict_default(prepTime, JsonIn, PrepTimeStr, "any"),
    get_dict_default(vegetarianOnly, JsonIn, VegetarianOnlyBool, false),
    
    % Convert parameters
    atom_string(CalorieLevel, CalorieLevelStr),
    atom_string(MealType, MealTypeStr),
    atom_string(Cuisine, CuisineStr),
    atom_string(SpiceLevel, SpiceLevelStr),
    atom_string(PrepTime, PrepTimeStr),
    convert_categories(CategoriesList, Categories),
    (VegetarianOnlyBool = true -> VegetarianOnly = yes ; VegetarianOnly = no),
    
    % Generate explanation
    with_output_to(string(Explanation),
        explain_recommendation(FoodID, MinPrice, MaxPrice, CalorieLevel, MealType, Cuisine, Categories, SpiceLevel, PrepTime, VegetarianOnly)
    ),
    
    reply_json_dict(_{
        success: true,
        foodId: FoodID,
        explanation: Explanation
    }).

% ==========================================
% HELPER PREDICATES
% ==========================================

% Safe dictionary get with default
get_dict_default(Key, Dict, Value, Default) :-
    (   get_dict(Key, Dict, Value)
    ->  true
    ;   Value = Default
    ).

% Convert category strings to atoms
convert_categories([], []).
convert_categories([H|T], [HA|TA]) :-
    atom_string(HA, H),
    convert_categories(T, TA).

% Convert results to dictionary format
convert_results_to_dict(Results, _{length: Count, items: ItemsList}) :-
    length(Results, Count),
    convert_items_to_dicts(Results, ItemsList).

convert_items_to_dicts([], []).
convert_items_to_dicts([json(Item)|Rest], [Dict|RestDicts]) :-
    member(id=ID, Item),
    member(name=Name, Item),
    member(price=Price, Item),
    member(calories=Calories, Item),
    member(categories=Categories, Item),
    member(spice=Spice, Item),
    member(prep=Prep, Item),
    member(protein=Protein, Item),
    member(trending=Trending, Item),
    
    % Convert atoms to strings for JSON
    atom_string(Name, NameStr),
    atom_string(Calories, CaloriesStr),
    atom_string(Spice, SpiceStr),
    atom_string(Prep, PrepStr),
    convert_categories_to_strings(Categories, CategoriesStr),
    (Trending = yes -> TrendingBool = true ; TrendingBool = false),
    
    Dict = _{
        id: ID,
        name: NameStr,
        price: Price,
        calories: CaloriesStr,
        categories: CategoriesStr,
        spice: SpiceStr,
        prep: PrepStr,
        protein: Protein,
        trending: TrendingBool
    },
    convert_items_to_dicts(Rest, RestDicts).

convert_categories_to_strings([], []).
convert_categories_to_strings([H|T], [HS|TS]) :-
    atom_string(H, HS),
    convert_categories_to_strings(T, TS).

% ==========================================
% SERVER START
% ==========================================

% Start the server with CORS enabled
start_server(Port) :-
    http_server(http_dispatch, [port(Port)]),
    format('~n==========================================~n'),
    format('✅ Server started successfully!~n'),
    format('==========================================~n'),
    format('Server running on: http://localhost:~w~n', [Port]),
    format('API endpoint: http://localhost:~w/recommend~n', [Port]),
    format('~n🎯 Frontend UI: http://localhost:~w/app~n', [Port]),
    format('~nTest the server: Open http://localhost:~w/app in browser~n', [Port]),
    format('==========================================~n~n').

% Stop the server
stop_server(Port) :-
    http_stop_server(Port, []),
    format('Server stopped.~n').

% Default start on port 5000
server :-
    start_server(5000).

% ==========================================
% STARTUP MESSAGE
% ==========================================

:- initialization((
    format('~n'),
    format('==========================================~n'),
    format('  Food Recommendation Expert System~n'),
    format('  Prolog Backend Server~n'),
    format('==========================================~n'),
    format('~n'),
    format('To start the server, run:~n'),
    format('  ?- server.~n'),
    format('~n'),
    format('Server will start on: http://localhost:5000~n'),
    format('~n')
)).