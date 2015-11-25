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
    
    class UnfoldTool
        
        def activate
            Flattery::label_edges()
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
        
            if view.model.selection.empty? || flags & CONSTRAIN_MODIFIER_KEY != 0
                view.model.selection.toggle(pick)
                return
            end
        
            view.model.start_operation("Unfold faces")
        
            entities = []
        
            view.model.selection.each {|selection|
                if Flattery::face?(selection)
                    group = view.model.active_entities.add_group(selection)
                elsif Flattery::container?(selection)
                    group = selection
                else
                    next
                end
            
                plane1 = Flattery::plane_for_entity(group)
                plane2 = Flattery::plane_for_entity(pick)
            
                $plane1 = plane1
                $plane2 = plane2
            
                if !plane2
                    next
                end
            
                group.transform!(plane1.transformationTo(plane2))
            
                entities.push(group)
            }
        
            entities.push(pick)
        
            group = view.model.active_entities.add_group(entities)
            for e in entities
                if Flattery::group?(e)
                    e.explode
                end
            end
        
            view.model.selection.clear
            view.model.selection.add(group)
        
            view.model.commit_operation
        
        end
    end

    $unfold_tool = UnfoldTool.new

end