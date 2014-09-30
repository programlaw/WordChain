# WordChain v1.0 - Will Atkinson
# Created: Sept. 29, 2014

class Word_Chain
     @@dictionary = Array.new # assign class variable dictionary to new array
     attr_reader :start, :finish, :wordchain # these instance variables are readable throughout Word_Chain class
     
     # normalize instance variables during instantiation
     def initialize( start, finish )
         @start  = self.class.clean_input(start)
         @finish = self.class.clean_input(finish)
         @wordchain = nil
     end

     # clean up input
     def self.clean_input( word )
        clean = word.dup
        clean.strip! # remove whitespace
        clean.delete!("^a-z") # take out anything that's not normal lower-case letters
        clean.downcase! # downcase
        clean
     end

     # check if words are in dictionary
     def self.check_words( start, finish )
        words_array = []
        f = File.open("words.txt")
        f.each_line do |line|
            words_array << line.chomp
        end
        f.close
        if words_array.any? { |x| x.include? start } == false or
            words_array.any? { |x| x.include? finish } == false or
            start == "" or finish == ""
                return false
        else
                return true
        end
    end

     # Calculates the Levenshtein distance between two strings
     def self.levenshtein_distance( first_word, second_word ) #lev_difference(first_word, second_word)
            first_word_length = first_word.length
            second_word_length = second_word.length

            # base case for empty strings
            return 0 if first_word == second_word
            return first_word_length if second_word_length == 0  
            return second_word_length if first_word_length == 0

            # create array with slots of first_word_length + 1
            # each slot contains an array with same slots as second_word_length + 1
            distance = Array.new(first_word_length+1) { Array.new(second_word_length+1) }

            # create grid for determining Levenshtein distance
            (0..first_word_length).each {|x| distance[x][0] = x}
            (0..second_word_length).each {|y| distance[0][y] = y}
            (1..second_word_length).each do |y| # iterate by y through each character & measure distance
                (1..first_word_length).each do |x| # go through each x row during each y iteration
                    distance[x][y] = 
                        if first_word[x-1] == second_word[y-1]
                            distance[x-1][y-1]          # nothing changed
                        else
                            [   distance[x-1][y]+1,       # deletion
                                distance[x-1][y-1]+1,   # substitution
                                distance[x][y-1]+1,     # addition
                            ].min # return minimum of delete/substitute/add
                        end
                end
            end
            distance[first_word_length][second_word_length] # returns the Levenshtein distance
    end

     def self.scan_file( start_word, finish_word)
        max_length = ""

        # determine if the start or finish word is larger
        if start_word.length > finish_word.length
            max_length = start_word
        else
            max_length = finish_word
        end

        # iterate through words.txt
        File.foreach("words.txt") do |word|
            word = clean_input(word)
            next unless max_length.length - word.length <= 3 # limit words added to the dictionary to words w/i 3 of max_length
                    @@dictionary << word
        end

         @@dictionary.uniq! # remove any duplicate items from array
     end

     # word chain builder
     def get_chain_link
         chain_links = Array[Array[@start]]

         until chain_links.empty? or self.class.levenshtein_distance(chain_links.first.last, @finish) == 1
               # run until chain is empty or lev distance from last element in subarray is 1
                compare_word = chain_links.shift # remove first element from chain links for comparison
             
                # find next word in chain
                next_words = @@dictionary.select do |word|
                     self.class.levenshtein_distance(compare_word.last, word) == 1 and
                         not compare_word.include? word
                end
                
                # add the next word to the chain
                next_words.each { |x| chain_links << (compare_word.dup << x) }
                chain_links = chain_links.sort_by { |y| y.length + self.class.levenshtein_distance(y.last, @finish) }
         end

         if chain_links.empty?
             @wordchain = Array.new
         else
             @wordchain = (chain_links.shift << @finish)
         end
     end

     def to_s # word chain printed on a puts command
         get_chain_link if @wordchain.nil?

         if @wordchain.empty?
             "No chain found between #{@start} and #{@finish}."
         else
             @wordchain.join(" ==> ")
         end
     end
end

puts "
 #     #                               #####                             
 #  #  #   ####   #####   #####       #     #  #    #    ##    #  #    # 
 #  #  #  #    #  #    #  #    #      #        #    #   #  #   #  ##   # 
 #  #  #  #    #  #    #  #    #      #        ######  #    #  #  # #  # 
 #  #  #  #    #  #####   #    #      #        #    #  ######  #  #  # # 
 #  #  #  #    #  #   #   #    #      #     #  #    #  #    #  #  #   ## 
  ## ##    ####   #    #  #####        #####   #    #  #    #  #  #    # 
                                                                         "
                                                                                            
# Get starting and ending chain words from user
print "What is your starting word? "
start = gets.chomp

print "What is your ending word? "
finish = gets.chomp

# check if words are in dictionary and aren't blank
if Word_Chain.check_words(start, finish) == true
    # load words.txt if true
    Word_Chain.scan_file(start, finish)
    puts "\nWord chain: "
    puts Word_Chain.new(start, finish)
else
    abort("Invalid entry.")
end