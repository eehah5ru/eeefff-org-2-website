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


#
# hakyll logic
#
def _if cond, &block
  return "$if(#{cond})$\n#{yield}\n"
end

def _else &block
  return "$else$\n#{yield}\n"
end

def _endif
  return "$endif$\n"
end

def _for stmt, &block
  return "$for(#{stmt})$\n#{yield}\n"
end

def _endfor
  return "$endfor$\n"
end

def _participantName p_id
  return "$participantName(\"#{p_id}\")$"
end


#
#
# url helpers
#
#
def picture_url(file_name)
  return "/pictures/projects/$canonicalName$/" + file_name
end
