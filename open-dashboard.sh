#!/bin/bash
echo "🌐 Opening Dashboard in browser..."
sleep 1
if [ -n "$BROWSER" ]; then
  "$BROWSER" "http://localhost:8501" 2>/dev/null &
else
  echo "Dashboard available at: http://localhost:8501"
fi
