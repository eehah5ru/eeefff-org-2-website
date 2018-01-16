require "redcarpet"
require "slim/include"

Slim::Engine.set_options(:disable_escape => true)

def include_file f
  File.read f
end

def markdown(text)
  rc = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  rc.render(text)
end

def _partial what
  return "$partial(\"#{what}\")$\n"
end
