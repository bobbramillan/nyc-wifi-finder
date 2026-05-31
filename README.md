# NYC WiFi Finder

An iOS app to discover free public WiFi hotspots across New York City, with personalized recommendations powered by vector similarity search.

## What it does

- Browse 500+ NYC public WiFi spots on an interactive map
- Filter by borough and neighborhood
- Get personalized "For You" recommendations based on your bookmarks
- Save spots to bookmarks, synced to the cloud

## How the recommendations work

When you bookmark spots, the app builds a taste profile by averaging the vector embeddings of those spots. It then finds the most similar unbookmarked spots in MongoDB using cosine similarity. Embeddings are generated via Voyage AI's `voyage-3-lite` model — each spot is converted to a text description and embedded into a 1024-dimension vector at seed time.

This means recommendations improve the more you bookmark, without any login or account required. Each device gets a unique ID via `UIDevice.identifierForVendor`.

## Tech stack

**iOS**
- Swift & SwiftUI
- MapKit + CoreLocation
- URLSession for REST API calls
- Combine + `@Published` for reactive state

**Backend**
- Node.js + Express
- MongoDB + Mongoose (bookmarks + WiFi spot embeddings)
- Voyage AI (vector embeddings)
- NYC Open Data API (WiFi hotspot data)

→ [Backend repository](https://github.com/bobbramillan/nyc-wifi-finder-backend)

## Running it locally

> **Note:** This app requires the backend to be running locally to load WiFi spots and recommendations. Start the backend first before running the iOS app. See the [backend repository](https://github.com/bobbramillan/nyc-wifi-finder-backend) for setup instructions.

### Backend

You'll need Node.js and a free MongoDB Atlas account and Voyage AI API key.

```bash
cd nyc-wifi-finder-backend
npm install
```

Create a `.env` file:

```
PORT=3000
NYC_WIFI_API=https://data.cityofnewyork.us/resource/yjub-udmw.json
MONGODB_URI=your_mongodb_connection_string
VOYAGE_API_KEY=your_voyage_api_key
```

```bash
npm run dev
```

On first run, the server will automatically seed all 500 WiFi spots with embeddings into MongoDB. This takes around 30 minutes due to Voyage AI's free tier rate limit (3 requests/min). It only runs once — subsequent starts skip seeding.

### iOS app

- Xcode 16+ and iOS 17+
- Open `NYCWiFiFinder.xcodeproj`
- Set your Apple ID under Signing & Capabilities
- Make sure the backend is running locally
- Select an iPhone simulator and hit Run

## API endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/api/wifi` | All 500 NYC WiFi spots |
| GET | `/api/wifi/:id` | Single spot by ID |
| GET | `/api/bookmarks?userID=x` | Get bookmarks for a device |
| POST | `/api/bookmarks` | Save a bookmark |
| DELETE | `/api/bookmarks/:id?userID=x` | Remove a bookmark |
| POST | `/api/recommendations` | Get personalized recommendations |

## Data source

[NYC Open Data — WiFi Hotspot Locations](https://data.cityofnewyork.us/City-Government/NYC-Wi-Fi-Hotspot-Locations/yjub-udmw/about_data)

## Author

Bavanan Bramillan · [GitHub](https://github.com/bobbramillan)

## License

MIT
