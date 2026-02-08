#!/bin/zsh

# Usage: ./multi_backup.sh /source/path -d /dest1 -d /dest2

# Initialize variables
SOURCE=""
DESTINATIONS=()

# Parse arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    -d|--dest)
      DESTINATIONS+=("$2")
      shift 2
      ;;
    *)
      if [[ -z "$SOURCE" ]]; then
        SOURCE="$1"
        shift
      else
        echo "Unknown argument: $1"
        exit 1
      fi
      ;;
  esac
done

# Validation
if [[ -z "$SOURCE" ]]; then
    echo "Error: Source directory is required."
    echo "Usage: $0 /source/path -d /dest1 [-d /dest2 ...]"
    exit 1
fi

if [[ ${#DESTINATIONS[@]} -eq 0 ]]; then
    echo "Error: At least one destination (-d) is required."
    exit 1
fi

# Rclone execution
for DEST in "${DESTINATIONS[@]}"; do
    echo "----------------------------------------------------------"
    echo "Starting backup: $SOURCE -> $DEST"
    echo "Start time: $(date)"
    echo "----------------------------------------------------------"

    rclone copy "$SOURCE" "$DEST" \
        --progress \
        --transfers 4 \
        --checkers 8 \
        --buffer-size 128M \
        --multi-thread-streams 4 \
        --size-only \
        --low-level-retries 10 \
        --stats 10s \
        --inplace \
	--local-encoding "Slash,Dot,Ctl,InvalidUtf8,LtGt,Pipe,BackSlash,Question,Colon,Asterisk" \
        --exclude "**.lrdata/**" \
        --exclude "**.DS_Store" \
        --ignore-errors

    echo "Finished backup to $DEST at $(date)"
done

echo "All backup tasks completed."

