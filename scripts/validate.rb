# frozen_string_literal: true

# Run with the site's existing Docker runtime; no additional gems are needed.
require "yaml"
require "date"
require "pathname"

root = File.expand_path("..", __dir__)
errors = []
counts = {}

read_yaml = lambda do |text, label|
  YAML.safe_load(text, permitted_classes: [Date, Time], aliases: false)
rescue Psych::Exception => e
  errors << "#{label}: invalid YAML (#{e.message.lines.first.strip})"
  nil
end

nonempty = ->(value) { value.is_a?(String) && !value.strip.empty? }
year_valid = ->(value) { value.is_a?(Integer) && value.between?(1900, 2200) }
asset = lambda do |value, label, prefix = nil|
  next if value.nil? || value == ""
  unless value.is_a?(String)
    errors << "#{label}: asset path must be text"
    next
  end
  path = prefix ? "#{prefix}/#{value}" : value
  unless path.start_with?("/") && !path.include?("\\") && !path.split("/").include?("..")
    errors << "#{label}: use a root-relative asset path (for example /images/projects/name/figure.jpg)"
    next
  end
  errors << "#{label}: missing file #{path}" unless File.file?(File.join(root, path.delete_prefix("/")))
end

roles = read_yaml.call(File.read(File.join(root, "_data/roles.yml")), "_data/roles.yml")
role_ids = []
if roles.is_a?(Array)
  roles.each do |role|
    unless role.is_a?(Hash) && nonempty.call(role["id"]) && nonempty.call(role["label"])
      errors << "_data/roles.yml: each role needs id and label"
      next
    end
    role_ids << role["id"]
  end
  errors << "_data/roles.yml: duplicate role IDs" unless role_ids.uniq == role_ids
else
  errors << "_data/roles.yml: expected a list"
end

navigation = read_yaml.call(File.read(File.join(root, "_data/navigation.yml")), "_data/navigation.yml")
unless navigation.is_a?(Array) && navigation.all? { |entry| entry.is_a?(Hash) && nonempty.call(entry["name"]) && nonempty.call(entry["href"]) }
  errors << "_data/navigation.yml: each menu entry needs name and href"
end

slides = read_yaml.call(File.read(File.join(root, "_data/slideshow.yml")), "_data/slideshow.yml")
if slides.is_a?(Array)
  paths = []
  slides.each_with_index do |slide, index|
    label = "_data/slideshow.yml entry #{index + 1}"
    unless slide.is_a?(Hash) && nonempty.call(slide["path"]) && nonempty.call(slide["alt"])
      errors << "#{label}: path and alt text are required"
      next
    end
    paths << slide["path"]
    asset.call(slide["path"], label)
  end
  errors << "_data/slideshow.yml: duplicate image paths" unless paths.uniq == paths
else
  errors << "_data/slideshow.yml: expected a list (use [] for an empty slideshow)"
end

required = {
  "_people" => %w[name position],
  "_projects" => %w[title summary],
  "_publications" => %w[title venue],
  "_posts" => %w[title]
}
required.each do |folder, fields|
  files = Dir.glob(File.join(root, folder, "**", "*.md")).sort
  counts[folder] = files.length
  files.each do |file|
    label = Pathname.new(file).relative_path_from(Pathname.new(root)).to_s
    source = File.read(file, encoding: "UTF-8")
    match = source.match(/\A---\s*\r?\n(.*?)\r?\n---\s*(?:\r?\n|\z)/m)
    unless match
      errors << "#{label}: add YAML front matter between --- lines"
      next
    end
    data = read_yaml.call(match[1], label)
    unless data.is_a?(Hash)
      errors << "#{label}: front matter must contain named fields"
      next
    end
    fields.each { |field| errors << "#{label}: #{field} is required" unless nonempty.call(data[field]) }
    if data.key?("published") && ![true, false].include?(data["published"])
      errors << "#{label}: published must be true or false, without quotes"
    end
    case folder
    when "_people"
      if data["email"] && data["email"] != "" && !(data["email"].is_a?(String) && data["email"].match?(/\A[^\s@<>:]+@[^\s@<>:]+\.[^\s@<>:]+\z/))
        errors << "#{label}: email must be an address such as name@umich.edu, or null"
      end
      errors << "#{label}: position must be one of #{role_ids.join(', ')}" unless role_ids.include?(data["position"])
      if data["position"] != "alumni" || !data["joined"].nil?
        errors << "#{label}: joined must be a four-digit year" unless year_valid.call(data["joined"])
      end
      if data["avatar"] && !(nonempty.call(data["avatar"]) && File.basename(data["avatar"]) == data["avatar"])
        errors << "#{label}: avatar must be a filename from images/people/, or null"
      else
        asset.call(data["avatar"], label, "/images/people")
      end
      if data["position"] == "alumni"
        errors << "#{label}: alumni need previous_role" unless nonempty.call(data["previous_role"])
        errors << "#{label}: alumni need graduation_year (a four-digit year)" unless year_valid.call(data["graduation_year"])
        if year_valid.call(data["graduation_year"]) && year_valid.call(data["joined"]) && data["graduation_year"] < data["joined"]
          errors << "#{label}: graduation_year cannot be before joined"
        end
        if data["left"] && !year_valid.call(data["left"])
          errors << "#{label}: left must be a four-digit year when provided"
        end
        if year_valid.call(data["left"]) && year_valid.call(data["joined"]) && data["left"] < data["joined"]
          errors << "#{label}: left cannot be before joined"
        end
      end
    when "_projects"
      errors << "#{label}: order must be a number" if data.key?("order") && !data["order"].is_a?(Numeric)
      if data["image"]
        asset.call(data["image"], label)
        errors << "#{label}: image_alt is required when image is set" unless nonempty.call(data["image_alt"])
      end
    when "_publications"
      if data["image"]
        asset.call(data["image"], label)
        errors << "#{label}: image_alt is required when image is set" unless nonempty.call(data["image_alt"])
      end
      %w[abstract award location paper_label].each do |field|
        errors << "#{label}: #{field} must be text or null" if data[field] && !nonempty.call(data[field])
      end
      errors << "#{label}: year must be a four-digit year" unless year_valid.call(data["year"])
      unless data["authors"].is_a?(Array) && !data["authors"].empty? && data["authors"].all? { |author| nonempty.call(author) }
        errors << "#{label}: authors must be a nonempty YAML list of names"
      end
      asset.call(data["pdf"], label)
      %w[paper_url code_url].each do |field|
        if data[field] && !(data[field].is_a?(String) && data[field].match?(%r{\Ahttps?://\S+\z}))
          errors << "#{label}: #{field} must be an http(s) URL or null"
        end
      end
    when "_posts"
      name = File.basename(file)
      begin
        raise ArgumentError unless name.match?(/\A\d{4}-\d{2}-\d{2}-.+\.md\z/)
        Date.iso8601(name[0, 10])
      rescue ArgumentError
        errors << "#{label}: filename must be YYYY-MM-DD-title.md with a valid date"
      end
    end
    # Check local images/downloads in body text, including Liquid relative_url expressions.
    body = source[match.end(0)..].gsub(/<!--.*?-->/m, "")
    body.scan(%r{(?:\A|[\s'"(=])(/(?:images|files)/[^\s'"<>\)\}]+)}).flatten.uniq.each { |path| asset.call(path, label) }
  end
end

if errors.empty?
  puts "Content checks passed: #{counts.map { |name, count| "#{count} #{name}" }.join(', ')}; #{slides.length} slides."
else
  warn errors.map { |error| "ERROR: #{error}" }.join("\n")
  exit 1
end
