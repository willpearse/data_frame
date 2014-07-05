#Interal helpers to check all members of a Hash have the same length
module HashHelpers
  #Check all items of a hash are of equal length
  #@param hash hash to be checked for length
  #@return return Either length of each item or false if not all equal
  def self.equal_length(hash)
    hash_length = []
    hash.each {|key, value| hash_length << value.length}
    if hash_length.uniq.length == 1
      return hash_length[0]
    else
      return false
    end
  end
end

#Class to hold data
# @param [Hash] Hash to be converted to a DataFrame
# @return [DataFrame] DataFrame object
class DataFrame
  include HashHelpers
  #Getters
  attr_reader :nrow, :ncol, :col_names, :data
  
  #Create DataFrame with a hash
  # @param [Hash] Hash to be converted to a DataFrame
  # @return [DataFrame] DataFrame object
  def initialize(input_hash)
    #Assert that input object is compatible
    unless input_hash.is_a? Hash then raise RuntimeError, "Must create a DataFrame with a Hash" end 
    unless HashHelpers.equal_length(input_hash) then raise RuntimeError, "Cannot add a hash with unequal element lengths to a data_base" end
    
    #Setup parameters
    @data = input_hash
    @nrow = HashHelpers.equal_length(input_hash)
    @ncol = @data.keys.length
    @col_names = @data.keys
  end
  
  #Copy constructor
  def initialize_copy(orig)
    #Can't do this using .dup or you won't copy the arrays within the hash...
    @data = Marshal::load(Marshal.dump(@data))
    @nrow = @nrow
    @ncol = @ncol
    @col_names = @col_names.dup
  end
  
  #Access individual columns of data
  def [](element)
    return self.data[element]
  end
  
  #Insert a new, empty column
  def insert(column)
    if @col_names.include? column then raise RuntimeError, "Cannot add a column whose name is already taken in DataFrame" end
    @data[column] = [''] * @nrow
    @ncol += 1
    @col_names.push column
    return column
  end
  
  #Delete a column by name
  def delete(column)
    if !@col_names.include? column then raise RuntimeError, "Attempting to remove non-existant column from DataFrame" end
    @data.delete(column)
    @ncol -= 1
    @col_names = @col_names - [column]
    return column
  end
  
  #Append a DataFrame or Hash
  def <<(binder)
    if binder.is_a? DataFrame
      unless self.data.keys.sort == binder.data.keys.sort then raise RuntimeError, "Cannot merge DataFrames with non-matching columns" end
      binder.data.each do |key, value|
        @data[key] << value
        @data[key].flatten!
      end
      @nrow += HashHelpers.equal_length(binder.data)
    elsif binder.is_a? Hash
      unless self.data.keys.sort == binder.keys.sort then raise RuntimeError, "Cannot merge DataFrame and Hash with non-matching elements" end
      unless HashHelpers.equal_length(binder) then raise RuntimeError, "Cannot merge DataFrame with non-equal-length Hash" end
      binder.each do |key, value|
        @data[key] << value
        @data[key].flatten!
      end
      @nrow += HashHelpers.equal_length(binder)
    else
      raise RuntimeError, "Can only merge DataFrame with a DataFrame or Hash"
    end
    return @nrow
  end
  
  #Equality checking
  def ==(comparison)
    if comparison.is_a? DataFrame and self.data == comparison.data and self.nrow == comparison.nrow and self.ncol == comparison.ncol and self.col_names == comparison.col_names
      return true
    else
      return false
    end
  end
          
  #Iterator along each column
  def each_column
    @data.each do |column, value|
      yield column, value
    end
  end
  
  #Iterator along each row
  def each_row
    (0...@nrow).each do |i|
      yield @data.keys.map {|x| @data[x][i]}
    end
  end
end
