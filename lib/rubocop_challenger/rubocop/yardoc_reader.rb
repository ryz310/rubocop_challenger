# frozen_string_literal: true

module RubocopChallenger
  module Rubocop
    class YardocReader
      def initialize(title)
        @cop_class = Object.const_get("RuboCop::Cop::#{title.sub('/', '::')}")
      end

      def read
        YARD.parse(source_file_path)
        yardoc = YARD::Registry.all(:class).first.docstring
        YARD::Registry.clear
        yardoc
      end

      private

      attr_reader :cop_class

      def instance_methods
        [
          cop_class.instance_methods(false),
          cop_class.private_instance_methods(false)
        ].flatten!
      end

      def source_file_path
        instance_methods
          .map { |m| cop_class.instance_method(m).source_location }
          .reject(&:nil?)
          .map(&:first)
          .first
      end
    end
  end
end
