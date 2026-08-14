CREATE PROCEDURE "informix".sp_actualiza_campos_uh(pNumCte CHAR(9), pSecuencia smallint, pPuntoCardinal char(1), pOtros smallint, pAndador smallint, pEtapa smallint, pEdificio smallint, pEntrada smallint)
RETURNING CHAR(5) as Cod_Ret;

DEFINE sCodRet		CHAR(5);
DEFINE iCantRep     INTEGER;
DEFINE iSqlErr		INTEGER;
DEFINE iSamErr		INTEGER;

LEt sCodRet     =   '00000';
LET iCantRep    =   0;
LET iSqlErr		=   0;
LET iSamErr     =   0;

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr != 0 THEN
            LET sCodRet = iSqlErr::CHAR(8);
            RETURN sCodRet;
        END IF;
    END EXCEPTION; 	
    
    IF EXISTS(SELECT * FROM si_direcciones WHERE numcte = pNumCte and secuencia = pSecuencia) THEN
        UPDATE SI_DIRECCIONES
        Set
        puntocardinal = pPuntoCardinal, otros = pOtros, andador = pAndador, etapa = pEtapa, edificio = pEdificio,
        entrada = pEntrada
        where
        numcte = pNumCte
        and secuencia=pSecuencia
        ;
        UPDATE SI_DIRECCIONES_actual
        Set
        puntocardinal = pPuntoCardinal, otros = pOtros, andador = pAndador, etapa = pEtapa, edificio = pEdificio,
        entrada = pEntrada
        where
        numcte = pNumCte
        and secuencia=pSecuencia
        ;
    else
        Let sCodRet = '00001';
    END IF; 

RETURN NVL(sCodRet,'00000');

END
END PROCEDURE
DOCUMENT
'Descripcion : Mejoras al proceso de alta unica',
'Modifico    : 99804945-HIRAM ALFREDO RAMÃREZ CRUZ',
'Fecha       : 28/07/2022',
'BD          : Bdinteg';

CREATE PROCEDURE "informix".sp_consultareferencias(pEmpresa char(3), pNumeroCliente char(20))
        returning char(5), integer, integer;

--Creado: Rodolfo Tortolero Varela
--Fecha: 05/03/2009
--Consulta las secuencias maximas del cliente en la tabla si_refclientes

--Se Definen Variables
DEFINE iSqlErr INTEGER;
DEFINE vcodret char(5);
DEFINE iSecuencia1 integer;
DEFINE iSecuencia2 integer;

--Se Inicializan Variables
LET vcodret = "000";
LET iSecuencia1  = 0;
LET iSecuencia2  = 0;

    BEGIN
            ON EXCEPTION
                    SET iSqlErr
                    IF iSqlErr <> 0 THEN
                            LET vCodRet = iSqlErr;
                            RETURN  vcodret, iSecuencia1, iSecuencia2;
                    END IF;
            END EXCEPTION;

            SELECT  MAX(secuencia)  INTO iSecuencia1
            FROM si_refclientes
            WHERE empresa = pEmpresa AND numcte = pNumeroCliente;

            SELECT  MAX(secuencia)  INTO iSecuencia2
            FROM si_refclientes
            WHERE empresa = pEmpresa AND numcte = pNumeroCliente AND secuencia < iSecuencia1;

            IF iSecuencia1 <> 0 OR iSecuencia1 IS NOT NULL THEN
                    --IF iSecuencia2 <> 0  OR iSecuencia2 IS NOT NULL THEN
                            RETURN vcodret, iSecuencia1, iSecuencia2;
                    --ELSE
                    --        LET vcodret = '001'; --No tiene NÃºmero de Secuencia
                    --        RETURN vcodret, iSecuencia1, iSecuencia2;
                    --END IF;
            ELSE
                    LET vcodret = '001'; --No tiene NÃºmero de Secuencia
                    RETURN vcodret, iSecuencia1, iSecuencia2;
            END IF;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: RQM 18159 OptimizaciÃ³n de Clientes y ContrataciÃ³n de Productos',
'Modificacion: 98440021-Veronica Zulema Rodriguez',
'FECHA: 26 julio 2022',
'Solicita: Fernando Rojas',
'BD: Bdinteg';

CREATE PROCEDURE "informix".sp_desfusion_ctescap(pClienteCorrecto CHAR(20),pClienteInCorrecto CHAR(20),pUsuario	CHAR(8))
	RETURNING CHAR (6) AS codigo_retorno, CHAR (30) AS Tabla;

	----- DECLARACION DE VARIABLES  -----
	DEFINE iSql_err		INTEGER;
	DEFINE cDescErr		CHAR(30);
	DEFINE cCodRet		CHAR (6);
	DEFINE cCuenta		CHAR(20);
	DEFINE cDet_mov		CHAR(200);
	DEFINE sBand		SMALLINT;
	DEFINE cNum_cte		CHAR(20);
	DEFINE cAniomes		CHAR(6);
	DEFINE sSecuencia	SMALLINT;
	DEFINE cNum_tarj	CHAR(20);
	DEFINE iNum_huella	INTEGER;
	DEFINE cEstado		CHAR(1);
	DEFINE cRfc			CHAR(13);
	DEFINE cRef_ret		CHAR(20);
	DEFINE cNum_cta		CHAR(20);
	DEFINE dFecha_mov	DATE;
	DEFINE mImp_tot_dep	MONEY(14,2);
	DEFINE iConsecutivo	INTEGER;
	DEFINE sEjercicio	SMALLINT;
	DEFINE cClave_prog	CHAR(10);
	DEFINE dFechafin, dFecha_insertAux, dFecha_insert	DATE;
	DEFINE iID_reg		INTEGER;
	DEFINE iKeyx		INTEGER;
	DEFINE cFolio_contr	CHAR(12);
	DEFINE cTipo_dir	CHAR(12);
	DEFINE cStatus_sol	CHAR(2);
	DEFINE cFecha_insert	CHAR(10);
	DEFINE cNum_solicitud	CHAR(20);
	DEFINE cTelefono	CHAR(10);
	DEFINE cEmpresaAux, cEmpresa	CHAR(3);
	DEFINE cNumcteBancoAux, cNumcteBanco, cClienteAux, cCliente CHAR(20);
	DEFINE iSecuenciaAux, iSecuencia	INTEGER;
	DEFINE cNumempleadoAux, cNumempleado CHAR(8); 
	
	DEFINE cSucursal 	CHAR(4);
	DEFINE dFecha_alta 	DATE;
	DEFINE cDmapa , cImapa CHAR(942);
	DEFINE cUsuario	CHAR(8);
	
	DEFINE cSit_Cliente_tit_fus, cSit_Cliente_tit_act, cSit_Cliente_tras_fus, cOri_Cliente_tit_act	CHAR(1);
	DEFINE iCau_Cliente_tit_fus, iCau_Cliente_tit_act, iCau_Cliente_tras_fus, iPon_Cliente_tit_fus, iPon_Cliente_tit_act, iPon_Cliente_tras_fus, iSqlErr	INTEGER;
	DEFINE vcnumcte_tf CHAR (20);
	DEFINE vc_cuenta_tf CHAR (20);
	DEFINE cTicket		CHAR(20);
	DEFINE iContador INTEGER;
	
	DEFINE cFolio_suc CHAR(16);
	DEFINE cFolio_suc_mov_crd CHAR(16);

	----- INICIALIZACION DE VARIABLES -----
	LET iSql_err		= 0;
	LET cDescErr    	= '';
	LET cCodRet			= '000000';
	LET cCuenta			= '';

	LET cAniomes		= '';
	LET sSecuencia		= 0;
	LET cNum_tarj		= '';
	LET iNum_huella		= 0;
	LET cEstado			= '';
	LET cRfc			= '';
	LET cRef_ret		= '';
	LET cNum_cta		= '';
	LET dFecha_mov		= '';
	LET mImp_tot_dep	= 0;
	LET iConsecutivo	= 0;
	LET sEjercicio		= 0;
	LET cClave_prog		= '';
	LET dFechafin		= '';
	LET iID_reg			= 0;
	LET iKeyx			= 0;
	LET cFolio_contr	= '';
	LET cStatus_sol		= '';
	LET cFecha_insert	= '';
	LET cNum_solicitud	= '';
	LET vcnumcte_tf = '';
	LET vc_cuenta_tf = '';
	LET iContador = 0;
	LET cFolio_suc = '';
	LET cFolio_suc_mov_crd = '';

	BEGIN
		ON EXCEPTION SET iSql_err
			IF iSql_err <> 0 THEN
			
				DROP TABLE IF EXISTS table_dirtemp;

				LET cCodret = iSql_err;
				RETURN NVL(TRIM(cCodret),''), TRIM(cDescErr);
			END IF;
		END EXCEPTION;

		-- RUTA Y NOMBRE DONDE SE GENERARÃ LO QUE REALIZÃ EL PROCEDIMIENTO
		--SET DEBUG FILE TO '/ifxsif01/MAPE/sp_desfusion_ctescap.out';
		--TRACE ON;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


		-- CUENTAS CHEQUES:
		FOREACH
			SELECT NVL(a.cuenta,'')
			INTO cCuenta
			FROM "informix".si_fusmaechq  a,
				bdicheq: "informix".sc_maechq b
			WHERE a.num_cte = pClienteInCorrecto
			AND a.cuenta = b.cuenta

			LET cDescErr = 'si_fusmaechq';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||TRIM(pClienteCorrecto);

				UPDATE bdicheq: "informix".sc_maechq SET num_cte = pClienteInCorrecto WHERE cuenta = cCuenta;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion (proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('CUENTA DE CHEQUES','si_fusmaechq',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov = '';

			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cCuenta = '';

		-- ESTADOS DE CUENTA:
		FOREACH
			SELECT {+INDEX (bdinteg:"informix".si_fusmaehis idxfusmaehis)} NVL(a.cuenta,''),NVL(a.aniomes,'')
			INTO cCuenta,cAniomes
			FROM "informix".si_fusmaehis  a,
				bdicheq: "informix".sc_maehis b
			WHERE a.num_cte = pClienteInCorrecto
			AND a.cuenta = b.cuenta
			AND a.empresa = b.empresa

			LET cDescErr = 'si_fusmaehis';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||TRIM(cAniomes)||'|'||TRIM(pClienteCorrecto);

				UPDATE bdicheq: "informix".sc_maehis SET num_cte = pClienteInCorrecto WHERE cuenta = cCuenta;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('ESTADO DE CUENTA','si_fusmaehis',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov = '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cCuenta = '';
		LET cAniomes = '';

		-- BENEFICIARIOS:
		FOREACH
			SELECT NVL(a.cuenta,''),NVL(a.secuencia,'')
			INTO cCuenta,sSecuencia
			FROM "informix".si_fusbeneficiario a,
				 bdicheq: "informix".sc_beneficiario b
			WHERE a.numcte = pClienteInCorrecto
			AND a.cuenta = b.cuenta
			AND a.secuencia = b.secuencia

			LET cDescErr = 'si_fusbeneficiario';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||sSecuencia||'|'||TRIM(pClienteCorrecto);

				UPDATE bdicheq: "informix".sc_beneficiario SET numcte = pClienteInCorrecto WHERE cuenta = cCuenta AND secuencia = sSecuencia;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('BENEFICIARIO','si_fusbeneficiario',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov = '';

			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cCuenta = '';
		LET sSecuencia = '';

		-- FIRMANTES:
		FOREACH
			SELECT NVL(a.cuenta,''),NVL(a.secuencia,'')
			INTO cCuenta,sSecuencia
			FROM "informix".si_fusfirmantes  a,
				bdicheq: "informix".sc_firmantes b
			WHERE a.numcte = pClienteInCorrecto
			AND a.cuenta = b.cuenta

			LET cDescErr = 'si_fusfirmantes';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||sSecuencia||'|'||TRIM(pClienteCorrecto);

				UPDATE bdicheq: "informix".sc_firmantes SET numcte = pClienteInCorrecto WHERE cuenta = cCuenta AND secuencia = sSecuencia;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('FIRMANTES','si_fusfirmantes',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov = '';

			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cCuenta = '';
		LET sSecuencia = '';

		-- TARJETAS:
		FOREACH
			SELECT NVL(a.cuenta,''),NVL(a.secuencia,''),NVL(a.num_tarjeta,'')
			INTO cCuenta,sSecuencia,cNum_tarj
			FROM  "informix".si_fustarjetadeb a,
				bdicheq: "informix".sc_tarjeta  b
			WHERE a.numcte = pClienteInCorrecto
			AND a.cuenta = b.cuenta

			LET cDescErr = 'si_fustarjetadeb';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||TRIM(pClienteCorrecto)||'|'||sSecuencia||'|'||TRIM(cNum_tarj);

				UPDATE bdicheq: "informix".sc_tarjeta SET numcte = pClienteInCorrecto WHERE cuenta = cCuenta;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('TARJETAS','si_fustarjetadeb',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov = '';

			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cCuenta = '';
		LET sSecuencia = '';
		LET cNum_tarj = '';

		-- INTERCARD:
		FOREACH
			SELECT {+INDEX (bdinteg:"informix".si_fusintercardtarjeta idx_intnumcte)} {+INDEX (bdinteg:"informix".sc_tarjeta ix_tarjeta2)} NVL(c.cuenta,''),NVL(a.numtarjeta,'')
			INTO cCuenta,cNum_tarj
			FROM "informix".si_fusintercardtarjeta  a,
				 intercard:"informix".tarjeta b,
				bdicheq: "informix".sc_tarjeta c
			WHERE a.numcliente = pClienteInCorrecto
			AND a.numtarjeta = b.numtarjeta
			AND a.numtarjeta = c.num_tarjeta
			AND c.empresa = '001'

			LET cDescErr = 'si_fusintercardtarjeta';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||TRIM(pClienteCorrecto);

				UPDATE intercard:"informix".tarjeta SET numcliente = pClienteInCorrecto WHERE numtarjeta = cNum_tarj;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('INTERCARD','si_fusintercardtarjeta',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov = '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cCuenta = '';
		LET sSecuencia = '';
		LET cNum_tarj = '';

		-- INVERSIONES:
		FOREACH
			SELECT {+INDEX (bdinvers:"informix".sv_maeinv idx_maeinv1)} a.cuenta,a.secuencia
			INTO cCuenta, sSecuencia
			FROM "informix".si_fusmaeinv a,
				bdinvers: "informix".sv_maeinv b
			WHERE a.num_cte = pClienteInCorrecto
			AND a.cuenta = b.cuenta
			AND b.empresa IS NOT NULL
			AND b.secuencia IS NOT NULL

			LET cDescErr = 'si_fusmaeinv';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||sSecuencia||'|'||TRIM(pClienteCorrecto);

				UPDATE {+INDEX (bdinvers:"informix".sv_maeinv idx_maeinv1)} bdinvers: "informix".sv_maeinv SET num_cte = pClienteInCorrecto WHERE cuenta = cCuenta AND empresa IS NOT NULL AND secuencia IS NOT NULL;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('INVERSIONES','si_fusmaeinv',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov = '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cCuenta = '';
		LET sSecuencia = 0;

		-- HUELLAS:

		SELECT {+INDEX (bdinteg:"informix".si_fushuellacte pk_hcte)} COUNT(*)
		INTO iNum_huella
		FROM "informix".si_fushuellacte
		WHERE numcte = pClienteInCorrecto;

		IF iNum_huella > 0 THEN
			FOREACH				
				SELECT {+INDEX (bdinteg:"informix".si_fushuellacte pk_hcte)}  secuencia, sucursal, fecha_alta, dmapa, imapa, usuario
				INTO iSecuencia, cSucursal, dFecha_alta, cDmapa, cImapa, cUsuario
				FROM bdinteg:si_fushuellacte
				WHERE numcte = pClienteInCorrecto
								
				LET cDescErr = 'si_fushuellacte';
				
				SELECT COUNT(*)
				INTO iContador						
				FROM bdinteg:si_cte_huella 
				WHERE numcte = pClienteCorrecto AND secuencia = iSecuencia AND sucursal = cSucursal 
				AND fecha_alta = dFecha_alta AND dmapa = cDmapa AND imapa = cImapa 
				AND usuario = usuario;
														
				IF ( iContador >= 1 ) THEN

					UPDATE bdinteg:si_cte_huella
					SET numcte = pClienteInCorrecto
					WHERE numcte = pClienteCorrecto 
					AND secuencia = iSecuencia;
					
					/*IF EXISTS(SELECT numcte FROM bdinteg:si_huella_linea 
								WHERE numcte = pClienteCorrecto 
									AND secuencia = iSecuencia AND sucursal = cSucursal AND fecha_alta_huella = dFecha_alta AND dmapa = cDmapa AND imapa = cImapa) THEN
						UPDATE bdinteg:si_huella_linea 
						SET numcte = pClienteInCorrecto
						WHERE numcte = pClienteCorrecto 
						AND secuencia = iSecuencia;
					END IF;*/	
				ELSE
					INSERT INTO "informix".si_cte_huella (numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,usuario_camb,fecha_camb,fech_ult_camb)
					SELECT {+INDEX (bdinteg:"informix".si_fushuellacte pk_hcte)} numcte,secuencia,estado,dmapa,imapa,usuario,sucursal,fecha_alta,usuario_camb,fecha_camb,fech_ult_camb
					FROM "informix".si_fushuellacte
					WHERE numcte = pClienteInCorrecto
					AND secuencia = iSecuencia;
				END IF;
				
				LET cDet_mov = TRIM(pClienteInCorrecto)||'|'||TRIM(pClienteCorrecto)||'|'||iSecuencia||'|'||TRIM(cEstado);

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('TRASPASO DE HUELLA','si_fushuellacte',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				SELECT numcte INTO cNum_cte FROM "informix".si_cte_huella WHERE numcte = pClienteInCorrecto AND secuencia = iSecuencia;

				IF cNum_cte = '' THEN
					LET cCodret = '000001';
				END IF;

				LET cDet_mov   = '';
				LET sSecuencia = 0;
				LET cEstado	   = '';
			END FOREACH

		END IF;
		
		SELECT COUNT(*)
		INTO iNum_huella
		FROM "informix".si_fushuella_linea
		WHERE numcte = pClienteInCorrecto;
		
		IF iNum_huella > 0 THEN
			FOREACH
				SELECT ticket
				INTO cTicket
				FROM "informix".si_fushuella_linea
				WHERE numcte = pClienteInCorrecto
						
				SELECT COUNT(*)
				INTO iContador
				FROM si_huella_linea 
				WHERE numcte = pClienteCorrecto AND ticket = cTicket;
				
				IF ( iContador >= 1 ) THEN				
					
					UPDATE si_huella_linea 
					SET numcte = pClienteInCorrecto 
					WHERE numcte = pClienteCorrecto 					
					AND ticket = cTicket;
										
				ELSE
					INSERT INTO bdinteg:si_huella_linea(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert) 
					SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert
					FROM bdinteg:si_fushuella_linea
					WHERE numcte = pClienteInCorrecto;
					
					INSERT INTO bdinteg:si_huella_linea_resultado(estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa) 
					SELECT estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa
					FROM bdinteg:si_fushuella_linea_resultado
					WHERE ticket IN(SELECT ticket FROM bdinteg:si_fushuella_linea WHERE numcte = pClienteInCorrecto);					
				END IF;
				
				LET cDet_mov = TRIM(cTicket)||'|'||TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto);
					
				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('HUELLA LINEA','si_huella_linea',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

			END FOREACH;
			
			FOREACH
				SELECT ticket
				INTO cTicket
				FROM "informix".si_fushuella_linea_hist
				WHERE numcte = pClienteInCorrecto
				
				SELECT COUNT(*)
				INTO iContador						
				FROM si_huella_linea_hist
				WHERE numcte = pClienteCorrecto AND ticket = cTicket;
				
				IF ( iContador >= 1 ) THEN
				
					UPDATE si_huella_linea_hist
					SET numcte = pClienteInCorrecto 
					WHERE numcte = pClienteCorrecto 
					AND ticket = cTicket;
				ELSE
					INSERT INTO bdinteg:si_huella_linea_hist(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601) 
					SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601
					FROM bdinteg:si_fushuella_linea_hist
					WHERE numcte = pClienteInCorrecto;
					
					INSERT INTO bdinteg:si_huella_linea_resultado_hist(estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl) 
					SELECT estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciaspl
					FROM bdinteg:si_fushuella_linea_resultado_hist
					WHERE ticket IN(SELECT ticket FROM bdinteg:si_fushuella_linea_hist WHERE numcte = pClienteInCorrecto);

				END IF;
				
				LET cDet_mov = TRIM(cTicket)||'|'||TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto);
				
				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('HUELLA LINEA HIST','si_huella_linea_hist',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
			END FOREACH;
			
			FOREACH
				SELECT ticket
				INTO cTicket
				FROM "informix".si_fushuella_linea_hist_chl
				WHERE numcte = pClienteInCorrecto
				
				SELECT COUNT(*)
				INTO iContador						
				FROM si_huella_linea_hist_chl 
				WHERE numcte = pClienteCorrecto AND ticket = cTicket;

				IF ( iContador >= 1 ) THEN
				
					UPDATE si_huella_linea_hist_chl
					SET numcte = pClienteInCorrecto 
					WHERE numcte = pClienteCorrecto 
					AND ticket = cTicket;
				ELSE
					INSERT INTO bdinteg:si_huella_linea_hist_chl(numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov) 
					SELECT numcte, fecha_consulta, secuencia, sexo, sucursal, fecha_alta_huella, ip, tipo_mov_huella, empleado, tipo_sensor, dmapa, imapa, status_huella, ref_coppel, fecha_ult_cambio, tipo_cliente, tipo_verificacion, ticket, status_consulta, respuesta_msj601, fecha_insert, fecha_mov
					FROM bdinteg:si_fushuella_linea_hist_chl
					WHERE numcte = pClienteInCorrecto;
					
					INSERT INTO bdinteg:si_huella_linea_resultado_hist_chl(estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa, fecha_mov) 
					SELECT estado_proceso, resultado, cliente, ticket, fecha, hora, empresa, num_mensaje, secuenciacpl, nombre, fecha_nac, situacion, causa, fecha_mov
					FROM bdinteg:si_fushuella_linea_resultado_hist_chl
					WHERE ticket IN(SELECT ticket FROM bdinteg:si_fushuella_linea_hist_chl WHERE numcte = pClienteInCorrecto);				
				END IF;
				LET cDet_mov = TRIM(cTicket)||'|'||TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto);
				
				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('HUELLA LINEA HIST CHL','si_huella_linea_hist_chl',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
				
			END FOREACH;
			
			DELETE FROM si_fushuella_linea_resultado
			WHERE ticket IN(SELECT ticket FROM bdinteg:si_fushuella_linea WHERE numcte = pClienteInCorrecto);
			DELETE FROM si_fushuella_linea 
			WHERE numcte = pClienteInCorrecto;
						
			DELETE FROM si_fushuella_linea_resultado_hist
			WHERE ticket IN(SELECT ticket FROM bdinteg:si_fushuella_linea_hist WHERE numcte = pClienteInCorrecto);	
			DELETE FROM si_fushuella_linea_hist 
			WHERE numcte = pClienteInCorrecto;
			
			DELETE FROM si_fushuella_linea_resultado_hist_chl 
			WHERE ticket IN(SELECT ticket FROM bdinteg:si_fushuella_linea_hist_chl WHERE numcte = pClienteInCorrecto);			
			DELETE FROM si_fushuella_linea_hist_chl 
			WHERE numcte = pClienteInCorrecto;
		ELSE
			SELECT {+INDEX (bdinteg:"informix".si_fushuellacte pk_hcte)}  secuencia, sucursal, fecha_alta, dmapa, imapa, usuario
			INTO iSecuencia, cSucursal, dFecha_alta, cDmapa, cImapa, cUsuario
			FROM bdinteg:si_fushuellacte
			WHERE numcte = pClienteInCorrecto
			AND estado = 'A'
			AND secuencia = (SELECT MAX(secuencia) FROM bdinteg:si_fushuellacte WHERE numcte = pClienteInCorrecto);
			
			SELECT COUNT(*)
			INTO iContador					
			FROM bdinteg:si_huella_linea 
			WHERE numcte = pClienteCorrecto 
			AND secuencia = iSecuencia AND sucursal = cSucursal AND fecha_alta_huella = dFecha_alta AND dmapa = cDmapa AND imapa = cImapa;
						
			IF ( iContador >= 1 ) THEN						
						
				UPDATE bdinteg:si_huella_linea 
				SET numcte = pClienteInCorrecto
				WHERE numcte = pClienteCorrecto 
				AND secuencia = iSecuencia;
			END IF;
		END IF;

		-- IDE:
		FOREACH
			SELECT a.aniomes,a.rfc,a.ref_ret,a.num_cta,a.fecha_mov,a.imp_tot_dep
			INTO cAniomes,cRfc,cRef_ret,cNum_cta,dFecha_mov,mImp_tot_dep
			FROM "informix".si_fusmovefec a,
				bdilide: "informix".sl_movefec b
			WHERE a.num_cte = pClienteInCorrecto
			AND a.num_cta = b.num_cta

			LET cDescErr = 'si_fusmovefec';

			IF cNum_cta <> '' THEN
				LET cDet_mov = cAniomes||'|'||TRIM(pClienteCorrecto)||'|'||TRIM(cRfc)||'|'||TRIM(cRef_ret)||'|'||TRIM(cNum_cta)||'|'||dFecha_mov||'|'||mImp_tot_dep;

				UPDATE {+INDEX (bdilide:"informix".sl_movefec i_102)} bdilide:"informix".sl_movefec SET num_cte = pClienteInCorrecto WHERE num_cta = cNum_cta AND aniomes IS NOT NULL;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('INFORMACION IDE','si_fusmovefec',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET cAniomes 	= '';
				LET cRfc 		= '';
				LET cRef_ret 	= '';
				LET dFecha_mov 	= '';
				LET mImp_tot_dep = 0;
				LET cNum_cta 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cNum_cta = '';
		LET sSecuencia = 0;
		LET cDet_mov 	= '';
		LET cAniomes 	= '';
		LET cRfc 		= '';
		LET cRef_ret 	= '';
		LET dFecha_mov 	= '';
		LET mImp_tot_dep = 0;

		-- IDE HISTORICO:
		FOREACH
			SELECT {+INDEX (bdilide:"informix".sl_movefec_his i_102_his)} a.aniomes,a.rfc,a.ref_ret,a.num_cta,a.fecha_mov,a.imp_tot_dep
			INTO cAniomes,cRfc,cRef_ret,cNum_cta,dFecha_mov,mImp_tot_dep
			FROM "informix".si_fusmovefec_his a,
				bdilide: "informix".sl_movefec_his b
			WHERE a.num_cte = pClienteInCorrecto
			AND a.num_cta = b.num_cta
			AND b.aniomes IS NOT NULL -- SE AGREGA LINEA PARA QUE TOME INDICE

			LET cDescErr = 'si_fusmovefec_his';

			IF cNum_cta <> '' THEN
				LET cDet_mov = cAniomes||'|'||TRIM(pClienteCorrecto)||'|'||TRIM(cRfc)||'|'||TRIM(cRef_ret)||'|'||TRIM(cNum_cta)||'|'||dFecha_mov||'|'||mImp_tot_dep;

				UPDATE {+INDEX (bdilide:"informix".sl_movefec_his i_102_his)} bdilide:"informix".sl_movefec_his SET num_cte = pClienteInCorrecto WHERE num_cta = cNum_cta AND aniomes IS NOT NULL;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('IDE HISTORICO','si_fusmovefec_his',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);


				LET cDet_mov 	= '';
				LET cAniomes 	= '';
				LET cRfc 		= '';
				LET cRef_ret 	= '';
				LET dFecha_mov 	= '';
				LET mImp_tot_dep = 0;
				LET cNum_cta 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cNum_cta = '';
		LET cDet_mov 	= '';
		LET cAniomes 	= '';
		LET cRfc 		= '';
		LET cRef_ret 	= '';
		LET dFecha_mov 	= '';
		LET mImp_tot_dep = 0; 

		-- RETENCIÃN IDE:
		
		FOREACH 
		
		SELECT DISTINCT (aniomes) 
		INTO cAniomes
		FROM bdinteg:si_fusretlide WHERE num_cte IN (pClienteCorrecto, pClienteIncorrecto)
		
		SELECT COUNT(*)
		INTO iContador				
		FROM bdinteg:si_fusretlide  
		WHERE num_cte IN (pClienteCorrecto,pClienteIncorrecto) AND aniomes = cAniomes;
		
		IF ( iContador >= 1 ) THEN		
		
			DELETE bdilide:sl_retlide WHERE num_cte = pClienteCorrecto AND aniomes = cAniomes;
		
			INSERT INTO bdilide:sl_retlide
			SELECT * FROM bdinteg:si_fusretlide WHERE num_cte IN (pClienteCorrecto, pClienteIncorrecto) AND aniomes = cAniomes;
		
		ELSE
			SELECT {+INDEX (bdilide:"informix".sl_retlide idx_retcte)} a.ref_ret,a.aniomes,a.rfc
			INTO cRef_ret,cAniomes,cRfc
			FROM "informix".si_fusretlide a,
				bdilide: "informix".sl_retlide b
			WHERE a.num_cte = pClienteInCorrecto
			AND a.ref_ret = b.ref_ret
			AND b.num_cte IS NOT NULL -- SE AGREGA LINEA PARA QUE TOME INDICE
			AND b.pendiente IS NOT NULL; -- SE AGREGA LINEA PARA QUE TOME INDICE

			LET cDescErr = 'si_fusretlide';
			
		END IF;
		
			IF cRef_ret <> '' THEN
				LET cDet_mov = cAniomes||'|'||TRIM(pClienteCorrecto)||'|'||TRIM(cRfc)||'|'||TRIM(cRef_ret);

				UPDATE {+INDEX (bdilide:"informix".sl_retlide idx_retcte)} bdilide: "informix".sl_retlide SET num_cte = pClienteInCorrecto WHERE ref_ret = cRef_ret AND num_cte IS NOT NULL AND b.pendiente IS NOT NULL; -- SE AGREGA LINEA (num_cte) PARA QUE TOME INDICE
		
				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('RETENCION IDE','si_fusretlide',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET cAniomes 	= '';
				LET cRfc 		= '';
				LET cRef_ret 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cDet_mov 	= '';
		LET cAniomes 	= '';
		LET cRfc 		= '';
		LET cRef_ret 	= '';

		-- DETALLE IDE:
		FOREACH
		
		SELECT DISTINCT(aniomes),consecutivo
		INTO cAniomes,iConsecutivo
		FROM bdinteg:si_fusdetlide WHERE num_cte IN (pClienteCorrecto, pClienteInCorrecto)
		
		SELECT COUNT(*)
		INTO iContador				
		FROM bdinteg:si_fusdetlide  
		WHERE num_cte IN (pClienteCorrecto,pClienteIncorrecto) AND aniomes = cAniomes AND consecutivo = iConsecutivo;
		
		IF ( iContador >= 1 ) THEN		
		
			DELETE bdilide:sl_detlide WHERE num_cte = pClienteCorrecto AND aniomes = cAniomes AND consecutivo = iConsecutivo;
		
			INSERT INTO bdilide:sl_detlide
			SELECT * FROM bdinteg:si_fusdetlide WHERE num_cte IN (pClienteCorrecto, pClienteIncorrecto) AND aniomes = cAniomes AND consecutivo = iConsecutivo;
		ELSE
			SELECT {+INDEX (bdilide:"informix".sl_detlide i_d102)} a.cuenta_ret,a.aniomes,a.rfc,a.ref_ret,a.consecutivo
			INTO cCuenta,cAniomes,cRfc,cRef_ret,iConsecutivo
			FROM "informix".si_fusdetlide a,
			bdilide: "informix".sl_detlide b
			WHERE a.num_cte = pClienteInCorrecto
			AND a.cuenta_ret  = b.cuenta_ret
			AND b.aniomes IS NOT NULL; -- SE AGREGA LINEA (aniomes) PARA QUE TOME INDICE

			LET cDescErr = 'si_fusdetlide';
			
		END IF;
		
			IF cCuenta <> '' THEN
				LET cDet_mov = cAniomes||'|'||TRIM(pClienteCorrecto)||'|'||TRIM(cRfc)||'|'||TRIM(cRef_ret)||'|'||TRIM(cCuenta)||'|'||iConsecutivo;

				UPDATE {+INDEX (bdilide:"informix".sl_detlide i_d102)} bdilide:"informix".sl_detlide SET num_cte = pClienteInCorrecto WHERE cuenta_ret = cCuenta AND aniomes IS NOT NULL; -- SE AGREGA LINEA (aniomes) PARA QUE TOME INDICE
		
				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('DETALLE IDE','si_fusdetlide',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				SELECT {+INDEX (bdilide:"informix".sl_detlide i_d102)} num_cte INTO cNum_cte FROM bdilide: "informix".sl_detlide WHERE cuenta_ret = cCuenta AND aniomes IS NOT NULL;

				LET cDet_mov 	= '';
				LET cAniomes 	= '';
				LET cRfc 		= '';
				LET cRef_ret 	= '';
				LET cCuenta 	= '';
				LET iConsecutivo = 0;
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cCuenta = '';
		LET cDet_mov 	= '';
		LET cAniomes 	= '';
		LET cRfc 		= '';
		LET cRef_ret 	= '';
		LET iConsecutivo = 0;

		-- RETEN ISR:
		FOREACH
			SELECT {+INDEX (bdicheq:"informix".sc_retenisr inx_retenisr)} a.cuenta,a.ejercicio
			INTO cCuenta,sEjercicio
			FROM "informix".si_fusretenisr a,
				bdicheq: "informix".sc_retenisr b
			WHERE a.num_cte = pClienteInCorrecto
			AND a.cuenta  = b.cuenta
			AND b.empresa IS NOT NULL
			AND b.ejercicio IS NOT NULL -- SE AGREGAN CAMPOS PARA TOMAR EL INDICE

			LET cDescErr = 'si_fusretenisr';

			IF cCuenta <> '' THEN
				LET cDet_mov = sEjercicio||'|'||TRIM(cCuenta)||'|'||TRIM(pClienteCorrecto);

				UPDATE {+INDEX (bdicheq:"informix".sc_retenisr inx_retenisr)} bdicheq: "informix".sc_retenisr SET num_cte = pClienteInCorrecto WHERE cuenta = cCuenta AND empresa IS NOT NULL AND ejercicio = sEjercicio;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('RETEN ISR','si_fusretenisr',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET sEjercicio 	= 0;
				LET cCuenta 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cDet_mov 	= '';
		LET cCuenta = '';
		LET cDet_mov 	= '';
		LET sEjercicio 	= 0;

		-- TRASPASO DE SOLICITUDES:
		FOREACH
			SELECT  a.num_solicitud,a.status_solicitud,a.fecha_insert
			INTO cCuenta, cStatus_sol,cFecha_insert
			FROM "informix".si_fussolicitudes a,
			bdisolic: "informix".ss_solicitudes b
			WHERE a.numcte = pClienteInCorrecto
			AND a.num_solicitud =  b.num_solicitud

			LET cDescErr = 'si_fussolicitudes';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(pClienteCorrecto)||'|'||TRIM(cCuenta)||'|'||TRIM(cStatus_sol)||'|'||TRIM(cFecha_insert);

				UPDATE {+INDEX (bdisolic:"informix".ss_solicitudes empsol)} bdisolic: "informix".ss_solicitudes SET numcte = pClienteInCorrecto
				WHERE num_solicitud = cCuenta AND empresa = '001'; -- SE AGREGA CAMPO PARA TOMAR EL INDICE

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				UPDATE  bdisolic:"informix".ss_refpersonales SET numcte = pClienteIncorrecto
				WHERE num_solicitud = cCuenta AND empresa = '001';

				UPDATE bdisolic:"informix".ss_refpersonales SET numcte_ref = pClienteIncorrecto
				WHERE num_solicitud = cCuenta AND numcte_ref = pClienteCorrecto AND empresa = '001';

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('TRASPASO DE SOLICITUDES','si_fussolicitudes',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET sEjercicio 	= 0;
				LET cCuenta 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cDet_mov 	= '';
		LET cCuenta = '';
		LET cDet_mov 	= '';
		LET sEjercicio 	= 0;
		
		--REFERENCIAS PERSONALES DE SOLICITUDES DE CREDITO
		FOREACH			
			SELECT {+INDEX(bdinteg:si_fusrefpersonales idx_si_fusrefpersonales02)} num_solicitud
			INTO cNum_solicitud
			FROM bdinteg:"informix".si_fusrefpersonales
			WHERE numcte_ref = pClienteInCorrecto
			
			LET cDet_mov = TRIM(pClienteCorrecto)||'|'||TRIM(cNum_solicitud);
			
			UPDATE bdisolic:"informix".ss_refpersonales
			SET numcte_ref = pClienteInCorrecto
			WHERE numcte_ref = pClienteCorrecto
			AND num_solicitud = cNum_solicitud;
			
			INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('TRASPASO DE REFERENCIAS','si_fusrefpersonales',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
			
		END FOREACH;
				
		-- PAGOS PROGRAMADOS:
		FOREACH
			SELECT {+INDEX (bdiprog:"informix".pp_pagoprog idxpp_num_cte)} a.cuenta_origen,a.cve_pagoprog
			INTO cCuenta,cClave_prog
			FROM "informix".si_fuspagoprog a,
				bdiprog: "informix".pp_pagoprog b
			WHERE a.num_cte = pClienteInCorrecto
			AND a.cuenta_origen = b.cuenta_origen
			AND a.cve_pagoprog = b.cve_pagoprog -- SE ANEXA PARA QUE TOME SOLO EL REGISTRO QUE TRASPASO
			AND b.num_cte IS NOT NULL -- SE AGREGA CAMPO PARA TOMAR EL INDICE

			LET cDescErr = 'si_fuspagoprog';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||TRIM(pClienteCorrecto)||'|'||TRIM(cClave_prog);

				UPDATE {+INDEX (bdiprog:"informix".pp_pagoprog idxpp_num_cte)} bdiprog:"informix".pp_pagoprog SET num_cte = pClienteInCorrecto WHERE cuenta_origen = cCuenta AND num_cte IS NOT NULL;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('PAGOS PROGRAMADOS','si_fuspagoprog',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET cCuenta 	= '';
				LET cClave_prog 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cDet_mov 	= '';
		LET cCuenta 	= '';
		LET cClave_prog = '';

		-- DOMICILIACIONES:
		FOREACH
			SELECT {+INDEX (bdidomi:"informix".dom_autorizaciones idx_cuenta)} a.cuenta
			INTO cCuenta
			FROM "informix".si_fusdomautorizaciones a,
				bdidomi: "informix".dom_autorizaciones b
			WHERE a.num_cte = pClienteInCorrecto
			AND a.cuenta = b.cuenta

			LET cDescErr = 'si_fusdomautorizaciones';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||TRIM(pClienteCorrecto);

				UPDATE {+INDEX (bdidomi:"informix".dom_autorizaciones idx_cuenta)} bdidomi: "informix".dom_autorizaciones SET num_cte = pClienteInCorrecto WHERE cuenta = cCuenta;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('DOMICILIACIONES','si_fusdomautorizaciones',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET cCuenta 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cDet_mov 	= '';
		LET cCuenta 	= '';

		-- TRANSPASO DE CHEQUERAS:
		FOREACH
			SELECT a.num_cuenta
			INTO cCuenta
			FROM "informix".si_fussq_envios  a,
				bdicntchq:"informix".sq_envios b
			WHERE a.numcte = pClienteInCorrecto
			AND a.num_cuenta = b.num_cuenta
			AND b.numcte = pClienteCorrecto

			LET cDescErr = 'si_fussq_envios';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||TRIM(pClienteCorrecto);

				UPDATE bdicntchq:"informix".sq_envios SET numcte = pClienteInCorrecto WHERE num_cuenta = cCuenta;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('TRANSPASO DE CHEQUERAS','si_fussq_envios',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET cCuenta 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cDet_mov 	= '';
		LET cCuenta 	= '';

		-- SOBREGIROS:
		FOREACH
			SELECT {+INDEX (bdicheq:"informix".sc_histsbg idx_histsbg1)} a.cuenta
			INTO cCuenta
			FROM "informix".si_fushistsbg  a,
				bdicheq:"informix".sc_histsbg b
			WHERE a.num_cte = pClienteInCorrecto
			AND a.cuenta = b.cuenta
			AND b.empresa = '001' -- SE AGREGA CAMPO PARA TOMAR EL INDICE

			LET cDescErr = 'si_fushistsbg';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||TRIM(pClienteCorrecto);

				UPDATE {+INDEX (bdicheq:"informix".sc_histsbg idx_histsbg1)} bdicheq:"informix".sc_histsbg SET num_cte = pClienteInCorrecto WHERE cuenta = cCuenta AND empresa = '001';

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('SOBREGIROS','si_fushistsbg',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET cCuenta 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cDet_mov 	= '';
		LET cCuenta 	= '';

		-- PROAC:
		FOREACH
			SELECT {+INDEX (bdinteg:"informix".si_fusproac idxfusproac3)} a.cta_eje
			INTO cCuenta
			FROM "informix".si_fusproac  a,
				bdicheq:"informix".sc_proac b
			WHERE a.num_cte = pClienteInCorrecto
			AND a.cta_eje = b.cta_eje

			LET cDescErr = 'si_fusproac';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||TRIM(pClienteCorrecto);

				UPDATE bdicheq:"informix".sc_proac SET num_cte = pClienteInCorrecto WHERE cta_eje = cCuenta AND num_cte = pClienteCorrecto;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('PROAC','si_fusproac',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET cCuenta 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cDet_mov 	= '';
		LET cCuenta 	= '';

		-- PORTABILIDAD NOMINA:
		FOREACH
			SELECT a.cuenta
			INTO cCuenta
			FROM "informix".si_fusportabilidad  a,
				bdicheq:"informix".sc_portabilidad b
			WHERE a.numcte = pClienteInCorrecto
			AND a.cuenta = b.cuenta

			LET cDescErr = 'si_fusportabilidad';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||TRIM(pClienteCorrecto);

				UPDATE {+INDEX (bdinteg:"informix".sc_portabilidad 1361_566)} bdicheq:"informix".sc_portabilidad SET numcte = pClienteInCorrecto WHERE cuenta = cCuenta AND empresa = '001' AND numcte IS NOT NULL; -- SE AGREGA CAMPO PARA TOMAR EL INDICE

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('PORTABILIDAD NOMINA','si_fusportabilidad',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET cCuenta 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cDet_mov 	= '';
		LET cCuenta 	= '';

		-- FACTURA ELECTRONICA:
		FOREACH
			SELECT {+INDEX (bdinteg:"informix".si_fusencabezado_edocta_factelect idxfusfacele)} a.num_cuenta,a.idreg,a.fechafinal
			INTO cCuenta,iID_reg,dFechafin
			FROM "informix".si_fusencabezado_edocta_factelect a,
				bdicheq:"informix".sc_encabezado_edocta_factelect b
			WHERE a.num_cte = pClienteInCorrecto
			AND a.num_cuenta = b.num_cuenta
			AND a.fechafinal = b.fechafinal --SE ANEXAN ULTIMOS DOS CAMPOS PARA QUE TRAPSASE CORRECTAMENTE LA INFORMACION
			AND a.idreg = b.idreg 
			

			LET cDescErr = 'si_fusencabezado_edocta_factelect';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||TRIM(pClienteCorrecto)||'|'||iID_reg||'|'||dFechafin;

				UPDATE {+INDEX (bdicheq:"informix".sc_encabezado_edocta_factelect idx_encabezado_cte)}  bdicheq:"informix".sc_encabezado_edocta_factelect SET num_cte = pClienteInCorrecto WHERE num_cuenta = cCuenta AND num_cte IS NOT NULL; -- SE AGREGA CAMPO PARA TOMAR EL INDICE

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('FACTURA ELECTRONICA','si_fusencabezado_edocta_factelect',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET cCuenta 	= '';
				LET iID_reg 	= 0;
				LET dFechafin 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cDet_mov 	= '';
		LET sBand 		= 0;
		LET cCuenta 	= '';
		LET iID_reg 	= 0;
		LET dFechafin 	= '';
		LET cNum_cte 	= '';

		-- BENEFICIARIOS INVERSION:
		FOREACH
			SELECT {+INDEX (bdinteg:"informix".si_fusbenefic_inv idxfusbenefinv2)} a.cuenta
			INTO cCuenta
			FROM "informix".si_fusbenefic_inv  a,
				bdinvers:"informix".sv_benefic b
			WHERE a.numcte = pClienteInCorrecto
			AND a.cuenta = b.cuenta

			LET cDescErr = 'si_fusbenefic_inv';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||TRIM(pClienteCorrecto);

				UPDATE bdinvers:"informix".sv_benefic SET numcte = pClienteInCorrecto WHERE cuenta = cCuenta; -- REVISAR

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('BENEFICIARIOS INVERSION','si_fusbenefic_inv',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET cCuenta 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH

		LET cDet_mov 	= '';
		LET cCuenta 	= '';

		-- AUTORIZADOS INVERSION:
		FOREACH
			SELECT {+INDEX (bdinteg:"informix".si_fuscotitular_inv idxfuscotit2)} a.cuenta
			INTO cCuenta
			FROM "informix".si_fuscotitular_inv  a,
				bdinvers:"informix".sv_cotitular b
			WHERE a.numcte = pClienteInCorrecto
			AND a.cuenta = b.cuenta

			LET cDescErr = 'si_fuscotitular_inv';

			IF cCuenta <> '' THEN
				LET cDet_mov = TRIM(cCuenta)||'|'||TRIM(pClienteCorrecto);
				
				--SE ANEXO EL CLIENTE CORRECTO
				UPDATE bdinvers:"informix".sv_cotitular SET numcte = pClienteInCorrecto WHERE cuenta = cCuenta and numcte = pClienteCorrecto;

				-- SE VERIFÃCA SI HAY INFORMACIÃN O NO DE LA CONSULTA
				IF DBINFO('sqlca.sqlerrd2') = 0 THEN
					LET cCodret = '000001';
					RETURN cCodRet, cDescErr;
				END IF;

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('AUTORIZADOS INVERSION','si_fuscotitular_inv',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET cCuenta 	= '';
			ELSE
				CONTINUE FOREACH;
			END IF;
		END FOREACH



		LET cDet_mov 	= '';
		LET cCuenta 	= '';

		--*************************
		-- INICIO CASOS ESPECIALES
		--*************************
		
		SELECT COUNT(*)
		INTO iContador				
		FROM bdinteg:si_fusctessitespcte 
		WHERE numcte = pClienteInCorrecto;
		
		IF ( iContador >= 1 ) THEN		
		
			INSERT INTO bdisitesp:se_ctessitespcte (idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
				   usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje)
			SELECT idmovto,empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
				   usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje
			FROM bdinteg:si_fusctessitespcte
			WHERE numcte = pClienteInCorrecto;
			
			INSERT INTO bdisitesp:se_ctessitespcte_his(idmovto, tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica) 
			SELECT idmovto, tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica
			FROM bdinteg:si_fusctessitespcte_his
			WHERE numcte = pClienteInCorrecto;
			
			SELECT COUNT(*)
			INTO iContador		
			FROM bdinteg:si_fusctessitespcte 
			WHERE numcte = pClienteCorrecto;
			
			IF ( iContador >= 1 ) THEN			
			
				SELECT b.situacion, b.causa, NVL(a.ponderacion,0)
				INTO cSit_Cliente_tit_fus, iCau_Cliente_tit_fus, iPon_Cliente_tit_fus
				FROM bdisitesp:se_catsitesp a, bdinteg:si_fusctessitespcte b
				WHERE a.situacion = b.situacion
				AND a.causa = b.causa
				AND b.numcte = pClienteCorrecto;			
				
				SELECT b.situacion, b.causa, NVL(a.ponderacion,0)
				INTO cSit_Cliente_tras_fus, iCau_Cliente_tras_fus, iPon_Cliente_tras_fus
				FROM bdisitesp:se_catsitesp a, bdinteg:si_fusctessitespcte b
				WHERE a.situacion = b.situacion
				AND a.causa = b.causa
				AND b.numcte = pClienteInCorrecto;
				
				SELECT b.situacion, b.causa, cvesitesporigen, NVL(a.ponderacion,0)
				INTO cSit_Cliente_tit_act, iCau_Cliente_tit_act, cOri_Cliente_tit_act, iPon_Cliente_tit_act 
				FROM bdisitesp:se_catsitesp a, bdisitesp:se_ctessitespcte b
				WHERE a.situacion = b.situacion
				AND a.causa = b.causa
				AND b.numcte = pClienteCorrecto;			
				
				IF (iPon_Cliente_tit_act <  iPon_Cliente_tit_fus) AND (TRIM(cSit_Cliente_tit_act)||iCau_Cliente_tit_act <> TRIM(cSit_Cliente_tras_fus)||iCau_Cliente_tras_fus) THEN
				
					SELECT COUNT(*)
					INTO iContador		
					FROM bdisitesp:se_ctessitespcte_his 
					WHERE numcte = pClienteCorrecto AND situacion = cSit_Cliente_tit_fus AND causa = iCau_Cliente_tit_fus;
					
					IF ( iContador <= 0 ) THEN
					
						INSERT INTO bdisitesp:se_ctessitespcte_his (tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
						SELECT tipomovto,numcte, empresa, situacion, causa, cvesitesporigen, sucursal, USER, usralta, fchalta, usrmodifica, fchmodifica
						FROM bdinteg:si_fusctessitespcte
						WHERE numcte = pClienteCorrecto;

					END IF;
					
					DELETE FROM bdinteg:si_fusctessitespcte 
					WHERE numcte = pClienteCorrecto;
										
				ELIF (iPon_Cliente_tit_act <  iPon_Cliente_tit_fus) AND (TRIM(cSit_Cliente_tit_act)||iCau_Cliente_tit_act = TRIM(cSit_Cliente_tras_fus)||iCau_Cliente_tras_fus) THEN
					DELETE FROM bdisitesp:se_ctessitespcte 
					WHERE numcte = pClienteCorrecto;
										
					INSERT INTO bdisitesp:se_ctessitespcte (idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
						   usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje)
					SELECT idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
						   usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje
					FROM bdinteg:si_fusctessitespcte
					WHERE numcte = pClienteCorrecto;
										
					DELETE FROM bdinteg:si_fusctessitespcte
					WHERE numcte = pClienteCorrecto; 
					
					DELETE FROM bdisitesp:se_ctessitespcte_his 
					WHERE numcte = pClienteCorrecto 
					AND situacion = cSit_Cliente_tit_fus
					AND causa = iCau_Cliente_tit_fus;
					
				ELIF (iPon_Cliente_tit_fus =  iPon_Cliente_tit_act) AND (TRIM(cSit_Cliente_tit_act)||iCau_Cliente_tit_act <> TRIM(cSit_Cliente_tras_fus)||iCau_Cliente_tras_fus) THEN
				
					SELECT COUNT(*)
					INTO iContador						
					FROM bdisitesp:se_ctessitespcte_his 
					WHERE numcte = pClienteCorrecto AND situacion = cSit_Cliente_tit_fus AND causa = iCau_Cliente_tit_fus;
					
					IF ( iContador <= 0 ) THEN
					
						INSERT INTO bdisitesp:se_ctessitespcte_his (tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
						SELECT tipomovto,numcte, empresa, situacion, causa, cvesitesporigen, sucursal, USER, usralta, fchalta, usrmodifica, fchmodifica
						FROM bdinteg:si_fusctessitespcte
						WHERE numcte = pClienteCorrecto;
						
					END IF;
					DELETE FROM bdinteg:si_fusctessitespcte 
					WHERE numcte = pClienteCorrecto;
				ELIF (iPon_Cliente_tit_fus <  iPon_Cliente_tit_act) THEN
					INSERT INTO bdisitesp:se_ctessitespcte_his (tipomovto, numcte, empresa, situacion, causa, cvesitesporigen, sucursal, empleadoefectuo, usralta, fchalta, usrmodifica, fchmodifica)
					SELECT tipomovto,numcte, empresa, situacion, causa, cvesitesporigen, sucursal, USER, usralta, fchalta, usrmodifica, fchmodifica
					FROM bdisitesp:se_ctessitespcte
					WHERE numcte = pClienteCorrecto;
					
					DELETE FROM bdisitesp:se_ctessitespcte 
					WHERE numcte = pClienteCorrecto;
									
					INSERT INTO bdisitesp:se_ctessitespcte (idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
						   usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje)
					SELECT idmovto, empresa, numcte, situacion, causa, cvesitesporigen, sucursal, tipomovto, empleadoefectuo, nombreefectuo, fechamovto,
						   usralta, fchalta, usrmodifica, fchmodifica, motivo_desmarcaje
					FROM bdinteg:si_fusctessitespcte
					WHERE numcte = pClienteCorrecto;
					
				END IF;
			END IF;
		END IF;
		--*********************
		--FIN CASOS ESPECIALES
		--*********************

		--************************
		--INICIA EL PROCESO DE BPI
		--************************
		--USUARIOS BPI INTEG:
		--Â¿Preguntar si hay info de ambos clientes en la tabla de fus?
		--Si hay info de ambos, solo insertar en bpi_usuarios la info del incorrecto
		--si hay solo info del incorrecto, hacer un update en bpi_usuarios
		
		SELECT {+INDEX (bdinteg:"informix".si_fusbpiusuarios_int idxfusbpi)} COUNT(*)
		INTO iContador				
		FROM bdinteg:"informix".si_fusbpiusuarios_int 
		WHERE numcte = pClienteCorrecto and empresa = '001';
		
		IF ( iContador >= 1 ) THEN
		
			--Inserto los datos respaldados en la tabla bdinteg:si_fusbpiusuarios_int del cliente incorrecto
			INSERT INTO bdinteg:"informix".si_bpiusuarios(empresa, numcte, id_status, folio_contrato, usuario, pass, f_pass, pass1, f_pass1, pass2, f_pass2, pass3, f_pass3, f_status, f_ultimo_acceso, f_actualizacion, suc_registro, f_registro, fec_primer_acceso, num_empleado, fecha_movto, servicio, f_unico_reg)
			SELECT {+INDEX (bdinteg:"informix".si_fusbpiusuarios_int idxfusbpi)} empresa, numcte, id_status, folio_contrato, usuario, pass, f_pass, pass1, f_pass1, pass2, f_pass2, pass3, f_pass3, f_status, f_ultimo_acceso, f_actualizacion, suc_registro, f_registro, fec_primer_acceso, num_empleado, fecha_movto, servicio, f_unico_reg
			FROM bdinteg:"informix".si_fusbpiusuarios_int
			WHERE numcte = pClienteInCorrecto and empresa = '001';

			--Inserto el log_desfusion
			LET cDet_mov = TRIM(pClienteInCorrecto)||'|'||TRIM(pClienteCorrecto);
			INSERT INTO bdinteg:"informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES('RESPALDO USUARIOS BPI INTEG','si_fusbpiusuarios_int',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
			
		ELSE
		
			SELECT {+INDEX (bdinteg:"informix".si_fusbpiusuarios_int idxfusbpi)} COUNT(*)
			INTO iContador				
			FROM bdinteg:"informix".si_fusbpiusuarios_int 
			WHERE numcte = pClienteInCorrecto and empresa = '001';
			
			IF ( iContador >= 1 ) THEN
			
				UPDATE {+INDEX (bdinteg:"informix".si_bpiusuarios idx_bpi)} bdinteg:"informix".si_bpiusuarios
				SET numcte = pClienteInCorrecto
				WHERE numcte = pClienteCorrecto and empresa = '001';
				
				--Inserto el log_desfusion
				LET cDet_mov = TRIM(pClienteInCorrecto)||'|'||TRIM(pClienteCorrecto);
				INSERT INTO bdinteg:"informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('USUARIOS BPI INTEG','si_fusbpiusuarios_int',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
			END IF;
		END IF;
		
		--**********************
		--CAMBIOS CTE BPI INTEG
		--**********************

		SELECT {+INDEX (bdinteg:"informix".si_fuscambiostcte_int idxfusbpi3)} COUNT(*)
		INTO iContador				
		FROM bdinteg:"informix".si_fuscambiostcte_int 
		WHERE numcliente = pClienteCorrecto;
		
		IF ( iContador >= 1 ) THEN
		
			INSERT INTO bdinteg:"informix".si_cambiostcte(numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio)
			SELECT {+INDEX (bdinteg:"informix".si_fuscambiostcte_int idxfusbpi3)} numcliente, id_statusanterior, id_statusactual, ipusuario, fecha_cambio, suc_cambio, usuario_cambio
			FROM bdinteg:"informix".si_fuscambiostcte_int
			WHERE numcliente = pClienteInCorrecto;
			
			--INSERTO EN LOG DESFUSION
			INSERT INTO bdinteg:"informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'RESPALDO CAMBIOS CTE BPI INTEG','si_fuscambiostcte_int',pClienteCorrecto,pClienteInCorrecto,TRIM(pClienteInCorrecto)||'|'||TRIM(pClienteCorrecto)||'|'||id_statusanterior||'|'||id_statusactual||'|'||fecha_cambio,current,pUsuario,CURRENT
			FROM bdinteg:"informix".si_fuscambiostcte_int
			WHERE numcliente = pClienteInCorrecto;
		
		ELSE
		
			SELECT {+INDEX (bdinteg:"informix".si_fuscambiostcte_int idxfusbpi3)} COUNT(*)
			INTO iContador				
			FROM bdinteg:"informix".si_fuscambiostcte_int 
			WHERE numcliente =  pClienteInCorrecto;
			
			IF ( iContador >= 1 ) THEN
			
				UPDATE {+INDEX (bdinteg:"informix".si_cambiostcte idx_cambiostcte)} bdinteg:"informix".si_cambiostcte
				SET numcliente = pClienteInCorrecto
				WHERE numcliente = pClienteCorrecto;
				
				--INSERTO EN LOG DESFUSION
				INSERT INTO bdinteg:"informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'CAMBIOS CTE BPI INTEG','si_fuscambiostcte_int',pClienteCorrecto,pClienteInCorrecto,TRIM(pClienteInCorrecto)||'|'||TRIM(pClienteCorrecto)||'|'||id_statusanterior||'|'||id_statusactual||'|'||fecha_cambio,current,pUsuario,CURRENT
				FROM bdinteg:"informix".si_fuscambiostcte_int
				WHERE numcliente = pClienteInCorrecto;
				
			END IF;
		END IF;
		
		--***********************
		--USUARIO BPI
		--***********************
		
		SELECT {+INDEX (bdinteg:"informix".si_fusbpiusuario idxfusbpi4)} COUNT(*)
		INTO iContador				
		FROM bdinteg:"informix".si_fusbpiusuario 
		WHERE numcliente = pClienteCorrecto;
		
		IF ( iContador >= 1 ) THEN		
		
			INSERT INTO bdibpi:"informix".bpi_usuario(id_usuario, usuario, numcliente, tel_celular, cia_cel, e_mail, f_ultimo_acceso, id_ultima_oper, id_perfil, fecha_bloqueo, st_portal, fecha_bloqueo_camb_pass, fecha_bloqueo_camb_pregs, tipo_bloq_temp_pass, tipo_bloq_temp_resp)
			SELECT {+INDEX (bdinteg:"informix".si_fusbpiusuario idxfusbpi4)} id_usuario, usuario, numcliente, tel_celular, cia_cel, e_mail, f_ultimo_acceso, id_ultima_oper, id_perfil, fecha_bloqueo, st_portal, fecha_bloqueo_camb_pass, fecha_bloqueo_camb_pregs, tipo_bloq_temp_pass, tipo_bloq_temp_resp
			FROM bdinteg:"informix".si_fusbpiusuario
			WHERE numcliente = pClienteInCorrecto;
			
			--INSERTAR EN LOG_DESFUSION
			INSERT INTO bdinteg:"informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'RESPALDO DE USUARIO BPI','si_fusbpiusuario',pClienteCorrecto,pClienteInCorrecto,TRIM(pClienteInCorrecto)||'|'||TRIM(pClienteCorrecto)||'|'||id_usuario||'|'||TRIM(usuario)||'|'||st_portal,CURRENT,pUsuario,CURRENT::DATE
			FROM bdinteg:"informix".si_fusbpiusuario
			WHERE numcliente = pClienteInCorrecto;
			
		ELSE
		
			SELECT {+INDEX (bdinteg:"informix".si_fusbpiusuario idxfusbpi4)} COUNT(*)
			INTO iContador				
			FROM bdinteg:"informix".si_fusbpiusuario 
			WHERE numcliente = pClienteInCorrecto;
			
			IF ( iContador >= 1 ) THEN			
			
				UPDATE {+INDEX(bdibpi:"informix".bpi_usuario inx_ncst)} bdibpi:"informix".bpi_usuario
				SET numcliente = pClienteInCorrecto
				WHERE numcliente = pClienteCorrecto and st_portal IS NOT NULL;				
				--INSERTAR EN LOG_DESFUSION
				INSERT INTO bdinteg:"informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'RESPALDO DE USUARIO BPI','si_fusbpiusuario',pClienteCorrecto,pClienteInCorrecto,TRIM(pClienteInCorrecto)||'|'||TRIM(pClienteCorrecto)||'|'||id_usuario||'|'||TRIM(usuario)||'|'||st_portal,current,pUsuario,CURRENT::DATE
				FROM bdinteg:"informix".si_fusbpiusuario
				WHERE numcliente = pClienteInCorrecto;
			END IF;
		END IF;
		
		
		--**************************
		--CAMBIOS CTE BPI
		--**************************
		
		SELECT {+INDEX (bdinteg:"informix".si_fuscambiostcte idxfusbpi5)} COUNT(*)
		INTO iContador				
		FROM bdinteg:"informix".si_fuscambiostcte 
		WHERE numcliente = pClienteCorrecto;
		
		IF ( iContador >= 1 ) THEN		
		
			INSERT INTO bdibpi:"informix".si_cambiostcte(numcliente,id_statusanterior,id_statusactual,ipusuario,fecha_cambio,suc_cambio,usuario_cambio)
			SELECT {+INDEX (bdinteg:"informix".si_fuscambiostcte idxfusbpi5)} numcliente,id_statusanterior,id_statusactual,ipusuario,fecha_cambio,suc_cambio,usuario_cambio
			FROM bdinteg:"informix".si_fuscambiostcte
			WHERE numcliente = pClienteInCorrecto;
			
			--INSERTAMOS EN LOG_DESFUSION
			INSERT INTO bdinteg:"informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'RESPALDO CAMBIOS CTE BPI','si_fuscambiostcte',pClienteCorrecto,pClienteInCorrecto,TRIM(pClienteInCorrecto)||'|'||TRIM(pClienteCorrecto)||'|'||id_statusanterior||'|'||id_statusactual,CURRENT,pUsuario,CURRENT
			FROM bdinteg:"informix".si_fuscambiostcte
			WHERE numcliente = pClienteInCorrecto;
		ELSE
		
			SELECT {+INDEX (bdinteg:"informix".si_fuscambiostcte idxfusbpi5)} COUNT(*)
			INTO iContador				
			FROM bdinteg:"informix".si_fuscambiostcte 
			WHERE numcliente = pClienteInCorrecto;
			
			IF ( iContador >= 1 ) THEN
			
				UPDATE {+INDEX (bdibpi:"informix".si_cambiostcte numcliente)} bdibpi:"informix".si_cambiostcte
				SET numcliente = pClienteInCorrecto
				WHERE numcliente = pClienteCorrecto;
				
				--INSERTAMOS EN LOG_DESFUSION
				INSERT INTO bdinteg:"informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				SELECT 'CAMBIOS CTE BPI','si_fuscambiostcte',pClienteCorrecto,pClienteInCorrecto,TRIM(pClienteInCorrecto)||'|'||TRIM(pClienteCorrecto)||'|'||id_statusanterior||'|'||id_statusactual,CURRENT,pUsuario,CURRENT
				FROM bdinteg:"informix".si_fuscambiostcte
				WHERE numcliente = pClienteInCorrecto;
			END IF;
		END IF;
		
		--++++++++++++++++++++++++++
		--AVATAR BPI
		--++++++++++++++++++++++++++
		
		SELECT {+INDEX (bdinteg:"informix".si_fusbpiavatar idxfusbpi6)} COUNT(*)
		INTO iContador				
		FROM bdinteg:"informix".si_fusbpiavatar 
		WHERE num_cte = pClienteCorrecto;
		
		IF ( iContador >= 1 ) THEN		
		
			INSERT INTO bdibpi:"informix".bpi_avatar(num_cte,avatar,f_registro,f_modifica,imagen,frase,fecha_bloqtemp, num_intentos_bloqtemp, bloqueo_temporal, mosaico_img)
			SELECT {+INDEX (bdinteg:"informix".si_fusbpiavatar idxfusbpi6)} num_cte,avatar,f_registro,f_modifica,imagen,frase,fecha_bloqtemp, num_intentos_bloqtemp, bloqueo_temporal, mosaico_img
			FROM bdinteg:"informix".si_fusbpiavatar
			WHERE num_cte = pClienteInCorrecto;
			
			--INSERTAMOS EN LOG_DESFUSION
			LET cDet_mov = TRIM(pClienteInCorrecto)||'|'||TRIM(pClienteCorrecto);
			INSERT INTO bdinteg:"informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES('RESPALDO AVATAR BPI','si_fusbpiavatar',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
		ELSE
		
			SELECT {+INDEX (bdinteg:"informix".si_fusbpiavatar idxfusbpi6)} COUNT(*)
			INTO iContador				
			FROM bdinteg:"informix".si_fusbpiavatar 
			WHERE num_cte = pClienteCorrecto;
			
			IF ( iContador >= 1 ) THEN
			
				UPDATE {+INDEX (bdibpi:"informix".bpi_avatar 168_44)} bdibpi:"informix".bpi_avatar
				SET num_cte = pClienteInCorrecto
				WHERE num_cte = pClienteCorrecto;
				--INSERTAMOS EN LOG_DESFUSION
				LET cDet_mov = TRIM(pClienteInCorrecto)||'|'||TRIM(pClienteCorrecto);
				INSERT INTO bdinteg:"informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('RESPALDO AVATAR BPI','si_fusbpiavatar',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
			END IF;
		END IF;
		
		--**************************
		--FINALIZA EL PROCESO DE BPI
		--**************************
		
		-- DIRECCIONES

		LET cDescErr = 'si_direcciones';
		/*--Verificar si la tabla temporal existe en la base de datos
		IF EXISTS (SELECT tabname FROM sysmaster:systabnames WHERE tabname = 'table_dirtemp') THEN
			DROP TABLE  table_dirtemp;--Si existe eliminamos la tabla
		END IF;*/
		--Leer la tabla direcciones y guardar los registros en una tabla temporal
		SELECT numcte,secuencia,tipo_dir,calle, colonia,entre_calles,pais, estado,ciudad, municipio,cod_postal,apart_postal,estado_inegi,
			municipio_inegi,localidad_inegi,numerociudad,numeroextcalle, numerointcalle, departamento,numerocalle,numerocolonia,
			puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio ,entrada ,observaciones,user_insert ,fecha_insert,
			ind_cofeteltel1,ind_cofeteltel2, ind_cofeteltel3
		FROM "informix".si_direcciones
		WHERE numcte = pClienteCorrecto
		INTO TEMP table_dirtemp WITH NO LOG;
		
		--Eliminar los registros de la tabla direcciones y direcciones actual del cliente correcto (no hay otro por que ya fueron fusionados)
		DELETE "informix".si_direcciones WHERE numcte = pClienteCorrecto;
		DELETE "informix".si_direcciones_actual WHERE numcte = pClienteCorrecto;
		
		--Leer la tabla de la tabla fus_direcciones y obtener todos los registros de ambos clientes fusionados,
		--Insertar los registros obtenidos en la tabla direcciones de ambos clientes
		INSERT INTO "informix".si_direcciones (numcte,secuencia,tipo_dir,calle, colonia,entre_calles,pais, estado,ciudad, municipio,cod_postal,apart_postal,estado_inegi,
		municipio_inegi,localidad_inegi,numerociudad,numeroextcalle, numerointcalle, departamento,numerocalle,numerocolonia,
		puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio ,entrada ,observaciones,user_insert ,fecha_insert,
		ind_cofeteltel1,ind_cofeteltel2, ind_cofeteltel3)
		SELECT numcte,secuencia,tipo_dir,calle, colonia,entre_calles,pais, estado,ciudad, municipio,cod_postal,apart_postal,estado_inegi,
		municipio_inegi,localidad_inegi,numerociudad,numeroextcalle, numerointcalle, departamento,numerocalle,numerocolonia,
		puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio ,entrada ,observaciones,user_insert ,fecha_insert,
		ind_cofeteltel1,ind_cofeteltel2, ind_cofeteltel3
		FROM "informix".si_fusdirecciones
		WHERE numcte = pClienteInCorrecto OR numcte = pClienteCorrecto;
		
		LET cDescErr = 'si_fusdirecciones';
		
		IF DBINFO('sqlca.sqlerrd2') > 0 THEN
			FOREACH
				SELECT secuencia,tipo_dir
				INTO sSecuencia,cTipo_dir
				FROM "informix".si_fusdirecciones
				WHERE numcte = pClienteCorrecto

				LET cDet_mov = TRIM(pClienteCorrecto)||'|'||sSecuencia||'|'||TRIM(cTipo_dir);

				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('DIRECCIONES','si_fusdirecciones',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

				LET cDet_mov 	= '';
				LET cTipo_dir 	= '';
				LET sSecuencia 	= 0;

			END FOREACH;
		END IF;
		
		--Obtener los registros que no existan en la fusdirecciones y que esten en la si_direcciones
		--obtengo la secuencia y con esa secuencia buscar en la tabla temporal de si_direcciones
		FOREACH
			SELECT NVL(secuencia,0)
			INTO sSecuencia
			FROM table_dirtemp 
			WHERE fecha_insert >= (SELECT fecha_insert FROM bdinteg:"informix".si_fusionaut WHERE cliente_tit = pClienteCorrecto and cliente_tras= pClienteInCorrecto and estatus = 1)
			
			--Si dicha secuencia es > 0, obtener el registro de la tabla temporal e insertarla en direcciones del cliente correcto
			IF sSecuencia > 0 THEN
				INSERT INTO "informix".si_direcciones (numcte,secuencia,tipo_dir,calle, colonia,entre_calles,pais, estado,ciudad, municipio,cod_postal,apart_postal,estado_inegi,
				municipio_inegi,localidad_inegi,numerociudad,numeroextcalle, numerointcalle, departamento,numerocalle,numerocolonia,
				puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio ,entrada ,observaciones,user_insert ,fecha_insert,
				ind_cofeteltel1,ind_cofeteltel2, ind_cofeteltel3)
				SELECT numcte,(SELECT MAX(secuencia) + 1 from si_direcciones WHERE numcte = pClienteCorrecto),tipo_dir,calle, colonia,entre_calles,pais, estado,ciudad, municipio,cod_postal,apart_postal,estado_inegi,
				municipio_inegi,localidad_inegi,numerociudad,numeroextcalle, numerointcalle, departamento,numerocalle,numerocolonia,
				puntocardinal,unidadhabitac,manzana,otros,andador,etapa,lote,edificio ,entrada ,observaciones,user_insert ,fecha_insert,
				ind_cofeteltel1,ind_cofeteltel2, ind_cofeteltel3
				FROM "informix".table_dirtemp
				WHERE secuencia = sSecuencia;
			END IF;
		END FOREACH;		
		
			DROP TABLE IF EXISTS table_dirtemp;
		--********CUENTA-TELEFONO*********
		
		SELECT COUNT(*)
		INTO iContador				
		FROM bdinteg:si_fuscuenta_telefono 
		WHERE num_cte = pClienteInCorrecto;
		
		IF ( iContador >= 1 ) THEN
		
			LET cDet_mov = TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto);
			
			INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES('CUENTA-TELEFONO','sc_cuenta_telefono',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
			
			SELECT telefono 
			INTO cTelefono 
			FROM bdinteg:si_fuscuenta_telefono 
			WHERE num_cte = pClienteInCorrecto;
			
			UPDATE bdicheq:sc_cuenta_telefono
			SET num_cte = pClienteInCorrecto
			WHERE num_cte = pClienteCorrecto
			AND telefono = cTelefono;
			
			DELETE FROM bdinteg:si_fuscuenta_telefono
			WHERE num_cte = pClienteInCorrecto
			AND telefono = cTelefono;
		END IF;
		--********FINALIZA CUENTA-TELEFONO*********
		
		--********CLUB DE PROTECCION**********
		
		SELECT COUNT(*)
		INTO iContador		
		FROM bdinteg:"informix".si_fus_club_proteccion 
		WHERE numcte = pClienteInCorrecto and empresa = '001' and aceptada IS NOT NULL;
		
		IF ( iContador >= 1 ) THEN
		
			--SI_CLUB_PROTECCION
			--Actualizamos el numero de cliente correcto por el incorrecto
			UPDATE bdinteg:"informix".si_club_proteccion
			SET numcte = pClienteInCorrecto
			WHERE numcte = pClienteCorrecto and empresa = '001' and aceptada IS NOT NULL;
			
			--Insertamos registro en la tabla log_desfusion
			LET cDet_mov = TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto);
			INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES('CLUB DE PROTECCION','si_club_proteccion',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
			
			----BENEFICIARIOS
			UPDATE bdinteg:"informix".si_club_beneficiario
			SET numcte = pClienteInCorrecto
			WHERE numcte = pClienteCorrecto and empresa = '001' and secuencia IS NOT NULL;
			
			----INSERTAMOS EN log_desfusion
			INSERT INTO si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			SELECT 'CLUB DE PROTECCION','si_club_beneficiario',pClienteCorrecto,pClienteInCorrecto,TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto)||'|'||secuencia,CURRENT,pUsuario,CURRENT::DATE
			FROM bdinteg:si_fus_club_beneficiario
			WHERE numcte = pClienteInCorrecto and empresa = '001' and secuencia IS NOT NULL;
			
			--BITACORA
			UPDATE bdinteg:"informix".si_club_bitacora
			SET numcte = pClienteInCorrecto
			WHERE numcte = pClienteCorrecto and empresa = '001' and fecha IS NOT NULL;
			
			--Insertamos registro en la tabla log_desfusion
			LET cDet_mov = TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto);
			INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES('CLUB DE PROTECCION','si_club_bitacora',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
			
			--SI_CLUB_HISCTEPROSPECTO
			UPDATE bdinteg:"informix".si_club_hiscteprospecto
			SET ctebancpl = pClienteInCorrecto
			WHERE ctebancpl = pClienteCorrecto and empresa = '001';
			
			--Insertamos registro en la tabla log_desfusion
			LET cDet_mov = TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto);
			INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES('CLUB DE PROTECCION','si_club_hiscteprospecto',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
			
			--SERVICIO
			UPDATE bdinteg:"informix".si_club_servicio
			SET numcte = pClienteInCorrecto
			WHERE numcte = pClienteCorrecto and empresa = '001' and fecha IS NOT NULL;
			
			--Insertamos registro en la tabla log_desfusion
			LET cDet_mov = TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto);
			INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES('CLUB DE PROTECCION','si_club_servicio',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
			
			
		END IF;
		--*******FIN CLUB DE PROTECCION*******
		
		--CTESCTAS TRANSFER 
		
		SELECT COUNT(*)
		INTO iContador				
		FROM bdinteg:si_fustfmaecte 
		WHERE numcte = (pClienteInCorrecto);
		
		IF ( iContador >= 1 ) THEN
			
			FOREACH  
				SELECT numcte_tf, cuenta_tf
				INTO vcnumcte_tf, vc_cuenta_tf
				FROM "informix".si_fustfmaecte
				WHERE numcte = pClienteInCorrecto
		
				UPDATE bditransfer:tf_maecte
				SET numcte = pClienteInCorrecto
				WHERE numcte = pClienteCorrecto AND numcte_tf = vcnumcte_tf AND cuenta_tf = vc_cuenta_tf;
			
				LET cDet_mov = TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto)||'|'||TRIM(vcnumcte_tf)||'|'||TRIM(vc_cuenta_tf);
				
				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('TRANSFER','tf_maecte',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
		
			END FOREACH; 
		END IF;
		--*******RELACION CLIENTE BANCOPPEL-COPPEL*******
		
		SELECT COUNT(*)
		INTO iContador				
		FROM bdinteg:si_fusrelacion_ctebcplcpl 
		WHERE empresa = '001' AND numcte_banco = pClienteInCorrecto;
		
		IF ( iContador >= 1 ) THEN
			
			SELECT empresa, numcte_banco, cliente, numempleado, fecha_insert
			INTO cEmpresa, cNumcteBanco, cCliente, cNumempleado, dFecha_insert
			FROM bdinteg:si_fusrelacion_ctebcplcpl
			WHERE empresa = '001'
			AND numcte_banco = pClienteInCorrecto;
			
			SELECT empresa, numcte_banco, cliente, numempleado, fecha_insert
			INTO cEmpresaAux, cNumcteBancoAux, cClienteAux, cNumempleadoAux, dFecha_insertAux
			FROM bdinteg:si_relacion_ctebcplcpl
			WHERE empresa = cEmpresa
			AND numcte_banco = pClienteCorrecto;
			
			IF DBINFO ('sqlca.sqlerrd2') <> 0 THEN
				IF cEmpresa = cEmpresaAux AND cCliente = cClienteAux AND cNumempleado = cNumempleadoAux AND dFecha_insert = dFecha_insertAux THEN
					UPDATE bdinteg:si_relacion_ctebcplcpl
					SET numcte_banco = pClienteInCorrecto
					WHERE empresa = cEmpresa
					AND numcte_banco = pClienteCorrecto;
				ELSE
					INSERT INTO bdinteg:si_relacion_ctebcplcpl (empresa, numcte_banco, cliente, numempleado, tipo_relacion, definicion, status, tipo_re_ini, fecha_insert, cliente_prosp)
					SELECT empresa, numcte_banco, cliente, numempleado, tipo_relacion, definicion, status, tipo_re_ini, fecha_insert, cliente_prosp
					FROM bdinteg:si_fusrelacion_ctebcplcpl 
					WHERE empresa = cEmpresa
					AND numcte_banco = pClienteInCorrecto;			
				END IF;
			END IF;
						
			DELETE FROM bdinteg:si_fusrelacion_ctebcplcpl
			WHERE empresa = cEmpresa 
			AND numcte_banco = pClienteInCorrecto;
			
			LET cDet_mov = TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto)||'|'||TRIM(cCliente);
			
			INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
			VALUES('REL CTE BCPL-CPL','si_relacion_ctebcplcpl',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);

		END IF;
		
		--*******RELACION CLIENTE BANCOPPEL-COPPEL HISTORICA*******
		
		SELECT COUNT(*)
		INTO iContador				
		FROM bdinteg:si_fusrelacion_ctebcplcpl_hist 
		WHERE empresa = '001' AND numcte_banco = pClienteInCorrecto;
		
		IF ( iContador >= 1 ) THEN
		
			FOREACH
				SELECT empresa, numcte_banco, secuencia, cliente, numempleado, fecha_insert
				INTO cEmpresa, cNumcteBanco, iSecuencia, cCliente, cNumempleado, dFecha_insert
				FROM bdinteg:si_fusrelacion_ctebcplcpl_hist
				WHERE empresa = '001'
				AND numcte_banco = pClienteInCorrecto
				
				SELECT empresa, numcte_banco, secuencia, cliente, numempleado, fecha_insert
				INTO cEmpresaAux, cNumcteBancoAux, iSecuenciaAux, cClienteAux, cNumempleadoAux, dFecha_insertAux
				FROM bdinteg:si_relacion_ctebcplcpl_hist
				WHERE empresa = cEmpresa
				AND numcte_banco = pClienteCorrecto
				AND secuencia = iSecuencia;
			
				IF DBINFO ('sqlca.sqlerrd2') <> 0 THEN
					IF cEmpresa = cEmpresaAux AND cCliente = cClienteAux AND cNumempleado = cNumempleadoAux AND dFecha_insert = dFecha_insertAux THEN
						UPDATE bdinteg:si_relacion_ctebcplcpl_hist
						SET numcte_banco = pClienteInCorrecto
						WHERE empresa = cEmpresa
						AND numcte_banco = pClienteCorrecto
						AND secuencia = iSecuencia;
					ELSE
						INSERT INTO bdinteg:si_relacion_ctebcplcpl_hist (empresa, numcte_banco, cliente, numempleado, tipo_relacion, definicion, status, tipo_re_ini, fecha_insert, cliente_prosp)
						SELECT empresa, numcte_banco, cliente, numempleado, tipo_relacion, definicion, status, tipo_re_ini, fecha_insert, cliente_prosp
						FROM bdinteg:si_fusrelacion_ctebcplcpl_hist 
						WHERE empresa = cEmpresa 
						AND numcte_banco = pClienteInCorrecto
						AND secuencia = iSecuencia;
					END IF;
				END IF;
				LET cDet_mov = TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto)||'|'||TRIM(cNumcteBanco);
				
				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('REL CTE BCPL-CPL HIST','si_relacion_ctebcplcpl_hist',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
			END FOREACH;
			
			DELETE FROM bdinteg:si_fusrelacion_ctebcplcpl_hist 
			WHERE empresa = cEmpresa 
			AND numcte_banco = pClienteInCorrecto;
		END IF;
		
		--CREDISOLUCIONES
		
		SELECT {+INDEX (bdicred:si_fuspromocion_credito si_fuspromocion_credito_num_cte)} COUNT(*)
		INTO iContador				
		FROM bdinteg:si_fuspromocion_credito 
		WHERE num_cte = (pClienteInCorrecto);

		IF ( iContador >= 1 ) THEN

			FOREACH  
				SELECT {+INDEX (bdicred:si_fuspromocion_credito si_fuspromocion_credito_num_cte)} folio_suc
				INTO cFolio_suc
				FROM "informix".si_fuspromocion_credito
				WHERE num_cte = pClienteInCorrecto
				
				UPDATE {+INDEX (bdicred:sd_promocion_credito indx_cte)} bdicred:sd_promocion_credito
				SET num_cte = pClienteInCorrecto
				WHERE num_cte = pClienteCorrecto AND folio_suc = cFolio_suc;
			
				LET cDet_mov = TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto)||'|'||TRIM(cFolio_suc);
				
				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('CREDISOLUCIONES','sd_promocion_credito',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
		
			END FOREACH;
			DELETE "informix".si_fuspromocion_credito WHERE num_cte = pClienteInCorrecto;
		END IF;		
		
		--CREDISOLUCIONESRV
		
		SELECT {+INDEX (bdicred:si_fuspromocion_credito_rev si_fuspromocion_credito_rev_num_cte)} COUNT(*)
		INTO iContador				
		FROM bdinteg:si_fuspromocion_credito_rev 
		WHERE num_cte = (pClienteInCorrecto);

		IF ( iContador >= 1 ) THEN

			FOREACH  
				SELECT {+INDEX (bdicred:si_fuspromocion_credito_rev si_fuspromocion_credito_rev_num_cte)} folio_suc, folio_suc_mov_crd
				INTO cFolio_suc, cFolio_suc_mov_crd
				FROM "informix".si_fuspromocion_credito_rev
				WHERE num_cte = pClienteInCorrecto
				
				UPDATE {+INDEX (bdicred:sd_promocion_credito_rev inx_cte)} bdicred:sd_promocion_credito_rev
				SET num_cte = pClienteInCorrecto
				WHERE num_cte = pClienteCorrecto AND folio_suc = cFolio_suc AND folio_suc_mov_crd = cFolio_suc_mov_crd;
			
				LET cDet_mov = TRIM(pClienteCorrecto)||'|'||TRIM(pClienteInCorrecto)||'|'||TRIM(cFolio_suc)||'|'||TRIM(cFolio_suc_mov_crd);
				
				INSERT INTO "informix".si_logdesfusion(proceso,tabla,cliente_tit,cliente_tras,detalle_mov,fecha_hora,user_insert,fecha_insert)
				VALUES('CREDISOLUCIONESRV','sd_promocion_credito_rev',pClienteCorrecto,pClienteInCorrecto,cDet_mov,CURRENT,pUsuario,CURRENT);
		
			END FOREACH;
			DELETE "informix".si_fuspromocion_credito_rev WHERE num_cte = pClienteInCorrecto;	
		END IF;				

		RETURN cCodRet, cDescErr;
END
END PROCEDURE;