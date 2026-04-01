# 1. Initialize the repo (if not already done)
git init

# 2. Add your remote
git remote add origin https://github.com/pastioke/onifast.git

# 3. Stage all files (binaries, services, and the cmd folder)
git add .

# 4. Commit using the text inside the VERSION file
git commit -m "Release version: $(cat VERSION)"

# 5. Ensure you are on the main branch
git branch -M main

# 6. Force push to overwrite the remote with these binaries
git push -u origin main --force