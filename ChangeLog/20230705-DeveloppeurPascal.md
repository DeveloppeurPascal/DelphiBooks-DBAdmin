# 20230705 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

* set has changed property from items when adding/removing an element from a child list
=> book's authors
=> book's publishers
=> descriptions
=> tables of content

* Replace "save" button by "Close" in descriptions/tocs insert/edit screens
* Replaced "&Cancel" by "Ca&ncel" because "c" is already the "Close" shortcut key

* save books, authors, publishers and languages to the repository when "save" on Insert/Edit screen
* replace "save and exit" and "cancel" buttons by "close" button on authors, publishers, books and languages lists

* set HasNewImage when changing a book cover in fBookCoverImage.pas
* reduce too big pictures when displaying them in a TImageViewer
* add a "remove picture" button on image cover editor

* add ReportMemoryLeaksOnShutdown in debug mode

* hide "description" button from publisher in INSERT mode
* hide "description" & co buttons from book in INSERT mode

* fixed : Missing "lang" field on books edition
* added "language" to "iso 2 letters code" field and error message (fDescriptions.pas & fTablesOfContent.pas

* removed onCloseQuery event (no global list change is waiting, each item is saved outside the list)
=> books, publishers, authors and languages list screens

* released version 2.1 - 20230705
