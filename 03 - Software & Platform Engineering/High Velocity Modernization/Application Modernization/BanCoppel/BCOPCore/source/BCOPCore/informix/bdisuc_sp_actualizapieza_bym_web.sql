CREATE PROCEDURE "informix".sp_actualizapieza_bym_web(pOpcion CHAR(1), pNumRecibo CHAR(10), pEstatus INTEGER, pTipoPago INTEGER, pNumCuenta CHAR(11), pEjecutivo CHAR(8))
RETURNING CHAR(5) AS cCodRet;

--DEFINICION DE VARIABLES
DEFINE cCodRet  CHAR(5);
DEFINE iSqlErr INTEGER;

--INICIALIZACION DE VARIABLES 
LET cCodret	= "00000";
LET iSqlErr = 0;

	--SET DEBUG FILE TO '/respaldosbd/Leslie/sp_actualizapieza_bym.out';
    --TRACE ON;
	
BEGIN
    
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodret = iSqlErr;
				RETURN  cCodRet;
			END IF;
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 5;
		
		-- pOpcion = 1 ---> Actualizacion de datos en Caja
		-- pOpcion = 2 ---> Reversion de los datos en Reversio
		-- pTipoPago = 1 --> Pago en Efectivo
		-- pTipoPago = 2 --> Pago en Abono a Cuenta de CaptaciÃ³n
		IF TRIM(NVL(pOpcion,''))=1 OR TRIM(NVL(pOpcion,''))=2 THEN
			IF TRIM(NVL(pOpcion,''))=1 THEN
				IF TRIM(NVL(pNumRecibo,''))<>'' AND  NVL(pEstatus,0)>0 AND NVL(pTipoPago,0)>0 AND TRIM(NVL(pEjecutivo,''))<>'' THEN
					IF NVL(pTipoPago,0)=2 THEN
						IF TRIM(NVL(pNumCuenta,''))='' THEN
							LET cCodret = '00001';
							RETURN cCodRet;
						END IF;
					END IF;
						IF (SELECT COUNT(num_recibo) FROM bdisuc:"informix".ss_piezas_bym_falsos WHERE num_recibo=TRIM(NVL(pNumRecibo,'')))>0 THEN
							UPDATE bdisuc:"informix".ss_piezas_bym_falsos
							SET fecha_pago=CURRENT, tipo_pago=NVL(pTipoPago,0), num_cta_cliente=TRIM(NVL(pNumCuenta,'')), 
								estatus=NVL(pEstatus,0), ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
							WHERE num_recibo=TRIM(NVL(pNumRecibo,''))
							AND estatus= 3
							AND dictamen_banxico= 1;
							
							RETURN cCodRet;
						ELSE
							LET cCodret = '00002';
							RETURN cCodRet;
						END IF;
				
				ELSE
					LET cCodret = '00001';
					RETURN cCodRet;
				END IF;
			ELIF TRIM(NVL(pOpcion,''))=2 THEN
				IF TRIM(NVL(pNumRecibo,''))<>'' AND  NVL(pEstatus,0)>0 AND TRIM(NVL(pEjecutivo,''))<>'' THEN
							UPDATE bdisuc:"informix".ss_piezas_bym_falsos
							SET fecha_pago='', tipo_pago='', num_cta_cliente='', 
								estatus=NVL(pEstatus,0), ejecutivo_update=TRIM(NVL(pEjecutivo,'')), fecha_update=CURRENT
							WHERE num_recibo=TRIM(NVL(pNumRecibo,''))
							AND estatus=4
							AND dictamen_banxico= 1;
							
							RETURN cCodRet;
				ELSE
					LET cCodret = '00001';
					RETURN cCodRet;
				END IF;
			END IF;
		ELSE
			LET cCodret = '00001';
			RETURN cCodRet;
		END IF;


END
END PROCEDURE
DOCUMENT
"DescripciÃ³n: ActualizÃ¡ los campos de la tabla ss_piezas_bym_falsos en caja y reversio",
"Autor : Leslie RendÃ³n",
"FECHA : 09/03/2015",
"BD    : bdisuc";

CREATE PROCEDURE "informix".sp_autenviocajaras_web(pvSucursal VARCHAR(5), pvNumcaja VARCHAR(12),pvStatus VARCHAR(10),pvOpcion VARCHAR(1), psRegistros SMALLINT, pcNumCte CHAR(20))

RETURNING CHAR(5), --CodRet
CHAR(5),           --cNumsucursal
CHAR(12),          --cNumerocaja
CHAR(30),          --cDescripcion
CHAR(20),          --cNumeroguia
CHAR(10),          --cEstatus
SMALLINT;          --sTipoPaquete


DEFINE cCod_Ret      CHAR(5);
DEFINE isqlerr       INTEGER ;
DEFINE cNumsucursal  CHAR(5);
DEFINE cNumerocaja   CHAR(12);
DEFINE cDescripcion  CHAR(30);
DEFINE cNumeroguia   CHAR(20);
DEFINE cEstatus      CHAR(10);
DEFINE sTipoPaquete  SMALLINT;


LET cCod_Ret       = "00000";
LET isqlerr 	   = 0;
LET cNumsucursal   = '';
LET cNumerocaja    = '';
LET cDescripcion   = '';
LET cNumeroguia    = 0;
LET cEstatus       = '';
LET sTipoPaquete   = 0;

BEGIN
    
    ON EXCEPTION  SET isqlerr
        IF isqlerr <> 0  THEN
            LET  cCod_Ret  = isqlerr;
            RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
        END IF;
    END  EXCEPTION;

     --SET DEBUG FILE TO '/home/tmp/jairo/sp_autenviocaja.out';
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;
	
		--VALIDANDO PARÃMETROS 
		IF pvOpcion = '' OR pvOpcion NOT IN ('1','2','3','4') THEN
		  LET  cCod_Ret  = '00002';
		  RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		ELIF pvOpcion = '1' THEN
		  IF pvNumcaja = '' THEN
			LET  cCod_Ret  = '00002';
			RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		  END IF
		ELIF pvOpcion = '2' THEN
		  IF pvSucursal = '' THEN
			LET  cCod_Ret  = '00002';
			RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		  END IF
		ELIF pvOpcion = '3' THEN
		   IF pvSucursal = '' OR pvStatus = '' THEN
			 LET  cCod_Ret  = '00002';
			 RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		   END IF
		ELIF pvOpcion = '4' THEN
			IF pvSucursal = '' OR pvOpcion = '' OR pcNumCte = '' THEN
			 LET  cCod_Ret  = '00002';
			 RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
		   END IF
		END IF
	
       IF pvOpcion = '1' THEN
	        -- busca por caja	  		
			SELECT TRIM(cajas.numsucursal),TRIM(cajas.numerocaja),TRIM(catpaq.descripcion),cajas.numeroguia,TRIM(cajas.estatus),cajas.tipopaquete
			INTO cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete
			FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq
			WHERE cajas.tipopaquete = catpaq.tipopaquete
			AND cajas.empresa = catpaq.empresa
			AND cajas.estatus IS NOT NULL
			AND cajas.estatus IN ('Activa','Enviada','Cerrada','Eliminada')
			AND cajas.numerocaja = TRIM(pvNumcaja);			
	   
	        IF DBINFO('sqlca.sqlerrd2') = 0 THEN
				LET cCod_Ret= "00001";
			END IF;	   
	        	
            RETURN cCod_Ret,NVL(cNumsucursal,''),NVL(cNumerocaja,''),TRIM(NVL(cDescripcion,'')),TRIM(NVL(cNumeroguia,'')),NVL(cEstatus,''),NVL(sTipoPaquete,0);  				
				   
	   ELIF pvOpcion = '2' THEN
	        -- busca por Sucursal
			FOREACH WITH HOLD			
				SELECT skip psRegistros LIMIT 11 TRIM(cajas.numsucursal),TRIM(cajas.numerocaja),TRIM(catpaq.descripcion),cajas.numeroguia,TRIM(cajas.estatus),cajas.tipopaquete
				INTO cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete
				FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq
				WHERE cajas.tipopaquete = catpaq.tipopaquete
				AND cajas.empresa = catpaq.empresa
				--AND cajas.numsucursal = pvSucursal--dsb-31/08/2012
				AND cajas.numsuc_crea = TRIM(pvSucursal)
				AND cajas.estatus IS NOT NULL
				AND cajas.estatus IN ('Activa','Enviada','Cerrada','Eliminada')
				ORDER BY cajas.numerocaja			    
	
				RETURN cCod_Ret,NVL(cNumsucursal,''),NVL(cNumerocaja,''),TRIM(NVL(cDescripcion,'')),TRIM(NVL(cNumeroguia,'')),TRIM(NVL(cEstatus,'')),NVL(sTipoPaquete,0) WITH RESUME;
				
		    END FOREACH; 
		
	   ELIF pvOpcion = '3' THEN
	         -- busca por status
			FOREACH 
				SELECT skip psRegistros LIMIT 11 TRIM(cajas.numsucursal),TRIM(cajas.numerocaja),TRIM(catpaq.descripcion),cajas.numeroguia,TRIM(cajas.estatus),cajas.tipopaquete
				INTO cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete
				FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq
				WHERE cajas.tipopaquete = catpaq.tipopaquete
				AND cajas.empresa = catpaq.empresa
 				AND cajas.numsuc_crea = TRIM(pvSucursal)
				AND cajas.estatus = TRIM(pvStatus)
				ORDER BY cajas.numerocaja
							
				RETURN cCod_Ret,NVL(cNumsucursal,''),NVL(cNumerocaja,''),TRIM(NVL(cDescripcion,'')),TRIM(NVL(cNumeroguia,'')),TRIM(NVL(cEstatus,'')),NVL(sTipoPaquete,0) WITH RESUME; 
				
		    END FOREACH;
		
	   ELIF pvOpcion = '4' THEN 
			--BUSCA POR CLIENTE
			FOREACH
				SELECT DISTINCT TRIM(cajas.numsucursal),TRIM(cajas.numerocaja),TRIM(catpaq.descripcion),cajas.numeroguia,TRIM(cajas.estatus),cajas.tipopaquete
				INTO cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete 
				FROM bdisuc:"informix".ss_numcajas cajas, bdisuc:"informix".ss_cattipopaquetes catpaq, bdisuc:"informix".ss_expedientesclientes expcte
				WHERE cajas.tipopaquete = catpaq.tipopaquete 
				AND cajas.numerocaja = expcte. numerocaja 
				AND cajas.empresa = catpaq.empresa
				AND cajas.numsucursal = TRIM(pvSucursal)
				AND expcte.numerocliente = TRIM(pcNumCte) 
				AND expcte.estatus <> 'E'
							
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCod_Ret= "00001";
				END IF;		
				
				RETURN cCod_Ret,NVL(cNumsucursal,''),NVL(cNumerocaja,''),TRIM(NVL(cDescripcion,'')),TRIM(NVL(cNumeroguia,'')),TRIM(NVL(cEstatus,'')),NVL(sTipoPaquete,0) WITH RESUME; 				
				
			END FOREACH;
	   END IF;  	
	   
	   IF DBINFO('sqlca.sqlerrd2') = 0 THEN	
				LET cCod_Ret = "00001";
				RETURN cCod_Ret,cNumsucursal,cNumerocaja,cDescripcion,cNumeroguia,cEstatus,sTipoPaquete;
	   END IF;	   
         
END
END PROCEDURE
DOCUMENT 
'ELABORO: Josue Zepeda',
'FECHA MODIFICACION: 09 Abril del 2012',
'DESCRIPCION: Se crea sp_AutEnvioCaja para hacer busqueda por caja, sucursal y status',
'VERSION: 20120409.1200',
'BD: BDISUC',
'MODIFICO: Victor Hugo NuÃ±ez',
'FECHA MODIFICACION: 31 Agosto del 2012',
'DESCRIPCION: Se modifica busqueda por sucursal y por estatus para obtener las cajas relacionadas',
'VERSION: 20120831.1900',
'BD: BDISUC',
'MODIFICO: Mireya Reyes',
'FECHA MODIFICACION: 14 Febrero del 2014',
'DESCRIPCION: Se aÃ±ade nuevo retorno TipoPaquete con la finalidad de utilizarlo de parÃ¡metro de entrada',
'entrada en el sp_actestatuscaja y se agrega validaciÃ³n para la consulta por caja y sucursal contemplando el estatus (Eliminada).',
'VERSION: 20140211.1900',
'BD: BDISUC',
'MODIFICO:	  Ernesto Aguilera',
'FECHA:		  17/10/2014',
'DESCRIPCION: Se agrega nueva busqueda por cliente con parametro de numero de cliente y se retorna los datos de la consulta.',
'VERSION: 20141017.1630',
'BD: BDISUC',
'MODIFICO:	  Jairo Valdez Gonzalez',
'FECHA:		  23/10/2015',
'DESCRIPCION: Se modifica parametro de retorno cNumeroguia a CHAR(20) y su respectiva variable.',
'BD: BDISUC';

CREATE PROCEDURE "informix".sp_consultarcattipocarpeta_web(p_sEmpresa CHAR(3), p_iTipoCarpeta SMALLINT)
	RETURNING	CHAR(5) AS retorno,
				CHAR(3) AS empresa,
				SMALLINT AS tipocarpeta,
				CHAR(80) AS descripcion;

	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(5);
	DEFINE v_sEmpresa						CHAR(3);
	DEFINE v_iTipoCarpeta					SMALLINT;
	DEFINE v_sDescripcion					CHAR(80);	

	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_consultarCatTipoCarpeta.out";
	--TRACE ON;
	-----------------------------------------------------------------------------
	LET v_sValRetorno = '00001';

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','';
			END IF;
		END EXCEPTION;
		
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;
		 

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' THEN
			RETURN v_sValRetorno,'','','';
		END IF;

		IF p_iTipoCarpeta = '' THEN
			LET p_iTipoCarpeta = NULL;
		END IF;

		--OBTIENE EL CATALOGO DE TIPOS DE CARPETA
		FOREACH
			SELECT empresa, tipocarpeta, descripcion
			INTO v_sEmpresa, v_iTipoCarpeta, v_sDescripcion
                FROM bdisuc:"informix".ss_cattipocarpeta
			WHERE empresa = p_sEmpresa AND tipocarpeta = NVL(p_iTipoCarpeta, tipocarpeta)

			LET v_sValRetorno = '00000';
			RETURN v_sValRetorno,  v_sEmpresa, v_iTipoCarpeta, v_sDescripcion WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT
'CREADO: Erick Zamora',
'FECHA: 05/Agosto/2009',
'DESCRIPCION: Obtiene todos los datos del catalogo de tipos de carpeta',
'CASO DE USO: PCU-bdisuc\CU-0020-ConsultarCatTipoCarpeta-SPL';

CREATE PROCEDURE "informix".sp_consultarexpedientesclientes_web(p_sEmpresa CHAR(3), p_sNumCliente CHAR(20), p_sNumCaja CHAR(10), 
				p_sTipoDocumento CHAR(1), p_iCantRegistros INTEGER)
				
	RETURNING	CHAR(5) AS retorno, 
				SMALLINT AS cvedocumento,
				CHAR(80) AS documento, 
				CHAR(4) AS numSucursal, 
				CHAR(40) AS desSucursal,
				CHAR(10) AS cajaRegistrada,
				CHAR(10) AS fechaRegistro,
				CHAR(1) AS estatus,
				CHAR(8) AS numUsuarioRegistro,
				CHAR(45) AS desUsuarioRegistro,
				CHAR(8) AS numUsuarioAutorizo,
				CHAR(45) AS desUsuarioAutorizo,
				CHAR(1) AS bloqueado,			
				CHAR(8)  AS numUsuarioSolicita,
				CHAR(45) AS desUsuarioSolicita,
				CHAR(100) AS desComentario,
				CHAR(1) AS cantidad,  --DSB 22/02/2013
				CHAR(3) AS cantidadExp,  --DSB 22/02/2013
				INTEGER AS NumHojasReg,
				INTEGER AS Capacidad;

	DEFINE iSqlErr							INTEGER;
	DEFINE v_sValRetorno					CHAR(5);
	DEFINE v_iClaveDocto					SMALLINT;
	DEFINE v_sDocumento						CHAR(80);
	DEFINE v_sNumSucursal					CHAR(4);
	DEFINE v_sDesSucursal					CHAR(40);
	DEFINE v_sCajaRegistrada				CHAR(10);
	DEFINE v_sFechaRegistro					CHAR(10);
	DEFINE v_sEstatus						CHAR(1);
	DEFINE v_sNumUsuarioRegistro			CHAR(8);
	DEFINE v_sDesUsuarioRegistro			CHAR(45);
	DEFINE v_sNumUsuarioAutorizo			CHAR(8);
	DEFINE v_sDesUsuarioAutorizo			CHAR(45);
	DEFINE v_iNumRegistro					INTEGER;
	DEFINE v_sbloqueado						CHAR(1);
	DEFINE v_sNumUsuarioSolicita			CHAR(8);
	DEFINE v_sDesUsuarioSolicita			CHAR(45);
	DEFINE v_sDesComentario					CHAR(100);
	DEFINE cCantidad						CHAR(1);   --DSB 22/02/2013
	DEFINE cCantidadExp						CHAR(3);   --DSB 22/02/2013
	DEFINE iCapacidad						INTEGER;	--DSB 14/10/2014
	DEFINE iHojas							INTEGER;	--DSB 14/10/2014
	
	LET cCantidad = '';  --DSB 22/02/2013
	LET cCantidadExp = '';  --DSB 22/02/2013
	LET iHojas = 0; --DSB 14/10/2014
	LET iCapacidad = 0; --DSB 14/10/2014
	-----------------------------------------------------------------------------	
	--SET DEBUG FILE TO "/tmp/sp_consultarExpedientesClientes.out";
	--TRACE ON;
	-----------------------------------------------------------------------------

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				RETURN iSqlErr,'','','','','','','','','','','','','','','','','',iHojas,iCapacidad;
			END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		LET v_sValRetorno = '00001';
		LET v_iNumRegistro = 0;

		--LOS PARAMETROS NO DEBEN SER NULOS
		IF NVL(p_sEmpresa,'')='' OR NVL(p_sNumCliente,'')='' THEN
			RETURN v_sValRetorno,'','','','','','','','','','','','','','','','','',iHojas,iCapacidad;
		END IF;

		IF p_sNumCaja = '' THEN
			LET p_sNumCaja = NULL;
		END IF;

		IF p_sTipoDocumento = '' THEN
			LET p_sTipoDocumento = NULL;
		END IF;
		
		--OBTENER LA CAPACIDAD Y EL NUMERO DE HOJAS DE LA CAJA
		SELECT NVL(paq.capacidad,0), NVL(caj.num_hojas_registradas,0) 
		INTO iCapacidad, iHojas
		FROM "informix".ss_cattipopaquetes paq, "informix".ss_numcajas caj
		WHERE paq.empresa = p_sEmpresa
		AND caj.empresa = paq.empresa
		AND caj.tipopaquete = paq.tipopaquete
		AND caj.numerocaja = p_sNumCaja
		AND paq.tipopaquete = 1;
		
		LET p_sNumCliente = LPAD(TRIM(p_sNumCliente),9,'0');

		FOREACH
			--OBTIENE TODOS LOS DOCUMENTOS QUE TIENE EL CLIENTE REGISTRADOS MAS LOS DOCUMENTOS DEL CLIENTE QUE FALTAN POR CAPTURAR
			SELECT SKIP p_iCantRegistros NVL(cat.cvedocumento,''), NVL(cat.descripcion,''), NVL(ex.sucursal,''), NVL(ex.numerocaja,''), 
			NVL(ex.fecharegistro,''), NVL(ex.estatus,''), NVL(ex.usuarioregistra,''), NVL(ex.usuarioautoriza,''), 
			NVL(cat.bloqueado,''), NVL(ex.usuariosolicita,''), NVL(ex.comentario,''),cat.cantidad,ex.cantidad
			INTO v_iClaveDocto, v_sDocumento, v_sNumSucursal, v_sCajaRegistrada, 
			v_sFechaRegistro, v_sEstatus, v_sNumUsuarioRegistro, v_sNumUsuarioAutorizo, 
			v_sbloqueado, v_sNumUsuarioSolicita, v_sDesComentario,cCantidad,cCantidadExp   --DSB 22/02/2013
			FROM "informix".ss_catdocumentos cat LEFT JOIN "informix".ss_expedientesclientes ex 
			ON(cat.empresa = ex.empresa AND cat.cvedocumento = ex.cvedocumento
			AND ex.empresa = p_sEmpresa
			AND ex.numerocliente = p_sNumCliente
			AND ex.cvedocumento = ex.cvedocumento --para que tome en cuenta los indices
			AND ex.numerocaja = NVL(p_sNumCaja, ex.numerocaja))
			WHERE cat.tipodocumento = NVL(p_sTipoDocumento, cat.tipodocumento)
			AND cat.bloqueado <> 1   --DSB 22/02/2013
			ORDER BY cat.cvedocumento, ex.numerocaja, ex.sucursal

			--SI EL DOCUMENTO ESTA REGISTRADO
			IF v_sCajaRegistrada <> '' THEN
				--OBTIENE EL NOMBRE DE LA SUCURSAL
				SELECT NVL(nombre,'') INTO v_sDesSucursal 
				FROM bdinteg:"informix".si_sucursales
				WHERE empresa = p_sEmpresa
				AND sucursal = v_sNumSucursal;

				--OBTIENE EL NOMBRE DEL USUARIO QUE REGISTRA
				IF NVL(v_sNumUsuarioRegistro,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioRegistro 
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioRegistro;
				ELSE
					LET v_sDesUsuarioRegistro = '';
				END IF

				--OBTIENE EL NOMBRE DEL USUARIO QUE AUTORIZA
				IF NVL(v_sNumUsuarioAutorizo,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioAutorizo 
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioAutorizo;
				ELSE
					LET v_sDesUsuarioAutorizo = '';
				END IF
				
				--OBTIENE EL NOMBRE DEL USUARIO QUE SOLICITA
				IF NVL(v_sNumUsuarioSolicita,'') <> '' THEN
					SELECT NVL(nombre,'') INTO v_sDesUsuarioSolicita
					FROM bdinteg:"informix".si_ejecut
					WHERE empresa = p_sEmpresa
					AND ejecutivo = v_sNumUsuarioSolicita;
				ELSE 
					LET v_sDesUsuarioSolicita = '';
				END IF
			ELSE
				LET v_sDesSucursal = '';
				LET v_sDesUsuarioRegistro = '';
				LET v_sDesUsuarioAutorizo = '';
				LET v_sDesUsuarioSolicita = '';
			END IF;

			LET v_sValRetorno = '00000';

			RETURN v_sValRetorno, v_iClaveDocto, v_sDocumento, v_sNumSucursal, v_sDesSucursal, v_sCajaRegistrada, v_sFechaRegistro, 
			v_sEstatus,v_sNumUsuarioRegistro,v_sDesUsuarioRegistro,v_sNumUsuarioAutorizo,v_sDesUsuarioAutorizo, v_sbloqueado,
			v_sNumUsuarioSolicita, v_sDesUsuarioSolicita, v_sDesComentario,cCantidad,cCantidadExp,iHojas,iCapacidad WITH RESUME;
		END FOREACH;
	END;
END PROCEDURE
DOCUMENT
'CREADO:      Erick Zamora', 
'FECHA:       01/Agosto/2009',
'DESCRIPCION: Obtiene todos los documentos que tiene el cliente registrados mas los documentos del cliente que faltan por capturar',
'CASO DE USO: Caso de uso asociado PCU-bdisuc\CU-0002-ConsultarExpedientesClientes-SPL',
'MODIFICADO:  Fabiola Corrales 16/Oct/2009. Se modifica para agregar los campos usuariosolicita y comentario',
'MODIFICO:    Josue Zepeda', 
'FECHA:       22/Febrero/2013',
'MODIFICADO:  Se agrega variable into cCantidad,cCantidadExp y tambien variable de retorno cantidad',
'MODIFICO:	  Ernesto Aguilera',
'FECHA:		  17/10/2014',
'DESCRIPCION: Se obtiene y retorna la capacidad y el nÃºmero de hojas que tiene la caja.';

CREATE PROCEDURE "informix".sp_consulta_doctos_admin_web(pEmpresa CHAR(3),pSucursal CHAR(4),pNumeroCaja CHAR(10),pTipo INTEGER,pRegistro INTEGER)
--DATOS A REGRESAR---
RETURNING	CHAR(5) AS cCodRet,
			SMALLINT AS cTipoDocumento,
			CHAR(80) AS cDocumento,
			CHAR(1) AS cTipoEstatus,
			CHAR(20) AS cEstatus,
			CHAR(10) AS cFechaInicio,
			CHAR(10) AS cFechaFin;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet			CHAR(5);
DEFINE  cTipoEstatus	CHAR(1);
DEFINE  cDocumento		CHAR(80);
DEFINE  cEstatus		CHAR(20);
DEFINE  cFechaInicio	CHAR(10);
DEFINE  cFechaFin		CHAR(10);
DEFINE  cCaja			CHAR(10);
DEFINE  cTipoDistinto   SMALLINT;
DEFINE	iConteo			INTEGER;
DEFINE	cTipoDocumento	SMALLINT;
DEFINE  iSqlErr			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet			= '00000';
LET cTipoEstatus	= '';
LET cDocumento		= '';
LET cEstatus		= '';
LET cFechaInicio	= '';
LET cFechaFin		= '';
LET cCaja			= '';
LET cTipoDistinto   = 0;
LET iConteo			= 0;
LET cTipoDocumento	= 0;
LET iSqlErr			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cTipoDocumento,cDocumento,cTipoEstatus,cEstatus,cFechaInicio,cFechaFin;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/respaldosbd/claudio/sp_consulta_doctos_admin.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pTipo,0) = 1 THEN
		IF NVL(pEmpresa,'') <> '' THEN

			FOREACH
				SELECT tipodocumento,descripcion INTO cTipoDocumento,cDocumento
				FROM bdisuc:"informix".ss_cattipodocumento
				WHERE empresa = pEmpresa

				LET iConteo = iConteo + 1;
				IF iConteo <= pRegistro THEN
					CONTINUE FOREACH;
				END IF;
				LET cTipoEstatus = 'N';
				LET cEstatus = 'No Registrado';

				RETURN cCodRet,cTipoDocumento,cDocumento,cTipoEstatus,cEstatus,cFechaInicio,cFechaFin WITH RESUME;
			END FOREACH;

			IF iConteo = 0 THEN
				LET cCodRet ='01309';
			END IF;
		ELSE
			LET cCodRet ='01308';
		END IF;
	ELIF NVL(pTipo,0) = 2 THEN
		IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' AND NVL(pNumeroCaja,'') <> '' THEN

				
			SELECT numerocaja, tipopaquete INTO cCaja, cTipoDistinto
			FROM bdisuc:"informix".ss_numcajas 
			WHERE empresa = pEmpresa AND numerocaja = pNumeroCaja;

			IF NVL(cCaja,'') = '' THEN
				LET cCodRet ='01320';
			ELIF cTipoDistinto <> 3 THEN
				LET cCodRet ='01334';
			ELSE
				FOREACH
					SELECT cat.tipodocumento,cat.descripcion,adm.estatus,adm.fechainicio,adm.fechafinal
					INTO cTipoDocumento,cDocumento,cTipoEstatus,cFechaInicio,cFechaFin
					FROM bdisuc:"informix".ss_cattipodocumento cat, OUTER bdisuc:"informix".ss_documentosadmon adm
					WHERE adm.numerocaja = pnumerocaja AND adm.sucursal = psucursal
					AND cat.tipodocumento = adm.tipodocumento

					LET iConteo = iConteo + 1;
					IF iConteo <= pRegistro THEN
						CONTINUE FOREACH;
					END IF;

					IF NVL(cTipoEstatus,'') = 'R' THEN
						LET cEstatus ='Registrado';
					ELIF NVL(cTipoEstatus,'') = 'C' THEN
						CONTINUE FOREACH;
					ELIF NVL(cTipoEstatus,'') = 'N' THEN
						LET cEstatus ='No Registrado';
					END IF;

					IF NVL(cFechaInicio,'') = '' THEN
						LET cFechaInicio ='';
					END IF;

					IF NVL(cFechaFin,'') = '' THEN
						LET cFechaFin ='';
					END IF;

					RETURN cCodRet,cTipoDocumento,cDocumento,cTipoEstatus,cEstatus,cFechaInicio,cFechaFin WITH RESUME;
				END FOREACH;

				IF iConteo = 0 THEN
					LET cCodRet ='01309';
				END IF;
			END IF;

		ELSE
			LET cCodRet ='01308';
		END IF;
	END IF;

	IF NVL(cCodRet,'') <> '00000' THEN
		RETURN cCodRet,cTipoDocumento,cDocumento,cTipoEstatus,cEstatus,cFechaInicio,cFechaFin;
	END IF;
END;
END PROCEDURE
DOCUMENT
'000000 - Retorna Sucursales',
'001308 - Parametros Incompletos',
'001309 - No Existe informacion',
'DESCRIPCION: Consulta documentos',
'AUTOR: Claudio Almodovar',
'Folio: 1759',
'Solicita: Rodolfo GÃ³mez',
'FECHA: 16/10/2015',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consulta_suc_relacionadas_web(pEmpresa CHAR(3),pSucursal CHAR(4),pRegistro INTEGER)
--DATOS A REGRESAR---
RETURNING	CHAR(5) AS cCodRet,
			CHAR(4) AS cSucRelacionada,
			CHAR(10) AS cMatriz;

--DEFINICION DE VARIABLES--
DEFINE  cCodRet			CHAR(5);
DEFINE  cSucRelacionada	CHAR(4);
DEFINE  cMatriz			CHAR(10);
DEFINE  iSqlErr			INTEGER;
DEFINE	iConteo			INTEGER;

--INICIALIZACION DE VARIABLES--
LET cCodRet			= '00000';
LET cSucRelacionada	= '';
LET cMatriz			= '';
LET iSqlErr			= 0;
LET iConteo			= 0;

BEGIN
	ON EXCEPTION SET iSqlErr
	   IF (iSqlErr != 0) THEN
		  LET cCodRet = iSqlErr;
		  RETURN cCodRet,cSucRelacionada,cMatriz;
	   END IF;
	END EXCEPTION;

	--SET DEBUG FILE TO '/home/tmp/jairo/sp_consulta_suc_relacionadas.out';
	--TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	IF NVL(pEmpresa,'') <> '' AND NVL(pSucursal,'') <> '' THEN

		SELECT sucursal INTO cSucRelacionada
		FROM bdinteg:"informix".si_sucursales
		WHERE empresa = pEmpresa AND sucursal = pSucursal;

		IF DBINFO('sqlca.sqlerrd2') = 0 THEN
			LET cCodret = '01309';
		ELSE

				SELECT LIMIT 1 sucursal_matriz INTO cSucRelacionada
				FROM bdisuc:"informix".ss_sucursalesrelacionadas
				WHERE empresa = pEmpresa
				AND sucursal_matriz = pSucursal AND status_relacion = 'A';

				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodRet = '01309';
				ELSE
					IF pRegistro = 0 THEN
						LET cMatriz = '';
						LET cMatriz = '(Matriz)';
						RETURN cCodRet,cSucRelacionada,cMatriz WITH RESUME;
					ELSE
						LET cMatriz = '';
					END IF;
				END IF;

			LET cMatriz = '';

			FOREACH
				SELECT sucursal_relacionada INTO cSucRelacionada
				FROM bdisuc:"informix".ss_sucursalesrelacionadas
				WHERE empresa = pEmpresa
				AND sucursal_matriz = pSucursal
				AND status_relacion = 'A'
				ORDER BY sucursal_relacionada ASC

				LET iConteo = iConteo + 1;
				IF iConteo <= pRegistro -1 THEN
					CONTINUE FOREACH;
				END IF;

				IF NVL(cSucRelacionada,'') = pSucursal THEN
					CONTINUE FOREACH;
				END IF;
				RETURN cCodRet,cSucRelacionada,cMatriz WITH RESUME;
			END FOREACH;

			IF iConteo = 0 THEN
				LET cCodRet ='00001';
			END IF;
		END IF;
	ELSE
		LET cCodRet ='01308';
	END IF;

	IF NVL(cCodRet,'') <> '00000' THEN
		RETURN cCodRet,cSucRelacionada,cMatriz;
	END IF;
END;
END PROCEDURE
;