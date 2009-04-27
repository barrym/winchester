require 'erb'

module Winchester

  class Routes
    def add(path)
    end

    def routes
    end

    def self.find(req)
      #controller = Home.new if controller.nil?

      path = req.env["REQUEST_PATH"].gsub(/^\//,'').split(/\//)
      if path.size == 1
        @controller = Home.new
        @action = path[0]
      else
        @controller = Kernel.const_get(path[0].capitalize).new
        @action = path[1]
      end
      @action = "index" if @action == ""
      
      # action = req.env["REQUEST_PATH"].gsub(/^\//,'')
      # action = "index" if action == ""
      return @controller, @action 
    end
  end

  class Dispatcher
    def initialize
      puts "Init"
    end

    def call(env)
      req = Rack::Request.new(env)
      res = Rack::Response.new

      controller, action = Routes.find(req)

      res.write(controller.render_page(action, req.env))
      res.finish
    end

  end

  class Controller

    def render_page(method_name, env)
      @env = env

      render(method_name)
    end

    def render(method_name)
      self.send(method_name.to_sym)
      file_name = "#{method_name}.html.erb"

      if File.exist?(file_name)
        contents = ERB.new(File.read(file_name))
        contents.result(binding)
      else
        "Missing template file #{file_name} :: #{@error}"
      end
    end

    def method_missing(symbol, *args)
      @error =  "<p>also, missing method #{symbol}</p>"
    end 

    def params
      @env
    end
  end

end

class Home < Winchester::Controller
  def index
  end

  def foo
    @name = "Barry"
  end

end

class Blah < Winchester::Controller
  def foo
  end
end
