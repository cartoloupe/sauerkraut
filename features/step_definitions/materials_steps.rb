Given(/^a glass jar$/) do
  @glass_jar = []
end

Given(/^a (\w+) stone$/) do |stone_weight|
  @stone = {:thing => :stone, :weight => stone_weight}
end

Given(/^salt$/) do
  @salt = true
end

Given(/^(?:some )?vegetables$/) do
  @vegetables = ["cabbage","carrot","onion"]
end

Given(/^a sharp knife$/) do
  @knife = true
end

When(/^start chopping the vegetables$/) do
  @vegetables.each do |v|
    v.chop
  end
end

Then(/^there should be ([\w]+) slices of vegetables$/) do |vegetable_size|
  @vegetables.each do |v|
    expect(v.length).to be >= vegetable_size.length
  end
end

Given(/^([\w]+) slices of vegetables$/) do |vegetable_size|
  @vegetable_slice_size = vegetable_size.to_sym
end

Given(/^a(nother)? layer of vegetables is placed in the jar$/) do |repeat|
  @jar ||= []
  put_vegetables_in_jar
end

Given(/^some more vegetables are placed into the jar$/) do
  put_vegetables_in_jar
end

def put_vegetables_in_jar
  @jar << {:layer_of_vegetables => true}
end

Given(/^then (more )?salt is added$/) do |more|
  @salt = 1
  @salt += 1 if more
end

Given(/^some garlic is chopped up$/) do
  @garlic ||= :some
  @garlic.to_s.chop
end

Given(/^garlic is layered into the jar$/) do
  @jar << {:garlic => true}
end

When(/^the jar is nearly full$/) do
  @jar << {:nearly_full => true}
end

Then(/^a stone should be put on top$/) do
  @jar << {:stone => true}
end

Given(/^a jar full of salted vegetables$/) do
  @jar
end

When(/^a heavy stone is placed on top$/) do
  @jar ||= []
  @jar << {:stone => true, :weight => "heavy"}
end

When(/^eventually the salt draws water out of the vegetables$/) do
  sleep 1
end

Then(/^eventually the water level will be above the vegetables$/) do
  sleep 1
end

Then(/^the vegetables should not be exposed to the air$/) do
  @jar_water_level = 10
  @jar_vegetable_level = 9
  expect(@jar_water_level < @jar_vegetable_level)
end

Given(/^a jar full of salted weighed down vegetables$/) do
  @jar
end

When(/^the jar is left in a cool place between (\d+) and (\d+) degrees F$/) do |arg1, arg2|
  @low_temp = arg1.to_i
  @high_temp = arg2.to_i
end

Given(/^about two to four weeks time$/) do
  sleep 2
end

Then(/^the vegetables should ferment$/) do
  @ready = true
end
