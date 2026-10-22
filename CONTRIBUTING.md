# Updating the lab website

Use a separate file for each person, project, publication or post. Shared templates
handle page formatting, so routine contributions need only Markdown, metadata and assets.

## The usual workflow

1. Pull the latest repository and create a branch for your update.
2. Edit an existing content file locally or copy the appropriate file from `templates/`.
3. Put images and downloads in the matching asset folders and reference them.
4. Run the checks in [README.md](README.md#check-before-committing) and preview at `http://localhost:4000`.
5. Commit the source files and assets together, push your branch to GitHub, and open a pull request describing the update.
6. After merge, a maintainer publishes it to the U-M server using [README.md](README.md#production-build-and-deployment). Pushing to GitHub does not publish the site.

Keep one change per pull request when practical. Do not commit `_site/`, caches
or local comparison output. Documentation, templates, scripts and the HTML guide
are excluded from the public website.

## Add or edit a person

Copy `templates/person.md` to `_people/firstname_lastname.md`. Keep existing
filenames when editing a person: the filename determines the profile URL.

```yaml
---
name: "Your Full Name"
email: name@umich.edu
position: gradstudent
avatar: firstname-lastname.jpg
joined: 2026
---
```

- Put the photo in `images/people/firstname-lastname.jpg`.
- Set `email` to the address you want displayed. It becomes a clickable link on
  a line below your name in the People listing and on your profile page.
  Omit it or use `email: null` when no address should be displayed.
- For master's and undergraduate students (`position: others`), set `mentor`
  to the mentor's display name, for example `mentor: Julia`. The People listing
  shows `Ellina Ho (Mentor: Julia)` with the mentor beside the student's name.
  Omit it or use `mentor: null` to hide the mentor text.
- Use `avatar: null` when no photo is available. The listing uses the local placeholder.
- Write the bio after the second `---` line. Do not add the profile-photo HTML;
  `_layouts/profile.html` renders the photo automatically.
- Names, biographies and personal links belong in the person file.
- Set `profile_link: false` (without quotes) to show a person's name and portrait
  without links in the People listing while their bio is not ready. Omit the
  field or set it to `true` to restore both links. Email links stay active, and
  the individual profile URL remains available.
- People are grouped by role and sorted by `joined`, as before.

### Role values

| `position` | Section |
| --- | --- |
| `pi` | Principal Investigator |
| `postdoc` | Postdoctoral Fellows |
| `gradstudent` | PhD Students |
| `researchstaff` | Research Staff |
| `visiting` | Visiting Students |
| `others` | Master & Undergrad Students |
| `alumni` | Alumni |

These values and headings come from `_data/roles.yml`. Use `gradstudent`, not `graduate`.

Add your profile when you officially join the lab, ideally in your first week.
When you graduate or finish your appointment or visit, retain the profile and
change its metadata if you should be listed as alumni:

```yaml
position: alumni
previous_role: "PhD Student"
graduation_year: 2026
joined: 2021
left: 2026
destination: "Your next position or institution"
```

For a new alumni record, copy `templates/alumni.md` into `_people/`.
Set `graduation_year` to a four-digit number, without quotes. The People page
automatically groups alumni by graduation year, newest first, and alphabetically
by name within each year. Do not manually reorder the page or its templates.

`previous_role` is display text. `joined`, `left`, and `graduation_year` are numbers;
`joined`, `left`, and `destination` may be omitted or set to `null` for alumni when
unknown. Current members still require `joined`. Use `graduation_year` for the degree
year; `left` is optional and only controls a lab-membership date range when `joined`
is also provided. Alumni keep smaller photo, name, and email cards below current
members, with links to their full profiles.
The old, previously hidden table is retained in `docs/archive/alumni-table.md`
for history; its entries are not automatically published.

## Add a project

Copy `templates/project.md` to `_projects/project-name.md`.

```yaml
---
title: "Project title"
summary: "One sentence for the project listing."
order: 100
image: /images/projects/project-name/system.jpg
image_alt: "Describe what the system figure shows"
---
```

Write the project description below the header. The shared layout adds the title
and cover image. The project appears automatically on `/project/`, with a detail
page at `/project/project-name/`. A lower `order` appears earlier; the default is
100. Keep the filename stable to preserve the URL.

`image` is optional; set it to `null` or omit it if no cover is needed. If an image
is set, add `image_alt`. Store additional figures under the same project folder.
The introductory text in `projects.md` is independently editable; the structural
migration preserved its existing placeholder text.

For the saved richer design, open [`templates/project-page.html`](templates/project-page.html).
Duplicate it inside `templates/` to try adjustments; replace its bracketed text
and figure placeholder. The [ViLA reference](_guides/show-me-project-vila.html)
preserves the approved example. These HTML drafts are excluded from the public
build and are not yet part of the shared project layout. See
[docs/PROJECT-PREVIEW.md](docs/PROJECT-PREVIEW.md).

## Add a publication

Copy `templates/publication.md` to `_publications/2026-paper-name.md`.

Required fields: `title`, `authors` (a YAML list), `venue`, and `year` (a number).
Optional fields: `paper_url`, `paper_label` (defaults to Article; use DOI for a DOI
link), `pdf`, `code_url`, `location`, `award`, `image`, `image_alt`, and `abstract`.
Use `null` or omit an optional field you do not need. An `image` requires
descriptive `image_alt`. Store thumbnails in `images/publications/`.

```yaml
authors:
  - "First Author"
  - "Second Author"
pdf: /files/publications/2026-paper-name.pdf
image: /images/publications/paper-name.jpg
image_alt: "Describe the publication thumbnail"
award: "Best Paper Award"
abstract: >-
  Put the paper abstract here. Indent continuation lines by two spaces.
```

Entries appear automatically under their year on `/publication/`, newest years
first. Within a year, keep descriptive, stable filenames for a consistent order.
Rows use a thumbnail, bold title, author list, italic venue and compact resource
buttons, following the HCIMaker publication style. Readers can expand extra
authors and the abstract, or filter the list. Edit `_includes/publication-item.html`
and `_sass/_publications.scss` to adjust all rows; filtering is in `js/publications.js`.
Publication records do not generate individual pages. Optional Markdown after
the header appears below the citation. Introductory text and the existing Scholar
link stay in `publications.md`.

## Add a news item

Add short news (papers accepted, awards, talks, new members) to `_data/news.yml`.
Each item is a few lines; the News page sorts them newest first:

```yaml
- date: 2026-10-01
  text: "Our paper on X was accepted to **SenSys 2026**!"
  link: https://example.com/paper        # optional
  image: /images/news/sensys-2026.jpg    # optional; file goes in images/news/
  image_alt: "Julia presenting at SenSys"  # required with image
```

Write `date` as `YYYY-MM-DD` without quotes. `text` accepts Markdown, such as
`**bold**` and `[links](https://...)`. Delete optional lines you don't need.

### Longer articles

For a full write-up with its own page, copy `templates/post.md` to
`_posts/YYYY-MM-DD-post-name.md`. The filename must contain a real date. Supply
`title`; optionally add `author` and `summary`. Put figures in
`images/posts/post-name/`. A post named `2026-09-14-lab-update.md` is published at
`/2026/09/14/lab-update.html`; link to it from a news item with that path.
Posts appear under "Articles" on the News page.

Use `published: false` on a post or project while drafting. The listings also
respect this flag for publications.

## Images and downloads

Use lowercase descriptive filenames without spaces. Keep an item's assets together:

```text
_projects/vibration-sensing.md
images/projects/vibration-sensing/system.jpg
images/projects/vibration-sensing/results.png

_posts/2026-09-14-lab-update.md
images/posts/lab-update/demo.jpg

_publications/2026-paper-name.md
files/publications/2026-paper-name.pdf
```

Reference a figure in Markdown using a root-relative URL and Jekyll's `relative_url` filter:

```liquid
![A description of the figure]({{ '/images/projects/vibration-sensing/system.jpg' | relative_url }})
```

The bracketed description is alternative text for people who cannot see the image.
Optimize large image files before committing. Paths and filenames must match exactly,
including capitalization, because the production host uses a case-sensitive filesystem.

### Homepage slideshow

1. Add the photo to `images/slideshow/`.
2. Add an entry to `_data/slideshow.yml`:

```yaml
- path: /images/slideshow/lab-retreat.jpg
  alt: "Lab members at the retreat"
```

The list order is the slide order. Reorder the entries to reorder the slideshow;
numeric filename prefixes are no longer required. Existing filenames, photo order,
alt text and the five-second interval were preserved. Dropping a file into the
folder alone no longer adds it to the slideshow: the data entry is required.

## Editing shared components

For site-wide design changes, use `_layouts/`, `_includes/` and `_sass/` rather
than repeating markup in content files. See [docs/STRUCTURE.md](docs/STRUCTURE.md).
After configuration changes, restart the local preview. Ordinary Markdown,
data-file, image and style edits rebuild automatically.

## Before submitting

- For substantial changes to the project structure or contribution workflow,
  update `_guides/show-me-website-map.html` in the same change. Keep it focused
  on what contributors need to know; routine content edits do not need a guide update.
- Preview the changed page and its listing; check links and images at desktop and mobile widths.
- Run `scripts/validate.rb` and `scripts/check-build.rb` using the commands in README.md.
- Check that filenames remain stable and that the correct source files and assets appear in `git diff`.
- Include a short description and, for a visible layout change, a screenshot in the pull request.

If you need help preparing a contribution, reach out to Julia.
