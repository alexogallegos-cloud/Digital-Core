CREATE PROCEDURE "informix".sp_consultareestructuravencidos(pVencido_min integer, pVencido_max integer, pImporte_min decimal(18,2), 
																	pImporte_max decimal(18,2), pSituacion CHAR(7), pCausa SMALLINT,
																	pFecha_consulta DATE)
RETURNING 	CHAR(5)  AS codigo_retorno,
			CHAR(20) AS Cliente,
			CHAR(20) AS Credito,
			CHAR(20) AS Cuenta,
			CHAR(20) AS Ciudad,
			CHAR(20) AS Estado,
			CHAR(13) AS Celular,
			CHAR(50) AS nombre1,
			CHAR(50) AS nombre2,
			CHAR(50) AS apell_pat,
			CHAR(50) AS apell_mat,
			DECIMAL(18,2) AS dPagoMin;

---DECLARACIONES
DEFINE cCodRet        	CHAR(5); 
DEFINE iSqlErr      	INTEGER;
DEFINE cCredito			CHAR(20);
DEFINE cCliente			CHAR(20);
DEFINE cCiudad			CHAR(20);
DEFINE cEstado			CHAR(20);
DEFINE cNombre			CHAR(110);
DEFINE cCelular			CHAR(13);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cApellPat		CHAR(26);
DEFINE cApellMat		CHAR(26);
DEFINE dPagoMin			DECIMAL(18,2);
DEFINE cNumCta			CHAR(20);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "000000";
LET cCredito			= '';
LET cCliente			= '';
LET cCiudad				= '';
LET cEstado				= '';
LET cNombre				= '';
LET cCelular			= '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET cCelular			= '';
LET dPagoMin   			= 0;
LET cNumCta				= '';

BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    RETURN cCodRet, nvl(cCliente,''), nvl(cCredito,''), nvl(cNumCta,''), nvl(cCiudad,''), nvl(cEstado,''),  nvl(cCelular,''),  nvl(cNombre1,''), 
					nvl(cNombre2,''), nvl(cApellPat,''), nvl(cApellMat,''), nvl(dPagoMin,0);
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_consultareestructuravencidos.out';
--TRACE ON;


	IF pVencido_min IS NULL OR pVencido_max IS NULL OR pImporte_min IS NULL OR pImporte_max IS NULL OR 
	pSituacion IS NULL OR pCausa IS NULL OR pFecha_consulta IS NULL THEN
		LET cCodRet = '00001';  --Parametros no validos
		RETURN cCodRet, nvl(cCliente,''), nvl(cCredito,''), nvl(cNumCta,''), nvl(cCiudad,''), nvl(cEstado,''),  nvl(cCelular,''),  nvl(cNombre1,''), 
					nvl(cNombre2,''), nvl(cApellPat,''), nvl(cApellMat,''), nvl(dPagoMin,0);	
	END IF;

	IF pVencido_min < 0 OR pVencido_max < 0 OR pImporte_min < 0 OR pImporte_max < 0 THEN
		LET cCodRet = '00002';  -- Los parametros numericos deben ser positivos
		RETURN cCodRet, nvl(cCliente,''), nvl(cCredito,''), nvl(cNumCta,''), nvl(cCiudad,''), nvl(cEstado,''),  nvl(cCelular,''),  nvl(cNombre1,''), 
					nvl(cNombre2,''), nvl(cApellPat,''), nvl(cApellMat,''), nvl(dPagoMin,0);	
	END IF;

SET LOCK MODE TO WAIT 3;
SET ISOLATION DIRTY READ;
	
	FOREACH 
	
		SELECT  cliente, credito, cuenta, ciudad, estado, t_celular, nombre1, nombre2, apell_paterno, apell_materno,  pago_min
		INTO cCliente, cCredito, cNumCta, cCiudad, cEstado, cCelular, cNombre1, cNombre2, cApellPat, cApellMat, dPagoMin
		FROM bdicobranza:"informix".cb_info_administrativa
		WHERE num_campania =11	
		--AND situacion= CASE WHEN pSituacion <> "" THEN pSituacion ELSE situacion END  --quitar para que muestre todos aunque no tengan Sit. y Causa 
		--AND causa = CASE WHEN pCausa <> 0 THEN pCausa ELSE causa END
		AND pago_venc >= pVencido_min AND pago_venc <= pVencido_max
		AND pago_min >= pImporte_min AND pago_min <= pImporte_max				
		AND NVL(fecha_ejecucion,'01/01/1900') = pFecha_consulta
		
		RETURN cCodRet, nvl(cCliente,''), nvl(cCredito,''), nvl(cNumCta,''), nvl(cCiudad,''), nvl(cEstado,''),  nvl(cCelular,''),  nvl(cNombre1,''), 
					nvl(cNombre2,''), nvl(cApellPat,''), nvl(cApellMat,''), nvl(dPagoMin,0) WITH RESUME;
		
	END FOREACH;	
	
	IF DBINFO("sqlca.sqlerrd2") = 0 THEN
		LET cCodRet= '00003';  --No hay informacion
		RETURN cCodRet, nvl(cCliente,''), nvl(cCredito,''), nvl(cNumCta,''), nvl(cCiudad,''), nvl(cEstado,''),  nvl(cCelular,''),  nvl(cNombre1,''), 
					nvl(cNombre2,''), nvl(cApellPat,''), nvl(cApellMat,''), nvl(dPagoMin,0);
    END IF;
		
END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Se realiza procedimiento para la obtencion de la informacion de campaña 17 de la tabla cb_info_administrativa',
'AUTOR : Abigail Vasavilbazo Cañedo ',
'FECHA : 10/05/2011',
'BD    : BDICOBRANZA',
'Version: 20110523.1254',
'20110922 Modificar query principal. Autor: Marco A. Campos';

CREATE PROCEDURE "informix".sp_cat_obtentpscampania()
		RETURNING CHAR(6),SMALLINT,CHAR(50);

	DEFINE cCodRet 			CHAR(6);
	DEFINE iCont			INTEGER;
	DEFINE iSqlErr 			INTEGER;
	DEFINE sTipoCampania		SMALLINT;
	DEFINE cDescripcion		CHAR(50);

	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET icont=0;
	LET sTipoCampania = 0;
	LET cDescripcion = '';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/hector/sp_cat_obtentpscampania.out';
	--TRACE ON;
	--------------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cDescripcion = 'Error de Informix';
			RETURN cCodRet,sTipoCampania,cDescripcion;
		END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT num_campania, descripcion
			INTO  sTipoCampania,cDescripcion
			FROM bdicobranza:"informix".cb_cat_campania
			WHERE modulo_cob=3
			LET icont=icont+1;
            RETURN cCodret,sTipoCampania,cDescripcion WITH RESUME;
		END FOREACH;

        IF icont == 0 THEN
			LET cCodret='000001';
			LET cDescripcion='No hay Informacion en la tabla';
            RETURN cCodret,sTipoCampania,cDescripcion WITH RESUME;
        END IF;

	END;
END PROCEDURE

DOCUMENT
'AUTOR       : Héctor Manuel Bojorquez Ruelas',
'DESCRIPCION : Devuelve un listado de las Campañas existentes en la tabla cb_cat_campania',
'FECHA       : 30 de Septiembre de 2010',
'MODIFICA    : Maria Elena Angulo Aispuro',
'DESCRIPCION : Se actualiza para agregar a la consulta el filtro por modulo_cob que se igual a 3',
'FECHA       : 08 de junio de 2011',
'VERSION     : 20110608.1152',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cat_modstadocte(pOpHabiInha SMALLINT, --Bandera de opciones 1.- Habilitar,  2.- Inhabilitar
												pUsuario CHAR(8),
												pEmpresa CHAR(3),
												pCampania CHAR(1),
												pCliente CHAR(20),
												pPagosVencMin INTEGER,
												pPagosVencMax INTEGER,
												pMontoMin DECIMAL(18,2),
												pMontoMax DECIMAL(18,2),
												pEstado  CHAR (2),
												pNumCiudad CHAR (3),
												pRegion   SMALLINT ,
												pSitEsp   CHAR (1),
												pCausa	  SMALLINT,
												pStatus   CHAR(2),
												pTipoMov  INTEGER,
												pTipoResul SMALLINT,
												pExepcion  CHAR(5),
												pRegistros INTEGER,
												pLogica		SMALLINT,
												pSaldos		INTEGER)
		RETURNING   
					CHAR(6) AS Codigo,	--codret
					CHAR(80) AS Descripcioncodigo, --Descripcion del codigo
					INTEGER AS Total; --Total de registros afectados
	
		
	--Se definen las variables.
	DEFINE cCodRet 			CHAR(6);
	DEFINE cCodRet2			CHAR(6);
	DEFINE iSqlErr 			INTEGER; 
	DEFINE cDesCod			CHAR(80);
	DEFINE cMensaje         CHAR(80);
	DEFINE cNumCte          CHAR(20);
	DEFINE cNum_credito 	CHAR(20);
	DEFINE cEstado 			CHAR(30);
	DEFINE dPago_Minimo 	DECIMAL(18,2);
	DEFINE dSaldo_Total 	DECIMAL(18,2);
	DEFINE iTotal 			INTEGER;
	DEFINE CCobranza		CHAR(1);
	--Se agregan campos nuevos del procedimiento sp_cat_consulta_ctes
	DEFINE sTpoLogica		SMALLINT;
	DEFINE cTarjeta			CHAR(20);
	DEFINE cNombre1       	CHAR(26);
	DEFINE cNombre2         CHAR(26);
	DEFINE cApell_pat       CHAR(26);
	DEFINE cApell_mat       CHAR(26);
	DEFINE cSexo			CHAR(1);
	DEFINE cEdoCivil		CHAR(1);
	DEFINE dtFechaUltPago   DATE;
	DEFINE dMontoUltPag     DECIMAL(18,2);
	DEFINE dCapVdoExig      DECIMAL(18,2);
	DEFINE dPagoMinSinVdo   DECIMAL(14,2);
	DEFINE dtFechaRep       DATE;
	DEFINE dFechaGestion    DATE;
	DEFINE OrigenGestion	INTEGER;
	
	-- Se inicializan las variables.
	LET cCodRet = '000000';
	LET cCodRet2='';
	LET iSqlErr = 0;
	LET cDesCod='PROCESO EXITOSO';
	LET cMensaje='';
	LET cNumCte='';
	LET cNum_credito='';
	LET cEstado='';
	LET dPago_Minimo=0;
	LET dSaldo_Total=0;
	LET iTotal=0;	
	LET CCobranza='';
	--Se agregan campos nuevos del procedimiento sp_cat_consulta_ctes
	LET sTpoLogica	=0;
	LET cTarjeta	='';	
	LET cNombre1='';
	LET cNombre2='';
	LET cApell_pat='';
	LET cApell_mat='';	
	LET cSexo		='';
	LET cEdoCivil 	='';
	LET dtFechaUltPago =DATE(1);
	LET dMontoUltPag =0;
	LET dCapVdoExig =0;
	LET dPagoMinSinVdo=0;
	LET dtFechaRep= DATE(1);
	LET dFechaGestion = DATE(1);
	LET OrigenGestion = 0;
	
	
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/home/sysifx/Malena/sp_cat_modstadocte.out';
	--TRACE ON;
	--------------------------------------------------------------------------
	
	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cDesCod='Error de Informix';
			RETURN cCodRet,cDesCod,itotal;
		END EXCEPTION;		
	
	SET ISOLATION TO DIRTY READ; -- Lectura de tablas bloqueadas.
	SET LOCK MODE TO WAIT 5;
	
	IF pOpHabiInha NOT IN (1,2) THEN
			LET cCodRet='000001';
			LET cDesCod='DEBE INGRESAR UNA OPCION DE 1.HABILITAR O 2.DESHABILITAR';
			RETURN cCodRet,cDesCod,itotal;
	END IF;
	FOREACH
	EXECUTE PROCEDURE bdicobranza:"informix".sp_cat_consulta_ctes(pEmpresa,pCampania,pCliente,pPagosVencMin,pPagosVencMax,pMontoMin,pMontoMax,pEstado,pNumCiudad,pRegion,pSitEsp,
	pCausa,pStatus,pTipoMov,pTipoResul,pExepcion,pRegistros,pLogica,pSaldos) 
	INTO cCodRet2,CCobranza,sTpoLogica,cNumCte,cNum_credito,cTarjeta,cEstado,cNombre1,cNombre2,cApell_pat,cApell_mat,cSexo,cEdoCivil,dPago_Minimo,iTotal,dSaldo_Total,
	dtFechaUltPago,dMontoUltPag,dCapVdoExig,dPagoMinSinVdo,dtFechaRep,dFechaGestion,OrigenGestion
											
			IF cCodRet2='000000' THEN 
					IF pOpHabiInha=1 THEN 
							IF pStatus IN ('IN','PR') THEN
								EXECUTE PROCEDURE bdicobranza:"informix".sp_cat_cambia_estatus_cte(cNumCte,'AC',pTipoMov,pCampania,pEmpresa,pUsuario)
								INTO cCodRet2,cMensaje;
								IF cCodRet2 <> 0 THEN
									LET cCodRet=cCodRet2;
									LET cDesCod=cMensaje;
									RETURN cCodRet,cDesCod,itotal;	
								END IF;
							END IF;												
					ELIF pOpHabiInha=2 THEN 	
							IF pStatus = 'AC' THEN
								EXECUTE PROCEDURE bdicobranza:"informix".sp_cat_cambia_estatus_cte(cNumCte,'IN',pTipoMov,pCampania,pEmpresa,pUsuario)
								INTO cCodRet2,cMensaje;
								IF cCodRet2 <> 0 THEN
									LET cCodRet=cCodRet2;
									LET cDesCod=cMensaje;									
									RETURN cCodRet,cDesCod,itotal;	
								END IF;
							END IF;
					END IF;
			ELIF cCodRet2='105008' THEN
					LET cCodRet='000002';
					LET cDesCod='NO HAY REGISTROS PARA EL CAMBIO DE ESTATUS';			
			ELSE 
					LET cCodRet= cCodRet2;
					LET cDesCod='OCURRIO UN ERROR EN LA EJECUCION DEL sp_cat_consulta_ctes';			
			END IF;
	END FOREACH;
		RETURN cCodRet,cDesCod,itotal;	
	END;
END PROCEDURE
DOCUMENT
'AUTOR       : Maria Elena Angulo Aispuro',
'DESCRIPCION : Se actualiza el estatus del cliente para habilitar o inhabilitarlo para que se les realice cobranza',
'FECHA       : 10 de Noviembre de 2010',
'VERSION     : 20101110.1047',
'MODIFICÓ       : Maria Elena Angulo Aispuro',
'CAMBIO: Se actualiza el llamado al procedimiento sp_cat_consulta_ctes, debido a que el proceso devuelve mas campos correspondientes a los saldos',
'FECHA       : 26 de Agosto de 2011',
'VERSION     : 20101110.1047',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_ctbcpl_gen_arcctesexcluidos(pEmpresa  CHAR(3),
                                                           pFecha_ex DATE, 
														   pTipCobranza char(1) )
RETURNING CHAR(6) AS codigo_retorno;
          
DEFINE cCodRet             CHAR(6); 
DEFINE cMensajeRet         CHAR(80);
DEFINE iSqlErr             INTEGER;
DEFINE iIsamErr            INTEGER;
DEFINE cErrorInfo          CHAR(80);
DEFINE cSql                CHAR(2204);
DEFINE cNombreArchivo1     CHAR(50);
DEFINE cNombreArchivo      CHAR(50);
DEFINE cRuta               CHAR(100);
DEFINE iNumreg             INTEGER;
DEFINE iDatos              INTEGER;
DEFINE cEmpresa            CHAR(3);
DEFINE cNombre             CHAR(100);
DEFINE cSeparador          CHAR(1);
DEFINE cValor_status       CHAR(20);
DEFINE cHora               CHAR(8);
DEFINE cUsuario            CHAR(8);
DEFINE cSql1               CHAR(100);
DEFINE cSql2               CHAR(2004);
DEFINE cSql3               CHAR(100);
DEFINE dDia                DATE;
DEFINE cFechaGenArchivo    CHAR(8);
DEFINE cCodRetIB           CHAR(6);
DEFINE cMensaje            CHAR(80);

LET iSqlErr                = 0;
LET iIsamErr               = 0;
LET cErrorInfo             = "";
LET cCodRet                = "000000";
LET cRuta                  = "";
LET cNombreArchivo1        = "";
LET cNombreArchivo         = "";
LET iNumreg                = 0;
LET iDatos                 = 0;
LET cEmpresa               = "";
LET cNombre                = '';
LET cSeparador             = '';
LET cSql                   = "";
LET cValor_status          = "";
LET cHora                  = "";
LET dDia                   = DATE(1);
LET cMensajeRet            = 'PROCESO EXITOSO';
LET cUsuario               = USER;
LET cSql1                  = "";
LET cSql2                  = "";
LET cSql3                  = "";
LET cFechaGenArchivo       = "";
LET cCodRetIB              = "000000";
LET cMensaje               = "";

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
    IF iSqlErr != 0 THEN
        LET cCodRet     = iSqlErr;
        LET cMensajeRet = cErrorInfo;
        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensajeRet,"02")
                     INTO cCodRetIB;
       RETURN cCodRet; 
    END IF;
END EXCEPTION;

SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO '/home/syscobra/cat/envios/sp_ctbcpl_gen_arcctesexcluidos.out';
--TRACE ON;

-- Inserta bitacora de procesos
EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029","","","01")
             INTO cCodRetIB;
        
-- Validacion de los datos de entrada
IF NVL(pEmpresa,"") = "" THEN
    LET cCodRet     = "104007";
    SELECT descripcion
      INTO cMensaje
      FROM bdicobranza:"informix".cb_errores
     WHERE origen       = 3
       AND codigo_error = cCodRet; 

     IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
    RETURN cCodRet;
END IF;
    
SELECT empresa
  INTO cEmpresa 
  FROM bdinteg:si_empresas
 WHERE empresa = pEmpresa;

IF NVL(cEmpresa,"")= "" then
    LET cCodRet = "104002";
    SELECT descripcion
      INTO cMensaje
      FROM bdicobranza:"informix".cb_errores
     WHERE origen       = 3
       AND codigo_error = cCodRet; 

     IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
    RETURN cCodRet;
END IF;

IF NVL(pFecha_ex,"") = "" THEN
    LET cCodRet     = "104008";
    SELECT descripcion
      INTO cMensaje
      FROM bdicobranza:"informix".cb_errores
     WHERE origen       = 3
       AND codigo_error = cCodRet; 

     IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
    RETURN cCodRet;
END IF;

-- obtener la ruta donde se almacenara el archivo que sera enviado a buro de credito
SELECT valor_alfabetico 
  INTO cRuta
  FROM bdicobranza:cb_param_campania
 WHERE empresa         = pEmpresa
   AND tipo_campania   = '1'
   AND grupo_parametro = 'ARCHIVOS'
   AND num_parametro   = 3;

IF NVL(cRuta,"")    = "" THEN
    LET cCodRet     = "104005";
    SELECT descripcion
      INTO cMensaje
      FROM bdicobranza:"informix".cb_errores
     WHERE origen       = 3
       AND codigo_error = cCodRet; 

     IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                  INTO cCodRetIB;
    RETURN cCodRet;
END IF;

-- Se obtiene del nombre del archivo
SELECT valor_alfabetico 
  INTO cNombre
  FROM bdicobranza:cb_param_campania
 WHERE empresa         = pEmpresa
   AND tipo_campania   = '1'
   AND grupo_parametro = 'ARCHIVOS'
   AND num_parametro   = 5;

    IF NVL(cNombre,"") = "" THEN
        LET cCodRet = "104006";
     SELECT descripcion
       INTO cMensaje
       FROM bdicobranza:"informix".cb_errores
      WHERE origen       = 3
        AND codigo_error = cCodRet; 

     IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                     INTO cCodRetIB;
        RETURN cCodRet;
    END IF;

-- Se obtiene el separador de los campos
SELECT valor_alfabetico 
  INTO cSeparador
  FROM bdicobranza:cb_param_campania
 WHERE empresa         = pEmpresa
   AND tipo_campania   = '1'
   AND grupo_parametro = 'ARCHIVOS'
   AND num_parametro   = 2;
    
	IF NVL(cSeparador,"") = "" THEN
        LET cCodRet     = "104004";
     SELECT descripcion
       INTO cMensaje
       FROM bdicobranza:"informix".cb_errores
      WHERE origen       = 3
        AND codigo_error = cCodRet; 

        IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

        EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                     INTO cCodRetIB;
        RETURN cCodRet;
    END IF;
     
	LET cNombreArchivo1 = 'prueba.txt';
    LET cNombreArchivo  = TRIM(cNombre) || LPAD(TRIM(DAY(pFecha_ex)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(pFecha_ex)::CHAR(2)),2,'0') || YEAR(pFecha_ex) || '.txt';
   
FOREACH
     	SELECT trim(valor_alfabetico)
	      INTO cValor_status
		  FROM bdicobranza:cb_param_campania
		 WHERE empresa         = pEmpresa
		   AND tipo_campania   = '1'
		   AND grupo_parametro = 'STATARCHCE'
     
			SELECT COUNT (numcte)
			  INTO iNumreg
			  FROM bdicobranza:cb_cat_directorio_cte
			 WHERE status_cliente 		= cValor_status
			   AND fecha_modificacion   = pFecha_ex
			   AND tipo_cobranza  = pTipCobranza
		       AND empresa        = pEmpresa;

			LET cNombreArchivo1 = 'prueba.txt';
            LET cNombreArchivo  = TRIM(cNombre) || LPAD(TRIM(DAY(pFecha_ex)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(pFecha_ex)::CHAR(2)),2,'0') || YEAR(pFecha_ex) || '.txt';
   
			IF iNumreg = 0 THEN
				CONTINUE FOREACH;
			END IF;

			LET iDatos = iDatos + 1;

            -- para generar el archivo 
		    LET cSql1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM (cNombreArchivo1) || " DELIMITER '" || cSeparador || "'";
            
                LET cSql2 = " SELECT tipo_cobranza, numcte, "  
                        || " (select  ''||round(valor_numerico) FROM cb_param_campania WHERE  tipo_campania = 1 "
                        || "   AND grupo_parametro ='STATUSCTE'"
                        || "   AND TRIM(valor_alfabetico)=status_cliente) status_cliente, "
                        || " tipo_movto, "
                        || " fecha_modificacion "
                        || " FROM bdicobranza:cb_cat_directorio_cte "
						|| " WHERE "
						|| " tipo_cobranza  ='" ||pTipCobranza||  "' AND  status_cliente = '"||cValor_status||"' AND  fecha_modificacion = '"||pFecha_ex||"';";
						
			    						
						
            LET cSql3 = ' " > '|| TRIM(cRuta) || 'Ejecuta_ExcluidosCAT.sql';
            
            LET cSql1 = TRIM(cSql1);
            LET cSql3 = TRIM(cSql3);
            
            LET cSql = cSql1 || cSql2 || cSql3;
			
			SYSTEM cSQL;
			--Permiso para la creacion de archivo.
			LET cSQL = '' ;
			LET cSQL = 'chmod 666 ' || TRIM(cRuta) || 'Ejecuta_ExcluidosCAT.sql' ;
			LET cSQL = '' ;
			LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_ExcluidosCAT.sql';
			SYSTEM cSQL;
			
			LET cSql = "sed 's/"||cSeparador||"$//g' "|| TRIM(cRuta) || cNombreArchivo1 || " >> " || TRIM(cRuta) || cNombreArchivo;
            SYSTEM cSql;

			--Borra el archivo de control.
			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cRuta) || 'Ejecuta_ExcluidosCAT.sql';
			SYSTEM cSQL;

			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cRuta) || cNombreArchivo1;
			SYSTEM cSQL;
      ------------------------------------------------------------------------------------------------------------------------
	  LET cNombreArchivo1 = 'pruebaC.txt';    
	  LET cNombreArchivo  = TRIM(Replace(cNombre,'_','')) || LPAD(TRIM(DAY(pFecha_ex)::CHAR(2)),2,'0') || LPAD(TRIM(MONTH(pFecha_ex)::CHAR(2)),2,'0') || YEAR(pFecha_ex) || '.txt';
      LET cSql1 = 'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM (cNombreArchivo1) || " DELIMITER '" || cSeparador || "'";
            
                LET cSql2 = " SELECT a.tipo_cobranza, a.numcte, "  
                        || " (select  ''||round(valor_numerico) FROM cb_param_campania WHERE  tipo_campania = 1 "
                        || "   AND grupo_parametro ='STATUSCTE'"
                        || "   AND TRIM(valor_alfabetico)=a.status_cliente) status_cliente, "
                        || " a.tipo_movto, "
                        || " to_char(a.fecha_modificacion, '%Y-%m-%d'), (to_char(fecha_insert,'%Y-%m-')|| b.dia_corte ) fechacorte "
                        || " FROM bdicobranza:cb_cat_directorio_cte a, bdicred:sd_maecredanexo b  "
						|| " WHERE  a.empresa = b.empresa  and a.num_credito = b.num_credito and a.empresa = '001' and " 
						|| " a.tipo_cobranza  ='" ||pTipCobranza||  "' and a.status_cliente = '"||cValor_status||"' AND  a.fecha_modificacion = '"||pFecha_ex||"';";
						
            LET cSql3 = ' " > '|| TRIM(cRuta) || 'Ejecuta_ExcluidosCarteras.sql';
            
            LET cSql1 = TRIM(cSql1);
            LET cSql3 = TRIM(cSql3);
            
            LET cSql = cSql1 || cSql2 || cSql3;
			
			SYSTEM cSQL;
			--Permiso para la creacion de archivo.
			LET cSQL = '' ;
			LET cSQL = 'chmod 666 ' || TRIM(cRuta) || 'Ejecuta_ExcluidosCarteras.sql' ;
			LET cSQL = '' ;
			LET cSQL = 'dbaccess bdicobranza ' || TRIM(cRuta) || 'Ejecuta_ExcluidosCarteras.sql';
			SYSTEM cSQL;
			
			LET cSql = "sed 's/"||cSeparador||"$//g' "|| TRIM(cRuta) || cNombreArchivo1 || " >> " || TRIM(cRuta) || cNombreArchivo;
            SYSTEM cSql;

			--Borra el archivo de control.
			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cRuta) || 'Ejecuta_ExcluidosCarteras.sql';
			SYSTEM cSQL;

			LET cSQL = '' ;
			LET cSQL = 'rm ' || TRIM(cRuta) || cNombreArchivo1;
			SYSTEM cSQL;
END FOREACH;

-- Por si el archivo no  se genera 
IF iDatos = 0 THEN
    LET cCodRet = '104009';
    SELECT descripcion
      INTO cMensaje
      FROM bdicobranza:"informix".cb_errores
     WHERE origen       = 3
       AND codigo_error = cCodRet; 

     IF cMensaje IS NULL THEN LET cMensaje = ""; END IF;

    EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensaje,"02")
                 INTO cCodRetIB;
    RETURN cCodRet;
END IF;

EXECUTE PROCEDURE bdicobranza:"informix".sp_inserta_bitacora_cob(pEmpresa,"0029",cCodRet,cMensajeRet,"03")
             INTO cCodRetIB;

RETURN cCodRet;

END
END PROCEDURE
DOCUMENT 
'El SP genera un archivo que extrae información de los clientes excluidos de cobranza',
'AUTOR : Leonardo Arellano M.',
'FECHA : 01/OCTUBRE/2010',
'VERSION:201000927.1500',
'BD    : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_catobtenstpslogica()
		RETURNING CHAR(6),SMALLINT,CHAR(50);

	--Declaracion de variables
	DEFINE cCodRet 			CHAR(6);
	DEFINE iCont			INTEGER;
	DEFINE iSqlErr 			INTEGER;
	DEFINE sTipoLogica		SMALLINT;
	DEFINE cDescripcion		CHAR(50);

	--Inicializacion de variables
	LET cCodRet = '000000';
	LET iSqlErr = 0;
	LET icont=0;
	LET sTipoLogica = 0;
	LET cDescripcion = '';
	--------------------------------------------------------------------------
	--SET DEBUG FILE TO '/respaldosbd/Malena/sp_catobtenstpslogica.out';
	--TRACE ON;
	--------------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET iSqlErr
			LET cCodRet = iSqlErr;
			LET cDescripcion = 'Error de Informix';
			RETURN cCodRet,sTipoLogica,cDescripcion;
		END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

		FOREACH
			SELECT num_parametro,descripcion 
			INTO  sTipoLogica,cDescripcion
			FROM bdicobranza:"informix".cb_param_campania 
			WHERE grupo_parametro='LOGICA' 
			AND tipo_campania=1		
            RETURN cCodret,sTipoLogica,cDescripcion WITH RESUME;
		END FOREACH;

		LET iCont = dbinfo("sqlca.sqlerrd2");
		IF iCont = 0 THEN
			LET cCodRet='000001'; 
			LET cDescripcion='No Hay Datos';
			RETURN cCodRet,sTipoLogica,cDescripcion;	
		END IF;
	END;
END PROCEDURE

DOCUMENT
'AUTOR    : Maria Elena Angulo Aispuro',
'DESCRIPCION : Devuelve un listado de los diferentes tipos de logica.',
'FECHA       : 14 de junio de 2011',
'VERSION     : 20110614.1152',
'BD          : BDICOBRANZA';

CREATE PROCEDURE "informix".sp_cat_depura_cte_tel_inactivo()
RETURNING 	CHAR(5) AS CodigoRet;

---DECLARACIONES
DEFINE cCodRet        	CHAR(5); 
DEFINE iSqlErr      	INTEGER;
DEFINE cTel				CHAR(13);
DEFINE cNumCte			CHAR(20);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cTel				= '';
LET cNumCte				= '';

BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    RETURN cCodRet ;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_cat_depura_cte_tel_inactivo.out';
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION DIRTY READ;	
	
	FOREACH 		
		
		SELECT {+INDEX "informix".cb_telefonos idx_cons_telefono4)} DISTINCT(telefono), numcte
		INTO cTel, cNumCte
		FROM bdicobranza:cb_telefonos
		WHERE estatus= 'IN'
      AND fecha_insert >= '01-01-1900'  	
		
		IF EXISTS( SELECT 1 FROM bdicobranza:"informix".cb_telefonos WHERE numcte= cNumCte AND
					estatus <> 'IN' ) THEN
			CONTINUE FOREACH;			
		ELSE
			INSERT INTO bdisitesp:"informix".se_ctessitespcred (numcte, empresa, numcred, situacion, causa,
				cvesitesporigen,	 sucursal, tipomovto, nombreefectuo, usralta, fchalta, usrmodifica, fchmodifica)
			VALUES ( cNumCte, '001', '', 'T', 1, '', '', '', '', 'informix', CURRENT, '', '');
		END IF;
		
	END FOREACH;	
	
	RETURN cCodRet;
		
END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Marca los telefonos inactivo con situacion especial T causa 1',
'AUTOR : Abigail Vasavilbazo Cañedo ',
'FECHA : 08/06/2011',
'BD    : BDICOBRANZA',
'Version: 20110622.0914';

CREATE PROCEDURE "informix".sp_cat_depura_tel_inactivo()
RETURNING 	CHAR(5) AS CodigoRet;

---DECLARACIONES
DEFINE cCodRet        	CHAR(5); 
DEFINE iSqlErr      	INTEGER;
DEFINE cTel				CHAR(13);
DEFINE cNumcte    CHAR(20);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cTel				= '';
LET cNumcte = '';


BEGIN

ON EXCEPTION SET iSqlErr
    LET cCodRet= iSqlErr;
    RETURN cCodRet ;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_cat_depura_tel_inactivo.out';
--TRACE ON;
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

	FOREACH 		
    
    SELECT {+INDEX "informix".cb_telefonos idx_cons_telefono4)} DISTINCT(telefono)
		INTO cTel
		FROM bdicobranza:cb_telefonos
		WHERE estatus = 'AC'
     AND fecha_insert >= '01-01-1900'  	
     

		IF EXISTS( SELECT 1 FROM bdicobranza:"informix".cb_registro_llamadas a	INNER	JOIN 
					bdicobranza:"informix".cb_cat_tipo_resultado b ON (a.codigo_resultado = b.codigo_resultado) 
					WHERE a.telefono= cTel AND b.genera_inactivacion = 'V' AND a.veces_marcado >= b.num_marca_inactiva) 
					THEN

						UPDATE bdicobranza:"informix".cb_telefonos SET estatus = 'IN' WHERE telefono = TRIM(cTel);
	
		ELSE
			CONTINUE FOREACH;
		END IF;
		
	END FOREACH;	
	
	RETURN cCodRet;
		
END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Marca los telefonos como inactivos',
'AUTOR : Abigail Vasavilbazo Cañedo ',
'FECHA : 08/06/2011',
'BD    : BDICOBRANZA',
'Version: 20110608.1851';

CREATE PROCEDURE "informix".sp_generatelinactivos()
RETURNING 	CHAR(5) AS CodigoRet;

---DECLARACIONES
DEFINE cCodRet        		CHAR(5); 
DEFINE iSqlErr      		INTEGER;
DEFINE cTel					CHAR(13);
DEFINE cNumCte				CHAR(20);
DEFINE cFechaHoy			CHAR(10);
DEFINE cRuta				CHAR(100);
DEFINE cNombreCtes			CHAR(100);
DEFINE cNombreTels			CHAR(100);			
DEFINE cStatus				CHAR(2);
DEFINE cDescripcionStatus	CHAR(100);
DEFINE cDescTpoTel			CHAR(30);
DEFINE cDescripcionResult	CHAR(50);
DEFINE sTpoTel				SMALLINT;
DEFINE sNumMarcados			SMALLINT;
DEFINE cEstatus				CHAR(2); 
DEFINE sCodResultado		SMALLINT;
DEFINE vsSQL1 				CHAR(300);
DEFINE cSql3 				CHAR(900);
DEFINE vsSQL2				CHAR(300);
DEFINE cSql					CHAR(1500);
DEFINE DescContac			CHAR(14);
DEFINE cNombreTels2			CHAR(100);
DEFINE cNombreCtes2			CHAR(100);

---INICIALIZACIONES
LET iSqlErr             = 0;
LET cCodRet             = "00000";
LET cTel				= '';
LET cNumCte				= '';
LET cFechaHoy			= '';
LET  cRuta				= '';
LET cNombreCtes			= '';
LET cNombreTels			= '';	
LET cStatus				= '';
LET cDescripcionStatus	= '';
LET cDescTpoTel			= '';
LET cDescripcionResult	= '';
LET sTpoTel				= 0;
LET sNumMarcados		= 0;
LET cEstatus			= '';
LET sCodResultado		= 0;
LET vsSQL1  = '';
LET cSql	= '';
LET vsSQL2	= '';
LET cSql3	= '';
LET DescContac = '';
LET cNombreTels2	= '';
LET cNombreCtes2	= '';
		
BEGIN

ON EXCEPTION SET iSqlErr
	IF EXISTS (SELECT tabname  FROM sysmaster:"informix".systabnames where tabname = 'tmpctescat' and dbsname= 'bdicobranza') THEN
        DROP  TABLE bdicobranza:"informix".tmpctescat;
    END IF;
	
	IF EXISTS (SELECT tabname FROM sysmaster:"informix".systabnames where tabname = 'tmptelscat' and dbsname= 'bdicobranza') THEN
        DROP  TABLE bdicobranza:"informix".tmptelscat;
    END IF;
    LET cCodRet= iSqlErr;
    RETURN cCodRet ;
END EXCEPTION;

--SET DEBUG FILE TO '/tmp/sp_generatelinactivos.out';
--TRACE ON;

SET LOCK MODE TO WAIT 3;
SET ISOLATION DIRTY READ;	

	IF EXISTS (SELECT tabname FROM sysmaster:"informix".systabnames where tabname = 'tmpctescat' and dbsname= 'bdicobranza') THEN
        DROP  TABLE bdicobranza:"informix".tmpctescat;
    END IF;
	
	IF EXISTS (SELECT tabname FROM sysmaster:"informix".systabnames where tabname = 'tmptelscat' and dbsname= 'bdicobranza') THEN
        DROP  TABLE bdicobranza:"informix".tmptelscat;
    END IF;

	
	CREATE TABLE "informix".tmpctescat
	( cliente   CHAR(20),
	  Status	CHAR(14));
	 
	CREATE TABLE "informix".tmptelscat
	( cliente   CHAR(20),
	  telefono	CHAR(13),
	  tipo_tel	CHAR(30),
	  resultado	CHAR(40),
	  veces_marcado	SMALLINT,
	  status	CHAR(10));	 	  

	--Ruta archivo
	SELECT valor_alfabetico
	INTO	cRuta
	FROM bdicobranza:"informix".cb_param_campania 
	WHERE empresa = '001' 
  AND tipo_campania = 1 
	AND grupo_parametro= 'ARCHIVOS'  
	AND num_parametro= 21;
	
	--Nombre para el archivo de Clientes
	SELECT valor_alfabetico
	INTO cNombreCtes
	FROM bdicobranza:"informix".cb_param_campania 
	WHERE empresa = '001' 
  AND tipo_campania = 1 
	AND grupo_parametro= 'ARCHIVOS'  
	AND num_parametro= 22;
	
	--Nombre para el archivo de Telefonos
	SELECT valor_alfabetico
	INTO cNombreTels
	FROM bdicobranza:"informix".cb_param_campania 
	WHERE empresa = '001' 
  AND tipo_campania = 1 
	AND grupo_parametro= 'ARCHIVOS'  
	AND num_parametro= 23;
	
	SELECT fecha_hoy
	INTO cFechaHoy
	FROM bdicred:"informix".sd_fechas
  WHERE empresa = '001';	
	
	--Para clientes	
	--Inactivo		
	LET DescContac= 'NO CONTACTABLE';
	
	INSERT INTO  "informix".tmpctescat 
	SELECT distinct (tel.numcte), DescContac FROM bdicobranza:"informix".cb_telefonos tel
	INNER JOIN  bdisitesp:"informix".se_ctessitespcred  esp	ON ( tel.numcte = esp.numcte) WHERE esp.situacion= 'T'
	AND esp.causa = 1 AND tel.estatus= 'IN';			
	LET DescContac= '';
		
	
	--Activo
	LET DescContac= 'CONTACTABLE';
	INSERT INTO  "informix".tmpctescat 
	SELECT distinct(numcte), DescContac FROM bdicobranza:"informix".cb_telefonos WHERE estatus= 'AC';
		
	
	--Para Telefonos
	FOREACH 
		
		SELECT {+INDEX "informix".cb_telefonos idx_cons_telefono4)} distinct (numcte), telefono, tipo_telefono, numvecesmarcado, estatus, codigo_resultado
		INTO cNumCte, cTel, sTpoTel, sNumMarcados, cEstatus, sCodResultado
		FROM bdicobranza:"informix".cb_telefonos
		WHERE empresa = '001'
     AND estatus in('AC','IN', 'CA')
     AND fecha_insert >= '01-01-1900'	
     	
		
		SELECT descripcion
		INTO	cDescTpoTel
		FROM bdicobranza:"informix".cb_tipo_telefono
		WHERE empresa = '001'
      AND tipo_telefono = sTpoTel;
		
		SELECT  descripcion  
		INTO cDescripcionResult
		FROM bdicobranza:"informix".cb_cat_tipo_resultado
		WHERE codigo_resultado =NVL(sCodResultado,0);
		
		IF cEstatus = 'AC' THEN
			SELECT descripcion
			INTO cDescripcionStatus
			FROM bdicobranza:"informix".cb_param_campania 
			WHERE empresa = '001' 
      AND tipo_campania = 11
			AND grupo_parametro = 'STATUS' 
			AND num_parametro = 1;
		
		ELIF cEstatus = 'IN' THEN
			
			SELECT descripcion
			INTO cDescripcionStatus
			FROM bdicobranza:"informix".cb_param_campania 
			WHERE empresa = '001' 
      AND tipo_campania = 11
			AND grupo_parametro = 'STATUS' 
			AND num_parametro = 2;
		ELIF cEstatus = 'CA'	THEN
		
			SELECT descripcion
			INTO cDescripcionStatus
			FROM bdicobranza:"informix".cb_param_campania 
			WHERE empresa = '001' 
      AND tipo_campania = 11
			AND grupo_parametro = 'STATUS' 
			AND num_parametro = 3;
			
		END IF;		
		
		INSERT INTO "informix".tmptelscat (cliente, telefono, tipo_tel, resultado, veces_marcado, status)
		VALUES (cNumCte, cTel, cDescTpoTel, cDescripcionResult, sNumMarcados, cDescripcionStatus);
		
	END FOREACH; 
	
	LET cNombreCtes =  TRIM(cNombreCtes)||lpad(DAY(cFechaHoy),2,0)||lpad(MONTH(cFechaHoy),2,0)||lpad(YEAR(cFechaHoy),4,0);
	LET cNombreTels =  TRIM(cNombreTels)||lpad(DAY(cFechaHoy),2,0)||lpad(MONTH(cFechaHoy),2,0)||lpad(YEAR(cFechaHoy),4,0);	
	
	--GENERA ARCHIVO CLIENTES
	let cRuta = TRIM(cRuta);
	let vsSQL1 = 	'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreCtes) ||"Temporal.sql" ;
	LET vsSQL1 = TRIM(vsSQL1);
	let cSql3 = ' SELECT cliente, status  FROM bdicobranza:"informix".tmpctescat;  '  ;
	LET vsSQL2 = ' " >' || TRIM(cRuta ) || 'ConsultaCtesCAT.sql';
	LET cSql = TRIM(vsSQL1) ||" "|| TRIM(cSql3) || "" || vsSQL2;
	SYSTEM cSql;
	LET vsSQL1 = "";
	LET vsSQL1 = "dbaccess bdicobranza " || trim(cRuta) ||  "ConsultaCtesCAT.sql";
	SYSTEM vsSQL1;
	LET cNombreCtes2 = "ConsultaCtesCAT.sql";
	
	LET vsSQL1 = "";
	LET vsSQL1 = "sed 's/|$//g' " || trim(cRuta) || TRIM(cNombreCtes) ||"Temporal.sql" || " > " || trim(cRuta) || TRIM(cNombreCtes) ||".xls" ;
	SYSTEM vsSQL1;	

	LET vsSQL1 = '';
	LET vsSQL1 = "rm -rf " || trim(cRuta) || "*.sql";
	SYSTEM vsSQL1;
	
	LET vsSQL1  = '';
	LET cSql	= '';
	LET vsSQL2	= '';
	LET cSql3	= '';	
	
	--GENERA ARCHIVO TELEFONOS
	
	let cRuta = TRIM(cRuta);
	let vsSQL1 = 	'echo "UNLOAD TO ' || TRIM(cRuta) || TRIM(cNombreTels) ||"Temporal.sql" ;
	LET vsSQL1 = TRIM(vsSQL1);
	let cSql3 = ' SELECT cliente, telefono, tipo_tel, resultado, veces_marcado, status FROM bdicobranza:"informix".tmptelscat;  '  ;
	LET vsSQL2 = ' " >' || TRIM(cRuta ) || 'ConsultaTelCAT.sql';
	LET cSql = TRIM(vsSQL1) ||" "|| TRIM(cSql3) || "" || vsSQL2;
	SYSTEM cSql;
	LET vsSQL1 = "";
	LET vsSQL1 = "dbaccess bdicobranza " || trim(cRuta) ||  "ConsultaTelCAT.sql";
	SYSTEM vsSQL1;
	LET cNombreTels2 = "ConsultaTelCAT.sql";
	
	LET vsSQL1 = "";
	LET vsSQL1 = "sed 's/|$//g' " || trim(cRuta) || TRIM(cNombreTels) ||"Temporal.sql" || " > " || trim(cRuta) || TRIM(cNombreTels) ||".xls" ;
	SYSTEM vsSQL1;	

	LET vsSQL1 = '';
	LET vsSQL1 = "rm -rf " || trim(cRuta) || "*.sql";
	SYSTEM vsSQL1;

	--ELIMINA TABLAS
	DROP TABLE bdicobranza:"informix".tmptelscat;
	DROP TABLE bdicobranza:"informix".tmpctescat;
	
	RETURN cCodRet;
		
END
END PROCEDURE

DOCUMENT 
'DESCRIPCION: Genera 2 archivos, uno de clientes con los numeros de ctes y status, y otro de telefonos, con ctes, tel, tpo tel, resultado, veces marcado y estatus',
'AUTOR : Abigail Vasavilbazo Cañedo ',
'FECHA : 08/06/2011',
'BD    : BDICOBRANZA',
'Version: 20110620.1755';

create procedure "informix".sp_inserta_mensaje(pempresa  char(3), ptipomensaje smallint, pnumvencido  smallint, ptipomail smallint)
returning VARCHAR(6);
-- execute procedure "informix".sp_inserta_mensaje('001',5,2,0)

DEFINE pidtipomensaje	char (2);
DEFINE pnumvencidos     smallint;
DEFINE pnumcte          char(20);
DEFINE pnumcredito      char(20);
DEFINE pnombre          char(60);
DEFINE pemail           char (60);
DEFINE pmonto           decimal(18,2);
DEFINE psaldototal      decimal(18,2);
DEFINE ppagominimo      decimal(18,2);
DEFINE pmontoconvenio   decimal(18,2);
DEFINE pfechahoy		date;
DEFINE pvalor			smallint;
DEFINE vfecha			datetime year to second;
DEFINE pfecha			datetime year to second;
DEFINE pfechaprimercons datetime year to second;
DEFINE pfreestructu datetime year to second;
DEFINE cProceso  		char(4);
DEFINE cCod_ret  		smallint;
DEFINE cMensaje  		char (100);
DEFINE SQL_ERR          INTEGER;
DEFINE ISAM_ERR         INTEGER;
DEFINE ERROR_INFO       VARCHAR(80);
DEFINE P_COD_RET        VARCHAR(6);
DEFINE P_MENSAJE        VARCHAR(80);
DEFINE v_longitud       INTEGER;  
DEFINE v_cuenta			INTEGER;  
DEFINE v_subcadena		CHAR(1);  
DEFINE v_mail_incorrecto CHAR(1);  
LET v_longitud          = 0;  
LET v_cuenta            = 1;   
LET v_subcadena         = ''; 

BEGIN

    ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, P_COD_RET, P_MENSAJE, '02')
            RETURNING P_COD_RET;
        RETURN P_COD_RET;
    END exception;
	
 --SET DEBUG FILE TO "/informix/Elizabeth/inserta_mensaje.out";
 --TRACE ON;

  let P_COD_RET = '111111';
  let cCod_ret = '';
  let cMensaje = '';
  let cProceso = '2030';
  let pmonto = 0;
  let vfecha = to_char(today, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S');
 
  --valida parametros
	IF NVL (pempresa, '') = '' THEN
        LET cCod_Ret= '104002';
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	IF NVL (ptipomensaje, '') = '' THEN
        LET cCod_Ret= '106007';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	IF NVL (pnumvencido, '') = '' THEN
        LET cCod_Ret= '104001';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	IF NVL (ptipomail, '') = '' THEN
        LET cCod_Ret= '104001';        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
		IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, cCod_ret, cMensaje, '01');
        Return cCod_Ret;
	END IF;
	
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01') RETURNING P_COD_RET;
			
	Select Fecha_Hoy
    Into pfechahoy
    From bdicred:sd_fechas
    Where empresa = pempresa;
	
    select id_tipo_mensaje
    into pidtipomensaje
    from bdicobranza:cb_mail_configuracion
    where tipo_mensaje = ptipomensaje
    and num_vencidos = pnumvencido
	and tipo_mail = ptipomail;

    DELETE FROM bdinteg:si_mensajes_enviar WHERE date(f_mensaje) = pfechahoy and id_tipo_mensaje = pidtipomensaje;
	
	--valida el tipo de mensaje para la busqueda  en el where del select mas adelante
	if (ptipomensaje = 1 and pnumvencido <=5) then -- obtiene los meses de vencidos para mensajes de mora
		let pvalor=pnumvencido;
	end if;
	if (ptipomensaje = 1 and ptipomail >= 30) then --obtiene el valor para tipo de mensaje para mensajes de remanente y compra mayor a $5,000
		let pvalor=ptipomail;
	end if;
	if (ptipomensaje = 3) then--obtiene el valor para tipo de mensaje para convenios
		let pvalor = ptipomail;
	end if;
	if (ptipomensaje = 2) then--obtiene el valor para mensajes a venta de cartera
		let pvalor = 5;
	end if;
	if (ptipomensaje = 4 and pnumvencido > 0 ) then --valor para mensajes en reestructura moras
		let pvalor = pnumvencido;
	end if;
	if (ptipomensaje = 4 and pnumvencido = 0  and ptipomail = 0) then --valor para mensajes en reestructura preventiva
		let pvalor = 0;
	end if;
	if (ptipomensaje = 5 and pnumvencido <= 2 and ptipomail = 0) then --valor para mensajes en prestamo P moras
		let pvalor = pnumvencido;
	end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 0) then --valor para mensajes en prestamo P preventiva
		let pvalor = 0;
	end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 10) then --valor para mensajes en prestamo P autorizacion
		let pvalor = ptipomail;
	end if;
	
foreach
			
    select a.numcte, a.num_credito, a.email,a.pago_minimo,a.saldo_total
		, a.monto_convenio,
		to_char(a.fecha_convenio, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S') as fecha_convenio ,
		to_char(a.fecha_compac, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S') as fecha_compac , to_char(a.fecha_primercons, '%y-%m-%d') ||' '|| to_char(current,'%H:%M:%S') as fecha_primercons,
		trim (e.apell_paterno) || ' ' || trim ( e.apell_materno) || ' ' || trim (e.nombre1) || ' ' || trim (e.nombre2) as nombre_cliente 
    into pnumcte,pnumcredito,pemail,ppagominimo,psaldototal,pmontoconvenio,pfreestructu,
		 pfecha,pfechaprimercons ,pnombre  
    from bdicobranza:cb_mail_cliente a, bdinteg:si_cliente  e 
    where a.empresa = e.empresa
		and a.numcte = e.numcte
		and a.tipo_mensaje = ptipomensaje
		and a.pagos_vencidos = pvalor --se obtine de las validaciones anteriores
		and  a.fecha_insert = pfechahoy
	--montos
	if (ptipomensaje = 1) then let pmonto = ppagominimo; end if;
    if (ptipomensaje = 3) then let pmonto = pmontoconvenio; end if;
	if (ptipomensaje = 2) then let pmonto = psaldototal; end if;
	if (ptipomensaje = 4) then let pmonto = ppagominimo; end if;
	if (ptipomensaje = 5) then let pmonto = psaldototal; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 0)  then let pmonto = ppagominimo; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 10)  then let pmonto = psaldototal; end if;
	--fechas
	if (ptipomensaje = 3) then let vfecha = pfecha; end if;
	if (ptipomensaje = 1 and ptipomail = 30) then let vfecha = pfechaprimercons; END IF;
	if (ptipomensaje = 4 and pnumvencido = 0 and ptipomail = 0) then let vfecha = pfreestructu; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 0) then let vfecha = pfreestructu; end if;
	if (ptipomensaje = 5 and pnumvencido = 0 and ptipomail = 10) then let vfecha = pfreestructu; end if;
	
	LET v_longitud = length(pemail);
			FOR v_cuenta = 1 to v_longitud
				  LET v_subcadena = SUBSTR(pemail,v_cuenta,1);
					IF v_subcadena  in ('A','B','C','D','E','F','G','H','I','J','K','L','M','N','O','P','Q','R','S','T',
                                 'U','V','W','X','Y','Z',
                                 'a','b','c','d','e','f','g','h','i','j','k','l','m','n','o','p','q','r','s','t',
                                 'u','v','w','x','y','z',
                                 '1','2','3','4','5','6','7','8','9','0','@','_','-','.') THEN
						LET v_mail_incorrecto = 'F'; 
					-- INSERT INTO bdinteg:si_mensajes_enviar(f_mensaje, numcte, cuenta, nombre_cliente, correo_cliente, monto_reportar, id_tipo_mensaje, enviado,f_enviado,observaciones)
					--	VALUES(current, pnumcte, pnumcredito, pnombre,pemail, pmonto,pidtipomensaje,'V',current,'DIRECCION DE CORREO INCORRECTA');
					
						CONTINUE FOR;
					ELSE
						LET v_mail_incorrecto   = 'T';
				    EXIT FOR;
				    END IF;
			END FOR
			
				IF v_mail_incorrecto = 'T' THEN
					INSERT INTO bdinteg:si_mensajes_enviar(f_mensaje, numcte, cuenta,/*num_tarjeta ,tipo_tarjeta,*/ nombre_cliente, correo_cliente, monto_reportar, id_tipo_mensaje, enviado,f_enviado,observaciones)
					VALUES(current, pnumcte, pnumcredito,/* null,null,*/pnombre,pemail, pmonto,pidtipomensaje,'V',current,'DIRECCION DE CORREO INCORRECTA');
				else
					insert into bdinteg:"informix".si_mensajes_enviar(f_mensaje, numcte, cuenta,/*num_tarjeta ,tipo_tarjeta,*/ nombre_cliente, correo_cliente,
																	  monto_reportar, id_tipo_mensaje, enviado )
					values(vfecha, pnumcte, pnumcredito,/*null,null,*/ pnombre,pemail, pmonto,pidtipomensaje,'F');
				END IF;
			
end foreach
   let P_COD_RET = '000000';

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '03')
    RETURNING P_COD_RET;
end
RETURN P_COD_RET;
END PROCEDURE;