require 'mongo'
require './papers'

p = papers
p.indexes.create_one({:num => 1}, unique: true)

