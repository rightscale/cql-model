module Cql::Model::Query

  # DELETE statement DSL
  # << A DELETE statement removes one or more columns from one or more rows in a table,
  #    or it removes the entire row if no columns are specified. >>
  # (from http://www.datastax.com/documentation/cassandra/1.2/cassandra/cql_reference/delete_r.html)
  #
  # E.g.:
  # Model.delete.where{ id == 1}
  # Model.delete(:col).where{ id == 1}
  # Model.delete(:col => ['element1', 'element2', 'element3']).where{ id == 1}
  # Model.delete.timestamp(1366057256324).where{ id == 1}
  # Model.delete(:col1, :col2).timestamp('2013-04-15 13:21:48')
  # Model.delete(:col1).consistency('ONE')
  # Model.delete.timestamp(1366057256324).consistency('ONE')
  class DeleteStatement < MutationStatement
    def initialize(klass, client=nil)
      super(klass, client)
      @where = []
      @columns = []
    end

    # Create or append to the WHERE clause for this statement. The block that you pass will define the constraint
    # and any where() parameters will be forwarded to the block as yield parameters. This allows late binding of
    # variables in the WHERE clause, e.g. for prepared statements.
    # TODO examples
    # @see Expression
    def where(*params, &block)
      @where << ComparisonExpression.new(*params, &block)
      self
    end

    alias and where

    # DELETE columns
    #
    # @param [Arguments] list of columns to delete
    def delete(*values)
      raise ArgumentError, "Cannot specify DELETE values twice" unless @columns.nil?
      @columns = values
      self
    end

    # @return [String] a CQL UPDATE statement with suitable constraints and options
    def to_s
      columns = ''
      @columns.each do |col|
        if columns.size > 0
          columns << ','
        end
        if col.class == Symbol
          col = col.to_s
        elsif col.class == Hash
          if col.size == 1 && col.values.first.class == Array
            list = []
            col.values.first.each do |value|
              if value.class == String
                list.push("'#{value.gsub(/'/,"''")}'")
              else
                begin
                  list.push(Integer(value))
                rescue
                  raise "Collection set, list or map values should be Integers or Strings in DELETE statement"
                end
              end
            end
            col = "#{col.keys.first.to_s}[#{list.join(', ')}]"
          end
        end
        raise "Wrong columns list in DELETE statment" unless col.class == String
        columns << " #{col}"
      end
      s = "DELETE#{columns} FROM #{@klass.table_name}"
      s << " USING TIMESTAMP #{@timestamp}" unless @timestamp.nil?
      unless @where.empty?
        s << " WHERE " << @where.map { |w| w.to_s }.join(' AND ')
      end
      s << ';'

      s
    end
  end
end
