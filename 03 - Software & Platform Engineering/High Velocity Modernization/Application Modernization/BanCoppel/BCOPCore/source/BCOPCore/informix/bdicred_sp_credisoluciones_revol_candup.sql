CREATE PROCEDURE "informix".sp_credisoluciones_revol_candup(pempresa CHAR(3), pFolioMovto CHAR(20) DEFAULT "", pSucursal CHAR(4), pUsuario CHAR(20))
   RETURNING CHAR(6), CHAR(80);
	---SE CAMBIA EL PARAMETRO pFolioMovto = Folio_suc de la credisolucion
	--DECLARACION DE VARIABLES.
	DEFINE iSqlErr                       INTEGER;
	DEFINE iIsamErr                      INTEGER;
	DEFINE cErrorInfo                    CHAR(100);
	DEFINE CodRet                        CHAR(6);
	DEFINE Mensaje                  	 CHAR(80);
	DEFINE CSnum_credito,cCredito_promo  CHAR(20);
	DEFINE v_total_cap_cs, v_total_mto_cs, v_mto_pag_cs, v_capital_cs, v_interes_cs, v_iva_cs, v_monto_actual, v_monto_int_iva 	DECIMAL(14,2);
	DEFINE cfolio_mov_promo,cfolio_suc_promo CHAR(16);
	DEFINE cCharAux          			 CHAR(80);
	DEFINE dtDateAux         			 DATE;
	DEFINE dDecAux           			 DECIMAL(18,2);
	DEFINE iIntAux           			 INTEGER;
	DEFINE dPagoCom,dPagoIvaCom,dSdoAdeudTotal,dIntDevengado,dIvaIntDevengado,vcap_vig,dSdoAdeudTotalAct,dIntVig,dIvaIntVig   DECIMAL(18,2);
	DEFINE dtFechaApertura,dtFechaProxPago  DATE;
	DEFINE dPagoMinAct        			 DECIMAL(18,2);
	DEFINE cStatus						 CHAR(23);
	DEFINE cStatus_tar					 CHAR(1);
	DEFINE dFecha_hoy					 DATE;
	DEFINE dFecha_credisol				 DATE;
	DEFINE cTipo_promo					 CHAR(1);
	DEFINE sStatus_cancel1				 SMALLINT;
	DEFINE sStatus_cancel2				 SMALLINT;
	DEFINE sStatus_cancel3				 SMALLINT;
	DEFINE sBand				 		 SMALLINT;
	DEFINE cStatus_promo				 CHAR(1);
	
	--INICIALIZACION DE VARIABLES.

	LET iSqlErr      = 0;
	LET iIsamErr     = 0;
	LET cErrorInfo   = "";
	LET CodRet       = "000000";
	LET Mensaje   	 = "Se realiz?? proceso exitosamente";
	LET CSnum_credito,cCredito_promo = '','';
	LET v_total_cap_cs, v_total_mto_cs, v_mto_pag_cs, v_capital_cs, v_interes_cs, v_iva_cs, v_monto_actual, v_monto_int_iva = 0,0,0,0,0,0,0,0;
	LET cfolio_mov_promo,cfolio_suc_promo = '','';
	LET cCharAux       = "";
	LET dtDateAux      = DATE(1);
	LET dDecAux        = 0; LET iIntAux = 0; LET dPagoCom = 0; LET dPagoIvaCom = 0; LET dSdoAdeudTotal = 0; LET dIntDevengado = 0; LET dIvaIntDevengado = 0; LET vcap_vig = 0; LET dIntVig = 0; LET dIvaIntVig = 0;
	LET dtFechaApertura  = DATE(1); LET dtFechaProxPago = DATE(1); LET dPagoMinAct = 0; LET dSdoAdeudTotalAct = 0;
	LET cStatus 		 = "";
	LET cStatus_tar 	 = "";
	LET dFecha_hoy 	 	 = "";
	LET dFecha_credisol  = "";
	LET cTipo_promo 	 = "";
	LET sStatus_cancel1      = 0;
	LET sStatus_cancel2      = 0;
	LET sStatus_cancel3      = 0;
	LET sBand      			 = 0;
	LET cStatus_promo 	 	 = "";
	
	
	
	BEGIN

		ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
		   IF iSqlErr != 0 THEN
				LET CodRet     = iSqlErr;
				LET Mensaje = cErrorInfo;
				RETURN CodRet, TRIM(Mensaje);
		   END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/resplogifx/credisoluciones/sp_credisoluciones_revol_can20.out";
		--TRACE ON;
	  
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		-- SE TOMA LA FECHA HOY PARA COMPARARSE CON LA FECHA DE LA CREDISOLUCION A CANCELAR YA QUE NO SE PUEDE CANCELAR EL MISMO DÃA QUE SE DA DE ALTA
		SELECT fecha_hoy 
		INTO dFecha_hoy
		FROM "informix".sd_fechas;
		
			-- SE OBTIENEN LOS ESTATUS DE CREDISOLUCIONES QUE SI SE PUEDEN CANCELAR
			SELECT valor INTO sStatus_cancel1 FROM "informix".sd_param WHERE cod_param = '965';
			SELECT valor INTO sStatus_cancel2 FROM "informix".sd_param WHERE cod_param = '966';
			SELECT valor INTO sStatus_cancel3 FROM "informix".sd_param WHERE cod_param = '967';
		
			FOREACH
				-- SE OBTIENEN LOS DATOS DE LAS CREDISOL QUE SE VAN A CANCELAR DE ACUERDO AL FOLIO_MOVTO 
				SELECT b.num_credito,a.num_sol_prestamo, a.monto_actual, a.monto_int_iva, a.folio_movto, a.folio_suc, a.fecha, a.num_promo, a.status
				INTO CSnum_credito,cCredito_promo, v_monto_actual, v_monto_int_iva, cfolio_mov_promo, cfolio_suc_promo, dFecha_credisol,cTipo_promo, cStatus_promo     
				FROM bdicred:"informix".sd_promocion_credito a
				INNER JOIN bdicred:sd_maecred b on (b.empresa = a.empresa and b.num_credito = a.num_credito)
				INNER JOIN bdicred:sd_maesdos mae on (mae.num_credito = b.num_credito)
				 WHERE a.empresa = pEmpresa
				   AND a.sistema = '06'
				   AND b.status_cred IN ('AA','E1')
				   AND (mae.monto_vencido + mae.mto_venc_trasp) = 0
				   AND a.folio_suc = DECODE(pFolioMovto, "", a.folio_suc, pFolioMovto)				   
				   
				-- SI EL ESTATUS DE LA CREDISOL NO COINCIDE CON LOS DE LA SD_PARAM YA NO SE TOMA ENCUENTA Y SE TOMA LA SIGUIENTE
				IF cStatus_promo NOT IN(sStatus_cancel1,sStatus_cancel2,sStatus_cancel3) THEN
					CONTINUE FOREACH;
				END IF

				-- LA CREDISOL NO SE PUEDE CANCELAR EL MISMO DÃA QUE SE DA DE ALTA, POR TAL MOTIVO SE COMPARA LA FECHA DE ALTA CON LA FECHA HOY
                IF dFecha_hoy <= dFecha_credisol THEN				
					CONTINUE FOREACH;
				END IF				

				--SE OBTIENE EL ADEUDO DEL CLIENTE DE CREDISOLUCIONES HASTA ESE MOMENTO				

				EXECUTE PROCEDURE "informix".sp_consulta_saldos_general(pEmpresa,cCredito_promo)
					INTO CodRet,Mensaje,cCharAux,cCharAux,dtFechaApertura,dtFechaProxPago,dPagoMinAct,dtDateAux,
					  iIntAux,iIntAux,dDecAux,dDecAux,dDecAux,dDecAux,vcap_vig,dDecAux,dDecAux,dDecAux,
					  dDecAux,dIntVig,dDecAux,dDecAux,dDecAux,dDecAux,dIvaIntVig,dDecAux,dDecAux,dDecAux,
					  dDecAux,dDecAux,dDecAux,dDecAux,dSdoAdeudTotalAct,dIntDevengado,dIvaIntDevengado,
					  dDecAux,dDecAux,cCharAux,iIntAux,cCharAux,cCharAux,cCharAux,cCharAux,iIntAux,
					  cCharAux,cCharAux,iIntAux,cCharAux;

				IF  dSdoAdeudTotalAct > 0 THEN
					--SE REALIZA EL PAGO POR EL MONTO CORRESPONDIENTE AL MES CORRIENTE DE CREDISOLUCIONES
					CALL "informix".sp_cargo_abono_palzo(pEmpresa,cCredito_promo,'',dSdoAdeudTotalAct,USER,'9290','4210',3,'')
					RETURNING CodRet, Mensaje;

					IF CodRet::INTEGER <> 0 THEN
						RETURN CodRet, TRIM(Mensaje);
					ELSE
						LET CodRet = "000";
					END IF;
					
					IF (SELECT sdo_retenido FROM "informix".sd_maesdos WHERE empresa = '001' and num_credito = CSnum_credito) >= (v_monto_actual + v_monto_int_iva) THEN		
						
						LET sBand = 1;
						
						UPDATE "informix".sd_maesdos
						 --SET sdo_retenido = sdo_retenido - (v_monto_actual + v_capital_cs)     --FMV 19mar14: Se omite v_capital_cs sin valor
						   SET sdo_retenido = sdo_retenido - (v_monto_actual + v_monto_int_iva) 
						 WHERE empresa = '001' 
						  and num_credito = CSnum_credito;

						UPDATE "informix".sd_promocion_credito
						   SET status = 7		-- SE CAMBIA EL ESTATUS A CANCELADO
						 WHERE empresa = '001'
						   AND num_sol_prestamo = cCredito_promo
						   AND folio_suc = pFolioMovto;

						UPDATE "informix".sd_maeretenido
						   SET estatus = 'S'
						 WHERE empresa = '001'
						   AND num_credito = CSnum_credito
						   AND folio_suc = cfolio_mov_promo;

						UPDATE "informix".sd_maeretenido
						   SET estatus = 'S'
						 WHERE empresa = '001'
						   AND num_credito = CSnum_credito
						   AND NVL(SUBSTR(referencia,1,16),'') = cfolio_suc_promo;
						   
						UPDATE "informix".sd_amortiza_creditocrd
						   SET capital_status = 5,
							   capital_status_ant = 1, 
							   interes_pagado = interes_debe,
							   interes_fecha_pago = dFecha_hoy,
							   iva_pagado = iva_debe,
							   iva_fecha_pago = dFecha_hoy							   
						 WHERE fecha_cuota = dFecha_hoy
						   AND num_credito = cCredito_promo;   
						   
						   LET cStatus = 'A SOLICITUD DEL CLIENTE'; 
						   
						   IF NVL(pFolioMovto, '') = '' THEN -- SI ES POR PROCESO BATCH SI LA TARJETA ESTA VENCIDA ES LA DESCRIPCIÃN QUE SE REGISTRA EN LA TABLA SD_CANCELA_CREDISOL
						   
								LET pSucursal = '9250';
						   
								SELECT status_tar
								INTO cStatus_tar
								FROM "informix".sd_tarjeta 
								WHERE empresa = '001'
								AND num_credito = CSnum_credito
								AND tipo_tarjeta = 'T'
								AND secuencia = (SELECT MAX(secuencia) FROM "informix".sd_tarjeta WHERE empresa = '001' AND num_credito = CSnum_credito AND tipo_tarjeta = 'T');
								
								IF cStatus_tar <> 'A' THEN
									LET cStatus = 'TARJETA VENCIDA';
								END IF							   
						   END IF							   
						   
						-- SE AGREGA UN REGISTRO CADA VEZ QUE SE CANCELA UNA CREDISOL A LA TABLA SD_CANCELA_CREDISOL
						INSERT INTO "informix".sd_cancela_credisol (empresa, num_credito, folio_movto, fecha_cancela, motivo_de_cancelacion,tipo_promo, sucursal, fecha_insert, user_insert)
						VALUES (pempresa, cCredito_promo, TRIM(pFolioMovto), CURRENT, TRIM(cStatus), cTipo_promo, pSucursal, dFecha_hoy, pUsuario);
						
					END IF;

                    IF dtFechaProxPago - dFecha_hoy = 0 THEN ----VALIDAR CUANDO ES EL MISMO DIA DEL MESIVERSARIO
                        IF dIvaIntVig <> 0 THEN
                            CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIvaIntVig,USER,'9290','4202',1,cCredito_promo)
                            RETURNING CodRet, Mensaje;

                            IF CodRet::INTEGER <> 0 THEN
                                RETURN CodRet, TRIM(Mensaje);
                            ELSE
                                LET CodRet = "000";
                            END IF;
                        END IF; 

                        IF dIntVig <> 0 THEN
                            CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIntVig,USER,'9290','4201',1,cCredito_promo)
                            RETURNING CodRet, Mensaje;

                            IF CodRet::INTEGER <> 0 THEN
                               RETURN CodRet, TRIM(Mensaje);
                            ELSE
                             LET CodRet = "000";
                            END IF;
                        END IF;

                    ELSE 
                        IF dIvaIntDevengado <> 0 THEN
                            CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIvaIntDevengado,USER,'9290','4202',1,cCredito_promo)
                            RETURNING CodRet, Mensaje;

                            IF CodRet::INTEGER <> 0 THEN
                                RETURN CodRet, TRIM(Mensaje);
                            ELSE
                                LET CodRet = "000";
                            END IF;
                        END IF;

                        IF dIntDevengado <> 0 THEN
                            CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',dIntDevengado,USER,'9290','4201',1,cCredito_promo)
                              RETURNING CodRet, Mensaje;

                              IF CodRet::INTEGER <> 0 THEN
                                   RETURN CodRet, TRIM(Mensaje);
                              ELSE
                                 LET CodRet = "000";
                              END IF;
                        END IF;
                    END IF;

					IF vcap_vig <> 0 THEN
						CALL "informix".sp_cargo_abono_palzo(pEmpresa,CSnum_credito,'',vcap_vig,USER,'9290','4200',1,cCredito_promo)
						  RETURNING CodRet, Mensaje;

						IF CodRet::INTEGER <> 0 THEN
						   RETURN CodRet, TRIM(Mensaje);
						ELSE
						 LET CodRet = "000";
						END IF;
					END IF;
				END IF;

				LET dSdoAdeudTotalAct = 0;
				LET vcap_vig = 0;
				LET dIntDevengado = 0;
				LET dIvaIntDevengado = 0;				

			END FOREACH;
			
			IF DBINFO('sqlca.sqlerrd2') = 0 OR sBand = 0 THEN
				LET CodRet = '000001';
				LET Mensaje = 'CREDISOLUCION NO VALIDA PARA CANCELARSE';
			END IF		

		RETURN CodRet, TRIM(Mensaje);
	END;
END PROCEDURE
DOCUMENT
'--------------------------------------------------------------------------------------------------------------',
'NOMBRE: Mario Olivo',
'DESCRIPCION: Se agrega parametro pFolioMovto con (DEFAULT = '') para agregar el filtro',
' 			(AND a.folio_movto = DECODE(pFolioMovto, "", a.folio_movto, pFolioMovto)) en la consulta de',
'			la tabla sd_promocion_credito.',
'			Se implementan reglas de informix.',
'			Se castea el codret por integer para compactar el codigo de retorno y entrar a las validaciones',
'FECHA DE MODIFICACION: 11/junio/2013',
'BASE DE DATOS: bdicred',
'FOLIO DE PROYECTO: 1373',
'--------------------------------------------------------------------------------------------------------------',
'Folio: 1397',
'Autor: 94912599 ',
'Fecha: 23/12/2013',
'DescripciÃ³n: Se modifica para que se cancelen las cresidol solo los que esten en la sd_param,asÃ­ como',
'que no se puedan cancelar el mismo dÃ­a, tambiÃ©n se agrega un registro cada vez que se cancela una credisol',
' a la tabla sd_cancela_credisol.',
'Si folio_movto = vacio se compara el estatus de la tarjeta y si esta vencida se regresa la descripciÃ³n:',
'TARJETA VENCIDA y si no es es asÃ­ sera por default A SOLICITUD DEL CLIENTE',
'Sustento: RQM 10 214-4 Ademdum Credisoluciones Efec_Vf_cancela.doc',
'Solicita: Faviola Martinez Juarez',
'BD:BDICRED',
'--------------------------------------------------------------------------------------------------------------';

create procedure "informix".sp_generasdosvdos()
       returning CHAR(5);

DEFINE cfechaarchivo           CHAR(8);
DEFINE cfechaconsulta          DATE;
DEFINE cNombreArchivo1	       CHAR(100);
DEFINE cNombreArchivo2	       CHAR(100);

DEFINE cSql                    CHAR(5000);

DEFINE vcodret   CHAR(6);
--DEFINE p_Mensaje CHAR(80);
DEFINE scod_ret  CHAR(5);
DEFINE vsqlerr   INTEGER;


LET  cSql="";
LET cNombreArchivo1 = "";
LET cNombreArchivo2 = "";
LET cSql = '';

BEGIN

ON EXCEPTION SET vsqlerr
   IF vsqlerr != 0 THEN
      LET vcodret = vsqlerr;
      Return vcodret;
   END IF;
END EXCEPTION;

    LET vcodret = "000000";
    

   -- SET DEBUG FILE TO "gensdosvdos17012008.out";
   -- TRACE ON;

    IF DAY(CURRENT::DATE) BETWEEN 1 AND 20 THEN
        LET  cfechaconsulta=MDY(MONTH(CURRENT::DATE),'01',YEAR(CURRENT::DATE))-1;
        LET  cfechaarchivo=LPAD(TRIM(DAY(cfechaconsulta)::CHAR(2)),2,'0') || 
                           LPAD(TRIM(MONTH(cfechaconsulta)::CHAR(2)),2,'0')||
                           YEAR(cfechaconsulta);
       --para Generar el archivo de Salida.
            LET cSql = 'echo "set isolation to dirty read;  set lock mode to wait 3;' ||
		       ' UNLOAD TO ' || '''/resplogifx/archivoscartera/SaldosVencidosRegistros.unl''' || ' DELIMITER ' || '''|'''|| 
                       ' SELECT a.num_credito, a.numcte, f.num_tarjeta, nvl((SELECT sucursal FROM bdicred:sd_movhis WHERE '||
                       ' empresa= ''001'' AND a.empresa = empresa and a.num_credito = num_credito AND codigo_fun= ''001'' AND '||
                       ' codigo_ref= 1 AND reversado = ''N'' AND secuencia = (SELECT MAX(secuencia) FROM bdicred:sd_movhis WHERE '||
                       ' empresa= ''001'' AND a.num_credito = num_credito AND codigo_fun= ''001'' AND codigo_ref= 1 AND '||
                       ' reversado = ''N'' and fecha_mov > date(0))),"0000"),'||
                       ' nvl((select numerociudad from bdinteg:si_direcciones where a.numcte = numcte and tipo_dir = ''1'' and '||
                       ' secuencia = (select max(secuencia) from bdinteg:si_direcciones where a.numcte = numcte and tipo_dir = ''1'' )),0),'||
                       ' nvl(b.sdo_capital+b.monto_vencido+b.mto_venc_trasp+b.cap_tras_no_venci,0),'||
                       ' nvl((SELECT max(fecha_mov) FROM bdicred:sd_movhis WHERE empresa = ''001'' and a.empresa = empresa AND '||
                       ' a.num_credito = num_credito AND codigo_fun = ''002'' AND codigo_ref  IN (30,40,41,42,37,38,39,50) AND '||
                       ' reversado = ''N'' and fecha_mov > date(0)),date(1)),'||
                       ' nvl((select monto_financiado from bdicred:sd_maesdoshist where empresa = ''001'' and a.empresa = empresa'||
                       ' and a.num_credito = num_credito and fecha = mdy(month(a.fecha),''20'',year(a.fecha))),0),'||
                       ' nvl(b.monto_vencido + b.mto_venc_trasp,0), case when (a.status_cred in (''AA'',''E1'') and (b.monto_vencido + b.mto_venc_trasp) = 0) then 0 else '||
                       ' nvl((select sum(interes_debe+iva_debe-interes_pagado-iva_pagado) '||
                       ' from bdicred:sd_amortiza_credito where empresa=a.empresa and num_credito=a.num_credito and capital_status IN (''2'',''7'',''6'')),0) end, '||
                       ' nvl((b.sdo_contab_mora+sdo_moratorio)*(SELECT sum(1 + iva) From bdinteg:si_sucursales WHERE a.sucursal = sucursal),0),'||
                       ' a.fecha_apertura, b.monto_otorgado, nvl(a.tasa_interes,0),'||
                       ' nvl((select sdo_capital+monto_vencido+mto_venc_trasp+cap_tras_no_venci from bdicred:sd_maesdoscont '||
                       ' where empresa = ''001'' and a.empresa = empresa and a.num_credito = num_credito and '||
                       ' fecha = (mdy(month(a.fecha),''01'',year(a.fecha)) - 1)),0), nvl(h.prox_fecha_pago,date(1)),'||
                       ' a.status_cred, nvl(b.mto_fin_ven_trasp,0), nvl((SELECT trim(valor)  FROM bdicred:sd_param WHERE cod_param= ''034''),''0''),'||
                       ' '' '', nvl((select monto_financiado - monto_vencido - mto_venc_trasp from bdicred:sd_maesdoshist '||
                       ' where empresa = ''001'' and a.empresa = empresa and a.num_credito = num_credito and '||
                       ' fecha = (mdy(month(a.fecha),''20'',year(a.fecha)) - 1 units month)),0)'||
                       ' FROM bdicred:sd_maecredcont a '||
                       ' inner join bdicred:sd_maesdoscont b on (b.empresa = a.empresa AND b.num_credito= a.num_credito'||
                       ' AND b.fecha = '''|| cfechaconsulta || '''  AND b.sdo_cap_insoluto > 0) '||
                       ' inner join bdicred:sd_tarjeta f on (f.empresa = a.empresa AND f.num_credito= a.num_credito '||
                       ' and f.tipo_tarjeta = ''T'' AND f.secuencia= (SELECT MAX(i.secuencia) FROM bdicred:sd_tarjeta i'||
                       ' WHERE i.empresa =  a.empresa AND i.num_credito=a.num_credito AND i.tipo_tarjeta = ''T''))'||
                       ' inner join  bdicred:sd_maecredanexo h  on (a.empresa = h.empresa AND a.num_credito=h.num_credito)'||
                       ' WHERE a.empresa = ''001'' AND a.status_cred in (''AA'',''BA'',''BT'',''E1'',''E2'',''E3'') AND a.fecha = '''|| cfechaconsulta || ''';'||
                       ' " > /resplogifx/archivoscartera/SaldosVencidosQuerys.sql';

              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/SaldosVencidosQuerys.sql';
              SYSTEM cSql;

  
       -- para Generar el archvio de Cifras.
              LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/SaldosVencidosCifrasControlRegistros.unl''' || ' DELIMITER ' || '''|'''  ||
                         ' SELECT count(*)::integer,sum(b.sdo_capital+b.monto_vencido+b.mto_venc_trasp+b.cap_tras_no_venci),'||
                         ' sum(b.monto_vencido + b.mto_venc_trasp), '''|| cfechaconsulta ||''''||
                         ' FROM bdicred:sd_maecredcont a '||
                         ' inner join bdicred:sd_maesdoscont b on (b.empresa = a.empresa AND b.num_credito= a.num_credito'||
                         ' AND b.fecha = '''|| cfechaconsulta || '''  AND b.sdo_cap_insoluto > 0) '||
                         ' inner join bdicred:sd_tarjeta f on (f.empresa = a.empresa AND f.num_credito= a.num_credito '||
                         ' and f.tipo_tarjeta = ''T'' AND f.secuencia= (SELECT MAX(i.secuencia) FROM bdicred:sd_tarjeta i'||
                         ' WHERE i.empresa =  a.empresa AND i.num_credito=a.num_credito AND i.tipo_tarjeta = ''T''))'||
                         ' inner join  bdicred:sd_maecredanexo h  on (a.empresa = h.empresa AND a.num_credito=h.num_credito)'||
                         ' WHERE a.empresa = ''001'' AND a.status_cred in (''AA'',''BA'',''BT'',''E1'',''E2'',''E3'') AND a.fecha = '''|| cfechaconsulta || ''';'||
                         ' " > /resplogifx/archivoscartera/SaldosVencidosQuerysCifrasControl.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/SaldosVencidosQuerysCifrasControl.sql';
              SYSTEM cSql;
    ELSE 
        LET  cfechaconsulta=MDY(MONTH(CURRENT::DATE),'20',YEAR(CURRENT::DATE));
        LET  cfechaarchivo=LPAD(TRIM(DAY(cfechaconsulta)::CHAR(2)),2,'0') || 
                           LPAD(TRIM(MONTH(cfechaconsulta)::CHAR(2)),2,'0')||
                           YEAR(cfechaconsulta);

            LET cSql = 'echo " set isolation to dirty read;  set lock mode to wait 3;' ||
		       ' UNLOAD TO ' || '''/resplogifx/archivoscartera/SaldosVencidosRegistros.unl''' || ' DELIMITER ' || '''|'''|| 
                       ' SELECT a.num_credito, a.numcte, f.num_tarjeta, nvl((SELECT sucursal FROM bdicred:sd_movhis '||
                       ' WHERE empresa= ''001'' AND a.empresa = empresa and a.num_credito = num_credito AND codigo_fun= ''001'' AND'||
                       ' codigo_ref= 1 AND reversado = ''N'' AND secuencia = (SELECT MAX(secuencia) FROM bdicred:sd_movhis WHERE '||
                       ' empresa= ''001'' AND a.num_credito = num_credito AND codigo_fun= ''001'' AND codigo_ref= 1 AND reversado = ''N'''||
                       ' and fecha_mov > date(0))),"0000"), nvl((select numerociudad from bdinteg:si_direcciones where a.numcte = numcte'||
                       ' and tipo_dir = ''1'' and secuencia = (select max(secuencia) from bdinteg:si_direcciones where a.numcte = numcte'||
                       ' and tipo_dir = ''1'' )),0), nvl(b.sdo_capital+b.monto_vencido+b.mto_venc_trasp+b.cap_tras_no_venci,0),'||
                       ' nvl((SELECT max(fecha_mov) FROM bdicred:sd_movhis WHERE empresa = ''001'' and a.empresa = empresa AND'||
                       ' a.num_credito = num_credito AND codigo_fun = ''002'' AND codigo_ref  IN (30,40,41,42,37,38,39,50) AND'||
                       ' reversado = ''N'' and fecha_mov > date(0)),date(1)), monto_financiado, nvl(b.monto_vencido + b.mto_venc_trasp,0),'||
                       ' case when (a.status_cred in (''AA'',''E1'') and (b.monto_vencido + b.mto_venc_trasp) = 0) then 0 else  '||
					   ' nvl((select sum(interes_debe+iva_debe-interes_pagado-iva_pagado) from bdicred:sd_amortiza_credito '||
                       ' where empresa=a.empresa and num_credito=a.num_credito and capital_status IN (''2'',''6'',''7'')),0) end, '||
                       ' nvl((b.sdo_contab_mora+sdo_moratorio)*(SELECT sum(1 + iva) From bdinteg:si_sucursales WHERE a.sucursal = sucursal),0), a.fecha_apertura, b.monto_otorgado, nvl(a.tasa_interes,0),'||
                       ' nvl((select sdo_capital+monto_vencido+mto_venc_trasp+cap_tras_no_venci from bdicred:sd_maesdoshist '||
                       ' where empresa = ''001'' and a.empresa = empresa and a.num_credito = num_credito and '||
                       ' fecha = b.fecha - 1 units month),0), nvl(h.prox_fecha_pago,date(1)),'||
                       ' a.status_cred, '||
                       ' b.mto_fin_ven_trasp, '||
                       ' nvl((SELECT trim(valor)  FROM bdicred:sd_param WHERE cod_param= ''034''),"0"), '' '','||
                       ' (monto_financiado - monto_vencido - mto_venc_trasp) FROM bdicred:sd_maecred a, bdicred:sd_maesdoshist b,'||
                       ' bdicred:sd_tarjeta f, bdicred:sd_maecredanexo h WHERE a.empresa = ''001'' AND'||
                       ' a.status_cred in (''AA'',''BA'',''BT'',''E1'',''E2'',''E3'') AND a.empresa = b.empresa AND a.num_credito= b.num_credito'||
                       ' AND b.fecha ='''||cfechaconsulta||''' AND a.empresa = f.empresa AND a.num_credito= f.num_credito'||
                       ' AND a.empresa = h.empresa AND a.num_credito=h.num_credito AND b.sdo_cap_insoluto > 0  AND'||
                       ' f.tipo_tarjeta = ''T'' AND f.secuencia= (SELECT MAX(i.secuencia) FROM bdicred:sd_tarjeta i'||
                       ' WHERE i.empresa =  a.empresa AND i.num_credito=a.num_credito AND i.tipo_tarjeta = ''T'') ;'||
                       ' " > /resplogifx/archivoscartera/SaldosVencidosQuerys.sql';

              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/SaldosVencidosQuerys.sql';
              SYSTEM cSql;

              LET cSql = 'echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/SaldosVencidosCifrasControlRegistros.unl''' || ' DELIMITER ' || '''|'''  ||
                         ' SELECT count(*)::integer,sum(b.sdo_capital+b.monto_vencido+b.mto_venc_trasp+b.cap_tras_no_venci),'||
                         ' sum(b.monto_vencido + b.mto_venc_trasp),'''|| cfechaconsulta||''' FROM bdicred:sd_maecred a,'||
                         ' bdicred:sd_maesdoshist b, bdicred:sd_tarjeta f, bdicred:sd_maecredanexo h WHERE a.empresa = ''001'' AND'||
                         ' a.status_cred in (''AA'',''BA'',''BT'',''E1'',''E2'',''E3'') AND a.empresa = b.empresa AND a.num_credito= b.num_credito AND'||
                         ' b.fecha ='''|| cfechaconsulta||''' AND a.empresa = f.empresa AND a.num_credito= f.num_credito AND'||
                         ' a.empresa = h.empresa AND a.num_credito=h.num_credito AND b.sdo_cap_insoluto > 0  AND'||
                         ' f.tipo_tarjeta = ''T'' AND f.secuencia= (SELECT MAX(i.secuencia) FROM bdicred:sd_tarjeta i'||
                         ' WHERE i.empresa =  a.empresa AND i.num_credito=a.num_credito AND i.tipo_tarjeta = ''T'') ;'||
                         ' " > /resplogifx/archivoscartera/SaldosVencidosQuerysCifrasControl.sql';
              SYSTEM cSql;

              LET cSql = '';
              LET cSql = 'dbaccess bdicred /resplogifx/archivoscartera/SaldosVencidosQuerysCifrasControl.sql';
              SYSTEM cSql;
    END IF;

--    SET DEBUG FILE TO "gensdosvdos17012008.out";
--   TRACE ON;

            LET  cNombreArchivo1= '/resplogifx/archivoscartera/SaldosVencidos' || cfechaarchivo || '.txt';
            LET  cNombreArchivo2= '/resplogifx/archivoscartera/SaldosVencidosCifrasControl' ||cfechaarchivo || '.txt';

              LET cSql = '';
              LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/SaldosVencidosRegistros.unl > " || cNombreArchivo1;
              SYSTEM cSql;

              LET cSql = '';

              LET cSql = '';
              LET cSql = "sed 's/|$//g' /resplogifx/archivoscartera/SaldosVencidosCifrasControlRegistros.unl > " || cNombreArchivo2;
              SYSTEM cSql;


--               LET cSql = '';
--               LET cSql = "scp " || trim(cNombreArchivo2) || ".gz" || " sysbancartera@10.36.193.35:/sysx/progs/archivoscartera";
--               SYSTEM cSql;

              LET cSql = '';
              LET cSql = "gzip -9 " || cNombreArchivo1;
              SYSTEM cSql;
 
 --              LET cSql = '';
 --              LET cSql = "scp " || trim(cNombreArchivo1) || ".gz" || " sysbancartera@10.36.193.35:/sysx/progs/archivoscartera";
 --              SYSTEM cSql;

               LET cSql = '';
               LET cSql = "rm /resplogifx/archivoscartera/SaldosVencidosRegistros.unl /resplogifx/archivoscartera/SaldosVencidosQuerys.sql";
               SYSTEM cSql;
               LET cSql = '';
               LET cSql = "rm /resplogifx/archivoscartera/SaldosVencidosCifrasControlRegistros.unl /resplogifx/archivoscartera/SaldosVencidosQuerysCifrasControl.sql";
               SYSTEM cSql;
   
               LET cNombreArchivo1 = "";
               LET cNombreArchivo2 = "";
               LET cSql = '';

RETURN vcodret;

END
END PROCEDURE document "Version 1.00.000";

CREATE PROCEDURE "informix".sp_indicador_max_fecha_monto()  
       returning CHAR(5) ,CHAR(100),CHAR(60);
   
--declaracion de variables
------------------------------------------------------------
DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info		CHAR(150);
DEFINE	cMensaje		CHAR(80);
DEFINE	cCod_ret		CHAR(6);
DEFINE  vlCredito		CHAR(20);
DEFINE	pEmpresa		CHAR(3);
------------------------------------------------
------------------------------------------------
DEFINE  vNumCredito		CHAR(12);
DEFINE  vMto			DECIMAL(16,2);
DEFINE	vFechapagoMax	DATE;
DEFINE  contador_commit	INTEGER;
DEFINE  cMensajeExt		CHAR(200);

-----------------------------------------------

    LET cCod_ret      = '00000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET vlCredito = '';
	LET cMensaje      = 'ACTUALIZACION DE ULTIMA FECHA DE PAGO Y MONTO, EXITOSO';	
	
	let pEmpresa 		= '001';
	LET vNumCredito 	= '';
	LET vMto			= 0;
	LET vFechapagoMax	= DATE(0);
	LET contador_commit = 0;
	LET cMensajeExt 	= '';

BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
			-- UPDATE bdicred:sd_indicador_cred (mensaje) values  (error_info);		
            -- RETURN cCod_ret;
			RETURN cCod_ret,vlCredito,cMensaje;
        END EXCEPTION;		
		
		--SET DEBUG FILE TO '/RESPALDOS/INFOSAT/ALDO/warning.out';
		--TRACE ON;
		
        SET ISOLATION TO DIRTY READ;
        SET LOCK MODE TO WAIT 3;

		select a.num_credito num_credito,max(fecha_mov) max_fec_mov
		from bdicred:sd_maecred a inner join bdicred:sd_movhis b
		on (a.num_credito = b.num_credito and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
					 and codigo_ref = 1  
					 and reversado = 'N' )    
		where a.num_producto = '7800'
		and a.status_cred IN ('AA','BA','BT','E1','E2','E3')                
		group by 1 
		into temp actu_monto with no log;

			FOREACH WITH HOLD
				select num_credito,max_fec_mov INTO vNumCredito,vFechapagoMax
				from actu_monto
				 
				select monto into vMto
				from bdicred:sd_movhis
				where fecha_mov=vFechapagoMax
				 and secuencia = (SELECT max(secuencia) from bdicred:sd_movhis
									where num_credito=vNumCredito
									and fecha_mov=vFechapagoMax 
									and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
									and codigo_ref = 1  
									and reversado = 'N'
									and empresa = '001')
				 and num_credito=vNumCredito
				 and codigo_fun in (select cod_fun from bdicred:sd_conceptospagomanual)
				 and codigo_ref = 1  
				 and reversado = 'N'
				 and empresa = pEmpresa;
				 
					BEGIN WORK;
					  
						update bdicred:sd_indicador_cred set fecha_ultimo_pago=vFechapagoMax,
						monto_ultimo_pago=vMto
						WHERE empresa = pEmpresa
						 and num_credito = vNumCredito;

						update bdicred:sd_maecredanexo set fecha_ult_pago=vFechapagoMax
						WHERE empresa = pEmpresa
						 and num_credito = vNumCredito; 
						
						LET contador_commit = contador_commit  + 1;
					COMMIT WORK;  
			
			END FOREACH; 

	
	LET cMensajeExt= 'TOTAL DE CUENTAS ACTUALIZADAS: '||contador_commit;	
		
    RETURN cCod_ret,cMensaje,cMensajeExt;
    END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Se actualiza el ultimo monto y fecha de pago de los indicadores de producto 7800',
'AUTOR : Aldo Edgar',
'FECHA : 2019/08/22';

CREATE PROCEDURE "informix".sp_pp_sdofinmes_riesgos(pEmpresa CHAR(3))
RETURNING CHAR(6) AS CodigoRetorno,
		CHAR(80) AS Mensaje;

--Declaracion de variables
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE pMensaje				CHAR(80);
DEFINE pCod_ret				CHAR(6);
DEFINE cErrorInfo			CHAR(80);
DEFINE pempresa				CHAR(3);
DEFINE pproceso				CHAR(30);
DEFINE pusuario				CHAR(8);
DEFINE cruta				CHAR(100);
DEFINE cnombre				CHAR(100);
DEFINE ntrimestre 			CHAR(30);
DEFINE cnomarchivo			CHAR(100);
DEFINE cnomarchivo1			CHAR(100);
DEFINE cnumcte				CHAR(20);
DEFINE cnumcred				CHAR(20);
DEFINE cSucursal			CHAR(4);
DEFINE cSQL					CHAR(8500);
DEFINE cSQL1				CHAR(7000);
DEFINE cSQL2				CHAR(6204);
DEFINE cSQL3				CHAR(100);
DEFINE cCod_RetIB			CHAR(6);
DEFINE dFechaHoy			DATE;
DEFINE dFecha				DATE;
DEFINE sPaso				smallint;


--Inicialización de variables
LET sql_err					= 0;
LET isam_err				= 0;
LET error_info				= "";
LET pCod_Ret				= "000000";
LET pMensaje				= 'PROCESO EXITOSO';
LET pproceso				= '2118';
LET pempresa				= '001';
LET pusuario				= USER;
LET cruta					= "";
LET cnombre					= "";
LET ntrimestre 				= "";
LET cnomarchivo				= "";
LET cnomarchivo1			= "";
LET cnumcte					= "";
LET cnumcred				= "";
LET cSucursal				= "";
LET cSQL					= "";
LET cSQL1					= "";
LET cSQL2					= "";
LET cSQL3					= "";
LET cCod_RetIB				= "000000";
LET dFechaHoy				= DATE(1);
LET dFecha					= DATE(1);
LET sPaso					=0;

BEGIN

	ON EXCEPTION SET sql_err, isam_err, error_info
	LET pCod_ret = sql_err;
	LET pMensaje = error_info;
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '02')
	Returning cCod_RetIB;
		RETURN pCod_ret,pMensaje;
	END EXCEPTION;

--SET DEBUG FILE TO "sp_pp_gensdo_finmes_riesgos.out";
--TRACE ON;	
	--Directiva para lectura de tablas bloqueadas.
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;
	
	CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '01')
	Returning cCod_RetIB;
	
	select fecha_hoy,pri_dia_mes - 1 units day 
	into dFechaHoy,dFecha
	from bdicred:"informix".sd_fechas;
	

	select first 1 trim(valor_alfabetico) 
	into cRuta 
	from bdicred:"informix".sd_param_campania 
	where empresa = '001' and tipo_campania = 50  and grupo_parametro = 'CAT_PROMOS'
	and num_parametro = 2;
	
	 
	--Genera archivo
	LET cnomarchivo1 = 'saldos_PrestamosPersonales'||'.unl';
	LET cnomarchivo =  'saldos_PrestamosPersonales_'||to_char( dFecha,'%m%Y')||'.txt';
	--Encabezado
	let cSql='';
	let csql = ' echo "Solicitud;Cliente;Ctecoppel; Filtro;Status;PagoVencido;MontoOtorgado;'
	||'SdoCierre;CapitalVigente;CapitalTransitorio;IntVigente;CapitalVencidoexigible;CapitalVencidonoexigible;'
	||'IntVencidoBalance;FechaApertura;PeriodoReporte;SituacionPago;MesesHistoria;Sucursal;NumCiudad;'
	||'NombreCiudad;Score1;Score2;Scoring;Cuota;Plazo;MontoTotalPago;CampoBaja; " >' ||TRIM(cruta)|| cnomarchivo;
	system csql;
	--LET cSQL2 = ' select * from sd_gen_pp';
	LET cSQL1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO ' || TRIM(cruta) || TRIM(cnomarchivo1) || ' DELIMITER ' || ''';'''||'' ||--;	
	            ' select a.num_credito, a.numcte,  '  ||
			' (select numcte_ref from bdinteg:si_cliente cte where cte.numcte = a.numcte) ClienteCoppel,'||
			' decode (nvl(evalua_cc,''''), '''',''NO HIT'', ''X'',''NO HIT'', ''HIT'') Filtro,'||
			' a.status_cred, b.mto_fin_ven_trasp, b.monto_otorgado, '||
			' (b.sdo_capital + b.monto_vencido + '||
			' b.mto_venc_trasp + b.cap_tras_no_venci  + '||
			' (case  when  a.status_cred IN (''BT'',''E2'',''E3'') then int_venc_bal'|| day(dFecha)||
			' else sdo_no_exig+ provision_normal '||
			' end )) Saldo_Cierre, '||
			' b.sdo_capital Capita_Vigente, b.monto_vencido Capital_transitorio, '||
			' (sdo_no_exig+ provision_normal) Interes_Vigente_balanza,' ||
			' b.mto_venc_trasp Capital_VencidoExigible,	'||
			' b.cap_tras_no_venci  Capital_VencidNOExigible,'|| 
			' int_venc_bal'|| day(dFecha)||' Interes_vencido_balanza,'||
			' a.fecha_apertura, to_char(a.fecha, ''%m%Y'') , ' ||
			' scor.situacion_pago , meses_historia ,	a.sucursal ,  dir.numerociudad, '  ||
			' (select  ciu.nombreciudad  from bdinteg:si_catciudades ciu where ciu.numerociudad = dir.numerociudad) nombreciudad,'||
			' (select evaluacion from bdisolic:ss_resumen_scoring res where res.num_solicitud = a.num_credito  and seccion = 1 )score1,'||
			' (select evaluacion from bdisolic:ss_resumen_scoring res where res.num_solicitud = a.num_credito  and seccion = 2 )score2,'||
			' (select evaluacion from bdisolic:ss_resumen_scoring res where res.num_solicitud = a.num_credito  and seccion = 2 )scoring,'||
			' ( select  am.capital_mto_cuota  from bdicred:sd_amortiza_creditocrd am where am.num_credito = a.num_credito '||
			' and am.fecha_cuota = (select max(ac.fecha_cuota) from  bdicred:sd_amortiza_creditocrd ac where ac.num_credito = am.num_credito and ac.capital_status <>3 )) '||
			' PagoMinimo,'  ||
			' crd.plazo, ' || --edo.monto_pago '|| -- monto_tot_pagar
			' capvig'||day(dFecha)  ||' + captrans'||day(dFecha) ||' +capvencnoexig'||day(dFecha) ||' + capvenexig'||day(dFecha) ||
			' + intvig'||day(dFecha) || '+ intvenc'||day(dFecha) ||' +ivaintvig'||day(dFecha) || '+ ivaintvenc'||day(dFecha) ||
			' + int_venc_bal'||day(dFecha) || ' + ivaint_venc_bal'||day(dFecha) || ', a.campo_trab3' ||
	' from bdicred:sd_maecredcontcrd a ' ||
	' join bdicred:sd_maesdoscontcrd b on (a.empresa = b.empresa and a.num_credito = b.num_credito and a.fecha = b.fecha) '||
	' join bdisolic:ss_resum_scor_fin scor on ( a.empresa = scor.empresa and a.num_credito = scor.num_solicitud  ) '||	
	' join bdicred:sd_maecredcrd crd on ( a.empresa = crd.empresa and a.num_credito = crd.num_credito  ) '||
	' join bdisolic:ss_solicitudes ss on ( a.empresa = ss.empresa and a.num_credito = ss.num_solicitud ) '||
	' join bdicred:sd_sdodiariocrd c on (c.fecha =mdy( month('''||dFecha||'''), ''01'', year('''||dFecha||''')) and c.num_credito =a.num_credito) '||
	' left outer join bdinteg:si_direcciones_actual dir on ( a.numcte = dir.numcte and dir.tipo_dir = 1  ) '||	
	' where a.empresa = ''001'' '||
	' and a.num_producto in (select num_producto from bdicred:sd_definicion where empresa = ''001'' and cod_tipcred = ''05'' and flag_arbol = ''1'') '||
	' and a.fecha = mdy( month('''||dFecha||'''),day('''||dFecha||''') , year('''||dFecha||''')) ';
	
	--to_char('''|| dFecha || ''',''%m-%d-%Y'')' ; 
	
	LET cSQL3 = '">'||TRIM(cruta)||'exsdospp.sql';
	LET cSQL = trim(cSQL1) || trim(cSQL3);  ---|| cSQL2 || trim(cSQL3);
	System cSQL;
	LET cSQL='chmod 777 '|| TRIM(cruta)||'exsdospp.sql';
	System cSQL;
	LET cSQL = 'dbaccess bdicred ' || TRIM(cruta) || 'exsdospp.sql';
	System cSQL;
	LET cSql = cSql; 
	LET cSql = "sed 's/;$//g' "|| TRIM(cruta) || TRIM(cnomarchivo1) || " >> " || TRIM(cruta) || TRIM(cnomarchivo);
	SYSTEM cSql;
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || 'exsdospp.sql';
	SYSTEM cSQL;
	LET cSQL = '' ;
	LET cSQL = 'rm ' || TRIM(cruta) || cnomarchivo1;
	SYSTEM cSQL;
	

	  CALL bdicred:"informix".sp_inserta_bitacora(pempresa, pproceso, pCod_ret, pMensaje, '03')
		Returning cCod_RetIB;

	RETURN pCod_ret,pMensaje;

END
END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para generar archivo mensual de prestamos personales',
'AUTOR : Guadalupe de Jesus Espinoza Valenzuela ',
'FECHA : 14/Octubre/2013',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_renueva_grupoa (pc_Empresa CHAR(3), p_producto CHAR(4), p_diacort_prod SMALLINT, p_FechaRenov DATE)
    RETURNING CHAR(5)  AS Codigo_retorno,
              CHAR(80) AS Mensaje,
              CHAR(25) AS StorePro;

DEFINE vsqlerr          INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);

DEFINE v_codigo_retorno	CHAR(5);
DEFINE v_mensaje	  	CHAR(80);
DEFINE v_store_pro      CHAR(25);

DEFINE dtFechaHoy       DATE;
DEFINE dtFechaProx      DATE;
DEFINE dtFechaFinMes    DATE;

DEFINE vc_crdcontproc 	CHAR(1);
DEFINE vc_intcontproc 	CHAR(1);

DEFINE vc_numproducto   CHAR (4);
DEFINE vc_numcredito    CHAR(20);
DEFINE vc_numcte        CHAR(20);
DEFINE vc_statuscred        CHAR(2);
DEFINE vd_motorgado         DECIMAL(18,2);
DEFINE vd_cap_insoluto      DECIMAL(18,2);
DEFINE vi_porcent_usoHist   DECIMAL(18,2);
DEFINE vi_porcentaje_usoUM  DECIMAL(18,2);
DEFINE vd_capital_insol     DECIMAL(18,2);
DEFINE vd_mto_fin_ven_trasp DECIMAL(18,2);
--DEFINE vf_ult_fecha_fac     DATE;
DEFINE vc_tipproceso        CHAR(20);
DEFINE vf_fechapertu        DATE;
DEFINE vi_meses_antigdad    INTEGER;

DEFINE vi_meses_vigts       INTEGER;
DEFINE vd_usolinea_min      DECIMAL(5,2);
DEFINE vd_usolinea_max      DECIMAL(5,2);
DEFINE vcontador            SMALLINT;
DEFINE vc_meses_sinusolin   SMALLINT;
DEFINE vi_Bandera           SMALLINT;
DEFINE dtFechaCortePrev     DATE;
DEFINE dtFechaHoy_aux       DATE; 
DEFINE vf_vig_fecha_fac     DATE;

LET vc_numproducto    ='';
LET vc_numcredito     ='';
LET vc_numcte         ='';
LET vc_statuscred     ='';
LET vd_motorgado      = 0;
LET vd_cap_insoluto   = 0;
LET vi_porcent_usoHist = 0;
LET vi_porcentaje_usoUM  =0;
LET vd_capital_insol  = 0;
LET vd_mto_fin_ven_trasp = 0;
--LET vf_ult_fecha_fac  = DATE(1);
LET vc_tipproceso     = '';
LET vf_fechapertu     = DATE(1);
LET dtFechaCortePrev  = DATE(1);
LET dtFechaHoy_aux    = DATE(1);
LET vf_vig_fecha_fac  = DATE(1);
LET vi_meses_antigdad = 0;
LET vc_meses_sinusolin =0;

LET vi_meses_vigts  = 0;
LET vd_usolinea_min = 0;
LET vd_usolinea_max = 0;
LET vcontador       = 0;
LET vc_crdcontproc 	= '';
LET vc_intcontproc 	= '';

LET v_codigo_retorno = "00000";
LET v_mensaje        = "Proceso Inicia Correctamente";
LET v_store_pro      = 'sp_renueva_grupoa';
LET vc_tipproceso    = 'RenuevaGpoA_' || p_producto;
LET vi_Bandera       = 0;

--SET DEBUG FILE TO "/tmp/sp_renueva_grupoa.out";
--TRACE ON;

    SET ISOLATION TO dirty READ;
    SET LOCK MODE TO wait 3;

BEGIN
    ON EXCEPTION SET vsqlerr,iIsamErr,cErrorInfo 
        IF vsqlerr <> 0 THEN
            LET v_codigo_retorno = vsqlerr;			
            LET v_mensaje = cErrorInfo;
            LET v_store_pro = 'sp_renueva_grupoa';
            RETURN v_codigo_retorno, v_mensaje, v_store_pro;
        END IF;
    END EXCEPTION;

    --*********************************************************--
	-- Creado por: Francisco Martinez Viveros --Fecha Creacion: 25/JULIO/2012 / Fecha Modifica: 16/OCTUBRE/2012
	--Objetivo: Valida Clientes que son candidatos al Grupo A, por tener buen comportamiento de Credito
	--*********************************************************--

    SELECT a.fecha_hoy, a.prox_fecha, a.ult_dia_mes
      INTO dtFechaHoy, dtFechaProx, dtFechaFinMes
      FROM "informix".sd_fechas a
     WHERE a.empresa = pc_Empresa;

    SELECT valor::integer
      INTO vi_meses_vigts
      FROM "informix".sd_param
     WHERE empresa = pc_Empresa
       AND cod_param = '55';
    IF vi_meses_vigts IS NULL THEN
        LET v_codigo_retorno = "00040";
        LET v_mensaje="Falta parametro para el calculo de meses vigentes";
        LET v_store_pro = 'sp_renueva_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT valor::decimal(5,2)
      INTO vd_usolinea_min
      FROM "informix".sd_param
     WHERE empresa = pc_Empresa
       AND cod_param = '56';
    IF vd_usolinea_min IS NULL THEN
        LET v_codigo_retorno = "00041";
        LET v_mensaje="Falta parametro del porcentaje minimo uso de linea";
        LET v_store_pro = 'sp_renueva_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT valor::decimal(5,2)
      INTO vd_usolinea_max
      FROM "informix".sd_param
     WHERE empresa = pc_Empresa
       AND cod_param = '57';
    IF vd_usolinea_min IS NULL THEN
        LET v_codigo_retorno = "00042";
        LET v_mensaje="Falta parametro del porcentaje maximo uso de linea";
        LET v_store_pro = 'sp_renueva_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT status_proc INTO vc_intcontproc FROM bdinteg:sx_contproc 
     WHERE empresa = pc_Empresa AND fecha = dtFechaHoy AND proceso = vc_tipproceso;
    IF (vc_intcontproc='F') THEN
        LET v_codigo_retorno = "00031";
        LET v_mensaje="PROCESO DE GRUPOA, YA EJECUTADO ANTERIORMENTE";
        LET v_store_pro = 'sp_renueva_grupoa';
        RETURN v_codigo_retorno, v_mensaje,  v_store_pro;
    END IF;

    SELECT status_proc INTO vc_crdcontproc FROM bdicred:sd_contproc
     WHERE empresa = pc_Empresa AND fecha = dtFechaHoy AND proceso = vc_tipproceso;
    IF vc_intcontproc IS NULL THEN
        INSERT INTO bdinteg:sx_contproc(empresa,proceso,fecha,sistema,status_proc,ejecutivo,hora_ini,hora_fin,codret) 
             VALUES (pc_Empresa,vc_tipproceso,dtFechaHoy,'06','I','informix',CURRENT,CURRENT,'000');
    END IF;
    IF vc_crdcontproc IS NULL THEN
        INSERT INTO bdicred:sd_contproc(empresa,proceso,fecha,status_proc,ejecutivo,hora_inicio,hora_fin,cod_ret,mensaje)
             VALUES (pc_Empresa,vc_tipproceso,dtFechaHoy,'I','informix',CURRENT,CURRENT,'000','Renueva GrupoA');
    END IF;

    IF vc_intcontproc = 'I' OR vc_crdcontproc = 'I' THEN
        UPDATE bdinteg:sx_contproc SET status_proc = 'I', hora_ini = CURRENT WHERE empresa = pc_Empresa AND fecha = dtFechaHoy AND proceso = vc_tipproceso;
        UPDATE bdicred:sd_contproc SET status_proc = 'I', hora_inicio = CURRENT, mensaje = 'Iniciamos grupoA'
         WHERE empresa = pc_Empresa AND fecha = dtFechaHoy AND proceso = vc_tipproceso;
    END IF;

    -- Establece la fecha de corte la el producto correspondiente.
    LET dtFechaHoy_aux = monthadd(dtFechaHoy,- 1);

    IF DAY(p_FechaRenov) <= p_diacort_prod THEN
        LET dtFechaCortePrev = mdy(month(dtFechaHoy_aux),p_diacort_prod, year(dtFechaHoy_aux));  -- Fecha corte de mes anterior
    ELSE
        LET dtFechaCortePrev = mdy(month(p_FechaRenov), p_diacort_prod, year(p_FechaRenov));
    END IF;

    LET vf_vig_fecha_fac = monthadd(p_FechaRenov,- vi_meses_vigts);   --Mses vigentes y los porcentajes de uso de linea en grupo A

    -- Actualiza información de creditos activos.
    FOREACH WITH HOLD
        SELECT c.num_producto, c.num_credito, c.numcte, nvl(c.meses_sinusolin,0), crd.status_cred
          INTO vc_numproducto, vc_numcredito, vc_numcte, vc_meses_sinusolin, vc_statuscred
          FROM bdicred:"informix".sd_grupo_credito c JOIN bdicred:sd_maecred crd
            ON (c.empresa = crd.empresa and c.numcte = crd.numcte and c.num_credito = crd.num_credito and c.num_producto = crd.num_producto)
         WHERE c.empresa = pc_Empresa
           AND c.num_producto = p_producto
           AND c.fecha_status < p_FechaRenov
           AND crd.status_cred IN ('AA','BA','BT','E1','E2','E3')
           --AND c.num_credito = p_credito

        LET vi_Bandera = 0;

        SELECT count(*) INTO vi_porcent_usoHist -- Al menos uno de los meses previos tuvo 80% de utilizacion
          FROM bdicred:sd_maesdoshist    
         WHERE fecha >= vf_vig_fecha_fac AND fecha <= dtFechaCortePrev AND empresa = pc_Empresa AND num_credito = vc_numcredito
           AND ((sdo_cap_insoluto * 100) / monto_otorgado ) >= vd_usolinea_min
           AND monto_otorgado > 0;

        SELECT NVL(SUM(mto_fin_ven_trasp),0) INTO vd_mto_fin_ven_trasp  -- Consulta historico de meses de atraso, debe ser = 0
          FROM bdicred:"informix".sd_maesdoshist 
         WHERE fecha >= vf_vig_fecha_fac AND fecha <= dtFechaCortePrev AND empresa = pc_Empresa AND num_credito = vc_numcredito;
        IF vd_mto_fin_ven_trasp > 0 THEN
            lET vc_statuscred = 'BT';  -- Si un credito tuvo meses vencidos previos, pero no el actual, se marca como BT, para que salga del gpo A
        END IF;

        --IF (vi_porcentaje_usoUM > vd_usolinea_max) AND ( vd_mto_fin_ven_trasp <=0) THEN
        /*IF (vi_porcentaje_usoUM > vd_usolinea_max) THEN
            LET vc_statuscred     = 'SG'; -- Sobregiro de la linea Autorizada
            LET vi_meses_antigdad = 0;
            UPDATE bdicred:sd_grupo_credito
               SET fecha_status = p_FechaRenov,
                   status_cred  = vc_statuscred
             WHERE empresa = pc_Empresa
               AND numcte  = vc_numcte
               AND num_credito = vc_numcredito;
            LET vi_Bandera = 1;
        --END IF;    --vi_porcentaje_usoUM > vd_usolinea_max

        ELIF (vi_porcentaje_usoUM < vd_usolinea_min) AND (vc_meses_sinusolin < vi_meses_vigts ) AND ( vd_mto_fin_ven_trasp <=0)  THEN  -- ????  vc_meses_sinusolin??
            IF vc_meses_sinusolin + 1 = vi_meses_vigts  THEN
                --LET vc_statuscred     = 'ML'; -- Un mes de Facturacion sin 80% Uso Linea
                LET vi_meses_antigdad = 0;
            END IF;
            UPDATE bdicred:sd_grupo_credito
               SET fecha_status = p_FechaRenov,
                   status_cred  = vc_statuscred,
                   meses_sinusolin =nvl(meses_sinusolin,0) + 1
             WHERE empresa = pc_Empresa
               AND numcte  = vc_numcte
               AND num_credito = vc_numcredito;
            LET vi_Bandera = 1;
        --END IF;    --vi_porcentaje_usoUM < vd_usolinea_min */

        IF (vi_porcent_usoHist <= 0 OR vd_mto_fin_ven_trasp >= 1)  THEN     -- Si en los ultimos 6 meses tuvo vencidos o no uso minimo un mes el 80%
        --IF (vd_mto_fin_ven_trasp > 0 ) THEN

            IF vi_porcent_usoHist <= 0 THEN
                LET vc_statuscred     = 'ML'; -- Un mes de Facturacion sin 80% Uso Linea
                LET vi_meses_antigdad = 0;
            END IF;
            IF vd_mto_fin_ven_trasp >= 1 THEN     
                LET vc_statuscred     = 'BT';   -- Si un credito esta en AA, pero tuvo meses vencidos previos, se marca como BT, para que salga del gpo A          
                LET vi_meses_antigdad = 0;
            END IF;

            UPDATE bdicred:sd_grupo_credito
               SET fecha_status = p_FechaRenov,
                   status_cred  = vc_statuscred,
                   num_historia_efic = vi_meses_antigdad
             WHERE empresa = pc_Empresa
               AND numcte  = vc_numcte
               AND num_credito = vc_numcredito;
            LET vi_Bandera = 1;
        --END IF;  --  IF vd_mto_fin_ven_trasp > 0

        --ELIF vi_Bandera = 0 THEN  
        ELSE                        -- Si no cumplio condiciones, actualiza datos y que el proceso de integra lo analice y lo elimine del gpo si es necesario. 
            UPDATE bdicred:sd_grupo_credito
               SET fecha_status = p_FechaRenov,
                   status_cred  = vc_statuscred,
                   num_historia_efic = num_historia_efic + 1,
                   meses_sinusolin = vi_porcent_usoHist
             WHERE empresa = pc_Empresa
               AND numcte  = vc_numcte
               AND num_credito = vc_numcredito;
        END IF;

    END FOREACH;

    -- Actualiza informacion de creditos que no se encuentran activos
    FOREACH WITH HOLD
        SELECT c.num_producto, c.num_credito, c.numcte, nvl(c.meses_sinusolin,0), crd.status_cred
          INTO vc_numproducto, vc_numcredito, vc_numcte, vc_meses_sinusolin, vc_statuscred
          FROM bdicred:"informix".sd_grupo_credito c JOIN bdicred:sd_maecred crd
            ON (c.empresa = crd.empresa and c.numcte = crd.numcte and c.num_credito = crd.num_credito and c.num_producto = crd.num_producto)
         WHERE c.empresa = pc_Empresa
           AND c.num_producto = p_producto
           AND c.fecha_status < p_FechaRenov
           AND crd.status_cred NOT IN ('AA','BA','BT','E1','E2','E3')


        LET vi_meses_antigdad = 0;

        UPDATE bdicred:sd_grupo_credito
           SET fecha_status = p_FechaRenov,
               status_cred  = vc_statuscred,
               num_historia_efic = vi_meses_antigdad
         WHERE empresa = pc_Empresa
           AND numcte  = vc_numcte
           AND num_credito = vc_numcredito;

    END FOREACH;


    IF v_codigo_retorno = "00000" THEN
        -- LET v_codigo_retorno = "00000";
        LET v_mensaje        = 'Renovacion grupoA Tarjeta, Termino Correctamente';

        UPDATE bdinteg:sx_contproc
           SET status_proc = 'F',
               hora_fin = CURRENT
         WHERE empresa = pc_Empresa
           AND fecha   = dtFechaHoy 
           AND proceso = vc_tipproceso;

        UPDATE bdicred:sd_contproc
           SET status_proc = 'F',
               hora_fin = CURRENT,
               mensaje = v_mensaje			       
         WHERE empresa = pc_Empresa
           AND proceso = vc_tipproceso
           AND fecha = dtFechaHoy;        
              
    END IF; -- IF v_codigo_retorno = "00000"

    RETURN v_codigo_retorno, v_mensaje, v_store_pro;

END;   --begin
END PROCEDURE;