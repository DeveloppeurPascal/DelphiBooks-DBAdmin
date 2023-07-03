# 20230703 - [DeveloppeurPascal](https://github.com/DeveloppeurPascal)

Work on DBAdmin v2.0

* new FMX project created
* enabled universal binary for macOS ARM+x64_64 compilation
* updated version infos in project options
* added the icon to the project options
* added the dependencies : about dialog box, Delphi Books common units, and others from [DeveloppeurPascalLibrairies](https://github.com/DeveloppeurPascal/librairies)
* added the About Box dialog and set its parameters
* added the menu buttons to main form
* implemented onclick event for "about the program" button
* implemented onclick event for "close" button
* added a database from repository loading
* added the database save to the repository
* added the CRUD form for the languages
* implemented the onclick event on "Languages" button in main form
* added "save and exit" and "cancel" buttons on the languages CRUD form
* filled the list in Languages form
* finished the languages CRUD form

* added a search field on the list view (fLanguages.pas)
* added shortcuts for 'Save' and 'Close'/'Cancel' buttons (fLanguages.pas)
* added some TODOs (fLanguages.pas)

* added fPublishers.pas unit to the project
* added fPublishers.pas unit for publishers CRUD operations by copying fLanguages.pas unit
* call frmPublishers form from main form

* added fAuthors.pas unit to the project
* call frmAuthors form from main form
* added fAuthors.pas unit for authors CRUD operations by copying fPublishers.pas unit

* added fBooks.pas unit to the project
* call frmBooks form from main form
* added fBooks.pas unit for authors CRUD operations by copying fAuthors.pas unit

* changed version number display in main form title bar
