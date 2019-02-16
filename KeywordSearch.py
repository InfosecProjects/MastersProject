from docx import Document
import os

# Open a list of keywords
f = open("keywords.txt", "r").read().split("\n")
print("Keywords: ")
print(f)

# Get a list of all files in a directory (doc or docx for this example)
cwd = os.getcwd()

for root, dirs, files in os.walk(cwd + "/Documents"):
    for name in files:

        # Open each .docx file
        document = Document(os.path.join(root, name))
        # For each paragraph in the documents
        for para in document.paragraphs:
            for keyword in f:
                if (para.text.find(keyword)) != -1:
                    print("Found keyword: '" + para.text + "'")
                    print("File: " + os.path.join(root, name) + "\n")

# Search returns true if found
