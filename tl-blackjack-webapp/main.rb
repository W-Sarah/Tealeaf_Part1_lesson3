require 'rubygems'
require 'sinatra'

set :sessions, true

get '/home' do
  "Hey Sarah, good job!"
end

get '/template' do
  erb :my_template
  end




