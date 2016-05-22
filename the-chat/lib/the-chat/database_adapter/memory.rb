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

      def save(table, attributes)
        if table.nil?
          raise SaveError, "No table provided"
        else
          id = SecureRandom.uuid
          @tables[table.to_s][id] = attributes.to_h
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
          @tables[table.to_s].each_with_object([]) do |(_, record), acc|
            acc << record if compare(attributes, record)
          end
        else
          raise FindError, "No table provided"
        end
      end

      def first(table, attributes)
        if table
          @tables[table.to_s].find { |_, record| compare(attributes, record) }
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

      private

      def compare(attributes, record)
        attributes.all? { |k,v| record[k.to_s].to_s == v.to_s }
      end
    end
  end
end
