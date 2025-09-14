# SQLITE : CRÉATION DE LA BASE DE DONNÉES ET INSERTION DE DONNÉES

import sqlite3  # Importation du module SQLite pour interagir avec une base de données SQLite

# Établissement de la connexion à la base de données SQLite (création du fichier "music2.db" s'il n'existe pas)
connexion = sqlite3.connect("music2.db")

# Création d'un objet curseur permettant d'exécuter des requêtes SQL
curseur = connexion.cursor()

# Création de la table 'artiste' qui stocke les artistes de musique
curseur.execute("""
    CREATE TABLE artiste (
        artiste_id INTEGER NOT NULL PRIMARY KEY,  -- Clé primaire unique pour identifier chaque artiste
        nom VARCHAR  -- Nom de l'artiste (stocké comme TEXT en SQLite, VARCHAR est accepté mais sans limite de taille)
    );
""")

# Création de la table 'album' qui stocke les albums de musique
curseur.execute("""
    CREATE TABLE album (
        album_id INTEGER NOT NULL PRIMARY KEY,  -- Clé primaire unique pour chaque album
        artiste_id INTEGER REFERENCES artiste,  -- Clé étrangère faisant référence à l'artiste associé
        titre VARCHAR,  -- Titre de l'album
        annee_sortie INTEGER  -- Année de sortie de l'album
    );
""")

# Insertion de données dans la table 'artiste'
curseur.execute("""INSERT INTO artiste (nom) VALUES ('Michael Jackson');""")
mj_id = curseur.lastrowid  # Récupération de l'ID de Michael Jackson après insertion

curseur.execute("""INSERT INTO artiste (nom) VALUES ('Céline Dion');""")
cd_id = curseur.lastrowid  # Récupération de l'ID de Céline Dion après insertion

# Insertion des albums en utilisant les ID des artistes récupérés précédemment
curseur.execute("""INSERT INTO album (artiste_id, titre, annee_sortie) VALUES (?, 'Thriller', 1982);""", (mj_id,))
curseur.execute("""INSERT INTO album (artiste_id, titre, annee_sortie) VALUES (?, "Falling into You", 1996);""", (cd_id,))
curseur.execute("""INSERT INTO album (artiste_id, titre, annee_sortie) VALUES (?, "Let's Talk About Love", 1997);""", (cd_id,))

# Validation des modifications dans la base de données
connexion.commit()

# Fermeture de la connexion à la base de données pour libérer les ressources
connexion.close()
