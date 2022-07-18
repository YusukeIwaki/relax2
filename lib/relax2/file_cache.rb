# frozen_string_literal: true

module Relax2
  class FileCache
    def initialize(dirname, filename)
      @cache_dir = cache_dir(dirname)
      @cache_path = File.join(@cache_dir, filename)
    end

    private def cache_dir(name)
      if Gem.win_platform?
        File.join(Dir.home, 'AppData', 'Roaming', name)
      else
        File.join(Dir.home, ".#{name}")
      end
    end

    def load
      File.read(@cache_path) if Dir.exist?(@cache_dir) && File.exist?(@cache_path)
    end

    def save(data)
      Dir.mkdir(@cache_dir) unless Dir.exist?(@cache_dir)
      File.write(@cache_path, data)
    end

    def clear
      File.delete(@cache_path) if File.exist?(@cache_path)
    end
  end
end
