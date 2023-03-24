#!/bin/bash
echo "Enter the day for the commit (e.g., 'Mon', 'Tue', 'Wed', etc.):"
read day
git add FIFA2022_analysis.sas
git commit -m "fixed some issues" --date="$day 14:00 2023 +0100" --no-edit
git push

echo "Git operations completed successfully."
