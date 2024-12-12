To have the app work with your data, the data must be in this format:

The column names for the csv should be: 
1. doc_id, 
2. date, 
3. year, 
4. month, 
5. day, 
6. hour, 
7. sentence, 
8. text, and 
9. any number of emotion columns with their respective scores ranging from 0 to 1

The csv must also be delimited by '|' since journal entries with ',' are very common and can result in the parser misreading your data.
