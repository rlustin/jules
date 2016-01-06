require 'rubygems'
require 'fileutils'
require 'pathname'
require 'rmagick'

module Jules
  # Generate photo
  class Photo
    def initialize(build_dir, photo)
      @paths = {}
      @build_dir = build_dir
      @photo = photo
      @original_file = Pathname.new(@photo)
      @img = Magick::Image.read(@photo).first
    end

    def generate
      @paths = {
        original:  copy_original,
        thumbnail: generate_image('450x450'),
        medium:    generate_image('1500x1500')
      }
      info = informations
      @img.destroy!
      info
    end

    private

    def copy_original
      path = "original/#{@original_file.basename}"
      FileUtils.copy(
        @original_file,
        "#{@build_dir}/#{path}"
      )
      path
    end

    def generate_image(size)
      path = "#{size}/#{@original_file.basename}"
      FileUtils.mkdir_p("#{@build_dir}/#{size}")
      resized = @img.change_geometry(size) do |cols, rows, image|
        image.resize(cols, rows)
      end
      resized.write("#{@build_dir}/#{path}")
      resized.destroy!
      path
    end

    def informations
      {
        filename: @original_file.basename.to_s,
        title:    @photo.to_s,
        width:    @img.columns,
        height:   @img.rows,
        portrait: @img.columns < @img.rows,
        paths:    @paths
      }
    end
  end
end
