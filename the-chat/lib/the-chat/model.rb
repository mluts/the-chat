require 'securerandom'

module TheChat
  class Model
    class << self
      # Should implement:
      #   * #find(table, id)
      #   * #save(table, id, attributes)
      #   * #destroy(table, id, attributes)
      attr_accessor :adapter

      def find(id)
        attributes = adapter.find(self.class.name, id)
        attributes && new(attributes, id)
      end

      def def_attr(*attrs)
        attrs.each do |attr|
          define_method(attr.to_sym) { @attributes[attr.to_s] }
          define_method(:"#{attr}=") { |val| @attributes[attr.to_s] = val }
        end
      end
    end

    def initialize(attributes = {}, id = nil)
      @attributes = attributes
      @id = id
    end

    attr_reader :attributes, :id

    def save
      @id = adapter.save(self.class.name, attributes)
    end

    private

    def adapter
      self.class.adapter
    end
  end
end
