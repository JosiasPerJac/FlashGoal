# ⚽️ FlashGoal
FlashGoal integrates the Sportmonks API to deliver real-time football scores, league standings, and player statistics in a clean, native iOS interface. The app provides a comprehensive view of the season, allowing users to track live match statuses, analyze league tables, and search for specific player details.

The app focuses on responsiveness and complex data presentation, utilizing modern list rendering and search capabilities to handle large datasets efficiently.

# Technologies Used
* SwiftUI
* `async / await` (Modern Concurrency)
* Combine (for Search Debouncing)
* MVVM Architecture
* Sportmonks API (REST)
* `AsyncImage` (Optimized Image Loading)
* DocC (Code Documentation)
* Git & GitHub

# 📱 App Demo

https://github.com/user-attachments/assets/eb47601d-4bc3-49b6-8601-7a54641e1058

# 📸 Screenshots

<p align="center">
  <img width="180" alt="Screen 1" src="https://github.com/user-attachments/assets/bc7fb858-55f7-4061-825b-0543b2e573f8">
  <img width="180" alt="Screen 2" src="https://github.com/user-attachments/assets/043b9bfd-c5c9-4adb-958a-a1abd73cfa10">
  <img width="180" alt="Screen 3" src="https://github.com/user-attachments/assets/ea8433c5-d599-49a9-aa8a-fde09bacdcc1">
  <img width="180" alt="Screen 4" src="https://github.com/user-attachments/assets/6f9ef1b7-e50c-4a36-9388-daa7c1dac0c9">
  <img width="180" alt="Screen 5" src="https://github.com/user-attachments/assets/b3ace2ac-a169-4f6e-8dff-3b480b16c287">
  <img width="180" alt="Screen 6" src="https://github.com/user-attachments/assets/e18df162-a402-4663-b100-df340ceb429f">
  <img width="180" alt="Screen 7" src="https://github.com/user-attachments/assets/0ae18b0e-aa66-45b3-ab19-f4671542ff76">
</p>

# I'm Most Proud Of...
The efficient Search Throttling (Debouncing) mechanism in the `PlayerSearchViewModel`.

Querying the Sportmonks API for players is an expensive network operation. If the app requested data on every single keystroke, it would rapidly hit API rate limits and degrade performance, causing "flickering" results.

To solve this, I implemented a robust cancellation and delay logic:

As the user types, any existing search task is immediately cancelled.

The app introduces a calculated delay (0.5 seconds).

If the user keeps typing, the timer resets.

Only when the user stops typing does the network request fire.

This ensures that we only send a request when the user has expressed a clear intent, saving data and providing a smoother UI.

Here's the code:

```swift
    @MainActor
    func searchPlayers(query: String) {
        // 1. Cancel the previous task if it's still running
        searchTask?.cancel()
        
        guard query.count > 2 else {
            self.players = []
            return
        }

        // 2. Create a new task for the new query
        searchTask = Task {
            do {
                // 3. Debounce: Sleep for 500ms to wait for typing to stop
                try await Task.sleep(nanoseconds: 500_000_000)
                
                // 4. Check for cancellation before network call
                try Task.checkCancellation()
                
                isLoading = true
                
                let results = try await service.searchPlayer(name: query)
                
                // 5. Check cancellation again before updating UI
                try Task.checkCancellation()
                
                self.players = results
                isLoading = false
                
            } catch {
                // Ignore cancellation errors, handle network errors
                if !(error is CancellationError) {
                    print("Search error: \(error.localizedDescription)")
                    self.errorMessage = "Could not find player."
                    isLoading = false
                }
            }
        }
    }
```
<br>
</br>

# Completeness
Although it's a simple portfolio project, I've implemented the following
* Defensive Coding
* Adaptive Layouts
* Empty States
* Code documentation (DocC)
* Modular Design
