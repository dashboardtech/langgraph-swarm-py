#!/bin/bash
# Verification script for Master-Langshat private repository
# Run this AFTER you've pushed to verify everything is there

set -e

echo "=========================================================================="
echo "🔍 Master-Langshat Repository Verification"
echo "=========================================================================="
echo ""

# Colors
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m'

# Check if private remote exists
echo "Checking if 'private' remote is configured..."
if git remote | grep -q "^private$"; then
    echo -e "${GREEN}✅ 'private' remote found${NC}"
    PRIVATE_URL=$(git remote get-url private)
    echo "   URL: $PRIVATE_URL"
else
    echo -e "${RED}❌ 'private' remote not found${NC}"
    echo "   Please add it first:"
    echo "   git remote add private git@github.com:dashboardtech/Master-Langshat.git"
    exit 1
fi

echo ""

# Fetch from private
echo "Fetching from private repository..."
if git fetch private 2>/dev/null; then
    echo -e "${GREEN}✅ Successfully connected to private repository${NC}"
else
    echo -e "${RED}❌ Could not fetch from private repository${NC}"
    echo "   Check your authentication (SSH keys or credentials)"
    exit 1
fi

echo ""

# Check if main branch exists
echo "Checking if 'main' branch exists on private..."
if git ls-remote --heads private | grep -q "refs/heads/main"; then
    echo -e "${GREEN}✅ 'main' branch exists on private repository${NC}"
else
    echo -e "${RED}❌ 'main' branch not found on private repository${NC}"
    echo "   You may need to push first:"
    echo "   git push private claude/fork-customization-011CUqwFUL7gU7Yhbz8bhdns:main"
    exit 1
fi

echo ""

# Check for Master Services files
echo "Checking for Master Services files..."
MASTER_SERVICES_FILES=$(git ls-tree -r private/main --name-only | grep -c "examples/master_services/" || echo "0")

if [ "$MASTER_SERVICES_FILES" -gt 0 ]; then
    echo -e "${GREEN}✅ Found $MASTER_SERVICES_FILES Master Services files${NC}"
else
    echo -e "${RED}❌ No Master Services files found${NC}"
    echo "   The push may not have completed successfully"
    exit 1
fi

echo ""

# Check for specific critical files
echo "Verifying critical files exist..."

CRITICAL_FILES=(
    "examples/master_services/src/data/company_data.py"
    "examples/master_services/src/agents/company_simulation.py"
    "examples/master_services/run_simulation.py"
    "examples/master_services/README.md"
    "MASTER_SERVICES_SUMMARY.md"
)

ALL_FOUND=true

for file in "${CRITICAL_FILES[@]}"; do
    if git ls-tree -r private/main --name-only | grep -q "^$file$"; then
        echo -e "${GREEN}✅${NC} $file"
    else
        echo -e "${RED}❌${NC} $file"
        ALL_FOUND=false
    fi
done

echo ""

if [ "$ALL_FOUND" = true ]; then
    echo -e "${GREEN}✅ All critical files verified!${NC}"
else
    echo -e "${RED}⚠️  Some critical files are missing${NC}"
    echo "   The push may have been incomplete"
fi

echo ""

# Count commits
echo "Checking commit history..."
COMMIT_COUNT=$(git rev-list --count private/main 2>/dev/null || echo "0")
echo "   Total commits on main: $COMMIT_COUNT"

# Check for Master Services commits
MASTER_COMMITS=$(git log private/main --oneline | grep -c "Master Services" || echo "0")
if [ "$MASTER_COMMITS" -gt 0 ]; then
    echo -e "${GREEN}✅ Found $MASTER_COMMITS Master Services commits${NC}"
    echo ""
    echo "Recent commits:"
    git log private/main --oneline -n 5
else
    echo -e "${YELLOW}⚠️  No commits mentioning 'Master Services' found${NC}"
fi

echo ""

# Final summary
echo "=========================================================================="
echo "📊 Verification Summary"
echo "=========================================================================="
echo ""

if git ls-tree -r private/main --name-only | grep -q "examples/master_services/src/data/company_data.py"; then
    echo -e "${GREEN}✅ Repository Status: READY${NC}"
    echo ""
    echo "Your Master Services simulation has been successfully pushed!"
    echo ""
    echo "Next steps:"
    echo "  1. Visit: https://github.com/dashboardtech/Master-Langshat"
    echo "  2. Verify the 🔒 PRIVATE badge is visible"
    echo "  3. Clone a fresh copy:"
    echo "     git clone git@github.com:dashboardtech/Master-Langshat.git"
    echo "  4. Test the simulation:"
    echo "     cd Master-Langshat"
    echo "     pip install -e . && pip install langchain-openai"
    echo "     python examples/master_services/run_simulation.py"
    echo ""
else
    echo -e "${RED}❌ Repository Status: INCOMPLETE${NC}"
    echo ""
    echo "The Master Services files don't appear to be in the repository."
    echo "Please try pushing again:"
    echo "  git push private claude/fork-customization-011CUqwFUL7gU7Yhbz8bhdns:main"
    echo ""
fi

echo "=========================================================================="
