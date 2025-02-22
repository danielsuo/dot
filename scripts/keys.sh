#!/bin/bash

#!/bin/bash

# Set terminal to raw mode to capture each key press
stty raw -echo

echo "Press keys, press Ctrl+C to exit..."

while true; do
  # Read a single character
  char=$(dd bs=1 count=1 2>/dev/null)

  # Check for Ctrl+C (ASCII code 3)
  if [[ $char == $'\x03' ]]; then
    echo
    echo "Exiting..."
    break
  fi

  # Print the character (or its hex representation if not printable)
  printf "Key pressed: "
  case "$char" in
    [$' \t\r\n']) # Handle whitespace characters
      printf "'%q'\n" "$char"
      ;;
    * )
      printf "'%s' (0x%02x)\n" "$char" "$(printf '%d' "'$char")"
      ;;
  esac
done

# Restore terminal settings
stty -raw echo
