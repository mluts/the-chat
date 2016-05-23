require 'optparse'
require 'rack'
require 'thin'

module TheChat
  module CLI
    module_function

    def root
      @root ||= Pathname.new(File.expand_path('../../..', __FILE__))
    end

    def public
      root.join 'public'
    end

    def app
      @app ||= Rack::Builder.new do
        map '/api' do
          run TheChat::API
        end

        use Rack::Static, urls: ['/js', '/css'],
                          root: TheChat::CLI.public,
                          index: 'index.html'

        run lambda { |env| [404, {'Content-Type' => 'text/plain'}, ['Not Found']] }
      end
    end

    def run(argv)
      @argv = argv.dup
      @rack_options = {
        app: TheChat::CLI.app
      }
      parse!(@argv)
      Rack::Server.start(@rack_options)
    end

    def parse!(argv)
      OptionParser.new do |opts|
        opts.banner = "Usage: the-chat [options]"

        opts.on '-bHOST', 'Listen on HOST' do |host|
          @rack_options[:Host] = host
        end

        opts.on '-pPORT', 'Use PORT' do |port|
          @rack_options[:Port] = port
        end

        opts.on '-h', '--help' do
          abort opts.to_s
        end
      end.parse!(argv)
    end

    def public_path
    end
  end
end
