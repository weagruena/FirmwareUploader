require 'rubygems'
require 'ftools'
require 'zip/zip'

desc "Publish / Release project"
task :new => [:backup, :installer] do		
end

desc "Backup project"
task :backup do
	fUploader = "./_save/backup_uploader_#{Time.now.strftime("%d%m%y")}.zip"
	#Clear backup
	File.delete(fUploader) if File.exist?(fUploader)
	#Make backup
	Zip::ZipFile.open(fUploader, true) do |zip|
		Dir['{src,dist}/**/*'].each { |f| zip.add(f,f) }
	end
end

desc "Create installer"
task :installer do
  Dir.chdir("src")	
  system("ocra upload.rb")
	
	File.move("./upload.exe", "../release", true)
	File.copy("./config.txt", "../release", true)
	File.copy("./readme.txt", "../release", true)
	File.copy("./license.txt", "../release", true)
	File.copy("./sihpP1005.dl", "../release", true)	
  
  Dir.chdir("../_Setup_NSIS")
  script = "FirmwareUploader_Setup.nsi"
  system("d:/Programmierung/NSIS/makensis.exe #{script}")
  File.move("./setup.exe", "../dist", true)
end
