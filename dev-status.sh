#!/bin/bash

# Ravali ERP - Development Status Script
# Shows current development status and git information

set -e

# Colors for output
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

echo -e "${BLUE}🏢 Ravali ERP Ecosystem - Development Status${NC}"
echo -e "${BLUE}===========================================${NC}\n"

# Navigate to project root
cd "$(dirname "$0")"

# Git Information
echo -e "${GREEN}📊 Git Repository Status:${NC}"
echo -e "  Current Branch: $(git branch --show-current)"
echo -e "  Total Commits: $(git rev-list --count HEAD)"
echo -e "  Last Commit: $(git log -1 --format='%h - %s (%cr)')"
echo ""

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${YELLOW}⚠️  Uncommitted Changes Detected:${NC}"
    git status --short
    echo ""
    echo -e "${YELLOW}💡 Run './track-changes.sh' to commit these changes${NC}"
else
    echo -e "${GREEN}✅ Working tree is clean${NC}"
fi
echo ""

# Show recent activity
echo -e "${CYAN}📝 Recent Development Activity:${NC}"
git log --oneline -10
echo ""

# Project structure overview
echo -e "${CYAN}🏗️  Project Structure:${NC}"
echo -e "  📱 Customer App: $(find customer_app -name "*.dart" | wc -l) Dart files"
echo -e "  🖥️  ERP Admin Panel: $(find erp_admin_panel -name "*.dart" | wc -l) Dart files"
echo -e "  🤝 Supplier App: $(find supplier_app -name "*.dart" | wc -l) Dart files"
echo -e "  📦 Shared Package: $(find shared_package -name "*.dart" | wc -l) Dart files"
echo -e "  📚 Documentation: $(find . -name "*.md" | wc -l) MD files"
echo ""

# Show total lines of code
total_dart=$(find . -name "*.dart" -not -path "./.dart_tool/*" -not -path "./*/build/*" | xargs wc -l 2>/dev/null | tail -1 | awk '{print $1}' || echo "0")
echo -e "${CYAN}📏 Total Lines of Dart Code: ${total_dart}${NC}"
echo ""

# Git repository size
repo_size=$(du -sh .git 2>/dev/null | cut -f1 || echo "Unknown")
echo -e "${CYAN}💾 Repository Size: ${repo_size}${NC}"

echo -e "\n${BLUE}===========================================${NC}"
echo -e "${GREEN}💡 Use './track-changes.sh' to commit any changes${NC}"
echo -e "${GREEN}💡 All development changes are being tracked automatically${NC}"
