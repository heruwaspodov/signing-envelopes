# frozen_string_literal: true

module Annotations
  module SignatureRotations
    module Rotation270
      include PdfRotationHelper

      def rotation270
        @matrix_coordinate = matrix_coordinate270
        @widget_width = widget_width270
        @widget_height = widget_height270
      end

      def matrix_coordinate270
        [page_width - position_x_rotate,
         page_height - position_y_rotate,
         page_width - (position_x_rotate + el_width_rotate),
         page_height - (position_y_rotate + el_height_rotate)]
      end

      def widget_width270
        el_height_rotate
      end

      def widget_height270
        el_width_rotate
      end

      def rotate_content270(widget)
        rotate_val = get_page_rotation(@page)
        widget.rotate(rotate_val)
              .translate(-@widget_width, 0)
      end
    end
  end
end
