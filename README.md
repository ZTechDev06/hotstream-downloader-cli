# Hotstream Downloader CLI
Hotstream Downloader CLI is a (hopefully) simple powershell script for easily downloading series and films from hotstream.at

Many thanks to https://github.com/Nathan765/hotstream-downloader-cli

Movie Downloads: Fetch movies effortlessly by providing their unique ID.
Series Downloads: Download specific episodes, entire seasons, or complete series.
Interactive CLI: Step-by-step prompts ensure a smooth user experience.
Automatic Folder Organization: Downloads are neatly organized into folders by series and season.
Error Handling: Retries downloads or stops after encountering too many failures

#Prerequisites
Windows with PowerShell 5.1 or later.
Internet access.

##Installation

Clone the repository
git clone https://github.com/ZTechDev06/hotstream-downloader-cli.git  


### Examples
Download the movie Alien with ID 1234:
Enter your choice (1 or 2): 1  
Enter the movie name: Inception  
Enter the movie ID: 1234  
✅ - Download succeeded: .\Inception.mp4  

Download episode 10 of season 1 of the series X-Files with ID 51:
Enter your choice (1 or 2): 2  
Enter the series name: X-Files  
Enter the series ID: 5678  
Enter the season number: 1  
Enter the episode range (e.g., '1', '1-3', '-f'): 1-5  
🚀 - Downloading episodes 1 to 5 of season 1 for X-Files...  


# Contributions
Contributions are welcome! If you want to improve this script or add new features, feel free to submit a Pull Request or open an issue.

# License
This project is licensed under the MIT License. See the LICENSE file for details.



# 🚨 Disclaimer 🚨
This script is provided for demonstration purposes only and is intended solely for personal learning and entertainment. It is not meant for commercial use, promotion, or distribution of any copyrighted material. The author assumes no responsibility for how this script is used.

If requested, I will remove the script immediately to comply with any legal or ethical concerns.
