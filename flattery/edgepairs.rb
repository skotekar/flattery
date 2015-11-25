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
    
    @@edge_counter = 0
    
    module_function
    
    def index_edges()
        if Sketchup.active_model.selection.empty?
            label_edges(nil, false)
        else
            label_edges(Sketchup.active_model.selection, true)
        end
    end
    
    def set_edge_counter(entities)
        entities.each do |e|
            if edge?(e)
                id = e.get_attribute("Unfold", "edge_id")
                if id
                    @@edge_counter = [@@edge_counter, id].max
                end
            elsif container?(e)
                set_edge_counter(get_entities(e))
            end
        end
    end
    
    def label_edges_recursive(entities, relabel)
        entities.each do |e|
            if edge?(e)
                id = e.get_attribute("Unfold", "edge_id")
                if relabel || !id
                    @@edge_counter += 1
                    e.set_attribute("Unfold", "edge_id", @@edge_counter)
                end
            elsif container?(e)
                label_edges_recursive(get_entities(e), relabel)
            end
        end
    end
    
    #Test with: Sketchup.active_model.selection.first.get_attribute("Unfold", "edge_id")
    def label_edges(entities=nil, relabel=false)
        if !entities
            entities = Sketchup.active_model.entities
        end
        
        set_edge_counter(entities)
        
        entities.model.start_operation("Index Edges")
        label_edges_recursive(entities, relabel)
        entities.model.commit_operation()
    end
    
    def paired_edges(edge, entities=nil, recursive=true)
        edge_id = edge.get_attribute("Unfold", "edge_id")
        
        if !edge_id
            return nil
        end
        
        if !entities
            entities = Sketchup.active_model.entities
        end
        
        found = []
        
        entities.each do |e|
            if e.get_attribute("Unfold", "edge_id") == edge_id && e != edge
                found.push(e)
            elsif recursive && container?(e)
                found.concat(paired_edges(edge, get_entities(e)))
            end
        end
        
        return found
    end
    
    def select_paired()
        selection = Sketchup.active_model.selection
        edge = selection.first
        
        if !edge?(edge)
            return
        end
        
        pair = paired_edge(edge)
        if pair
            selection.clear()
            selection.toggle(pair)
        end
    end
end