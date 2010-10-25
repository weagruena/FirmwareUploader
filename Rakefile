require 'rubygems'
require 'ftools'
require 'zip/zip'

desc "Publish / Release project"
task :new => [:backup, :make_exe, :installer] do		
end

desc "Backup project"
task :backup do
	fUploader = "./_save/backup_uploader_#{Time.now.strftime("%d%m%y")}.zip"
	#Clear backup
	File.delete(fUploader) if File.exist?(fUploader)
	#Make backup
	Zip::ZipFile.open(fUploader, true) do |zip|
		Dir['{src,dist}/**/*'].each { |f| zip.add(f,f) }
		Dir['*'].each { |f1| zip.add(f1,f1) if !File.directory?(f1)}
	end
end

desc "Make EXE"
task :make_exe do
	Dir.chdir("src")	
	system("ocra upload.rb")
	system("ocra test_server.rb")
	
	File.move("./upload.exe", "../release", true)
	File.move("./test_server.exe", "../release", true)
	File.copy("./config.txt", "../release", true)
	File.copy("./readmeD.txt", "../release", true)
	File.copy("./readmeE.txt", "../release", true)
	File.copy("./licenseD.txt", "../release", true)
	File.copy("./licenseE.txt", "../release", true)
	File.copy("./sihpP1005.dl", "../release", true)	
end

desc "Create installer"
task :installer do
	# InnoSetup installer
	Dir.chdir("..")
	script = "innosetup.iss"
	installer = "d:/Programmierung/InnoSetup"
	system("#{installer}/iscc.exe /O#{Dir.pwd} /Fuploader_setup  #{script}")
	File.move("uploader_setup.exe", "dist", true)
end
