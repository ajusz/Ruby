require 'dbi'
require 'drb/drb'

$db = DBI.connect("DBI:SQLite3:komunikaty.db")
URI="druby://localhost:9000"

#Dodanie tabeli do bazy
$db.do "CREATE TABLE IF NOT EXISTS Komunikaty(Prg_id INTEGER, Time INTEGER, Msg TEXT)"
#Wypisanie wszystkich komunikatów z bazy
$db.select_all("SELECT * FROM Komunikaty")do |row|
			puts "#{row[0]}\t#{row[1]}\t#{row[2]}"
end

class LogSerwer
	def initialize
		@@id = 0
	end
	#metoda zwracająca kolejne id
	def as_id
		@@id = @@id+1
		return @@id
	end
	#metoda save wstawia do tabeli komunikatów id programu, czas wysłania komunikatu oraz komunikat
	def save(id, message)	
		$db.execute "INSERT INTO Komunikaty(Prg_id, Time, Msg) VALUES('#{id}', '#{Time.now.to_i}', '#{message}')"
	end
	#metoda raport zwraca kod html, w którym znajduje się tabela komunikatów spełniających podane kryteria
	def raport(from, to, prg_id, re)	
		results = "<html>\n<body>\n"	#początek pliku html
		results += "<style>\ntable, th, td {\nborder: 1px solid black;\nborder-collapse: collapse;\}\n</style>"	#określenie stylu tabeli
		results += "<table>\n"	#początek tabeli
		results += "<tr><th>Prg_id</th><th>Time</th><th>Message</th></tr>"	#dodanie nagłówków do tabeli
		#wybieramy z tabeli te wiersze, w których czas należy do wyznaczonego przedziału oraz id programu jest równe podanemu
		$db.select_all "SELECT * FROM Komunikaty WHERE Time BETWEEN #{from.to_i} AND #{to.to_i} AND Prg_id=#{prg_id}" do |row|
			if("#{row[2]}" =~ re)	#wybieramy te wiersze, które pasują do podanego wyrażenia regularnego
				results += "<tr><td>" + "#{row[0]}" + "</td><td>" + Time.at("#{row[1]}".to_i).to_s + "</td><td>" + "#{row[2]}" + "</td></tr>\n"
			end
		end
		results += "</table>\n"	#koniec tabeli
		results += "</body>\n</html>"	#koniec pliku html
	end
	def LogSerwer.Run
		@@server = LogSerwer.new
		DRb.start_service('druby://localhost:9000', @@server)
		DRb.thread.join
	end
end
LogSerwer.Run

$db.disconnect
