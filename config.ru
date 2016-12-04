require 'rubygems'
require 'bundler'

Bundler.require

require './papers'
run Sinatra::Application
