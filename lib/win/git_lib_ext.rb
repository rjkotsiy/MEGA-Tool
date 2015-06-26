# encoding: utf-8
# this is patch for Git library, if you run command to RUBY_PLATFORM == java

if MGT::ParamsParser.os == :windows

	module Git
		class Lib
			def escape(s)
	     	return "'#{s && s.to_s.gsub('\'','\'"\'"\'')}'" if RUBY_PLATFORM !~ /mingw|mswin|java/
	      
	     	# Keeping the old escape format for windows users
	     	escaped = s.to_s.gsub('\'', '\'\\\'\'')
	     	return %Q{"#{escaped}"}
	    end
    end
  end

end