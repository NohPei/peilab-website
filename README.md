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

### 1. Save the source on GitHub

Commit the source files, assets and any contributor documentation together, then
push your branch to `origin` (`https://github.com/NohPei/peilab-website`). Use
a pull request for team review. An authorized maintainer publishing an approved
update may instead push the reviewed commits directly to `main`, when repository
rules permit. In either case, synchronize local and GitHub `main` before
building the version to publish. Check
that the working tree is clean with `git status` and record `git rev-parse HEAD`
so the published version can be traced to a commit. Do not commit `_site/`.

Pushing to GitHub runs checks; it does not upload files to the U-M vhost.

### 2. Build locally from the saved source

Stop the preview before writing production output to `_site/`:

```powershell
docker compose down
docker compose run --rm -e JEKYLL_ENV=production jekyll build
```

Using an existing Jekyll installation instead: `JEKYLL_ENV=production jekyll build`.

### 3. Upload and verify

Back up the live website before uploading. Connect to the U-M VPN when needed.
An authorized lab maintainer can then upload the generated files using the
existing UM vhost workflow (from an environment with `rsync`, such as WSL):

```bash
rsync -rlcP _site/ <uniquename>@vhosts.eecs.umich.edu:/w/peilab/
```

Avoid `scp`: changing destination permissions can break access for other maintainers.
The `-c` option compares file contents, avoiding unnecessary transfers when local
timestamps differ. After uploading, verify the public pages and use
`rsync -rlcni _site/ <uniquename>@vhosts.eecs.umich.edu:/w/peilab/` to check for
remaining content differences.
The existing `rsync` command copies updates but does not remove old remote files;
when profiles or pages are removed, the maintainer must also review obsolete
remote paths against the source changes saved on GitHub. Never edit `_site/` as
source: the next build overwrites it.

If rsync reports `Permission denied`, the owner of the affected server directory
or an administrator must restore shared access. For each reviewed directory,
the owner can run `chgrp peigroup <directory>` and
`chmod g+rwx,g+s <directory>`. This keeps existing owner/other access while allowing
lab maintainers to update files and making new files inherit the lab group.
Do not report deployment complete until remaining differences and obsolete paths
have been resolved. GitHub repository access and vhost filesystem access are
separate; pushing a commit does not change permissions on the server.

For help with contributions, reach out to Julia.
