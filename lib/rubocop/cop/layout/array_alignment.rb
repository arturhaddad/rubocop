# frozen_string_literal: true

module RuboCop
  module Cop
    module Layout
      # Here we check if the elements of a multi-line array literal are
      # aligned.
      #
      # @example EnforcedStyle: with_first_element (default)
      #   # good
      #
      #   array = [1, 2, 3,
      #            4, 5, 6]
      #   array = ['run',
      #            'forrest',
      #            'run']
      #
      #   # bad
      #
      #   array = [1, 2, 3,
      #     4, 5, 6]
      #   array = ['run',
      #        'forrest',
      #        'run']
      #
      # @example EnforcedStyle: with_fixed_indentation
      #   # good
      #
      #   array = [1, 2, 3,
      #     4, 5, 6]
      #
      #   # bad
      #
      #   array = [1, 2, 3,
      #            4, 5, 6]
      class ArrayAlignment < Cop
        include Alignment

        ALIGN_ELEMENTS_MSG = 'Align the elements of an array literal ' \
          'if they span more than one line.'

        FIXED_INDENT_MSG = 'Use one level of indentation for elements ' \
          'following the first line of a multi-line array.'

        def on_array(node)
          return if node.children.size < 2

          check_alignment(node.children, base_column(node, node.children))
        end

        def autocorrect(node)
          AlignmentCorrector.correct(processed_source, node, column_delta)
        end

        private

        def message(_node)
          fixed_indentation? ? FIXED_INDENT_MSG : ALIGN_ELEMENTS_MSG
        end

        def fixed_indentation?
          cop_config['EnforcedStyle'] == 'with_fixed_indentation'
        end

        def base_column(node, args)
          if fixed_indentation?
            lineno = target_method_lineno(node)
            line = node.source_range.source_buffer.source_line(lineno)
            indentation_of_line = /\S.*/.match(line).begin(0)
            indentation_of_line + configured_indentation_width
          else
            display_column(args.first.source_range)
          end
        end

        def target_method_lineno(node)
          node.loc.line
        end
      end
    end
  end
end
