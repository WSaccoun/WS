require 'creek'
require 'rexml/document'
include REXML
require 'fileutils'
require 'json'
require 'yaml'
require 'pathname'
require 'fileutils'
require 'rubygems'
require 'daemons'

$pwdxlsx  = File.dirname(File.expand_path(__FILE__))
filexlsx = $pwdxlsx + '/params.xlsx'
workbook = Creek::Book.new filexlsx
worksheets = workbook.sheets
$sheet = workbook.sheets[0]
$sheet2 = workbook.sheets[1]
$sheet3 = workbook.sheets[2]
$sheet4 = workbook.sheets[3]
$sheet5 = workbook.sheets[4]

$tool_groups = $sheet.rows.to_a[1]
$inserts = $sheet2.rows.to_a[0]
$names3 = $sheet3.rows.to_a[0]
$comp = $sheet5.rows.to_a[0]

$cells = Hash.new
  $sheet.rows.each do |row|
    $cells.merge!(row)
  end

def prepare_col(name,sheet,drop_value)
colA = sheet.simple_rows.map{|col| col[name]}
colA.map! {|e| e ? e : 0}
colA = colA.drop(drop_value)
return colA
end

$colA = prepare_col("A",$sheet,3)
$colC = prepare_col("C", $sheet,3)
$colI = prepare_col("A",$sheet2,1)
#$colB = sheet.simple_rows.map{|col| col['B']}

$row_group = []
group = []
group_name = ""
$tool_groups.each do |key, value|
   if key != 'A2' && key != 'B2' && key != 'C2'
   	unless value.nil?      # if value != null (unless)
         $row_group.push [group_name,group]
         group = []
         group_name = value
      end
      group.push key
   end
end

def insert_types()
ins_types = []
$inserts.each do |key, value|
   if key != 'A1' 
      ins_types.push [[value], [key]]
   end
end
return ins_types
end

def get_groups()
   select_group = []
	$tool_groups.each do |key, value|
   	unless value.nil?      # if value != null (unless)
         select_group.push value
      end
   end
   return select_group
end

def get_types(param)
select_group = get_groups()
ind = select_group.index(param) + 1
types = $row_group[ind][1]
final = []
types.each do |col|
	pos = col.index('2')
   new = col.dup
   new[pos] = "3"
   final.push [[$cells[new]], [new]]
end
return final
end

def get_params(param)
col_name  = param.chomp("3")
col_val = $sheet.simple_rows.map{|col| col[col_name]}
col_val = col_val.compact
return col_val
end

def get_param_in(param,sheet)
col_name  = param.chomp("1")
col_val = sheet.simple_rows.map{|col| col[col_name]}
col_val = col_val.compact
return col_val
end

def get_group_number(main,group)
col = $names3.index(main) 
col_name  = col.chomp("1")
col_val = $sheet3.simple_rows.map{|col| col[col_name]}
index = col_val.index(group).to_s;
len =  index.length
	if group == "Other" || group =="Unknown"
		 group_number = "000"
   elsif group == "No_Insert"
       group_number = "999"
	elsif len == 1
		 group_number = "00" + index
	elsif len == 2
		 group_number = "0" + index 
	end
return group_number
end

def create_file_name(group,type,insert,tool_name)
n1 = get_group_number('Groups',group)
n2 = get_group_number(group,type)
n3 = get_group_number('Inserts',insert)
name = n1 + n2 + n3 + '_0001_' + tool_name
return name
end

def get_components()
   final = {}
	$comp.each do |key, value|
		col = $comp.index(value) 
		val = get_param_in(col,$sheet5)
      val = val.drop(1)
      final[value] = val
	end
   return final.to_json
end

def get_comp_param(val)
final = {}
comp = $sheet4.rows.to_a[0]
val.each do |key, value|
if value != "empty"
col = comp.index(value)
final[key] = get_param_in(col,$sheet4)
end
end
return final
end

def get_blue_prints()
blueprints = []
test = Pathname($pwdxlsx+'/DataBase').children.select(&:directory?)
test.each do |t|
a = t.to_s
a = a.split('/')[-1]
blueprints.push a
end
return blueprints
end 

def get_runtimes(blueprint)
blueprints = []
path = $pwdxlsx+'/DataBase/' + blueprint + '/runtime'
if Dir.exist?(path)
test = Pathname(path).children.select(&:directory?)
test.each do |t|
a = t.to_s
a = a.split('/')[-1]
blueprints.push a
end
end
return blueprints
end 

def get_num(path)
blueprints = []
test = Pathname(path).children.select(&:directory?)
test.each do |t|
a = t.to_s
a = a.split('/')[-1]
blueprints.push a
end
num = blueprints.length
return num + 1
end 

def dummy_insert()
	b = {}
   c = {}
	$colI.each do |a|
		if a != 0
			b[a] = "NA"
		end
	end
   c["Insert"] = b
   return c.to_json
end


def get_num_blue(name,last)
path = $pwdxlsx+"/DataBase"
name=name.split(/_/)[0]
blueprints = []
test = Pathname(path).children.select(&:directory?)
test.each do |t|
a = t.to_s
a = a.split('/')[-1]
a = a.split(/_/)[0]
if a == name
blueprints.push a
end
end
num = blueprints.length
num = num + 1
num = num.to_s
len = num.length
	if len == 1
		 group_number = "000" + num
	elsif len == 2
		 group_number = "000" + num
	end
name = name + "_" + group_number + "_"+ last 
return name
end 

#cont2 = YAML.load(File.read("/home/nataliiak93/Projects/GIT/pimpel/DataBase/001002999_0001_schaftfraeserFRD10HM/blueprint/components.yaml"))
#puts cont2
#cont2 = cont2.to_json
#puts cont2




