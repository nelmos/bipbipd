
PARAMETRE ADMISSIBLE PAR LA COMMANDE

-rt       (all) => Request-type : active | passive - Defaut : active 
-m        (all) => Mode : standalone | wrapper - Defaut : standalone
-h        (all) => adresse de l'hote distant
-t   	  (all) => timeout - Defaut : 30 secondes
-c     (active) => commande a executer
-a     (active) => arguments de la commande
-serv (passive) => Service � notifier
-host (passive) => Host sur lequel porte la notification
-for  (passive) => Pour quelle type d'objet est la requete : host | service  ==> Utilis� par le deamon pour 
-rc   (passive) => Code de retour
-msg  (passive) => Message 


Logique de la commande

� Cr�ation du hash_config avec les valeurs par defaut : rt, m, t,

� R�cup�ration des informations de fonctionnement :
  -> Regarder dans les arguments passer � la commande et recopier la valeur si existante dans le hash_config["request_type"] 
  -> Regarder dans les arguments passer � la commande et recopier la valeur si existante dans le hash_config["mode"]

  
 � Lancer la v�rification des parametres en fonction du type de requete


 
 � Lancer la cr�ation de la requete en fonction du type de requete
  