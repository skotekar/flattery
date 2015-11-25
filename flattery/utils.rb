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


require 'sketchup.rb'

module Flattery

    #Represents the plane given by @normal (dot) x = @distance
    class Plane
        attr_reader :normal, :distance
    
        def initialize(plane_array)
            @normal = Geom::Vector3d.new(plane_array.slice(0,3))
            @distance = -plane_array[3] / @normal.length
            @normal.normalize!
        
        end
        
        def to_a()
            return [@normal.x, @normal.y, @normal.z, -@distance]
        end
        
        def intersect_line(line)
            return Geom.intersect_line_plane(line, to_a)
        end
        
        def parallel?(other)
            @normal.parallel? other.normal
        end
        
        def transform!(transformation)
            origin = Geom::Point3d.new
            point = @normal.clone
            point.length = @distance
            point = origin + point
            point.transform!(transformation)
            point = origin.vector_to(point)
        
        
            @normal.transform!(transformation)
            @normal.normalize!
            @distance = point.dot(@normal)
        end
    
        def transformationTo(other)
            if self.parallel?(other)
                #TODO: If paralell but not coplanar, return a translation?  What about orientation?
                return Geom::Transformation.new
            end
        
            vec = @normal * other.normal
            vec.normalize!
            if vec.x.abs >= vec.y.abs && vec.x.abs >= vec.z.abs
                #solve with x=0
                px = 0
            
                py = ( other.normal.z * @distance - @normal.z * other.distance ) /
                     ( @normal.y * other.normal.z - other.normal.y * @normal.z )
            
                pz = ( other.normal.y * @distance - @normal.y * other.distance ) /
                     ( @normal.z * other.normal.y - other.normal.z * @normal.y )
            elsif vec.y.abs >= vec.z.abs
                #solve with y=0
                px = ( other.normal.z * @distance - @normal.z * other.distance ) /
                     ( @normal.x * other.normal.z - other.normal.x * @normal.z )
            
                py = 0
            
                pz = ( other.normal.x * @distance - @normal.x * other.distance ) /
                     ( @normal.z * other.normal.x - other.normal.z * @normal.x )
            else
                #solve with z=0
                px = ( other.normal.y * @distance - @normal.y * other.distance ) /
                     ( @normal.x * other.normal.y - other.normal.x * @normal.y )
            
                py = ( other.normal.x * @distance - @normal.x * other.distance ) /
                     ( @normal.y * other.normal.x - other.normal.y * @normal.x )
            
                pz = 0
            end
        
            pt = Geom::Point3d.new(px, py, pz)
        
            angle_transform = Geom::Transformation.new(@normal, vec*@normal, vec, Geom::Point3d.new(0,0,0))
            angle_transform.invert!
            angle_vector = other.normal.transform(angle_transform)
            angle = Math::atan2(angle_vector.y, angle_vector.x)
        
            return Geom::Transformation.new(pt, vec, angle)
        end
    end
    
    module_function
    
    def vertex?(entity)
         entity.typename == "Vertex"
    end
    
    def face?(entity)
         entity.typename == "Face"
    end
    
    def group?(entity)
        entity.typename == "Group"
    end
    
    def edge?(entity)
        entity.typename == "Edge"
    end
    
    def definition?(entity)
        entity.typename == "ComponentDefinition"
    end
    
    def instance?(entity)
        entity.typename == "ComponentInstance"
    end
    
    def container?(entity)
        group?(entity) || definition?(entity) || instance?(entity)
    end
    
    def get_entities(entity)
        if group?(entity) || definition?(entity)
            return entity.entities
        elsif instance?(entity)
            return entity.definition.entities
        end
    end
    
    def plane_for_entity(entity)
        if face?(entity)
            return Plane.new(entity.plane)
        elsif container?(entity)
            get_entities(entity).each do |e|
                plane = plane_for_entity(e)
                if plane
                    plane.transform!(entity.transformation)
                    return plane
                end
            end
        end
        
        return nil
    end
    
    #Transformation from the (posibly nested) group or component that the entity is nested in
    #into the models actively edited coordinate space.
    def transformations_for_entity(entity)
        path = entity.model.active_path || []
        
        if group?(entity.parent)
            parents = [entity.parent]
        elsif definition?(entity.parent)
            parents = entity.parent.instances
        else
            parents = nil
        end
        
        path_index = path.index(entity)
        
        if path_index
            #puts path_index
            t = Geom::Transformation.new
            path.slice(path_index, path.length).each do |g|
                t = g.transformation.inverse * t
            end
            return [t]
        elsif parents
            transformations = []
            parents.each do |p|
                transformations.concat transformations_for_entity(p).map {|t| t * p.transformation }
            end
            return transformations
        else
            t = Geom::Transformation.new
            path.each do |g|
                t = g.transformation * t
            end
            return [t]
        end
    end
    
end