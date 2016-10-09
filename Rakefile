require 'fileutils'
require 'pathname'
require_relative 'jules/gallery'
require_relative 'jules/photo'
require_relative 'jules/zip'

task default: %w(install build)

desc 'Install assets'
task :install do
  sh 'node_modules/bower/bin/bower install --allow-root'

  current_dir = File.dirname(__FILE__)
  assets_dir = "#{current_dir}/build/assets"

  FileUtils.remove_dir(assets_dir, true)
  FileUtils.mkdir_p(assets_dir)

  puts 'Linking vendors assets...'
  vendor_dir = FileUtils.mkdir_p("#{assets_dir}/vendor").first
  Dir.glob('bower_components/*/dist') do |dir|
    next if dir == '.' || dir == '..'
    FileUtils.ln_s(
      "#{current_dir}/#{dir}",
      "#{vendor_dir}/#{dir.split('/')[1]}"
    )
  end

  puts 'Linking application assets...'
  FileUtils.ln_s("#{current_dir}/jules/assets", "#{assets_dir}/app")

  puts 'Done!'
end

desc 'Build all galleries in /photos'
task :build do
  Dir.foreach('photos') do |dir|
    next if dir == '.' || dir == '..'
    Rake::Task[:build_dir].reenable
    Rake::Task[:build_dir].invoke("photos/#{dir}")
  end
end

desc 'Build a gallery from a directory'
task :build_dir, :source_dir do |_, args|
  reset = "\r\e[0K"
  source_dir = args.source_dir

  puts "Building #{source_dir}..."

  gallery_slug = Pathname.new(source_dir).basename.to_s
  gallery_build_dir = "build/#{gallery_slug}"

  FileUtils.remove_dir(gallery_build_dir, true)
  FileUtils.mkdir_p("#{gallery_build_dir}/original")
  FileUtils.mkdir_p("#{gallery_build_dir}/thumbnail")

  photos = []

  sources = Dir.glob("#{source_dir}/*.{jpg,JPG}").sort

  i = 0
  n = sources.count

  sources.each do |photo|
    begin
      photos.push(Jules::Photo.new(gallery_build_dir, photo).generate)
    rescue => e
      puts "#{reset}Error #{e} for #{photo}"
    ensure
      print "#{reset}Creating thumbnails... [#{i += 1}/#{n}]"
    end
  end

  puts "\n"

  puts "#{reset}Creating zip..."
  Jules::Zip.new(source_dir, "#{gallery_build_dir}/#{gallery_slug}.zip").write

  gallery = {
    title:  gallery_slug.tr('_', ' '),
    photos: photos,
    zip:    "#{gallery_slug}.zip"
  }

  File.open("#{gallery_build_dir}/index.html", 'w') do |index|
    index.write(Jules::Gallery.new(gallery).render)
  end
end
