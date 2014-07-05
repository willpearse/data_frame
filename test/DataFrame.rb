require 'data_frame'
require 'minitest'
require 'minitest/autorun'

describe HashHelpers do
  it "Returns the length of equally-lengthed hashes" do
    assert HashHelpers.equal_length({:a=>[1,2,3], :b=>["a", "v", "a"]}) == 3
    assert HashHelpers.equal_length({:a=>[], :b=>[]}) == 0
  end
  it "Returns false for unequal length hashes" do
    assert HashHelpers.equal_length({:a=>[1,2,3], :b=>["a", "a"]}) == false
  end
end

describe DataFrame do
  it "Initialises with a Hash" do
    temp = DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]})
    assert temp.data == {:a=>[1, 2, 3], :b=>["a", "v", "a"]}
    assert temp.nrow == 3
    assert temp.ncol == 2
    assert_raises(RuntimeError) {DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a", "d"]})}
  end
  it "Appends rows from a DataFrame or Hash" do
    first = DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]})
    second = DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]})
    first << second
    assert first.data == {:a=>[1, 2, 3, 1, 2, 3], :b=>["a", "v", "a", "a", "v", "a"]}
    assert first.nrow == 6
    second << {:a=>[1,2,3], :b=>["a", "v", "a"]}
    assert second.data == {:a=>[1, 2, 3, 1, 2, 3], :b=>["a", "v", "a", "a", "v", "a"]}
    assert second.nrow == 6
  end
  it "Appends single elements from a DataFrame or Hash" do
    first = DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]})
    second = DataFrame.new({:a=>[4], :b=>["b"]})
    first << second
    assert first.data == {:a=>[1, 2, 3, 4], :b=>["a", "v", "a", "b"]}
    assert first.nrow == 4
    third = DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]})
    fourth = {:a=>[4], :b=>["b"]}
    third << fourth
    assert first.data == third.data
  end
  it "Allows access to columns" do
    first = DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]})
    assert first[:a] == [1,2,3]
  end
  it "Iterates columns" do 
    columns = []; values = []
    first = DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]})
    first.each_column  do |x,y|
      y.each do |z|
        columns << x
        values << z
      end
    end
    assert columns == [:a, :a, :a, :b, :b, :b]
    assert values == [1, 2, 3, "a", "v", "a"]
  end
  it "Iterates rows" do
    x = []; y = []
    first = DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]})
    first.each_row  do |a,b|
      x << a
      y << b
    end
    assert x == [1, 2, 3]
    assert y == ["a", "v", "a"]
    merged = []
    first.each_row  {|x| merged << x}
    assert merged == [[1, "a"], [2, "v"], [3, "a"]]
  end
  it "Checks for equality" do
    assert DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]}) == DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]})
    assert DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]}) != DataFrame.new({:a=>[1,2,3,4], :b=>["a", "v", "a", "b"]})
  end
  it "Adds columns" do 
    first = DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]})
    first.insert :test
    assert first.nrow == 3
    assert first.ncol == 3
    assert first[:test] == ['', '', '']
  end
  it "Delete columns" do
    first = DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]})
    first.delete :a
    assert first.nrow == 3
    assert first.ncol == 1
  end
  it "Has a copy constructor" do
    first = DataFrame.new({:a=>[1,2,3], :b=>["a", "v", "a"]})
    second = first.dup
    second[:a][0] = "asd"
    second.delete :a
    second.col_names[1] = "derp"
    assert first[:a][0] != "asd"
    assert first.ncol == 2
  end
end
