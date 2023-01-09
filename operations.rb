# Speaking about ruby, I love Touhou and some anime (not all), oh maybe undertale too!
def getchoice(text)
    print(text + " (Y/N): ")
    get_ch = $stdin.gets.chomp.downcase.chars
    while !get_ch[0].eql?('y') && !get_ch[0].eql?('n') do
        puts "Invalid case input"
        print text + " (Y/N): "
        get_ch = $stdin.gets.chomp.downcase.chars
    end
    return get_ch[0].eql? 'y'
end


def input(text)
    print text
    return $stdin.gets.chomp
end

class FDatabase
    @app
    @str
    def initialize(str, app=false)
        if !File.exist? str then
            f = File.open str, "w"
            f.write ""
            f.close
        end
        @app = app
        @str = str
    end
    def write(content)
        opened_file = File.open(@str, @app ? "a" : "w")
        opened_file.write content
        opened_file.flush
    end
    def index_at()
        return self.read_file().count + 1
    end
    def read_file()
        opened_file = File.open(@str)
        return opened_file.readlines()
    end
    def check_exist(key, retmode="bool")
        exist = false
        data = []
        self.read_file.each { |ln|
            lw = ln.downcase
            if lw.include? key.downcase then
                exist = true
                data = lw.split ","
            end            
        }
        if retmode.casecmp? "bool" then
            return exist
        else
            return data
        end
    end
end