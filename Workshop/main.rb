#!/usr/bin/ruby
require 'rubygems'
require 'daemons'

$pwd  = File.dirname(File.expand_path(__FILE__))
excel = $pwd + '/getExcel.rb'
require 'sinatra'
require excel
require 'serialport'
require 'json'
require 'yaml'
require 'time'
require 'fileutils'
require 'rexml/document'
require 'fileutils'
include REXML
set :bind, '0.0.0.0'
set :port, 8080
set :public_folder, 'public'

##---REST API--------------------------------------------------------------------------------------------
#before do
#  content_type 'application/json'
#end

#===========================================GET=============================================================

get '/tools' do
    content_type :json
    blue_print = get_blue_prints()
    blue_print.to_json
end
      #--------blueprint------------------

get '/search/blueprint/:where/:what' do 
  content_type :json
  blue_print = get_blue_prints()
  search = []
  blue_print.each do |b|
  cont = YAML.load(File.read($pwd+"/DataBase/"+b+"/blueprint/complete.yaml"))
  if cont["Technical Data"][params[:where]][params[:what]] == params[:value]
      search.push b
  end
  end
  search = search.to_json
end

get '/tools/:name/blueprint' do 
  content_type :json
  cont = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/blueprint/complete.yaml"))
  cont = cont.to_json
end
# ===xml===
get '/tools/:name/blueprint/model' do
      content_type 'text/xml'
      xmlfile = File.new($pwd+"/DataBase/"+params[:name]+"/blueprint/3dmodel.gdml")
		xmldoc = Document.new(xmlfile)
      xmldoc = xmldoc.to_s
end

get '/tools/:name/blueprint/model/:tag' do
      content_type 'text/xml'
      xmlfile = File.new($pwd+"/DataBase/"+params[:name]+"/blueprint/3dmodel.gdml")
		xmldoc = Document.new(xmlfile)
      output = "<xml>"
		XPath.each(xmldoc, "//"+params[:tag]) do |e|
			output = output + e.to_s
		end
      output = output + "</xml>"
      output
end
# ===xml===

get '/tools/:name/blueprint/:unit' do
  content_type :json
  cont = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/blueprint/complete.yaml"))
  cont = cont[params[:unit]]
  if  params.include? 'param' and params[:unit] == "Units"
    cont = cont[params[:param]]
  end
  cont = cont.to_json
end

get '/tools/:name/blueprint/:unit/:prop' do
  content_type :json
  cont = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/blueprint/complete.yaml"))
  cont = cont[params[:unit]][params[:prop]]
  if  params.include? 'param'
  cont = cont[params[:param]]
  end
  cont = cont.to_json
end
     #---------------runtime-----------------
get '/tools/:name/runtime' do 
    content_type :json
    runtime = get_runtimes(params[:name])
    runtime.to_json
end

get '/tools/:name/runtime/:version' do 
  content_type :json
  cont = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/runtime/"+params[:version]+"/definition/complete.yaml"))
  cont = cont.to_json
end

get '/tools/:name/runtime/:version/:unit' do
  content_type :json
  cont = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/runtime/"+params[:version]+"/definition/complete.yaml"))
  cont = cont[params[:unit]]
  if  params.include? 'param' and params[:unit] == "Units"
    cont = cont[params[:param]]
  end
  cont = cont.to_json
end

get '/tools/:name/runtime/:version/:unit/:prop' do
  content_type :json
  cont = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/runtime/"+params[:version]+"/definition/complete.yaml"))
  cont = cont[params[:unit]][params[:prop]]
  if  params.include? 'param'
  cont = cont[params[:param]]
  end
  cont = cont.to_json
end

#===========================================POST==============================================================
    #-----------blueprint---------------------
post '/tools/:name/blueprint/:unit' do
  content_type :json
  file = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/blueprint/complete.yaml"))
  if  params.include? 'param' and params[:unit] == "Units"
    file[params[:unit]][params[:param]] = params[:value]
  end
  file.to_json
  File.open($pwd+"/DataBase/"+params[:name]+"/blueprint/complete.yaml", 'w') {|f| f.write file.to_yaml }
  file.to_json
end

post '/tools/:name/blueprint/:unit/:prop' do
  content_type :json
  file = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/blueprint/complete.yaml"))
  if  params.include? 'param'
     file[params[:unit]][params[:prop]][params[:param]] = params[:value]
  end
  file.to_json
  File.open($pwd+"/DataBase/"+params[:name]+"/blueprint/complete.yaml", 'w') {|f| f.write file.to_yaml }
  file.to_json
end
 
    #--------------------runtime-------------------------

post '/tools/:name/runtime/:version/:unit' do
  content_type :json
  file = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/runtime/"+params[:version]+"/definition/complete.yaml"))
  if  params.include? 'param' and params[:unit] == "Units"
    file[params[:unit]][params[:param]] = params[:value]
  end
  file.to_json
  File.open($pwd+"/DataBase/"+params[:name]+"/runtime/"+params[:version]+"/definition/complete.yaml", 'w') {|f| f.write file.to_yaml }
  file.to_json
end

post '/tools/:name/runtime/:version/:unit/:prop' do
  content_type :json
  file = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/runtime/"+params[:version]+"/definition/complete.yaml"))
  if  params.include? 'param'
     file[params[:unit]][params[:prop]][params[:param]] = params[:value]
  end
  file.to_json
  File.open($pwd+"/DataBase/"+params[:name]+"/runtime/"+params[:version]+"/definition/complete.yaml", 'w') {|f| f.write file.to_yaml }
  file.to_json
end

#============================================DELETE============================================================
   #-------------------blueprint----------------
delete '/tools/:name/blueprint/:unit' do
  content_type :json
  file = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/blueprint/complete.yaml"))
  if  params.include? 'param' and params[:unit] == "Units"
    file[params[:unit]].delete(params[:param])
    file.to_json
  end
  File.open($pwd+"/DataBase/"+params[:name]+"/blueprint/complete.yaml", 'w') {|f| f.write file.to_yaml }
  file.to_json
end

delete '/tools/:name/blueprint/:unit/:prop' do
  content_type :json
  file = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/blueprint/complete.yaml"))
  if  params.include? 'param'
    file[params[:unit]][params[:prop]].delete(params[:param])
    file.to_json
  end
  File.open($pwd+"/DataBase/"+params[:name]+"/blueprint/complete.yaml", 'w') {|f| f.write file.to_yaml }
  file.to_json
end

    #-------------------runtime------------------------
delete '/tools/:name/runtime/:version/:unit' do
  content_type :json
  file = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/runtime/"+params[:version]+"/definition/complete.yaml"))
  if  params.include? 'param' and params[:unit] == "Units"
    file[params[:unit]].delete(params[:param])
    file.to_json
  end
  File.open($pwd+"/DataBase/"+params[:name]+"/runtime/"+params[:version]+"/definition/complete.yaml", 'w') {|f| f.write file.to_yaml }
  file.to_json
end

delete '/tools/:name/runtime/:version/:unit/:prop' do
  content_type :json
  file = YAML.load(File.read($pwd+"/DataBase/"+params[:name]+"/runtime/"+params[:version]+"/definition/complete.yaml"))
  if  params.include? 'param'
    file[params[:unit]][params[:prop]].delete(params[:param])
    file.to_json
  end
  File.open($pwd+"/DataBase/"+params[:name]+"/runtime/"+params[:version]+"/definition/complete.yaml", 'w') {|f| f.write file.to_yaml }
  file.to_json
end






#---GUI-------------------------------------------------------------------------------------------------

get '/start' do
  erb :'form'
end

get '/select_bp' do
  erb :'select_bp'
end

get '/select_tg' do
  erb :'select_tg'
end

get '/test' do
  erb :'test'
end

get '/select_tt' do
  erb :'select_tt'
end

get '/select_ins' do
  erb :'select_ins'
end

get '/insert_params' do
  erb :'insert_params'
end

get '/insert_comp' do
  erb :'insert_comp'
end

get '/insert_ins' do
  erb :'insert_ins'
end

get '/select_comp' do
  $list = get_components()
  erb :'select_comp'
end

get '/select_gdml' do
  erb :'select_gdml'
end

get '/select_runtime' do
  erb :'select_runtime'
end

get '/test' do
  erb :'test'
end

get '/post' do
  erb :'post'
end

get '/show_file' do
   erb :'show_file'
end

get '/change_file' do
	$cont = YAML.load(File.read($pwd+"/DataBase/"+$bluename+"/blueprint/complete.yaml"))
	$cont = $cont.to_json
   erb :'change_file'
end

get '/get_params' do
	$cont = YAML.load(File.read($pwd+"/DataBase/"+$bluename+"/blueprint/complete.yaml"))
	$cont = $cont.to_json
   erb :'get_params'
end

post '/test' do
     puts params
end

post '/select_act' do
    $act = params[:act]  
    $blue_print = get_blue_prints()
    puts $blue_print
    if $act == "Neuer Datensatz"
        $blue_print.push "New"
        redirect '/select_bp'
    else
        redirect '/select_bp'
    end
end

post '/select_bp' do
        selected = params[:selected].to_i
        $bluename =  $blue_print[selected]
        if $act == "Neuer Datensatz"
           if $bluename=="New"
		        $groups = get_groups()         
		        redirect '/select_tg'
           elsif
              redirect '/get_params'
           end
		  elsif $act == "Datensatz ansehen"
	        $runtimes = get_runtimes($bluename)
	        redirect '/select_runtime'
		  elsif $act == "Datensatz bearbeiten"
	        redirect '/change_file'
        end
end

post '/select_tg' do
        $group = params[:selected]
        $types = get_types($group) 
        redirect '/select_tt'
end

post '/insert_params' do
        $params = get_params(params[:type_num])
        $values = $colC
        $names = $colA  
        $tool_type = params[:type_name]
        $group_name = params[:group]
        redirect '/insert_params'
end

post '/save_params' do
      insert = params[:insert]
      json = JSON.parse(params.to_json)
      $dir = json['Technical Data']['General']['Name']
      $path = 'DataBase/'+$dir+'/blueprint'
      json.delete("insert")
      yaml = json.to_yaml  
      unless Dir.exist?('DataBase/'+$dir)  #not exists
		     FileUtils.mkdir_p $path
		end                         
		File.open($path+'/complete.yaml', 'w') {|f| f.write yaml } 
      $names_in = $colI 
      if (insert.to_i == 0)
		  json = dummy_insert()
		  json = JSON.parse(json)
		  yaml = YAML.load_file $path+'/complete.yaml'
		  yaml['Technical Data']['Insert'] = json['Insert']
        File.open($path+'/complete.yaml', 'w') {|f| f.write yaml.to_yaml }
        $dir_name = create_file_name($group_name,$tool_type,"No_Insert",$dir)
        File.rename 'DataBase/'+$dir, 'DataBase/'+$dir_name 
        $path = 'DataBase/'+$dir_name+'/blueprint'
        $list = get_components()
        redirect '/select_comp'
      else 
         $ins_types = insert_types()
			redirect '/select_ins'
      end
end

post '/insert_ins' do
        $param_in = get_param_in(params[:type_num],$sheet2)
        $names_in = $colI  
        $insert_type = params[:type_name]
        redirect '/insert_ins'
end

post '/save_ins' do
      json = JSON.parse(params.to_json)
      yaml = YAML.load_file $path+'/complete.yaml'
      yaml['Technical Data']['Insert'] = json['Insert']
      $dir_name = create_file_name($group_name,$tool_type,$insert_type,$dir)
		File.open($path+'/complete.yaml', 'w') {|f| f.write yaml.to_yaml }
      File.rename 'DataBase/'+$dir, 'DataBase/'+$dir_name
      $path = 'DataBase/'+$dir_name+'/blueprint'
      redirect '/select_comp'
end

post '/insert_comp' do
     $comp_param = get_comp_param(params)
     $comp_param = $comp_param.to_json
     redirect '/insert_comp'
end

post '/save_comp' do
      json = JSON.parse(params.to_json)
      yaml = json.to_yaml  
		File.open($path+'/components.yaml', 'w') {|f| f.write yaml } 
      redirect '/select_gdml'
end

post '/save_gdml' do
   if params[:act] == "Submit"
	File.open($path+"/3dmodel.gdml", "w") do |f|      #params[:myfile][:filename]
		 f.write(params[:myfile][:tempfile].read)
	end
   end
	redirect '/start'
end

post '/save_changes' do
      json = JSON.parse(params.to_json)
		yaml = json.to_yaml 
      unless Dir.exist?('DataBase/'+$bluename+'/runtime')  #not exists
		     FileUtils.mkdir_p 'DataBase/'+$bluename+'/runtime'
		end                 
      time = Time.new
      dir_time = time.strftime("%Y_%m_%d_%H_%M_%S")
      num = get_num('DataBase/'+$bluename+'/runtime') 
      $runtime = 'DataBase/'+$bluename+'/runtime/'+ num.to_s + '_' + dir_time
      FileUtils.mkdir_p $runtime
      FileUtils.cp_r 'DataBase/'+$bluename+'/blueprint/',  $runtime+'/definition'
		File.open($runtime+'/definition/complete.yaml', 'w') {|f| f.write yaml } 
      File.delete($runtime+'/definition/components.yaml')
      redirect '/start'
end

post '/select_runtime' do
   $run = params[:selected]
   if $run == "blueprint"
         file = $pwd + "/DataBase/"+$bluename+"/blueprint"
   elsif
         file = $pwd + "/DataBase/"+$bluename+"/runtime/"+ $run+"/definition"		
   end
	$cont = YAML.load(File.read(file+'/complete.yaml'))
	$cont = $cont.to_json
   $cont2 = YAML.load(File.read($pwd+"/DataBase/"+$bluename+"/blueprint/components.yaml"))
	$cont2 = $cont2.to_json
	redirect '/show_file'            
end

post '/save_bp' do
      puts params
      json = JSON.parse(params.to_json)
      $dir = json['Technical Data']['General']['Name']
      $dir_name = get_num_blue($bluename,$dir)
      $path = 'DataBase/'+$dir_name+'/blueprint'
      yaml = json.to_yaml  
      unless Dir.exist?('DataBase/'+$dir_name)  #not exists
		     FileUtils.mkdir_p $path
		end                         
		File.open($path+'/complete.yaml', 'w') {|f| f.write yaml } 
      redirect '/select_comp'
end

