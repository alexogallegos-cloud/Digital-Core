CREATE PROCEDURE "informix".sp_obtenernombrearchivo  ( piTipoArchivo INTEGER )

RETURNING CHAR (30) AS NomArchivo, CHAR (90) AS Ruta_Repositorio_AIX, CHAR (3) AS ArchivoOrigen, CHAR (90) AS Ruta_Repositorio_WIN ;

--****************************************************************************************************
-- DESCRIPCION:  GENERA EL NOMBRE DEL ARCHIVO DEL DIA ACTUAL
-- AUTOR : Casanova Edeza Hector Juan 
-- FECHA : 19/08/2008
-- BD: Intercard
-- SISTEMA : Conciliacion Intercard -- Automatico
-- MODIFICADO : 26/09/2008 CASANOVA EDEZA HECTOR JUAN 
-- DESCRIPCION : se modifico para que regrese la direccion del repositorio de Windows para utilizarlo en el transmisor de archivos  (demonio)
-- MODIFICADO : 14/01/2010 CASANOVA EDEZA HECTOR JUAN 
-- DESCRIPCION : se modifico el orden de los archivos con el fin de que se procesen primero los archivos de tienda coppel. Adicionalmemte se agrego el tipo de archivo GAC (generacion de archivo de comisiones)
-- MODIFICADO : 22/04/2010 CASANOVA EDEZA HECTOR JUAN 
-- ESCRIPCION: Se agrego la definicion de los nombre y rutas para los archivos de corresponsales de pagos(CCP), depositos(CCD) y archivo de comisiones(GCC).
-- MODIFICADO : 24/05/2011 ALFONSO ANTONIO CRUZ ALVAREZ 
-- DESCRIPCION: Se agrego la definicion de los nombre y rutas para los archivos de transferencias de prestamos coppel (TPD) y archivo de comisiones de transferencias de prestamos (ACT).
-- MODIFICADO : 13/10/2011 CASANOVA EDEZA HECTOR JUAN 
-- DESCRIPCION: Se agrego la definicion de los nombre y rutas para los archivos de reporte de cajeros automaticos (ATMS).
-- MODIFICADO : 13/10/2011 CASANOVA EDEZA HECTOR JUAN 
-- DESCRIPCION: Se aumenta el tamaño de la variable del nombre de los archivos de 23 a 30 caracteres.
-- MODIFICADO : 16/11/2011 CASANOVA EDEZA HECTOR JUAN 
-- DESCRIPCION: Se modifica la fecha de los archivos TMS para que sea la del dia anterior y no la del dia actual al formar el nombre del archivo.

--***************************************************************************************************

/*  DEFINICION DE VARIABLES */
DEFINE vsNombreArchivo CHAR (30) ;
DEFINE vsRuta_Repositorio_AIX CHAR (90) ;
DEFINE vsRuta_Repositorio_WIN CHAR (90) ;
DEFINE vsArchivoOrigen CHAR (3) ;
DEFINE dtFecha DATETIME YEAR TO FRACTION (5) ;

DEFINE visqlerr INTEGER ;

/* INICIALIZACION DE VARIABLES */

LET vsNombreArchivo = '' ;
LET vsRuta_Repositorio_AIX = '' ;
LET vsRuta_Repositorio_WIN = '' ;
LET vsArchivoOrigen = '' ;
LET dtFecha = CURRENT;

LET visqlerr = 0 ;

BEGIN

	ON EXCEPTION SET visqlerr   --cacha el error en caso de que exista y regresa un valor predeterminado
		
		RETURN 'ERROR', vsRuta_Repositorio_AIX, vsArchivoOrigen, vsRuta_Repositorio_WIN ;
		
	END EXCEPTION;
	
	IF (piTipoArchivo = 1) THEN -- POS TIENDAS COPPEL CREDITO
		LET vsNombreArchivo = 'BCPLTCC_' ;
		LET vsArchivoOrigen = 'TCC' ;
	ELIF (piTipoArchivo = 2) THEN -- POS TIENDAS COPPEL DEBITO
		LET vsNombreArchivo = 'BCPLTCD_' ;
		LET vsArchivoOrigen = 'TCD' ;
	ELIF (piTipoArchivo = 3) THEN  -- CORRESPONSALES  PAGOS --CREDITO
		LET vsNombreArchivo = 'BCPLCCP_' ;
		LET vsArchivoOrigen = 'CCP' ;
	ELIF (piTipoArchivo = 4) THEN  -- CORRESPONSALES DEPOSITOS ---DEBITO
		LET vsNombreArchivo = 'BCPLCCD_' ;
		LET vsArchivoOrigen = 'CCD' ;
	ELIF (piTipoArchivo = 5) THEN -- Transferencias de prestamos COPPEL
		LET vsNombreArchivo = 'BCPLTPD_';
		LET vsArchivoOrigen = 'TPD';
	ELIF (piTipoArchivo = 6) THEN  -- ATM  CREDITO
		LET vsNombreArchivo = 'BCPL_ATMC_' ;
		LET vsArchivoOrigen = 'TMC' ;
	ELIF (piTipoArchivo = 7) THEN -- ATM DEBITO
		LET vsNombreArchivo = 'BCPL_ATMD_' ;
		LET vsArchivoOrigen = 'TMD' ;
	ELIF (piTipoArchivo = 8) THEN -- ATM PROPIO
		LET vsNombreArchivo = 'BCPL_ATMPL_' ;
		LET vsArchivoOrigen = 'TMP' ;
	ELIF (piTipoArchivo = 9) THEN -- ATM OTROS
		LET vsNombreArchivo = 'BCPL_ATMOL_' ;
		LET vsArchivoOrigen = 'TMO' ;
	ELIF (piTipoArchivo = 10) THEN -- POS VENTAS NACIONALES DEBITO
		LET vsNombreArchivo = 'BCPLVND_' ;
		LET vsArchivoOrigen = 'VND' ;
	ELIF (piTipoArchivo = 11) THEN -- POS VENTAS INTERNACIONALES DEBITO
		LET vsNombreArchivo = 'BCPLVID_' ;
		LET vsArchivoOrigen = 'VID' ;
	ELIF (piTipoArchivo = 12) THEN -- POS VENTAS NACIONALES CREDITO
		LET vsNombreArchivo = 'BCPLVNC_' ;
		LET vsArchivoOrigen = 'VNC' ;
	ELIF (piTipoArchivo = 13) THEN -- POS VENTAS INTERNACIONALES CREDITO
		LET vsNombreArchivo = 'BCPLVIC_' ;
		LET vsArchivoOrigen = 'VIC' ;
	ELIF (piTipoArchivo = 14) THEN -- POS PAGOS INTERBANCARIOS
		LET vsNombreArchivo = 'BCPLPNC_' ;
		LET vsArchivoOrigen = 'PNC' ;
	ELIF (piTipoArchivo = 15) THEN -- REPORTES DE CAJEROS (ATMS)
		LET vsNombreArchivo = 'REDTCAT137D';
		LET vsArchivoOrigen = 'TMS';
	ELIF (piTipoArchivo = 70) THEN -- ARCHIVO DE COMISIONES INTERREDES  (GAC)
		LET vsNombreArchivo = 'concitarj' ;
		LET vsArchivoOrigen = 'ACI' ;
	ELIF (piTipoArchivo = 71) THEN -- ARCHIVO DE COMISIONES CORRESPONSALES  (GAC)
		LET vsNombreArchivo = 'concicorr' ;
		LET vsArchivoOrigen = 'ACC' ;
	ELIF (piTipoArchivo = 72) THEN -- ARCHIVO DE COMISIONES DE TRANSFERENCIAS DE PRESTAMOS (GAC)
		LET vsNombreArchivo = 'concipres' ;
		LET vsArchivoOrigen = 'ACT';
	ELSE --ERROR
		LET vsNombreArchivo = '' ;
		LET vsArchivoOrigen = '' ;
	END IF ;

	
	--ACOMPLETA EL NOMBRE DEL ARCHIVO A BUSCAR (AGREGA LA FECHA SEGUN SU FORMATO)
	IF ((vsArchivoOrigen = 'TMC') OR (vsArchivoOrigen = 'TMD') OR 
		(vsArchivoOrigen = 'TMP') OR (vsArchivoOrigen = 'TMO') ) THEN
		
		-- BCPL_ATM*_DDMMAA.txt  /  BCPL_ATMD_270308.txt  		
		--BCPL_TMC_190808.txt 
		-- LOS ARCHIVOS DE ATM LLEGAN CON FECHA DEL DIA ANTERIOR 
		LET dtFecha = CURRENT - Interval(1) day to day;			
		LET vsNombreArchivo = TRIM(vsNombreArchivo) || SUBSTRING (dtFecha FROM 9 FOR 2 ) || SUBSTRING (dtFecha FROM 6 FOR 2 ) || SUBSTRING (dtFecha FROM 3 FOR 2 ) || '.txt' ;
		
	ELIF ((vsArchivoOrigen = 'VNC') OR (vsArchivoOrigen = 'VND') OR
		(vsArchivoOrigen = 'VIC') OR (vsArchivoOrigen = 'VID') OR
		(vsArchivoOrigen = 'PNC') OR (vsArchivoOrigen = 'TCC') OR (vsArchivoOrigen = 'TCD') OR
		(vsArchivoOrigen = 'CCP') OR (vsArchivoOrigen = 'CCD') OR 
		(vsArchivoOrigen = 'TPD'))THEN 
		
		--BCPL***_DDMMAAAA.txt  /  BCPLVID_20062008.txt                
		IF (vsArchivoOrigen = 'PNC') THEN
			-- LOS ARCHIVOS DE PNC (PAGOINTERBANCARIO) LLEGAN CON FECHA DEL DIA ANTERIOR
			LET dtFecha = CURRENT - Interval(1) day to day;			
		END IF ;
		
		LET vsNombreArchivo = TRIM(vsNombreArchivo) || SUBSTRING (dtFecha FROM 9 FOR 2 ) || SUBSTRING (dtFecha FROM 6 FOR 2 ) || SUBSTRING (dtFecha FROM 1 FOR 4 ) || '.txt' ;
		
		
	ELIF ((vsArchivoOrigen = 'ACI') OR (vsArchivoOrigen = 'ACC') OR (vsArchivoOrigen = 'ACT')) THEN
		--concitarjMMDDAAAA.txt
		LET vsNombreArchivo = TRIM(vsNombreArchivo) || TRIM (REPLACE (SUBSTRING (CURRENT::DATE FROM 1 FOR 10),'/',''))||'.txt';
	ELIF (vsArchivoOrigen = 'TMS') THEN 
		--REDTCAT137DaammddEDcc.DAT
		LET dtFecha = CURRENT - Interval(1) day to day;	
		LET vsNombreArchivo = TRIM(vsNombreArchivo) || SUBSTR(YEAR(dtFecha), 3,2) || LPAD(MONTH(dtFecha),2,'0') || LPAD(DAY(dtFecha),2,'0') || 'ED01.DAT';
	END IF ;
	
	--OBTIENE LA RUTA DEL REPOSITORIO SEGUN EL PROVEDOR DEL ARCHIVO
	IF ((vsArchivoOrigen = 'TMC') OR (vsArchivoOrigen = 'TMD') OR   --EGLOBAL
		(vsArchivoOrigen = 'VNC') OR (vsArchivoOrigen = 'VND') OR
		(vsArchivoOrigen = 'VIC') OR (vsArchivoOrigen = 'VID') OR
		(vsArchivoOrigen = 'PNC') )THEN 
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		IF EXISTS ( SELECT Valor FROM intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'REP_EGLOBAL_AIX' ) THEN  
		
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			SELECT FIRST 1 Valor INTO vsRuta_Repositorio_AIX FROM intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'REP_EGLOBAL_AIX' ;
		ELSE
			LET vsRuta_Repositorio_AIX = 'NO ENCONTRADO' ;
		END IF ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		IF EXISTS ( SELECT Valor FROM intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'REP_EGLOBAL_WIN' ) THEN  
		
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			SELECT FIRST 1 Valor INTO vsRuta_Repositorio_WIN FROM intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'REP_EGLOBAL_WIN' ;
		ELSE
			LET vsRuta_Repositorio_WIN = 'NO ENCONTRADO' ;
		END IF ;
		
	ELIF ((vsArchivoOrigen = 'TMP') OR (vsArchivoOrigen = 'TMO') OR (vsArchivoOrigen = 'TMS')) THEN -- PROSA
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		IF EXISTS ( SELECT Valor FROM intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'REP_PROSA_AIX' ) THEN  
		
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			SELECT FIRST 1 Valor INTO vsRuta_Repositorio_AIX FROM intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'REP_PROSA_AIX' ;
		ELSE
			LET vsRuta_Repositorio_AIX = 'NO ENCONTRADO' ;
		END IF ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		IF EXISTS ( SELECT Valor FROM intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'REP_PROSA_WIN' ) THEN  
		
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			SELECT FIRST 1 Valor INTO vsRuta_Repositorio_WIN FROM intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'REP_PROSA_WIN' ;
		ELSE
			LET vsRuta_Repositorio_WIN = 'NO ENCONTRADO' ;
		END IF ;
		
	ELIF ((vsArchivoOrigen = 'TCC') OR (vsArchivoOrigen = 'TCD') OR 
		(vsArchivoOrigen = 'CCP') OR (vsArchivoOrigen = 'CCD') OR
		(vsArchivoOrigen = 'TPD') ) THEN -- TIENDAS COPPEL
	
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		IF EXISTS ( SELECT Valor FROM intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'REP_T.COPPEL_AIX' ) THEN  
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			SELECT FIRST 1 Valor INTO vsRuta_Repositorio_AIX FROM intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'REP_T.COPPEL_AIX' ;
		ELSE
			LET vsRuta_Repositorio_AIX = 'NO ENCONTRADO' ;
		END IF ;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		IF EXISTS ( SELECT Valor FROM intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'REP_T.COPPEL_WIN' ) THEN  
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			SELECT FIRST 1 Valor INTO vsRuta_Repositorio_WIN FROM intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'REP_T.COPPEL_WIN' ;
		ELSE
			LET vsRuta_Repositorio_WIN = 'NO ENCONTRADO' ;
		END IF ;
		
	ELIF ((vsArchivoOrigen = 'ACI') OR (vsArchivoOrigen = 'ACC') OR (vsArchivoOrigen = 'ACT')) THEN -- TIENDAS COPPEL  INTERREDES/CORRESPONSALES/TRANSFERENCIAS DE PRESTAMOS
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION TO DIRTY READ ;
		IF EXISTS ( SELECT Valor FROM intercard:"informix".Param_ConciliacionAuto WHERE Descripcion = 'generaarchivoconciliacion' ) THEN  
			
			SET LOCK MODE TO WAIT 3;
			SET ISOLATION TO DIRTY READ ;
			SELECT FIRST 1 Valor INTO vsRuta_Repositorio_AIX FROM intercard:"informix".Param_ConciliacionAuto WHERE descripcion = 'generaarchivoconciliacion';
		ELSE
			LET vsRuta_Repositorio_AIX = 'NO ENCONTRADO' ;
		END IF ;
		
		--NO TIENE REPOSITORIO WIN DEFINIDO
		LET vsRuta_Repositorio_WIN = '';
		
	END IF ;
	
	
	RETURN TRIM(vsNombreArchivo), vsRuta_Repositorio_AIX, vsArchivoOrigen, vsRuta_Repositorio_WIN ;
	
END

END PROCEDURE
DOCUMENT
'AUTOR: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: GENERA EL NOMBRE DEL ARCHIVO DE CONCILIACION DEL DIA ACTUAL.',
'Fecha: 2008/08/19',
'Version: 20080819.0933',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: se modifico para que regrese la direccion del repositorio de Windows para utilizarlo en el transmisor de archivos  (demonio).',
'Fecha: 2008/09/26',
'Version: 20080926.1640',
'BD: Intercard',
'',
'Modificado: Hector Juan Casanova Edeza',
'Proyecto: Conciliacion Automatica',
'Solicito: Jose Luis Puebla',
'Descripcion: se modifico el orden de los archivos con el fin de que se procesen primero los archivos de tienda coppel. Adicionalmemte se agrego el tipo de archivo GAC (generacion de archivo de comisiones).',
'Fecha: 2010/01/14',
'Version: 20100114.1220',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Mantenimiento',
'Folio: 1123',
'Solicito: Jose Luis Puebla',
'Descripcion: Se aumenta el tamaño de la variable correspondiente al nombre del archivo y se modifica el nombre de los archivos de cajeros de PROSA, de (BCPL_ATMO_ y BCPL_ATMP_) a (BCPL_ATMOL_ y BCPL_ATMPL_).',
'Fecha: 2010/04/13',
'Version: 20100413.0919',
'BD: Intercard', 
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Corresponsales',
'Folio: 1122',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrego la definicion de los nombre y rutas para los archivos de corresponsales de pagos(CCP), depositos(CCD) y archivo de comisiones(ACC).',
'Fecha: 2010/04/22',
'Version: 20100422.1107',
'BD: Intercard',
'',
'Modificado: Alfonso Antonio Cruz Alvarez',
'Proyecto: Conciliacion Automatica - Transferencia de pagos',
'Folio: ',
'Solicito: Jose Luis Puebla',
'Descripcion: Se agrego la definicion de los nombre y rutas para los archivos de transferencias de prestamos coppel (TDP) y archivo de comisiones de transferencias de prestamos (ACT).',
'Fecha: 2011/05/24',
'Version: 20110524.1609',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Transferencia de pagos',
'Folio: ',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se agrego la definicion de los nombre y rutas para los archivos de reporte de cajeros automaticos (ATMS).',
'Fecha: 2011/10/13',
'Version: 20111013.1049',
'BD: Intercard',
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Transferencia de pagos',
'Folio: ',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se aumenta el tamaño de la variable del nombre de los archivos de 23 a 30 caracteres.',
'Fecha: 2011/10/13',
'Version: 20111013.1159',
'BD: Intercard'
,
'',
'Modificado: Casanova Edeza Héctor Juan',
'Proyecto: Conciliacion Automatica - Transferencia de pagos',
'Folio: ',
'Solicito: Luis Antonio Gomez Santiago',
'Descripcion: Se modifica la fecha de los archivos TMS para que sea la del dia anterior y no la del dia actual al foemar el nombre del archivo.',
'Fecha: 2011/11/16',
'Version: 20111116.1158',
'BD: Intercard'
;

create procedure "informix".sp_actualiza_inventarios(ptipo_opcion varchar(1),pclave_sucursal varchar(5),
pclave_tipotarjeta integer, pnumerolote integer, pexistencia integer, psolicitadas integer)
RETURNING varchar(6), varchar(80);

/* Definición de parametros de llamada
tipo_opcion: Caracter que identifica que tipo de actualización a base de datos se ejecutará
'E': Actualización de existencias de un tipo de tarjeta
   Ejemplo: execute procedure "informix".sp_actualiza_inventarios('E','00297',4,0,0,0);
'S': Actualización de solicitadas de un tipo de tarjeta
   Ejemplo: execute procedure "informix".sp_actualiza_inventarios('S','00297',4,0,0,-1250);
'C': Cancelación de tarjetas por lote de la sucursal (no disponible)
'R': Reporte de Existencias e Inventarios de sucursal
   Ejemplo: execute procedure "informix".sp_actualiza_inventarios('R','00297',4,0,0,0);
   Ejemplo: execute procedure "informix".sp_actualiza_inventarios('R','00297',0,0,0,0);
*/

----------Variables-------------------------------
DEFINE  error_info              varchar(80);
DEFINE  isam_err                integer;
DEFINE  vsqlerr                 integer;
DEFINE  vcodret                 varchar(6);
DEFINE  p_mensaje               varchar(80);
DEFINE  vclave_sucursal         varchar(5);
DEFINE  vclave_tipotarjeta      integer;
DEFINE  vempleado               integer;
DEFINE  vnumerolote             integer;
DEFINE  vexistencia             integer;
DEFINE  vsolicitadas            integer;
DEFINE  vtipo_opcion            varchar(1);
DEFINE  vsql                    char(1550);
Define  vfecha_hoy              date;

------------- control de errores------
BEGIN 
 ON EXCEPTION SET vsqlerr,isam_err, error_info
            IF vsqlerr <> 0 then
                let vcodret = vsqlerr;
                let p_mensaje = error_info;
                  RETURN vcodret, p_mensaje;
            END IF;
 END EXCEPTION;
	
LET vclave_sucursal = pclave_sucursal;
LET vclave_tipotarjeta = pclave_tipotarjeta;
LET vnumerolote= pnumerolote;
LET vtipo_opcion = ptipo_opcion;
LET vexistencia = pexistencia;
LET vsolicitadas = psolicitadas;

LET vcodret = '0000';
LET  p_mensaje  = '';

/*Set debug file to "/informix/resplogifx/sp_actualiza_inventarios.out";
Trace on;*/

set isolation to dirty read;
select fecha_hoy into vfecha_hoy from bdinteg:si_fechas;

--Limpieza de existencias de una sucursal
IF (vtipo_opcion = 'E' and vclave_sucursal <> '') THEN
      
   let vsql = '';
   let vsql = ' echo "Clave Sucursal|Tipo Tarjeta|Existencia|Solicitadas|">/resplogifx/log_existencia_sucursal_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt'; 
   system vsql; 							
   let vsql = '';
   let vsql = '';
   let vsql=  'echo "set isolation to dirty read; UNLOAD TO /resplogifx/log_existencia_sucursal.unl select * from "informix".sucursal_tipotarjeta where clave_sucursal = ' || vclave_sucursal || ' and clave_tipotarjeta = ' || vclave_tipotarjeta|| ';">/resplogifx/log_existencia_sucursal.sql'; 
   system vsql;
   let vsql = '';
   let vsql= 'dbaccess intercard  /resplogifx/log_existencia_sucursal.sql';
   system vsql;
   let vsql ='';
   let vsql ='rm  /resplogifx/log_existencia_sucursal.sql';
   system vsql;
   let vsql ='';
   let vsql = "sed 's/|$//g' /resplogifx/log_existencia_sucursal.unl >>/resplogifx/log_existencia_sucursal_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt';
   system vsql;
   let vsql ='rm  /resplogifx/log_existencia_sucursal.unl';
   system vsql;             		

   update "informix".sucursal_tipotarjeta
   set existencia = vexistencia
   where clave_sucursal = vclave_sucursal  and
         clave_tipotarjeta = vclave_tipotarjeta;
    
ELSE 
    IF (vtipo_opcion = 'S' and vclave_sucursal <> '') THEN
     
   let vsql = '';
   let vsql = ' echo "Clave Sucursal|Tipo Tarjeta|Existencia|Solicitadas|">/resplogifx/log_solicitadas_sucursal_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt'; 
   system vsql; 							
   let vsql = '';
   let vsql = '';
   let vsql=  'echo "set isolation to dirty read; UNLOAD TO /resplogifx/log_solicitadas_sucursal.unl select * from "informix".sucursal_tipotarjeta where clave_sucursal = ' || vclave_sucursal || ' and clave_tipotarjeta = ' || vclave_tipotarjeta|| ';">/resplogifx/log_solicitadas_sucursal.sql'; 
   system vsql;
   let vsql = '';
   let vsql= 'dbaccess intercard  /resplogifx/log_solicitadas_sucursal.sql';
   system vsql;
   let vsql ='';
   let vsql ='rm  /resplogifx/log_solicitadas_sucursal.sql';
   system vsql;
   let vsql ='';
   let vsql = "sed 's/|$//g' /resplogifx/log_solicitadas_sucursal.unl >>/resplogifx/log_solicitadas_sucursal_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt';
   system vsql;
   let vsql ='rm  /resplogifx/log_solicitadas_sucursal.unl';
   system vsql;             		

   update "informix".sucursal_tipotarjeta
   set solicitadas = solicitadas - vsolicitadas
   where clave_sucursal = vclave_sucursal and
         clave_tipotarjeta = vclave_tipotarjeta;

ELSE IF (vtipo_opcion = 'R' and vclave_sucursal <> '') THEN

   IF (vclave_tipotarjeta = 0) THEN
   
      let vsql = '';
      let vsql = ' echo "Clave Sucursal|Tipo Tarjeta|Existencia|Solicitadas|">/resplogifx/log_reporte_tarjetas_resumen_sucursal_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt'; 
      system vsql; 							
      let vsql = '';
      let vsql = '';
      let vsql=  'echo "set isolation to dirty read; UNLOAD TO /resplogifx/log_reporte_tarjetas_resumen_sucursal.unl select * from "informix".sucursal_tipotarjeta where clave_sucursal = ' || vclave_sucursal || ';">/resplogifx/log_reporte_tarjetas_resumen_sucursal.sql'; 
      system vsql;
      let vsql = '';
      let vsql= 'dbaccess intercard  /resplogifx/log_reporte_tarjetas_resumen_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_resumen_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql = "sed 's/|$//g' /resplogifx/log_reporte_tarjetas_resumen_sucursal.unl >>/resplogifx/log_reporte_tarjetas_resumen_sucursal_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt';
      system vsql;
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_resumen_sucursal.unl';
      system vsql;             		

      let vsql = '';
      let vsql = ' echo "Tarjeta|Estatus Tarjeta|Producto|FechaExp|Lote|EstatusAsiganda|Guia|FechaGenenracion|Tipo Tarjeta|">/resplogifx/log_reporte_tarjetas_detalle_sucursal_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt'; 
      system vsql; 							
      let vsql = '';
      let vsql = '';
      let vsql=  'echo "set isolation to dirty read; UNLOAD TO /resplogifx/log_reporte_tarjetas_detalle_sucursal.unl select tjt.numtarjeta,	tjt.codstatustarjeta,	tjt.codproductotarjeta, tjt.fechaexp, tjt.numerolote, tjt.codstatusasignada, tjt.numeroguia, lte.fechageneracion, lte.clave_tipotarjeta from "informix".lote lte, "informix".tarjeta tjt where lte.clave_sucursal = ' || vclave_sucursal || ' and lte.numerolote = tjt.numerolote and tjt.codstatustarjeta = \"INA\" and tjt.codstatusasignada = \"NOA\" order by lte.clave_tipotarjeta, tjt.numerolote, tjt.numtarjeta;">/resplogifx/log_reporte_tarjetas_detalle_sucursal.sql'; 
      system vsql;
      let vsql = '';
      let vsql= 'dbaccess intercard  /resplogifx/log_reporte_tarjetas_detalle_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_detalle_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql = "sed 's/|$//g' /resplogifx/log_reporte_tarjetas_detalle_sucursal.unl >>/resplogifx/log_reporte_tarjetas_detalle_sucursal_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt';
      system vsql;
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_detalle_sucursal.unl';
      system vsql;   

   ELSE

      let vsql = '';
      let vsql = ' echo "Clave Sucursal|Tipo Tarjeta|Existencia|Solicitadas|">/resplogifx/log_reporte_tarjetas_resumen_sucursal_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt'; 
      system vsql; 							
      let vsql = '';
      let vsql = '';
      let vsql=  'echo "set isolation to dirty read; UNLOAD TO /resplogifx/log_reporte_tarjetas_resumen_sucursal.unl select * from "informix".sucursal_tipotarjeta where clave_sucursal = ' || vclave_sucursal || ' and clave_tipotarjeta = ' || vclave_tipotarjeta|| ';">/resplogifx/log_reporte_tarjetas_resumen_sucursal.sql'; 
      system vsql;
      let vsql = '';
      let vsql= 'dbaccess intercard  /resplogifx/log_reporte_tarjetas_resumen_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_resumen_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql = "sed 's/|$//g' /resplogifx/log_reporte_tarjetas_resumen_sucursal.unl >>/resplogifx/log_reporte_tarjetas_resumen_sucursal_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt';
      system vsql;
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_resumen_sucursal.unl';
      system vsql;   
    
      let vsql = '';
      let vsql = ' echo "Tarjeta|Estatus Tarjeta|Producto|FechaExp|Lote|EstatusAsiganda|Guia|FechaGenenracion|Tipo Tarjeta|">/resplogifx/log_reporte_tarjetas_detalle_sucursal_'|| day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt'; 
      system vsql; 							
      let vsql = '';
      let vsql = '';
      let vsql=  'echo "set isolation to dirty read; UNLOAD TO /resplogifx/log_reporte_tarjetas_detalle_sucursal.unl select tjt.numtarjeta,	tjt.codstatustarjeta,	tjt.codproductotarjeta, tjt.fechaexp, tjt.numerolote, tjt.codstatusasignada, tjt.numeroguia, lte.fechageneracion, lte.clave_tipotarjeta from "informix".lote lte, "informix".tarjeta tjt where lte.clave_sucursal = ' || vclave_sucursal || ' and lte.numerolote = tjt.numerolote and tjt.codstatustarjeta = \"INA\" and tjt.codstatusasignada = \"NOA\" and lte.clave_tipotarjeta = ' || vclave_tipotarjeta || ' order by lte.clave_tipotarjeta, tjt.numerolote, tjt.numtarjeta;">/resplogifx/log_reporte_tarjetas_detalle_sucursal.sql'; 
      system vsql;
      let vsql = '';
      let vsql= 'dbaccess intercard  /resplogifx/log_reporte_tarjetas_detalle_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_detalle_sucursal.sql';
      system vsql;
      let vsql ='';
      let vsql = "sed 's/|$//g' /resplogifx/log_reporte_tarjetas_detalle_sucursal.unl >>/resplogifx/log_reporte_tarjetas_detalle_sucursal_"||day(vfecha_hoy)||LPAD (MONTH(vfecha_hoy),2,"0")||year(vfecha_hoy)|| '_' || vclave_sucursal || '.txt';
      system vsql;
      let vsql ='rm  /resplogifx/log_reporte_tarjetas_detalle_sucursal.unl';
      system vsql; 

     END IF;

   ELSE IF (vtipo_opcion = '' or vclave_sucursal = '') THEN
           LET vcodret = '0001';
           LET  p_mensaje  = '¡¡¡¡¡Error/La sucursal no puede ser CERO!!!!!!!! ';
           return vcodret, p_mensaje;
         END IF;
    END IF;
  END IF;
END IF;
return vcodret, p_mensaje;
END
END PROCEDURE;