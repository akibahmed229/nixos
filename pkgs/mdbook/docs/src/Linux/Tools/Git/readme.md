## Git add and staging area

Commit is for permanently saving your changes to the project’s history, marking a new point in the development timeline.

1. `git add <file>` # Adds a file to the staging area.
2. `git add .` # Adds all files in the current directory to the staging area.
3. `git commit -m "<message>"` # Commits the staging area to the repository with the given message.

## Git log and history

4. `git log --graph --oneline` # Shows a concise, one-line representation of the commit history with a graphical view.
5. `git log --graph --oneline --decorate --all --simplify-by-decoration` # Displays the commit history with a graphical view, showing only commits with tags and branches. The --decorate option adds information about branches and tags.
6. `git reflog` # Shows a reference log, which includes all the Git references (branches, tags, etc.) and their associated commit history. Useful for recovering lost commits.

## Git head to undo changes

7. `git reset --hard <commit>` # Resets the current branch and working directory to the specified commit. Discards all changes after that commit.
8. `git reset --hard origin/master` # Resets the current branch to the state of the remote master branch. Useful for discarding local changes and syncing with the remote repository.
9. `git reset --hard HEAD~1` # Resets the current branch and working directory to the previous commit (one commit before the current HEAD).
10. `git reset --soft <commit>` # Resets the current branch to the specified commit but keeps the changes in the working directory. The changes will appear as uncommitted modifications.

## Git branches

11. `git branch --list` # Lists all the local branches in the current repository.
12. `git branch <branch>` # Creates a new branch with the given name.
13. `git checkout <branch>` # Switches to the specified branch.
14. `git checkout -b <branch>` # Creates a new branch with the given name and switches to it.
15. `git branch -d <branch>` # Deletes the specified branch.
16. `git branch -m <branch>` # Renames the current branch to the specified name.

## Git merge

17. `git merge <branch>` # Merges the specified branch into the current branch (the one that HEAD points to).
18. `git stash` # Temporarily stores all modified tracked files.

## Git stash

Stash is for temporarily saving your progress when you need to switch contexts without committing unfinished work.

19. `git stash list` # Lists all stashed changesets.
20. `git stash show -p <stash>` # Shows the changeset recorded in the stash as a patch.
21. `git stash apply <stash>` # Applies the changeset recorded in the stash to the working directory.
22. `git stash pop` # Removes and applies the changeset last saved with git stash.

## Git mv and rm

23. `git rm <file>` # Removes a file from the working directory and staging area.
24. `git rm --cached <file>` # Removes a file from the staging area only. After that do git commit
25. `git mv <file-original> <file-renamed>` # Renames a file.

## Git remote

26. `git remote add origin <url>` # Adds a remote repository to the current Git project.
27. `git remote -v` # Lists all currently configured remotes.
28. `git remote show <remote>` # Shows information about the specified remote.
29. `git remote rename <remote> <new-name>` # Renames the specified remote.
30. `git remote remove <remote>` # Removes the specified remote.
31. `git push -u origin master` # Pushes the master branch to the origin remote and sets it as the default upstream branch for master.
32. `git push origin --delete <branch>` # Deletes a remote branch.
33. `git push` # Pushes the current branch to the remote repository.
34. `git pull` # Pulls the latest changes from the remote repository into the current branch.

##  Working with Submodules
Let's go through a complete example workflow:

1. **Initial Setup:**
   ```sh
   # Navigate to the main repository
   cd ~/path/to/nixos-config

   # Add the submodule
   git submodule add https://github.com/username/my-other-repo.git my-other-repo

   # Initialize and update the submodule
   git submodule init
   git submodule update

   # Commit the submodule addition in the main repository
   git add .gitmodules my-other-repo
   git commit -m "Add my-other-repo as a submodule"
   git push origin main
   ```

2. **Making Changes in the Submodule:**
   ```sh
   # Navigate to the submodule directory
   cd my-other-repo

   # Make changes and commit them
   git add .
   git commit -m "Make some changes in the submodule"
   git push origin main

   # Navigate back to the main repository
   cd ..

   # Update the submodule reference in the main repository
   git add my-other-repo
   git commit -m "Update submodule my-other-repo to latest commit"
   git push origin main
   ```

3. **Cloning and Updating:**
   ```sh
   # Clone the main repository
   git clone https://github.com/username/nixos-config.git

   # Navigate into the main repository
   cd nixos-config

   # Initialize and update submodules
   git submodule update --init --recursive
   ```

By following these steps, you can effectively manage submodules in your Git repository, ensuring that both the main repository and the submodules are kept up to date.

## Git WorkTree

Using git worktree can greatly enhance your workflow efficiency by allowing you to manage multiple branches in parallel with ease.

```sh
# Clone the current repository as a bare repository
git clone --bare . /path/to/my-bare-repo.git

# Add a worktree for the main branch in the default location
git worktree add main

# Add a worktree for the dev branch
git worktree add dev

# Remove the worktree for the dev branch when it's no longer needed
git worktree remove dev
```
