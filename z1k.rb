require 'drb/drb'

SERVER_URI="druby://localhost:9000"
DRb.start_service

class Client
	def initialize
		@log_service = DRbObject.new_with_uri(SERVER_URI)	#utworzenie instancji obiektu połączonego z serwerem
		@id = @log_service.as_id
	end
	
	def send(message)	#wysyłanie komunikatu
		if @log_service.respond_to?('save')
			@log_service.save(@id, message)	#podajemy id programu i komunikat jako argumenty funkcji save na serwerze
		end
	end
	
	#metoda raportk wyszukuje komunikaty z podanego zakresu czasu, pasujące do podanego wyrażenia regularnego
	#metoda ta zwraca kod html, w którym znajduje się tabela z komunikatami spełniającymi podane kryteria dla danego programu
	def raportk(from, to, re)	
		if @log_service.respond_to?('raport')
			@log_service.raport(from, to, @id, re)
		end	
	end
end

p1 = Client.new
p2 = Client.new
p3 = Client.new

puts "Jeśli chcesz dodać komunikat wpisz 1"
puts "Jeśli chcesz zakończyć dodawanie komunikatów wpisz coś innego niż 1"
while(napis = gets)
	napis.chomp!
	if napis == '1'
		puts "Wybierz który program wysyła komunikat (wpisz 1, 2 lub 3)"
		nr = gets
		nr.chomp!
		puts "Podaj komunikat programu nr "+nr
		k = gets
		k.chomp!
		if(nr == '1')
			p1.send(k)
		elsif(nr == '2')
			p2.send(k)
		elsif(nr == '3')
			p3.send(k)
		end
	else
		break
	end
end

File.open("raporty.html", "w") do |f|
	f.puts p1.raportk(0, Time.now, /komunikat|Coś/)
end
