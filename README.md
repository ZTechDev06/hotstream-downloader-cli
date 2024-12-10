# Hotstream Downloader CLI
Hotstream Downloader CLI is a simple (hopefully) Bash script for easily downloading series and movies from hotstream.at. It uses wget to handle the downloads.

## Features
	•	Download individual movies
	•	Download specific episodes of a series
	•	Download entire seasons
	•	Download complete series
	•	Support for episode ranges

## Installation
Make the script executable:

```bash
chmod +x download_series.sh
```

## Usage
The general command structure is:

```bash
./download_series.sh <fileName> <ID> [<season_number>] [<episode_number>] | [<episode_number> | -<end_episode>] -f
```

### Examples
Download the movie Alien with ID 1234:
```bash
./download_series.sh "Alien" 1234
```

Download episode 10 of season 1 of the series X-Files with ID 51:
```bash
./download_series.sh "X-Files" 51 1 10
```

Download episodes 8 to 11 of season 3 of the series X-Files with ID 51:
```bash
./download_series.sh "X-Files" 51 3 8-11
```

Download all episodes of season 2 of the series X-Files with ID 51:
```bash
./download_series.sh "X-Files" 51 2 -f
```

Download all episodes of the series X-Files with ID 51:
```bash
./download_series.sh "X-Files" 51 -f
```

# Contributions
Contributions are welcome! If you want to improve this script or add new features, feel free to submit a Pull Request or open an issue.

# License
This project is licensed under the MIT License. See the LICENSE file for details.
