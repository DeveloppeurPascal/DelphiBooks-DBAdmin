# DelphiBooksAdmin-Soft

## TODO Liste de Delphi-Books.com

### bogues :

* vérifier stockage des caractères non latins dans la base de données lors de la traduction automatique

--------------------------------------------------

### évolutions du site :

- ajouter la saisie de commentaires de lecteurs sur les livres
- ajouter une page d'infos légales (éditeur, hébergeur, copyright photos/pictos, marques déposées, ...)
- ajouter un formulaire de contact
- faire l'index général du site (avec redirection automatique sur la langue du navigateur si elle est dispo, sinon vers la page de choix de la langues à afficher)
- faire page de choix de la langue à afficher
- Dans le header des pages mettre le lien "lecteurs"
<a href="lecteurs.html" title="All readers" class="btn"><img src="../img/btn/BoutonLecteurs.gif" alt="Readers"></a>
- Dans le header des pages, mettre le lien "mots clés"
<a href="motscles.html" title="All topics" class="btn"><img src="../img/btn/BoutonMotsCles.gif" alt="Topics"></a>
- Dans le header des pages mettre le lien "contact"
<a href="" title="Contact us" class="btn"><img src="../img/btn/BoutonContact.gif" alt="Contact"></a>
- changer le :hover des boutons de menus
- mettre un :hover sur les couvertures de livres
- sur la page des livres, ajouter un moteur de recherche « in page » en JS qui filtrerait les fiches affichées en fonction des mots saisis

--------------------------------------------------

### évolutions du logiciel :

- Faire un formulaire « fiche de renseignement » pour les auteurs et les éditeurs afin de mettre à jour les pages du site les concernant.
- Remplacer le composant de saisie HTML de TMS Sofware par Delphi HTML Components.
- ajouter liens pour les pages de téléchargement et de vente
- ajouter liens amazon
- ajouter email sur auteurs
- ajouter email sur éditeurs
- gérer la langue des lecteurs
- gérer la sychronisation de la base de données et des photos avec un serveur de backup
- gérer le choix de photos pour les auteurs
- gérer le choix des photos pour les éditeurs
- gérer le choix des photos pour les lecteurs
- retirer le champ "a_generer" des programmes
- retirer le champ "a_generer" des tables de la base de données
- gérer une table de traduction des textes des pages pour se servir d'un template unique pour la même page dans toutes les langues
- ajouter une suppression logique des enregistrements de chaque table, en particulier au niveau des liens entre tables principales
- Ajouter la possibilité de saisir une description au niveau des mots clés.
- Lister les descriptions / tables des matières avec leurs langues afin de repérer les absentes et pouvoir les traduire et ajouter.
- lister les livres par ordre décroissant d’ajout dans la gestion des livres (et proposer un tri par titre ou une recherche)
- ajouter la date de modification des fiches et le tag correspondant (pour le sitemap et sur les fiches de livres, les descriptions et les tables des matières pour une totale transparence)
- ajouter le tag LastMod au sitemap.xml racine et par langue :
<lastmod>2005-01-01</lastmod>
- ajouter un champ « a_lister » O/N sur les livres / éditeurs / lecteurs / auteurs / mots-clés afin de les filtrer dans les pages de liste, flux et sitemap
- afficher "a_lister" dans une colonne des grilles de saisie sous forme de rond rouge/vert clicable
- ajouter un menu au programme d’admin pour accéder à toutes les options 
- modifier la génération pour ne générer qu'une partie ou la totale, modifications de base, images, rubrique, type de page, langues...
- ajouter une fonctionnalité de consultation des backups de la base de données et pouvoir y faire du ménage ou en réimporter un
- dans le module de backup, prévoir également un archivage des originaux des couvertures de livres et autres photos (auteurs, lecteurs, logos éditeurs, ...)
- lors de la sélection d’une photo de couverture, signaler lorsque les dimensions ne sont pas bonnes (par exemple moins de 500px de large)
- pour les liens de vente, lister les sites (amazon, ebay, leanpub, lulu, …) de façon globale, puis ajouter un lien pour chaque depuis la fiche de chaque livre en fonction des langues gérées par ces sites
- les sites de vente ont un libellé, un logo, une URL générale d’affiliation (si possible) et une langue
- ajouter un O/N "generer_pages" sur les langues pour indiquer si le site est traduit dans la langue
- ne générer les pages que des langues traduites avec "generer_pages"=O
- dans le module du choix des langues d’affichage du site (index.php et choix de langues à l’écran), proposer celles qui ont des pages générées ("generer_pages"=O)
- gérer si possible les fichiers TIFF en lecture
- ajouter les traductions des textes en dur en fonction de la LangueEnCours (tags TXT_xxx et QRY LangueEnCours ou autre selon comment les traductions sont stockées)
- ajouter la possibilité d'inclure des fichiers séparés dans les templates (notamment pour header/footer)
- sur l'inclusion de fichiers, pouvoir les faire dépendre de la langue en cours (sous-dossiers "lng" du dossier "template")

- Rendre le générateur de pages plus générique et le vendre ou le mettre à disposition sur github.
- Une fois le logiciel et le back office terminés, le cloner pour liregay.com et une éventuelle refonte de Bdgay.com sans passer par une plateforme de blogs.
- faire une éventuelle version C++Builder du site

- ajouter un tag pour le nombre de livres par auteurs
- ajouter un tag pour le nombre de livres par éditeur
- ajouter un tag pour le nombre de livres par mot clé
- ajouter un tag pour le nombre de livres par lecteur
- ajouter un tag pour le nombre de livres par langues
- ajouter un tag pour le nombre de commentaires par lecteurs
- ajouter un tag pour le nombre de commentaires par livre
- ajouter un tag pour se positionner sur la description du livre dans la langue en cours
- ajouter un tag pour se positionner sur la table des matières du livre dans la langue en cours
- ajouter un tag pour se positionner sur la description de l'auteur dans la langue en cours
- ajouter un tag pour se positionner sur la description de l'editeur dans la langue en cours
- ajouter un tag pour se positionner sur la description du motclé dans la langue en cours
- ajouter un tag pour se positionner sur la description du lecteur dans la langue en cours
- ajouter les phrases classiques en footer « tous droits réservés » + « marques déposées »

- ajouter le tri des livres par date de publication ou par titre sur les pages de langues
- s'assurer que les titres, raisons sociales et libellés d'auteurs affichés dans l'API JSON sont conformes (" transformés en \")

* sur le bouton "traduire", ajouter une fenêtre de confirmation, et demander la confirmation de traduction pour les textes déjà remplis (ne pas tout traduire à l'identique plusierus fois)

* ajouter un module de traduction automatique depuis une langue (à priori anglais) sur toutes les données qui n'ont pas d'équivalent dans les autres langues

* bogue : la génération des pages prend plusieurs fois la description / TOC dans certains cas, comme si on avait plusieurs enregistrements qui si on faisait une création à chaque modification de la base de données
