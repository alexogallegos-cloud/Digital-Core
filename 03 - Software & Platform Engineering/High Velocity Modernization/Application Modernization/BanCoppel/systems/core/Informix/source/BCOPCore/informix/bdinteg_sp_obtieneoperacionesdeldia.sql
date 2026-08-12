CREATE PROCEDURE "informix".sp_obtieneoperacionesdeldia( p_sUsuario CHAR(20), p_dFecha date, pDesde INTEGER, pHasta INTEGER )
    RETURNING CHAR(6), CHAR(10), CHAR(50), CHAR(12), CHAR(18), CHAR(16), CHAR(10), CHAR(40);

--Declaracion de variables

DEFINE v_sCodRet CHAR(6);
DEFINE v_sMensajeRet CHAR(60);
DEFINE intcodret INTEGER;

DEFINE v_sFecha CHAR(10);
DEFINE v_sTransaccion CHAR(50);
DEFINE v_sOrigen CHAR(12);
DEFINE v_sDestino CHAR(18);
DEFINE v_sImporte CHAR(16);
DEFINE v_sFAplicacion CHAR(10);
DEFINE v_sFolio CHAR(40);

-- *************************************************
-- Realizo: Walber Castro                    
-- Actividad: Obtener las operaciones del dÃ­a 
-- Solicito: Diana Castellanos                
--Fecha: 29/JUNIO/2010                                                      
-- 
-- Realizo: JosÃ© de JesÃºs Nevarez             
-- Modificacion: Se agrega id_operacion 1022 DISH y 1023 MASTV para que se incluya dentro de las operaciones a consultar--*
-- Solicito: Mauricio LeÃ³n                    
--Fecha: 3/SEPTIEMBRE/2010                        
--
-- Realizo: ING. ALFONSO CRUZ
-- Modificacion: Se cambia el campo de cosnsulta de folio de la operaciÃ³n
-- Solicito: WALBERTO CASTRO
-- Fecha: 15/07/2013
--
-- Se cambia la tabla de bitÃ¡cora y se agregan las operaciones de Pago TDC terceros BanCoppel
-- Bibiana Gaxiola
-- 29/11/2013
--
--Realizo: Roberto Castro
--Modificacion: Se agrega id_operacion 1033 para que se incluya pago de servicio avon en las operaciones del dia.
--Solicito: Bibiana Gaxiola
--Fecha: 16/06/2014
--
--Realizo: Jose Ruben Lopez
--Modificacion: Se agrega id_operacion 1034 para que se incluya las ordenes de pago en las operaciones del dia.
--Solicito: Jose de Jesus Nevarez
--Fecha: 15/01/2015
--

--Realizo: RenÃ© Aldana
--Modificacion: Se agrega id_operacion 1050 para que se incluya las transferencias a cuentas transfer en las operaciones del dia.
--Solicito: Alejandro Vazquez
--Fecha: 18/01/2017
--*******************************************

--Asignacion de variables
LET v_sFecha = '';
LET v_sTransaccion = '';
LET v_sOrigen = '';
LET v_sDestino = '';
LET v_sImporte = '';
LET v_sFAplicacion = '';
LET v_sFolio = '';
LET v_sCodRet = '000';

--SET DEBUG FILE TO "/home/informix/bibiana/sp_obtieneoperacionesdeldia.out";
--TRACE ON;   

BEGIN
        ON EXCEPTION SET intcodret
            IF intcodret <> 0 THEN
                LET v_sCodRet  = intcodret;
                RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio ;
            END IF;
        END EXCEPTION;
	
	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
	--Se valida que la cuenta no este en blanco o en nulo

	IF (NVL(p_sUsuario,'') = '') THEN
		SELECT cod_ret,desc_mensaje INTO v_sCodRet, v_sMensajeRet FROM bdiprog:"informix".pp_mensajes 
		where cve_mensaje = '147';
		RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio ;
	END IF;		

        FOREACH SELECT SKIP pDesde FIRST pHasta  DATE(fecha_oper), NVL(desc_oper,''), NVL(cuenta_origen,''), NVL(destino,''), NVL(monto_oper,'0.00'), DATE(fecha_aplic), NVL(folio,'')
                INTO v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio
                FROM bdibpi:"informix".bpi_bitacora a, bdibpi:"informix".bpi_cat_operaciones b
                WHERE DATE(fecha_oper) = DATE(p_dFecha)
                AND a.id_operacion = b.id_oper AND id_usuario = p_sUsuario
				AND id_operacion IN ('1006',
				'1007',
				'1008',
				'1011',
				'1015',
				'1016',
				'1017',
				'1020',
				'1021',
				'1022',
				'1023',
				'1024',
				'1025',
				'1026',
				'1027',
				'1030',
				'1031',
				'1033',
				'2011',
				'2015',
				'2017',
				'2020',
				'2021',
				'2022',
				'2023',
				'2027',
				'1034',
				'1050',
				'1041',
				'1070')
                ORDER BY fecha_oper

                RETURN v_sCodRet, v_sFecha, v_sTransaccion, v_sOrigen, v_sDestino, v_sImporte, v_sFAplicacion, v_sFolio WITH RESUME;     
        
        END FOREACH;        
END
END PROCEDURE
DOCUMENT
'FOLIO.........: 1597 - EdoMovimientos',
'AUTOR.........: Edgar Alarcon',
'FECHA.........: 15-09-2015',
'MODIFICACIÃ?N..: Se cambia tamaÃ±o del quinto parametro del retorno de 12 a 18 caracteres',
'SOLICITA......: Jesus Montoya',
'BD............: BDINTEG',
'FOLIO.........: 308 - HomologaciÃ³n de Servicios Coppel',
'AUTOR.........: Arturo Astorga',
'FECHA.........: 20-09-2017',
'MODIFICACIÃ?N..: Se agrega id_operacion 1041 para que se incluya pago de servicio CFE en las operaciones del dia.',
'SOLICITA......: Evelia Ontiveros Valenzuela',
'FECHA.........: 10-10-2019',
'MODIFICACIÃ¿N..: Se agrega id_operacion 1070 para que se incluya Timpo Aire en las operaciones del dia.',
'SOLICITA......: Gabriela Aguilar',
'BD............: BDINTEG';

CREATE PROCEDURE "informix".sp_alta_solicitud_movil_online(
pproductos         	CHAR(120),
pnumcte            	CHAR(20),
pap_nombre1        	CHAR(26),
pap_nombre2        	CHAR(26),
pap_apell_paterno  	CHAR(26),
pap_apell_materno  	CHAR(26),
pap_sexo           	CHAR(1),
pap_fecha_nac      	CHAR(10),
pap_rfc            	CHAR(13),
pemail             	CHAR(100),
ptelefono_casa     	CHAR(10),
ptelefono          	CHAR(10),
pcarrier           	CHAR(1),
ppais_nac          	CHAR(3),
pap_cod_postal     	CHAR(5),
pap_id_estado         	CHAR(2),
pap_id_ciudad         	CHAR(3),
pap_id_colonia        	CHAR(10),
pap_id_municipio      	CHAR(5),
pap_id_calle          	CHAR(40),
pnumero_exterior	CHAR(10),
pnumero_interior	CHAR(10),
pentre_calles		CHAR(40),
pcomplemento		CHAR(80),
ptarjeta_de_credito_activa	CHAR(1),
pultimos_cuatro_digitos	CHAR(4),
pcredito_hipotecario	CHAR(1),
pcredito_automotriz		CHAR(1),
pfirma_buro        	CHAR(1),
pescolaridad       	CHAR(2),
pestado_civil       CHAR(1),
ptpo_edo_civil     	CHAR(2),
pmeses_edo_civil   	CHAR(2),
ptipo_residencia   	CHAR(1),
ptiempo_domicilio  	CHAR(2),
ppers_domicilio    	CHAR(2),
ppers_trabajan     	CHAR(2),
ppers_dependen     	CHAR(2),
pempresa           	CHAR(60),
ptiempo_trabajo    	CHAR(2),
ptiempo_trab_ant   	CHAR(2),
pactividad         	CHAR(2),
psubactividad      	CHAR(2),
pnivel_ingresos    	CHAR(8),
ptel_trabajo       	CHAR(10),
pprimer_nombre_referencia	CHAR(26),
psegundo_nombre_referencia	CHAR(26),	
pprimer_apellido_referencia	CHAR(26),
psegundo_apellido_referencia	CHAR(26),
pfecha_de_nacimiento_referencia	DATE,
pgenero_referencia				CHAR(1),
pparentesco_referencia			CHAR(2),
ptelefono_celular_referencia	CHAR(13),
pejecutivo         	CHAR(8),
pnumero_control         	CHAR(25),
pfecha_hora        	DATETIME YEAR to FRACTION(5)
)

    RETURNING 
          CHAR(4)       as vcodret1,
		  CHAR(120)     as vmsjresp,
		  CHAR(2)       as vcodsolbcpl,
		  CHAR(40)      as vdescsolbcpl,
		  CHAR(255)     as vmotivobcpl,
		  CHAR(4)       as vproductobcpl,
		  CHAR(20)      as vfoliobcpl,
		  CHAR(2)       as vcodsolcpl,
		  CHAR(40)      as vdescsolcpl,
		  CHAR(255)     as vmotivocpl,
		  CHAR(4)       as vproductocpl,
		  CHAR(20)      as vfoliocpl;
         
    DEFINE vcodret1 CHAR(4);
	DEFINE vmsjresp CHAR(120);
	DEFINE vcodsolbcpl CHAR(2);
	DEFINE vdescsolbcpl CHAR(40);
	DEFINE vmotivobcpl CHAR(255);
	DEFINE vproductobcpl CHAR(4);
	DEFINE vfoliobcpl CHAR(20);
	DEFINE vcodsolcpl CHAR(2);
	DEFINE vdescsolcpl CHAR(40);
	DEFINE vmotivocpl CHAR(255);
	DEFINE vproductocpl CHAR(4);
	DEFINE vfoliocpl CHAR(20);
	
    DEFINE sql_err  INTEGER;
    DEFINE isam_err INTEGER;
    DEFINE desc_err CHAR(50);
	
    LET vcodret1 = '0000';
	LET vmsjresp = 'Consulta exitosa';
	LET vcodsolbcpl = 'PA';
	LET vdescsolbcpl = 'Pre autorizada';
	LET vmotivobcpl = '';
	LET vproductobcpl = '6001';
	LET vfoliobcpl = '11111111';
	LET vcodsolcpl = 'PA';
	LET vdescsolcpl = 'Pre autorizada';
	LET vmotivocpl = '';
	LET vproductocpl = '6500';
	LET vfoliocpl = '55555555';
	
    LET sql_err	 = 0;
    LET isam_err = 0;
    LET desc_err = '';

    BEGIN
	
		ON EXCEPTION SET sql_err, isam_err, desc_err
			--SET DEBUG FILE TO "/informix/LIP/sp_alta_solicitud_movil_online.out";
			--TRACE ON;
			IF sql_err <> 0 THEN
				LET vcodret1 = sql_err;
				LET vmsjresp = isam_err;
				--LET vmsjresp = desc_err;
				RETURN vcodret1,vmsjresp,vcodsolbcpl,vdescsolbcpl,vmotivobcpl,vproductobcpl,vfoliobcpl,vcodsolcpl,vdescsolcpl,vmotivocpl,vproductocpl,vfoliocpl;
			END IF;
		END EXCEPTION;

		--SET DEBUG FILE TO "/informix/LIP/logs/sp_alta_solicitud_movil_online.out";
		--TRACE ON;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
		
		INSERT INTO informix.si_solicitud_movil_online(productos, numcte, ap_nombre1, ap_nombre2, ap_apell_paterno, ap_apell_materno, ap_sexo, ap_fecha_nac, ap_rfc, email, telefono_casa, telefono, carrier, pais_nac, ap_cod_postal, ap_id_estado, ap_id_ciudad, ap_id_colonia, ap_id_municipio, ap_id_calle, num_exterior, num_interior, entre_calles, complemento, tdc_activa, cuatro_digitos, credito_hipotecario, credito_automotriz, firma_buro, escolaridad, estado_civil, tpo_edo_civil, meses_edo_civil, tipo_residencia, tpo_domicilio, pers_domicilio, pers_trabajan, pers_dependen, empresa, tpo_trabajo, tpo_trab_ant, actividad, subactividad, nivel_ingresos, tel_trabajo, nombre1_ref, nombre2_ref, apell_paterno_ref, apell_materno_ref, fech_nac_ref, genero_ref, parentesco_ref, tel_celular_ref, ejecutivo, numero_control, fecha_hora)
		VALUES(pproductos,pnumcte,pap_nombre1,pap_nombre2,pap_apell_paterno,pap_apell_materno,pap_sexo,pap_fecha_nac,pap_rfc,pemail,ptelefono_casa,ptelefono,
				pcarrier,ppais_nac,pap_cod_postal,pap_id_estado,pap_id_ciudad,pap_id_colonia,pap_id_municipio,pap_id_calle,pnumero_exterior,pnumero_interior,
				pentre_calles,pcomplemento,ptarjeta_de_credito_activa,pultimos_cuatro_digitos,pcredito_hipotecario,pcredito_automotriz,pfirma_buro,pescolaridad,
				pestado_civil,ptpo_edo_civil,pmeses_edo_civil,ptipo_residencia,ptiempo_domicilio,ppers_domicilio,ppers_trabajan,ppers_dependen,pempresa,ptiempo_trabajo,
				ptiempo_trab_ant,pactividad,psubactividad,pnivel_ingresos,ptel_trabajo,pprimer_nombre_referencia,psegundo_nombre_referencia,pprimer_apellido_referencia,
				psegundo_apellido_referencia,pfecha_de_nacimiento_referencia,pgenero_referencia,pparentesco_referencia,ptelefono_celular_referencia,pejecutivo,pnumero_control,pfecha_hora);

		
		RETURN vcodret1,vmsjresp,vcodsolbcpl,vdescsolbcpl,vmotivobcpl,vproductobcpl,vfoliobcpl,vcodsolcpl,vdescsolcpl,vmotivocpl,vproductocpl,vfoliocpl;
	
	END;
	
END PROCEDURE;