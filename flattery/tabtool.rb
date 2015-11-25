# Copyright (c) 2010 Andrew Stoneman
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
# 
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.


require "flattery/utils.rb"

module Flattery

    class TabTool
        @@tab_width = 0.25
        
        def reset(view)
            @hover_edge = nil
            @pair_edges = []
            @active_edge = nil
            @active_plane = nil
            @xdown = 0
            @ydown = 0
            @width = 0
            @inset = 0
            @dragging = false
            
            if view
                view.invalidate
            end
        end
        
        def update_flags(flags, view)
        end
        
        def width_and_inset(line, symmetric = true)
            point = @edge_transformation * @active_plane.intersect_line(line)
            width = point.distance_to_line(@active_edge.line)
            inset = (point - @active_edge.start.position).dot(@active_edge.line[1].normalize)
            
            return [width, inset]
        end
        
        #|-------------------| <- inset
        #                __--\     ---
        #            __--     \     |
        #        __--          \    | <- width
        #    __--               \   |
        #__--                    \  |
        #------------------------- ---
        def triangle_tab(edge, width, inset, draw_view=nil, draw_reversed=false)
            if !edge || edge.faces.length != 1
                return
            end
            
            face = edge.faces[0]
            plane = Flattery::plane_for_entity(face)
            start_pt = edge.start.position
            end_pt = edge.end.position
            x_vec = edge.line[1].normalize #Along the edge
            length = edge.length
            if edge.reversed_in?(face) ^ draw_reversed
                x_vec.reverse!
                start_pt, end_pt = end_pt, start_pt
                inset = length - inset #Inset is measured from edge.start, regardless of reversedness
            end
            y_vec = x_vec * plane.normal  #Perpendicular to the edge, away from the face
            z_vec = plane.normal
            
            transformation = Geom::Transformation.new(x_vec, y_vec, z_vec, start_pt)
            
            
            
            p1 = start_pt
            p2 = transformation * [inset, width, 0]
            p3 = end_pt
            
            if draw_view
                transformations = Flattery::transformations_for_entity(edge)
                transformations.each do |t|
                    draw_view.draw_polyline(t * p1, t * p2, t * p3)
                end
            else
                edge.model.start_operation("Add Tab")
                edge.parent.entities.add_face([p1,p2,p3])
                edge.model.commit_operation
            end
        end
        
        
        #|--| <- inset       -> |--|
        #   /-------------------\
        #  /   |                 \
        # /    | <- width         \
        #/     |                   \
        #----------------------------
        def trapezoid_tab(edge, width, inset, draw_view=nil, draw_reversed=false)
            if !edge || edge.faces.length != 1
                return
            end
            
            length = edge.length
            
            if length <= inset * 2
                inset = length - inset
            end
            
            face = edge.faces[0]
            plane = Flattery::plane_for_entity(face)
            start_pt = edge.start.position
            end_pt = edge.end.position
            x_vec = edge.line[1].normalize #Along the edge
            if edge.reversed_in?(face) ^ draw_reversed
                x_vec.reverse!
                start_pt, end_pt = end_pt, start_pt
            end
            y_vec = x_vec * plane.normal  #Perpendicular to the edge, away from the face
            z_vec = plane.normal
            
            transformation = Geom::Transformation.new(x_vec, y_vec, z_vec, start_pt)
            
            
            p1 = start_pt
            p2 = transformation * [inset, width, 0]
            p3 = transformation * [length - inset, width, 0]
            p4 = end_pt
            
            if draw_view
                transformations = Flattery::transformations_for_entity(edge)
                transformations.each do |t|
                    draw_view.draw_polyline(t * p1, t * p2, t * p3, t * p4)
                end
            else
                edge.model.start_operation("Add Tab")
                edge.parent.entities.add_face([p1,p2,p3,p4])
                edge.model.commit_operation
            end
        end
        
        def tab(edge, width, inset, draw_view=nil, draw_reversed=false)
            if @trapezoid
                trapezoid_tab(edge, width, inset, draw_view, draw_reversed)
            else
                triangle_tab(edge, width, inset, draw_view, draw_reversed)
            end
        end
        
        def auto_tab(edge)
            if @trapezoid
                if edge.length >= @@tab_width * 2
                    trapezoid_tab(edge, @@tab_width, @@tab_width)
                else
                    triangle_tab(edge, edge.length/2, edge.length/2)
                end
            else
                triangle_tab(edge, @@tab_width, edge.length/2)
            end
        end
        
        def activate()
            @hover_edge = nil
            @pair_edges = []
            @trapezoid = true
            reset(nil)
        end
        
        def onMouseMove(flags, x, y, view)
            update_flags(flags, view)
            ph = view.pick_helper
            ph.do_pick x,y
            
            if @active_edge
                if( (x-@xdown).abs > 10 || (y-@ydown).abs > 10 )
                    @dragging = true
                end
                
                if @dragging
                    ray = view.pickray(x,y)
                    @width, @inset = width_and_inset(ray)
                    Sketchup::set_status_text("#{@width.to_l}, #{@inset.to_l}", SB_VCB_VALUE)
                    view.invalidate
                end
            else
                edge = ph.picked_edge
            
                if edge != @hover_edge
                    @hover_edge = edge
                
                    if edge
                        @pair_edges = Flattery::paired_edges(edge) || []
                    else
                        @pair_edges = []
                    end
                
                    view.invalidate
                end
            end
        end
        
        def draw(view)
            if @active_edge && @dragging
                
                
                tab(@active_edge, @width, @inset, view)
                @pair_edges.each do |edge|
                    view.drawing_color = Sketchup::Color.new(255, 0, 0)
                    tab(edge, @width, @inset, view, true)
                end
            else
                @pair_edges.each do |edge|
                    view.drawing_color = Sketchup::Color.new(255, 0, 0)
                    view.line_width = 3
                    Flattery::transformations_for_entity(edge).each do |transformation|
                        x = view.screen_coords(transformation * edge.start.position)
                        y = view.screen_coords(transformation * edge.end.position)
                        view = view.draw2d(GL_LINES, [x,y])
                    end
                end
            end
        end
        
        
        def onLButtonDown(flags, x, y, view)
            update_flags(flags, view)
            
            if @active_edge:
                if @dragging
                    ray = view.pickray(x,y)
                    width, inset = width_and_inset(ray)
                    
                    tab(@active_edge, width, inset)
                else
                    auto_tab(@active_edge)
                end
                reset(view)
                return
            end
            
            reset(view)
            ph = view.pick_helper
            ph.do_pick x,y
            edge = ph.picked_edge
            
            if edge && edge.faces.length == 1
                @active_edge = edge
                @xdown = x
                @ydown = y
                
                face = edge.faces[0]
                @active_plane = Flattery::plane_for_entity(face)
                @pair_edges = Flattery::paired_edges(edge) || []
                
                (0..ph.count-1).each do |i|
                    if ph.leaf_at(i) == edge
                        @edge_transformation = ph.transformation_at(i).inverse
                        @active_plane.transform!(ph.transformation_at(i))
                    end
                end
            end
        end
        
        def onLButtonUp(flags, x, y, view)
            update_flags(flags, view)
            if @active_edge && @dragging:
                ray = view.pickray(x,y)
                width, inset = width_and_inset(ray)
                    
                tab(@active_edge, width, inset)
                reset(view)
            end
        end
        
        def onLButtonDoubleClick(flags, x, y, view)
            update_flags(flags, view)
            if @active_edge:
                auto_tab(@active_edge)
                reset(view)
            end
        end
        
        def onUserText(text, view)
            if !@active_edge
                return
            end

            # The user may type in something that we can't parse as a length
            # so we set up some exception handling to trap that
            
            bits = text.split(",")
            
            if bits.length > 2
                UI.beep
                Sketchup::set_status_text "Too many values.", SB_PROMPT
                Sketchup::set_status_text "", SB_VCB_VALUE
                return
            elsif bits.length == 2
                begin
                    width = bits[0].strip.to_l
                    inset = bits[1].strip.to_l
                rescue
                    # Error parsing the text
                    UI.beep
                    Sketchup::set_status_text "Cannot convert #{text} to Lengths", SB_PROMPT
                    Sketchup::set_status_text "", SB_VCB_VALUE
                    return
                end
            else
                begin
                    width = bits[0].strip.to_l
                rescue
                    # Error parsing the text
                    UI.beep
                    Sketchup::set_status_text "Cannot convert #{text} to a Length", SB_PROMPT
                    Sketchup::set_status_text "", SB_VCB_VALUE
                    return
                end
                
                if @trapezoid
                    inset = width
                else
                    inset = @active_edge.length / 2
                end
            end
            
            tab(@active_edge, width, inset)
            
            self.reset(view)
        end
        
        def onKeyDown(key, repeat, flags, view)
            if key == VK_CONTROL
                @trapezoid = !@trapezoid
                view.invalidate
            end
        end
        
        def onKeyUp(key, repeat, flags, view)
            update_flags(flags, view)
        end
        
        def onCancel(flag, view)
            reset(view)
        end
    end
    
    $tab_tool = TabTool.new
    
    
end