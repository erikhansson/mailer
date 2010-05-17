require 'net/protocol'

module Net # :nodoc:
  class InternetMessageIO < BufferedIO   #:nodoc: internal use only
    def each_crlf_line(src)
      buffer_filling(@wbuf, src) do
        while line = @wbuf.slice!(/\A.*(?:\n|\r\n|\r(?!\z))/u)
          yield line.chomp("\n") + "\r\n"
        end
      end
    end
  end
end
