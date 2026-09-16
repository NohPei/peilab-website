# frozen_string_literal: true

# End-to-end checks use a temporary copy, so fixture content never enters the site.
require "jekyll"
require "tmpdir"
require "fileutils"
require "yaml"

root = File.expand_path("..", __dir__)
assert = ->(condition, message) { raise message unless condition }

Dir.mktmpdir("peilab-check-") do |temporary|
  source = File.join(temporary, "source")
  destination = File.join(temporary, "built")
  FileUtils.mkdir_p(source)
  Dir.children(root).each do |name|
    next if name.start_with?(".") || %w[_site _guides].include?(name)
    FileUtils.cp_r(File.join(root, name), source)
  end
  fixture = lambda do |template, path, fields, body = nil|
    original = File.read(File.join(root, "templates", template), encoding: "UTF-8")
    _empty, header, original_body = original.split(/^---\s*$\n?/, 3)
    data = YAML.safe_load(header).merge(fields)
    File.write(File.join(source, path), YAML.dump(data) + "---\n\n" + (body || original_body || ""))
  end
  fixture.call("alumni.md", "_people/check-alumni.md", {
    "name" => "Fixture Alumni", "position" => "alumni", "joined" => 2020,
    "previous_role" => "PhD Student", "graduation_year" => 2025, "left" => 2025, "destination" => "Fixture destination",
    "avatar" => "ece-photo-placeholder.png", "email" => "fixture-alumni@example.com"
  }, "Fixture biography.")
  fixture.call("alumni.md", "_people/check-alumni-earlier.md", {
    "name" => "Earlier Fixture Alumnus", "graduation_year" => 2010
  }, "Earlier alumni biography.")
  fixture.call("alumni.md", "_people/check-alumni-same-year.md", {
    "name" => "Alphabetical Fixture Alumnus", "graduation_year" => 2025
  }, "Same-year alumni biography.")
  fixture.call("person.md", "_people/check-student.md", { "name" => "Fixture Student", "position" => "gradstudent", "email" => "fixture-student@example.com" }, "Fixture student biography.")
  fixture.call("project.md", "_projects/check-project.md", {
    "title" => "Fixture Project", "summary" => "Fixture project summary.", "order" => 1,
    "image" => "/images/people/ece-photo-placeholder.png", "image_alt" => "Fixture illustration"
  }, "Fixture project body.\n\n![External fixture image](https://example.com/images/external-fixture.png)")
  fixture.call("project.md", "_projects/check-hidden-project.md", { "title" => "Unpublished fixture", "published" => false }, "Hidden body.")
  fixture.call("publication.md", "_publications/check-paper.md", {
    "title" => "Fixture Paper", "authors" => ["Fixture Author", "Second", "Third", "Fourth"], "venue" => "Fixture Venue", "year" => 2025,
    "image" => "/images/people/ece-photo-placeholder.png", "image_alt" => "Fixture paper figure",
    "abstract" => "Fixture abstract text.", "award" => "Fixture Award", "paper_label" => "DOI"
  })
  fixture.call("publication.md", "_publications/check-hidden-paper.md", { "title" => "Unpublished fixture", "published" => false })
  fixture.call("post.md", "_posts/2020-01-02-check-post.md", { "title" => "Fixture Post" }, "Fixture post body.\n\n![Fixture image]({{ '/images/people/ece-photo-placeholder.png' | relative_url }})")
  fixture.call("post.md", "_posts/2020-01-03-check-hidden-post.md", { "title" => "Unpublished fixture", "published" => false })
  news = File.join(source, "news.md")
  File.write(news, File.read(news).sub("published: false", "published: true"))

  assert.call(system(RbConfig.ruby, File.join(source, "scripts/validate.rb")), "Fixture content validation failed")
  config = Jekyll.configuration("source" => source, "destination" => destination, "config" => File.join(source, "_config.yml"), "baseurl" => "/fixture", "quiet" => true)
  Jekyll::Site.new(config).process
  html = ->(path) { File.read(File.join(destination, path), encoding: "UTF-8") }
  people = html.call("people/index.html")
  assert.call(people.include?("Fixture Alumni") && people.include?("Fixture destination"), "Alumni must render from profile data")
  assert.call(people.include?("Fixture Student"), "New members must appear automatically")
  assert.call(people.include?('href="mailto:fixture-student@example.com"') && people.include?('href="mailto:fixture-alumni@example.com"'), "Member and alumni emails must render as mailto links")
  assert.call(!people.include?('href="mailto:"'), "Missing emails must not create empty links")
  year_labels = people.scan(/<h4 class="alumni-year-heading"[^>]*>(\d{4})<\/h4>/).flatten.map(&:to_i)
  assert.call(year_labels == year_labels.sort.reverse && year_labels.uniq == year_labels, "Alumni year groups must appear once each, newest first")
  year_2025 = people[/<section class="alumni-year" aria-labelledby="alumni-year-2025">.*?<\/section>/m]
  assert.call(year_2025 && year_2025.index("Alphabetical Fixture Alumnus") < year_2025.index("Fixture Alumni"), "Alumni in the same year must be alphabetized")
  assert.call(year_2025.include?('class="profile-thumbnail"') && year_2025.include?('href="mailto:fixture-alumni@example.com"'), "Year grouping must retain alumni photo cards and email links")
  profile = html.call("people/check-alumni/index.html")
  assert.call(profile.include?('href="mailto:fixture-alumni@example.com"'), "The profile must use the same email field")
  assert.call(profile.scan('data-action="zoom"').length == 1 && profile.include?("Fixture biography."), "Profile layout must render one photo and the biography")
  project = html.call("project/check-project/index.html")
  assert.call(project.include?("Fixture project body.") && project.include?('src="/fixture/images/people/ece-photo-placeholder.png"'), "Project pages and cover images must render")
  projects = html.call("project/index.html")
  assert.call(projects.include?('href="/fixture/project/check-project/"') && projects.include?("Fixture project summary."), "Project listing must link to the generated page")
  papers = html.call("publication/index.html")
  assert.call(papers.include?("Fixture Paper") && papers.include?("Fixture Author") && papers.include?("Fixture Venue"), "Publications must render from individual records")
  assert.call(papers.include?('src="/fixture/images/people/ece-photo-placeholder.png"') && papers.include?('alt="Fixture paper figure"'), "Publication thumbnails must support baseurl and alt text")
  assert.call(papers.include?('class="publication-abstract"') && papers.include?("Fixture abstract text.") && papers.include?("FIXTURE AWARD"), "Publication abstract and award must render")
  assert.call(papers.include?('class="publication-more-authors"') && papers.include?("Fourth"), "All authors must remain available in expandable lists")
  assert.call(papers.include?('src="/fixture/js/publications.js"'), "Publication filter must support baseurl")
  assert.call(!File.exist?(File.join(destination, "publications/check-paper/index.html")), "Publication records should not generate detail pages")
  news_html = html.call("news/index.html")
  assert.call(news_html.include?('href="/fixture/2020/01/02/check-post.html"'), "News listing must link to dated posts")
  post = html.call("2020/01/02/check-post.html")
  assert.call(post.include?("Fixture post body.") && post.include?('src="/fixture/images/people/ece-photo-placeholder.png"'), "Posts and figures must render")
  assert.call([projects, papers, news_html].none? { |text| text.include?("Unpublished fixture") }, "Unpublished records must stay out of listings")
  assert.call(!File.exist?(File.join(destination, "project/check-hidden-project/index.html")), "Unpublished projects must not generate pages")
  %w[templates docs scripts README.md CONTRIBUTING.md docker-compose.yml].each do |name|
    assert.call(!File.exist?(File.join(destination, name)), "Contributor resource was published: #{name}")
  end

  # Confirm a genuinely broken edit fails with an actionable filename.
  invalid_alumnus = File.join(source, "_people/check-alumni-earlier.md")
  valid_alumnus = File.read(invalid_alumnus)
  File.write(invalid_alumnus, valid_alumnus.sub("graduation_year: 2010", 'graduation_year: "2010"'))
  require "open3"
  year_output, year_status = Open3.capture2e(RbConfig.ruby, File.join(source, "scripts/validate.rb"))
  assert.call(!year_status.success? && year_output.include?("check-alumni-earlier.md") && year_output.include?("graduation_year"), "Graduation years must be validated as numbers")
  File.write(invalid_alumnus, valid_alumnus)
  invalid = File.join(source, "_projects/check-project.md")
  File.write(invalid, File.read(invalid).sub("/images/people/ece-photo-placeholder.png", "/images/projects/missing-fixture.png"))
  require "open3"
  output, status = Open3.capture2e(RbConfig.ruby, File.join(source, "scripts/validate.rb"))
  assert.call(!status.success? && output.include?("check-project.md") && output.include?("missing-fixture.png"), "Missing image validation must fail with the affected filename")
end
puts "Build checks passed: members, alumni, project pages, publication records, posts, images, unpublished content and tooling exclusions."
