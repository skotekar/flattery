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


require "flattery/unfoldtool.rb"
require "flattery/reunitetool.rb"
require "flattery/tabtool.rb"
require "flattery/svgexport.rb"
require "flattery/edgepairs.rb"

module Flattery
    
    if !$flattery_toolbar
        $flattery_toolbar = UI.toolbar("Flattery")
    end
    
    cmd = UI::Command.new("Index Edges") {
        index_edges()
    }
    cmd.small_icon = "IndexLarge.png"
    cmd.large_icon = "IndexLarge.png"
    cmd.tooltip = "Index Edges"
    cmd.status_bar_text = "Index edges to enable reuniting and tab hints"
    cmd.menu_text = "Index Edges"
    cmd.set_validation_proc { MF_UNCHECKED }
    

    $flattery_toolbar.add_item cmd
    
    cmd = UI::Command.new("Unfold Tool") {
        Sketchup.active_model.select_tool $unfold_tool
    }
    cmd.small_icon = "UnfoldLarge.png"
    cmd.large_icon = "UnfoldLarge.png"
    cmd.tooltip = "Unfold Faces"
    cmd.status_bar_text = "Unfold faces to flatten an object"
    cmd.menu_text = "Unfold"

    $flattery_toolbar.add_item cmd
    
    
    cmd = UI::Command.new("Reunite Tool") {
        Sketchup.active_model.select_tool $reunite_tool
    }
    cmd.small_icon = "ReuniteLarge.png"
    cmd.large_icon = "ReuniteLarge.png"
    cmd.tooltip = "Reunite Edges"
    cmd.status_bar_text = "Move faces to reattach a split edge"
    cmd.menu_text = "Reunite Edges"

    $flattery_toolbar.add_item cmd


    cmd = UI::Command.new("Tab Tool") {
        Sketchup.active_model.select_tool $tab_tool
    }
    cmd.small_icon = "TabLarge.png"
    cmd.large_icon = "TabLarge.png"
    cmd.tooltip = "Add tabs"
    cmd.status_bar_text = "Click an edge to add a tab to it"
    cmd.menu_text = "Add Tabs"

    $flattery_toolbar.add_item cmd


    cmd = UI::Command.new("SVG Export") {
        export_svg()
    }
    cmd.small_icon = "SvgLarge.png"
    cmd.large_icon = "SvgLarge.png"
    cmd.tooltip = "SVG Export"
    cmd.status_bar_text = "Export a flattened group to svg"
    cmd.menu_text = "SVG Export"
    cmd.set_validation_proc { MF_UNCHECKED }

    $flattery_toolbar.add_item cmd
    $flattery_toolbar.show
    
end