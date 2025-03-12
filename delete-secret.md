Here's how to safely use `git filter-repo` to remove sensitive data from your repository history:

### Step-by-step guide:

**1. Install `git-filter-repo` (if not already installed):**

```bash
pip install git-filter-repo
```

Or, using Homebrew (macOS):

```bash
brew install git-filter-repo
```

**2. Identify the secret to remove:**

Assuming you accidentally committed an API key or secret like `"SECRET_KEY=abcd1234"` in your code.

**3. Run `git-filter-repo` to remove the sensitive content from all commits:**

```bash
git filter-repo --force --invert-grep --replace-text expressions.txt
```

**Create an `expressions.txt` file** first to specify what you want to remove, e.g.:

```
SECRET_KEY=abcd1234==>SECRET_KEY=[REMOVED]
```

- This replaces all occurrences of `SECRET_KEY=abcd1234` with `SECRET_KEY=[REMOVED]`.

Alternatively, if you want to remove all lines containing the secret entirely:

```bash
git filter-repo --force --invert-grep --path-glob expressions.txt
```

and in `expressions.txt`, just put the exact line or regex pattern.

If you prefer using a quick command line (without a file):

```bash
git filter-repo --force --invert-grep --message-callback '
  return message.replace(b"SECRET_KEY=abcd1234", b"[REMOVED]")'
```

This example specifically modifies commit messages containing sensitive data, but usually the `expressions.txt` method is simpler and recommended.

**4. Verify the sensitive information is completely removed:**

Check your commit history thoroughly:

```bash
git log -p --all | grep 'SECRET_KEY'
```

If the secret no longer appears, you're set.

**5. Force-push the cleaned history to GitHub:**

```bash
git push --force --all origin
git push --force --tags origin
```

⚠️ **Important notes**:

- Inform collaborators to re-clone the repository because history has been rewritten. They should reclone it a "git pull" will not work
- Immediately revoke or regenerate the exposed secrets.

That's it—your sensitive data is now securely removed from your Git history!
