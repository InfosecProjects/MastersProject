from docx import Document
import os

# Open a list of keywords
f = open("keywords.txt", "r").read().split("\n")
print(f)

# Get a list of all files in a directory (doc or docx for this example)
cwd = os.getcwd()

for root, dirs, files in os.walk(cwd + "/Documents"):
   for name in files:
      print(os.path.join(root, name))
   for name in dirs:
      print(os.path.join(root, name))


files = os.walk(cwd)
print(files)
my_file = os.getcwd() + "/Documents/paper.docx"

# Open each .docx file
document = Document(my_file)
# For each paragraph in the documents
for para in document.paragraphs:
    for keyword in f:
        if (para.text.find(keyword)) != -1:
            print(para.text)

# Search returns true if found

#print((document,'your search string')())
