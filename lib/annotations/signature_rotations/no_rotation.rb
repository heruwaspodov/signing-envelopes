# frozen_string_literal: true

module Annotations
  module SignatureRotations
    module NoRotation
      def no_rotation
        @matrix_coordinate = matrix_coordinate
        @widget_width = widget_width
        @widget_height = widget_height
      end

      def matrix_coordinate
        [adj_position_xy.first,
         adj_position_xy.last,
         adj_position_xy.first + el_width,
         adj_position_xy.last + el_height]
      end

      def widget_width
        el_width
      end

      def widget_height
        el_height
      end
    end
  end
end
