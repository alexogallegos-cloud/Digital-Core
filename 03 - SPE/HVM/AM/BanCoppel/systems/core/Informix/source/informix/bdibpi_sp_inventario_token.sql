CREATE PROCEDURE "informix".sp_inventario_token ()
returning char (5) as codRet, char (6) as Existencia,char (6) as Disponible,char (6) as Enviado,char (6) as Entregados,
		  char (6) as Garantia, char (9) as SerieIn, char (9) as SerieFin, char (6) as Solicitud, char(6) as Envio1,
		  char(6) as Envio2, char(6) as Envio3, char(6) as Devueltos, char (6) as EnvioEntregado, char(6) as Envio1M,
		  char(6) as Envio2M, char(6) as Envio3M, char(6) as DevueltosM, char (6) as EnvioEntregadoM;
--Elaboró: Javier A. Chávez Trujillo.
--Fecha: 05/11/09
--Solicitó: Mauricio León
--Actividad: regresa los token disponibles

--Modificó: Walber Castro
--Fecha: 18/08/2011
--Solicitó: Diana Castellanos
--Actividad: Se agregaron 5 nuevos parámetros de salida con el conteo de paquetes para personas morales.

--Modificó: Ilse Jazmín Gómez Pérez
--Fecha: 26/11/2013
--Solicitó: José de Jesus Nevarez
--Actividad: Se agregaron los nuevos estatus y tipo para las solicitudes.

--Define Variables
DEFINE sql_err integer;
DEFINE cod_ret char(5);
DEFINE vExistencias char (6);
DEFINE vDisponibles char (6);
DEFINE vEnviados char (6);
DEFINE vEntregados char (6);
DEFINE vGarantia char (6);
DEFINE vSerieIni char(9);
DEFINE vSerieFin char(9);
DEFINE vSolicitud char (6);
DEFINE vEnvio1 char(6);
DEFINE vEnvio2 char(6);
DEFINE vEnvio3 char(6);
DEFINE vEnvios char(6);
DEFINE vDevueltos char(6);
DEFINE vEnvioEntregado char(6);

DEFINE vEnvio1M char(6);
DEFINE vEnvio2M char(6);
DEFINE vEnvio3M char(6);
DEFINE vDevueltosM char(6);
DEFINE vEnvioEntregadoM char(6);

--SET DEBUG FILE TO "/tmp/sp_inventario_token.out";
--TRACE ON;

-- Inicializa
LET cod_ret = '000';
LET vExistencias = 0;
LET vDisponibles = 0;
LET vEnviados = 0;
LET vEntregados = 0;
LET vGarantia = 0;
LET vEnvio1 = '';
LET vEnvio2 = '';
LET vEnvio3 = '';
LET vEnvios = '';
LET vDevueltos = '';
LET vEnvioEntregado = '';
LET vSerieIni = '';
LET vSerieFin = '';
LET vSolicitud = '';

LET vEnvio1M = '';
LET vEnvio2M = '';
LET vEnvio3M = '';
LET vDevueltosM = '';
LET vEnvioEntregadoM = '';

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

 BEGIN

   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, vExistencias, vDisponibles, vEnviados, vEntregados, vGarantia, vSerieIni,vSerieFin,vSolicitud,vEnvio1, vEnvio2, vEnvio3, vDevueltos, vEnvioEntregado, vEnvio1M, vEnvio2M, vEnvio3M, vDevueltosM, vEnvioEntregadoM;
      END IF ;
   END EXCEPTION ;

   IF EXISTS(SELECT ns_token FROM bdibpi:"informix".tkn_nseries) THEN

		SELECT
		SUM(CASE WHEN  id_status = 100 THEN 1 END) id100,
		SUM(CASE WHEN  id_status = 105 THEN 1 END) id105,
		SUM(CASE WHEN  id_status = 120 THEN 1 END) id120,
		SUM(CASE WHEN  id_status = 130 THEN 1 END) id130,
		SUM(CASE WHEN  id_status = 199 THEN 1 END) id199
		INTO vExistencias, vDisponibles, vEnviados, vEntregados, vGarantia
		FROM bdibpi:"informix".tkn_nseries
		WHERE id_status IN (100,105,120,130,199);


		SELECT MIN(ns_token::varchar(9)) INTO vSerieIni FROM bdibpi:"informix".tkn_nseries WHERE id_status = 100;
		SELECT MAX(ns_token::varchar(9)) INTO vSerieFin FROM bdibpi:"informix".tkn_nseries WHERE id_status = 100;


		LET cod_ret = '00000';
	ELSE
		LET cod_ret = '00001'; -- No se encontró ningún token en la tabla
   END IF;

		SELECT COUNT (solicitud) INTO vSolicitud FROM bdibpi:"informix".bpi_tokensolicitud WHERE id_status IN (100,180,200) AND tipo IN (1,2,3,4,6,7);

		SELECT
		SUM(CASE WHEN a.num_envio = 1 AND b.tipo NOT IN ('3','4') THEN 1 ELSE 0 END) id1,
		SUM(CASE WHEN a.num_envio = 2 AND b.tipo NOT IN ('3','4') THEN 1 ELSE 0 END) id2,
		SUM(CASE WHEN a.num_envio = 3 AND b.tipo NOT IN ('3','4') THEN 1 ELSE 0 END) id3,
		SUM(CASE WHEN a.num_envio = 1 AND b.tipo IN ('3','4') THEN 1 ELSE 0 END) id1m,
		SUM(CASE WHEN a.num_envio = 2 AND b.tipo IN ('3','4') THEN 1 ELSE 0 END) id2m,
		SUM(CASE WHEN a.num_envio = 3 AND b.tipo IN ('3','4') THEN 1 ELSE 0 END) id3m
		INTO vEnvio1, vEnvio2, vEnvio3, vEnvio1M, vEnvio2M, vEnvio3M
		FROM bdibpi:"informix".tkn_envios a INNER JOIN bdibpi:"informix".bpi_tokensolicitud b ON (a.solicitud=b.solicitud and a.numcte=b.numcte)
		WHERE a.num_envio IN (1,2,3);		
		
		
		SELECT COUNT(*) INTO vDevueltos FROM bdibpi:"informix".tkn_envios a INNER JOIN bdibpi:"informix".bpi_tokensolicitud b ON (a.solicitud=b.solicitud and a.numcte=b.numcte) WHERE a.id_status = 170 AND b.tipo NOT IN ('3','4');
		SELECT COUNT(*) INTO vDevueltosM FROM bdibpi:"informix".tkn_envios a INNER JOIN bdibpi:"informix".bpi_tokensolicitud b ON (a.solicitud=b.solicitud and a.numcte=b.numcte) WHERE a.id_status = 170 AND b.tipo IN ('3','4');
		
		SELECT COUNT(*) INTO vEnvioEntregado FROM bdibpi:"informix".tkn_envios a INNER JOIN bdibpi:"informix".bpi_tokensolicitud b ON (a.solicitud=b.solicitud and a.numcte=b.numcte) WHERE a.id_status = 130 AND b.tipo NOT IN ('3','4');
		SELECT COUNT(*) INTO vEnvioEntregadoM FROM bdibpi:"informix".tkn_envios a INNER JOIN bdibpi:"informix".bpi_tokensolicitud b ON (a.solicitud=b.solicitud and a.numcte=b.numcte) WHERE a.id_status = 130 AND b.tipo IN ('3','4');
		
   RETURN cod_ret, vExistencias, vDisponibles, vEnviados, vEntregados, vGarantia, vSerieIni,vSerieFin,vSolicitud,vEnvio1, vEnvio2, vEnvio3, vDevueltos, vEnvioEntregado, vEnvio1M, vEnvio2M, vEnvio3M, vDevueltosM, vEnvioEntregadoM;
 END;
END PROCEDURE;