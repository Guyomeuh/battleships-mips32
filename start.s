# ===== Section donnees =====
.data 
    grille:     .space 100 #Grille de char de 10x10 soit 100 octet
    nb_tir:	.word 0	#Nombre de tir
    nb_tirBut:	.word 0	#Nombre de tir touché
# ===== Section code =====  
.text
# ----- Main ----- 
main:
    jal initPartie
    jal displayGrille
    jal simulationJeu
    j   exit 

# ----- Fonctions -----

# ----- Fonction initPartie -----
# Objectif : Génère une nouvelle partie à chaque appel
# Registres utilises : $a0, $a1

initPartie:
    addi    $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)

    jal initGrille
    li  $a0, 5
    li  $a1, 65 # 'A' pour Aircraft Carrier (Porte-Avion)
    jal setShip
    li  $a0, 4  
    li  $a1, 66 # 'B' pour Battleship (Cuirassé)
    jal setShip
    li  $a0, 3
    li  $a1, 67 # 'C' pour Cruiser (Croiseur)
    jal setShip
    li  $a0, 3
    li  $a1, 83 # 'S' pour Submarine (Sous-marin)
    jal setShip
    li  $a0, 2
    li  $a1, 68 # 'D' pour Destroyer (Torpilleur)
    jal setShip

    lw      $ra, 0($sp)                 # On recharge la reference 
    addi    $sp, $sp, 4                 # du dernier jump
    jr $ra

# ----- Fonction initGrille -----
# Objectif : Charge la grille avec '.' (Case vide)
# Registres utilises : $t[0-3]

initGrille:
    la      $t0, grille     # Chargement de l'adresse de la grille
    li      $t1, 0          # Initialisation du compteur de boucle dans $t1
    li      $t3, 46         # Charge la valeur ASCII de '.'
    boucle_initGrille:
        bge     $t1, 100, end_initGrille # Si $t1 est plus grand ou egal a 100 alors branchement a end_boucle_initGrille
            add     $t2, $t0, $t1   # $t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
            sb		$t3, 0($t2)		# On place la valeur de $t3 à l'adresse contenue dans $t2
            addi    $t1, $t1, 1     # $t1 += 1 (On augmente le compteur)
        j boucle_initGrille
    end_initGrille:
        jr $ra

# ----- Fonction displayGrille -----
# Objectif : Affiche la grille avec les indicateur de coordonnées
# Registres utilises : $t[0-3], $v0, $a[0-1]

displayGrille:
    addi    $sp, $sp, -4        # Sauvegarde de la reference du dernier jump
    sw      $ra, 0($sp)
    
    la      $t0, grille     #Charge l'adresse de la grille dans $t0
    li      $t1, 0          #Initialisation du compteur de boucle dans $t1
    li $s5 1
    
    li $a0 32
    li $v0 11
    syscall

    jal displayLettres
    jal addNewLine
    
    boucle_displayGrille:
	bge     $t1, 100, end_displayGrille     #Si $t1 est plus grand ou egal a 100 alors branchement a end_displayGrille
	
	move $a0, $t1
	li $a1 10
	jal getModulo
	beq $v0 0 addLineCount	#Quand on change de ligne on affiche le numero de ligne
          add     $t2, $t0, $t1         #$t0 + $t1 -> $t2 ($t0 l'adresse du tableau et $t1 la position dans le tableau)
          lb      $a0, ($t2)            #load byte at $t2(adress) in $a0
          li      $v0, 11               #code pour l'affichage d'un caractère (char)
          syscall
          li $a0 32
          syscall
          addi    $t1, $t1, 1           #$t1 += 1;
          move $a0, $t1
          li $a1, 10
          jal getModulo       
          beq $v0, 0, addNewLine	#Après avoir afficher la ligne, on met un '\n' pour passer à la prochaine ligne
        	j boucle_displayGrille
        	
    end_displayGrille:
	jal addNewLine		#Sert juste à pas coller tout les tableaux lors de l'affichage
	lw      $ra, 0($sp)           #On recharge la reference 
	addi     $sp, $sp, 4          #du dernier jump
	jr $ra

# ----- Fonction displayLettres -----
# Objectif : afficher les lettres de A à J
# Regitres utilises : $t4, $t5, $v0, $a0
# $t4 : Compteur de boucle
# $t5 : Compteur ASCII
# $a0, $v0 : Pour le syscall affichage de caractère

displayLettres:
li $a0 32
li $v0 11
syscall	#On crée un espace pour que les lettres soient allignés avec les colonnes
li $t4 0	#Debut du compteur de boucle
li $t5 65	#Code ASCII de 'A'
	boucle_Lettres:
	beq $t4 10 end_Lettres	#Quand 10 lettres sont affichées on sort de la boucle
	move $a0 $t5		#On charge la valeur de $t5 (Lettre en cours) pour l'afficher
	li $v0 11
	syscall			#Affiche la lettre en cours
	li $a0 32
	syscall			#Un espace pour que la prochaine lettre soit alligné
	
	addi $t4 $t4 1		#On incrémente la boucle
	addi $t5 $t5 1		#On incrémente la lettre en cours
	
	j boucle_Lettres
	end_Lettres:
	jr $ra


# ----- Fonction addNewLine -----  
# Objectif : fait un retour a la ligne a l'ecran
# Registres utilises : $v0, $a0

addNewLine:
    li      $v0, 11         # Chargement appel systeme 11 (Affichage d'un char)
    li      $a0, 10         # Chargement chaine à afficher -> '\n'
    syscall
    jr      $ra             # Retour à la fonction précendente

# ----- Fonction addLineCount -----
# Objectif : affiche le numéro de la ligne
# Registres utilises : $v0, $a0, $a1
# Paramètre : $a1 (Ligne en cours : res du modulo + 1)

addLineCount:
move $a0 $s5	#On copie la ligne en cours pour l'afficher
li $v0 1
syscall		#On affiche la ligne en cours
beq $s5 10 end_AddCount	#Si la ligne affiché < 10 on continue en ajoutant un espace avant les points du tableau
li $a0 32
li $v0 11
syscall
addi $s5 $s5 1		#Incremente le compteur de ligne

end_AddCount:
jr $ra

# ----- Fonction getModulo ----- 
# Objectif : Fait le modulo (a mod b)
#   $a0 represente le nombre a (doit etre positif)
#   $a1 represente le nombre b (doit etre positif)
# Resultat (reste) dans : $v0
# Resultat (quotient) dans : $v1
# Registres utilises : $a0 et $a1

getModulo: 
    li $v1, 0
    sub     $sp, $sp, 4
    sw      $ra, 0($sp)
    boucle_getModulo:
        blt $a0, $a1, end_getModulo
        addi $v1, $v1, 1
        sub $a0, $a0, $a1
        j boucle_getModulo
    end_getModulo:
    move    $v0, $a0
    lw      $ra, 0($sp)
    addi    $sp, $sp, 4
    jr $ra

# ----- Fonction getAleatoire ----- 
# Objectif : Génère un nombre aléatoire de 0 à n-1
#   $a1 represente la valeur max-1
# Resultat dans : $a0
# Registres utilises : $a0, $a1, $v0

getAleatoire:
    li $v0, 42
    syscall
    jr $ra

# ----- Fontion setShip -----
# Objectif : place un bateau de taille donné.
#   $a0 represente la taille en nombre de case du bateau à placer
#   $a1 represente le caraètre pour représenter le bateau
# Registres utilises : $a0, $a1, $s[0-4], $t[0-4]

setShip:
    sub     $sp, $sp, 4
    sw      $ra, 0($sp)     #On sauvegarde l'adresse de retour

    move 	$s0, $a0		# On recopie la taille dans $s0
    move    $s4, $a1        # On recopie le caractère du bateau
    try_setShip:
        #Choix de l'axe (horizontale ou verticale)
        li      $a1, 2          # Définition de la borne surpérieur (Resultat possbile : 0 ou 1)
        jal getAleatoire        # Saut pour obtenir une valeur aléatoire
        move 	$s1, $a0		# On copie le résultat dans $s1
        # Placement en fonction de l'axe
        beq     $s1, 1, placeVerticale  # Si la valuer est 1 alors le bateau sera placer verticalement
        j       placeHorizontale        # Si la valuer est 0 alors le bateau sera placer horizontalement
        

    end_setShip:
        lw      $ra, 0($sp)
        addi    $sp, $sp, 4     # On rétablie l'adresse de retour
    jr $ra
        
# ----- Fontion placeHorizontale -----
# Objectif : place aléatoirement un bateau de manière horizontale.
#   Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]

placeHorizontale:
li $a1 10		#On va générer un nombre entre 0 et 9
jal getAleatoire
move $s2 $a0
li $a1 10
jal getAleatoire
move $s3 $a0
jal verifPlaceHorizontale 	#On va vérifier le placement horizontale ($2 ligne $s3 colonne $s0 taille)
beq $v0 1 placeHorizontale

li $t1 0			#Init compteur
la $t0 grille		#adresse de T[0]
add $t2 $t0 $s2		#adresse de T[bato]
	placerBato:
	beq $t1 $s0 finBato
	sb $s4 0($t2)		
	add $t2 $t2 1
	addi $t1 $t1 1
	j placerBato
	
finBato:
j end_setShip
	
# ----- Fontion verifPlaceHorizontale -----
# Objectif : verifie si le placement (horizontale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3

verifPlaceHorizontale:
subi $sp $sp 4
sw $ra 0($sp)
li $s1 10
mult $s2 $s1
mflo $s2
add $s2 $s2 $s3		#Calcul de la case exacte dans le tableau

move $a0 $s2		#On copie le numero de la case pour en récupérer le mod 10 et savoir si on a changé de ligne ou pas en y ajoutant le bato
li $a1 10
jal getModulo
add $s1 $v0 $s0

bge $s1 10 pasPossible_Horizon	#Si le numero de la case mod 10 + la taille du bato > 10 on change de ligne alors impossible aussi

li $t1 0			#Init compteur
la $t0 grille		#adresse de T[0]
add $t2 $t0 $s2		#adresse de T[bato]

	verif_autreBato:
	lb $t7 0($t2)	#On utilise lb parce que lw c'est par 4 et pas par 1
	bne $t7 46 pasPossible_Horizon
	beq $t1 $s0 possible_Horizon
	add $t2 $t2 1
	addi $t1 $t1 1
	j verif_autreBato
	
pasPossible_Horizon:
li $v0 1
lw $ra 0($sp)
addi $sp $sp 4
jr $ra
possible_Horizon:
li $v0 0
lw $ra 0($sp)
addi $sp $sp 4
jr $ra

# ----- Fontion placeVerticale -----
# Objectif : place aléatoirement un bateau de manière verticale.
#   Prends les paramètres de setShip
# Registres utilises : $v0, $a0, $a1, $s[0-4], $t[0-4]

placeVerticale:
li $a1 10		#On va générer un nombre entre 0 et 9
jal getAleatoire
move $s2 $a0

li $a1 10
sub $a1 $a1 $s0 		#Un autre nombre entre 0 et 9
jal getAleatoire
move $s3 $a0

jal verifPlaceVerticale 	#On va vérifier le placement horizontale ($2 ligne $s3 colonne $s0 taille)
beq $v0 1 placeVerticale

li $t1 0			#Init compteur
la $t0 grille		#adresse de T[0]
add $t2 $t0 $s2		#adresse de T[bato]
	placerBatoVert:
	beq $t1 $s0 finBatoVert
	sb $s4 0($t2)
	add $t2 $t2 10
	addi $t1 $t1 1
	j placerBatoVert
	
finBatoVert:
j end_setShip

# ----- Fontion verifPlaceVerticale -----
# Objectif : verifie si le placement (verticale) est possible.
#   $s0 contient la taille du navire
#   $s2 contient la ligne 
#   $s3 contient la colonne
# Retourne 0 si placement ok, 1 sinon
# Registres utilises : $v0, $t[0-4], $s0, $s2, $s3

verifPlaceVerticale:
subi $sp $sp 4		#Calcul de la coordonnée
sw $ra 0($sp)
li $s1 10
mult $s2 $s1
mflo $s2
add $s2 $s2 $s3	

bge $s2 100 pasPossible_Vertical	#Si le numero de la case + la taille du bato * 10 > 100 on sort du tableau alors impossible aussi

li $t1 0			#Init compteur
la $t0 grille		#adresse de T[0]
add $t2 $t0 $s2		#adresse de T[bato]

	verif_autreBatoVert:
	lb $t7 0($t2)	#On utilise lb parce que lw c'est par 4 et pas par 1
	bne $t7 46 pasPossible_Vertical
	beq $t1 $s0 possible_Vertical
	beq $t2 100 pasPossible_Vertical
	add $t2 $t2 10
	addi $t1 $t1 1
	j verif_autreBatoVert
	
pasPossible_Vertical:
li $v0 1
lw $ra 0($sp)
addi $sp $sp 4
jr $ra
possible_Vertical:
li $v0 0
lw $ra 0($sp)
addi $sp $sp 4
jr $ra

# ----- Fonction simulationJeu -----
# Objectif : Simule une partie avec une grille déjà généré.
# Registres utilises : $s[0-3], $a1

simulationJeu:
add $sp $sp -16       #Allocation de memoire, 16 octets
sw $ra 0($sp)         #Sauvegarde de l'adresse de retour
sw $s0 4($sp)         #Sauvegarde de $s0 $s1 et $s2
sw $s1 8($sp)         
sw $s2 12($sp)        

boucle_simulation:
#Verification de nb_coup_but < 17
lw $t0 nb_tirBut    
bge $t0 17 end_simulation #Si nb_coup_but >= 17 la partie est finie
lw $s0 nb_tir        #$s0 = nb_coup actuel

#Generation de la ligne 
li $a1 10             
jal getAleatoire        
move $s1 $a0            #Stocke dans $s1

#Generation de la colonne 
li $a1 10             
jal getAleatoire        
move $s2 $a0            #Stocke dans $s2

#Appel de la fonction traque(ligne, colonne)
move $a0 $s1            #Argument $a0 : ligne
move $a1 $s2            #Argument $a1 : colonne
jal traque              
j boucle_simulation   #Debut de la boucle

end_simulation:
lw $ra 0($sp)         #Restauration adresse retour
lw $s0 4($sp)         #Restauration $s0
lw $s1 8($sp)         #Restauration $s1
lw $s2 12($sp)        #Restauration $s2
add $sp $sp 16        #libere la pile
jr $ra                




# ----- Fontion traque -----     
# Objectif : Vérifie la présence d'un navire et le traque de manière récursive
# Registres utilises : $t[8-9], $s[0-3]

traque:
add $sp $sp -12       #Allocation memoire
sw $ra 0($sp)         #Sauvegarde adresse retour
sw $a0 4($sp)         #Sauvegarde argument ligne 
sw $a1 8($sp)         #Sauvegarde argument colonne 

#0 <= ligne < 10 & 0 <= col < 10
blt $a0 0, fin_traque  #ligne < 0 : fin traque
bge $a0 10, fin_traque #ligne >= 10 : fin trque
blt $a1 0, fin_traque  #col < 0 : fin traque
bge $a1 10, fin_traque #col >= 10 : fin traque

#Calcul de l'adresse de la case 
la $t0 grille         #$t0 = adresse de base de la grille
li $t1 10             #$t1 = 10
mult $a0 $t1            #ligne * 10
mflo $t1                 #$t1 = r�sultat mult
add $t1 $t1 $a1       
add $t0 $t0 $t1       #$t0 = adresse effective de la case

#Recuperation du contenu de la case
lb $t2 0($t0)         #$t2 est egal au caractere de la case

#Verif si un tir a deja eu lieu
li $t3 126		#charge '~'
beq $t2 $t3 fin_traque	#S'il y a deja '~' on sort
li $t3 88		#charge 'X'
beq $t2 $t3 fin_traque	#S'il y a un 'X' on sort

#si le coup est possible : incremente nb_tir
lw $t3 nb_tir        #charge compteur tir
addi $t3 $t3, 1         #incremente
sw $t3 nb_tir       #sauvegarde compteur

#si case vide 
li $t3 46             # '.'
bne $t2 $t3 touche #Si ce n'est pas '.', on touche

#tir manque
li $t3 126            #Charge '~' (126)
sb $t3 0($t0)         #Met '~' dans la grille
    
jal displayGrille       #MAJ Affichage Grille 
    
j fin_traque          

#Navire deja touche
touche:
lw $t3 nb_tirBut
addi $t3 $t3 1
sw $t3 nb_tirBut

#navire touche 'X'
li $t3 88         #Charge 'X'
sb $t3 0($t0)     #Ecrit 'X' dans la grille

jal displayGrille  

#Appels recursifs 
        
#Nord
lw $a0 4($sp)     #Restaure ligne original
lw $a1 8($sp)     #Restaure col original
sub $a0 $a0 1     #Ligne - 1
jal traque          #Appel recursif

#Est
lw $a0 4($sp)     #Restaure ligne original
lw $a1 8($sp)     #Restaure col original
addi $a1 $a1 1     #Col + 1
jal traque          #Appel recursif

#Sud
lw $a0 4($sp)     
lw $a1 8($sp)     
addi $a0 $a0 1     
jal traque          

#Ouest
lw $a0 4($sp)     
lw $a1 8($sp)     
sub $a1 $a1 1     
jal traque          

fin_traque:
lw $ra 0($sp)     #Restaure adresse retour
add $sp $sp 12    
jr $ra
    
#---------------------------------------------------

exit: 
    li $v0, 10  #Chargement appel systeme 10 (Sortie)
    syscall
