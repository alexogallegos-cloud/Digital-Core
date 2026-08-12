CREATE PROCEDURE "informix".sp_consultamovtosgeneraldomi(p_sTipo CHAR (1), p_sFechaInicial CHAR(10), p_sFechaFinal CHAR (10), p_sNumCte CHAR(9), p_iSecuencia SMALLINT)

RETURNING 	CHAR(5)  AS Codret,
			CHAR(20) AS Cuenta,
			CHAR(18) AS Rfc,
			CHAR(60) AS RazonSocial,
			CHAR(20) AS NumTarjeta,
			CHAR(20) AS Clabe,
			CHAR(15) AS Importe,
			CHAR(2)  AS CveStatus,
			CHAR(20) AS Descripcion,
	        CHAR(8)  AS FechaAplica,
			CHAR(7)  AS RefNum,
			CHAR(40) AS sRefLeyenda,
			CHAR(19) AS ImporteMax,
			CHAR(20) AS NombreArchivo,
			CHAR(7)  AS Secuencia,
			CHAR(8)  As FechaPresentacion,
			CHAR(2)  AS TipoRegistro,
			CHAR(16) AS Folio_Suc,
			CHAR(2)	 AS CausaReverso;
		---	CHAR(4)  AS GrupoReverso;

	--definicion de variables
    DEFINE sCodret 				CHAR(5);
	DEFINE sql_err  			INTEGER;
	DEFINE sCuenta 				CHAR(20);
	DEFINE sRfc					CHAR(18);
	DEFINE sRazonSocial 		CHAR(60);
	DEFINE sNumTarjeta			CHAR(20);
	DEFINE sClabe				CHAR(20);
	DEFINE sImporte				CHAR(15);
	DEFINE sCveStatus			CHAR(2);
	DEFINE sDescripcion 		CHAR(20);
	DEFINE sRefLeyenda  		CHAR(40);
	DEFINE sRefNum     			CHAR(7);
	DEFINE sFechaAplica 		CHAR(8);
	DEFINE sImporteMax  		CHAR(19);
	DEFINE sNombreArchivo 		CHAR(20);
	DEFINE sNumSecuencia 		CHAR(7);
	DEFINE sFechaPresentacion 	CHAR(8);
	DEFINE sTipoRegistro 		CHAR(2);
	DEFINE sFolioSuc 			CHAR(16);
	DEFINE sCausaReverso		CHAR(2);
	DEFINE sGrupoReverso		CHAR(4);

	--Asignacion de variables
    LET sCodret 			= "00000";
	LET sql_err	    		= 0;
	LET sCuenta 			= "";
	LET sRfc				= "";
	LET sRazonSocial		= "";
	LET sNumTarjeta			= "";
	LET sClabe				= "";
	LET sImporte			= "";
	LET sCveStatus			= "";
	LET sDescripcion		= "";
	LET sRefLeyenda 		= "";
	LET sRefNum				= "";
	LET sFechaAplica		= "";
	LET sImporteMax 		= "";
	LET sNombreArchivo		= "";
	LET sNumSecuencia  		= "";
	LET sFechaPresentacion 	= "";
	LET sTipoRegistro  		= "";
	LET sFolioSuc			= "";
	LET sCausaReverso 		= "";
	LET sGrupoReverso		= "";

	--**********************************************************************************
	--SET DEBUG FILE TO "/tmp/sp_ConsultaMovtosGeneralDomi.out";
	--TRACE ON;
	--**********************************************************************************

	BEGIN
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET sCodret = sql_err;
				RETURN sCodret, sCuenta, sRfc, sRazonSocial, sNumTarjeta, sClabe, sImporte, sCveStatus, sDescripcion, sFechaAplica, sRefNum,
				--sRefLeyenda, sImporteMax, sNombreArchivo, sNumSecuencia, sFechaPresentacion, sTipoRegistro, sFolioSuc, sCausaReverso, sGrupoReverso;
				  sRefLeyenda, sImporteMax, sNombreArchivo, sNumSecuencia, sFechaPresentacion, sTipoRegistro, sFolioSuc, sCausaReverso;
			END IF;
		END EXCEPTION;

		--Valida parametros de entrada
		IF NVL(p_sTipo,'') = ''  OR NVL(p_sFechaInicial,'') = '' OR NVL(p_sFechaFinal,'') = ''OR NVL(p_sNumCte,'') = ''  THEN
			LET sCodret = "00100";
		    RETURN sCodret, sCuenta, sRfc, sRazonSocial, sNumTarjeta, sClabe, sImporte, sCveStatus, sDescripcion, sFechaAplica, sRefNum, sRefLeyenda,
			--sImporteMax,sNombreArchivo,sNumSecuencia,sFechaPresentacion,sTipoRegistro, sFolioSuc, sCausaReverso, sGrupoReverso;
			  sImporteMax,sNombreArchivo,sNumSecuencia,sFechaPresentacion,sTipoRegistro, sFolioSuc, sCausaReverso;
		END IF;

		LET p_sFechaFinal = TRIM(p_sFechaFinal );
		LET p_sFechaInicial = TRIM (p_sFechaInicial);

		--*****************************************Tipo ## 1 ###, Consulta todos lo movimientos del cliente (reversados y aplicados).*******************************************
		IF p_sTipo = '1' THEN
		   FOREACH
				SELECT a.cuenta, a.rfc, b.razon_social, a.imp_maximo, b.cod_grupo_rev
				INTO sCuenta, sRfc, sRazonSocial, sImporteMax, sGrupoReverso
				FROM bdidomi:dom_autorizaciones a
				INNER JOIN bdidomi:dom_cat_servicios b ON a.rfc = b.rfc
				WHERE a.num_cte = p_sNumCte
				ORDER BY a.cuenta

				--SELECT num_tarjeta INTO sNumTarjeta FROM bdicheq:sc_tarjeta WHERE cuenta = sCuenta AND numcte = p_sNumCte;
				SELECT cuenta_clabe INTO sClabe FROM bdicheq:sc_maechq WHERE cuenta = sCuenta;

				--LET sNumTarjeta = LPAD(TRIM(sNumTarjeta),20,'0');
				LET sClabe = LPAD(TRIM(sClabe),20,'0');

				FOREACH
	                SELECT SKIP p_iSecuencia a.importe, b.cve_status, b.descripcion, a.fecha_aplica, a.ref_numerica, a.ref_leyenda, a.nombre_arch,
					a.num_secuencia, a.fecha_presentacion, a.tipo_registro, a.folio_suc
					INTO sImporte, sCveStatus, sDescripcion, sFechaAplica, sRefNum, sRefLeyenda, sNombreArchivo,
					sNumSecuencia, sFechaPresentacion, sTipoRegistro, sFolioSuc
					FROM bdidomi:dom_cce_detalle a
					INNER JOIN bdidomi:dom_status_pago b ON a.cve_estatus = b.cve_status
					WHERE (a.cve_estatus = "01" OR a.cve_estatus = "03")
					AND a.fecha_presentacion BETWEEN p_sFechaInicial AND p_sFechaFinal
					AND a.rfc_ord = sRfc
					AND (a.num_cta_rec IN (SELECT LPAD(TRIM(num_tarjeta),20,'0') FROM bdicheq:sc_tarjeta WHERE cuenta = sCuenta AND numcte = p_sNumCte)
					OR a.num_cta_rec = sClabe)
					AND a.cod_operacion = "30"
					ORDER BY a.fecha_presentacion

					SELECT cve_reverso INTO sCausaReverso FROM  bdidomi:dom_reversos WHERE nombre_arch = sNombreArchivo
					AND fecha_presentacion = sFechaPresentacion AND tipo_registro = sTipoRegistro AND num_secuencia = sNumSecuencia;

       				RETURN sCodret, sCuenta, sRfc, sRazonSocial, sNumTarjeta, sClabe, sImporte, sCveStatus, sDescripcion, sFechaAplica, sRefNum,
					sRefLeyenda, sImporteMax, sNombreArchivo, sNumSecuencia, sFechaPresentacion, sTipoRegistro, sFolioSuc, NVL(sCausaReverso,'') 
				  --sGrupoReverso WITH RESUME;
				    WITH RESUME;

                END FOREACH;
           END FOREACH;

			--*****************************************Tipo ### 2 ###, Consulta los movimientos del cliente aplicados).*******************************************
		ELIF p_sTipo = '2' THEN
		   FOREACH
				SELECT a.cuenta, a.rfc, b.razon_social, a.imp_maximo, b.cod_grupo_rev
				INTO sCuenta, sRfc, sRazonSocial, sImporteMax, sGrupoReverso
				FROM bdidomi:dom_autorizaciones a
				INNER JOIN bdidomi:dom_cat_servicios b ON a.rfc = b.rfc
				WHERE a.num_cte = p_sNumCte
				ORDER BY a.cuenta

				--SELECT num_tarjeta INTO sNumTarjeta FROM bdicheq:sc_tarjeta WHERE cuenta = sCuenta AND numcte = p_sNumCte;
				SELECT cuenta_clabe INTO sClabe FROM bdicheq:sc_maechq WHERE cuenta = sCuenta;

				--LET sNumTarjeta = LPAD(TRIM(sNumTarjeta),20,'0');
				LET sClabe = LPAD(TRIM(sClabe),20,'0');

				FOREACH
					SELECT SKIP p_iSecuencia a.importe, b.cve_status, b.descripcion, a.fecha_aplica, a.ref_numerica, a.ref_leyenda, a.nombre_arch,
					a.num_secuencia, a.fecha_presentacion, a.tipo_registro, a.folio_suc
					INTO sImporte, sCveStatus, sDescripcion, sFechaAplica, sRefNum, sRefLeyenda, sNombreArchivo, sNumSecuencia,
					sFechaPresentacion, sTipoRegistro, sFolioSuc
					FROM bdidomi:dom_cce_detalle a
					INNER JOIN bdidomi:dom_status_pago b ON a.cve_estatus = b.cve_status
					WHERE a.cve_estatus = '01' --Clave de Aplicado
					AND a.fecha_presentacion BETWEEN p_sFechaInicial AND p_sFechaFinal
					AND a.rfc_ord = sRfc
					AND (a.num_cta_rec IN (SELECT LPAD(TRIM(num_tarjeta),20,'0') FROM bdicheq:sc_tarjeta WHERE cuenta = sCuenta AND numcte = p_sNumCte)
					OR a.num_cta_rec = sClabe)
					AND a.cod_operacion = "30"
					ORDER BY a.fecha_presentacion

					RETURN sCodret, sCuenta, sRfc, sRazonSocial, sNumTarjeta, sClabe, sImporte, sCveStatus, sDescripcion, sFechaAplica, sRefNum,
					sRefLeyenda, sImporteMax, sNombreArchivo, sNumSecuencia, sFechaPresentacion, sTipoRegistro, sFolioSuc, NVL(sCausaReverso,'') 
				  --sGrupoReverso WITH RESUME;
				    WITH RESUME;

                END FOREACH;
           END FOREACH;
		   --*****************************************Tipo ## 3 ###, Consulta los movimientos del cliente reversados .*******************************************
		ELIF p_sTipo = '3' THEN
		   FOREACH
				SELECT a.cuenta, a.rfc, b.razon_social, a.imp_maximo, b.cod_grupo_rev
				INTO sCuenta, sRfc, sRazonSocial, sImporteMax, sGrupoReverso
				FROM bdidomi:dom_autorizaciones a
				INNER JOIN bdidomi:dom_cat_servicios b ON a.rfc = b.rfc
				WHERE a.num_cte = p_sNumCte
				ORDER BY a.cuenta

				--SELECT num_tarjeta INTO sNumTarjeta FROM bdicheq:sc_tarjeta WHERE cuenta = sCuenta AND numcte = p_sNumCte;
				SELECT cuenta_clabe INTO sClabe FROM bdicheq:sc_maechq WHERE cuenta = sCuenta;

				--LET sNumTarjeta = LPAD(TRIM(sNumTarjeta),20,'0');
				LET sClabe = LPAD(TRIM(sClabe),20,'0');

				FOREACH
					SELECT SKIP p_iSecuencia a.importe, b.cve_status, b.descripcion, a.fecha_aplica, a.ref_numerica, a.ref_leyenda, a.nombre_arch,
					a.num_secuencia, a.fecha_presentacion, a.tipo_registro, a.folio_suc
					INTO sImporte, sCveStatus, sDescripcion, sFechaAplica, sRefNum, sRefLeyenda, sNombreArchivo, sNumSecuencia,
					sFechaPresentacion, sTipoRegistro, sFolioSuc
					FROM bdidomi:dom_cce_detalle a
					INNER JOIN bdidomi:dom_status_pago b ON a.cve_estatus = b.cve_status
					WHERE a.cve_estatus = '03' --CLave Reversado
					AND a.fecha_presentacion BETWEEN p_sFechaInicial AND p_sFechaFinal
					AND a.rfc_ord = sRfc
					AND (a.num_cta_rec IN (SELECT LPAD(TRIM(num_tarjeta),20,'0') FROM bdicheq:sc_tarjeta WHERE cuenta = sCuenta AND numcte = p_sNumCte)
					OR a.num_cta_rec = sClabe)
					AND a.cod_operacion = "30"
					ORDER BY a.fecha_presentacion

					SELECT cve_reverso INTO sCausaReverso FROM bdidomi:dom_reversos WHERE nombre_arch = sNombreArchivo
					AND fecha_presentacion = sFechaPresentacion AND tipo_registro = sTipoRegistro AND num_secuencia = sNumSecuencia;

       				RETURN sCodret, sCuenta, sRfc, sRazonSocial, sNumTarjeta, sClabe, sImporte, sCveStatus, sDescripcion, sFechaAplica, sRefNum,
					sRefLeyenda, sImporteMax, sNombreArchivo, sNumSecuencia, sFechaPresentacion, sTipoRegistro, sFolioSuc, NVL(sCausaReverso,'') 
				  --sGrupoReverso WITH RESUME;
				    WITH RESUME;
                END FOREACH;
           END FOREACH;
		END IF;
	END;
END PROCEDURE
DOCUMENT
'AUTOR      : Cristian Valentina Aguilar',
'DESCRIPCION: Consulta los movimientos del cliente en el servicio de domiciliacion, en tres secciones los aplicados, reversados y los aplicados y reversados',
'FECHA      : 06/08/2009',
'VERSION    : 20091027.1229, ',
'BD         : BDIDOMI',
'CASO DE USO: Caso de uso asociado PCU-Domciliacion\CU-0005-ConsultarMovtosGeneralDomi-SPL',
'MODIFICADO : Fabiola Corrales. 2009/10/08. Se modifica para agregar la causa cuando exista un reverso (estatus = 03), se modifica la consulta a la sc_tarjetas y la sc_maechq, se agrega el skip para la paginación.',
'MODIFICADO : Fabiola Corrales. 2009/10/27. Se modifica para agregar el campo grupo de reverso para la digitalización del documento',
'MODIFICADO : Ingrid Pamela Cázarez Villegas. 2017/07/20 se modifica para quitar el campo grupo de reverso para la digitalización del documento';

CREATE PROCEDURE "informix".sp_grabarreversodomi(p_sTipo CHAR (1), p_sNumCta CHAR(12),	p_sNumCte CHAR(9), p_sSucursal CHAR (4), p_sNomArch CHAR(20), 
                                     p_dFechaPresentacion CHAR(12), p_sTipoReg CHAR(2), p_sSecuencia CHAR(7), p_sUsuario CHAR(10), p_dFecha DATE,
									 p_sCveReverso CHAR(2))
RETURNING	CHAR(5)  AS Codret;
		
	--definicion de variables
    DEFINE sCodret 		CHAR(5);
	DEFINE sql_err  	INTEGER;
	DEFINE sCveRastreo	CHAR(30);
	DEFINE sFolio		CHAR(16);
	DEFINE sCtaClabe	CHAR(20);
	DEFINE dFechaInsert	DATE;
	DEFINE cCodRetsp	CHAR(5);
	DEFINE dFecha		DATE;
	DEFINE dFechaProx	DATE;
	DEFINE iDiasNat		INTEGER;
	DEFINE cFechaPres	CHAR(8);
	
	--Asignacion de variables
    LET sCodret 		= "00000";
	LET sql_err	    	= 0;
	LET sCveRastreo		= "";
	LET sFolio			= "";
	LET dFechaInsert	= CURRENT::DATE;
	LET cCodRetsp       = '00002';
	LET dFecha			= DATE(1);
	LET dFechaProx	    = DATE(1);
	LET iDiasNat		= 0;
	LET cFechaPres		= '';
	
	--****************************************************************
	--SET DEBUG FILE TO "/tmp/ingrid/sp_GrabarReversoDomi.out";
	--TRACE ON;
	--****************************************************************
	
	BEGIN
		--Manejo de excepciones (errores)
		ON EXCEPTION SET sql_err
			IF sql_err <> 0 THEN
				LET sCodret = sql_err;
				RETURN sCodret;
			END IF;
		END EXCEPTION;		
						 
		--Valida parametros de entrada
		IF NVL(p_sTipo,'') = '' OR NVL(p_dFecha,'') = '' OR NVL(p_dFechaPresentacion, '') = '' OR NVL(p_sNumCta, '') = '' 
		    OR NVL(p_sNumCte,'') = '' OR NVL(p_sSecuencia,'') = '' OR NVL(p_sTipoReg,'') = '' OR NVL(p_sUsuario,'') = '' 
			OR NVL(p_sNomArch,'') = '' OR NVL(p_sSucursal,'') = '' OR NVL(p_sCveReverso,'') = '' THEN
			LET sCodret = "00020"; --Faltan parametros
			RETURN sCodret;			    
		END IF
		
		-- SE OBTIENE EL NUMERO DE DIAS NATURALES
		SELECT valor INTO iDiasNat FROM bdidomi: "informix".dom_parametros WHERE cod_param = '17';
		

		IF EXISTS (SELECT 1 FROM bdidomi:dom_reversos WHERE nombre_arch = p_sNomArch AND fecha_presentacion = p_dFechaPresentacion 
		AND  tipo_registro = p_sTipoReg AND num_secuencia = p_sSecuencia) THEN			
			LET sCodret = "00040"; --La informiacion ya está almacenada.
			RETURN sCodret; 
		END IF;
		
		IF NOT EXISTS (SELECT 1 FROM bdidomi:dom_cce_detalle WHERE nombre_arch = p_sNomArch AND fecha_presentacion = p_dFechaPresentacion 
		AND  tipo_registro = p_sTipoReg AND num_secuencia = p_sSecuencia AND cod_operacion = "30") THEN
			LET sCodret = "00050"; --No existe informacion para los parametros proporcionados
			RETURN sCodret; 
		END IF;
		
		SELECT cuenta_clabe INTO sCtaClabe FROM bdicheq:sc_maechq WHERE cuenta = p_sNumCta;
		LET sCtaClabe = LPAD (TRIM(sCtaClabe),20,'0');
		
		SELECT clave_rastreo, folio_suc 
		INTO sCveRastreo, sFolio 
		FROM  bdidomi:dom_cce_detalle 
		WHERE nombre_arch = p_sNomArch AND fecha_presentacion = p_dFechaPresentacion AND tipo_registro = p_sTipoReg  
		AND num_secuencia = p_sSecuencia AND cod_operacion = "30";
		
		WHILE (cCodRetsp = '00002')
			EXECUTE PROCEDURE BdiDomi:Sp_Valida_Fecha(LPAD (YEAR(p_dFecha), 4, '0') || LPAD (MONTH(p_dFecha), 2, '0') || LPAD (DAY(p_dFecha), 2, '0')) INTO cCodRetsp;
		    
			IF cCodRetsp = '00002' THEN
			LET p_dFecha = p_dFecha + 1;
			END IF;
		END WHILE;		
			
		SELECT fecha, fecha_prox INTO dFecha, dFechaProx
		FROM bdinteg:si_feriado_banca
		WHERE pais = '001' AND fecha = p_dFecha;

		IF dFecha = p_dFecha THEN
			LET p_dFecha = dFechaProx; 
		END IF;
		
		LET cFechaPres = SUBSTR(p_dFechaPresentacion,5,2) || SUBSTR(p_dFechaPresentacion,7,2) || SUBSTR(p_dFechaPresentacion,1,4);
		
		IF p_dFecha > DATE(cFechaPres) + iDiasNat THEN 
			LET sCodret = '00060'; --No se puede reversar porque pasa de los 90 dias naturales
			RETURN sCodret;
		
		ELSE
		
			INSERT INTO bdidomi:dom_reversos (nombre_arch, fecha_presentacion, tipo_registro, num_secuencia, 
			clave_rastreo, fecha_solicitud, num_cte, cuenta, sucursal_sol, 
			procesado, nom_archivo_rev, fecha_presentacion_rev, folio_suc, user_insert, fecha_insert, cve_reverso) 					
			VALUES (p_sNomArch, p_dFechaPresentacion, p_sTipoReg, p_sSecuencia, 
			sCveRastreo, p_dFecha, p_sNumCte, sCtaClabe, p_sSucursal, 'N', ' ', ' ', ' ', p_sUsuario, dFechaInsert, p_sCveReverso);	
		END IF;
		
		RETURN sCodret;				
	END;	
END PROCEDURE
DOCUMENT
'AUTOR      : Cristian Valentina Aguilar',
'DESCRIPCION: Proceso que graba la solicitud de reverso del servicio de domiciliación.',
'FECHA      : 11/08/2009',
'VERSION    : 20090824.0928, 20091008.0946',
'BD         : BDIDOMI',
'CASO DE USO: Caso de uso asociado PCU-Domciliacion\CU-0009-GrabarReversoDomi-SPL',
'MODIFCADO  : Fabiola Corrales 08/Oct/2009. Se modifica para que tome la fecha insert del current del server y grabe la clabe en lugar de la cuenta',
              'ademas se agrega la clave de reverso',
'AUTOR      : Ingrid Pamela Cazarez Villegas',
'DESCRIPCION: Se modifica para que se validen dias inhabiles',
'FECHA      : 30/05/2017',
'AUTOR      : Ingrid Pamela Cazarez Villegas',
'DESCRIPCION: Se modifica para que respete el número de días naturales',
'FECHA      : 29/08/2017';

CREATE PROCEDURE "informix".sp_domi_procesararchivo34 (pNomArch CHAR(20),pUsuario CHAR(8))
RETURNING CHAR(5),CHAR(80);

DEFINE vcSql 			CHAR(1000);		-- COMANDO QUE SE EJECUTA EN EL ARCHIVO.SQL
DEFINE vcStmt 			CHAR(50); 		-- EJECUCION DE ARCHIVO SQL
DEFINE vcodRet 			CHAR(6); 		-- CODIGO DE RETORNO
DEFINE vsqlerr 			integer;		-- VARIABLE PARA CACHAR EL CODIGO DE ERRORDEFINE vsqlerr integer;
DEFINE iIsamErr 		smallint;		-- VARIABLE PARA CACHAR EL CODIGO DE ERROR
DEFINE cErrorInfo 		CHAR(80);  		-- VARIABLE PARA CACHAR LA DESCRIPCION DEL ERROR
DEFINE vErrorInfo 		CHAR(80);		-- VARIABLE PARA RETORNAR EL MENSAJE DE ERROR O MENSAJE DE EXITO
DEFINE dfecha 			date; 			-- DIAS
DEFINE dfechaactual 	date; 			-- CONTIENE LA FECHA DEL DIA DE HOY
DEFINE cCveProceso 		CHAR(20); 		-- CLAVE DEL PROCESO
DEFINE sProceso 		CHAR(20);		-- PROCESO QUE SE MANDA A LA TABLA
DEFINE cNumeroFolio 	CHAR(16);		-- FOLIO PARA REGISTRAR EL CARGO
DEFINE cTransacc 		CHAR(4);		-- FOLIO DE TRANSACCION DEL CARGO
DEFINE cSucursalSol 	CHAR(4); 		-- SUCURSAL  QUE OBTENEMOS DE LA TABLA DE PARAMETROS

--VARIABLES PARA LA TABLA dom_cce_detalle
DEFINE cNombreArchdet 	CHAR(20); 		-- NOMBRE DE ARCHIVO
DEFINE cFechaPresdet 	CHAR(8);   		-- FECHA DE PRESENTACION
DEFINE cTipoRegdet 		CHAR(2);		-- TIPO DE REGISTRO TABLA
DEFINE cNumSecdet 		CHAR(7);		-- NUMERO DE SECUENCIA
DEFINE cImportedet 		CHAR(15);		-- IMPORTE
DEFINE cTipoCtaOrddet 	CHAR(2);		-- TIPO DE CUENTA ORDENANTE
DEFINE cNumCtaOrddet 	CHAR(20);		-- NUMERO DE CUENTA DEL ORDENANTE
DEFINE cRefLeyendadet 	CHAR(40);		-- REFERENCIA LEYENDA

--VARIABLES PARA LA TABLA dom_cce_detalle_paso
DEFINE cNombreArchpas 	CHAR(20); 		-- NOMBRE DE ARCHIVO
DEFINE cFechaPrespas	CHAR(8);   		-- FECHA DE PRESENTACION
DEFINE cTipoRegpas 		CHAR(2);		-- TIPO DE REGISTRO
DEFINE cNumSecpas 		CHAR(7);		-- NUMERO DE SECUENCIA
DEFINE cImportepas 		CHAR(15);		-- IMPORTE
DEFINE cTipoOppas 		CHAR(2);		-- TIPO DE OPERACION
DEFINE cFechaAplicapas 	CHAR(8);		-- FECHA DE APLICACION
DEFINE cTipoCtaOrdpas 	CHAR(2);		-- TIPO DE CUENTA ORDENANTE
DEFINE cNumCtaOrdpas 	CHAR(20);		-- NUMERO DE CUENTA DEL ORDENANTE
DEFINE cRfcOrdpas     	CHAR(18);		-- RFC DEL ORDENANTE
DEFINE cTipoCtaRecpas  	CHAR(2);		-- TIPO DE CUENTA DEL RECEPTOR
DEFINE cNumCtaRecpas   	CHAR(20);		-- NUMERO DE CUENTA DEL RECEPTOR
DEFINE cRfcRecpas      	CHAR(18);		-- RFC DEL RECEPTOR
DEFINE cRefServiciopas 	CHAR(40);		-- REFERENCIA DEL SERVICIO CON EL EMISOR
DEFINE cRefLeyendapas	CHAR(40);		-- LEYENDA DE LA REFERENCIA

DEFINE bDia 			boolean;		-- BANDERA QUE NOS INDICA SI EL DIA ES VALIDO PARA APLICAR EL REVERSO
DEFINE cFechaFor 		CHAR(8);		-- FECHA ACTUAL CON EL FORMATO YYYYMMDD
DEFINE iExiste 			integer;		-- PARA SABER SI EXISTE LA TRANSACCION EN LA TABLA DE TRANSACCIONES DE LA BDINTEG
DEFINE mSaldoActual 	money(16,2);	-- SALDO ACTUAL DEL PROVEEDOR
DEFINE cCtaEfectiva		CHAR(20);		-- CUENTA PARAMETRIZADA A LA QUE SE ABONA EN CASO DE NO HABER SALDO EN LA CUENTA DEL PROVEEDOR
DEFINE cCodRetMensaje	CHAR(6);		-- CODIGO DE ERROR QUE REGRESA EL SP sp_obtenermensajeerror

DEFINE cTranRet 		CHAR(4);		-- CODIGO DE TRANSACCION QUE REGRESA EL SP cargo_ref
DEFINE dFecha_hoy 		date;			-- FECHA QUE REGRESA EL SP cargo_ref
DEFINE mSdoDisp 		money(14,2);	-- SALDO DISPONIBLE QUE REGRESA EL SP cargo_ref
DEFINE mMontoRet 		money(14,2);	-- MONTO QUE REGRESA EL SP cargo_ref

DEFINE dFechaRecep		date;			-- FECHA DE RECEPCION
DEFINE cTransaccA 		CHAR(4);		-- FOLIO DE TRANSACCION DEL ABONO
DEFINE cNumeroTarjeta	CHAR(20); 		-- NUMERO DE TARJETA DEL CLIENTE
DEFINE sTabladet		smallint;		-- PARA SABER SI SE CREO LA TABLA TEMPORAL DE LOS DETALLES
DEFINE sTablaAbo		smallint;		-- PARA SABER SI SE CREO LA TABLA TEMPORAL DE LOS ABONOS
DEFINE idiasnat 		integer;  		-- CANTIDAD DE DIAS NATURALES EL VALOR SE OBTIENE DE  LA TABLA DE PARAMETROS
DEFINE cSqlState		CHAR(8);		-- VARIABLE PARA VERIFICAR LOS ERRORES EN LAS SENTENCIAS EJECUTADAS
DEFINE mImporte			money(16,2);	-- IMPORTE
DEFINE cStatusCta		CHAR(1);		-- ESTATUS DE LA CUENTA
DEFINE cMensajeDev		CHAR(50);		-- DESCRIPCION DEL MOTIVO DE DEVOLUCION

DEFINE cNumCte_Coppel 	CHAR(20);
DEFINE cRfcCoppel		CHAR(20);
DEFINE cNom_Arch_Salida	CHAR(20);
DEFINE cSecuencia_Salida CHAR(6);
DEFINE cSecuencia_Entrada CHAR(6);

LET vcSql 				= "";
LET vcStmt 				= "";
LET vcodRet 			= '000';
LET vsqlerr 			= 0;
LET iIsamErr 			= 0;
LET cErrorInfo 			= "";
LET vErrorInfo 			= "";
LET dfecha 				= DATE(1);
LET dfechaactual 		= DATE(1);
LET cCveProceso 		= "";
LET sProceso 			= "PROCESAR ARCH. 34";
LET cTransacc 			= "";
LET cSucursalSol 		= "";

LET cNombreArchdet 		= "";
LET cFechaPresdet 		= "";
LET cTipoRegdet 		= "";
LET cNumSecdet 			= "";
LET cImportedet 		= "";
LET cTipoCtaOrddet 		= "";
LET cNumCtaOrddet 		= "";
LET cRefLeyendadet 		= "";

LET cNombreArchpas 		= "";
LET cFechaPrespas		= "";
LET cTipoRegpas 		= "";
LET cNumSecpas 			= "";
LET cImportepas 		= "";
LET cTipoOppas 			= "";
LET cFechaAplicapas		= "";
LET cTipoCtaOrdpas 		= "";
LET cNumCtaOrdpas 		= "";
LET cRfcOrdpas     		= "";
LET cTipoCtaRecpas 		= "";
LET cNumCtaRecpas  		= "";
LET cRfcRecpas     		= "";
LET cRefServiciopas		= "";
LET cRefLeyendapas		= "";

LET bDia				= "F";
LET iExiste 			= 0;
LET mSaldoActual 		= 0;
LET cCtaEfectiva		= "";

LET dFechaRecep			= date(1);
LET cTransaccA			= "";
LET cNumeroTarjeta		= "";
LET sTabladet 			= 0;
LET sTablaAbo 			= 0;
LET idiasnat			= 0;
LET cSqlState			= "";
LET mImporte			= 0;
LET cStatusCta			= "0";
LET cMensajeDev			= "";

LET cNumCte_Coppel		= '';
LET cRfcCoppel			= '';
LET cNom_Arch_Salida	= '';
LET cSecuencia_Salida	= '';
LET cSecuencia_Entrada  = '';

BEGIN

	ON EXCEPTION  SET vsqlerr, iIsamErr, cErrorInfo
		IF vsqlerr <> 0  THEN
			LET  vCodRet  = vsqlerr;
			LET vErrorInfo = cErrorInfo;

			IF  sTablaAbo = 1 THEN
				FOREACH
					--SE OBTIENEN TODOS LOS CARGOS QUE SE HICIERON
					SELECT sucursal,transacc,cuenta,importe,num_tarjeta
					INTO cSucursalSol,cTransaccA,cNumCtaOrddet,cImportedet,cNumeroTarjeta
					FROM tmpAbono

					-- SE GENERA EL FOLIO PARA LA TRANSACCION
					CALL bdicheq:sp_generafolionomina (pUsuario) RETURNING vcodRet, cNumeroFolio;

					-- SE APLICA EL ABONO
					CALL bdicheq:abono_ref ("001", cSucursalSol, pUsuario, cTransaccA, "0000", cNumeroFolio, cNumCtaOrddet, 0,
											cImportedet, cImportedet, 0, 0, 0, "01", " ", cNumeroTarjeta, pUsuario) RETURNING vcodret;

				END FOREACH;

				-- SE ELIMINA LA TABLA TEMPORAL
				DROP TABLE tmpAbono;
			END IF ;

			IF  sTabladet = 1 THEN
				FOREACH
					SELECT nombre_arch,fecha_presentacion,tipo_registro,num_secuencia
					INTO cNombreArchdet,cFechaPresdet,cTipoRegdet,cNumSecdet
					FROM tmp_dom_cce_detalle

					--SE ACTUALIZA LA TABLA DE DETALLES
					UPDATE bdidomi:dom_cce_detalle SET cve_estatus = "01", motivo_dev = "00"
					WHERE nombre_arch = cNombreArchdet AND fecha_presentacion = cFechaPresdet AND tipo_registro = cTipoRegdet
							AND num_secuencia = cNumSecdet AND cve_estatus = '03';

					--SE ACTUALIZA LA TABLA DE DETALLE PASO
					UPDATE bdidomi:dom_cce_detalle_paso SET folio_suc = ""
					WHERE nombre_arch = cNombreArchdet AND fecha_presentacion = cFechaPresdet AND tipo_registro = cTipoRegdet
						  AND num_secuencia = cNumSecdet;

					-- SE ACTUALIZA LA TABLA DE CTE_DETALLES
					UPDATE bdidomi:dom_cte_detalle SET estatus = "01", causa_rechazo = ""
					WHERE nombre_arch_cce = cNombreArchdet AND fecha_presentacion_cce = cFechaPresdet AND tipo_registro_cce = cTipoRegdet
						  AND numero_secuencia_cce = cNumSecdet;
					
					DELETE FROM dom_cte_detalle
					WHERE nombre_arch = cNom_Arch_Salida
					AND nombre_arch_cce = cNombreArchdet
					AND fecha_presentacion_cce = cFechaPresdet 
					AND tipo_registro_cce = cTipoRegdet
					AND numero_secuencia_cce = cNumSecdet 
					AND estatus = '03';

				END FOREACH;

				DROP TABLE tmp_dom_cce_detalle;
			END IF ;

			RETURN vCodRet, vErrorInfo;

		END IF;
	END  EXCEPTION

/*
 SET debug file to "/tmp/Pulido/PRUEBAPUL.out";
 trace on;
*/
	-- SE OBTIENE LA FECHA DE LA TABLA SC_FECHAS DE LA BD BDICHEQ
	SELECT fecha_hoy,YEAR(fecha_hoy) || LPAD(TRIM(month(fecha_hoy)::CHAR(2)),2,'0') || LPAD(TRIM(DAY(fecha_hoy)::CHAR(2)),2,'0')
	INTO dfechaactual,cFechaFor
	FROM bdicheq:sc_fechas;

	-- SE OBTIENE LA SUCURSAL
	SELECT valor INTO cSucursalSol FROM bdidomi:dom_parametros WHERE cod_param ='07';

	-- SE OBTIENE EL NUMERO DE TRANSACCION PARA EL CARGO
	SELECT valor INTO cTransacc FROM bdidomi:dom_parametros WHERE cod_param ='35';  --T Cargo reverso

	-- SE OBTIENE EL NUMERO DE TRANSACCION PARA EL ABONO
	SELECT valor INTO cTransaccA FROM bdidomi:dom_parametros WHERE cod_param ='34'; --T Abono reverso

	-- SE OBTIENE LA CUENTA DEUDORA
	SELECT valor INTO cCtaEfectiva FROM bdidomi:dom_parametros WHERE cod_param ='13';

	-- SE OBTIENEN LOS DIAS NATURALES
	SELECT valor INTO idiasnat FROM bdidomi:dom_parametros WHERE cod_param ='17';

	-- SE OBTIENE LA DESCRIPCION DEL MOTIVO DE RECHAZO
	SELECT TRIM(descripcion) INTO cMensajeDev FROM bdidomi:dom_cat_devoluciones WHERE motivo_dev="13";

	-- SE VALIDA SI EXISTE LA TRANSACCION EN LA TABLA DE TRANSACCIONES DE LA BDINTEG
	SELECT COUNT(numero) INTO iExiste FROM bdinteg:si_transacc WHERE numero = cTransacc;
	IF iExiste < 1 Then
		LET vCodRet = '01802';
		CALL sp_obtenermensajeerror (vCodRet) RETURNING cCodRetMensaje,vErrorInfo;
		RETURN vCodRet,vErrorInfo;
	ELSE
		LET iExiste = 0;
	END IF;

	-- SE CREAN LAS TABLAS TEMPORALES POR SI EL PROCESO MARCA ERROR PODER REVERSAR TODAS LAS OPERACIONES
	-- TABLA PARA REVERSAR LOS MOVIMIENTOS DEL DETALLE EN CASO DE ERROR
	CREATE TABLE tmp_dom_cce_detalle (nombre_arch CHAR(20), fecha_presentacion CHAR(8), tipo_registro CHAR(2), num_secuencia CHAR(7));
	LET sTabladet = 1;

	-- TABLA PARA REVERSAR LOS CARGOS EN CASO DE ERROR
	CREATE TABLE tmpAbono (sucursal CHAR(4),transacc CHAR(4),cuenta CHAR(20),importe money(16,2),num_tarjeta CHAR(16));
	LET sTablaAbo = 1;

	--SE OBTIENE NUMERO DE CLIENTE COPPEL
	SELECT TRIM(valor) INTO cNumCte_Coppel 
	FROM dom_parametros 
	WHERE cod_param = '45';
	
	--SE OBTIENE VALOR DE RFC COPPEL	
	SELECT rfc 
	INTO cRfcCoppel 
	FROM dom_cat_servicios 
	WHERE num_cte = TRIM(cNumCte_Coppel);
		
	--SE OBTIENE NOMBRE DE ARCHIVO DE SALIDA PARA COPPEL 
	LET cNom_Arch_Salida = 	'S'||
							TRIM(cNumCte_Coppel)||
							'D'||
							LPAD(DAY(dfechaactual),2,'0') || 	LPAD(MONTH(dfechaactual),2,'0') || SUBSTR(YEAR(dfechaactual)::CHAR(4),3,2)||
							'.'||
							'01';

	SET ISOLATION TO DIRTY READ;

	FOREACH WITH HOLD
		-- OBTENEMOS LOS DATOS DEL DETALLE PASO
		SELECT nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,importe,tipo_operacion,fecha_aplica,tipo_cta_ord,
				num_cta_ord,rfc_ord,tipo_cta_rec,num_cta_rec,rfc_rec,ref_servicio, LEFT("REVERSO-DOMI" || ref_leyenda,40)
		INTO cNombreArchpas,cFechaPrespas,cTipoRegpas,cNumSecpas,cImportepas,cTipoOppas,cFechaAplicapas,cTipoCtaOrdpas,
			cNumCtaOrdpas,cRfcOrdpas, cTipoCtaRecpas,cNumCtaRecpas,cRfcRecpas,cRefServiciopas,cRefLeyendapas
		FROM bdidomi:dom_cce_detalle_paso
		WHERE nombre_arch = pNomArch

		-- FORMATEO DE FECHA PARA EFECTUAR LA OPERACION DE FECHA PARA OBTENER LOS DIAS
		LET dFechaRecep = MDY(SUBSTRING(cFechaPrespas FROM 5 for 2),SUBSTRING(cFechaPrespas FROM 7 for 2),SUBSTRING(cFechaPrespas FROM 1 for 4));

		-- OBTENEMOS LA FECHA LIMITE DE LOS DIAS HABLIES
		LET dfecha = dFechaRecep + idiasnat;

		-- SE VERIFICA SI SE ENCUENTRA DENTRO DE EL RANGO DE DIAS PERMITIDO
		IF  dfechaactual > dfecha THEN
			IF  dfechaactual = dfecha + 1 THEN
				IF  EXISTS (SELECT fecha FROM bdinteg:si_feriado WHERE fecha = dfechaactual - 1 UNITS DAY) THEN
					LET bDia = "T";
				ELSE
					LET bDia = "F";
				END IF ;
			ELSE
				LET bDia = "F";
			END IF ;
		ELSE
			LET bDia = "T";
		END IF ;

		-- VALIDAMOS QUE EXISTA EL ORIGINAL
		IF  NOT EXISTS (SELECT nombre_arch FROM bdidomi:dom_cce_detalle
					   WHERE importe = cImportepas AND tipo_operacion = cTipoOppas AND fecha_aplica = cFechaAplicapas
						     AND tipo_cta_ord = cTipoCtaOrdpas AND num_cta_ord = cNumCtaOrdpas AND rfc_ord = cRfcOrdpas
							AND tipo_cta_rec = cTipoCtaRecpas AND num_cta_rec = cNumCtaRecpas AND rfc_rec = cRfcRecpas
							AND ref_servicio = cRefServiciopas AND cod_operacion = "30" AND cve_estatus = '01') THEN

			LET vCodRet = '01801';
			CALL sp_obtenermensajeerror (vCodRet) RETURNING cCodRetMensaje,vErrorInfo;

			-- SE COMPRUEBA SI FUE CREADA LA TABLA TEMPORAL PARA ABONOS SE HA CREADO
			IF  sTablaAbo = 1 THEN
				FOREACH
					-- SE OBTIENEN TODOS LOS CARGOS QUE SE HICIERON
					SELECT sucursal,transacc,cuenta,importe,num_tarjeta
					INTO cSucursalSol,cTransaccA,cNumCtaOrddet,cImportedet,cNumeroTarjeta
					FROM tmpAbono

					-- SE GENERA EL FOLIO PARA LA TRANSACCION
					CALL bdicheq:sp_generafolionomina (pUsuario) RETURNING vcodRet, cNumeroFolio;

					-- SE APLICA EL ABONO
					CALL bdicheq:abono_ref ("001", cSucursalSol, pUsuario, cTransaccA, "0000", cNumeroFolio, cNumCtaOrddet, 0,
											cImportedet, cImportedet, 0, 0, 0, "01", " ", cNumeroTarjeta, pUsuario) RETURNING vcodret;

				END FOREACH;

				-- SE ELIMINA LA TABLA TEMPORAL
				DROP TABLE tmpAbono;
			END IF ;

			-- SE COMPRUEBA SI FUE CREADA LA TABLA TEMPORAL PARA LOS DETALLES
			IF  sTabladet = 1 THEN
				FOREACH
					SELECT nombre_arch,fecha_presentacion,tipo_registro,num_secuencia
					INTO cNombreArchdet,cFechaPresdet,cTipoRegdet,cNumSecdet
					FROM tmp_dom_cce_detalle

					-- SE ACTUALIZA LA TABLA DE DETALLES
					UPDATE bdidomi:dom_cce_detalle SET cve_estatus = "01", motivo_dev = "00"
					WHERE nombre_arch = cNombreArchdet AND fecha_presentacion = cFechaPresdet AND tipo_registro = cTipoRegdet
							AND num_secuencia = cNumSecdet AND cve_estatus = '03';

					-- SE ACTUALIZA LA TABLA DE DETALLE PASO
					UPDATE bdidomi:dom_cce_detalle_paso SET folio_suc = ""
					WHERE nombre_arch = cNombreArchdet AND fecha_presentacion = cFechaPresdet AND tipo_registro = cTipoRegdet
						  AND num_secuencia = cNumSecdet;

					-- SE ACTUALIZA LA TABLA DE CTE_DETALLES
					UPDATE bdidomi:dom_cte_detalle SET estatus = "01", causa_rechazo = ""
					WHERE nombre_arch_cce = cNombreArchdet AND fecha_presentacion_cce = cFechaPresdet AND tipo_registro_cce = cTipoRegdet
						  AND numero_secuencia_cce = cNumSecdet;

				END FOREACH;

				DROP TABLE tmp_dom_cce_detalle;
			END IF ;

			RETURN vCodRet, vErrorInfo;

		-- SE VALIDA QUE ESTE DENTRO DE LOS SIGUIENTES 90 DIAS HABILES
		ELIF bDia="F" THEN
			CONTINUE FOREACH;

		-- SE VALIDA QUE NO SE ENCUENTRE REVERSADO
		ELIF EXISTS (SELECT nombre_arch,fecha_presentacion FROM bdidomi:dom_cce_detalle
					WHERE importe = cImportepas AND tipo_operacion = cTipoOppas AND fecha_aplica = cFechaAplicapas
						   AND tipo_cta_ord = cTipoCtaOrdpas AND num_cta_ord = cNumCtaOrdpas AND rfc_ord = cRfcOrdpas
						   AND tipo_cta_rec = cTipoCtaRecpas AND num_cta_rec = cNumCtaRecpas AND rfc_rec = cRfcRecpas
						   AND ref_servicio = cRefServiciopas AND cod_operacion = "30" AND cve_estatus = '03') THEN
			CONTINUE FOREACH;

		-- SE VALIDA QUE NO SE ENCUENTRE DEVUELTO
		ELIF EXISTS (SELECT nombre_arch,fecha_presentacion FROM bdidomi:dom_cce_detalle
						WHERE importe = cImportepas AND tipo_operacion = cTipoOppas AND fecha_aplica = cFechaAplicapas
						   AND tipo_cta_ord = cTipoCtaOrdpas AND num_cta_ord = cNumCtaOrdpas AND rfc_ord = cRfcOrdpas
						   AND tipo_cta_rec = cTipoCtaRecpas AND num_cta_rec = cNumCtaRecpas AND rfc_rec = cRfcRecpas
						   AND ref_servicio = cRefServiciopas AND cod_operacion = "30" AND motivo_dev <> '00') THEN
			CONTINUE FOREACH;

		END IF ;

		-- SE OBTIENE LOS DATOS DEL DETALLE ORIGINAL
		SELECT nombre_arch,fecha_presentacion,tipo_registro,num_secuencia,tipo_cta_ord,SUBSTR (num_cta_ord,9,11)
		INTO cNombreArchdet,cFechaPresdet,cTipoRegdet,cNumSecdet,cTipoCtaOrddet,cNumCtaOrddet
		FROM bdidomi:dom_cce_detalle
		WHERE importe = cImportepas AND tipo_operacion = cTipoOppas AND fecha_aplica = cFechaAplicapas AND tipo_cta_ord = cTipoCtaOrdpas
			  AND num_cta_ord = cNumCtaOrdpas AND rfc_ord = cRfcOrdpas AND tipo_cta_rec = cTipoCtaRecpas AND num_cta_rec = cNumCtaRecpas
			  AND rfc_rec = cRfcRecpas AND ref_servicio = cRefServiciopas AND cod_operacion = "30" AND cve_estatus = '01';
		/*
		SELECT tipo_cta_ord,SUBSTR (num_cta_ord,9,11) INTO cTipoCtaOrddet,cNumCtaOrddet FROM bdidomi:dom_cce_detalle
		WHERE nombre_arch = cNombreArchdet AND fecha_presentacion = cFechaPresdet AND tipo_registro = cTipoRegdet AND num_secuencia = cNumSecdet
			  AND cve_estatus = '01';
		*/
		-- SE OBTIENE EL SALDO DE LA CUENTA DEL PROVEEDOR
		SELECT sdo_actual-(sdo_cong + sdo_retenido + imp_chq_sbg)
		INTO mSaldoActual
		FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = cNumCtaOrddet;

		LET mImporte = cImportepas::integer/100;

		-- SE VERIFICA EL SALDO DEL PROVEEDOR, SI NO ES SUFICIENTE SE UTILIZA UNA CUENTA PARAMETRIZADA
		IF  nvl(mSaldoActual,0) < mImporte THEN
			LET cNumCtaOrddet = cCtaEfectiva;
		END IF ;


		--SE OBTIENE EL STATUS DE LA CUENTA
		SELECT status_cta INTO cStatusCta FROM bdicheq:sc_maechq WHERE empresa = '001' AND cuenta = cNumCtaOrddet;

		-- SE CHECA SI LA CUENTA SE ENCUENTRA BLOQUEADA
		IF  cStatusCta = "2" THEN
			LET vCodRet = '01803';
			LET cNumCtaOrddet = cCtaEfectiva;
		ELIF cStatusCta = "3" THEN -- SE CHECA SI LA CUENTA SE ENCUENTRA CANCELADA
			LET vCodRet = '01804';
			LET cNumCtaOrddet = cCtaEfectiva;
		END IF ;
		
		-- SE GENERA EL FOLIO PARA LA TRANSACCION
		CALL bdicheq:sp_generafolionomina (pUsuario) RETURNING vcodRet, cNumeroFolio;

		-- SE APLICA EL CARGO
		CALL bdicheq:cargo_ref ("001", cSucursalSol, pUsuario, cTransacc, "0000", cNumeroFolio,cNumCtaOrddet,0,mImporte,"01",
							cRefLeyendapas, '', pUsuario) RETURNING vCodRet,cTranRet,dFecha_hoy,mSdoDisp,mMontoRet;

		--CHECAMOS QUE NO HAYA OCURRIDO NINGUN ERROR AL MOMENTO DE GENERAR EL ABONO
		IF vcodret <> "000" THEN

		ELSE
			-- SE OBTIENE EL NUMERO DE LA TARJETA DEL CLIENTE
			Select NVL(num_tarjeta, '') INTO cNumeroTarjeta From bdicheq:sc_tarjeta
			WHERE empresa = '001' AND cuenta = cNumCtaOrddet AND  tipo_tarjeta = "T" AND status_tar = "A";

			-- SE INSERTAN LOS DATOS EN LA TABLA TEMPORAL POR SI ES NECESARIO REVERSAR LOS CARGOS APLICADOS
			INSERT INTO tmpAbono (sucursal,transacc,cuenta,importe,num_tarjeta)
			VALUES (cSucursalSol,cTransaccA,cNumCtaOrddet,mImporte,cNumeroTarjeta);
		END IF ;

		-- SE ACTUALIZA LA TABLA DE DETALLES
		UPDATE bdidomi:dom_cce_detalle SET cve_estatus = "03", motivo_dev = "13"
		WHERE nombre_arch = cNombreArchdet AND fecha_presentacion = cFechaPresdet AND tipo_registro = cTipoRegdet AND num_secuencia = cNumSecdet
			  AND cve_estatus = '01';
		
		
		-- SE ACTUALIZA LA TABLA DE DETALLE PASO
		UPDATE bdidomi:dom_cce_detalle_paso SET folio_suc = cNumeroFolio
		WHERE nombre_arch = pNomArch AND fecha_presentacion = cFechaPrespas AND tipo_registro = cTipoRegpas
			  AND num_secuencia = cNumSecpas;

		-- SE ACTUALIZA LA TABLA DE CTE_DETALLES			
		UPDATE bdidomi:dom_cte_detalle SET estatus = "03", causa_rechazo = DECODE (cRfcOrdpas, cRfcCoppel,'13',cMensajeDev)
		WHERE nombre_arch_cce = cNombreArchdet AND fecha_presentacion_cce = cFechaPresdet AND tipo_registro_cce = cTipoRegdet
			  AND numero_secuencia_cce = cNumSecdet;
		
		IF cRfcOrdpas = cRfcCoppel THEN
			SELECT LPAD(TRIM((COUNT(consecutivo) + 1)::INTEGER::CHAR(6)),6,'0')
			INTO  cSecuencia_Salida FROM bdidomi:dom_cte_detalle_paso
			WHERE nombre_arch = cNom_Arch_Salida;
			
			INSERT INTO dom_cte_detalle_paso(nombre_arch, fecha_envio, tipo_registro, consecutivo, fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo, 
			cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta,
			estatus, causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert, fecha_insert, tipo_cta_abono, folio_suc)
			SELECT 	cNom_Arch_Salida, CURRENT::DATE, tipo_registro, cSecuencia_Salida , fecha_cargo, fecha_abono, tipo_cta_cargo, cve_banco_cargo,  
			cuenta_cargo, rfc_cargo, nombre_cargo, cuenta_abono, imp_operacion, imp_iva, ref_numerica, ref_leyenda, ref_servicio, ref_titular_serv, accion, reintentar_cuenta,
			estatus, causa_rechazo, nombre_arch_cce, fecha_presentacion_cce, tipo_registro_cce, numero_secuencia_cce, comision_cobrada, iva_cobrado, user_insert, CURRENT::DATE, tipo_cta_abono, folio_suc
			FROM dom_cte_detalle
			WHERE nombre_arch_cce = cNombreArchdet
			AND fecha_presentacion_cce = cFechaPresdet 
			AND tipo_registro_cce = cTipoRegdet
			AND numero_secuencia_cce = cNumSecdet 
			AND LEFT( nombre_arch, 1 ) = 'S'
			AND estatus = '03';				
		END IF;
		
		-- SE INSERTA UN REGISTRO EN LA TABLA TEMPORAL POR SI ES NECESARIO REVERSAR LOS MOVIMIENTOS EN LAS TABLAS DE DETALLES
		INSERT INTO tmp_dom_cce_detalle (nombre_arch, fecha_presentacion, tipo_registro, num_secuencia)
		VALUES (cNombreArchdet,cFechaPresdet,cTipoRegdet,cNumSecdet);

	END FOREACH;

	DROP TABLE tmpAbono;
	LET sTablaAbo = 0;
	DROP TABLE tmp_dom_cce_detalle;
	LET sTabladet = 0;
	LET vCodRet = '00000';
	LET vErrorInfo = 'PROCESO EXITOSO';
	RETURN vCodRet,vErrorInfo;


END;
END PROCEDURE

DOCUMENT
'AUTOR: Jose Luis Pulido Zepeda',
'Descripcion: PROCESA el archivo 34',
'Fecha: 2009/07/22',
'Version: 20090727.1005',
'BD: BDIDOMI',

'MODIFICO: Jose Luis Pulido Zepeda',
'Descripcion: Se agrego un commit despues de ejecutar el SP cargo_ref ',
'Fecha: 2009/08/06',
'Version: 20090806.1743',

'MODIFICO: Jose Luis Pulido Zepeda',
'Descripcion: Se agrego el dividir la cantidad del importe entre 100 para obtener el importe real ',
'Fecha: 2009/08/06',
'Version: 20090806.1820',

'MODIFICO: Jose Luis Pulido Zepeda',
'Descripcion: Se agregaron tablas temporales para llevar el registro de los cargos que se realizaron y de los cambios que se hicieron ',
'				en la tabla de detalles y detalles paso pro si se da algun error se puedan reversar los cambios',
'Fecha: 2009/08/10',
'Version: 20090810.1240',

'MODIFICO: Jose Luis Pulido Zepeda',
'Descripcion: Se quito la insercion en la tabla de errores, tambien se agrego obtener los dias naturales de la tabla de parametros',
'Fecha: 2009/08/11',
'Version: 20090811.1143',

'MODIFICO: Jose Luis Pulido Zepeda',
'Descripcion: Se agrego cachar error cuando se ejecuta el commit sin haber transaccion',
'Fecha: 2009/08/12',
'Version: 20090812.1502',


'MODIFICO: Jose Luis Pulido Zepeda',
'Descripcion: Se cambio la llave de busqueda para el original de los archivos en la tabla de detalles, ahora se usa lo siguiente:',
'			  Importe de operacion, tipo de operacion, fecha de aplicacion, tipo de cuenta del ordenante, numero de cuenta del ordenante,',
'			  RFC del ordenante, tipo de cuenta del receptor, numero de cuenta del receptor, RFC del receptor, referencia del servicio con el,',
'			  emisor.',
'Fecha: 2009/08/13',
'Version: 20090813.1812',

'Modifico: Jose Luis Pulido',
'Descripcion del cambio: Se agrego validacion paras saber si la cuenta esta bloqueada o cancelada, tambien se agrego registrar en la bitacora',
'						de errores cuando no se puede generar un cargo.',
'Fecha: 2009/08/19',
'Version: 20090819.1203',

'Modifico: Jose Luis Pulido',
'Descripcion del cambio: Se cambio la operacion para obtener la fecha limite, ahora se hace sumando los dias naturales a la fecha de presentacion',
'						y se compara con la fecha actual.',
'Fecha: 2009/09/03',
'Version: 20090903.1145',

'Modifico: Jose Luis Pulido',
'Descripcion del cambio: Se agrego el filtro de validacion cod_operacion = "30" para verificar que exista el archivo original.',
'Fecha: 2009/09/07',
'Version: 20090907.1036',

'Modifico: Jose Luis Pulido',
'Descripcion del cambio: Se agrego actualizar la tabla bdidomi:dom_cte_detalle los campos estatus y causa_rechazo.',
'Fecha: 2009/09/07',
'Version: 20090907.1301',

'Modifico: Jose Luis Pulido',
'Descripcion del cambio: Se agrego filtro para que tambien busque por estatus = 01 cuando se esta validando que existe el registro original.',
'Fecha: 2009/09/21',
'Version: 20090921.0852';

CREATE PROCEDURE "informix".sp_domi_generar_comprimido_b()
RETURNING VARCHAR(5) AS cCodRet, VARCHAR(100) AS cMensaje, VARCHAR(100) AS cArchivo;

DEFINE vsSQL 			CHAR(1000);
DEFINE cCodRet			VARCHAR(5);
DEFINE viSqlErr			INTEGER;
DEFINE cNombreArchResp	CHAR(20);
DEFINE cRutaarchivoResp CHAR(100);
DEFINE cRutaNombreArch 	CHAR(1000);
DEFINE cMensaje			VARCHAR(100);

LET vsSQL 				= '';
LET cCodRet 			= '';
LET viSqlErr			= '';
LET cNombreArchResp	 	= '';
LET cRutaarchivoResp 	= '';
LET cRutaNombreArch		= '';
LET cMensaje			= '';


--SET DEBUG FILE TO "/tmp/ingrid/sp_domi_generar_comprimido_b.out";
--TRACE ON;


BEGIN

		ON EXCEPTION SET viSqlErr   
				IF viSqlErr <> 0 THEN
				RETURN viSqlErr, 'ERROR AL COMPRIMIR EL ARCHIVO', '';
				END IF;
		END EXCEPTION;

		
		--SE OBTIENE RUTA DONDE SE DEPOSITA ARCHIVO DE RESPUESTA
		SELECT valor 
		INTO cRutaarchivoResp
		FROM dom_parametros
		WHERE cod_param = '02';
		
		
		--SE OBTIENE NOMBRE DE ARCHIVOS DE RESPUESTA GENERADOS 
		FOREACH WITH HOLD
		
			SELECT DISTINCT nombre_arch
			INTO cNombreArchResp
			FROM dom_cte_archivos 
			WHERE LEFT( nombre_arch, 1) = 'S'
			AND SUBSTR( nombre_arch, 11, 1) = 'B'
			AND fecha_insert = TODAY
			
			LET cRutaNombreArch = TRIM(cRutaNombreArch) || ' ' || TRIM(cRutaarchivoResp)|| TRIM(cNombreArchResp);
			
		END FOREACH;
	
		IF cRutaNombreArch <> '' THEN
			
			LET vsSQL = 'zip '||TRIM(cRutaarchivoResp)||'RespuestaDomiciliacionB' || TO_CHAR( TODAY , '%Y%m%d' ) || '.zip '||'-P bancoppel ' ||cRutaNombreArch;
			SYSTEM vsSQL;
			
			LET cCodRet = '01424';
			LET cMensaje = 'ARCHIVO COMPRIMIDO';
			RETURN cCodRet, cMensaje, TRIM(cRutaarchivoResp)||'RespuestaDomiciliacionB' || TO_CHAR( TODAY , '%Y%m%d' ) || '.zip';
		
		ELSE 
		
			LET cCodRet = '01426';
			LET cMensaje = 'NO HAY ARCHIVO PARA COMPRIMIR';
			RETURN cCodRet, cMensaje, '';
			
		END IF;
		
END;
END PROCEDURE;