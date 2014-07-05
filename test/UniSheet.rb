require 'data_frame'
require 'minitest'
require 'minitest/autorun'
require "spreadsheet"
require "csv"
require "rubyXL"

describe UniSheet do
  before do
    @csv_test = UniSheet.new "dataFrame.csv"
    @xls_test = UniSheet.new "dataFrame.xls"
    @xlsx_test = UniSheet.new "dataFrame.xlsx"
  end
  describe "When loading a CSV file" do
    it "Will iterate correctly" do
      temp = []
      @csv_test.each {|line| temp << line[0]}
      assert_equal ["Name", "John Ward", "Tom Ensom"], temp
    end
    it "Will load a row correctly" do
      @csv_test[0].must_equal ["Name", "Emailed?", "Confirmed?", "Emailed Re. Payment?","Paid?"]
    end
    it "Doesn't have sheets" do
      proc {@csv_test.set_sheet(1)}.must_raise RuntimeError
    end
  end
  describe "When loading an XLS file" do
    it "Will iterate correctly" do
      temp = []
      @xls_test.each {|line| temp << line[0]}
      assert_equal ["Name", "John Ward", "Tom Ensom"], temp
    end
    it "Will load a row correctly" do
      @xls_test[0].must_equal ["Name", "Emailed?", "Confirmed?", "Emailed Re. Payment?","Paid?"]
    end
    it "Handles multiple sheets" do
      @xls_test.set_sheet 1
      assert @xls_test[0] == ["Another sheet"]
    end
  end
  describe "When loading an XLSX file" do
    it "Will iterate correctly" do
      temp = []
      @xlsx_test.each {|line| temp << line[0]}
      assert_equal ["Name", "John Ward", "Tom Ensom"], temp
    end
    it "Will load a row correctly" do
      @xlsx_test[0].must_equal ["Name", "Emailed?", "Confirmed?", "Emailed Re. Payment?","Paid?"]
    end
    it "Handles multiple sheets" do
      @xlsx_test.set_sheet 1
      assert @xlsx_test[0][0] == "Another sheet"
      assert @xlsx_test.n_sheets == 2
      assert @xls_test.n_sheets == 2
      assert_raises(RuntimeError) {@csv_test.n_sheets}
    end
  end
  describe "When loading files" do
    it "Can ignore file endings if asked" do
      @trick = UniSheet.new("test_files/dataFrameXLSTrick.csv", "xls")
      temp = []
      @xls_test.each {|line| temp << line[0]}
      assert_equal ["Name", "John Ward", "Tom Ensom"], temp
    end
  end
end
