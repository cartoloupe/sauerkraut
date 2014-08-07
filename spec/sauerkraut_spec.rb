require 'sauerkraut'
require 'pry'

describe "parsing" do

  it "parses" do
    expect {Sauerkraut.run "blah".split}.to raise_error
    expect {Sauerkraut.run "blah.feature".split}.to raise_error
    expect {Sauerkraut.run "blah.feature:39".split}.to raise_error
    expect {Sauerkraut.run "features/test.feature:39".split}.to raise_error
    expect {Sauerkraut.run "features/test.feature".split}.to_not raise_error
    expect {Sauerkraut.run "features/test.feature:15".split}.to_not raise_error
    expect {Sauerkraut.run "features/test.feature:15:".split}.to raise_error
    expect {Sauerkraut.run "features/test.feature:15:17".split}.to_not raise_error
    expect {Sauerkraut.run "features/test.feature:15:17 -o ".split}.to raise_error
    expect {Sauerkraut.run "features/test.feature:15:17 -o aaa.text".split}.to_not raise_error
    expect {Sauerkraut.run "features/test.feature:15 -o aaa.text".split}.to_not raise_error
    expect {Sauerkraut.run "features/test.feature:15 -o ".split}.to raise_error
    expect {Sauerkraut.run "features/blah.feature:15".split}.to raise_error
  end
end

describe "output" do
  it "runtest1" do
    Sauerkraut.run "features/test.feature:15 -o a.text".split
    diff=`diff a.text test/runtest1.output`
    expect(diff).to eq("")
  end
  it "runtest2" do
    Sauerkraut.run "features/test.feature:15:18 -o b.text".split
    diff=`diff b.text test/runtest2.output`
    expect(diff).to eq("")
  end
end

