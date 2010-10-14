
module Rednode
  class Process < EventEmitter
    include Constants
    include Namespace
    attr_reader :global, :env

    def initialize(node)
      @node = node
      @engine = node.engine
      @global = @engine.scope
      @bindings = {}
      @env = Env.new
    end

    def binding(id)
      if @bindings[id]
        @bindings[id]
      elsif Rednode::Bindings::const_defined?(pascalize(id))
        @bindings[id] = Rednode::Bindings::const_get(pascalize(id)).new
      elsif id == "natives"
        exports = @engine['Object'].new
        for native in Dir["#{NODE_HOME}/lib/*.js"]
          File.basename(native) =~ /^(.*)\.js$/
          exports[$1] = File.read(native)
        end
        @bindings[id] = exports
      else
        raise "no such module: #{id}"
      end
    end

    def compile(source, filename)
      @engine.eval(source, filename)
    end

    def argv
      ['rednode', @node.main]
    end

    def cwd(*args)
      Dir.pwd
    end

    def chdir(dirname)
      Dir.chdir(dirname)
    end

    def _byteLength(str, encoding = 'utf8')
      chars = encoding == 'utf8' ? str.unpack('C*') : str.unpack('U*')
      chars.length
    end

    #TODO: find a good place to read this.
    def version
      "0.2.0"
    end

    def loop(*args)
    end

    def dlopen(filename, exports)
      raise "Rednode currently can't read native (.node) modules. Failed to load: #{filename}"
    end

    class Env
      def [](property)
        ENV.has_key?(property) ? ENV[property] : yield
      end
    end

    class Timer
    end

    EventEmitter = self.superclass
    
  private

    def pascalize(str)
      str.gsub(/(_|^)(\w)/) {$2.upcase}
    end    
    
  end
end