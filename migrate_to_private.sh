#!/bin/bash
# Migration Helper Script for Master Services Simulation
# This script helps you migrate to a new private repository

set -e  # Exit on any error

echo "=========================================================================="
echo "🔐 Master Services - Private Repository Migration Helper"
echo "=========================================================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Check if we're in the right directory
if [ ! -d "examples/master_services" ]; then
    echo -e "${RED}Error: examples/master_services not found!${NC}"
    echo "Please run this script from the langgraph-swarm-py directory"
    exit 1
fi

echo -e "${GREEN}✅ Verified: Master Services directory found${NC}"
echo ""

# Get the new repository URL from user
echo "=========================================================================="
echo "Step 1: Enter Your New Private Repository URL"
echo "=========================================================================="
echo ""
echo "First, create a new PRIVATE repository on GitHub:"
echo "  1. Go to: https://github.com/new"
echo "  2. Name it something like: master-services-simulation"
echo "  3. Make it PRIVATE ⭐"
echo "  4. Do NOT initialize with README, .gitignore, or license"
echo "  5. Click 'Create Repository'"
echo ""
echo "Then copy the repository URL from GitHub."
echo ""
echo "Example URLs:"
echo "  SSH:   git@github.com:dashboardtech/master-services-simulation.git"
echo "  HTTPS: https://github.com/dashboardtech/master-services-simulation.git"
echo ""
read -p "Enter your new repository URL: " NEW_REPO_URL

if [ -z "$NEW_REPO_URL" ]; then
    echo -e "${RED}Error: No URL provided${NC}"
    exit 1
fi

echo ""
echo -e "${YELLOW}New repository URL: $NEW_REPO_URL${NC}"
echo ""
read -p "Is this correct? (yes/no): " CONFIRM

if [ "$CONFIRM" != "yes" ] && [ "$CONFIRM" != "y" ]; then
    echo "Cancelled."
    exit 0
fi

echo ""
echo "=========================================================================="
echo "Step 2: Adding New Repository as Remote"
echo "=========================================================================="
echo ""

# Check if 'private' remote already exists
if git remote | grep -q "^private$"; then
    echo -e "${YELLOW}Remote 'private' already exists. Removing...${NC}"
    git remote remove private
fi

# Add the new remote
echo "Adding remote 'private'..."
git remote add private "$NEW_REPO_URL"

echo -e "${GREEN}✅ Remote added successfully${NC}"
echo ""

# Show remotes
echo "Current remotes:"
git remote -v
echo ""

echo "=========================================================================="
echo "Step 3: Verifying Repository Status"
echo "=========================================================================="
echo ""

# Check for uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}Warning: You have uncommitted changes!${NC}"
    echo "Please commit or stash them first."
    exit 1
fi

echo -e "${GREEN}✅ Working directory is clean${NC}"
echo ""

# Show what will be pushed
echo "Your Master Services commits:"
git log --oneline -n 5 | grep -E "(Master Services|company simulation|security verification)" || echo "Recent commits:"
git log --oneline -n 5
echo ""

echo "=========================================================================="
echo "Step 4: Push to New Private Repository"
echo "=========================================================================="
echo ""
echo "This will push your current branch to the new repository as 'main'"
echo ""
read -p "Ready to push? (yes/no): " PUSH_CONFIRM

if [ "$PUSH_CONFIRM" != "yes" ] && [ "$PUSH_CONFIRM" != "y" ]; then
    echo "Cancelled. Remote 'private' is still configured if you want to push manually."
    exit 0
fi

# Get current branch name
CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
echo ""
echo "Pushing branch '$CURRENT_BRANCH' to remote 'private' as 'main'..."
echo ""

# Push to the new repository
if git push private "$CURRENT_BRANCH:main"; then
    echo ""
    echo -e "${GREEN}✅ Successfully pushed to new repository!${NC}"
else
    echo ""
    echo -e "${RED}❌ Push failed!${NC}"
    echo "This might be because:"
    echo "  - The repository already has content"
    echo "  - Authentication failed"
    echo "  - Network issues"
    echo ""
    echo "You can try manually:"
    echo "  git push private $CURRENT_BRANCH:main --force"
    exit 1
fi

echo ""
echo "=========================================================================="
echo "🎉 Migration Complete!"
echo "=========================================================================="
echo ""
echo "Your Master Services simulation is now in your private repository!"
echo ""
echo "Next steps:"
echo ""
echo "1. Verify the migration:"
echo "   Visit: ${NEW_REPO_URL%.git}"
echo "   Check that you see the 🔒 PRIVATE badge"
echo "   Verify examples/master_services/ directory exists"
echo ""
echo "2. Clone the new repository for a fresh start:"
echo "   cd ~"
echo "   git clone $NEW_REPO_URL"
echo "   cd \$(basename $NEW_REPO_URL .git)"
echo ""
echo "3. Test the simulation:"
echo "   pip install -e ."
echo "   pip install langchain-openai"
echo "   export OPENAI_API_KEY='your-key-here'"
echo "   python examples/master_services/run_simulation.py"
echo ""
echo "4. (Optional) Clean up the old fork:"
echo "   See MIGRATE_TO_PRIVATE_REPO.md for options"
echo ""
echo "=========================================================================="
echo ""
echo -e "${GREEN}Your company data is now safe in a private repository! ✅${NC}"
echo ""
