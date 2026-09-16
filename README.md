# PEI Lab @ University of Michigan

Source for the [PEI Lab website](https://peilab.eecs.umich.edu). Jekyll combines
content files with shared templates and writes the published website to `_site/`.

## Start here

- **Visual folder guide:** open [_guides/show-me-website-map.html](_guides/show-me-website-map.html) in a browser.
- **Saved project design:** open the [reusable HTML template](templates/project-page.html) or [ViLA reference](_guides/show-me-project-vila.html). These drafts include optional video/material areas and stay out of the published projects.
- **Add or edit content:** follow [CONTRIBUTING.md](CONTRIBUTING.md).
- **Maintain templates and styling:** see [docs/STRUCTURE.md](docs/STRUCTURE.md).

| Update | Edit |
| --- | --- |
| Person, bio or email | `_people/<existing-filename>.md` (optional `email` field) |
| Master's / undergraduate mentor | `_people/*.md`: for `position: others`, add `mentor: Julia` to show a line below the name |
| Disable a person's name/photo links | Set `profile_link: false` in their `_people/*.md`; remove it or use `true` to restore links |
| Alumni / graduation year | `_people/*.md`: `position: alumni` and `graduation_year: 2026`; automatically grouped newest first |
| Headshot | `images/people/`; match the profile's `avatar` field |
| Project | `_projects/<project-name>.md` |
| Publication | `_publications/<year>-<paper-name>.md` |
| News post | `_posts/YYYY-MM-DD-title.md` |
| Project / post figures | `images/projects/<project-name>/` or `images/posts/<post-name>/` |
| Paper PDFs | `files/publications/` |
| Publication thumbnails | `images/publications/` |
| Homepage text | `index.html` |
| Slideshow images, order and alt text | `images/slideshow/` + `_data/slideshow.yml` |
| Navigation | `_data/navigation.yml` |
| Member role labels / order | `_data/roles.yml` |

Copy a starting file from `templates/`. People, project and publication listings
read their content folders automatically. The news listing is prepared but
disabled until the first post is ready; see the activation steps in CONTRIBUTING.md.
Existing projects/publications introduction text stays in the root page files.

## Which GitHub branch should I use?

Use **`main`** as the shared source for the website and the starting point for new
updates. Create a short-lived branch for a contribution, then merge it into
`main` after review. Authorized maintainers may push approved changes directly
to `main` when repository rules permit.

The earlier `website-maintenance` branch was used for the website reorganization.
Its changes are already included in `main`; it is not a separate website or a
deployment branch. Do not start new work from that older branch. A branch being
on GitHub does not mean it has been published to the U-M server.

## Preview locally with Docker (Windows or other platforms)

This uses the same Ruby/Jekyll Docker image as `HCIMaker.github.io`; no local
Ruby installation is needed.

1. Start Docker Desktop and wait for its engine to run.
2. Open a terminal in this repository:

```powershell
docker compose up
```

Open <http://localhost:4000> once Jekyll reports that the server is running.
Keep it running while editing, then refresh your browser after each rebuild.
Data-file edits are picked up automatically. After changing `_config.yml` or
`_config.local.yml`, stop with `Ctrl+C` and run the command again.

For background operation, use `docker compose up -d`, inspect output with
`docker compose logs -f`, and stop with `docker compose down`.

### Existing Jekyll installation

If you already have a compatible Jekyll installation, run:

```bash
jekyll serve --config _config.yml,_config.local.yml
```

The Docker runtime is the reference environment used by the automated checks.

## Check your update

```powershell
docker compose run --rm --entrypoint ruby jekyll scripts/validate.rb
docker compose run --rm -e JEKYLL_ENV=production --entrypoint ruby jekyll scripts/check-build.rb
```

The first command validates required fields, member roles and local content assets.
The second builds sample contributions in a temporary copy, including alumni,
projects, publications, posts, images and unpublished records. It does not add
sample content to your working website. GitHub Actions runs both checks and a
production build on pushes and pull requests.

## Production build and deployment

Follow this order for every update: **edit locally → check and preview → commit
and push to GitHub → build locally → upload to the U-M vhost**. GitHub holds the
source and change history; `/w/peilab/` holds the generated public website.
Make all content, layout and style edits in your local repository. Do not edit
website files directly on the remote vhost.

**What does “copy to vhosts” mean?** Upload the *contents* of your locally built
`_site/` directory to `/w/peilab/` on `vhosts.eecs.umich.edu`. For example,
`_site/publication/index.html` becomes `/w/peilab/publication/index.html`.
Do not upload the source repository or create `/w/peilab/_site/`.

| Location | Purpose |
| --- | --- |
| Local repository + GitHub `main` | Editable Markdown, templates, assets and change history |
| Local `_site/` | Generated HTML, CSS, JavaScript and assets; rebuilt by Jekyll |
| Vhost `/w/peilab/` | Generated files served at `https://peilab.eecs.umich.edu/` |

Pushing to GitHub runs checks; it does **not** upload to vhosts. A direct upload
can look the same to visitors, but the GitHub step first preserves the exact
source for other contributors and future updates.

### 1. Save the source on GitHub and select the version to publish

Commit content, assets and relevant documentation together. Push your branch and
merge its reviewed pull request into `main`, or push an approved maintainer update
directly to `main`. Never commit `_site/`. Wait for the GitHub checks to pass.

Then run in **PowerShell, in your local repository**:

```powershell
# Check for uncommitted changes. If any are listed, save them before continuing.
git status --short

# Get the shared source branch from GitHub without creating a merge commit.
git switch main
git pull --ff-only

# Expect 0 0: local main and GitHub main must contain the same commits.
git rev-list --left-right --count HEAD...origin/main

# Record this commit ID with your deployment notes.
git rev-parse HEAD
```

Stop and resolve errors or differing commits before publishing. Run the checks
in [Check your update](#check-your-update) and preview any visible changes.

### 2. Build the public website locally

Keep Docker Desktop running. In **PowerShell, in the repository**:

```powershell
# Stop the preview so it cannot overwrite production files with localhost URLs.
docker compose down

# Build using _config.yml and the production website URL.
docker compose run --rm -e JEKYLL_ENV=production jekyll build
```

Continue only if the build succeeds. Keep the preview stopped until uploading
is finished. Never manually edit `_site/`; make corrections in the source,
check and push them, then rebuild.

### 3. Open a local WSL terminal and sign in to the vhost

Windows maintainers need WSL Ubuntu with `ssh` and `rsync`, plus a U-M account
with write access to the lab's vhost. Connect to the U-M VPN if required to reach
the server. GitHub access and server access are separate permissions.

From **PowerShell**:

```powershell
# Open Ubuntu on YOUR computer. This does not log in to the web server.
wsl -d Ubuntu
```

Run the remaining commands in that **local Ubuntu/Bash terminal**. On Linux or
macOS, use a local terminal with `ssh` and `rsync` and your own repository path.

```bash
# Change this path if your clone is elsewhere; C:\ maps to /mnt/c/ in WSL.
cd /mnt/c/Academic/peilab-website

# Confirm you can see the production build and the required commands.
test -f _site/index.html
command -v ssh rsync

# Replace the example value with YOUR U-M uniqname, without @umich.edu.
deploy_user="YOUR_UM_UNIQNAME"
deploy_target="${deploy_user}@vhosts.eecs.umich.edu"
control_socket="/tmp/peilab-deploy-control"

# Complete SSH login prompts here. This connection is reusable for 30 idle minutes.
ssh -M -S "$control_socket" -o ControlPersist=30m -fN "$deploy_target"

# Confirm authentication succeeded before proceeding.
ssh -S "$control_socket" -O check "$deploy_target"

# Reuse this login for the upload commands below.
ssh_transport="ssh -S $control_socket -o BatchMode=yes -o ConnectTimeout=15 -o StrictHostKeyChecking=yes"
```

Keep passwords in the login prompt, never in project files. If the control socket
is already running, reuse it after the `-O check` succeeds. If it expires, repeat
the login command. All upload commands below run **locally**, not inside an
interactive SSH session on the server. Run each step separately and stop on errors.

### 4. Back up, preview the transfer, then copy the build

First create a private backup on the server. This command enters the web root
before archiving, so it includes the files even when `/w/peilab` is a symlink.

```bash
# Back up the current live files; save the printed backup path in your notes.
ssh -S "$control_socket" -o BatchMode=yes "$deploy_target" '
  set -eu
  umask 077
  backup_dir=$(mktemp -d /tmp/peilab-before-deploy.XXXXXX)
  tar -czf "$backup_dir/site.tar.gz" -C /w/peilab .
  tar -tzf "$backup_dir/site.tar.gz" >/dev/null
  printf "Backup saved: %s/site.tar.gz\n" "$backup_dir"
'
```

The `/tmp` backup is temporary; retain a copy in an approved longer-term location
if needed. Continue only after the backup succeeds.

```bash
# Preview what would change. -n means dry run: this command uploads nothing.
rsync -rlcni -e "$ssh_transport" _site/ "$deploy_target:/w/peilab/"

# After reviewing the list, copy new or changed generated files to the live site.
rsync -rlcP -e "$ssh_transport" _site/ "$deploy_target:/w/peilab/"
```

**Keep the trailing slash in `_site/`: it copies the contents into the web root.**
Use these `rsync` flags: `-r` copies directories, `-l` preserves symbolic links,
`-c` compares contents instead of timestamps, and `-P` shows progress and retains
partial transfers. They do not request changes to existing ownership or permissions.
Use this workflow instead of `scp` or adding permission-preserving flags.

### 5. Verify the public result

```bash
# Expect no file differences and a successful exit status for a full deployment.
rsync -rlcni -e "$ssh_transport" _site/ "$deploy_target:/w/peilab/"

# When finished, close the temporary authenticated connection.
ssh -S "$control_socket" -O exit "$deploy_target"
```

Open the actual [public website](https://peilab.eecs.umich.edu/) and check the
changed page, its links and its images. Hard-refresh if your browser shows an old
copy. Record the commit, uploaded paths, backup location and verification result.
An upload error or remaining differences means the full deployment is incomplete.

### Publishing only a small update

An authorized maintainer can upload a reviewed subset when only those generated
files need changing. Follow the same commit, build, login, backup and verification
steps above. For example, to update the People listing and its styling, run these
in place of the full-site transfer and comparison, **before closing SSH**:

```bash
# Preview just these two generated files.
rsync -rlcni --relative -e "$ssh_transport" \
  _site/./people/index.html _site/./style.css "$deploy_target:/w/peilab/"

# Upload the selected files, keeping their paths relative to _site/./.
rsync -rlcP --relative -e "$ssh_transport" \
  _site/./people/index.html _site/./style.css "$deploy_target:/w/peilab/"

# Verify the same selection; expect no file differences.
rsync -rlcni --relative -e "$ssh_transport" \
  _site/./people/index.html _site/./style.css "$deploy_target:/w/peilab/"
```

Include **every** generated file and asset affected by your change. Shared layout
or navigation edits can change many pages, so use the full-site comparison to
determine the scope. A successful targeted upload verifies only its selected files;
it does not resolve unrelated differences elsewhere on the server.

### Removed pages and permission errors

- These commands do not delete old remote files. For a removed page or photo,
  review its exact server path against the committed source change, retain a
  backup, then have an authorized maintainer remove that specific obsolete path.
  Do not add a blanket `--delete` to the upload command.
- A People card is in `/w/peilab/people/index.html`; Ellina's individual profile
  is `/w/peilab/people/ellina_ho/index.html`. One can be writable while the other
  is blocked. Updating the listing does not require replacing the profile page.
- If a transfer reports `Permission denied`, check the exact destination path.
  The directory owner or an administrator must grant the appropriate shared
  access. For a reviewed directory, they can run `chgrp peigroup <directory>`
  and `chmod g+rwx,g+s <directory>`. These are owner/admin repair commands,
  not a routine publishing step. Preserve existing access; do not change
  permissions across the whole site indiscriminately.
- SSH login failure, network timeout and a file-transfer permission error are
  different problems. Check login for the first, VPN/network access for the
  second, and the named server folder's permissions for the third. A GitHub
  push does not grant vhost write access.

### Documentation-only changes

README, CONTRIBUTING and the visual maintenance guide are excluded from `_site/`.
Commit and push documentation updates to GitHub; they require no vhost upload.

For help with contributions, reach out to Julia.
