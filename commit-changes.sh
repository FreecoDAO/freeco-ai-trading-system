#!/bin/bash

echo "📝 FreEco AI Trading Bot - Git Commit Helper"
echo "==========================================="
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Step 1: Configure Git
echo -e "${BLUE}Step 1: Configuring Git...${NC}"
git config --global --add safe.directory /workspaces/freeco-ai-trading-system 2>/dev/null || true
echo -e "${GREEN}✓ Git configured${NC}"
echo ""

# Step 2: Check status
echo -e "${BLUE}Step 2: Checking Git status...${NC}"
git status
echo ""

# Step 3: Show what will be committed
echo -e "${BLUE}Step 3: Files to be committed:${NC}"
git diff --cached --name-only || echo "No staged changes"
echo ""

# Step 4: Confirm commit
echo -e "${YELLOW}Ready to commit? (y/n)${NC}"
read -r CONFIRM

if [ "$CONFIRM" != "y" ]; then
  echo "Commit cancelled"
  exit 0
fi

# Step 5: Create commit
echo ""
echo -e "${BLUE}Step 5: Creating commit...${NC}"
git commit -m "feat: Replace Streamlit with HTTP dashboard, fix devcontainer config

- Replace Streamlit with lightweight Python HTTP server (no auth required)
- Fix devcontainer.json schema errors (extensions, settings → customizations/vscode)
- Add comprehensive setup and diagnostic scripts:
  * master-setup.sh: Automated setup with step-by-step verification
  * quickstart.sh: One-command quick start
  * force-restart.sh: Force restart all services
  * diagnose.sh: System diagnostics
  * verify-step2.sh: Automated verification
  * check-status.sh: Status checker
- Improve start-all.sh and stop-all.sh for Alpine Linux compatibility
- Remove Streamlit from dependencies
- Update DEPLOYMENT_GUIDE.md with troubleshooting and recovery steps"

if [ $? -eq 0 ]; then
  echo -e "${GREEN}✓ Commit created successfully${NC}"
  echo ""
  
  # Step 6: Show commit
  echo -e "${BLUE}Step 6: Commit details:${NC}"
  git log --oneline -1
  echo ""
  
  # Step 7: Push confirmation
  echo -e "${YELLOW}Push to GitHub now? (y/n)${NC}"
  read -r PUSH_CONFIRM
  
  if [ "$PUSH_CONFIRM" = "y" ]; then
    echo ""
    echo -e "${BLUE}Pushing to GitHub...${NC}"
    git push origin main
    
    if [ $? -eq 0 ]; then
      echo -e "${GREEN}✓ Successfully pushed to GitHub!${NC}"
      echo ""
      echo "🎉 All done! Your changes are now in the FreecoDAO repository."
    else
      echo -e "${YELLOW}⚠ Push failed. Try manually:${NC}"
      echo "  git push origin main"
    fi
  else
    echo ""
    echo -e "${YELLOW}To push later, run:${NC}"
    echo "  git push origin main"
  fi
else
  echo -e "${RED}✗ Commit failed${NC}"
  exit 1
fi
