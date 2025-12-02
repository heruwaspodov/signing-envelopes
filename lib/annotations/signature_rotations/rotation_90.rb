# frozen_string_literal: true

module Annotations
  module SignatureRotations
    module Rotation90
      include PdfRotationHelper

      def rotation90
        @matrix_coordinate = matrix_coordinate90
        @widget_width = widget_width90
        @widget_height = widget_height90
      end

      def matrix_coordinate90
        [position_x_rotate,
         position_y_rotate,
         position_x_rotate + el_width_rotate,
         position_y_rotate + el_height_rotate]
      end

      def widget_width90
        el_height_rotate
      end

      def widget_height90
        el_width_rotate
      end

      def rotate_content90(widget)
        rotate_val = get_page_rotation(@page)
        widget.rotate(rotate_val)
              .translate(0, -@widget_height)
      end
    end
  end
end
