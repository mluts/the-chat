module TheChat
  module DatabaseAdapter
    class Memory
      Error = Class.new(StandardError)
      FindError = Class.new(Error)
      SaveError = Class.new(Error)
      DeleteError = Class.new(Error)

      def initialize
        @tables = Hash.new { |h,k| h[k.to_s] = {} }
      end

      def save(table, attributes, id = nil)
        if table.nil?
          raise SaveError, "No table provided"
        else
          id ||= SecureRandom.uuid
          @tables[table.to_s][id.to_s] = attributes.to_h
          id
        end
      end

      def find(table, id)
        if table
          @tables[table.to_s][id.to_s]
        else
          raise FindError, "No table provided"
        end
      end

      def select(table, attributes)
        if table
          @tables[table.to_s].select do |_, record|
            compare(attributes, record)
          end
        else
          raise FindError, "No table provided"
        end
      end

      def first(table, attributes)
        if table
          @tables[table.to_s].find do |_, record|
            compare(attributes, record)
          end
        else
          raise FindError, "No table provided"
        end
      end

      def delete(table, id)
        if table
          @tables[table.to_s].delete(id.to_s)
        else
          raise DeleteError, "No table provided"
        end
      end

      def reset
        @tables.clear
      end

      private

      def compare(attributes, record)
        attributes.all? do |k,v|
          val = record[k.to_s]
          if v.is_a?(Enumerable)
            v.any? { |comp| val == comp }
          else
            record[k.to_s].to_s == v.to_s
          end
        end
      end
    end
  end
end
