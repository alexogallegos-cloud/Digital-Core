CREATE PROCEDURE "informix".sp_locale_data_geo( pLat VARCHAR(12), pLong VARCHAR(12), xLat VARCHAR(12), xLong VARCHAR(12), pTipo CHAR(1)) 
       RETURNING CHAR(5), VARCHAR(60);
--****************************************************************************************************
-- DESCRIPCION: Generar trazado de geolocalizacion -> canal APP Movil
-- AUTOR : AVF
-- FECHA : 15/05/2023
-- FECHA DE EDICION: 25/03/2026
-- BD: bdibpi
--****************************************************************************************************

-- Definicion de variables
DEFINE distance          INTEGER;
DEFINE idEnt             INTEGER;
DEFINE lat0              VARCHAR(12);
DEFINE lon0              VARCHAR(12);
DEFINE lat1	             FLOAT;
DEFINE lng1	             FLOAT;
DEFINE geodata	         VARCHAR(60);
DEFINE vdata	         VARCHAR(60);
DEFINE vflgData          VARCHAR(60);	
DEFINE vflg	             CHAR(1);
DEFINE vregistros	     INTEGER;
DEFINE vinserta		     INTEGER;
DEFINE vtermina	         INTEGER;
DEFINE vlimite           INTEGER;
DEFINE vdistanciaMax     INTEGER;
DEFINE distancePreReg    INTEGER;
-- Variables para manejo de excepcion/resultado
DEFINE sql_err           INTEGER;
DEFINE cod_ret           CHAR(5);

LET distance             = 0;
LET idEnt                = 0;
LET lat0                 = "";
LET lon0                 = "";
LET lat1                 = 0;
LET lng1                 = 0;
LET geodata              = '000,000,00,00000,XX';
LET vdata                = "";
LET vflgData             = "";	
LET vflg                 = "";
LET vregistros           = 10;
LET vinserta             = 0;	
LET vtermina             = 0;
LET vlimite              = 2;
LET vdistanciaMax        = 0;
LET distancePreReg       = 10;
LET sql_err              = 0;
LET cod_ret              = '00000';

BEGIN
    -- Manejo de excepcion
    ON EXCEPTION SET sql_err
       --SET debug FILE TO "/ifxsif01/aw/out/sp_locale_data_geo.out";
       --TRACE ON;   
       IF sql_err <> 0 THEN
          LET cod_ret = sql_err;
          RETURN cod_ret, vdata;
       END IF ;
    END EXCEPTION;
	
    --SET debug FILE TO "/ifxsif01/aw/out/sp_locale_data_geo.out";
    --TRACE ON;    

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3; 
	
    LET lat0 = TRIM(xLat) ||'%';
    LET lon0 = TRIM(xLong)||'%';	 
 
    IF (lat0 = "" OR lat0 = "%") THEN
       LET cod_ret  = '00001'; 
       RETURN cod_ret, vdata;
    END IF;

    SELECT valor 
      INTO vflg 
      FROM bdibpi:bpi_param 
     WHERE id_param='34';
    
    SELECT valor 
      INTO vdistanciaMax 
      FROM bdibpi:bpi_param 
     WHERE id_param='33';

    IF NVL(vdistanciaMax,0) = 0 THEN
       LET vdistanciaMax =50;
    END IF;

    IF (pTipo='1') THEN--Inicia iteracion tipo 1
      FOREACH cur01 FOR
      	 SELECT id, cod_ciudad||","||cod_munic||","||cod_ent||","||CP||",MX" as a1, lat, log 
           INTO idEnt, geodata, lat1, lng1
           FROM bdibpi:bpi_geoloc_ent 
          WHERE lat LIKE lat0 AND log LIKE lon0
          ORDER BY lat
		  
         LET vflgData = geodata;
         
         EXECUTE FUNCTION getdistance (pLat, pLong, lat1, lng1) 
		    INTO distance;
         ---ini ciclo1
         IF (distance>=0 AND distance<=vdistanciaMax) THEN				
         	LET vinserta = vinserta + 1 ;			
         	IF distance <= distancePreReg THEN
         		LET distancePreReg = distance;
         		LET vdata= geodata;
         	END IF;
         	IF (distance=0 OR vinserta >= vlimite) THEN
         		LET vtermina = 1;
         	END IF;
         END IF;
         ---fin ciclo1
         IF vtermina = 1 THEN
         	EXIT FOREACH;
         END IF; 
			
      CONTINUE FOREACH;
      END FOREACH;
    END IF;	
 
    IF (pTipo='2') THEN--Inicia iteracion tipo 2
      FOREACH cur02 FOR
      	 SELECT id, cod_ciudad||","||cod_munic||","||cod_ent||","||CP||",MX" as a1, lat, log 
           INTO idEnt, geodata, lat1, lng1
           FROM bdibpi:bpi_geoloc_ent 
          WHERE lat LIKE lat0
          ORDER BY lat
      	 
         EXECUTE FUNCTION getdistance ( pLat, pLong, lat1, lng1 ) 
		    INTO distance;
         ---ini ciclo1
         IF (distance>=0 AND distance<=vdistanciaMax) THEN				
         	LET vinserta = vinserta + 1 ;			
         	IF distance <= distancePreReg THEN
               LET distancePreReg = distance;
               LET vdata= geodata;
         	END IF;
         	IF (distance=0 OR vinserta >= vlimite) THEN
               LET vtermina = 1;
         	END IF;
         END IF;
         ---fin ciclo1
         IF vtermina = 1 THEN
         	EXIT FOREACH;
         END IF;
      CONTINUE FOREACH;
      END FOREACH;
    END IF;

    IF (pTipo='3') THEN--Inicia iteracion tipo 3
       LET lat1 = pLat::FLOAT;
       LET lng1 = pLong::FLOAT; 
       IF ( (lat1 <= 48.16 AND lat1 >= 31.96 AND lng1 >=-122.04 AND lng1 <=-71.54) ) THEN
          LET vdata = "000,000,00,00000,US";
       END IF;
    END IF;
	
    IF (vflg='1' AND vinserta = 0 AND vflgData<>"") THEN
       LET vdata = vflgData;
    END IF;

RETURN cod_ret, vdata;
END;
END PROCEDURE;