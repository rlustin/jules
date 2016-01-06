require 'rubygems'
require 'mustache'

module Jules
  # Template for gallery
  class Gallery < Mustache
    def initialize(gallery)
      @gallery = gallery
    end

    def title
      @gallery[:title]
    end

    def photos
      @gallery[:photos]
    end

    def zip
      @gallery[:zip]
    end
  end
end
