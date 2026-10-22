# PEI Lab @ University of Michigan

Source for the [PEI Lab website](https://peilab.eecs.umich.edu). Jekyll combines content files with shared templates and writes the published website to `_site/`.

## Start here

- **Visual folder guide:** open [_guides/show-me-website-map.html](_guides/show-me-website-map.html) in a browser.
- **Saved project design:** open the [reusable HTML template](templates/project-page.html) or [project ViLA reference](_guides/show-me-project-vila.html). These drafts include optional video/material areas and stay out of the published projects.
- **Add or edit content:** follow [CONTRIBUTING.md](CONTRIBUTING.md).
- **Maintain templates and styling:** see [docs/STRUCTURE.md](docs/STRUCTURE.md).

| Update | Edit |
| --- | --- |
| Person | `_people/<existing-filename>.md` and add photo to `images/people/` |
| Project | `_projects/<project-name>.md` |
| Publication | `_publications/<year>-<paper-name>.md` |
| News item | `_data/news.yml` (longer articles: `_posts/YYYY-MM-DD-title.md`) |
| Project / post figures | `images/projects/<project-name>/` or `images/posts/<post-name>/` |
| Paper PDFs | `files/publications/` |
| Publication thumbnails | `images/publications/` |
| Slideshow images, order and alt text | `images/slideshow/` + `_data/slideshow.yml` |
| Navigation | `_data/navigation.yml` |

See `CONTRIBUTING.md` for more info.

## Which GitHub branch should I use?

Use **`main`** as the shared source for the website and the starting point for new
updates. Create a short-lived branch for a contribution, then merge it into
`main` after review. Authorized maintainers may push approved changes directly
to `main` when repository rules permit.


## Preview changes locally

Requires Ruby 3.2+ (macOS, Linux or WSL). Install the pinned gems once, then
start the preview:

```bash
bundle install
bundle exec jekyll serve --config _config.yml,_config.local.yml
```

Open <http://localhost:4000> once Jekyll reports that the server is running.
Keep it running while editing, then refresh your browser after each rebuild.
After changing `_config.yml` or `_config.local.yml`, stop with `Ctrl+C` and run
the command again. On WSL, add `--force_polling` if edits are not picked up.
`Gemfile.lock` pins the Jekyll version; commit it when it changes.

Backup option without Ruby (requires Docker): `docker compose up`. The first
start installs the pinned gems and takes a few minutes; later starts reuse them.
Run the checks below the same way by prefixing each command with
`docker compose run --rm site`, for example
`docker compose run --rm site ruby scripts/validate.rb`.

## Check your update

```bash
bundle exec ruby scripts/validate.rb
JEKYLL_ENV=production bundle exec ruby scripts/check-build.rb
```

The first command validates required fields, member roles and local content assets.
The second builds sample contributions in a temporary copy, including alumni,
projects, publications, posts, images and unpublished records. It does not add
sample content to your working website. GitHub Actions runs both checks and a
production build on pushes and pull requests.

## Production build and deployment

Follow this order for every update: **edit locally → check and preview → commit and push to GitHub → build locally → copy/upload to UM vhost**. 

GitHub holds the source and change history; `/w/peilab/` holds the generated public website.
Make all content, layout and style edits in your local repository. **Do not edit website files directly on the remote vhost.**

**What does “copy to vhosts” mean?** Upload the *contents* of your locally built
`_site/` directory to `/w/peilab/` on `vhosts.eecs.umich.edu`. For example,
`_site/publication/index.html` becomes `/w/peilab/publication/index.html`.
Do not upload the source repository or create `/w/peilab/_site/`.

After uploading, the changes will be reflected on `https://peilab.eecs.umich.edu/`.

## Quick publish to vhosts

After building (`JEKYLL_ENV=production bundle exec jekyll build`), copy the site to the server:

```bash
rsync -rlP --chmod=Dg+rwx,Fg+rw _site/ <uniqname>@vhosts.eecs.umich.edu:/w/peilab/
```

`--chmod=Dg+rwx,Fg+rw` keeps newly uploaded files group-writable so other
maintainers can update them later. See
[Production build and deployment](#production-build-and-deployment) for the full
checklist and [Permission denied errors](#permission-denied-errors-during-rsync)
if the upload reports `mkstemp ... Permission denied (13)`.

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

In a terminal **in the repository** (WSL on Windows):

```bash
# Stop the preview (Ctrl+C) so it cannot overwrite production files with localhost URLs.
# Build using _config.yml and the production website URL.
JEKYLL_ENV=production bundle exec jekyll build
```

Backup option: `docker compose run --rm -e JEKYLL_ENV=production site jekyll build`.

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
rsync -rlcP --chmod=Dg+rwx,Fg+rw -e "$ssh_transport" _site/ "$deploy_target:/w/peilab/"
```

**Keep the trailing slash in `_site/`: it copies the contents into the web root.**
Use these `rsync` flags: `-r` copies directories, `-l` preserves symbolic links,
`-c` compares contents instead of timestamps, `-P` shows progress and retains
partial transfers, and `--chmod=Dg+rwx,Fg+rw` makes newly created files and
folders group-writable so the next maintainer can overwrite them. They do not
change ownership or permissions of existing files.
Use this workflow instead of `scp` or adding permission-preserving flags (`-p`, `-a`).

#### Permission denied errors during rsync

```text
rsync: [receiver] mkstemp "/w/peilab/people/shijia_pan/.index.html.DnjiRn" failed: Permission denied (13)
rsync error: some files/attrs were not transferred (see previous errors) (code 23)
```

rsync writes a temporary file inside each destination folder, so this means
**that folder** is not writable by you, usually because another maintainer
uploaded it without group-write permission. Other files still uploaded; only the
listed paths are stale. To fix it:

```bash
# See who owns the blocked folders and their permissions.
ssh <uniqname>@vhosts.eecs.umich.edu 'ls -ld /w/peilab/images/publications /w/peilab/people/shijia_pan'
```

The **owner shown in that listing** (or an EECS vhost administrator) runs this on
the server to make the whole site group-writable again:

```bash
ssh <owner-uniqname>@vhosts.eecs.umich.edu \
  'find /w/peilab -user "$USER" \( -type d -exec chmod g+rwxs {} + \) -o \( -type f -exec chmod g+rw {} + \)'
```

Then rerun the rsync command. The `--chmod` flag above prevents this from
happening again for files uploaded afterwards.

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


### Documentation 
README, CONTRIBUTING and the visual maintenance guide are excluded from `_site/`.
Commit and push documentation updates to GitHub; they require no vhost upload.


For help or questions, reach out to Julia. 