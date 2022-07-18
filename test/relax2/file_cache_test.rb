# frozen_string_literal: true

require 'minitest/autorun'
require 'relax2/base'
require 'fileutils'

module Relax2
  class FileCacheTest < Minitest::Test
    def test_load_save_clear
      FileUtils.rm_rf(File.join(Dir.home, '.test_load_save_clear'))

      cache = ::Relax2::FileCache.new('test_load_save_clear', 'filename123')
      assert_nil cache.load
      cache.save('hogehoge')
      assert_equal 'hogehoge', cache.load
      cache.clear
      assert_nil cache.load

      FileUtils.rm_rf(File.join(Dir.home, '.test_load_save_clear'))
    end

    def test_exclusiveness
      FileUtils.rm_rf(File.join(Dir.home, '.test_exclusiveness'))

      foo = ::Relax2::FileCache.new('test_exclusiveness', 'foo')
      bar = ::Relax2::FileCache.new('test_exclusiveness', 'bar')
      foo.save('foo')
      bar.save('bar')
      assert_equal 'foo', foo.load
      foo.clear
      assert_equal 'bar', bar.load

      FileUtils.rm_rf(File.join(Dir.home, '.test_exclusiveness'))
    end
  end
end
