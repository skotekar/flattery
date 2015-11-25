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
require "flattery/edgepairs.rb"

module Flattery
    
    class ReuniteTool
        def edge_face_transformation(edge)
            plane = Plane.new(edge.faces[0].plane)
            
            origin = edge.start.position
            x_vec = edge.line[1].normalize
            y_vec = plane.normal
            z_vec = x_vec * y_vec
            
            return Geom::Transformation.new(x_vec, y_vec, z_vec, origin)
        end
        
        def activate()
            @hover_edge = nil
            @pair_edges = []
        end
        
        def onMouseMove(flags, x, y, view)
            ph = view.pick_helper
            ph.do_pick x,y
            pick = ph.best_picked
            
            edge = pick && Flattery::edge?(pick) ? pick : nil
        
            if edge != @hover_edge
                @hover_edge = edge
            
                if edge
                    @pair_edges = Flattery::paired_edges(edge, edge.parent.entities, false) || []
                else
                    @pair_edges = []
                end
            
                view.invalidate
            end
        end
        
        def draw(view)
            @pair_edges.each do |edge|
                view.drawing_color = Sketchup::Color.new(255, 0, 0)
                view.line_width = 3
                x = view.screen_coords(edge.start.position)
                y = view.screen_coords(edge.end.position)
                view = view.draw2d(GL_LINES, [x,y])
            end
        end
        
        def count_verticies(entities)
            vertecies = Set.new
            entities.each do |e|
                if Flattery::edge?(e)
                    vertecies.insert(e.start)
                    vertecies.insert(e.end)
                end
            end
            return vertecies.length
        end
        
        def select_paired_edge(edge)
            if edge.faces.length != 1
                UI.beep
                Sketchup::set_status_text "Picked edge has #{edge.faces.length} faces.", SB_PROMPT
                return nil
            end
            pair_edges = Flattery::paired_edges(edge, edge.parent.entities, false)
            if pair_edges.length != 1
                UI.beep
                Sketchup::set_status_text "Picked edge has #{pair_edges.length} paired edges.", SB_PROMPT
                return nil
            end
            pair_edge = pair_edges[0]
            if pair_edge.faces.length != 1
                UI.beep
                Sketchup::set_status_text "Paired edge has #{pair_edge.faces.length} faces.", SB_PROMPT
                return nil
            end
            
            return pair_edge
        end
        
        # The onLButtonUp method is called when the user releases the left mouse button.
        def onLButtonUp(flags, x, y, view)
            ph = view.pick_helper
            ph.do_pick x,y
            pick = ph.best_picked
            
            if !pick
                view.model.selection.clear
                return
            end
            
            if Flattery::face?(pick)
                view.model.selection.toggle(pick)
                return
            end
            
            if Flattery::edge?(pick)
                pair_edge = select_paired_edge(pick)
                
                if !pair_edge
                    return
                end
                
                if view.model.selection.contains?(pick.faces[0])
                    transformation = edge_face_transformation(pair_edge) * edge_face_transformation(pick).inverse
                elsif view.model.selection.contains?(pair_edge.faces[0])
                    transformation = edge_face_transformation(pick) * edge_face_transformation(pair_edge).inverse
                else
                    UI.beep
                    Sketchup::set_status_text "Edge does not touch selected faces.", SB_PROMPT
                    return
                end
                
                @hover_edge = nil
                @pair_edges = []
                
                view.model.start_operation("Reunite Edge")
                
                group = pick.parent.entities.add_group(view.model.selection)
                group.transform!(transformation)
                
                vertex_count = count_verticies(group.entities)
                
                exploded = group.explode
                
                @ex = exploded
                
                if count_verticies(exploded) > vertex_count
                    UI.beep
                    Sketchup::set_status_text "A collision occured.", SB_PROMPT
                    view.model.abort_operation
                    return
                end
                
                view.model.commit_operation
            end
            
        end
    end
    
    $reunite_tool = ReuniteTool.new
    
end