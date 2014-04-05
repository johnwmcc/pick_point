# Copyright 2014 Trimble Navigation Ltd and John McClenahan.
#
# License: The MIT License (MIT)
#
# A SketchUp Ruby Extension to pick an origin point, preparatory to creating  shape objects.  

require "sketchup.rb"
require "extensions.rb"

module CommunityExtensions
  module PickPoint

    # Create the extension.
    loader = File.join(File.dirname(__FILE__), "jwm_pick_point", "pick_point.rb")
    extension = SketchupExtension.new("Pick Point", loader)
    extension.description = "Pickpoint script"
    extension.version     = "1.04"
    extension.creator     = "John McClenahan"
    extension.copyright   = "2014, Trimble Navigation Limited and " <<
                            "John W McClenahan"

    # Register the extension with so it shows up in the Preference panel.
    Sketchup.register_extension(extension, true)

  end # module PickPoint
end # module CommunityExtensions
