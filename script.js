// ==========================================
// SMART FOOD RECOMMENDATION SYSTEM - FRONTEND
// ==========================================

// API Configuration
const API_BASE_URL = 'http://localhost:5000';

// Current selections
let selectedValues = {
    calorie: 'any',
    meal: 'any',
    cuisine: 'any',
    categories: [],
    spice: 'any',
    prep: 'any'
};

// Food emoji mapping
const foodEmojis = {
    'Beef Bhuna': '🍖',
    'Hilsa Fish Curry': '🐟',
    'Panta Bhat with Ilish': '🍚',
    'Dal Bhaji': '🥘',
    'Shorshe Ilish': '🐟',
    'Chicken Tikka Masala': '🍗',
    'Paneer Butter Masala': '🧈',
    'Biryani (Chicken)': '🍛',
    'Samosa (2 pcs)': '🥟',
    'Masala Dosa': '🫓',
    'Chicken Fried Rice': '🍚',
    'Sweet and Sour Chicken': '🍗',
    'Vegetable Spring Rolls': '🥢',
    'Szechuan Noodles': '🍜',
    'Pad Thai': '🍝',
    'Tom Yum Soup': '🍲',
    'Green Curry': '🍛',
    'Thai Basil Fried Rice': '🍚',
    'Grilled Chicken Steak': '🥩',
    'Caesar Salad': '🥗',
    'Spaghetti Carbonara': '🍝',
    'Beef Burger': '🍔',
    'Mushroom Soup': '🍄',
    'Fish and Chips': '🐟',
    'Vegetable Biryani': '🍛',
    'Prawn Malai Curry': '🦐',
    'Chicken Chow Mein': '🍜',
    'Mango Sticky Rice': '🥭',
    'Mushroom Risotto': '🍄',
    'Beef Kebab': '🍢'
};

// ==========================================
// PAGE NAVIGATION
// ==========================================

function goToWelcomePage() {
    showPage('welcomePage');
}

function goToRecommendPage() {
    showPage('recommendPage');
}

function goToResultsPage() {
    showPage('resultsPage');
}

function showPage(pageId) {
    const pages = document.querySelectorAll('.page');
    pages.forEach(page => page.classList.remove('active'));
    document.getElementById(pageId).classList.add('active');
    window.scrollTo(0, 0);
}

// ==========================================
// OPTION BUTTON HANDLERS
// ==========================================

function setupOptionButtons() {
    // Single selection buttons
    setupSingleSelection('calorieGroup', 'calorie');
    setupSingleSelection('mealGroup', 'meal');
    setupSingleSelection('cuisineGroup', 'cuisine');
    setupSingleSelection('spiceGroup', 'spice');
    setupSingleSelection('prepGroup', 'prep');
    
    // Multiple selection buttons
    setupMultipleSelection('categoryGroup');
}

function setupSingleSelection(groupId, key) {
    const group = document.getElementById(groupId);
    const buttons = group.querySelectorAll('.option-btn');
    
    buttons.forEach(btn => {
        btn.addEventListener('click', function() {
            buttons.forEach(b => b.classList.remove('active'));
            this.classList.add('active');
            selectedValues[key] = this.dataset.value;
        });
    });
    
    // Set first button as active by default
    buttons[0].classList.add('active');
}

function setupMultipleSelection(groupId) {
    const group = document.getElementById(groupId);
    const buttons = group.querySelectorAll('.option-btn');
    
    buttons.forEach(btn => {
        btn.addEventListener('click', function() {
            this.classList.toggle('active');
            
            const value = this.dataset.value;
            if (this.classList.contains('active')) {
                if (!selectedValues.categories.includes(value)) {
                    selectedValues.categories.push(value);
                }
            } else {
                selectedValues.categories = selectedValues.categories.filter(v => v !== value);
            }
        });
    });
}

// ==========================================
// FORM SUBMISSION
// ==========================================

function setupFormSubmission() {
    const form = document.getElementById('preferencesForm');
    form.addEventListener('submit', async function(e) {
        e.preventDefault();
        
        const minPrice = parseInt(document.getElementById('minPrice').value) || 0;
        const maxPrice = parseInt(document.getElementById('maxPrice').value) || 10000;
        const vegetarianOnly = document.getElementById('vegetarianOnly').checked;
        
        // Prepare request data
        const requestData = {
            minPrice: minPrice,
            maxPrice: maxPrice,
            calorieLevel: selectedValues.calorie,
            mealType: selectedValues.meal,
            cuisine: selectedValues.cuisine,
            categories: selectedValues.categories,
            spiceLevel: selectedValues.spice,
            prepTime: selectedValues.prep,
            vegetarianOnly: vegetarianOnly
        };
        
        // Go to results page and fetch recommendations
        goToResultsPage();
        await fetchRecommendations(requestData);
    });
}

// ==========================================
// API CALLS
// ==========================================

async function fetchRecommendations(preferences) {
    const loadingSpinner = document.getElementById('loadingSpinner');
    const resultsGrid = document.getElementById('resultsGrid');
    const noResults = document.getElementById('noResults');
    const resultsCount = document.getElementById('resultsCount');
    
    // Show loading
    loadingSpinner.style.display = 'block';
    resultsGrid.style.display = 'none';
    noResults.style.display = 'none';
    
    try {
        const response = await fetch(`${API_BASE_URL}/recommend`, {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
            },
            body: JSON.stringify(preferences)
        });
        
        if (!response.ok) {
            throw new Error('Network response was not ok');
        }
        
        const data = await response.json();
        
        // Hide loading
        loadingSpinner.style.display = 'none';
        
        if (data.success && data.count > 0) {
            resultsCount.textContent = `Found ${data.count} dishes matching your preferences`;
            displayResults(data.recommendations);
            resultsGrid.style.display = 'grid';
        } else {
            noResults.style.display = 'block';
        }
        
    } catch (error) {
        console.error('Error fetching recommendations:', error);
        loadingSpinner.style.display = 'none';
        
        // Show error message
        alert('Error connecting to Prolog server. Please make sure the server is running on port 5000.\n\nTo start the server:\n1. Open SWI-Prolog\n2. Load server.pl\n3. Run: ?- server.');
        
        // Go back to recommend page
        goToRecommendPage();
    }
}

// ==========================================
// DISPLAY RESULTS
// ==========================================

function displayResults(recommendations) {
    const resultsGrid = document.getElementById('resultsGrid');
    resultsGrid.innerHTML = '';
    
    recommendations.forEach(food => {
        const foodCard = createFoodCard(food);
        resultsGrid.appendChild(foodCard);
    });
}

function createFoodCard(food) {
    const card = document.createElement('div');
    card.className = 'food-card';
    
    const emoji = foodEmojis[food.name] || '🍽️';
    const trendingBadge = food.trending ? '<div class="trending-badge">⭐ TRENDING</div>' : '';
    
    // Format categories
    const categoriesHTML = food.categories.map(cat => {
        const displayName = cat === 'non_veg' ? 'Non-Veg' : cat.replace('_', ' ');
        return `<span class="category-badge">${displayName}</span>`;
    }).join('');
    
    card.innerHTML = `
        <div class="food-header">
            <div class="food-emoji">${emoji}</div>
            ${trendingBadge}
        </div>
        <div class="food-body">
            <h3 class="food-name">${food.name}</h3>
            <div class="price-availability">
                <span class="food-price">৳${food.price}</span>
                <span class="availability-badge">Available</span>
            </div>
            <div class="food-details">
                <div class="detail-row">
                    <span class="detail-label">Cuisine:</span>
                    <span class="detail-value">${food.calories}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Calories:</span>
                    <span class="detail-value">${food.calories}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Spice:</span>
                    <span class="detail-value">${food.spice}</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Protein:</span>
                    <span class="detail-value">${food.protein}g</span>
                </div>
                <div class="detail-row">
                    <span class="detail-label">Prep Time:</span>
                    <span class="detail-value">${food.prep}</span>
                </div>
            </div>
            <div class="food-categories">
                ${categoriesHTML}
            </div>
        </div>
    `;
    
    return card;
}

// ==========================================
// INITIALIZE
// ==========================================

document.addEventListener('DOMContentLoaded', function() {
    setupOptionButtons();
    setupFormSubmission();
    
    console.log('Food Recommendation System Initialized');
    console.log('Make sure Prolog server is running on port 5000');
    console.log('To start server: ?- server.');
});