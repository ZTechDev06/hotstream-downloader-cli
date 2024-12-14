# ---------------------------------------------
# Hotstream Downloader CLI (Windows - PowerShell Version)
# Author: Nathan
# Date: 30/09/2024
# Description: A simple PowerShell script for downloading series and movies from hotstream.at.
# ---------------------------------------------

function Show-Help {
    Write-Host "Usage: .\HotstreamDownloader.ps1" -ForegroundColor Yellow
    Write-Host "\nOptions:\n"
    Write-Host "  1 : Download a Movie" -ForegroundColor Cyan
    Write-Host "  2 : Download a Series" -ForegroundColor Cyan
    exit
}

function Download-File {
    param (
        [string]$url,
        [string]$outputPath
    )

    try {
        Invoke-WebRequest -Uri $url -OutFile $outputPath -UseBasicParsing
        Write-Host "✅ - Download succeeded: $outputPath" -ForegroundColor Green
    } catch {
        Write-Host "❌ - Download failed: $outputPath" -ForegroundColor Red
        if (Test-Path $outputPath) { Remove-Item $outputPath }
        return $false
    }
    return $true
}

function Create-Directory {
    param (
        [string]$path
    )

    if (-Not (Test-Path $path)) {
        New-Item -ItemType Directory -Path $path | Out-Null
        Write-Host "✅ - Directory created: $path" -ForegroundColor Green
    } else {
        Write-Host "ℹ️ - Directory already exists: $path" -ForegroundColor Yellow
    }
}

function Format-SeasonEpisode {
    param (
        [int]$season,
        [int]$episode
    )

    return "S$("{0:D2}" -f $season)E$("{0:D2}" -f $episode)"
}

function Download-Episode {
    param (
        [string]$baseUrl,
        [string]$fileName,
        [int]$season,
        [int]$episode
    )

    $formatted = Format-SeasonEpisode -season $season -episode $episode
    $url = "$baseUrl/$ID/play/seasons/$season/$episode.mp4"
    $outputPath = ".\$fileName\Season $season\$fileName $formatted.mp4"

    Create-Directory -path ".\$fileName\Season $season"
    Download-File -url $url -outputPath $outputPath
}

function Download-Season {
    param (
        [string]$baseUrl,
        [string]$fileName,
        [int]$season
    )

    Write-Host "🚀 - Downloading all episodes of season $season for $fileName..." -ForegroundColor Cyan
    $episode = 1
    $errorCount = 0
    $maxErrors = 2

    while ($errorCount -lt $maxErrors) {
        if (-Not (Download-Episode -baseUrl $baseUrl -fileName $fileName -season $season -episode $episode)) {
            $errorCount++
        } else {
            $errorCount = 0
        }
        $episode++
    }

    Write-Host "⚠️ - Stopping season download after $errorCount errors." -ForegroundColor Yellow
}

function Main {
    Write-Host "Welcome to Hotstream Downloader!" -ForegroundColor Cyan
    Write-Host "Please select an option:" -ForegroundColor Cyan
    Write-Host "  1. Download a Movie" -ForegroundColor Yellow
    Write-Host "  2. Download a Series" -ForegroundColor Yellow

    $choice = Read-Host "Enter your choice (1 or 2)"

    if ($choice -eq "1") {
        $fileName = Read-Host "Enter the movie name"
        $ID = Read-Host "Enter the movie ID"

        $baseUrl = "https://cdn.hotstream.at"
        $movieUrl = "$baseUrl/$ID/play/1.mp4"
        $outputPath = ".\$fileName.mp4"

        if (-Not (Download-File -url $movieUrl -outputPath $outputPath)) {
            Write-Host "❌ - Movie download failed. Exiting." -ForegroundColor Red
            exit
        }

    } elseif ($choice -eq "2") {
        $fileName = Read-Host "Enter the series name"
        $ID = Read-Host "Enter the series ID"
        $season = Read-Host "Enter the season number"
        $episodeRange = Read-Host "Enter the episode range (e.g., '1', '1-3', '-f')"

        $baseUrl = "https://cdn.hotstream.at"

        if ($episodeRange -eq "-f") {
            Write-Host "🚀 - Downloading complete series for $fileName..." -ForegroundColor Cyan
            $currentSeason = 1
            while ($true) {
                if (-Not (Download-Season -baseUrl $baseUrl -fileName $fileName -season $currentSeason)) {
                    break
                }
                $currentSeason++
            }
        } elseif ($episodeRange -match "^\d+-\d+$") {
            $range = $episodeRange -split "-"
            for ($i = $range[0]; $i -le $range[1]; $i++) {
                Download-Episode -baseUrl $baseUrl -fileName $fileName -season $season -episode $i
            }
        } elseif ($episodeRange -match "^-\d+$") {
            for ($i = 1; $i -le [int]$episodeRange.Trim('-') ; $i++) {
                Download-Episode -baseUrl $baseUrl -fileName $fileName -season $season -episode $i
            }
        } else {
            Download-Episode -baseUrl $baseUrl -fileName $fileName -season $season -episode [int]$episodeRange
        }

    } else {
        Write-Host "Invalid choice. Exiting." -ForegroundColor Red
        exit
    }

    # Prevent the window from closing immediately
    Read-Host "Press Enter to exit"
}

Main
