require 'test/unit'
class DrzewoBinarne
	attr_accessor :root
	
	class Element
		attr_accessor :value
		include Comparable
		def initialize(value)
				@value = value
		end
		
		def <=>(other)
			self.value <=> other.value
		end
		
		def to_s
			value.to_s
		end
	end
	
	class Node
		attr_accessor :value, :left, :right
		def initialize(v)
			@value = Element.new(v)
			@left = nil
			@right = nil
		end
		
		def wstaw(e)
			if e <= @value
				@left.nil? ? @left = Node.new(e.value) : @left.wstaw(e)
			elsif e > @value
				@right.nil? ? @right = Node.new(e.value) : @right.wstaw(e)
			end
		end
		
		def print_inorder
			@left.print_inorder unless @left.nil?
			puts @value
			@right.print_inorder unless @right.nil?
		end 
		
		def istnieje?(e)
			if e == @value
				true
			elsif e < @value && @left
				@left.istnieje?(e)
			elsif e > @value && @right
				@right.istnieje?(e)
			else 
				false
			end
		end
		
		def min
			if self.left.nil?
				self.value
			else 
				self.left.min
			end
		end
		
		def usun(e)
			if e < @value
				if @left.nil?
					false
				else
					@@parent = self
					@left.usun(e)
				end
			elsif e > @value
				if @right.nil?
					false
				else
					@@parent = self
					@right.usun(e)
				end
			else
				if @right.nil? && @left.nil?
					if self == @@parent.left
						@@parent.left = nil
					elsif self == @@parent.right
						@@parent.right = nil
					end
				elsif @right.nil? 
					if self == @@parent.left
						@@parent.left = self.left
					elsif self == @@parent.right
						@@parent.right = self.left
					end
				elsif @left.nil? 
					if self == @@parent.left
						@@parent.left = self.right
					elsif self == @@parent.right
						@@parent.right = self.right
					end
				else
					x = @right.min
					self.value = x
					@right.usun(x)
				end
				
				true
			end
			
		end
		
	end
	
	def initialize
		@root = nil
	end
	
	def wstaw(value)
		if @root.nil?
			@root = Node.new(value)
		else
			e = Element.new(value)
			@root.wstaw(e)
		end
	end	 
	
	def istnieje?(value)
		if @root.nil?
			false
		else
			e = Element.new(value)
			@root.istnieje?(e)
		end
	end
	
	def usun(value)
		if @root.nil?
			false
		else
			e = Element.new(value)
			if @root.value == e 
				if @root.left.nil? && @root.right.nil?
					@root = nil
				elsif @root.left.nil?
					@root = @root.right
				elsif @root.right.nil?
					@root = @root.left
				else
					x = @root.right.min
					self.value = x
					@root.right.usun(x)
				end
				true
			else
			@root.usun(e)
			end
		end	
	end
end

class StringBT < DrzewoBinarne
	class Element
		attr_accessor :value
		include Comparable
		def initialize(value)
				@value = value
		end
		
		def <=>(other)
			self.value.to_s <=> other.value.to_s
		end
	end
end

class TestDrzewoBinarne < Test::Unit::TestCase

	def test_wstaw_istnieje
		d = DrzewoBinarne.new()
		0.upto(10) { | i | d.wstaw(i) }
		490.upto(500) { | i | d.wstaw(i) }
		0.upto(10) { | i | assert_equal(true, d.istnieje?(i)) }
		490.upto(500) { | i | assert_equal(true, d.istnieje?(i)) }
	end
	
	def test_usun
		d = DrzewoBinarne.new()
		0.upto(20) { | i | d.wstaw(i) }
		0.upto(10) { | i | assert_equal(true, d.usun(i)) }
		0.upto(10) { | i | assert_equal(false, d.usun(i)) }
		11.upto(20) { | i | assert_equal(true, d.usun(i))}
		0.upto(20) { | i | assert_equal(false, d.usun(i))}		
	end
	
	def test_wyjatki
		assert_raise(ArgumentError){DrzewoBinarne.new(10)}
	end
	
	def test_StringBT_metody
		d = StringBT.new()
		assert_respond_to(d, :wstaw)
		assert_respond_to(d, :usun)
		assert_respond_to(d, :istnieje?)
	end
	
	def test_string_wstaw_usun_istnieje
		d = StringBT.new()
		"a".upto("z") { | i | d.wstaw(i) }
		"a".upto("k") { | i | assert_equal(true, d.usun(i)) }
		"a".upto("k") { | i | assert_equal(false, d.istnieje?(i)) }
		"l".upto("z")	{ | i | assert_equal(true, d.istnieje?(i)) }
	end
end
