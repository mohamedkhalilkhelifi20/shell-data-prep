#!/bin/bash

# Variable globale
current_file=""

#Charger un dataset
charger_dataset(){
	echo -n "Entrez le chemin du fichier CSV : "
	read -r chemin
	
	# Vérifie que l'utilisateur n'a pas appuyé Entrée sans rien écrire
	if [ -z "$chemin" ]; then
		echo "Erreur : Vous n'avez pas entré de chemin."
		return
	fi
	
	# Vérifie que le fichier existe sur le disque
	if [ ! -f "$chemin" ]; then
		echo "ERREUR : Le fichier '$chemin' n'existe pas."
		return
    	fi
    	
    	# Vérifie que c'est bien un fichier CSV
	case "$chemin" in
	    *.csv)
		;;  # OK, c'est un CSV
	    *)
		echo "ERREUR : Le fichier n'est pas un CSV."
		return
		;;
	esac
    	
    	#on sauvegarde dans la variable globale
	current_file="$chemin"
	echo "Fichier '$current_file' chargé avec succès."
}


#Afficher statistiques du dataset
afficher_statistique(){

	# Vérifie qu'un fichier est bien chargé avant de continuer
	if [ -z "$current_file" ]; then
		echo "ERREUR : Aucun fichier chargé. Faites d'abord l'option 1."
        	return
        fi
        
        # Nombre total de lignes
        total_lignes=$(wc -l < "$current_file")
        
        # Nombre de lignes non vides
        lignes_non_vides=$(grep -c "." "$current_file")
        
        # Nombre de lignes contenant "NULL"
        lignes_null=$(grep -c "NULL" "$current_file")
        
        # Affichage des résultats
        echo "=== Statistiques du fichier : $current_file ===="
        echo "Nombre total de lignes       : $total_lignes"
        echo "Nombre de lignes non vides   : $lignes_non_vides"
        echo "Nombre de lignes avec NULL   : $lignes_null"
}

# Supprimer lignes vides
supprimer_lignes_vides(){

	# Vérifie qu'un fichier est bien chargé
	if [ -z "$current_file" ]; then
		echo "ERREUR : Aucun fichier chargé. Faites d'abord l'option 1."
		return
	fi
	
	# Fichier temporaire pour stocker le résultat
	fichier_temp="clean_data.csv"
	
	# Compteur de lignes supprimées
	compteur=0
	
	# Lecture ligne par ligne
	while IFS= read -r line
	do
		# Si la ligne n'est PAS vide, on la garde
		if [ -n "$line" ]; then
			echo "$line" >> "$fichier_temp"
		else 
			compteur=$((compteur + 1))
		fi
	done < "$current_file"
	# Remplacer le fichier original par le fichier nettoyé
	mv "$fichier_temp" "$current_file"
	
	echo "$compteur ligne(s) vide(s) supprimée(s)."

}

# Supprimer lignes non annotées
supprimer_lignes_non_annotees(){

	# Vérifie qu'un fichier est bien chargé
	if [ -z "$current_file" ]; then
		echo "ERREUR : Aucun fichier chargé. Faites d'abord l'option 1."
		return
	fi
	
	# Compter les lignes avec NULL avant suppression
	nb_null=$(grep -c "NULL" "$current_file")
	
	# grep -v garde toutes les lignes qui ne contiennent pas NULL
	grep -v "NULL" "$current_file" > annotated.csv
	
	# Remplacer le fichier original
	mv annotated.csv "$current_file"

	echo "$nb_null ligne(s) non annotée(s) supprimée(s)."
}

# Supprimer doublons simples
supprimer_doublons(){

	if [ -z "$current_file" ]; then
		echo "ERREUR : Aucun fichier chargé. Faites d'abord l'option 1."
		return
	fi

	# Compter les lignes avant
	avant=$(wc -l < "$current_file")

	# Sauvegarder l'en-tête (première ligne)
	head -n 1 "$current_file" > sans_doublons.csv

	# Trier et supprimer doublons sur les données (sans l'en-tête)
	tail -n +2 "$current_file" | sort | uniq >> sans_doublons.csv

	# Remplacer le fichier original
	mv sans_doublons.csv "$current_file"

	# Compter les lignes après
	apres=$(wc -l < "$current_file")

	# Calculer le nombre de doublons supprimés
	doublons=$((avant - apres))

	echo "$doublons doublon(s) supprimé(s)."
}

# Diviser en Train/Test
diviser_train_test(){

	# Vérifie qu'un fichier est bien chargé
	if [ -z "$current_file" ]; then
		echo "ERREUR : Aucun fichier chargé. Faites d'abord l'option 1."
		return
	fi

	# Demander le pourcentage train
	echo -n "Entrez le pourcentage pour Train (ex: 80) : "
	read -r pourcentage
	
	# Vérifier que c'est un nombre entre 1 et 99
	if [ -z "$pourcentage" ]; then
		echo "ERREUR : Vous n'avez pas entré de valeur."
		return
	fi
	
	if [ "$pourcentage" -lt 1 ] || [ "$pourcentage" -gt 99 ]; then
		echo "ERREUR : Le pourcentage doit être entre 1 et 99."
		return
	fi
	
	# Nombre total de lignes
	total=$(wc -l < "$current_file")
	
	# Calculer le nombre de lignes pour train
	nb_train=$((total * pourcentage / 100))
	
	# Le reste va dans test
	nb_test=$((total - nb_train))
	
	# head prend les premières lignes pour train
	head -n "$nb_train" "$current_file" > train.csv
	
	# tail prend les dernières lignes pour test
	tail -n "$nb_test" "$current_file" > test.csv

	echo "Division effectuée :"
	echo "  Train : $nb_train lignes ($pourcentage%) de train.csv"
	echo "  Test  : $nb_test lignes ($((100 - pourcentage))%) de test.csv"
}

# Organiser dossiers train/test
organiser_dossiers(){

	# Vérifie que les fichiers train.csv et test.csv existent
	if [ ! -f "train.csv" ] || [ ! -f "test.csv" ]; then
		echo "ERREUR : Faites d'abord la division Train/Test (option 6 )."
		return
	fi

	# Créer les dossiers train et test
	mkdir -p train test
	
	# Déplacer les fichiers dans les dossiers
	mv train.csv train/
	mv test.csv test/

	echo "Dossiers organisés avec succès :"
	echo "  train/ contient train.csv"
	echo "  test/ contient test.csv"
}

#  Générer le rapport
generer_rapport(){

	# Vérifie que les dossiers train et test existent
	if [ ! -f "train/train.csv" ] || [ ! -f "test/test.csv" ]; then
		echo "ERREUR : Faites d'abord les options 6 et 7."
		return
	fi
	
	# Compter les lignes de chaque fichier
	nb_train=$(wc -l < "train/train.csv")
	nb_test=$(wc -l < "test/test.csv")
	total=$((nb_train + nb_test))

	# Calculer les pourcentages
	pct_train=$((nb_train * 100 / total))
	pct_test=$((100 - pct_train))
	
	# Créer le rapport avec la date
	echo "=== RAPPORT DU DATASET ===" > dataset_report.txt
	echo "Date : $(date)" >> dataset_report.txt
	echo "Nombre total de données : $total" >> dataset_report.txt
	echo "Train : $nb_train lignes ($pct_train%)" >> dataset_report.txt
	echo "Test  : $nb_test lignes ($pct_test%)" >> dataset_report.txt
	echo "==========================" >> dataset_report.txt

	echo "Rapport généré avec succès"
}

# Menu principal
while true
do
	echo ""
	echo "======== MENU PRINCIPAL ========"
	echo "1. Charger un dataset"
	echo "2. Afficher statistiques du dataset"
	echo "3. Supprimer lignes vides"
	echo "4. Supprimer lignes non annotées"
	echo "5. Supprimer doublons simples"
	echo "6. Diviser en Train/Test"
	echo "7. Organiser dossiers train/test"
	echo "8. Générer un rapport statistique"
	echo "9. Quitter"
	echo "================================"
	echo -n "Votre choix : "
	read -r choix
 
	# case appelle la bonne fonction selon le choix de l'utilisateur
	case $choix in
		1) charger_dataset ;;          
		2) afficher_statistique ;;    
		3) supprimer_lignes_vides ;;
		4) supprimer_lignes_non_annotees ;;
		5) supprimer_doublons ;;
		6) diviser_train_test ;;
		7) organiser_dossiers ;;
		8) generer_rapport ;;
		9) echo "Au revoir !" ; exit 0 ;;
		*) echo "ERREUR : Choix invalide, tapez un nombre entre 1 et 9." ;;
	esac
done
