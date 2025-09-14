# 📄 ANALYSE D'UN FICHIER HTML AVEC BEAUTIFULSOUP

from bs4 import BeautifulSoup  # Importation du module pour le parsing HTML

# 📌 Lecture des données HTML depuis le fichier local
with open("recette.html", "r", encoding="utf-8") as f:
    html_content = f.read()  # Lecture complète du fichier HTML

# 📌 Création d'un objet BeautifulSoup pour analyser le HTML
soup = BeautifulSoup(html_content, "html.parser")

# 🔹 Recherche de la première balise <h1> dans le document HTML
titre_h1 = soup.find("h1")

# 🔹 Recherche de la première balise <p> ayant la classe "description"
paragraphe_description = soup.find("p", class_="description")

# 🔹 Affichage des résultats avec une gestion des cas où les balises sont absentes
if titre_h1:
    print("Titre de la page HTML:", titre_h1.text.strip())  # Suppression des espaces inutiles
else:
    print("❌ Aucun titre <h1> trouvé dans le document HTML.")

if paragraphe_description:
    print("Paragraphe de description:", paragraphe_description.text.strip())  # Suppression des espaces inutiles
else:
    print("❌ Aucun paragraphe avec la classe 'description' trouvé dans le document HTML.")

print()  # Ajout d'une ligne vide pour la lisibilité de l'affichage

# 🔹 Recherche de la balise <div> ayant la classe "info"
div_info = soup.find("div", class_="info")

# Vérification que la <div> avec la classe "info" existe avant de chercher une image à l'intérieur
if div_info:
    # 🔹 Recherche de la première balise <img> à l'intérieur de cette div
    img_info = div_info.find("img")

    # Vérification que l'image a bien été trouvée avant d'accéder à l'attribut "src"
    if img_info and "src" in img_info.attrs:
        print("✅ Le src de l'image est :", img_info["src"])  # Affichage du lien de l'image
    else:
        print("❌ Aucune image trouvée dans la div 'info'.")

else:
    print("❌ La div avec la classe 'info' est introuvable dans le document HTML.")
