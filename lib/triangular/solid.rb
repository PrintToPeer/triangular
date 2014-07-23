module Triangular
  class Solid
    
    attr_accessor :name, :facets, :units
    
    def initialize(name, *args)
      @name = name
      @facets = args
      @units = units
    end
    
    def to_s
      output = "solid #{@name || ""}\n"
      @facets.each do |facet|
        output << "facet normal #{facet.normal.x.to_f} #{facet.normal.y.to_f} #{facet.normal.z.to_f}\n"
        output << "outer loop\n"
        facet.vertices.each do |vertex|
          output << "vertex #{vertex.x.to_f} #{vertex.y.to_f} #{vertex.z.to_f}\n"
        end
        output << "endloop\n"
        output << "endfacet\n"
      end
      output << "endsolid #{@name || ""}\n"
      
      output
    end
    
    def get_bounds
      largest_x = @facets[0].vertices[0].x
      largest_y = @facets[0].vertices[0].y
      largest_z = @facets[0].vertices[0].z
      
      smallest_x = @facets[0].vertices[0].x
      smallest_y = @facets[0].vertices[0].y
      smallest_z = @facets[0].vertices[0].z
      
      @facets.each do |facet|
        facet.vertices.each do |vertex|
          largest_x = vertex.x if vertex.x > largest_x
          largest_y = vertex.y if vertex.y > largest_y
          largest_z = vertex.z if vertex.z > largest_z
          
          smallest_x = vertex.x if vertex.x < smallest_x
          smallest_y = vertex.y if vertex.y < smallest_y
          smallest_z = vertex.z if vertex.z < smallest_z
        end
      end
      
      [Point.new(smallest_x, smallest_y, smallest_z), Point.new(largest_x, largest_y, largest_z)]
    end
    
    def align_to_origin!
      bounds = self.get_bounds
      self.translate!(-bounds[0].x, -bounds[0].y, -bounds[0].z)
    end
    
    def center!
      bounds = self.get_bounds
      
      x_translation = ((bounds[1].x - bounds[0].x).abs / 2) + -bounds[1].x
      y_translation = ((bounds[1].y - bounds[0].y).abs / 2) + -bounds[1].y
      z_translation = ((bounds[1].z - bounds[0].z).abs / 2) + -bounds[1].z
      
      self.translate!(x_translation, y_translation, z_translation)
    end
    
    def slice_at_z(z_plane)
      lines = @facets.map {|facet| facet.intersection_at_z(z_plane) }
      lines.compact!
      
      Polyline.new(lines)
    end
    
    def translate!(x, y, z)
      @facets.each do |facet|
        facet.translate!(x, y, z)
      end
    end
    
    def self.parse(string)
      partial_pattern = /\s* solid\s+ (?<name> [a-zA-Z0-9\-\_\.]+)?/x
      match_data = string.match(partial_pattern)
      
      solid = self.new(match_data[:name])
      
      solid.facets = Facet.parse(string.gsub(partial_pattern, ""))
      
      solid
    rescue
      parse_binary(string)
    end

    def self.parse_binary(string)
      name = string.unpack('C80').select{ |c| !c.nil? }.pack('c*')
      facets_count = string.unpack('C80L1').last
      solid = new name
      string.unpack('C80L1' + 'f12S1' * facets_count)[81..-1].each_slice(13) do |fs|
        facet = Facet.new
        facet.normal = Vector.new fs[0], fs[1], fs[2]
        fs[3..-2].each_slice(3) do |x, y, z|
          facet.vertices << Vertex.new(x, y, z)
        end
        solid.facets << facet
      end
      solid
    end

    def to_b
      output = @name.bytes
      output += [0] * (80 - output.count)
      output << @facets.count

      @facets.each do |f|
        output += [f.normal.x, f.normal.y, f.normal.z]
        f.vertices.each do |v|
          output += [v.x, v.y, v.z]
        end
        output << 0
      end

      output.pack('C80L1' + 'f12S1' * facets.count).force_encoding("ASCII")
    end

    def to_inc
      lines = ["# declare #{inc_name} = mesh {"]
      facets.each do |f|
        lines << f.to_inc { |ls| ls.map! { |l| " " * 2 + l } }
      end
      lines << '}'
      lines.join("\n") + "\n"
    end

    def inc_name
      name.gsub(%r{[^\w_]}, "_")
    end

    def volume
      facets.inject(0) { |sum, facet| sum + facet.signed_volume }
    end
  end
end
