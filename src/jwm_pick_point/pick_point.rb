# Pick_point.rb
# load "jwm_pick_point/pick_point.rb"
# (c) John McClenahan April 2014
# This code borrows extensively from an original point.rb plugin to draw a series of points
#----------------------------------------------------------------------
# (c) Matt666 Sept. 2008

# Permission to use, copy, modify, and distribute this software for 
# any purpose and without fee is hereby granted, provided that the above
# copyright notice appear in all copies.
#------------------------------------------------------------------------
# Pick or enter a point to act as the centre to draw a 3D Shape
#V1.04

class PickPointTool
	def initialize
		@ip1 = nil
		@ip2 = nil
		@xdown = 0
		@ydown = 0
	end

	def activate
		Sketchup.active_model.start_operation "PickPoint"
		@ip = Sketchup::InputPoint.new
		@ip1 = Sketchup::InputPoint.new
		@drawn = false
		
    # Testing
    cursor_name = "tetra hedron.png"
    if Sketchup.active_model.rendering_options["HideConstructionGeometry"] == true 
			##Sketchup.active_model.rendering_options["HideConstructionGeometry"] = false 
		end
    cursor_img = File.join(File.dirname(__FILE__),cursor_name)
 p "Cursor file loaded = " + cursor_img    
    @cursor_id = UI::create_cursor(cursor_img, 0,0)
#p "dodeca_cursor = " + @cursor_id.inspect  
		self.reset(nil)
	end
   
	def deactivate(view)
		view.invalidate if @drawn
	end
  
  def onSetCursor
    UI.set_cursor(@cursor_id)
  end
	
	def onCancel(flag, view)
    # Complete operation and change to SelectionTool
		Sketchup.active_model.commit_operation
		Sketchup.send_action "selectSelectionTool:"
	end
  
	def reset(view)
    @state = 0
		Sketchup::set_status_text("Pick centre point for shape or type (absolute) coordinates  x,y,z in VCB", SB_PROMPT)
    Sketchup::set_status_text("Centre at x,y,z", SB_VCB_LABEL)
		@ip.clear
		@ip1.clear

		if view
			view.tooltip = nil
			view.invalidate if @drawn
		end

		@drawn = false
		@dragging = false
	end
	
	def onMouseMove(flags, x, y, view)
		case @state
		
			when 0
			@ip.pick view, x, y
			if @ip != @ip1
				view.invalidate if @ip.display? or @ip1.display?
				@ip1.copy! @ip
				view.tooltip = @ip1.tooltip
			end
			view.tooltip = nil
		end
	end

	def onLButtonDown(flags, x, y, view)
		case @state
			when 0
			@ip1.pick view, x, y
			if @ip1.valid?
				@state = 1
        self.create_geometry(@ip1.position, view)

		    Sketchup::set_status_text("Pick centre point for shape or type (absolute) coordinates  x,y,z in VCB", SB_PROMPT)

				@xdown = x
				@ydown = y
			end
    end
		view.lock_inference
	end

	def onLButtonUp(flags, x, y, view)
		# if @dragging && @ip2.valid?
			#self.create_geometry(@ip1.position, view)
			# self.reset(view)
		end
	end

	def onKeyDown(key, repeat, flags, view)
		if key == CONSTRAIN_MODIFIER_KEY && repeat == 1
			@shift_down_time = Time.now
			if( view.inference_locked? )
				view.lock_inference
			elsif @state == 0 && @ip1.valid?
				view.lock_inference @ip1
				view.line_width = 3
			end
		end
	end

	def onKeyUp(key, repeat, flags, view)
		view.lock_inference if key == CONSTRAIN_MODIFIER_KEY && view.inference_locked? && (Time.now - @shift_down_time) > 0.5
	end

	def onUserText(text, view)
    # Get text string and try to convert to 3D point coordinate
		begin
      pt = []
      pt = text.split(",") # This line would need modifying for non-English locales. I don't know how to do detect locale

      for i in 0..2 
        pt[i] = pt[i].to_l
      end

      pt1 = Geom::Point3d.new(pt)
    self.create_geometry(pt1, view)
		rescue
		  UI.messagebox "Cannot convert #{text} to coordinates of a point\n Please try again, or pick a point"
		  value = nil
		  Sketchup::set_status_text "", SB_VCB_VALUE
		end

	end
  
	def draw(view)
	    if @ip1.valid?
			if @ip1.display?
				@ip1.draw(view)
				@drawn = true
# p "@ip1 = " + @ip1.inspect
       # self.create_geometry(@ip1, view)
			end
			#if @ip2.valid?
			#	@ip2.draw(view) if @ip2.display?
			#	view.set_color_from_line(@ip1, @ip2)
			#	self.draw_geometry(@ip1.position, view)
			#	@drawn = true
			#  end
		end
	end

	def create_geometry(p1, view)
    # Simple geometry to draw - just a construction point
		view.model.active_entities.add_cpoint(p1)
		Sketchup::set_status_text("Centre point selected. Set size in dialogue", SB_PROMPT)
    view.tooltip = nil
	end

	def draw_geometry(pt1,  view)
    
		view.draw_cpoint(pt1)
	end
	
	def PickPointTool.tool
		Sketchup.active_model.select_tool PickPointTool.new
	end
end

if not file_loaded?("pick_point.rb")
   UI.menu("Draw").add_item("Pick Point") {PickPointTool.tool}
end
file_loaded("pick_point.rb")