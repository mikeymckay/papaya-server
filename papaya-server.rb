require 'rubygems'
require 'sinatra'
require 'rest-client'
require 'oj'
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
  return "Error uploading"  unless params[:file] && params[:file][:tempfile] && params[:file][:filename]

  dir_name = "#{Dir.pwd}/public/uploads/#{params["language-name"]}"
  FileUtils.mkdir_p dir_name
  filename = "#{dir_name}/#{params[:phoneme]}"
  File.open(filename, "w") do |f|
    f.write(params['file'][:tempfile].read)
  end

  if params[:format] and params[:format] == "wav"
    #encode to mp3
    `rm #{filename.sub(/wav/,"mp3")}`
    `lame #{filename}`
  end

  redirect '/index.html'
end

get '/languages' do
#  content_type :json
  Oj.dump(Dir.entries("#{Dir.pwd}/public/uploads")-[".",".."])
end

get '/app/config.json' do
  all_languages = (Dir.entries("#{Dir.pwd}/public/uploads")-[".",".."]).join(",")
  redirect "/json_package?languages=#{all_languages}"
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
  Oj.dump(result)
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

