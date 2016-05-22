require 'securerandom'

module TheChat
  class Model
    class << self
      # Should implement:
      #   * #find(table, id)
      #   * #select(table, attributes)
      #   * #first(table, attributes)
      #   * #save(table, id, attributes)
      #   * #destroy(table, id, attributes)
      def adapter
        @@adapter
      end

      def adapter=(value)
        @@adapter = value
      end

      def table_name
        name
      end

      def find(id)
        attributes = adapter.find(table_name, id)
        attributes && new(attributes, id)
      end

      def select(query)
        adapter.select(table_name, query).map do |id, attrs|
          new(attrs, id)
        end
      end

      def first(query)
        id, attrs = adapter.first(table_name, query)
        id && new(attrs, id)
      end

      def def_attr(*attrs)
        attrs.each do |attr|
          define_method(attr.to_sym) { @attributes[attr.to_s] }
          define_method(:"#{attr}=") { |val| @attributes[attr.to_s] = val }
        end
      end
    end

    def initialize(attributes = {}, id = nil)
      @attributes = attributes.map { |k,v| [k.to_s,v.to_s] }.to_h
      @id = id
    end

    attr_reader :attributes, :id

    def save
      @id = adapter.save(table_name, attributes)
    end

    def delete
      adapter.delete(table_name, id)
    end

    def persisted?
      !!adapter.find(table_name, id)
    end

    def reload
      @attributes.replace adapter.find(table_name, id).to_h
      self
    end

    def ==(other)
      other.is_a?(self.class) && id == other.id
    end

    private

    def adapter
      self.class.adapter
    end

    def table_name
      self.class.table_name
    end
  end
end
