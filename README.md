Ruby WordChain v1.0
===================

This program accepts two words and builds a chain of words between the initial two words.
Each successive entry in the chain only differs by one character (i.e., a Levenshtein distance of 1).

For example, you can get from "cat" to "bird" using the following chain:
  cat -> bat -> bit -> bid -> bird

Unlike Kata19, the words in this program can vary in length.

### How to use:
1. At the command prompt, type "ruby wordchain.rb"
2. Enter the first word in the word chain
3. Enter the second word in the word chain
4. Wait (hopefully not too long!)
5. Voila!
