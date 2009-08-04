# encoding: UTF-8

module Decider
  module Clustering
    
    # A BK Tree to provide more efficient computation of nearest neighbors.
    # The wikipedia article on BK Trees kinda sucks, but this blog post is decent:
    # http://blog.notdot.net/2007/4/Damn-Cool-Algorithms-Part-1-BK-Trees
    class BkTree
      
      def root
        @root
      end
      
      def insert(name, vector)
        return @root = Node.new(name, vector) unless root
        
        @root.attach(Node.new(name, vector))
      end
      
      # Finds all of the neighboring nodes within +limit+ distance
      # from +target_vector+
      def nearest_neighbors(limit, target_vector)
        nodes_to_test = [@root]
        neighbors = []
        while node = nodes_to_test.shift
          distance_to_node = node.vector.distance(target_vector)
          neighbors << node if distance_to_node <= limit
          nodes_to_test += node.children_in_range(limit, distance_to_node)
        end
        neighbors
      end
      
      def to_formatted_s
        root ? root.to_formatted_s : ""
      end
      
      def size
        root ? 1 + root.size : 0
      end
      
      class Node
        attr_reader :name, :vector, :children
        
        def initialize(name, vector)
          @name, @vector = name, vector
          @children = {}
        end
        
        def attach(subnode)
          distance = @vector.distance(subnode.vector)
          if equidistant_child = @children[distance]
            equidistant_child.attach(subnode)
          else
            @children[distance] = subnode
          end
        end
        
        def to_formatted_s(depth=0)
          prefix = "  " * depth
          str = "#{name}:\n"
          @children.each do |distance, node|
            str << prefix + "#{distance} => #{node.to_formatted_s(depth + 1)}\n"
          end
          str
        end
        
        def children_in_range(center, distance)
          min, max = center - distance, center + distance
          min = 0 if min < 0
          @children.select { |k,v| k >= min && k <= max }.map do |kv_pair|
            kv_pair.last
          end
        end
        
        def size
          @children.size + @children.inject(0) { |sum, child| sum + child.last.size }
        end

      end
      
    end
  end
end
