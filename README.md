# Singapore Prayer Times App

A modern, responsive web application that displays daily prayer times for Singapore with both Gregorian and Hijri dates.

## Features

- **Real-time Updates**: Automatically refreshes prayer times and dates
- **Dual Calendar Display**: Shows both Gregorian and Hijri dates
- **Responsive Design**: Works on desktop, tablet, and mobile devices
- **Auto-refresh**: Updates every minute and at midnight
- **Caching**: Efficient data caching to reduce API calls
- **Error Handling**: Graceful error handling with user-friendly messages

## Recent Improvements

### Fixed Issues:

1. **Hijri Date Updates**: Now properly changes at midnight along with the Gregorian date
2. **Midnight Auto-refresh**: Prayer times automatically update when the date changes
3. **Cache Management**: Improved cache logic to prevent "No data found for today" errors
4. **Extended Date Coverage**: Added more Hijri date mappings for 2025

### New Features:

- **Auto-refresh**: Updates every minute and at midnight
- **Last Updated Indicator**: Shows when data was last refreshed
- **Manual Refresh Endpoint**: `/api/refresh` to force cache refresh
- **Health Check**: `/health` endpoint for monitoring
- **Better Error Handling**: More informative error messages

## Installation & Usage

### Prerequisites

- Ruby 2.7 or higher
- Bundler

### Setup

1. Install dependencies:
   ```bash
   bundle install
   ```

2. Start the application:
   ```bash
   bundle exec rackup
   ```

3. Open your browser and navigate to `http://localhost:9292`

### Deployment

The app is configured for deployment on platforms like Heroku with the `Procfile`:

```
web: bundle exec rackup config.ru -p $PORT
```

## API Endpoints

- `GET /` - Main application page
- `GET /api/prayer-times` - Get prayer times for today
- `GET /api/refresh` - Force refresh the cache
- `GET /health` - Health check endpoint

## Data Source

The app fetches prayer times from the Singapore government's data.gov.sg API. The data is cached locally to reduce API calls and improve performance.

## Hijri Date Calculation

The app includes a simplified Hijri date calculation for 2025. For more accurate dates, consider using a proper Hijri calendar library.

To generate more Hijri date mappings, run:

```bash
ruby generate_hijri_dates.rb
```

## Architecture

### Backend (Ruby/Sinatra)
- **app.rb**: Main application logic
- **config.ru**: Rack configuration
- **cache/**: Local data caching

### Frontend (HTML/CSS/JavaScript)
- **public/index.html**: Main interface
- **public/styles.css**: Modern, responsive styling
- Auto-refresh functionality
- Date display updates

### Key Features

1. **Smart Caching**: 
   - Caches API responses locally
   - Automatically refreshes stale data
   - Merges new data with existing cache

2. **Auto-refresh**:
   - Updates every minute
   - Special midnight refresh
   - Updates both dates and prayer times

3. **Error Handling**:
   - Graceful API failure handling
   - User-friendly error messages
   - Fallback to cached data

## Customization

### Adding More Hijri Dates

To add more accurate Hijri date mappings:

1. Run the generator script: `ruby generate_hijri_dates.rb`
2. Copy the output to the `hijriDates2025` object in `public/index.html`
3. Or integrate a proper Hijri calendar library

### Styling

The app uses modern CSS with:
- Gradient backgrounds
- Glassmorphism effects
- Responsive design
- Dark/light theme support

## Troubleshooting

### Common Issues

1. **"No data found for today"**
   - Check if the API is accessible
   - Try the `/api/refresh` endpoint
   - Verify the dataset ID is correct

2. **Hijri date not updating**
   - Ensure the date mapping includes the current date
   - Check browser console for JavaScript errors

3. **Auto-refresh not working**
   - Check browser console for errors
   - Verify JavaScript is enabled

### Debug Endpoints

- `/health` - Check application status
- `/api/refresh` - Force cache refresh

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is open source and available under the MIT License. 