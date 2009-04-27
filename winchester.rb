require 'erb'

module Winchester

  class Routes
    def add(path)
    end

    def routes
    end

    def self.find(req)
      path = req.env["REQUEST_PATH"].gsub(/^\//,'').split(/\//)
      if path.size == 1
        @controller = Home.new
        @action = path[0]
      else
        @controller = Kernel.const_get(path[0].capitalize).new
        @action = path[1]
      end
      @action = "index" if @action == ""
      
      return @controller, @action 
    end
  end

  class Dispatcher
    def initialize
      puts "Dispatcher Init"
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

      self.send(method_name.to_sym)

      if @render_text
        @render_text
      else
        render(method_name)
      end
    end

    def text(text)
      @render_text = text
    end

    def render(method_name)
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

  def test_text
    text "Lols #{Time.now}"
  end

end

class Blah < Winchester::Controller
  def foo
  end
end
