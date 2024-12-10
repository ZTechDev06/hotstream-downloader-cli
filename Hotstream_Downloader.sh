#!/bin/bash
# ---------------------------------------------
# Hotstream Downloader CLI
# Author: Nathan
# Date: 30/09/2024
# Description: A simple Bash script for downloading series and movies from hotstream.at.
# ---------------------------------------------

show_help() {
  echo "Usage: $0 <fileName> <ID> [<season_number>] [<episode_number>] | [<episode_number> | -<end_episode>] -f"
  
  echo""
  echo "Options:"
  echo ""
  echo "  fileName         : Nom de la série ou du film."
  echo "  ID               : Numéro de la série ou du film souhaité."
  echo "  season_number    : Numéro de la saison souhaité."
  echo "  episode_number   : Numéro de l'épisode souhaité."
  echo "  start_episode    : Numéro de l'épisode de départ souhaité."
  echo "  end_episode      : Numéro de l'épisode de fin souhaité."
  echo ""
  echo "  -f              Option f permet de forcer une saison ou une série complete"
  echo ""
  
  echo "Exemples:"
  echo ""
  echo "Téléchargement d'un film:"
  echo "./Hotstream_Downloader.sh "Alien" 1234"
  echo""
  echo "Téléchargement de l'épisode 10 de la saison 1 d'une série:"
  echo "./Hotstream_Downloader.sh "X-Files" 51 1 10"
  echo""
  echo "Téléchargement des épisodes 3 à 6 de la saison 1 d'une série:"
  echo "./Hotstream_Downloader.sh "X-Files" 51 3 3-6"
  echo""
  echo "Téléchargement du premier épisodes jusqu'a l'épisode 6 de la saison 8 d'une série:"
  echo "./Hotstream_Downloader.sh "X-Files" 51 8 -6"
  echo""
  echo "Téléchargement de la saison 2 au complet d'une série:"
  echo "./Hotstream_Downloader.sh "X-Files" 51 2 -f"
  echo""
  echo "Téléchargement de la série complète:"
  echo "./Hotstream_Downloader.sh <fileName> <ID> -f"
  echo""
}

handle_exit() {
  echo -e "\n⚠️ - Téléchargement interrompu. Suppression des fichiers incomplet."
  rm -f "$filename"
  exit 1
}

trap 'handle_exit' SIGINT

set_user_agent() {
  user_agent="Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/17.5 Safari/605.1.15"
  echo "$user_agent"
}

create_directory() {
  local path=$1
  local folder_name=$2

  local full_path="${path}/${folder_name}"

  if [ ! -d "$full_path" ]; then
    mkdir -p "$full_path"
    echo "✅ - Dossier créé : $full_path"
  else
    echo "ℹ️ - Le dossier existe déjà : $full_path"
  fi
}

download_file() {
  local url=$1
  local filename=$2
  local user_agent=$3

  wget --user-agent="$user_agent" "$url" -O "$filename" --show-progress

  if [ $? -eq 0 ]; then
    echo "✅ - Le téléchargement du fichier $filename a réussi"
    return 0
  else
    echo "❌ - Le téléchargement du fichier $filename a échoué (404 ou autre)."
    rm -f "$filename"
    return 1 #0
  fi
}

download_film() {
  local id=$1
  local user_agent=$2
  local film_url="$hotstreamURL${id}/play/1.mp4"
  
  echo "Téléchargement du film $filename"
  
  download_file "$film_url" "${filename}.mp4" "$user_agent"
}

format_season_episode() {
  local season=$(printf "%02d" $1)
  local episode=$(printf "%02d" $2)
  echo "S${season}E${episode}"
}

download_episode() {
  local id=$1
  local season=$2
  local episode_number=$3
  local user_agent=$4
  local serie_url="$hotstreamURL${id}/play/seasons/${season}/${episode_number}.mp4"
  local filename_formatted=$(format_season_episode $season $episode_number)
  local filepath="./$filename/Saison $season/${filename} ${filename_formatted}.mp4"
  
  create_directory "./$filename" "Saison $season"

  echo "Téléchargement de l'épisode $episode_number de la saison $season de la série $filename"
  
  download_file "$serie_url" "$filepath" "$user_agent"
}

try_download_as_film_then_serie() {
  local id=$1
  local user_agent=$2
  
  echo "👀 - Tentative de téléchargement du film $id"
  if download_film "$id" "$user_agent"; then
    echo "✅ - Le film a été téléchargé avec succès."
  else
    echo "❌ - Tentative échouée pour le film"
    echo "👀 - Tentative de téléchargement de l'épisode $episode_number de la saison $season de la série $id"
    download_episode "$id" 1 1 "$user_agent"
  fi
}

download_episode_range() {
  local id=$1
  local season=$2
  local start=$3
  local end=$4
  local user_agent=$5

  for ((episode=start; episode<=end; episode++)); do
    download_episode "$id" "$season" "$episode" "$user_agent"
  done
}

download_season() {
  local id=$1
  local season=$2
  local user_agent=$3
  local episode=1
  
  local number_of_errors=0
  local max_errors=2

  echo "🚀-  Téléchargement de tous les épisodes de la saison $season de la série $id"

  while true; do
    echo "🔄 - Téléchargement de l'épisode $episode."

    download_episode "$id" "$season" "$episode" "$user_agent"

    if [ $? -ne 0 ]; then
      echo "❌ - Téléchargement de l'épisode $episode échoué ou aucun épisode supplémentaire trouvé."
      ((number_of_errors++))

      if [ "$number_of_errors" -ge "$max_errors" ]; then
        echo "⚠️ - Nombre maximum d'erreurs atteint. Arrêt du téléchargement de la saison."
        return 1
      fi
    else
      number_of_errors=0
    fi

    ((episode++))
  done

  echo "✅ - Téléchargement terminé pour la saison $season de la série $id."
  return 0
}

download_seasons() {
  local id=$1
  local user_agent=$2
  local season=1

  local number_of_errors=0
  local max_errors=2
  
  echo "🚀-  Téléchargement de complet de la série $id"
  
  while true; do
    echo "Téléchargement de la saison $season."
    download_season "$id" "$season" "$user_agent"

    if [ $? -ne 0 ]; then
      echo "❌ - Échec du téléchargement de la saison $season. Arrêt du téléchargement."
      ((number_of_errors++))

      if [ "$number_of_errors" -ge "$max_errors" ]; then
        echo "⚠️ - Nombre maximum d'erreurs atteint. Arrêt du téléchargement de la série."
        return 1
    fi
    else
      number_of_errors=0
    fi
    
    ((season++))
  done
  
  echo "✅ - Téléchargement terminé pour les saisons de la série $id."
  return 0
}

main() {
  local filename=$1
  local id=$2
  local season=$3
  local episode_range=$4

  if [[ "$#" -lt 2 || "$#" -gt 4 ]]; then
   echo "Erreur : Pas assez d'arguments."
   show_help
   exit 1
  fi

  if [[ "$1" == "--h" || "$1" == "-h" || "$1" == "--helper" ]]; then
    show_help
    exit 0
  fi

  local user_agent
  user_agent=$(set_user_agent)
    
  if [ -z "$season" ]; then
    try_download_as_film_then_serie "$id" "$user_agent"
  else
    create_directory "." "$filename"
    if [[ "$season" == "-f" ]]; then
        download_seasons "$id" "$user_agent"
    
    elif [ -z "$episode_range" ]; then
        download_episode "$id" "$season" 1 "$user_agent"

    elif [[ "$episode_range" =~ ^[0-9]+$ ]]; then
        local episode_number=$episode_range
        download_episode "$id" "$season" "$episode_number" "$user_agent"

    elif [[ "$episode_range" =~ ^-[0-9]+$ ]]; then
        local end_episode=${episode_range#-}
        download_episode_range "$id" "$season" 1 "$end_episode" "$user_agent"

    elif [[ "$episode_range" =~ ^[0-9]+-[0-9]+$ ]]; then
        IFS='-' read -r start_episode end_episode <<< "$episode_range"
        download_episode_range "$id" "$season" "$start_episode" "$end_episode" "$user_agent"

    elif [[ "$episode_range" == "-f" ]]; then
        download_season "$id" "$season" "$user_agent"
    else
        echo "Erreur : Argument invalide."
        show_help
        exit 1
    fi
  fi
}

hotstreamURL="https://cdn.hotstream.at/"

main "$@"
