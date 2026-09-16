# Website structure and ownership

## Content → templates → generated pages

```text
peilab-website/
├── _people/                 # one member record + biography per file
├── _projects/               # one project per file; generates a detail page
├── _publications/           # one paper per file; renders in the bibliography
├── _posts/                  # dated news posts
├── _data/
│   ├── navigation.yml      # menu labels, links, order
│   ├── roles.yml           # accepted person roles, section headings, order
│   └── slideshow.yml       # image paths, alt text, order
├── images/
│   ├── people/
│   ├── slideshow/
│   ├── projects/<name>/
│   └── posts/<name>/
├── files/publications/      # downloadable PDFs and supplements
├── index.html               # homepage prose; layout: home
├── people.md                # entry point to the people listing
├── projects.md              # introduction + generated project listing
├── publications.md          # introduction + generated bibliography
├── news.md                  # news listing, initially published: false
├── _layouts/                # default, home, page, profile, project, post
├── _includes/               # reusable components and listing logic
├── _sass/                   # base, content, syntax, people, navigation, slideshow, publications
├── style.scss               # module order; builds the existing /style.css URL
├── css/                     # existing zoom styling
├── js/                      # slideshow and zoom behavior
├── templates/               # examples to copy; never published
├── scripts/                 # validation + isolated contributor build checks
├── docs/                    # maintainer notes and archived source content
├── _guides/                 # standalone HTML field guide
├── .github/workflows/       # checks on pushes and pull requests
├── _config.yml              # collection registration and layout defaults
├── _config.local.yml        # localhost preview overrides
└── docker-compose.yml       # shared build/preview runtime
```

`.gitkeep` files retain otherwise empty folders in Git and are not published.

## Responsibilities

| Content / data | Renderer | Output |
| --- | --- | --- |
| `index.html` | `_layouts/home.html` → `_layouts/default.html` | `/` |
| `_people/*.md` | `_layouts/profile.html` | Existing `/people/<filename>/index.html` URLs |
| `_people/*.md` + `_data/roles.yml` | `people-list.html`, `person-card.html`, `alumni-list.html` | `/people/` |
| `_projects/*.md` | `_layouts/project.html`, `project-list.html`, `project-card.html` | `/project/` + `/project/<filename>/` |
| `_publications/*.md` | `publication-list.html`, `publication-item.html` | `/publication/` |
| `_posts/*.md` | `_layouts/post.html`, `post-list.html` | Dated article URLs + `/news/` when enabled |
| `_data/navigation.yml` | `_includes/navbar.html` | Shared navigation |
| `_data/slideshow.yml` | `slideshow.html`, `slideshow-scripts.html`, `js/home-slideshow.js` | Homepage slideshow |

All includes in the table live in `_includes/`. People, projects and posts get
their layouts from `_config.yml` defaults. Collections with `output: true` generate
detail pages; publications have `output: false` and provide records to the listing.

Publication thumbnails live in `images/publications/`. Optional `award`,
`image`/`image_alt`, `abstract`, `location`, and `paper_label` fields extend the
basic citation. The shared publication component renders the thumbnail, author
expansion, abstract and resource buttons; `js/publications.js` filters the list.

The saved visual project template is `templates/project-page.html`, with its
ViLA reference in `_guides/show-me-project-vila.html`. These excluded design
drafts do not change the live project layout or create a project record.
The site uses built-in Jekyll/Liquid features without a custom publishing plugin.

## Preserve URLs and appearance

- Keep member and project filenames stable. The project's `:name` permalink uses
  its source filename, so changing its display title does not rename the page.
- The existing root pages and public asset folders keep their URLs.
- `style.scss` loads modules in the original cascade order. Each module currently
  emits an unchanged consecutive block from the original stylesheet.
- Homepage text stays in `index.html`; the home layout owns the surrounding markup.
- Profile photos are emitted once by the profile layout; bios contain only content.
- The optional `email` field in a person record supplies a clickable address below
  the name in both the People listing and the profile. Missing emails are hidden.
- Alumni appear after current members with a smaller heading and smaller photo,
  name and email cards, reusing `person-card.html` with alumni-specific styles.
  Set `position: alumni`, `previous_role`, and `graduation_year` in the member file.
  Alumni are grouped by graduation year (newest first), then by name within each
  year. `joined`, `left`, and `destination` are optional for alumni; membership
  date ranges appear only when both `joined` and `left` are provided.
- Shared head assets/metadata and footer scripts live in `head.html` and `scripts.html`.
  Existing integrations and commented source content were retained.

## Contributor checks

`scripts/validate.rb` checks YAML, required fields, roles, dates, slide entries,
cover images, profile photos, PDFs and root-relative asset references in content.
It intentionally does not fetch external links. It reports errors with filenames.

`scripts/check-build.rb` copies the source into a temporary directory and adds
fixture records based on the contributor templates. It verifies generated member
and alumni listings, graduation-year ordering and validation, a single profile photo, project routes, bibliography entries,
news activation, dated posts, image URLs with a base path, unpublished-content
handling and exclusions for contributor resources. It also confirms a missing
image causes validation to fail. Fixtures never enter the working site.

`.github/workflows/check-site.yml` runs content validation, a production build and
the fixture checks. It performs no deployment. All commands use the Docker image
already selected by this repository.

## Migration notes — 14 September 2026

- Preserved all existing live text, page URLs, remaining images and slideshow order.
- Kept the user's deletion of the Troy Zhong and Xinqi Zhang profiles and photos.
- Added empty project, publication and post folders; did not create sample live entries.
- Left the existing project/publication introduction text intact.
- Kept news disabled to preserve the current public page set and navigation.
- Archived the old inactive alumni table verbatim in `archive/alumni-table.md`.
  It had no active alumni records and was not visible. Future alumni come from
  explicit member records; archived entries are not asserted to be PEI Lab alumni.
- Excluded contributor documentation and tooling from generated output. README.md
  was previously copied to the public build as a static file; it is now repository documentation.

Build output (`_site/`), caches and local migration comparisons (`.refactor-check/`)
are generated artifacts, not content sources.

## Jekyll references

- [Directory structure](https://jekyllrb.com/docs/structure/)
- [Collections](https://jekyllrb.com/docs/collections/)
- [Front matter defaults](https://jekyllrb.com/docs/configuration/front-matter-defaults/)
- [Posts](https://jekyllrb.com/docs/posts/)
