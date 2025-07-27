#!/bin/bash

# Ravali ERP - Automated Git Tracking Script
# This script helps ensure all development changes are captured

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${GREEN}🔍 Ravali ERP - Checking for changes...${NC}"

# Navigate to project root
cd "$(dirname "$0")"

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}❌ Not a git repository${NC}"
    exit 1
fi

# Check for changes (including untracked files)
if git diff-index --quiet HEAD -- && [ -z "$(git ls-files --others --exclude-standard)" ]; then
    echo -e "${GREEN}✅ No changes detected${NC}"
    exit 0
fi

echo -e "${YELLOW}📝 Changes detected! Preparing to track...${NC}"

# Show status
echo -e "\n${YELLOW}Current status:${NC}"
git status --short

# Show detailed changes
echo -e "\n${YELLOW}Detailed changes:${NC}"
git diff --stat

# Ask for commit message or provide default
echo -e "\n${YELLOW}Enter commit message (or press Enter for auto-generated):${NC}"
read -r commit_msg

# Generate automatic commit message if none provided
if [ -z "$commit_msg" ]; then
    # Get current timestamp
    timestamp=$(date "+%Y-%m-%d %H:%M:%S")
    
    # Count changes
    added=$(git diff --name-only --cached --diff-filter=A | wc -l)
    modified=$(git diff --name-only --cached --diff-filter=M | wc -l)
    deleted=$(git diff --name-only --cached --diff-filter=D | wc -l)
    
    # Generate smart commit message
    commit_msg="Auto-commit: Development progress [$timestamp]"
    
    if [ "$added" -gt 0 ] || [ "$modified" -gt 0 ] || [ "$deleted" -gt 0 ]; then
        commit_msg="$commit_msg - $((added + modified + deleted)) files changed"
        [ "$added" -gt 0 ] && commit_msg="$commit_msg (+$added)"
        [ "$modified" -gt 0 ] && commit_msg="$commit_msg (~$modified)"
        [ "$deleted" -gt 0 ] && commit_msg="$commit_msg (-$deleted)"
    fi
fi

# Add all changes
echo -e "\n${YELLOW}📦 Adding all changes...${NC}"
git add .

# Commit changes
echo -e "${YELLOW}💾 Committing changes...${NC}"
git commit -m "$commit_msg"

echo -e "${GREEN}✅ Changes successfully tracked!${NC}"
echo -e "${GREEN}📊 Latest commits:${NC}"
git log --oneline -5
