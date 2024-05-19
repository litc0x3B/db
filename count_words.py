# Find frequency of each word in a string in Python
# using dictionary.
import re

def count(elements, dictionary):
    # check if each word has '.' at its last. If so then ignore '.'
    if elements[-1] == '.':
        elements = elements[0:len(elements) - 1]

    # if there exists a key as "elements" then simply
    # increase its value.
    if elements in dictionary:
        dictionary[elements] += 1

    # if the dictionary does not have the key as "elements"
    # then create a key "elements" and assign its value to 1.
    else:
        dictionary.update({elements: 1})

# driver input to check the program.

with open('./metadata.csv', 'r') as file:
    text = '\n'.join(file.readlines())
    # Declare a dictionary
    dictionary = {}

    lst =[]
    quoted = re.compile("'[^']*'")
    for value in quoted.findall(text):
        lst.append(value)

    # take each word from lst and pass it to the method count.
    for elements in lst:
        count(elements, dictionary)
    
    res = [(key, value) for key, value in dictionary.items()]
    res.sort(key=lambda x: x[1], reverse=False)
    # print(*res, sep='\n')
    print(*[key for key, value in res], sep='\n')