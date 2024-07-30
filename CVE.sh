#!/bin/bash

# Nom du fichier de sortie
OUTPUT_FILE="cve_report.html"

# Fonction pour ajouter une ligne au rapport HTML
add_line() {
    echo "$1" >> "$OUTPUT_FILE"
}

# Début du rapport HTML
add_line "<html>"
add_line "<head><title>Rapport de CVE pour les Paquets Linux</title></head>"
add_line "<body>"
add_line "<h1>Rapport de CVE pour les Paquets Linux</h1>"
add_line "<table border='1'>"
add_line "<tr><th>Paquet</th><th>Version</th><th>CVE</th><th>Description</th></tr>"

# Récupérer la liste des paquets installés
echo "Récupération des paquets installés..."
PACKAGES=$(dnf list installed | awk 'NR>2 {print $1}')

# Fonction pour vérifier les CVE pour un paquet
check_cve() {
    local package_name="$1"
    local package_version="$2"

    echo "Vérification des CVE pour $package_name $package_version..."
    
    # Rechercher les informations de sécurité pour le paquet
    security_info=$(dnf updateinfo list available --security | grep "$package_name" || echo "Pas d'informations de sécurité trouvées")

    if [[ "$security_info" == "Pas d'informations de sécurité trouvées" ]]; then
        echo "Aucun CVE trouvé pour $package_name $package_version."
    else
        echo "$security_info"
        
        # Extraire les CVE et descriptions
        while read -r line; do
            # Supposer que la sortie contient le CVE et la description
            # Vous devrez peut-être ajuster en fonction du format exact
            cve_id=$(echo "$line" | awk '{print $2}')
            cve_desc=$(echo "$line" | cut -d' ' -f3-)
            
            # Ajouter les résultats au rapport HTML
            add_line "<tr><td>$package_name</td><td>$package_version</td><td>$cve_id</td><td>$cve_desc</td></tr>"
        done <<< "$security_info"
    fi
}

# Vérifier les CVE pour chaque paquet
while read -r pkg; do
    pkg_name=$(echo "$pkg" | awk -F'.' '{print $1}')
    pkg_version=$(echo "$pkg" | awk -F'.' '{print $2}')
    
    check_cve "$pkg_name" "$pkg_version"
done <<< "$PACKAGES"

# Fin du rapport HTML
add_line "</table>"
add_line "</body>"
add_line "</html>"

echo "Le rapport de CVE a été généré dans $OUTPUT_FILE"
