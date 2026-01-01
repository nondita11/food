# Smart Food Recommendation Expert System

A Prolog-based expert system that provides intelligent food recommendations based on user preferences.

## 🚀 How to Start

### Step 1: Install SWI-Prolog
Download and install from [swi-prolog.org](https://www.swi-prolog.org/Download.html)

### Step 2: Start the Server

1. **Open SWI-Prolog** (search "SWI-Prolog" in Windows Start menu)

2. **Load the server file:**
   - Click **File** → **Consult...**
   - Navigate to this project folder
   - Select **`server.pl`**
   - Click **Open**

3. **Start the server:**
   - In the Prolog prompt, type:
   ```prolog
   ?- server.
   ```
   - Press **Enter**

4. **You'll see:**
   ```
   ==========================================
   ✅ Server started successfully!
   ==========================================
   Server running on: http://localhost:5000
   API endpoint: http://localhost:5000/recommend
   
   🎯 Frontend UI: http://localhost:5000/app
   ==========================================
   ```

### Step 3: Use the App

Open your browser and go to: **http://localhost:5000/app**

That's it! 🎉 Set your food preferences and get personalized recommendations.

## 🛑 How to Stop

- Close the SWI-Prolog window, OR
- Type `?- halt.` in the Prolog prompt

## 🏗️ Project Structure

```
food/
├── server.pl      # HTTP server
├── rules.pl       # Recommendation logic
├── food_db.pl     # Food database
├── index.html     # Frontend UI
├── script.js      # Frontend JavaScript
└── style.css      # Frontend styling
```
