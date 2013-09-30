require 'rubygems'
require 'sinatra'
require 'rest-client'
require 'json'
require 'yaml'
require 'fileutils'

set :enviroment, :development

post '/save/:language' do |language|
  puts params.inspect

  dir_name = "#{Dir.pwd}/public/uploads/#{params["language"]}"
  FileUtils.mkdir_p dir_name
  File.open(File.join(dir_name, "#{language}.json"), "w") do |f| 
    f.write(params["data"])
  end
  return "Success"

end

post '/upload' do
# TODO check for mp3 suffix
  return "Error uploading"  unless params[:file] && (tmpfile = params[:file][:tempfile]) && (name = params[:file][:filename])

  while blk = tmpfile.read(65536)
    dir_name = "#{Dir.pwd}/public/uploads/#{params["language-name"]}"
    FileUtils.mkdir_p dir_name
    File.open(File.join(dir_name, "#{params[:phoneme]}"), "wb") { |f| f.write(tmpfile.read) }
  end

  redirect '/index.html'
end

get '/languages' do
  content_type :json
  (Dir.entries("#{Dir.pwd}/public/uploads")-[".",".."]).to_json
end

get '/json_package' do
  content_type :json
  result = {
    "maxRecordTime" => 15000,
    "default_language" => params["defaultLanguage"],
    "languages" =>  {}
  }

  params['languages'].split(/,/).each do |language|
    result['languages'][language] = {
      "phonemes" =>  language_config(language)["phonemes"],
      "voices" =>  language_config(language)["voices"]
    }
  end

  puts language_config("English")["phonemes"]
  puts result
  result.to_json
end

def language_files(language)
  Dir.entries("#{Dir.pwd}/public/uploads")-[".",".."]
end

def path_to_config(language)
  "#{Dir.pwd}/public/uploads/#{language}/#{language}.json"
end

def language_config(language)
  begin
    JSON.parse( IO.read(path_to_config(language)))
  rescue
    {}
  end
end

