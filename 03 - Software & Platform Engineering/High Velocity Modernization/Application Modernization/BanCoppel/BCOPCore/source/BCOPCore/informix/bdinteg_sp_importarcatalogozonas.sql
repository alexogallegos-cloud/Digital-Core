CREATE PROCEDURE "informix".sp_importarcatalogozonas(pSeparador CHAR(1), pNomArch CHAR(30), pEjecucion CHAR(1))
RETURNING CHAR(6), CHAR(80);

--Declaracion de variables
------------------------------------------------------------
DEFINE sql_err                 	INTEGER;
DEFINE isam_err                	INTEGER;
DEFINE error_info              	CHAR(80);
DEFINE cCod_ret                	CHAR(6);
DEFINE cMensaje                	CHAR(80);

DEFINE cCadena                 	CHAR (500);
DEFINE vPath                   	CHAR(50);

DEFINE vNumerociudad           	SMALLINT;
DEFINE vNumerocolonia		   	SMALLINT;
DEFINE vNomzona              	CHAR(32);

--A.L.L.
DEFINE vfechahoy               	DATE;
DEFINE vTotalzonasRecibidas		INTEGER;

DEFINE vNumCiudad				INTEGER;
DEFINE vNumColonia				INTEGER; 
DEFINE vNombreZona				CHAR(32);
DEFINE vPoblacionZona			CHAR(27);
DEFINE vMunicipioZona			CHAR(27);
DEFINE vCodigoPostalZona		INTEGER;
DEFINE vNumeroCiudadCoppel		INTEGER;
DEFINE vNumeroColoniaCoppel		INTEGER;
DEFINE vNombreZonaCoppel		CHAR(32);
DEFINE iExisteTabla           INTEGER;
DEFINE iExisteIndice          INTEGER;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Creado: José de Jesús Almeida
-- Fecha: 21 de octubre de 2009
-- Crear en BDINTEG
-- Se crea con el objetivo de obtener el total o una parcialidad de las zonas del catalogo
---Nota: Este sp falla cuando se corre desde el visualizer pero funciona ok desde dbaccess.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Modificado por: MACF
-- Fecha: 08/06/2010
-- Agregar parámetro pEjecucion para determinar si es Automática o Manual
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Modificado por: Abrham López L.
-- Fecha: 09/05/2012
-- Eliminar llaves primarias de la tabla y eliminar registros repetidos.
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-- Modificado por: Abrham Lopez Lopez
-- Fecha: 25-07-2012
-- Se insertan registros duplicados, erroneos y relacionados a la tabla si_catzonas_bcpl_cpl
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------
LET cCod_ret  = '00000';
LET sql_err   = 0;
LET cMensaje  = 'Proceso Exitoso';
LET cCadena   = '';
LET vPath     = '';

LET vNumerociudad  = 0;
LET vNumerocolonia = 0;
LET vNombrezona    = '';
LET iExisteTabla   = 0;
LET iExisteIndice  = 0;

      BEGIN
  
        ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET cMensaje = error_info;
        RETURN cCod_ret, cMensaje;
        END EXCEPTION;

 --SET DEBUG FILE TO "/ifxsif01/macf/sp_importarcatalogozonas.out";
 --TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

-- A.L.L.* OBTENEMOS LA FECHA DE HOY------------------------------------------------------------
    SELECT prox_fecha        --fecha_hoy 
      INTO vfechahoy
      FROM bdinteg:si_fechas where empresa = '001';

    --IF EXISTS(SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'si_catzonas_coppel'  AND dbsname = 'bdinteg') THEN
    --   DROP TABLE si_catzonas_coppel;
    --END IF;

    SELECT count(*) into iExisteTabla
		  FROM sysmaster:systabnames 
      WHERE tabname= 'si_catzonas_coppel' 
       AND dbsname = 'bdinteg';
 
    if iExisteTabla > 0 then 
       DROP TABLE si_catzonas_coppel;
    end if;
       
    CREATE TABLE si_catzonas_coppel(
    numerociudad        smallint not null ,
    numerocolonia       smallint not null ,
    nombrezona          char(32),
    poblacionzona       char(27),
    municipiozona       char(27),
    codigopostalzona    integer,
    supervisorzona      integer,
    choferzona          integer,
    jefegrupozona       integer,
    gerentezona         integer,
    abogadozona         integer,
    centro              integer,
    ciudadcobranzas     integer,
    numerocobranzas     smallint,
    numerociudadcoppel  integer,
    numerocoloniacoppel integer,
    nombrezonacoppel    char(32)--,  A.L.L. SE ELIMINAN LLAVES PRIMARIAS PARA QUE META CIUDADES Y ZONAS REPETIDAS CAMBIO DEL 09/05/2012 YA EN PRODUCCION
   -- primary key (numerociudad, numerocolonia) constraint pk_si_catzonas_coppel
  );

  SELECT count(*) into iExisteIndice 
    FROM sysindices 
   WHERE idxname = 'idx_cuenta_tmp';
     
   IF iExisteIndice > 0 THEN
      DROP INDEX idx_si_catzonas_coppel_numcd_numcol;
   END IF; 

  begin;
      create index idx_si_catzonas_coppel_numcd_numcol on 
       si_catzonas_coppel(numerociudad, numerocolonia) online;
  commit;
  update statistics medium for table si_catzonas_coppel;
  
    IF pEjecucion = 'A' THEN
            SELECT valor INTO vPath 
            FROM bdinteg:si_param_dom 
            WHERE empresa = '001' AND cod_param = 12;
		  
		  LET cCadena = 'echo "FILE '|| SUBSTR(vPath,1,LENGTH(vPath)) || SUBSTR(pNomArch,1,LENGTH(pNomArch))  || ' DELIMITER '''||'|'||''' 17; insert into "informix".si_catzonas_coppel; " > ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_si_catzonas.sql';
          System SUBSTR(cCadena,1,LENGTH(cCadena));
		  let cCadena = '';
		  
		  LET cCadena = 'dbload -d bdinteg -c ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_si_catzonas.sql -l ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_si_catzonas.log -n 1000 -k';
		  System SUBSTR(cCadena,1,LENGTH(cCadena));
		  let cCadena = 'rm ' || SUBSTR(vPath,1,LENGTH(vPath)) || 'importa_si_catzonas.sql';

    ELSE
	
	LET cCadena = 'echo "FILE '|| '/tmp/' || SUBSTR(pNomArch,1,LENGTH(pNomArch))  || ' DELIMITER '''||'|'||''' 17; insert into "informix".si_catzonas_coppel; " > /tmp/importa_si_catzonas.sql';
    System SUBSTR(cCadena,1,LENGTH(cCadena));
	let cCadena = '';
	  
	LET cCadena = 'dbload -d bdinteg -c /tmp/importa_si_catzonas.sql -l /tmp/importa_si_catzonas.log -n 1000 -k';
	System SUBSTR(cCadena,1,LENGTH(cCadena));
	
	let cCadena = '';
	let cCadena = '/usr/bin/rm /tmp/importa_si_catzonas.sql'; 
	System SUBSTR(cCadena,1,LENGTH(cCadena));
	
END IF; 

	--A.L.L.* BORRAMOS LOS DATOS DE LA TABLA PARA INSERTAR NUEVOS CONCILIADOS ERRONEOS Y DUPLICADOS.
        TRUNCATE TABLE si_catzonas_bcpl_cpl;  --NOTA: Se le quitaron las llaves primarias a esta tabla.

--A.L.L.* SELECCIONAMOS LAS CIUDADES INCORRECTAS LA CUALES SON CIUDAD = 0 COLONIA = 0
	FOREACH
		SELECT numerociudad, numerocolonia, nombrezona, poblacionzona, municipiozona, codigopostalzona, numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel
		INTO vNumCiudad, vNumColonia, vNombreZona, vPoblacionZona, vMunicipioZona, vCodigoPostalZona, vNumeroCiudadCoppel, vNumeroColoniaCoppel, vNombreZonaCoppel
		FROM bdinteg:si_catzonas_coppel
		WHERE numerociudad = 0 
		AND numerocolonia = 0
	
		IF vNumCiudad = 0 AND vNumColonia = 0 THEN
		                                     
		INSERT INTO BDINTEG:si_catzonas_bcpl_cpl(numerociudad,fecha_conciliacion,numerocolonia,numerociudadcoppel,numerocoloniacoppel,nombrezonacoppel,tipo_actualizacion) 
										VALUES 
												(vNumCiudad, vfechaHoy, vNumColonia, vNumeroCiudadCoppel, vNumeroColoniaCoppel, vNombreZonaCoppel, 'E' );
	END IF;
END FOREACH;
	--A.L.L. BORRAMOS LAS ZONAS ERRONEAS LAS CUALES TIENEN NUMEROCIUDAD CERO Y NUMEROCOLONIA CERO
		DELETE si_catzonas_coppel WHERE numerociudad = 0 AND numerocolonia = 0; 

--A.L.L. CONSULTAMOS REGISTROS DUPLICADOS
	FOREACH
		SELECT numerociudad, numerocolonia
			INTO vNumerociudad, vNumerocolonia
			FROM bdinteg:si_catzonas_coppel 
		GROUP BY numerociudad, numerocolonia HAVING COUNT(*) > 1
		
		IF vNumerociudad >= 0  THEN
	--A.L.L. INSERTAMOS LOS REGISTROS DUPLICADOS EN LA TABLA si_catzonas_bcpl_cpl
		INSERT INTO BDINTEG:si_catzonas_bcpl_cpl
		SELECT numerociudad, numerocolonia, vfechaHoy, numerociudadcoppel, numerocoloniacoppel, nombrezonacoppel, 'D' 
		FROM bdinteg:si_catzonas_coppel
		WHERE numerociudad = vNumerociudad 
		AND numerocolonia = vNumerocolonia;
		
		--A.L.L. PARA ELIMINAR DUPLICADAS UNA VEZ QUE SE INSERTARON EN LA TABLA si_catzonas_bcpl_cpl
			DELETE FROM bdinteg:si_catzonas_coppel 
				WHERE numerociudad = vNumerociudad 
				AND numerocolonia = vNumerocolonia;
		
	END IF;
END FOREACH;

    ALTER TABLE si_catzonas_coppel ADD b_conciliado CHAR(1) DEFAULT 'F';

RETURN cCod_ret, cMensaje;

END;
END PROCEDURE;