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
      if Dir.exist?(@cache_dir) && File.exist?(@cache_path)
        File.read(@cache_path)
      else
        nil
      end
    end

    def save(data)
      unless Dir.exist?(@cache_dir)
        Dir.mkdir(@cache_dir)
      end
      File.write(@cache_path, data)
    end

    def clear
      if File.exist?(@cache_path)
        File.delete(@cache_path)
      end
    end
  end
end
