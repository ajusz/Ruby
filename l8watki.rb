require 'open-uri'
require 'thread'

class Pages

	def initialize
		@odwiedzone = Array.new
		@mutex = Mutex.new
		@print = Mutex.new
	end
	
	def przeglad(start_page, depth, block)
		start_page.strip!
		if start_page[start_page.length-1] == '/'
			start_page.chop!
		end
		@mutex.synchronize{
		if @odwiedzone.include?(start_page)
			return
		end
		}
		@mutex.synchronize{
			@odwiedzone.push(start_page)
		}
		nieodwiedzone = Array.new()
		
		open(start_page)  do |fh|
			p = ""
			fh.each_line { |line| p = p + line}
			@print.synchronize{
			block.call p
			}
			
			
			if depth == 0
				return
			end
			reg = /<a href="\S+"/
			p.each_line do |line|
				if(line=~reg)
					link = $&.chomp('"').gsub('<a href="', "")
					link.strip!
					if link[0] == '/'
						link = start_page + link
					end
					if link[link.length-1] == '/'
						link.chop!
					end		
					reg1 = /http\S+/
					if link =~ reg1
						nieodwiedzone.push(link)
					end						
				end
			end
			threads = []
			nieodwiedzone.each do |page|
				threads<<Thread.new{przeglad(page, depth-1, block)}
			end
			threads.each{|thr| thr.join()}
		end
		
		rescue
	end
	
	def page_weight(page) 
		reg1 = /<img | <canvas | <video | <audio/
		page.scan(reg1).length
	end 

	def page_summary(page)
		reg = %r{<head>((\s|\S)*?)</head>}
		reg1 = %r{<title>((\s|\S)*?)</title>}
		reg2 = %r{<meta((\s|\S)*?)>}
		reg3 = %r{name\s*=\s*"(\S*?)"}
		reg4 = %r{content\s*=\s*"((\s|\S)*?)"}
		
		if page =~ reg
			new = $1
			if new =~ reg1
				puts "Tytuł: " + $1.strip
			end
			tab = Array.new
			tab = new.scan(reg2)
			for i in 0..tab.size()-1 do
				if(tab[i][0] =~ reg3)
					name = $1
					if(tab[i][0] =~ reg4)
						content = $1
							puts name + ": " + content
					end
				end
			end
		end
	end

end
		
block = proc { |page|  puts Pages.new.page_weight(page)
						Pages.new.page_summary(page)}
strona = Pages.new()
strona.przeglad("http://miroslawzelent.pl/", 1, block)
