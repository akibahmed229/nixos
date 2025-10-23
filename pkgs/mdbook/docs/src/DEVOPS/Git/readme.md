## 🚀 Initial Configuration

Set these up once on any new machine.

- `git config --global user.name "Your Name"`
  - Sets the name that will appear on your commits.
- `git config --global user.email "you@example.com"`
  - Sets the email for your commits.
- `git config --global init.defaultBranch main`
  - Sets the default branch name to `main` for new repos.
- `git config --global alias.lg "log --graph --oneline --decorate --all"`
  - Creates a `git lg` shortcut for a clean, comprehensive log.
- `git config --global alias.st "status -s"`
  - Creates a `git st` shortcut for a short, one-line status.

---

## 📦 Basic Workflow: Staging & Committing

This is your day-to-day command cycle.

- `git init`
  - Initializes a new Git repository in the current directory.
- `git status`
  - Shows the status of your working directory and staging area (untracked, modified, and staged files).
- `git add <file...>`
  - Adds one or more specific files to the staging area.
  - _Example:_ `git add README.md package.json`
- `git add .`
  - Adds all new and modified files in the current directory to the staging area.
- `git add -p`
  - Interactively stages _parts_ of files. Git will show you each "hunk" of changes and ask if you want to stage it (y/n/q).
- `git commit -m "Your descriptive message"`
  - Saves a permanent snapshot of the staged files to the project history.
- `git commit -am "Your message"`
  - A shortcut to **stage all _tracked_ files** and commit them in one step. (Note: Does not add _new_, untracked files).
- `git rm <file>`
  - Removes a file from both the working directory and the staging area.
- `git rm --cached <file>`
  - Removes a file from the staging area (index) but **keeps the file** in your working directory. Useful for "untracking" a file, like a config file you accidentally added.
- `git mv <old-name> <new-name>`
  - Renames a file. This is equivalent to `mv <old> <new>`, `git rm <old>`, and `git add <new>`.

---

## 📜 Inspecting History & Logs

See what has happened in the project.

- `git log`
  - Shows the full commit history for the current branch.
- `git log --oneline`
  - Shows a compact, one-line view of the commit history.
- `git lg` (or `git log --graph --oneline --decorate --all`)
  - A powerful, customized log (using the alias from setup) that shows _all_ branches, commit graphs, and tags in a clean one-line format.
- `git log -p <file>`
  - Shows the commit history _for a specific file_, including the changes (patches) made in each commit.
- `git reflog`
  - Shows a log of _all_ movements of `HEAD` (commits, checkouts, resets, merges). This is your **ultimate safety net** for finding "lost" commits.

---

## 🌿 Branching & Merging

Manage parallel lines of development.

### Branching

- `git branch`
  - Lists all your **local** branches.
- `git branch -a`
  - Lists all local **and** remote-tracking branches.
- `git branch <branch-name>`
  - Creates a new branch based on your current `HEAD`.
- `git checkout <branch-name>`
  - Switches your working directory to the specified branch.
- `git checkout -b <branch-name>`
  - A shortcut to **create** a new branch and **switch** to it immediately.
- `git branch -m <new-name>`
  - Renames the _current_ branch.
- `git branch -d <branch-name>`
  - Deletes a _merged_ local branch. Git will stop you if the branch isn't merged (safety feature).
- `git branch -D <branch-name>`
  - **Force deletes** a local branch, even if it's not merged.

### Merging & Rebasing

- `git merge <branch-name>`
  - Merges the specified branch _into_ your current branch. This creates a new "merge commit" if there are new commits on both branches (a non-fast-forward merge).
- `git rebase <branch-name>`
  - Re-applies your current branch's commits _on top of_ the specified branch. This creates a cleaner, linear history.
  - _Example:_ You're on `feature` and `main` has updated. Run `git rebase main` to move your `feature` work to the tip of `main`.
- `git rebase -i HEAD~3`
  - Interactively rebase the last 3 commits. This opens an editor allowing you to `squash` (combine), `reword` (change message), `edit`, `drop`, or reorder commits.

---

## 📥 Stashing

Temporarily save changes you aren't ready to commit.

- `git stash` or `git stash save "Your message"`
  - Takes all your uncommitted changes (in tracked files), saves them, and cleans your working directory back to `HEAD`.
- `git stash list`
  - Shows all stashes you've saved.
- `git stash pop`
  - Applies the _most recent_ stash to your working directory and **deletes it** from the stash list.
- `git stash apply <stash@{n}>`
  - Applies a _specific_ stash (e.g., `stash@{1}`) but **does not delete it** from the list.
- `git stash drop <stash@{n}>`
  - Deletes a specific stash from the list.

---

## 📡 Remote Repositories (e.g., GitHub)

Manage connections to other repositories.

### Managing Remotes

- `git remote add <name> <url>`
  - Adds a new remote. The standard name is `origin`.
  - _Example:_ `git remote add origin https://github.com/user/repo.git`
- `git remote -v`
  - Lists all your remotes with their URLs.
- `git remote rename <old-name> <new-name>`
  - Renames a remote.
- `git remote remove <name>`
  - Removes a remote.

### Syncing Changes

- `git fetch <remote-name>`
  - Downloads all branches and history from the remote **without** merging them into your local branches. This is safe and lets you inspect changes first.
- `git pull <remote-name> <branch-name>`
  - A shortcut for `git fetch` followed by `git merge`. It fetches and _immediately_ tries to merge the remote branch into your current local branch.
  - _Example:_ `git pull origin main`
- `git push <remote-name> <branch-name>`
  - Uploads your local branch's commits to the remote repository.
- `git push -u <remote-name> <branch-name>`
  - Pushes and sets the remote as the "upstream" tracking branch. After this, you can just run `git pull` or `git push` from that branch.
- `git push <remote-name> --delete <branch-name>`
  - Deletes a branch on the remote repository.
- `git push --force-with-lease`
  - ⚠️ **Force-pushes** your local branch, overwriting the remote. This is safer than `git push --force` because it will fail if someone else has pushed new commits in the meantime. **Use this only when you have rewritten history (e.g., rebase) and have coordinated with your team.**

---

## ↩️ Undoing & Rewriting History

How to fix mistakes "after the fact."

### Before Committing (Working Directory / Staging)

- `git restore <file>`
  - Discards changes in your **working directory**. (The modern, clearer version of `git checkout -- <file>`).
- `git restore --staged <file>`
  - Unstages a file, moving it from the **staging area** back to the working directory. (The modern version of `git reset HEAD <file>`).

### After Committing (But Before Pushing)

- `git commit --amend`
  - Lets you **change the last commit's message** or **add more staged files** to it. It _replaces_ the last commit with a new one.
- `git reset --soft HEAD~1`
  - **Un-commits** the last commit. The changes from that commit are moved to the **staging area**.
- `git reset --mixed HEAD~1` (This is the default)
  - **Un-commits** the last commit. The changes are moved to the **working directory** (unstaged).
- `git reset --hard HEAD~1`
  - ⚠️ **Destroys** the last commit _and_ all changes associated with it. Your working directory is reset to the state of the commit _before_ it. **This is permanent.**
- `git reset --hard <commit-hash>`
  - ⚠️ Resets your entire project (working directory and index) to a specific commit. **Discards all subsequent commits and changes.**

### After Pushing (Public Commits)

- `git revert <commit-hash>`
  - The **safe** way to "undo" a public commit. This creates a _new_ commit that is the exact inverse of the specified commit. It doesn't rewrite history.
- `git revert -m 1 <merge-commit-hash>`
  - Reverts a merge commit. `-m 1` tells Git which parent to keep (usually 1).
- **Changing a Pushed Commit Message:**
  - This is **highly disruptive** to your team. Avoid if possible.
  1.  `git rebase -i HEAD~5` (Go back far enough to find the commit)
  2.  Find the commit line, change `pick` to `reword` (or `r`).
  3.  Save and close. Git will prompt you to enter the new message.
  4.  `git push --force-with-lease`
  - You _must_ force-push because you've rewritten public history. All collaborators will need to re-sync their branches.

---

## 🛠️ Advanced Tools

### Git Worktrees

Manage multiple branches in separate directories simultaneously.

- `git clone --bare . /path/to/my-bare-repo.git`
  - Clone the current repository as a bare repository
- `git worktree add <path> <branch-name>`
  - Checks out a branch into a new directory. This is great for working on a hotfix while keeping your main `feature` branch checked out in your primary folder.
  - _Example:_ `git worktree add ../my-hotfix-branch hotfix`
- `git worktree list`
  - Shows all active worktrees.
- `git worktree remove <path>`
  - Removes the worktree at the specified path.

### Git Submodules

Manage a repository _inside_ another repository.

- `git submodule add <repo-url> <path>`
  - Adds the other repo as a submodule in the specified path.
- `git clone --recurse-submodules <repo-url>`
  - Clones a repository **and** automatically initializes and updates all its submodules.
- `git submodule update --init --recursive`
  - Run this after a normal `git clone` (or `git pull`) to initialize or update submodules.
- **Workflow for updating a submodule:**
  1.  `cd <submodule-path>`
  2.  `git checkout main` (or desired branch)
  3.  `git pull`
  4.  `cd ..` (back to the parent repo)
  5.  `git add <submodule-path>`
  6.  `git commit -m "Update submodule to latest"`
  - This "parent" commit locks the submodule to the new commit hash you just pulled.
