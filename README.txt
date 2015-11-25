INSTALLATION

    To install Flattery, simply copy the file "flattery.rb" and the folder
"flattery" into the SketchUp plugins folder.  On Windows, this folder is
C:\Program Files\Google\Google SketchUp 7\Plugins.  On Macs, the folder is
/Library/Application Support/Google/Google SketchUp 7/SketchUp/plugins.
Once the files are copied, start SketchUp.  You should see the Flattery
toolbar.

USING

    There are five buttons on the Flattery toolbar: Index Edges, Unfold
Faces, Reunite Edges, Add Tabs, and SVG Export.

    When your model is fully constructed, and you are about to unfold it,
select the entire thing and press the Index Edges button.  This marks all
of the edges in your model so that later, when your model is unfolded,
Flattery will know what used to be connected.  This is critical for the
Reunite Edges tool, and helpful for the Add Tabs tool.

    Once your model is indexed, it's time to start unfolding.  To do so,
use the Unfold Faces tool.  With this tool selected, click once to select
a face, then click again on a neighboring face.  The selected face will be
unfolded so that it is flat with the second face.  The two will then be
grouped together and selected, so you can continue unfolding the two of them
to the next neighboring face.  To deselect the selected face, click away from
your model.  You can hold shift and click on faces to select several at once.
Then, when you click on a face to unfold to, all of the selected faces will be
unfolded at the same time.

    When your model is completely unfolded, you may want to adjust it with
the Reunite Edges tool.  First, with the pointer tool, double click on the 
group containing your flattened model to enter the group.  Then select the 
Reunite Edges tool.  From here you can change how your model is unfolded.
Click on the faces you want to move to select them.  While you hover over
edges, their partners will be hilighted in red.  Click on one, and all the
selected faces will be picked up and moved so that the selected edge and its
partner are reunited.

    Next, it's time to add tabs.  Select the Add Tab tool.  For a simple
1/4 inch tab, just double-click on the edge you want the tab added to.
For custom sized tabs, click once on an edge and move the mouse outward.
Click again to make the tab.  You can also enter sizes in the Value Control
Box.  Press Control to switch between trapezoid and triangle tabs.  Just
like the Reunite Edges tool, the tab tool will hilight an edges partner 
when you hover over it.  While you're making a tab, it will also show how
that tab will overlap on the face it will be glued to.

    The last step is to export your pattern.  With the Select tool, click
away from your model to step out of the group.  Then select the group and
press the SVG Export button.  Choose a place to save your SVG file, click
save, and you're done!  Now you can open it in a program like Illustrator
or Inkscape to color and/or print it.




Copyright (c) 2010 Andrew Stoneman

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.
