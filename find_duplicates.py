import os
import hashlib
import sys
import json
import argparse

#
# Función para obtener el hash de un fichero
# La he cogido de Internet ... 
#
def hashfile(path, blocksize = 65536):
    afile = open(path, 'rb')
    hasher = hashlib.md5()
    buf = afile.read(blocksize)
    while len(buf) > 0:
        hasher.update(buf)
        buf = afile.read(blocksize)
    afile.close()
    return hasher.hexdigest()

#
# Función para inicializar un diccionario con todos los hashes - filenames de un 
# directorio y todos los directorios que haya debajo.
#
def init_FotoDepot(depot,folder):
	for dirName, subdirs, fileList in os.walk(folder):
		print ('Escaneando %s ... %d ficheros ... ' % (dirName,len(fileList)))
		for num, file in enumerate(fileList):
			filepath=os.path.join(dirName,file)
			porcentaje = ((num + 1) / len(fileList)) * 100
			if (round(porcentaje,1) % 10) == 0:
				print ('%d%%' % (round(porcentaje,1)))
			filehash=hashfile(filepath)
			if filehash in depot:
				print ('DUPLICADO INTERNO !!!!! --> %s == %s' % (filepath,depot[filehash]))
				with open('inner_dups.txt', 'a') as inner_dups:
					inner_dups.write('DUPLICADO INTERNO !!!!! --> %s == %s\n' % (filepath,depot[filehash]))
			else:
				depot[filehash]=filepath
	print ('Numero de archivos en FotoDepot (%s) == %d' % (folder,len(depot)))
	outFotoDepot=os.path.join(folder,'FotoDepot.dict')
	with open(outFotoDepot,'w') as fileout:
		json.dump(depot,fileout)
	return(len(depot))

#
# Programa principal
#
parser = argparse.ArgumentParser()
parser.add_argument("Path_New_Pics", \
	help="Directorio que contiene las nuevas fotos. Solo debe contener fotos, no otros directorios")
parser.add_argument("Path_Pic_Lib", \
	help="Directorio del cual cuelga nuestra biblioteca de fotos actual")
parser.add_argument("--delete", \
	help="Añadir este modificador para borrar las fotos de Path_Nuevas que ya esten en Path_Foto_Lib", action="store_true")
parser.add_argument("--init", \
	help="No usará Path_Pic_Lib/FotoDepot.dict aunque exista, lo generará de nuevo.", action="store_true")
args = parser.parse_args()
#
# Carpeta donde estas las fotos sin clasificar, que queremos saber si ya estan 
# en el deposito general
#
unsort_folder = args.Path_New_Pics
#
# Deposito General de fotos
#
plibrary_path = args.Path_Pic_Lib
#
# Chequeamos que realmente sean directorios
#
if os.path.isdir(unsort_folder):
	print("OK - Path_New_Pics")
else:
	print ("ERROR: %s no existe o no es un directorio" % (unsort_folder))
	sys.exit(1)
if os.path.isdir(plibrary_path):
	print("OK - Path_Pic_Lib")
else:
	print ("ERROR: %s no existe o no es un directorio" % (plibrary_path))
	sys.exit(1)
#
# Primero buscamos dentro de plibrary_path si hay un fichero llamado
# FotoDepot.dict. Si existe, por defecto lo usamos, contiene los hash codes 
# de todas las fotos de la biblioteca. O deberia. Cargamos el contenido 
# de ese fichero en el dict FotoDepot.
# Si no esta el fichero llamamos a la función init_FotoDepot que recorrera
# todas las fotos de plibrary_path calculando el hash y almacenandolo en 
# FotoDepot.
# Si usamos la opción --init inicializará el fichero si, o si.
#
FotoDepot={}
if args.init:
	init_FotoDepot(FotoDepot,plibrary_path)
else:	
	filedepot=os.path.join(plibrary_path,'FotoDepot.dict')
	if os.access(filedepot,os.R_OK):
		print ('Fichero con diccionario encontrado')
		with open(filedepot) as fdepot:
			FotoDepot=json.load(fdepot)
		print ('Fichero con diccionario cargado. %d elementos en FotoDepot' % (len(FotoDepot)))
	else:
		init_FotoDepot(FotoDepot,plibrary_path)

#
# Ahora vamos recorriendo la carpeta de fotos nuevas 
# calculando el hash de cada una y mirando si ya esta en FotoDepot
#
FotosSinClas = os.listdir(unsort_folder)
print ('Numero de archivos en %s == %d' % (unsort_folder,len(FotosSinClas)))
for file in FotosSinClas:
	filepath = os.path.join(unsort_folder,file)
	print (filepath)
	filehash = hashfile(filepath)
	if filehash in FotoDepot:
		print ('DUPLICADO!!!!! --> %s == %s' % (filepath,FotoDepot[filehash]))
		with open('dups.txt','a') as dupis:
			dupis.write('DUPLICADO!!!!! --> %s == %s\n' % (filepath,FotoDepot[filehash]))
		if args.delete:
			os.remove(filepath)
