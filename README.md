# PrayerTimesSG

A modern, responsive web application that displays daily prayer times for Singapore with both Gregorian and Hijri dates.

**Live Site**: [prayertimes.sg](https://prayertimes.sg)  
**Health Dashboard**: [prayertimes.sg/health](https://prayertimes.sg/health)  
**Analytics**: [Tinylytics Dashboard](https://tinylytics.app/public/BXTp9qxuuwQ3bisB6ohq)

**© 2025 PrayerTimesSG. All rights reserved.**

## ⚠️ Important Notice

This project is open source for educational and community purposes. While the code is available under the MIT License, please respect the following:

- **Brand Identity**: "PrayerTimesSG" and associated branding are protected
- **Attribution**: Any use of this code must include proper attribution
- **Commercial Use**: Contact the author for commercial licensing
- **Domain**: prayertimes.sg is a registered domain and trademark

## 🐛 Known Issues

### Hijri Date Mapping Incomplete
- **Issue**: The Islamic date display is incomplete and shows incorrect dates for most of 2025 and all future years
- **Current Coverage**: Only January 1-3, August 1-31, and December 31, 2025
- **Fallback**: All other dates show "1 Muharram 1446H" (incorrect)
- **Impact**: Users may see wrong Islamic dates, affecting app reliability
- **Status**: Planned fix - implementing proper Hijri calculation algorithm
- **GitHub Issue**: [#1](https://github.com/roqom/prayertimes.sg/issues/1)

## Features

- **🕐 Real-time Updates**: Automatically refreshes prayer times and dates
- **📅 Dual Calendar Display**: Shows both Gregorian and Hijri dates
- **📱 Responsive Design**: Works on desktop, tablet, and mobile devices
- **🔄 Auto-refresh**: Updates every minute and at midnight
- **💾 Smart Caching**: Efficient data caching to reduce API calls
- **🛡️ Error Handling**: Graceful error handling with user-friendly messages
- **🇸🇬 Singapore Timezone**: Properly configured for Singapore timezone (UTC+8)
- **📊 Health Monitoring**: Built-in health dashboard for system status
- **📈 Analytics**: Integrated analytics for usage tracking

## Recent Improvements

### Fixed Issues:

1. **Hijri Date Updates**: Now properly changes at midnight along with the Gregorian date
2. **Midnight Auto-refresh**: Prayer times automatically update when the date changes
3. **Cache Management**: Improved cache logic to prevent "No data found for today" errors
4. **Extended Date Coverage**: Added more Hijri date mappings for 2025
5. **Timezone Fix**: Fixed timezone issue causing wrong date display (now uses Singapore timezone)
6. **Design Update**: Clean, minimalist white design for better user experience

### New Features:

- **Auto-refresh**: Updates every minute and at midnight
- **Manual Refresh Endpoint**: `/api/refresh` to force cache refresh
- **Health Check**: `/health` endpoint for monitoring
- **Better Error Handling**: More informative error messages
- **Timezone Support**: Proper Singapore timezone handling
- **Minimalist Design**: Clean white interface with subtle styling

## 🚀 Quick Start

### Prerequisites

- Ruby 2.7 or higher
- Bundler

### Local Development

1. **Clone the repository:**
   ```bash
   git clone https://github.com/roqom/prayertimes.sg.git
   cd prayertimes.sg
   ```

2. **Install dependencies:**
   ```bash
   bundle install
   ```

3. **Start the application:**
   ```bash
   bundle exec rackup
   ```

4. **Open your browser:**
   Navigate to `http://localhost:9292`

### Deployment

The app is configured for deployment on platforms like Heroku with the `Procfile`:

```
web: bundle exec rackup config.ru -p $PORT
```

### Environment Variables

- `TZ=Asia/Singapore` - Set timezone (automatically configured)
- `PORT=9292` - Set port (default: 9292)

## 🔗 API Endpoints

| Endpoint | Method | Description |
|----------|--------|-------------|
| `/` | GET | Main application page |
| `/api/prayer-times` | GET | Get prayer times for today |
| `/api/refresh` | GET | Force refresh the cache (admin only) |
| `/health` | GET | Health check endpoint with detailed cache info |
| `/api/health` | GET | JSON health data (used by health page) |

## Data Source

The app fetches prayer times from the Singapore government's data.gov.sg API. The data is cached locally to reduce API calls and improve performance.

## Timezone Configuration

The app is specifically configured for Singapore timezone (UTC+8) to ensure:
- Correct date display for Singapore users
- Proper midnight updates
- Accurate Hijri date calculations
- Reliable auto-refresh functionality

## Hijri Date Calculation

The app includes a simplified Hijri date calculation for 2025. For more accurate dates, consider using a proper Hijri calendar library.

To generate more Hijri date mappings, run:

```bash
ruby generate_hijri_dates.rb
```

## Architecture

### Backend (Ruby/Sinatra)
- **app.rb**: Main application logic with timezone support
- **config.ru**: Rack configuration
- **cache/**: Local data caching with smart refresh logic

### Frontend (HTML/CSS/JavaScript)
- **public/index.html**: Main interface with auto-refresh
- **public/styles.css**: Minimalist white design
- Auto-refresh functionality
- Date display updates

### Key Features

1. **Smart Caching**: 
   - Caches API responses locally
   - Automatically refreshes stale data
   - Merges new data with existing cache
   - Timezone-aware cache management

2. **Auto-refresh**:
   - Updates every minute
   - Special midnight refresh
   - Updates both dates and prayer times
   - Singapore timezone aware

3. **Error Handling**:
   - Graceful API failure handling
   - User-friendly error messages
   - Fallback to cached data
   - Detailed error information

4. **Timezone Support**:
   - Singapore timezone (UTC+8) configuration
   - Proper date calculations
   - Midnight update handling
   - Timezone debugging information

## Design

The app features a clean, minimalist white design:
- **Pure white background** with clean typography
- **Dark gray text** for excellent readability
- **Subtle gray borders** for definition
- **Hover effects** for better user interaction
- **Responsive design** that works on all devices
- **Modern system fonts** for optimal readability

## Customization

### Adding More Hijri Dates

To add more accurate Hijri date mappings:

1. Run the generator script: `ruby generate_hijri_dates.rb`
2. Copy the output to the `hijriDates2025` object in `public/index.html`
3. Or integrate a proper Hijri calendar library

### Styling

The app uses modern CSS with:
- Clean white backgrounds
- Minimalist color scheme
- Responsive design
- Subtle shadows and borders
- Hover effects for interactivity

## Troubleshooting

### Common Issues

1. **"No data found for today"**
   - Check if the API is accessible
   - Try the `/api/refresh` endpoint
   - Verify the dataset ID is correct
   - Check timezone configuration

2. **Hijri date not updating**
   - Ensure the date mapping includes the current date
   - Check browser console for JavaScript errors
   - Verify timezone settings

3. **Auto-refresh not working**
   - Check browser console for errors
   - Verify JavaScript is enabled
   - Check timezone configuration

4. **Wrong date displayed**
   - Verify timezone is set to Singapore (UTC+8)
   - Check server timezone configuration
   - Use `/health` endpoint to debug timezone issues

### Debug Endpoints

- `/health` - Check application status and timezone
- `/api/refresh` - Force cache refresh
- `/api/prayer-times` - Get current prayer times

### Timezone Debugging

The `/health` endpoint includes timezone information:
```json
{
  "status": "ok",
  "today": "2025-08-04",
  "timezone": "Asia/Singapore",
  "timestamp": "2025-08-04T07:30:00+08:00"
}
```

## 🤝 Contributing

We welcome contributions! Here's how you can help:

### How to Contribute

1. **Fork the repository**
2. **Create a feature branch**: `git checkout -b feature/amazing-feature`
3. **Make your changes**
4. **Test thoroughly**
5. **Submit a pull request**

### What We're Looking For

- **Bug fixes** - Help improve reliability

### Code of Conduct

- Be respectful and inclusive
- Help others learn and grow
- Focus on the community benefit
- Follow existing code style

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- **data.gov.sg** - For providing the prayer times API
- **Majlis Ugama Islam Singapura (MUIS)** - For the prayer timetable
- **Berlime.com** - For inspiration and tools
- **Singapore Muslim Community** - For the motivation to build this app 