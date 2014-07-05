#Allows loading and iterating over Excel (xls and xlsx) and CSV files
#without requiring the user to know what kind of file they're opening.
#Poorly tested, and doesn't attempt to handle exceptions thrown from
#underlying classes (e.g., file not found errors)
class UniSheet
  #Getters
  attr_reader :file_name, :file_type
  
  #Load in a file
  #@param [String] Location of file to be opened
  #@param [String] Optional: file type to be loaded, one of 'csv', 'xls', or 'xlsx'
  #@return UniSheet object
  def initialize(file_name, file_type=nil)
    #Detect filetype if not given
    @file_name = file_name
    if not file_type
      if file_name[".csv"]
        @file_type = "csv"
        @csv = CSV.read @file_name
        return @file_type
      elsif file_name[".xlsx"]
        @xlsx_book = RubyXL::Parser.parse file_name
        @xlsx_sheet = @xlsx_book.worksheets[0].extract_data
        @file_type = "xlsx"
        #Do our best not to get extra folders popping up all over the place
        #sleep 1
        return @file_type
      elsif file_name[".xls"]
        @excel_book = Spreadsheet.open file_name
        @excel_sheet = @excel_book.worksheet 0
        @file_type = "xls"
        return @file_type
      else
        raise RuntimeError, "File #{file_name} of undetectable or unsupported filetype"
      end
    end
    @file_type = file_type
    return @file_type
  end
  
  #Iterator
  def each(&block)
    case
    when @file_type=="csv"
      @csv.each(&block)
    when @file_type=="xls"
      @excel_sheet.each(&block)
    when @file_type=="xlsx"
      @xlsx_sheet.each(&block)
    else
      raise RuntimeError, "File #{@file_name} used in improperly defined UniSheet class"
    end
  end
  
  #Pull out a row; returns an array so columns can also be called in this way
  def [](index)
    case
    when @file_type=="csv"
      return @csv[index]
    when @file_type=="xls"
      return @excel_sheet.row(index).to_a
    when @file_type=="xlsx"
      return @xlsx_sheet[index]
    else
      raise RuntimeError, "File #{@file_name} used in improperly defined UniSheet class"
    end
  end
  
  #Change sheet if xls or xlsx file; give it a sheet number (starting at 0)
  def set_sheet(sheet)
    if @file_type == "xls"
      @excel_sheet = @excel_book.worksheet sheet
    elsif @file_type == "xlsx"
      @xlsx_sheet = @xlsx_book.worksheets[sheet].extract_data
    else
      raise RuntimeError, "File #{@file_name} is not an xls or xlsx file, so cannot change sheet" 
    end
  end

  #Find number of sheets if xls or xlsx file
  def n_sheets()
    if @file_type == "xls"
      return @excel_book.sheet_count
     elsif @file_type == "xlsx"
       return @xlsx_book.worksheets.size
     else
       raise RuntimeError, "File #{@file_name} is not an xls or xlsx file, so has only one sheet"
    end
  end
end
