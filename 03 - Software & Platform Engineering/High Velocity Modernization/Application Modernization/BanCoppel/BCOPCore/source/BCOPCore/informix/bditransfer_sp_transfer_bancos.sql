create procedure "informix".sp_transfer_bancos ()

returning 	
				char (5)    as codret, 
				char (150)  as mensaje_respuesta,
				char (3)    as id_banco,
				char (35)   as nombre;
				
-- Definicion de retorno
define 	vscodret 				char(5);
define  vsmensaje_respuesta     char(150);
define  vsidbanco               char (3);
define  vsdesc_bco				char (35);

define  visqlerr				integer;
	
begin
	on exception set visqlerr
		
		let vscodret = vsCodRet;
		
		return 	  	
					TRIM(NVL(vscodret, '')), 
					TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
					TRIM(NVL(vsidbanco, '')),
					TRIM(UPPER(NVL(vsdesc_bco,'')));
				
	end exception;
	
--set debug file to "/informix/mgap/sp_transfer_bancos.out";
--trace on;


-- Inicializacion de retorno
Let  vscodret = '00000';
let  vsmensaje_respuesta = '';
let  vsidbanco	 = '';
let  vsdesc_bco	= '';

set isolation to dirty read;

FOREACH cusor1 with hold for
		
			SELECT TRIM(id_banco),trim(nombre) 
		    INTO vsidbanco, vsdesc_bco 
			FROM Bditransfer:"informix".tf_cat_bancos
			
			RETURN 
					TRIM(NVL(vscodret, '')), 
					TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
					TRIM(NVL(vsidbanco, '')),
					TRIM(UPPER(NVL(vsdesc_bco,'')))
			WITH RESUME;
			
END FOREACH;

/*
RETURN 
					TRIM(NVL(vscodret, '')), 
					TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
					TRIM(NVL(vsidbanco, '')),
					TRIM(UPPER(NVL(vsdesc_bco,'')));*/
end
end procedure
DOCUMENT
'AUTOR: L.I. Marcos Gerardo Ayala Ponce',
'Proyecto: RQM 06 539 REPORTE INTERBANCARIO BANKSSETTLEMENT',
'Solicito: Operaciones TRANSFER',
'Descripcion: Recuperar el catalogo de Bancos con relación a la plataforma de Transfer',
'Fecha: 2016/11/18',
'Version: 20161117.1200',
'BD: Bditransfer';

CREATE PROCEDURE "informix".sp_transfer_msettlement2 (
					pdfechaini   date,
					pdfechafin   date,
					psbcoorigen  char(3),
					psbcodestino char(3),
					pRegistros INTEGER, 
					pRecuperacion INTEGER
					)
returning 	
				char (5) 	as codret, 
				char (150) 	as mensaje_respuesta,
				char (50)   as nombre_archivo,
				char (3)    as banco_origen,
				char (3)    as banco_destino,
				money       as monto; 

-- Definicion de retorno
DEFINE 	vscodret 				char(5);
DEFINE  vsmensaje_respuesta     char(150);
DEFINE	vsnombre_file			char  (50); 
DEFINE	vsbcoorigen		        char  (3); 
DEFINE	vsbcodestino		    char  (3); 
DEFINE	vmmonto		            money;
DEFINE  visqlerr				integer;
	
BEGIN
	ON exception SET visqlerr
		
		LET vscodret = vsCodRet;
		
		RETURN 	TRIM(NVL(vscodret, '')), 
				TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
				TRIM(NVL(vsnombre_file, '')),			
				TRIM(NVL(vsbcoorigen, '')),		
				TRIM(NVL(vsbcodestino, '')),			
				NVL(vmmonto,0); 
	
	end exception;
	
--set debug file to "/informix/mgap/sp_transfer_msettlement.out";
--trace on;

-- Inicializacion de retorno
LET vscodret            = '00000';
LET vsmensaje_respuesta = '';
LET	vsnombre_file		= '';
LET	vsbcoorigen     	= '';
LET	vsbcodestino	    = '';
LET	vmmonto		        = 0;


IF  pdfechaini > pdfechafin  THEN
		LET vscodret = '00001';
		LET vsmensaje_respuesta = 'Fecha Inicial no puede ser mayor a la Final';
        RETURN 	
		        TRIM(NVL(vscodret, '')), 
				TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
				TRIM(NVL(vsnombre_file, '')),			
				TRIM(NVL(vsbcoorigen, '')),		
				TRIM(NVL(vsbcodestino, '')),			
				NVL(vmmonto,0); 
END IF;


IF ((psbcoorigen = '' OR psbcoorigen IS NULL) AND (psbcodestino = '' OR psbcodestino IS NULL ) ) THEN
		
		SET  ISOLATION TO DIRTY READ;  
		FOREACH cusor1 with hold FOR   -- GENERAL 
		
		
		    SELECT SKIP pRegistros FIRST pRecuperacion	nombrearchivo,id_banco_origen,id_banco_destino,monto  	 
            INTO    vsnombre_file, vsbcoorigen, vsbcodestino, vmmonto 
            FROM    bditransfer:tf_settlement
            WHERE 	fech_alt::DATE BETWEEN pdfechaini AND pdfechafin			
 
        RETURN 	
		        TRIM(NVL(vscodret, '')), 
				TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
				TRIM(NVL(vsnombre_file, '')),			
				TRIM(NVL(vsbcoorigen, '')),		
				TRIM(NVL(vsbcodestino, '')),			
				NVL(vmmonto,0)	
				WITH RESUME;

		END FOREACH;
	

ELSE  -- ESPECÃFICA  

        SET  ISOLATION TO DIRTY READ;  
        FOREACH cusor1 with hold FOR   
		
	        SELECT 	SKIP pRegistros FIRST pRecuperacion nombrearchivo,id_banco_origen,id_banco_destino,monto  	 
            INTO    vsnombre_file, vsbcoorigen, vsbcodestino, vmmonto 
            FROM    bditransfer:tf_settlement
            WHERE 	fech_alt::DATE BETWEEN pdfechaini AND pdfechafin
            AND     id_banco_origen  = psbcoorigen 
            AND 	id_banco_destino = psbcodestino            	
					
			RETURN 	
		        TRIM(NVL(vscodret, '')), 
				TRIM(UPPER(NVL(vsmensaje_respuesta, ''))), 
				TRIM(NVL(vsnombre_file, '')),			
				TRIM(NVL(vsbcoorigen, '')),		
				TRIM(NVL(vsbcodestino, '')),			
				NVL(vmmonto,0)
				WITH RESUME;

		END FOREACH;

END IF;


END
END PROCEDURE
DOCUMENT
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 27/02/2017',
'MODULO: OPERACIONES',
'DESCRIPCION: Se colona SPL bditransfer:sp_transfer_msettlement para el tratado de paginaciÃ³n.',
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 23/03/2017',
'DESCRIPCION: Se modifica SPL para eliminar ordenamiento.',
'BD: bditransfer';

CREATE PROCEDURE "informix".sp_transfer_msettlement2_totales (
					pdfechaini   date,
					pdfechafin   date,
					psbcoorigen  char(3),
					psbcodestino char(3)
					)
		RETURNING CHAR (5) AS codret, 
				INTEGER AS num_registros; 

-- Definicion de retorno
DEFINE 	vscodret 				CHAR(5);
DEFINE  vsmensaje_respuesta     CHAR(150);
DEFINE	vsnombre_file			CHAR  (50); 
DEFINE	vsbcoorigen		        CHAR  (3); 
DEFINE	vsbcodestino		    CHAR  (3); 
DEFINE	vmmonto		            MONEY;
DEFINE  visqlerr				INTEGER;

DEFINE  iNumRegistros           INTEGER;
	
BEGIN
	ON exception SET visqlerr
		
		LET vscodret = vsCodRet;
		
		RETURN 	TRIM(NVL(vscodret, '')), NVL(iNumRegistros,0); 
	
	end exception;
	
--set debug file to "/informix/mgap/sp_transfer_msettlement.out";
--trace on;

-- Inicializacion de retorno
LET vscodret            = '00000';
LET vsmensaje_respuesta = '';
LET	vsnombre_file		= '';
LET	vsbcoorigen     	= '';
LET	vsbcodestino	    = '';
LET	vmmonto		        = 0;
LET iNumRegistros       = 0;


IF  pdfechaini > pdfechafin  THEN
		LET vscodret = '00001';
		LET vsmensaje_respuesta = 'Fecha Inicial no puede ser mayor a la Final';
        RETURN TRIM(NVL(vscodret, '')), NVL(iNumRegistros,0); 
END IF;


IF ((psbcoorigen = '' OR psbcoorigen IS NULL) AND (psbcodestino = '' OR psbcodestino IS NULL ) ) THEN
		
		SET  ISOLATION TO DIRTY READ;  
		--FOREACH cusor1 with hold FOR   -- GENERAL 
		
		
		    SELECT 	COUNT(*)  	 
            INTO    iNumRegistros
            FROM    bditransfer:tf_settlement
            WHERE 	fech_alt::DATE BETWEEN pdfechaini AND pdfechafin;
			--ORDER BY 1,2,3 
 
        RETURN TRIM(NVL(vscodret, '')), NVL(iNumRegistros,0); 

		--END FOREACH;
	

ELSE  -- ESPECÃFICA  

        SET  ISOLATION TO DIRTY READ;  
        --FOREACH cusor1 with hold FOR   
		
	        SELECT 	COUNT(*)  	 
            INTO    iNumRegistros
            FROM    bditransfer:tf_settlement
            WHERE 	fech_alt::DATE BETWEEN pdfechaini AND pdfechafin
            AND     id_banco_origen  = psbcoorigen 
            AND 	id_banco_destino = psbcodestino;
            --ORDER BY 1,2,3			
					
			 RETURN TRIM(NVL(vscodret, '')), NVL(iNumRegistros,0); 

		--END FOREACH;

END IF;


END
END PROCEDURE
DOCUMENT
'AUTOR: Miguel Huitzil Cuachayo',
'FECHA: 27/02/2017',
'MODULO: OPERACIONES',
'DESCRIPCION: Se realiza la clonaciÃ³n del SPL bditransfer:sp_transfer_msettlement para consultar el nÃºmero total de registros.',
'BD: bditransfer';

CREATE PROCEDURE "informix".sp_generaarch_transfer(pNombrearch char(50))
RETURNING  CHAR(5) AS CodRetorno;



--DECLARACION DE VARIABLES
DEFINE viSqlError INTEGER;
DEFINE vsCodRetorno       CHAR (5);
DEFINE cSQL1			  CHAR(500);
DEFINE cSQL				  CHAR(500);
DEFINE vsRutaArchRep	  CHAR(150);


--INICIALIZACION DE VARIABLES
LET viSqlError = 0;
LET vsCodRetorno = '00000';
LET cSQL1 = ' ';
LET cSQL = ' ';
LET vsRutaArchRep = ' ';

--SET DEBUG FILE TO "/informix/ragomez/sp_generaarch_transfer_pba.out";
--TRACE ON;
BEGIN

	ON EXCEPTION SET viSqlError
		IF (viSqlError != 0) THEN
			LET vsCodRetorno = viSqlError;
			RETURN vsCodRetorno;
		END IF;
	END EXCEPTION;

	--Directiva para lectura de tablas bloqueadas.
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;

	IF (pNombrearch is null) or (pNombrearch = '') THEN
		LET vsCodRetorno = '00042';
		RETURN vsCodRetorno;
	END IF;

	SELECT LIMIT 1 TRIM(VALOR)||'/'
	INTO vsRutaArchRep FROM bdimnsj:"informix".mnsj_param
	WHERE cod_param = '3';

	IF vsRutaArchRep <> ' ' THEN

		LET cSQL1 = 'echo "UNLOAD TO '||trim(vsRutaArchRep)||TRIM(pNombrearch)||' delimiter '' '' SELECT {+INDEX(mnsj_procesos,inx_mnsjsuscpaso)} linea from "informix".mnsj_susc_paso ORDER BY secuencial" >'||TRIM(vsRutaArchRep)||'Ejecuta_archivo.sql';
		SYSTEM cSQL1;

		LET cSQL='dbaccess bditransfer '||trim(vsRutaArchRep)||'Ejecuta_archivo.sql';
		System cSQL;
		
			LET cSQL = '' ;
			LET cSQL = 'zip /'||trim(vsRutaArchRep)||TRIM(pNombrearch)||'.zip '||'-P 12345 /'||TRIM(vsRutaArchRep)||TRIM(pNombrearch);
			SYSTEM cSQL ;

	ELSE
		LET vsCodRetorno = '00043';
		RETURN vsCodRetorno;
	END IF;


RETURN vsCodRetorno;

END;
END PROCEDURE;