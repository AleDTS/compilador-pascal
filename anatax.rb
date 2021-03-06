class Anatax
  @@i = 0
  @@table = Array.new # Tabela de simbolos

  def initialize(table)
    @@table = table
  end

  def table
    @@table
  end

  # Proximo token
  def nxt
    @@i += 1
  end

  # Token anterior
  def back
    @@i -= 1
  end

  # Retorna token
  def token
    if !eot
      @@table[@@i][1]
    end
  end

  # Retorna valor do token
  def tokenValue
    @@table[@@i][0]
  end

  # Retorna linha do token
  def line
    @@table[@@i][3]
  end

  # 'End of table'
  def eot
    @@i == @@table.length
  end

  #------------------------------------------

  def declared
      @@table[@@i][4] = true
  end

  def var
      @@table[@@i][5] = 'var'
  end

  #------------------------------------------

  def program
    # puts "#{token} - program"
    if token == "program"
      nxt
      if token == "IDENTIFIER"
        nxt
        if token == ";"
          nxt
          if block
            nxt
            if token == "."
              return true
            end
          end
        end
      end
    end
    false
  end

  def block
    # # puts "#{token} - block"
    if variable_declaration_part
      nxt
      if statement_part
        return true
      end
    end
    false
  end

  #------------------------------------------

  def variable_declaration_part
    # puts "#{token} - variable_declaration_part"
    if token == "var"
      nxt
      if variable_declaration
        nxt
        if token == ";"
          aux = @@i
          nxt
          if !variable_declaration
            @@i = aux
            return true
          else
            nxt
            while true
              if token == ";"
                aux = @@i
                nxt
                if !variable_declaration
                  @@i = aux
                  return true
                else
                  nxt
                end
              else
                return false
              end
            end
          end
        end
      end
    else
      return true
    end
    false
  end

  def variable_declaration
    # puts "#{token} - variable_declaration"
    if token == "IDENTIFIER"
        var
        declared
      nxt
      if token == ":"
        nxt
      else
        while true
          if token == ","
            nxt
            if token == "IDENTIFIER"
                var
               declared
              nxt
              if token == ":"
                nxt
                break
              end
            end
          else
            return false
          end
        end
      end
      if type
        return true
      end
    end
    false
  end

  def type
    # puts "#{token} - type"
    if simple_type
      return true
    elsif array_type
      return true
    end
    false
  end

  def array_type
    # puts "#{token} - array_type"
    if token == "array"
      nxt
      if token == "["
        nxt
        if index_range
          nxt
          if token =="]"
            nxt
            if token =="of"
              nxt
              if symple_type
                return true
              end
            end
          end
        end
      end
    end
    return false
  end

  def index_range
    # puts "#{token} - index_range"
    if token == "NUMBER" #integer_constant
      nxt
      if token == ".."
        nxt
        if token == "NUMBER" #integer_constant
          return true
        end
      end
    end
    false
  end

  def simple_type
    # puts "#{token} - simple_type"
    if ["char", "integer", "boolean"].include? token
      return true
    end
    return false
  end

  def type_identifier
    # puts "#{token} - type_identifier"
    if token == "IDENTIFIER"
        var
      return true
    end
    return false
  end

  #------------------------------------------

  def statement_part
    # puts "#{token} - statement_part"
    if compound_statement
    # if token == "end"
      return true
    end
    false
  end

  def compound_statement
    # puts "#{token} - compound_statement"
    if token == "begin"
      nxt
      if statement
        nxt
        if token == "end"
          return true
        else
          while true
            if token == ";"
              nxt
              if statement
                nxt
              end
            elsif token == "end"
              return true
            else
              return false
            end
          end
        end
      end
    end
    false
  end

  def statement
    # puts "#{token} - statement"
    if simple_statement
      return true
    elsif structured_statement
      return true
    end
    return false
  end

  #------------------------------------------

  def simple_statement
    # puts "#{token} - simple_statement"
    if assignment_statement
      return true
    elsif read_statement
      return true
    elsif write_statement
      return true
    end
    return false
  end

  def assignment_statement
    # puts "#{token} - assignment_statement"
    if variable
      nxt
      if token == ":="
        nxt
        if expression
          return true
        end
      end
    end
    false
  end

  def read_statement
    # puts "#{token} - read_statement"
    if token == "read"
      nxt
      if token == "("
        nxt
        if variable
          nxt
          if token == ")"
            return true
          else
            while true
              if token == ","
                nxt
                if variable
                  nxt
                end
              elsif token == ")"
                return true
              else
                return false
              end
            end
          end
        end
      end
    end
    false
  end

  def write_statement
    # puts "#{token} - write_statement"
    if token == "write"
      nxt
      if token == "("
        nxt
        if variable
          nxt
          if token == ")"
            return true
          else
            while true
              if token == ","
                nxt
                if variable
                  nxt
                end
              elsif token == ")"
                return true
              else
                return false
              end
            end
          end
        end
      end
    end
    false
  end

  #------------------------------------------

  def structured_statement
    # puts "#{token} - structured_statement"
    if compound_statement
      return true
    elsif if_statement
      return true
    elsif while_statement
      return true
    end
    false
  end

  def if_statement
    # puts "#{token} - if_statement"
    if token == 'if'
      nxt
      if expression
        nxt
        if token == 'then'
          nxt
          if statement
            nxt
            if token == 'else'
              nxt
              if statement
                return true
              end
            else
              back
              return true
            end
          end
        end
      end
    end
    false
  end

  def while_statement
    # puts "#{token} - while_statement"
    if token == "while"
      nxt
      if expression
        nxt
        if token == "do"
          nxt
          if statement
            return true
          end
        end
      end
    end
    return false
  end

  #------------------------------------------

  def expression
    # puts "#{token} - expression"
    if simple_expression
      nxt
      if relational_operator
        nxt
        if simple_expression
          return true
        end
      else
        back
        return true
      end
    end
    false
  end

  def simple_expression
    # puts "#{token} - simple_expression"
    if sign
      nxt
      if term
        aux = @@i
        nxt
        if !adding_operator
          @@i = aux
          return true
        else
          nxt
          while true
            if term
              aux = @@i
              nxt
              if !adding_operator
                @@i = aux
                return true
              else
                nxt
              end
            else
              return false
            end
          end
        end
      end
    end
    false
  end

  def term
    # puts "#{token} - term"
    if factor
      aux = @@i
      nxt
      if !multiplying_operator
        @@i = aux
        return true
      else
        nxt
        while true
          if factor
            aux = @@i
            nxt
            if !multiplying_operator
              @@i = aux
              return true
            else
              nxt
            end
          else
            return false
          end
        end
      end
    end
    false
  end

  def factor
    # puts "#{token} - factor"
    if variable or token == "NUMBER" #or constant
      return true
    elsif token == "("
      nxt
      if expression
        nxt
        if token == ")"
          return true
        end
      end
    elsif token == "not"
      nxt
      if factor
        return true
      end
    end
    false
  end

  #------------------------------------------

  def relational_operator
    # puts "#{token} - relational_operator"
    if ["=","<>","<","<=",">=",">","or","and"].include? token
      return true
    end
    return false
  end

  def sign
    # puts "#{token} - sign"
    if ["+","-"].include? token # or empty
      return true
    end
    back
  end

  def adding_operator
    # puts "#{token} - adding_operator"
    if ["+","-"].include? token
      return true
    end
    return false
  end

  def multiplying_operator
    # puts "#{token} - multiplying operator"
    if token == "*" or token == "/"
      return true
    end
    false
  end

  #------------------------------------------

  def variable
    # puts "#{token} - variable"
    if entire_variable
      return true
    elsif indexed_variable
      return true
    end
    return false
  end

  def indexed_variable
    # puts "#{token} - indexed_variable"
    if array_variable
      nxt
      if token == "["
        nxt
        if expression
          nxt
          if token == "]"
            nxt
            return true
          end
        end
      end
    end
    return false
  end

  def array_variable
    # puts "#{token} - array_variable"
    if entire_variable
      return true
    end
    return false
  end

  def entire_variable
    # puts "#{token} - entire-variable"
    if variable_identifier
      return true
    end
    return false
  end

  def variable_identifier
    # puts "#{token} - variable_identifier"
    # if ["IDENTIFIER", "STRING"].include? token
    if token == "IDENTIFIER"
        var
      return true
    end
    return false
  end

  def syntaxAnalysis
    if program
      return true
    end
    if eot
      @@i -= 1
    end
    false
  end
end
