import boto3
import os
import datetime

# 
# CloudWatchLogs -to- file
# 
# Argumentos:
#   Nombre del grupo de logs
#   Desde --> Fecha en segundos (date +%%s) desde la cual queremos los logs
#   Hasta --> Fecha en segundos (date +%%s) hasta la cual queremos los logs
# con import time
    # Por ejemplo:
    # >>> t = time.strptime("20 Feb 2019 10:00:00", "%d %b %Y %H:%M:%S")
    # >>> time.strftime('%s',t)
    # '1550653200' <-- Este es el valor que hay que pasar
    #
    # Otro ejemplo: fecha actual
    # >>> int(time.time())
    # 1558606299
# Con datetime
    # datetime.datetime(year, month, day, hour=0, minute=0, second=0, microsecond=0, tzinfo=None, *, fold=0)
    # Por Ejemplo:
    # >>> dt=datetime.datetime(2019,5,20)
    # >>> int(dt.timestamp())
    # 1558303200
# Otro ejemplo con datetime
    # Desde = datetime.datetime(2019, 5, 20)
    # Hasta = Desde + datetime.timedelta(hours=24)
    # Desde_secs = int(Desde.timestamp())
    # Hasta_secs = int(Hasta.timestamp())

def CWL2file(Log_Group_Name, Desde, Hasta, outfile):
    
    try:
        # 
        # Es necesario usar un paginador para no tener que hacer varias llamadas sucesivas 
        Logs = boto3.client('logs')
        paginator = Logs.get_paginator('describe_log_streams')
        lstreams = []
        pages = paginator.paginate(
            logGroupName = Log_Group_Name,
            orderBy = 'LastEventTime'
            )
        for page in pages:
            lstreams += page.get('logStreams')
    except Logs.exceptions.ResourceNotFoundException as e:
        print("El nombre %s no existe como grupo de Logs" % (Log_Group_Name))
        print(e)
        return 0
    except Exception:
        raise
    
    # Hay que multiplicar por mil los valores que nos hayan pasado en Desde y Hasta para ponerlos
    # en milisegundos.
    miliDesde = int(Desde) * 1000
    miliHasta = int(Hasta) * 1000

    process_streams = []

    for st in lstreams:
        #
        # Las streams cuyo las event timestamp se menor que miliDesde no hace 
        # falta mirarlas, todos los mensajes seran anteriores
        if st.get('lastEventTimestamp') < miliDesde:
            continue
        #
        # Las streams cuyo las event timestamp se mayor que miliHasta no hace 
        # falta mirarlas, todos los mensajes seran posteriores
        if st.get('firstEventTimestamp') > miliHasta:
            continue

        #
        # Todas las demas las tenemos que procesar
        stname = st.get('logStreamName')    
        process_streams.append(stname)
    # 
    # Es necesario usar un paginador para no tener que hacer varias llamadas sucesivas
    if process_streams:
        paginator = Logs.get_paginator('filter_log_events')
        pages = paginator.paginate(
            logGroupName=Log_Group_Name,
            logStreamNames=process_streams,
            startTime=miliDesde,
            endTime=miliHasta,
            )
        print("LogStreams procesadas en grupo: %s" %(Log_Group_Name))
        print(process_streams)
    else:
        print("No hay mensajes para ese intervalo de tiempo")
        return 0
    #
    # Vamos recorriendo las paginas y los eventos dentro de ellas
    # escribimos en el fichero de salida el message de cada evento.
    bytes_out = 0
    with open(outfile, 'a') as f_out:
        for page in pages:
            eventos = page.get('events')
            for ev in eventos:
                bytes_out += f_out.write(ev.get('message') + os.linesep)
    return bytes_out


def lambda_handler(event, context):
    Hasta = datetime.datetime.now()
    Desde = datetime.datetime.now() - datetime.timedelta(days=7)
    Desde_secs = int(Desde.timestamp())
    Hasta_secs = int(Hasta.timestamp())
    nsemana = Desde.strftime('%V')
    anio = Desde.strftime('%G')
    s3bucket = "registros-logs-koibox"
    #s3prefix = "autoescalado/"+anio+"/"
    s3prefix = "prueba/"
    osprefix = "/tmp/"
    cwl_groups = [
        "/aws/elasticbeanstalk/koiboxcrm-prod/var/log/httpd/access_log",
        "/aws/elasticbeanstalk/koiboxcrm-prod/var/log/httpd/error_log",
        "/aws/elasticbeanstalk/prod/var/app/current/var/logs/prod.log",
        "/aws/elasticbeanstalk/koiboxcrm-prod/var/log/eb-activity.log",
        "/aws/elasticbeanstalk/koiboxcrm-preprod/var/log/httpd/access_log",
        "/aws/elasticbeanstalk/koiboxcrm-preprod/var/log/httpd/error_log",
        "/aws/elasticbeanstalk/preprod/var/app/current/var/logs/prod.log",
        "/aws/elasticbeanstalk/koiboxcrm-preprod/var/log/eb-activity.log"
    ]
    log_files = [
        nsemana+"-apache_access_pro.log", 
        nsemana+"-apache_error_pro.log",
        nsemana+"-symfony_pro.log",
        nsemana+"-eb_activity_pro.log",
        nsemana+"-apache_access_pre.log",
        nsemana+"-apache_error_pre.log",
        nsemana+"-symfony_pre.log",
        nsemana+"-eb_activity_pre.log"
    ]
    map_groups_files = dict(zip(cwl_groups,log_files))

    s3 = boto3.resource('s3')

    for grp in map_groups_files.keys():
        os_file = osprefix+map_groups_files[grp]
        s3_obj = s3prefix+map_groups_files[grp]
        CWL2file(grp, Desde_secs, Hasta_secs, os_file)
        existe = os.path.isfile(os_file)
        if existe:
            s3.meta.client.upload_file(os_file,s3bucket,s3_obj)
            os.remove(os_file)

lambda_handler("EVENTO","KK")    

# Desde_secs = int(Desde.timestamp())
# Hasta_secs = int(Hasta.timestamp())

# escrito = CWL2file("RDSOSMetrics",Desde_secs,Hasta_secs,\
#     "/tmp/prueba_CWL2file2")
# print(escrito)
