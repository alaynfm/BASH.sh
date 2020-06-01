#!/bin/bash

##Instalacion y Mantenimiento de una Aplicacion Web
#Importar funciones de otros ficheros

############################################################
#                 DESINSTALAR Apache                          #
############################################################

function desinstalar()
{

	echo "Cerrando ejecucion de Apache"
	sudo service apache2 stop
	
	#Then uninstall Apache2 and its dependent packages. Use purge option instead of remove with apt-get command. The former option will try to remove dependent packages, as well as any configuration files created by them. In addition, use autoremove option as well, to remove any other dependencies that were installed with Apache2, but are no longer used by any other package.
	echo "Borrando Apache"	
	sudo apt-get purge apache2 apache2-utils apache2-data
	echo "Borrando paquetes Apache"	
	#paquetes sugeridos: apache2-doc apache2-suexec-pristine | apache2-suexec-custom
	sudo apt-get purge php libapache2-mod-php*
	#
	sudo apt-get autoremove
	udo rm -rf /var/www/html/*

	apacheInstall
	echo "Actualizando sistema"
	#sudo apt-get update
	
}

###########################################################
#                  1) INSTALAR APACHE                     #
###########################################################

function apacheInstall()
{
	aux=$(aptitude show apache2 | grep "State: installed")
	aux2=$(aptitude show apache2 | grep "Estado: instalado")
	aux3=$aux$aux2
	if [ -z "$aux3" ]
	then 
 	  echo "Instalando Apache..."
 	  sudo apt-get install apache2
	else
   	  echo "Apache ya estaba instalado"
	  echo ""
	  echo "Desinstalando apache para evitar fallos"
	  desinstalar
    	  echo ""
	fi 
	
}

###########################################################
#                  2) TESTEAR APACHE                      #
###########################################################

function webApacheTest(){

	echo "Reiniciando servicio de Apache"	

	sudo service apache2 restart
	sudo netstat -anp | grep apache
	
	echo "Comprobando que Apache se ha instalado correctamente"	
	firefox http://127.0.0.1
	
}

###########################################################
#                  3) CREAR UN HOST VIRTUAL               #
###########################################################

function createvirtualhost(){


	#Paso 0 : borrar todo lo que tengamos anteriormente de erraztest

	echo "Borrando carpeta erraztest, si esta creada ya"	
	sudo rm -r /var/www/html/erraztest	
	
	echo "Creando el directorio que aloja nuestra web"
	cd /var/www/html

	echo "Creando carpeta erraztest"	
	sudo mkdir erraztest
	
	echo "Creamos el archivo de configuración del nuevo host virtual"
	cd /etc/apache2/sites-available
	sudo cp 000-default.conf erraztest.conf
	sudo sed -i 's/html/html\/erraztest/g' /etc/apache2/sites-available/erraztest.conf
	sudo sed -i "s/<\/VirtualHost>/\<Directory \/var\/www\/html\/erraztest\>\nOptions Indexes FollowSymLinks MultiViews\nAllowOverride All\nOrder allow,deny\nallow from all\n<\/Directory>\n<\/VirtualHost>\n/g" /etc/apache2/sites-available/erraztest.conf
	
	echo "Abrimor el puerto adecuado de apache"
	sudo sed -i 's/Listen 80/Listen 80\nListen 8080/g' /etc/apache2/ports.conf
	
	echo "Habilitamos el nuevo virtualhost"
	sudo a2ensite erraztest.conf
	sudo service apache2 restart
	
	
}

###########################################################
#                4)TEST DEL HOST VIRTUAL                  #
###########################################################

function webVirtualApacheTest(){
	
	#1.	Testear si el servicio apache2 está escuchando por el 
	#puerto 8080 con el comando "sudo netstat -anp | grep apache" .
	
	echo "Testear si el servicio apache esta escuchando por el puerto 8080"
	sudo netstat -anp | grep apache
	
	#2.	Para saber si se visualiza la página por defecto index.html 
	#que esta en la carpeta /var/www/html/erraztest. Abrir el  navegador 
	#con la orden:  firefox http://127.0.0.1:8080
	
	echo "Prueba visualizacion pagina por defecto index.html"	
	firefox http://127.0.0.1:8080
	
}

###########################################################
#                  5) INSTALAR PHP                        #
###########################################################

function phpInstall(){

	echo "Instalando PHP"
	sudo apt install php libapache2-mod-php
	sudo apt install php-cli
	sudo apt install php-cgi
	sudo apt install php-mysql
	sudo apt install php-pgsql
	sudo service apache2 restart
	
}

###########################################################
#                  6) TESTEAR PHP                         #
###########################################################

function phpTest(){

	#1. Crear el fichero “test.php” en /var/www/html/erraztest 
	#con el siguiente código: ( <?php phpinfo(); ?>) para saber si 
	#el módulo de php instalado en apache lo interpreta correctamente.
		
	echo "Creando el fichero test.php en /var/www/html/erraztest"
	cd /var/www/html/
	sudo touch test.php 
	sudo chmod 777 test.php
	sudo echo "<?php phpinfo(); ?>" > test.php	

	#2. Abrir test.php con un navegador web. Asegurate que 
	#pertenece al mismo propietario  y tiene los mismo permisos 
	#que index.html. Visualiza utilizando: firefox http://127.0.0.1:8080/test.php
	
	echo "Testeando que el fichero php esta bien creado"
	firefox http://127.0.0.1:8080/test.php
	
}

###########################################################
#         7) CREAR ENTORNO VIRTUAL DE PHYTON              #
###########################################################

function creandoEntornoVirtualPython3(){

	echo "Creando entorno virtual Python 3"
	cd /var/www/html/erraztest
	sudo apt-get install python-virtualenv virtualenv
	sudo virtualenv python3envmetrix --python=python3
	
}
###########################################################################
#           8) PAQUETES DEL ENTORNO VIRTUAL A LA APLICACION               #
###########################################################################

function instalandoPaquetesEntornoVirtualPythonyAplicacion(){

	#1.	Instala los siguientes paquetes de ubuntu necesarios para la aplicación 
	#como python3-pip y dos2unix
	
	echo "Instalando paquetes necesarios para el correctamiento"
	sudo apt install python3-pip
	sudo apt install dos2unix
	sudo chown 777 /var/www/html/erraztest/python3envmetrix/bin/
	
	#2.	Instala mediante pip3 las librerías de python necesarias para la 
	#aplicación de python como numpy, nltk y  argparse en el entorno virtual  
	#de “python3envmetrix”. Activando el entorno para instalar y una vez instalados 
	#desactiva el entorno virtual
	
	echo "Instalando las librerias necesarias para el correcto funcionamiento"
	cd /var/www/html/erraztest/
sudo su << HERE

	echo -e "instalando software necesario"
	source python3envmetrix/bin/activate
	pip3 install numpy
	pip3 install nltk
	pip3 install argparse
	deactivate
HERE
	
	#3.	Finalmente instala la aplicación “Complejidad Textual” en la carpeta 
	#/var/www/html/erraztest/ . Copia los ficheros “index.php”, “webprocess.sh” 
	#y “complejidadtextual.py” a la carpeta /var/www/html/erraztest. Asigna la 
	#propiedad de todo desde la carpeta /var/www al usuario “www-data” y grupo 
	#“www-data” que es el usuario con que se ejecuta toda aplicación web para 
	#que tenga permisos para crear   ficheros o carpetas en la carpeta  
	#/var/www/html/erraztest (sudo chown -R www-data:www-data /var/www)
	
	#4.	Comprobar que el script “webprocess.sh” funciona correctamente. 
	#Este script es ejecutado por “index.php” pasandole como parámetro 
	#el nombre del fichero que contine el texto de la caja en inglés.  
	#Para comprobar que dicho s”webprocess.sh” funciona ejecutaremos el 
	#siguiente comando “./webprocess.sh english.doc.txt” como usuario www-data. 
	#Acontinuación se indican los pasos necesarios
	
	echo "Empezando instalacion de la aplicacion Complejidad Textual"
	echo ""
	echo -e "1 = English or 0 = Spanish? "
        read idioma
	case $idioma in
                        1) ingles;;
                        0) castellano;;	
			*) ;;


        esac 

}
########################################################
#		En Español			#
#########################################################3
function castellano(){
	echo -e "¿Escribe el nombre de usuario?\n"
        read usuario
 
        if [ -f /home/$usuario/Descargas/AplicacionWeb_ComplejidadTextual.zip ];

        then
	    echo "Instalando la aplicacion en erraztest"
            cd /home/$usuario/Descargas/
            unzip AplicacionWeb_ComplejidadTextual.zip
            sudo cp -r /home/$usuario/Descargas/AplicacionWeb_ComplejidadTextual/fich/index.php /var/www/html/erraztest
            sudo cp -r /home/$usuario/Descargas/AplicacionWeb_ComplejidadTextual/fich/webprocess.sh /var/www/html/erraztest
            sudo cp -r /home/$usuario/Descargas/AplicacionWeb_ComplejidadTextual/fich/complejidadtextual.py /var/www/html/erraztest
            sudo cp -r  /home/$usuario/Descargas/AplicacionWeb_ComplejidadTextual/fich/textos/english.doc.txt /var/www/html/erraztest
            sudo chown -R www-data:www-data /var/www
            echo "Comprobando que todo ha ido correctamente"
	    sudo su <<HERE
                 su - www-data -s /bin/bash
                 cd /var/www/html/erraztest
                 ./webprocess.sh english.doc.txt
HERE


            else
                 echo "No, no existe el archivo AplicacionWeb_ComplejidadTextual.zip dentro de la carpeta 
                  /home/$usuario/Descargas/ descargalo de la pagina o metelo en /home/$usuario/Descargas/ "
            fi


}

########################################################
#		En Ingles			#
#########################################################3
function ingles(){
		
	echo -e "¿Escribe el nombre de usuario?\n"
        read usuario

        if [ -f /home/$usuario/Downloads/AplicacionWeb_ComplejidadTextual.zip ];
        then

            cd /home/$usuario/Downloads/
            unzip AplicacionWeb_ComplejidadTextual.zip
            sudo cp -r /home/$usuario/Downloads/AplicacionWeb_ComplejidadTextual/fich/index.php /var/www/html/erraztest
            sudo cp -r /home/$usuario/Downloads/AplicacionWeb_ComplejidadTextual/fich/webprocess.sh /var/www/html/erraztest
            sudo cp -r /home/$usuario/Downloads/AplicacionWeb_ComplejidadTextual/fich/complejidadtextual.py /var/www/html/erraztest
            sudo cp -r  /home/$usuario/Downloads/AplicacionWeb_ComplejidadTextual/fich/textos/english.doc.txt /var/www/html/erraztest
            sudo chown -R www-data:www-data /var/www	
            echo "Comprobando que todo ha ido correctamente"	
	    sudo su <<HERE
                 su - www-data -s /bin/bash
                 cd /var/www/html/erraztest
                 ./webprocess.sh english.doc.txt
HERE
            else
                  echo "No, no existe el archivo AplicacionWeb_ComplejidadTextual.zip dentro de la carpeta 
                   /home/$usuario/Downloads/ descargalo de la pagina o metelo en /home/$usuario/Downloads/ "
            fi


}
###########################################################
#                     9) VISUALIZAR APLICACION            #
###########################################################

function visualizandoAplicacion(){

	echo "Visualizando aplicacion instalada en el punto 8"
	firefox http://127.0.0.1:8080/erraztest

}

###########################################################
#                     10) VER LOG DE ERRORES              #
###########################################################

function erroresApache(){
	
	echo "Viendo errores apache"
	cat /var/log/apache2/error.log
	sleep 2
	
	

}

###########################################################
#                     11) GESTIONAR LOGS                  #
###########################################################

function gestionarLogs(){


	aux=$(aptitude show ssh | grep "State: installed")
	aux2=$(aptitude show ssh | grep "Estado: instalado")
	aux3=$aux$aux2
	if [ -z "$aux3" ]
	then 
 	  echo "Instalando ssh..."
 	  sudo apt install ssh
	else
   	  echo "ssh ya estaba instalado"
	  echo "Obteniendo quien ha intentado conectarse"
	  cd /var/log/
	  archivoscomprimidos="/tmp/aux.txt"
	  archivos="/tmp/aux2.txt"
	  #sudo zcat auth.log*.gz > aux.txt
	  cat /var/log/auth.log /var/log/auth.log.1 > /tmp/aux2.txt
	  echo -e "Los ficheros tratados son: $archivos $archivoscomprimidos\n"
	  cat $archivos $archivoscomprimidos | grep sshd| grep "Failed password" |tr -s " "|tr  " " "@" > /tmp/logfailtratados.txt
	  echo -e "Los intentos de conexion por ssh, hoy, esta semana y este mes han sido:\n"
	  for linea in $(cat /tmp/logfailtratados.txt)
	  do
		usuario=$(echo $linea | cut -f9 -d "@")
		mes=$( echo $linea | cut -f1 -d "@")
		dia=$(echo $linea | cut -f2 -d "@")
		hora=$(echo $linea | cut -f3 -d "@")
		echo -e "Status: [fail] Account name: $usuario Date: $mes - $dia - $hora"
	  done
	fi 
	sleep 2

}

###########################################################
#                     12) SALIR                           #
###########################################################

function fin()
{
	echo -e "¿Quieres salir del programa?(S/N)\n"
        read respuesta
	if [ $respuesta == "S" ] 
	then
		echo -e "Nos despedimos Alain, Aitor y Nicolas"
	else
		opcionmenuppal=0
	fi	
}

### Main ###
opcionmenuppal=0
	sudo echo -e "Bienvenido"
	sleep 2
	while test $opcionmenuppal -ne 12
	do
	#Muestra el menu
	 echo -e "1 Instala Apache \n"
	 echo -e "2 Testea el servicio Web Apache \n"
         echo -e "3 Crear Virtual Host \n" 
         echo -e "4 Testea el virtual host \n" 
	 echo -e "5 Instala el modulo php \n"
	 echo -e "6 Testea PHP\n"
         echo -e "7 Creando un entorno virtual para Python3 \n"
	 echo -e "8 Instala los paquetes necesarios, para la aplicación en el entorno virtual de python \n"
	 echo -e "9 Instala la aplicacion \n"
         echo -e "10 Viendo errores apache \n"
         echo -e "11 Controla los intentos de conexión de ssh \n"
	 echo -e "12 Exit \n"
	 read -p "Elige una opcion:" opcionmenuppal
	 case $opcionmenuppal in
			1) apacheInstall;;
			2) webApacheTest;;
                        3) createvirtualhost;;
                        4) webVirtualApacheTest;;
			5) phpInstall;;
			6) phpTest;;
			7) creandoEntornoVirtualPython3;;
			8) instalandoPaquetesEntornoVirtualPythonyAplicacion;;
                      	9) visualizandoAplicacion;;
			10) erroresApache;;
			11) gestionarLogs;;
			12) fin;;
			
			*) ;;

	esac 
done 

echo "Fin del Programa" 
exit 0 
