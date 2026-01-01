% ==========================================
% FOOD DATABASE - Knowledge Base
% ==========================================

% food(ID, Name, Price, Calories, MealTypes, Cuisine, Categories, SpiceLevel, PrepTime, Available, Trending, Protein)

% Bangla Cuisine
food(1, 'Beef Bhuna', 280, high, [lunch, dinner], bangla, [spicy, non_veg], medium, long, yes, yes, 35).
food(2, 'Hilsa Fish Curry', 450, medium, [lunch, dinner], bangla, [spicy, non_veg], medium, medium, yes, yes, 30).
food(3, 'Panta Bhat with Ilish', 350, medium, [breakfast, lunch], bangla, [non_veg], mild, quick, yes, no, 25).
food(4, 'Dal Bhaji', 120, low, [lunch, dinner], bangla, [vegetarian], mild, medium, yes, no, 12).
food(5, 'Shorshe Ilish', 480, medium, [lunch, dinner], bangla, [spicy, non_veg], hot, medium, yes, yes, 32).

% Indian Cuisine
food(6, 'Chicken Tikka Masala', 320, high, [lunch, dinner], indian, [spicy, non_veg, grilled], medium, medium, yes, yes, 38).
food(7, 'Paneer Butter Masala', 250, medium, [lunch, dinner], indian, [vegetarian], mild, medium, yes, no, 18).
food(8, 'Biryani (Chicken)', 280, high, [lunch, dinner], indian, [spicy, non_veg], medium, long, yes, yes, 30).
food(9, 'Samosa (2 pcs)', 60, medium, [snacks], indian, [fried, vegetarian], mild, quick, yes, no, 6).
food(10, 'Masala Dosa', 180, medium, [breakfast, snacks], indian, [vegetarian], medium, medium, yes, no, 10).

% Chinese Cuisine
food(11, 'Chicken Fried Rice', 220, medium, [lunch, dinner], chinese, [fried, non_veg], mild, quick, yes, no, 22).
food(12, 'Sweet and Sour Chicken', 280, medium, [lunch, dinner], chinese, [fried, non_veg], mild, medium, yes, no, 26).
food(13, 'Vegetable Spring Rolls', 150, low, [snacks], chinese, [fried, vegetarian], mild, quick, yes, no, 8).
food(14, 'Szechuan Noodles', 240, medium, [lunch, dinner], chinese, [spicy, vegetarian], hot, quick, yes, yes, 12).

% Thai Cuisine
food(15, 'Pad Thai', 290, medium, [lunch, dinner], thai, [non_veg], medium, quick, yes, yes, 24).
food(16, 'Tom Yum Soup', 220, low, [snacks, lunch], thai, [spicy, non_veg], hot, medium, yes, no, 15).
food(17, 'Green Curry', 310, medium, [lunch, dinner], thai, [spicy, non_veg], hot, medium, yes, no, 28).
food(18, 'Thai Basil Fried Rice', 230, medium, [lunch, dinner], thai, [fried, vegetarian], medium, quick, yes, no, 10).

% Continental
food(19, 'Grilled Chicken Steak', 420, high, [lunch, dinner], continental, [grilled, non_veg], mild, long, yes, yes, 45).
food(20, 'Caesar Salad', 180, low, [snacks, lunch], continental, [vegetarian], mild, quick, yes, no, 12).
food(21, 'Spaghetti Carbonara', 320, high, [lunch, dinner], continental, [non_veg], mild, medium, yes, no, 28).
food(22, 'Beef Burger', 250, high, [snacks, lunch, dinner], continental, [fried, non_veg], mild, quick, yes, yes, 32).
food(23, 'Mushroom Soup', 150, low, [snacks], continental, [vegetarian], mild, medium, yes, no, 6).
food(24, 'Fish and Chips', 350, high, [lunch, dinner], continental, [fried, non_veg], mild, medium, yes, no, 30).

% Additional items for variety
food(25, 'Vegetable Biryani', 200, medium, [lunch, dinner], indian, [spicy, vegetarian], medium, long, yes, no, 15).
food(26, 'Prawn Malai Curry', 420, medium, [lunch, dinner], bangla, [spicy, non_veg], medium, medium, yes, yes, 28).
food(27, 'Chicken Chow Mein', 210, medium, [snacks, lunch, dinner], chinese, [fried, non_veg], mild, quick, yes, no, 20).
food(28, 'Mango Sticky Rice', 180, medium, [snacks], thai, [vegetarian], mild, quick, yes, no, 4).
food(29, 'Mushroom Risotto', 320, medium, [lunch, dinner], continental, [vegetarian], mild, medium, yes, no, 10).
food(30, 'Beef Kebab', 290, high, [snacks, lunch, dinner], bangla, [grilled, non_veg], medium, medium, yes, yes, 35).