require 'erb'

module Winchester

  class Dispatcher
    def initialize
      puts "Init"
    end

    def call(env)
      req = Rack::Request.new(env)
      res = Rack::Response.new

      @controller = Home.new
      
      @method_name = req.env["REQUEST_PATH"].gsub(/^\//,'')
      @method_name = "index" if @method_name == ""

      res.write(@controller.render_page(@method_name, req.env))
      res.finish
    end

  end

  class Controller

    def render_page(method_name, env)
      @env = env

      render(method_name)
    end

    def render(method_name)
      #@params = params
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
      @error =  "also, missing method"
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

