# 20230704 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

Work on DBAdmin v2.0

* added fDescripions.pas unit by copying fLanguages.pas unit to manage descriptions for authors, publishers and books
* added fTablesOfContent.pas unit by copying fDescripions.pas unit to manage the table of content for books
* added the descriptions for an author in authors screen
* added the descriptions for a publisher in publishers screen
* added the descriptions for a book in books screen
* added the tables of content for a book in books screen
* added a shortcut key for "add" button in all screens

On descriptions form :

* removed CANCEL button (and its code) on the list
* renamed the "save and exit button" to "close"
* enabled multiline text on the memo (wordwrap)
* added a control on ISO code (presence in the global languages list)

On tables of content form :

* removed CANCEL button (and its code) on the list
* renamed the "save and exit button" to "close"
* enabled multiline text on the memo (wordwrap)
* added a control on ISO code (presence in the global languages list)

* added fBookAuthors.pas unit to manage the authors of a book
* added the authors for a book in books screen

* changed default form position in show modal

* added fBookPublishers.pas unit to manage the authors of a book
* added the publishers for a book in books screen

* added a picture selector form for book's cover
* added a button to choose the book's cover image
* change the buttons display on book's detail screen

* updated the version date to "20230704"

changed "Biography" in "Description" on the button (books and publishers)
removed accessory image in list items (authors & publishers of books)

* released version 2.0 - 20230704 and added the program in [DelphiBooks-WebSite](https://github.com/DeveloppeurPascal/DelphiBooks-WebSite) repository
