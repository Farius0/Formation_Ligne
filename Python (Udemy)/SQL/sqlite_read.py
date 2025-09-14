# SQLITE : LECTURE DE LA TABLE

import sqlite3  # Importation du module SQLite pour interagir avec une base de données SQLite

# Établissement de la connexion à la base de données existante "music2.db"
connexion = sqlite3.connect("music2.db")

# Création d'un objet curseur pour exécuter des requêtes SQL
curseur = connexion.cursor()

# 🔹 Lecture de la table 'artiste' (différentes variantes possibles, actuellement en commentaire)

# Sélection de toutes les colonnes de la table 'artiste'
# curseur.execute('SELECT * FROM artiste')
# artistes = curseur.fetchall()
# print(artistes)  # Affichage de tous les artistes sous forme de liste de tuples

# Sélection uniquement du nom des artistes
# curseur.execute('SELECT nom FROM artiste')
# artistes = curseur.fetchall()
# for artiste in artistes:
#    print(artiste[0])  # Affichage des noms des artistes

# Parcours direct des résultats d'une requête
# for artiste in curseur.execute('SELECT * FROM artiste'):
#    print(artiste)  # Affichage de chaque ligne de la table artiste

# 🔹 Requête pour récupérer tous les titres des albums de Céline Dion
albums_cd = curseur.execute("""
    SELECT titre 
    FROM album AS a 
    JOIN artiste AS ar 
    ON a.artiste_id = ar.artiste_id 
    WHERE ar.nom = "Céline Dion"
""").fetchall()

# Affichage du résultat sous forme de liste de tuples
print(albums_cd)

# Fermeture de la connexion à la base de données pour libérer les ressources
connexion.close()
