CREATE PROCEDURE "informix".sp_consultarcorreccionesdatoscte(pFechaInicial CHAR(10), pFechaFinal CHAR(10),p_NumCte CHAR(20), p_Tipo CHAR(1))
RETURNING
    CHAR (5)   AS  Cod_Ret,
	CHAR (26)  AS NumCte,
	CHAR (20)  AS Fecha,
	CHAR (13)  AS Rfc_Orig,
	CHAR (100) AS Nom_Ant,
	CHAR (13)  AS Rfc_Nvo,
	CHAR (100) AS Nom_Nvo,
	CHAR (8)   AS User_insert;

	--declaracion de variables
	DEFINE cCod_ret                 CHAR(5);
    DEFINE iSqlErr                  INTEGER;
    DEFINE iSamErr                  INTEGER;
	DEFINE cNumCte                  CHAR(20);
	DEFINE dFecha			        DATE;
	DEFINE cRfc_orig			    CHAR(13);
	DEFINE cNombre1_orig			CHAR(26);
	DEFINE cNombre2_orig			CHAR(26);
	DEFINE cApell_paterno_orig		CHAR(26);
	DEFINE cApell_materno_orig		CHAR(26);
	DEFINE cRfc_nvo			        CHAR(13);
	DEFINE cNombre1_nvo	            CHAR(26);
	DEFINE cNombre2_nvo		        CHAR(26);
	DEFINE cApell_paterno_nvo		CHAR(26);
	DEFINE cApell_materno_nvo		CHAR(26);
	DEFINE cNomCompletoAnterior     CHAR(100);
	DEFINE cNomCompletoActual 		CHAR(100);
	DEFINE cUser_insert				CHAR(8);

	--incilizacion de variables
	LET cNomCompletoAnterior        ="";
	LET cNomCompletoActual          = "";
	LET cCod_ret                    = '00000';
	LET cNumCte                     = "";
	LET dFecha				        = "";
	LET cRfc_orig	                = "";
	LET cNombre1_orig			    = "";
	LET cNombre2_orig			    = "";
	LET cApell_paterno_orig	        = "";
	LET cApell_materno_orig	        = "";
	LET cRfc_nvo				    = "";
	LET cNombre1_nvo			    = "";
	LET cNombre2_nvo			    = "";
	LET cApell_paterno_nvo	        = "";
	LET cApell_materno_nvo		    = "";
	LET cUser_insert				= "";

BEGIN
    ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
            LET cCod_ret = iSqlErr;
        END IF;
        RETURN cCod_ret, NULL, NULL, NULL, NULL, NULL, NULL, NULL;
    END EXCEPTION;

    --SET DEBUG FILE TO "/tmp/sp_ConsultarCambiosNomCtasFechas.out";
    --TRACE ON;

	IF (p_Tipo="") OR (p_Tipo IS NULL) THEN
		RETURN '00001', NULL, NULL, NULL, NULL, NULL, NULL, NULL; --Faltan parametros
	END IF;
	IF p_Tipo=1 THEN

		IF (p_NumCte IS NULL) OR (p_NumCte = "") THEN --valida que el numero de cliente no sea nulo
	            RETURN '00001', NULL, NULL, NULL, NULL, NULL, NULL, NULL; --Faltan parametros
		ELSE
		    --Consulta las correcciones de los datos del numero de cliente ingresado como paramentro
	        SELECT numcte,fecha_insert, rfc_orig, nombre1_orig, nombre2_orig, apell_paterno_orig, apell_materno_orig, rfc_nvo,
		           nombre1_nvo, nombre2_nvo, apell_paterno_nvo, apell_materno_nvo,user_insert
		    INTO   cNumCte,dFecha,cRfc_orig, cNombre1_orig,cNombre2_orig, cApell_paterno_orig, cApell_materno_orig,cRfc_nvo,
			       cNombre1_nvo, cNombre2_nvo, cApell_paterno_nvo, cApell_materno_nvo, cUser_insert
	        FROM  bdinteg: si_cte_bitacora
		    WHERE  numcte = p_NumCte AND secuencia IN (SELECT MAX(secuencia) FROM bdinteg: si_cte_bitacora WHERE numcte = p_NumCte);

	        --Forma la cadena con los nombres y apellidos del cliente
		    LET cNomCompletoAnterior = TRIM(cNombre1_orig) || ' ' || TRIM(cNombre2_orig) || ' ' || TRIM (cApell_paterno_orig) || ' ' || TRIM(cApell_materno_orig);
		    LET cNomCompletoActual = TRIM(cNombre1_nvo) || ' ' || TRIM(cNombre2_nvo) || ' ' || TRIM (cApell_paterno_nvo) || ' ' || TRIM(cApell_materno_nvo);
		END IF;
		        --Regresa valores obtenidos
	            RETURN cCod_ret,cNumCte,dFecha,cRfc_orig, cNomCompletoAnterior,cRfc_nvo, cNomCompletoActual,cUser_insert WITH RESUME;
		END IF;

	IF p_Tipo= 2 THEN
		--Valida que las los parametros recibidos en fecha incial y fecha final, no sean nulos.
		IF (pFechaInicial IS NULL) OR (pFechaInicial = "") or (pFechaFinal IS NULL) OR (pFechaFinal="") THEN
		    RETURN '0001', NULL, NULL, NULL, NULL, NULL, NULL,NULL;
		ELSE
			FOREACH --Iicia un ciclo donde obtiene los datos de clientes  que se han corregido  durande el periodo de tiempo comprendido en el rango entre fecha unicial y fecha final
				 SELECT numcte, fecha_insert, rfc_orig, nombre1_orig, nombre2_orig, apell_paterno_orig, apell_materno_orig, rfc_nvo,
						nombre1_nvo, nombre2_nvo, apell_paterno_nvo, apell_materno_nvo,user_insert
				 INTO   cNumCte,dFecha,cRfc_orig, cNombre1_orig,cNombre2_orig, cApell_paterno_orig, cApell_materno_orig,cRfc_nvo,
						cNombre1_nvo, cNombre2_nvo, cApell_paterno_nvo, cApell_materno_nvo,cUser_insert
				 FROM   bdinteg: si_cte_bitacora
				 WHERE fecha_insert BETWEEN  pFechaInicial AND  pFechaFinal
				 ORDER BY fecha_insert, numcte, secuencia

				 --Forma la cadena con los nombres y apellidos del cliente

				 LET cNomCompletoAnterior = TRIM(cNombre1_orig) || ' ' || TRIM(cNombre2_orig) || ' ' || TRIM (cApell_paterno_orig) || ' ' || TRIM(cApell_materno_orig);
				 LET cNomCompletoActual = TRIM(cNombre1_nvo) || ' ' || TRIM(cNombre2_nvo) || ' ' || TRIM (cApell_paterno_nvo) || ' ' || TRIM(cApell_materno_nvo);
				 --regresa valores obtenidos
				 RETURN cCod_ret,cNumCte,dFecha,cRfc_orig, cNomCompletoAnterior,cRfc_nvo, cNomCompletoActual,cUser_insert WITH RESUME;
			END FOREACH;

		END IF;
	END IF;
END;
END PROCEDURE
DOCUMENT
    'DESCRIPCION: Realiza una consulta la tabla si_cte_bitacora, de los clientes a los que se les han actualizado sus datos durante un rango de fechas o la ultima corrección de los datos del cliente. ',
    'AUTOR: Cristian Valentina Aguilar',
    'FECHA: junio 2009',
    'VERSION: 20090626',
    'BD: BDINTEG',

	'CAMBIOS: Se modificaron las consultas, para que traigan tambien el user_insert, y lo regrese en los resultados',
	'MODIFICO: Cristian Valentina Aguilar',
	'FECHA: 20090818',
	'BD: BDINTEG';

CREATE PROCEDURE "informix".sp_loginusuario_bpi (pEmpresa char(3), pUsuario char(50), pPass char(50))
   returning char(5), char (20), char(26), char(26), char(26), char(26), smallint, integer, char(19);

--Modificó: Ramon Romero
--Fecha: 05/08/09
--Solicitó: Mauricio León
--Modificación: Se le agrego un parametro para devolver la fecha de último acceso
--Modificó: Javier Calderón Zazueta
--Fecha: 18/02/09
--Solicitó: Mauricio León
--Actividad: Permite realizar el log in de los usuarios de BPI
   
-- ***************************************************************************
-- Define variables
-- ***************************************************************************
    DEFINE cod_ret char(5);
    DEFINE sql_err integer ;
    DEFINE sNumCliente char (20);
    DEFINE iIdStatus smallint ;
    DEFINE sNombre1, sNombre2, sApellPaterno, sApellMaterno char (26);
	DEFINE iIdStatusToken integer;
	DEFINE fecPrimAcceso date;
	DEFINE fecUltAcceso char(19);

-- ***************************************************************************
-- Inicializa variables
-- ***************************************************************************
   LET cod_ret  = "000";
   LET sNumCliente  = '';
   LET iIdStatus = 0;
   LET sNombre1 = '';
   LET sNombre2  = '';
   LET sApellPaterno  = '';
   LET sApellMaterno  = '';
   LET iIdStatusToken = 0;
   LET fecUltAcceso = '';


  Set isolation to dirty read;

 --SET DEBUG FILE TO '/tmp/sp_loginusuario_bpi.out';
 --TRACE ON;


  BEGIN


   ON EXCEPTION SET sql_err
      IF sql_err <> 0 THEN
            let cod_ret = sql_err;
            RETURN cod_ret, sNumCliente, sNombre1, sNombre2, sApellPaterno, sApellMaterno, iIdStatus, iIdStatusToken, fecUltAcceso;
      END IF ;
   END EXCEPTION ;

        --Set explain file to '/tmp/bancaTiempo.out';
        IF EXISTS (SELECT numcte FROM bdinteg:si_bpiusuarios  WHERE empresa = pEmpresa AND usuario = pUsuario AND pass = pPass ) THEN

            SELECT usu.numcte, usu.id_status, si.nombre1, si.nombre2, si.apell_paterno, si.apell_materno, id_status_token, usu.fec_primer_acceso, 
			CASE WHEN usu.f_ultimo_acceso IS NULL THEN substring (current::varchar(23) from 1 for 19)
            ELSE substring (usu.f_ultimo_acceso::varchar(23)from 1 for 19)
            END f_ultimo_acceso
            INTO sNumCliente,  iIdStatus, sNombre1, sNombre2, sApellPaterno, sApellMaterno, iIdStatusToken, fecPrimAcceso, fecUltAcceso
			FROM bdinteg:si_bpiusuarios usu
            INNER JOIN bdinteg:si_cliente si ON si.numcte = usu.numcte
            AND usu.empresa = pEmpresa
            AND usu.usuario = pUsuario
            AND usu.pass = pPass
			LEFT JOIN bdinteg:si_bpitoken tk ON tk.num_cliente = usu.numcte
			AND tk.empresa = pEmpresa;

			--Modificó: Héctor Bojórquez
			--Fecha: 20/07/09
			--Solicitó: 
			--Se agregó validación del status de logueo para que se actualize la fecha del último acceso solamente cuando el proceso de logueo del usuario
			--se haya realizado correctamente, es decir, cuando el campo id_status de la tabla bdinteg:si_bpiusuarios sea igual a 30.
			
			IF iIdStatus = 30 THEN
				UPDATE bdinteg:si_bpiusuarios SET f_ultimo_acceso = CURRENT  WHERE numcte = sNumCliente;
			END IF;	
			
			IF fecPrimAcceso IS NULL THEN
				UPDATE bdinteg:si_bpiusuarios SET fec_primer_acceso = CURRENT  WHERE numcte = sNumCliente;
			END IF;
						
			--SELECT id_status_token INTO iIdStatusToken FROM si_bpitoken WHERE empresa = pEmpresa AND num_cliente = sNumCliente;

                LET cod_ret = '000';  -- Sesion iniciada

        ELSE

                LET cod_ret = '002';  -- Usuario y/o Contraseña incorrecta

        END IF ;

   RETURN cod_ret, sNumCliente, sNombre1, sNombre2, sApellPaterno, sApellMaterno, iIdStatus, iIdStatusToken, fecUltAcceso;

END

END PROCEDURE ;