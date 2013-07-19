module Jasmine
  class Configuration
    attr_writer :jasmine_css_files, :css_files
    attr_writer :jasmine_files, :boot_files, :src_files, :spec_files
    attr_accessor :jasmine_path, :spec_path, :boot_path, :src_path, :image_path
    attr_accessor :jasmine_dir, :spec_dir, :boot_dir, :src_dir, :images_dir
    attr_accessor :formatters
    #TODO: these are largely client concerns, move them.
    attr_accessor :port, :browser, :host, :result_batch_size
    attr_accessor :selenium_server, :selenium_server_port, :webdriver
    attr_accessor :junit_xml_path
    attr_accessor :spec_format, :jasmine_port

    def initialize()
      @rack_paths = {}
      @apps = []
      @path_mappers = []
      @jasmine_css_files = lambda { [] }
      @css_files = lambda { [] }
      @jasmine_files = lambda { [] }
      @boot_files = lambda { [] }
      @src_files = lambda { [] }
      @spec_files = lambda { [] }

      @formatters = [Jasmine::Formatters::Console]

      @browser = 'firefox'
      @junit_xml_path = Dir.getwd
      @jasmine_port = 8888
    end

    def css_files
      map(@jasmine_css_files, :jasmine) +
        map(@css_files, :src)
    end

    def js_files
      map(@jasmine_files, :jasmine) +
        map(@boot_files, :boot) +
        map(@src_files, :src) +
        map(@spec_files, :spec)
    end

    def rack_path_map
      {}.merge(@rack_paths)
    end

    def add_rack_path(path, rack_app_lambda)
      @rack_paths[path] = rack_app_lambda
    end

    def rack_apps
      [] + @apps
    end

    def add_rack_app(app, &block)
      @apps << [app, block]
    end

    def add_path_mapper(mapper)
      @path_mappers << mapper.call(self)
    end

    def port
      @port ||= Jasmine.find_unused_port
    end

    def host
      @host || 'http://localhost'
    end

    def result_batch_size
      @result_batch_size || 50
    end

    private

    def map(paths, type)
      @path_mappers.inject(paths.call)  do |paths, mapper|
        if mapper.respond_to?("map_#{type}_paths")
          mapper.send("map_#{type}_paths", paths)
        else
          paths
        end
      end
    end

  end
end
