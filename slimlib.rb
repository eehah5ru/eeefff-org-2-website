Slim::Engine.set_options(:disable_escape => true)

def _partial what
  return "$partial(\"#{what}\")$\n"
end
