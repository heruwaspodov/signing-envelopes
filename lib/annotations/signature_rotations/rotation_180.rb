# frozen_string_literal: true

module Annotations
  module SignatureRotations
    module Rotation180
      include PdfRotationHelper

      def rotation180
        @matrix_coordinate = matrix_coordinate180
        @widget_width = widget_width180
        @widget_height = widget_height180
      end

      def matrix_coordinate180
        [page_width - position_x,
         position_y,
         page_width - (position_x + el_width),
         position_y + el_height]
      end

      def widget_width180
        el_width
      end

      def widget_height180
        el_height
      end

      def rotate_content180(widget)
        rotate_val = get_page_rotation(@page)
        widget.rotate(rotate_val)
              .translate(-@widget_width, -@widget_height)
      end
    end
  end
end
