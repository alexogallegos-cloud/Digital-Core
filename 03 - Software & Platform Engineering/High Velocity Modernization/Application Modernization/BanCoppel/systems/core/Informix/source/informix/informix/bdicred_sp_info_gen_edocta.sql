CREATE PROCEDURE "informix".sp_info_gen_edocta(pempresa CHAR(3),pperiodo DATE, pTipo smallint)
--EXECUTE PROCEDURE sp_info_gen_edocta('001',mdy('04','20','2025'),0);
RETURNING CHAR(5);

DEFINE v_ruta       VARCHAR(255);
DEFINE v_ruta_cfd   VARCHAR(255);
DEFINE cod_ret      CHAR(5);
DEFINE cCodRetBit   CHAR(6);
DEFINE cProceso     CHAR(4);
DEFINE sql_err      INTEGER;
DEFINE isam_err     INTEGER;
DEFINE error_info   CHAR(80);
DEFINE cMensajeRet  CHAR(125);
DEFINE v_sql        CHAR(9000);
DEFINE v_sql0       CHAR(1400);
DEFINE v_sql1       CHAR(1400);
DEFINE v_sql2       CHAR(1400);
DEFINE v_sql3       CHAR(1400);
DEFINE v_sql4       CHAR(1600);
DEFINE v_sql5       CHAR(1600);
DEFINE v_sql6       CHAR(10000);
DEFINE v_sql7       CHAR(1600);
DEFINE v_sql8       CHAR(1400);
DEFINE cNumCred     CHAR(20);
DEFINE cNumCredAux  CHAR(20);
DEFINE cNumCte      CHAR(20);
DEFINE cNumCteAux   CHAR(20);
DEFINE iMovMax      INTEGER;
DEFINE sPaso        SMALLINT;
DEFINE v_periodo_tc_ini     DATE;       --periodo_tc_ini
DEFINE v_periodo_tc_fin   	DATE;	  	--periodo_tc_fin
DEFINE v_periodo_anterior   DATE;		--Fecha Periodo Anterior
DEFINE v_dias_periodo_tc 	INTEGER;	--dias_periodo_tc
DEFINE v_cod_ret_otro		CHAR(5);
DEFINE v_FechaModificaZona  DATE;
   
DEFINE wBandera     CHAR(01);
DEFINE cSql         CHAR(200);
DEFINE dFechaTmp 	DATE;
DEFINE sTabla 		SMALLINT;
DEFINE VSecuencia 	smallint;
DEFINE vNumCredito 	Char(20);
DEFINE vfemision	date;    
DEFINE Vnum_solpres CHAR(20);
DEFINE pperiodoSdoInt1 DATE;
DEFINE pperiodoSdoInt2 DATE;
DEFINE vControl		CHAR(02);
DEFINE vBandera		CHAR(1);
DEFINE vExiste		SMALLINT;

DEFINE vFechAnioAnt	DATE;
DEFINE vFechaCalculaMenosPeriodo DATE;
DEFINE vMesAnioAnt	CHAR(2);
DEFINE vAnioAnt		CHAR(4);

DEFINE vMenosPeriAnt	DATE;
DEFINE vMenosMesAnt		DATE;
DEFINE vMesPerAnt	CHAR(2);
DEFINE vAnioPerAnt	CHAR(4);
DEFINE cNomArchPL	CHAR(16);

LET v_ruta      = "";
LET v_sql       = "";
LET v_sql0		= "";
LET v_sql1      = "";
LET v_sql2      = "";
LET v_sql3      = "";
LET v_sql4      = "";
LET v_sql5      = "";
LET v_sql6      = "";
LET v_sql7      = "";
LET v_sql8		= "";
LET sPaso       = 0; 
LET cNumCred    = "";
LET cNumCredAux = "";
LET cNumCte     = "";
LET cNumCteAux  = "";
LET iMovMax     = 0;
LET v_periodo_tc_ini	= " ";	--periodo_tc_ini
LET v_periodo_tc_fin	= " ";	--periodo_tc_fin
LET v_periodo_anterior	= " ";  --Fecha Periodo Anterior
LET v_dias_periodo_tc	= 0;	--dias_periodo_tc
LET v_cod_ret_otro		= "000";
LET cProceso 			= '0061';
LET cMensajeRet 		= 'PROCESO EXITOSO';
LET sql_err 			= 0;
LET isam_err 			= 0;
LET error_info 			= "";
LET v_FechaModificaZona = mdy('12','19','2012');
LET pperiodoSdoInt1 	= mdy(MONTH(pperiodo),1,year(pperiodo));
LET pperiodoSdoInt2 	= pperiodoSdoInt1 ;
LET wBandera        = "";
LET cSql 			= '';
LET dFechaTmp 		= DATE(1);
LET sTabla 			= 0;
let VSecuencia		= 0;
let vNumCredito		= '';
let vfemision		= date(1);
let Vnum_solpres 	= '';
LET vControl		= '';
LET vBandera		= '0';
LET vExiste			= 0;

LET vFechAnioAnt	= date(1);
LET vFechaCalculaMenosPeriodo	= date(1);
LET vMesAnioAnt		= '';
LET vAnioAnt		= '';

LET vMenosPeriAnt	= DATE(1);
LET vMenosMesAnt	= "";
LET vMesPerAnt	= '';
LET vAnioPerAnt		= '';
LET cNomArchPL	= 'descarga_info_pl';

set isolation to dirty read;
set lock mode to wait 3;
--SET ISOLATION TO COMMITTED READ LAST COMMITTED;
--SET ISOLATION COMMITTED READ;
--set pdqpriority 20;

-- Fecha: 09/09/2009
-- Autor: Faviola Martinez Juarez
-- Nodificacion: Informacion Base para la generacion de los Estados de Cuenta
-- Separando los querys.
 
BEGIN

    ON EXCEPTION SET sql_err, isam_err, error_info
        IF sql_err <> 0 THEN
            LET cod_ret = sql_err;            
            LET cMensajeRet = error_info;
            --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cod_ret, cMensajeRet, '02') RETURNING cCodRetBit;
			IF vBandera = '1' THEN
				ROLLBACK WORK;
			END IF;
            RETURN cod_ret;
        END IF
    END EXCEPTION;

    LET cod_ret = "000";

 --SET DEBUG FILE TO "/home/c90035619/RQM_10_1674/Luis/sps/sp_info_gen_edocta1.out";
 --TRACE ON;

    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cod_ret, cMensajeRet, '01') RETURNING cCodRetBit;
    
    SELECT TRIM(valor) INTO v_ruta FROM sd_param WHERE empresa = pempresa AND cod_param = '033';
	 --let v_ruta = '/home/c90035619/RQM_10_1674/archivoscartera/';--prueba gpe
    --SELECT TRIM(valor) INTO v_FechaModificaZona FROM sd_param WHERE empresa = pempresa AND cod_param = '070';
    --LET v_FechaModificaZona = MDY(MONTH(pperiodo)-1, '20', DECODE(MONTH(pperiodo)-1, 12, YEAR(pperiodo)-1, YEAR(pperiodo)));

    EXECUTE PROCEDURE sp_mes_siguiente(pperiodo,-1,DAY(pperiodo))
                	INTO v_cod_ret_otro,v_periodo_anterior,v_dias_periodo_tc;
   
    LET v_periodo_tc_ini = v_periodo_anterior + 1 UNITS DAY;
    LET v_periodo_tc_fin = pperiodo;
	EXECUTE PROCEDURE MONTHADD(pperiodoSdoInt1,-1) into pperiodoSdoInt2;
	
	LET vFechaCalculaMenosPeriodo = pperiodo - (v_dias_periodo_tc * (-1));
	
    IF pTipo = 0 THEN
	
		BEGIN; TRUNCATE TABLE sd_paso_coppelmax_edc; COMMIT;
		
		select count(*) INTO vExiste
		from bdicred:"informix".sd_cifras_archivos_edocta
		where fecha_mov = pperiodo;
	
		IF vExiste = 0 THEN
		INSERT INTO "informix".sd_cifras_archivos_edocta
				(
				empresa, 		fecha_mov, 		t_clasica, 		t_oro, 		t_platino, 		mov_clasica, 	mov_oro, 		mov_platino, 	sit_especiales,
				aclaraciones, 	sucursales, 	comisiones, 	saldos, 	sepomex, 		correos, 		ctasermail,		coppelmax)
		  VALUES(
				'001', 			pperiodo, 		0, 				0, 			0, 				0, 				0, 			0, 				0,
				0, 				0, 				0, 				0, 			0, 				0, 				0 ,			0
				);
	END IF;
	
	-- Controlador de descargas.
	SELECT valor INTO vControl FROM bdicred:sd_param 
	WHERE empresa = '001' AND cod_param = '122';
	
	IF vControl IS NULL THEN
		LET vControl = '0';
		BEGIN WORK;
			INSERT INTO sd_param(empresa, cod_param, descripcion, valor, user_insert, fecha_insert)
			VALUES('001', '122', 'Control reinicio de descargas de opc194 edc tdc', vControl, USER, today);
		COMMIT WORK;
	ELIF vControl = '' THEN
		LET vControl = '0';
		BEGIN WORK;
			UPDATE bdicred:"informix".sd_param SET valor = vControl
			WHERE cod_param = '122';
		COMMIT WORK;
	END IF;
	
        -----------------DESCARGA SITUACIONES ESPECIALES----------------------------------------
	IF vControl = '0' THEN
		LET v_sql1 = ' echo "SET ISOLATION TO DIRTY READ; UNLOAD TO '||trim(v_ruta)||'descargaSE.unl ';
        LET v_sql2 = ' select cr.num_credito, se.situacion, se.causa, decode( se.situacion||se.causa,''F42'',5, nvl(sa.idaccion,0)) , nvl(sa.instruccion,''0'') '||
                      ' from bdicred:sd_maecred cr  ,  '||				  
                      '      bdisitesp:se_ctessitespcte  se'||
    				  ' left join  bdisitesp:se_situacionaccion sa on ( sa.situacion = se.situacion and sa.causa = se.causa and sa.idaccion in (0,1) ) '||
                      ' where cr.empresa = ''001'''||
					  ' and  cr.num_producto <> ''7800'''||
                      ' and cr.numcte = se.numcte and se.situacion in  (''L'',''F'',''G'',''S'',''Y'',''H'',''X'',''P'')  '||
					  ' and se.causa = case when se.situacion = ''P'' then 34 else se.causa end '||
					  ' and cr.status_cred in (''AA'',''BA'',''BT'',''FF'',''E1'',''E2'',''E3'') '||
					  ' and cr.campo_trab3 <> ''BAJA'' '	;
        LET v_sql3=  ' union '||
                      ' select  sdo.num_credito, se.situacion, se.causa, decode( se.situacion||se.causa,''F42'',5, nvl(sa.idaccion,0)), nvl(sa.instruccion,''0'') '||
                      ' from bdicred:sd_maecred sdo , bdisitesp:se_ctessitespcred  se '||
            		  ' left join  bdisitesp:se_situacionaccion sa on ( sa.situacion = se.situacion and sa.causa = se.causa and sa.idaccion in (0,1) ) '||
                      ' where sdo.empresa = ''001'' '||
					  ' and  sdo.num_producto <> ''7800'''||
                      ' and sdo.num_credito = se.numcred and se.situacion in (''L'',''F'',''G'',''S'',''Y'',''H'',''X'',''P'')  '||
					  ' and se.causa = case when se.situacion = ''P'' then 34 else se.causa end '||
                      ' and sdo.status_cred in (''AA'',''BA'',''BT'',''FF'',''E1'',''E2'',''E3'') and sdo.campo_trab3 <> ''BAJA'' "'||  ' > '; 
        LET v_sql4=  v_ruta||'querySE.sql ';  
        LET v_sql = v_sql1||v_sql2||v_sql3||v_sql4; --||v_sql5;

        system v_sql;

        LET v_sql = "dbaccess bdicred "|| v_ruta|| "querySE.sql";
        system v_sql;
		
		LET vControl = '1';
		LET vBandera = '0';
		BEGIN WORK;
		LET vBandera = '1';
			UPDATE bdicred:"informix".sd_param SET valor = vControl
			WHERE empresa = '001' AND cod_param='122';
		COMMIT WORK;
		--LIMPIEZA DE VARIABLES
		LET v_sql = '';
		LET v_sql1 = '';
		LET v_sql2 = '';
		LET v_sql3 = '';
		LET v_sql4 = '';
	END IF;

        -----------------DESCARGA MENSAJES------------------------------------------------------
	IF vControl = '1' THEN
        LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descargaMENSAJE.unl';
        LET v_sql2 = ' select  *  from sd_mensajes_mensual_edocta '||                        
                        ' where fecha_emision BETWEEN '''|| to_char(v_periodo_tc_ini,'%m-%d-%Y') ||''' AND ''' || to_char(v_periodo_tc_fin,'%m-%d-%Y') || ''''||                        
                        '  " > '||v_ruta ||'queryMENSAJE.sql';

        LET v_sql = v_sql1||v_sql2; --||v_sql3;

        system v_sql;
        LET v_sql = "dbaccess bdicred "||v_ruta||"queryMENSAJE.sql";
        system v_sql;
		
		LET vControl = '2';
		LET vBandera = '0';
		BEGIN WORK;
		LET vBandera = '1';
			UPDATE bdicred:"informix".sd_param SET valor = vControl
			WHERE empresa = '001' AND cod_param='122';
		COMMIT WORK;
		--LIMPIEZA DE VARIABLES
		LET v_sql = '';
		LET v_sql1 = '';
		LET v_sql2 = '';
	END IF;
		
		-----------------DESCARGA PTF (Sucursales por SEPOMEX) ---------------------------------
	IF vControl = '2' THEN
		LET v_sql1 = ' echo " set isolation to dirty read; ' ||
					 ' UNLOAD TO '||v_ruta||'descargaPTF.unl' ||
					 ' Select id_ptf,tipo,clave_sit,fecha_sit,cve_pais,calle,num_ext,num_int, '||
					 ' cve_col,cve_mun,cve_localidad,cp,cve_ciudad,cve_estado,latitud,longitud, '||
					 ' tel1,tel2,referencia,tipo_bovsuc,correo,horario,servicio_canje,tipo_acceso, '||
					 ' dispensa_baja,com_retiro,com_consulta,criterio_com from bdinteg:si_ptf where tipo = ''S'';  " >'|| v_ruta||'queryPTF.sql';
					 
        LET v_sql = v_sql1;
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "||v_ruta||"queryPTF.sql";
        system v_sql;
		
		LET vControl = '3';
		LET vBandera = '0';
		BEGIN WORK;
		LET vBandera = '1';
			UPDATE bdicred:"informix".sd_param SET valor = vControl
			WHERE empresa = '001' AND cod_param='122';
		COMMIT WORK;
		--LIMPIEZA DE VARIABLES
		LET v_sql = '';
		LET v_sql1 = '';
	END IF;

		-----------------DESCARGA SUCURSALES----------------------------------------------------		
	IF vControl = '3' THEN
		LET v_sql1 = ' echo " set isolation to dirty read; ' ||
					 ' UNLOAD TO '||v_ruta||'descargaSucs.unl' ||
					 ' Select empresa,sucursal,nombre,direccion1,direccion2,telefono1,telefono2,telex,gerente,subger,plaza,pais,estado,ciudad,dias_laborables,impresora,factor_remesas,monto_minimo,factor_rem_sbc,monto_min_sbc,iva,sal_min_pza,chq_num_cta,inv_num_cta,aho_num_cta,tpo_sucursal,user_insert,fecha_insert,mto_min_efect,mto_max_efect,plaza_cajagen,tienda_matriz,d_codigo from bdinteg:si_sucursales;  " >'|| v_ruta||'querySucs.sql';
					 
        LET v_sql = v_sql1;
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "||v_ruta||"querySucs.sql";
        system v_sql;
		
		LET vControl = '4';
		LET vBandera = '0';
		BEGIN WORK;
		LET vBandera = '1';
			UPDATE bdicred:"informix".sd_param SET valor = vControl
			WHERE empresa = '001' AND cod_param='122';
		COMMIT WORK;
		--LIMPIEZA DE VARIABLES
		LET v_sql = '';
		LET v_sql1 = '';
	END IF;
	
        -----------------DESCARGA ACLARACIONES--------------------------------------------------
	IF vControl = '4' THEN
		LET v_sql1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO '||v_ruta||'descargaACL.unl';
        LET v_sql2 = ' SELECT  ''001'' empresa,pro.numero_cuenta, acl.fechacaptura, acl.folio_csuac, '||
                        ' mov.fechahora, eve.descripcion , acl.importereclamado, sta.descripcion '||
    					' FROM bdiaclaracion:acl_aclaracion  acl '||
						' INNER JOIN bdiaclaracion:acl_movimiento mov ON acl.pky_aclaracion = mov.fky_aclaracion '||
        				' INNER JOIN bdiaclaracion:acl_tipo_evento eve ON acl.fky_tipo_evento = eve.pky_tipo_evento '||
            			' INNER JOIN bdiaclaracion:acl_producto pro ON pro.pky_producto = acl.fky_producto '||
						' LEFT OUTER JOIN bdiaclaracion:acl_estatus_aclaracion sta ON acl.fky_estatus_aclaracion = sta.pky_estatus_aclaracion '||
                    	' INNER JOIN bdicred:sd_maecred cr ON pro.numero_cuenta = cr.num_credito AND cr.status_cred in (''AA'',''BA'',''BT'',''FF'',''E1'',''E2'',''E3'') AND cr.empresa = ''001'' '||
                        ' where acl.fechacaptura BETWEEN '''|| to_char(v_periodo_tc_ini,'%m-%d-%Y') ||''' AND ''' || to_char(v_periodo_tc_fin,'%m-%d-%Y') || ''' '||
                        ' AND acl.fky_estatus_aclaracion = 2 '||
						' AND cr.campo_trab3 <> ''BAJA'' " > '||v_ruta ||'queryACL.sql';

        LET v_sql = v_sql1||v_sql2; --||v_sql3;

        system v_sql;
        LET v_sql = "dbaccess bdicred "||v_ruta||"queryACL.sql";
        system v_sql;
		
		LET vControl = '5';
		LET vBandera = '0';
		BEGIN WORK;
		LET vBandera = '1';
			UPDATE bdicred:"informix".sd_param SET valor = vControl
			WHERE empresa = '001' AND cod_param='122';
		COMMIT WORK;
		--LIMPIEZA DE VARIABLES
		LET v_sql = '';
		LET v_sql1 = '';
		LET v_sql2 = '';
		LET v_sql3 = '';
		LET v_sql4 = '';
	END IF;

		-----------------DESCARGA Comisiones----------------------------------------------------
	IF vControl = '5' THEN
		LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descargaCom.unl ';
        LET v_sql2 = 'SELECT *  FROM sd_detcomi  '||		
                ' where estado_com  = ''A''  " >'|| v_ruta||'queryCOM.sql';

        LET v_sql = v_sql1 || v_sql2 ;

		
        system v_sql;
        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryCOM.sql";
        system v_sql;
		
		LET vControl = '6';
		LET vBandera = '0';
		BEGIN WORK;
		LET vBandera = '1';
			UPDATE bdicred:"informix".sd_param SET valor = vControl
			WHERE empresa = '001' AND cod_param='122';
		COMMIT WORK;
		--LIMPIEZA DE VARIABLES
		LET v_sql = '';
		LET v_sql1 = '';
		LET v_sql2 = '';
	END IF;
	
		-----------------DESCARGA correos de clientes----------------------------------------------------
	IF vControl = '6' THEN
		LET v_sql1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO '||v_ruta||'descargaCorreos.unl ';
        LET v_sql2 = 'SELECT b.numcte,correo_elec,tipo_correo,status_correo,max(secuencia) '||
				' FROM bdicred:sd_maecred c '||
				' INNER JOIN bdinteg:"informix".si_correos b ON c.numcte=b.numcte AND b.status_correo = ''A'' AND b.tipo_correo = 1 '||
				' WHERE c.status_cred IN(''E1'',''E2'',''E3'') ' ||
				' AND b.valido = ''1'' ' ||
                ' GROUP BY b.numcte,correo_elec,tipo_correo,status_correo; " >'|| v_ruta||'queryMails.sql';

        LET v_sql = v_sql1 || v_sql2 ;

		
        system v_sql;
        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryMails.sql";
        system v_sql;
		
		LET vControl = '7';
		LET vBandera = '0';
		BEGIN WORK;
		LET vBandera = '1';
			UPDATE bdicred:"informix".sd_param SET valor = vControl
			WHERE empresa = '001' AND cod_param='122';
		COMMIT WORK;
		--LIMPIEZA DE VARIABLES
		LET v_sql = '';
		LET v_sql1 = '';
		LET v_sql2 = '';
	END IF;
	
		-----------------DESCARGA cuentas servicio activo x correo----------------------------------------------------
	IF vControl = '7' THEN
		LET v_sql1 = ' echo " SET ISOLATION TO DIRTY READ; UNLOAD TO '||v_ruta||'descargaServMail.unl ';
        LET v_sql2 = 'SELECT e.cuenta FROM bdiedoelec:"informix".edelec_alta_serv e '||
				' INNER JOIN (SELECT cuenta, max(fecha_alta_servicio) fecha_alta_servicio FROM bdiedoelec:"informix".edelec_alta_serv GROUP BY cuenta)j ON e.cuenta = j.cuenta '||
				' WHERE e.status_serv_elec = ''A'' '||
				' AND e.producto IN (''6001'',''6600'',''7000'') ' ||
                ' AND e.fecha_alta_servicio = j.fecha_alta_servicio; " >'|| v_ruta||'queryServMail.sql';

        LET v_sql = v_sql1 || v_sql2 ;

		
        system v_sql;
        LET v_sql = "dbaccess bdiedoelec "|| v_ruta||"queryServMail.sql";
        system v_sql;
		
		LET vControl = '8';
		LET vBandera = '0';
		BEGIN WORK;
		LET vBandera = '1';
			UPDATE bdicred:"informix".sd_param SET valor = vControl
			WHERE empresa = '001' AND cod_param='122';
		COMMIT WORK;
		--LIMPIEZA DE VARIABLES
		LET v_sql = '';
		LET v_sql1 = '';
		LET v_sql2 = '';
	END IF;
	
	----------------------------------DESCARGA CoppelMax / PlanLealtad------------------------------------------------------------------------------------
	IF vControl = '8' THEN
		LET v_sql1 = ' echo " set isolation to dirty read; UNLOAD TO '||v_ruta||'descarga_info_pl.unl '||
                     ' SELECT pl.numcte, m.num_credito, pl.origen, pl.estatus, SUM(saldo_total) sdo_tot_pleal_rew,'''' tipo_mov, 0 puntos_elect_money, '''' tipo, 0 monto_abono '||
                     ' from bdicred:sd_monedero_plan_lealtad pl '||
                     ' INNER JOIN bdicred:sd_maecred m ON pl.numcte = m.numcte '||
                     ' INNER JOIN bdinteg:si_cliente cl ON pl.numcte = cl.numcte '||
                     ' WHERE m.status_cred IN(''E1'',''E2'',''E3'') '||
                     ' AND m.num_producto IN(''6001'',''8100'',''5400'') '||
                     ' AND fecha_actualizacion <= MDY('||TO_CHAR(pperiodo,'%m,%d,%Y')||') '||   
                     ' GROUP BY 1,2,3,4 '||
                     ' UNION ALL '||
                     ' SELECT plm.numcte, m.num_credito, '''', '''', 0, plm.tipo_mov, SUM(monto),'''',0 '||
                     ' from bdicred:sd_movs_monedero_plan_lealtad plm '||
                     ' INNER JOIN bdicred:sd_maecred m ON plm.num_credito = m.num_credito '||
                     ' INNER JOIN bdinteg:si_cliente cl ON plm.numcte = cl.numcte '||
                     ' WHERE m.status_cred IN(''E1'',''E2'',''E3'') '||
                     ' AND m.num_producto IN(''6001'',''8100'',''5400'') '||
                     ' AND tipo_mov = ''CARGO_PUNTOS'' '||
                     ' AND fecha_mov <= MDY('||TO_CHAR(pperiodo,'%m,%d,%Y')||') '||
                     ' GROUP BY 1,2,6 ';
        LET v_sql2 = ' UNION ALL '||
                     ' SELECT plm.numcte, m.num_credito, '''', '''', 0, plm.tipo_mov, SUM(monto) monto,'''',0 '||
                     ' from bdicred:sd_movs_monedero_plan_lealtad plm '||
                     ' INNER JOIN bdicred:sd_maecred m ON plm.num_credito = m.num_credito '||
                     ' INNER JOIN bdinteg:si_cliente cl ON plm.numcte = cl.numcte '||
                     ' WHERE fecha_mov BETWEEN  MDY('||TO_CHAR(v_periodo_tc_ini,'%m,%d,%Y')||') AND MDY('||TO_CHAR(pperiodo,'%m,%d,%Y')||') '||
                     ' AND tipo_mov IN(''CARGO_VIGENCIA'',''ABONO_PUNTOS'') '||
                     ' AND m.status_cred IN(''E1'',''E2'',''E3'') '||
                     ' AND m.num_producto IN(''6001'',''8100'',''5400'') '||
                     ' GROUP BY 1,2,6 ';
        LET v_sql3 = ' UNION ALL '||
                     ' SELECT vpl.numcte, m.num_credito, '''', '''', 0, '''', 0, vpl.tipo, SUM(vpl.monto_abono) '||
                     ' from bdicred:sd_vigencia_monedero_plan_lealtad vpl '||
                     ' INNER JOIN bdicred:sd_maecred m ON vpl.numcte = m.numcte '||
                     ' INNER JOIN bdinteg:si_cliente cl ON vpl.numcte = cl.numcte '||
                     ' WHERE vpl.fecha_insert > MDY('||to_char(v_periodo_anterior,'%m,%d,%Y')||') AND vpl.fecha_insert <= MDY('||TO_CHAR(pperiodo,'%m,%d,%Y')||') '||
                     ' AND tipo = ''vigente'' '||
                     ' AND m.status_cred IN(''E1'',''E2'',''E3'') '|| 
                     ' AND m.num_producto IN(''6001'',''8100'',''5400'') '||
                     ' GROUP BY 1,2,8; " >'||v_ruta||'queryInfoCoppelMax.sql';
					 
		LET v_sql = trim(v_sql1) || ' ' || trim(v_sql2) || ' ' || trim(v_sql3);
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "||v_ruta|| "queryInfoCoppelMax.sql";
		system v_sql;
					 
        --LET v_sql3 = ' LOAD FROM '||v_ruta||'descarga_info_pl.unl INSERT INTO bdicred:sd_paso_coppelmax_edc; '||
					
		LET v_sql = '';		
		LET v_sql = ' echo "FILE '|| trim(v_ruta) || TRIM(cNomArchPL) || '.unl DELIMITER '''||'|'||''' 9; INSERT INTO "informix".sd_paso_coppelmax_edc; " > '|| trim(v_ruta) ||'queryCargaInfoPL.sql';
		system v_sql;							

		LET v_sql = '';	
		LET v_sql = 'dbload -d bdicred -c '|| trim(v_ruta) ||'queryCargaInfoPL.sql -l '|| trim(v_ruta) ||'sd_paso_coppelmax_edc.log -e 10000 -n 1000 -r';
		system v_sql;
		
		
        LET v_sql4 = ' echo " SET ISOLATION TO DIRTY READ; '||
                     ' UNLOAD TO '||v_ruta||'descargaCoppelMax.unl '||
                     ' SELECT a.numcte, a.num_credito, NVL(SUM(sdo_tot_pleal_rew),0) as sdo_initial, '||
                     ' (SELECT NVL(SUM(puntos_elect_money),0) FROM bdicred:sd_paso_coppelmax_edc b WHERE tipo_mov = ''CARGO_PUNTOS'' AND b.num_credito=a.num_credito) cash_used, '||
                     ' (SELECT NVL(SUM(puntos_elect_money),0) FROM bdicred:sd_paso_coppelmax_edc c WHERE tipo_mov = ''CARGO_VIGENCIA'' AND c.num_credito=a.num_credito) cash_defeated, '||
                     ' (SELECT NVL(SUM(puntos_elect_money),0) FROM bdicred:sd_paso_coppelmax_edc d WHERE tipo_mov = ''ABONO_PUNTOS'' AND d.num_credito=a.num_credito) cash_received, '||
                     ' (SELECT NVL(SUM(monto_abono),0) FROM bdicred:sd_paso_coppelmax_edc e WHERE tipo = ''vigente'' AND e.num_credito=a.num_credito) cash_beat, '||
					 ' (SELECT NVL(SUM(sdo_tot_pleal_rew),0) FROM bdicred:sd_paso_coppelmax_edc f WHERE f.num_credito=a.num_credito) cash_end, '||
                     ' (SELECT NVL(SUM(sdo_tot_pleal_rew),0) FROM bdicred:sd_paso_coppelmax_edc g WHERE g.num_credito=a.num_credito AND origen = ''Plan_Lealtad'' AND sdo_tot_pleal_rew > 0 )  cash_pl,'||
                     ' (SELECT NVL(SUM(sdo_tot_pleal_rew),0) FROM bdicred:sd_paso_coppelmax_edc h WHERE h.num_credito=a.num_credito AND origen = ''Reworth'' AND sdo_tot_pleal_rew > 0 ) cash_rw '||
                     ' FROM bdicred:sd_paso_coppelmax_edc a '||
                     ' GROUP BY 1,2,4,5,6,7,8,9,10; " >'||v_ruta||'queryCoppelMax.sql';
					 		   	   
		LET v_sql = trim(v_sql4);
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "||v_ruta|| "queryCoppelMax.sql";
		system v_sql;
		
		LET vControl = '9';
		LET vBandera = '0';
		BEGIN WORK;
		LET vBandera = '1';
			UPDATE bdicred:"informix".sd_param SET valor = vControl
			WHERE empresa = '001' AND cod_param='122';
		COMMIT WORK;
		--LIMPIEZA DE VARIABLES
		LET v_sql = '';
		LET v_sql1 = '';
		LET v_sql2 = '';
		LET v_sql3 = '';
        LET v_sql4 = '';
	END IF;
	
	---------------- LIMPIEZA Y CONVERSION DE ARCHIVOS ----------------
	IF vControl = '9' THEN
		--SITUACIONES ESPECIALES
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaSE.unl'||" >"||v_ruta||'descargaSE1.unl';
		SYSTEM v_sql;
		
		LET v_sql = '';
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaSE1.unl'||" > " || trim(v_ruta||'Edocta_SitEsp'||'.unl');
		SYSTEM v_sql;
		
		--MENSAJES
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaMENSAJE.unl'||" >"||v_ruta||'descargaMENSAJE1.unl';
		SYSTEM v_sql;
		
		LET v_sql = '';
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaMENSAJE1.unl'||" > " ||v_ruta||'Edocta_Mensajes'||'.unl';
		SYSTEM v_sql;
		
		--PTF (Sucursales por SEPOMEX)
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaPTF.unl'||" >"||v_ruta||'descargaPTF1.unl';
		SYSTEM v_sql;
		
		LET v_sql = '';
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaPTF1.unl'||" > "||v_ruta||'Edocta_PTF'||'.unl';
		SYSTEM v_sql;
		
		--SUCURSALES
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaSucs.unl'||" >"||v_ruta||'descargaSucs1.unl';
		SYSTEM v_sql;
		
		LET v_sql = '';
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaSucs1.unl'||" > "||v_ruta||'Edocta_Sucursales'||'.unl';
		SYSTEM v_sql;
		
		--ACLARACIONES
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaACL.unl'||" >"||v_ruta||'descargaACL1.unl';
		SYSTEM v_sql;
		
		LET v_sql = '';
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaACL1.unl'||" > " ||v_ruta||'Edocta_Aclaraciones'||'.unl';
		SYSTEM v_sql;
		
		--COMISIONES
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaCom.unl'||" >"||v_ruta||'descargaCom1.unl';
		SYSTEM v_sql;
		
		LET v_sql = '';        
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaCom1.unl'||" > "||v_ruta||'Edocta_Comisiones'||'.unl';
		SYSTEM v_sql;
		
		--CORREOS
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaCorreos.unl'||" >"||v_ruta||'descargaCorreos1.unl';
		SYSTEM v_sql;
		
		LET v_sql = '';        
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaCorreos1.unl'||" > "||v_ruta||'Edocta_Correos'||'.unl';
		SYSTEM v_sql;
		
		--SERVICIO X CORREO
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaServMail.unl'||" >"||v_ruta||'descargaServMail1.unl';
		SYSTEM v_sql;
		
		LET v_sql = '';        
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaServMail1.unl'||" > "||v_ruta||'Edocta_ServMail'||'.unl';
		SYSTEM v_sql;
		
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaCoppelMax.unl'||" >"||v_ruta||'descargaCoppelMax1.unl';
		SYSTEM v_sql;
		
		LET v_sql = '';        
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaCoppelMax1.unl'||" > "||v_ruta||'Edocta_CoppelMax'||'.unl';
		SYSTEM v_sql;
		
		LET vControl = '10';
		LET vBandera = '0';
		BEGIN WORK;
		LET vBandera = '1';
			UPDATE bdicred:"informix".sd_param SET valor = vControl
			WHERE empresa = '001' AND cod_param='122';
		COMMIT WORK;
		--LIMPIEZA DE VARIABLES
		LET v_sql = '';
	END IF;
	
	---------------- ELIMINACION DE ARCHIVOS ----------------
	IF vControl = '10' THEN
		LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'descargaSE.unl';
		SYSTEM v_sql;
		
		LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'descargaSE1.unl ';
		SYSTEM v_sql;
		
		LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'querySE.sql';
		SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaMENSAJE.unl';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaMENSAJE1.unl ';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'queryMENSAJE.sql';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'queryPTF.sql';
        SYSTEM v_sql; 
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaPTF1.unl';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaPTF.unl';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'querySucs.sql';
        SYSTEM v_sql; 
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaSucs1.unl';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaSucs.unl';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaACL.unl';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaACL1.unl ';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'queryACL.sql';
        SYSTEM v_sql; 
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaCom.unl';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaCom1.unl ';
        SYSTEM v_sql;
		
        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'queryCOM.sql ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaCorreos.unl ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaCorreos1.unl ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'queryMails.sql ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaServMail.unl ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaServMail1.unl ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'queryServMail.sql ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'queryInfoCoppelMax.sql ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'queryCoppelMax.sql ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descarga_info_pl.unl ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaCoppelMax.unl ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaCoppelMax1.unl ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'sd_paso_coppelmax_edc.log ';
        SYSTEM v_sql;
		
		LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'queryCargaInfoPL.sql ';
        SYSTEM v_sql;
		
		
		LET vControl = '11';
		LET vBandera = '0';
		BEGIN WORK;
		LET vBandera = '1';
			UPDATE bdicred:"informix".sd_param SET valor = vControl
			WHERE empresa = '001' AND cod_param='122';
		COMMIT WORK;
		--LIMPIEZA DE VARIABLES
		LET v_sql = '';
	END IF;
	
	BEGIN WORK;	
		update bdicred:"informix".sd_param
		set valor = '0'
		where empresa = '001' AND cod_param='122';
	COMMIT WORK;
        
    
    ELIF pTipo = 1 THEN

	    SELECT NVL(status_proc,'')
	      INTO wBandera
	      FROM bdinteg:sx_contproc
	     WHERE fecha= pperiodo 
	       AND proceso ='CierreCred';

	       IF wBandera = '' OR wBandera is NULL THEN
	          LET wBandera = '';
	       END IF;

	    WHILE wBandera <> 'F'
	        LET cSql = '';
        	LET wBandera = '';
	        LET cSQL = 'sleep 180';
	        SYSTEM cSql;

	        SELECT NVL(status_proc,'')
        	  INTO wBandera
	          FROM bdinteg:sx_contproc
	         WHERE fecha= pperiodo 
	           AND proceso = 'CierreCred';

	           IF wBandera = '' OR wBandera is NULL THEN
	              LET wBandera = '';
	           END IF;

	    END WHILE;
		
		LET vMenosPeriAnt = pperiodo - 1 units month;
		LET vMesPerAnt = LPAD(MONTH(vMenosPeriAnt::DATE), 2, '0');
		LET vAnioPerAnt = YEAR(vMenosPeriAnt);
		
		LET vFechAnioAnt = vMenosPeriAnt -1 units year;
		LET vMesAnioAnt = LPAD(MONTH(vFechAnioAnt::DATE), 2, '0');
		LET vAnioAnt = YEAR(vFechAnioAnt);
		-- AAME RQM 10 679 Se contempla el producto de TDC Oro para la descarga del ingreso mensual declarado por el cliente.
        -----------------DESCARGA SALDOS-------------------------------------------------------------
        --LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descargaSDO.unl ';
		LET v_sql0 = ' echo " SET ISOLATION TO DIRTY READ; '||
					 ' SELECT sdo.fecha,sdo.empresa,amor.num_credito,amor.iva_debe,sdo.monto_otorgado,sdo.sdo_cap_insoluto,sdo.sdo_int_anticip, '||
                     ' sdo.monto_vencido,sdo.mto_venc_trasp,sdo.sdo_retenido,sdo.sdo_acum_mes_cap,sdo.dias_acum_cap,sdo.int_tra_no_exig, '||
                     ' sdo.sdo_moratorio,sdo.sdo_contab_mora,sdo.monto_financiado,sdo.mto_fin_ven_trasp,sdo.mto_venc_int, anx.prox_fecha_pago, '||
					 ' anx.dia_corte,anx.fecha_proceso,sdo.act FROM bdicred:sd_amortiza_credito amor '||
                     ' INNER JOIN bdicred:sd_maesdoshist sdo ON amor.fecha_cuota = sdo.fecha AND amor.num_credito = sdo.num_credito AND amor.empresa = sdo.empresa '||
					 ' INNER JOIN bdicred:sd_maecredanexo anx ON sdo.num_credito = anx.num_credito '||
					 ' WHERE amor.fecha_cuota = '''|| to_char(pperiodo,'%m-''||'||'anx.dia_corte'||'||''-%Y') || ''' '||
					 ' AND NOT EXISTS (SELECT num_credito FROM sd_maecred mc1 WHERE mc1.num_credito = anx.num_credito AND num_producto = ''7800'') '||
					 ' INTO TEMP AmortizaCred WITH NO LOG; '||
					 ' CREATE INDEX InxAmortizaCred ON AmortizaCred(num_credito, empresa) ONLINE; '||
                     ' UPDATE STATISTICS MEDIUM FOR TABLE AmortizaCred FORCE; ';
		LET v_sql1 = ' SELECT d.num_credito,a.empresa,a.ingreso_mensual FROM AmortizaCred d '||
					 ' INNER JOIN bdisolic:ss_resum_scor_fin a ON d.num_credito = a.num_solicitud AND d.empresa = a.empresa '||
					 ' WHERE a.empresa = ''001'' AND a.num_solicitud > ''0'' INTO TEMP resumScor WITH NO LOG; '||
					 ' INSERT INTO resumScor '||
					 ' SELECT cr.num_credito,a.empresa,a.ingreso_mensual '||
					 ' FROM AmortizaCred d,bdisolic:ss_resum_scor_fin a,bdicred:sd_maecred cr '||
                     ' WHERE a.num_solicitud = cr.credito_externo AND d.num_credito = cr.num_credito AND d.empresa = a.empresa '||
                     ' AND d.empresa = ''001'' AND cr.num_producto in (''7000'',''8100'',''5400''); ';
		LET v_sql2 = ' INSERT INTO resumScor '||
                     ' SELECT a.num_credito,a.empresa,d.ingreso_mensual FROM bdicred:sd_maecred a '||
                     ' INNER JOIN bdicred:sd_maecred c ON (a.empresa = c.empresa AND a.credito_externo = c.num_credito) '||
                     ' INNER JOIN bdisolic:ss_resum_scor_fin d ON (d.empresa = c.empresa AND c.credito_externo = d.num_solicitud) '||
                     ' WHERE a.num_producto IN (''5400''); '||
                     ' CREATE INDEX InxresumScor1 ON resumScor(num_credito) ONLINE; '||
					 ' UPDATE STATISTICS MEDIUM FOR TABLE resumScor FORCE; '||
					 ' INSERT INTO resumScor '||
					 ' SELECT a.num_credito,a.empresa,c.ingreso_mensual FROM bdicred:sd_maecred a '||
					 ' INNER JOIN bdinteg:si_ingresos c ON (a.numcte = c.numcte) AND c.sec_ingreso = (SELECT max(sec_ingreso) FROM bdinteg:si_ingresos WHERE numcte = c.numcte) '||
					 ' WHERE a.status_cred IN(''E1'',''E2'',''E3'') AND a.num_producto IN (''8500'',''8100'',''7000'',''5400'') '||
					 ' AND a.num_credito NOT IN(SELECT num_credito FROM resumScor WHERE num_credito > ''0'');  ';
		LET v_sql3 = ' SELECT num_credito, fecha_mov, b.monto, b.codigo_fun, b.codigo_ref FROM bdicred:sd_movhis b '||
					 ' WHERE b.fecha_mov > MDY("'||vMesAnioAnt||'",15,"'||vAnioAnt||'") AND b.fecha_mov <= MDY("'||vMesPerAnt||'",20,"'||vAnioPerAnt||'") '||
					 ' AND b.codigo_ref IN (1,2,3,5,8,12,17,18,19,23,24,25,26,28,50,51,90,91,92,93,94,95,96,100,101,125,127,926,925,923,993,994,995,996,6212,6218,6219,6220,6221,6232,6238,6239,6240,6241) '||
					 ' AND b.codigo_fun <> '''' AND b.reversado = ''N'' AND b.empresa = ''001'' '||
					 ' INTO TEMP movs_anuales_edc_tdc_v2 WITH NO LOG; '||
					 ' CREATE INDEX idx_movs_anuales_1 ON movs_anuales_edc_tdc_v2(num_credito,fecha_mov) ONLINE; '||
					 ' CREATE INDEX idx_movs_anuales_2 ON movs_anuales_edc_tdc_v2(codigo_fun,codigo_ref) ONLINE; ';
------------------------------------------------------------intereses ---------------------------------------------------------------------
		LET v_sql4 = ' SELECT his.num_credito,sum(his.monto) int_gral FROM AmortizaCred edo '||
					 ' INNER JOIN movs_anuales_edc_tdc_v2 his ON edo.num_credito = his.num_credito AND his.fecha_mov > MDY("'||vMesAnioAnt||'",edo.dia_corte,"'||vAnioAnt||'") AND his.fecha_mov <= MDY("'||vMesPerAnt||'",edo.dia_corte,"'||vAnioPerAnt||'") '||
					 ' WHERE ((codigo_fun IN (select {+INDEX(bdicred:sd_conceptospagomanual idx_conceptospagomanual)} cod_fun from bdicred:sd_conceptospagomanual) AND codigo_ref IN (2,3,5,926,925,923)) '||
					 ' OR ((codigo_fun = ''605'' AND codigo_ref IN(2,125,127)) OR (codigo_fun IN(''061'',''081'') AND codigo_ref IN(8,12)))) '||
					 ' GROUP BY his.num_credito INTO TEMP tmp_intereses_grales2 WITH NO LOG; '||
					 ' CREATE INDEX idx_tmp_intereses_grales ON tmp_intereses_grales2(num_credito) ONLINE; '||
                     ' UPDATE STATISTICS MEDIUM FOR TABLE tmp_intereses_grales2 FORCE; ';
-------------------------------------------------------------------------comsiones---------------------------------------------------
        LET v_sql5 = ' SELECT cred.num_credito,SUM(monto) comi_gral FROM AmortizaCred cred '||
					 ' INNER JOIN movs_anuales_edc_tdc_v2 his ON cred.num_credito = his.num_credito AND his.fecha_mov > MDY("'||vMesAnioAnt||'",cred.dia_corte,"'||vAnioAnt||'") AND his.fecha_mov <= MDY("'||vMesPerAnt||'",cred.dia_corte,"'||vAnioPerAnt||'") '||
					 ' WHERE ((codigo_fun = ''339'' AND codigo_ref IN (50,51,1,3,24,25,26,17,18,19,90,91,92,93,94,95,96,100,101,993,994,995,996)) '||
                     ' OR (codigo_fun = ''039'' AND codigo_ref = 28) OR (codigo_fun = ''336'' AND codigo_ref = 23) OR (codigo_fun = ''033'' AND codigo_ref in(6212,6218,6219,6220,6221,6232,6238,6239,6240,6241))) '||
					 ' GROUP BY cred.num_credito INTO TEMP tmp_comis_grales WITH NO LOG; '||
					 ' CREATE INDEX idx_tmp_comis_grales ON tmp_comis_grales(num_credito) ONLINE; '||
					 ' UPDATE STATISTICS MEDIUM FOR TABLE tmp_comis_grales FORCE; '||
					 ' SELECT cred.num_credito,ROUND(SUM(monto) / 1.16) comi_surcharge FROM AmortizaCred cred '||
                     ' INNER JOIN movs_anuales_edc_tdc_v2 his ON cred.num_credito = his.num_credito AND his.fecha_mov > MDY("'||vMesAnioAnt||'",cred.dia_corte,"'||vAnioAnt||'") AND his.fecha_mov <= MDY("'||vMesPerAnt||'",cred.dia_corte,"'||vAnioPerAnt||'") '||
                     ' WHERE codigo_fun = ''033'' AND codigo_ref in(6212,6218,6219,6220,6221,6232,6238,6239,6240,6241) '||
					 ' GROUP BY cred.num_credito INTO TEMP tmp_comis_sourcharge WITH NO LOG; '||
					 ' CREATE INDEX idx_tmp_comis_sourcharge ON tmp_comis_sourcharge(num_credito) ONLINE; '||
					 ' UPDATE STATISTICS MEDIUM FOR TABLE tmp_comis_sourcharge FORCE; ';
---------------------------------------------------------- anualidad -----------------------------------------------------------------------
		LET v_sql7 = ' SELECT his.num_credito,SUM(monto) anualidad FROM AmortizaCred cred '||
					 ' INNER JOIN movs_anuales_edc_tdc_v2 his ON cred.num_credito = his.num_credito AND his.fecha_mov > MDY("'||vMesAnioAnt||'",cred.dia_corte,"'||vAnioAnt||'") AND his.fecha_mov <= MDY("'||vMesPerAnt||'",cred.dia_corte,"'||vAnioPerAnt||'") '||
					 ' WHERE his.codigo_fun = ''339'' AND his.codigo_ref IN(100,96) '||
					 ' GROUP BY his.num_credito INTO TEMP tmp_anualidades WITH NO LOG; '||
					 ' CREATE INDEX idx_tmp_anualidades ON tmp_anualidades(num_credito) ONLINE; '||
					 ' UPDATE STATISTICS MEDIUM FOR TABLE tmp_anualidades FORCE; '||
					 ' UNLOAD TO '||v_ruta||'descargaSDO.unl'||
				     ' SELECT '''||to_char(pperiodo,'%m-%d-%Y')||''', cre.empresa,cre.num_credito,cre.numcte,cre.num_producto,tar.num_tarjeta,cre.fecha_apertura, '|| 
        		     ' cre.sucursal,scr.ingreso_mensual,cre.status_cred,cre.tasa_interes,sdo.monto_otorgado,cre.tasa_moratorios, '|| 
            	     ' sdo.monto_vencido,mto_venc_trasp,sdo_cap_insoluto,sdo_retenido,sdo_acum_mes_cap,dias_acum_cap, ' ||
                     ' int_tra_no_exig,sdo_moratorio,sdo_contab_mora,monto_financiado,mto_fin_ven_trasp,mto_venc_int Iva_Int_vdo, '||			
				     ' sdo.prox_fecha_pago,monto_ult_convenio,fecha_ult_convenio,decode(cumplio_convenio,''1'',''S'',''0'',''N'', cumplio_convenio ), '||
        		     ' ind.fecha_ultima_compra,(case when sdo.sdo_cap_insoluto > 0 then sdo.sdo_int_anticip else 0 end) interes_debe, '||
            	     ' sdo.iva_debe,ind.fecha_ultimo_pago,today fecha_primer_vencido,nvl(ind.f_primer_compra,date(1)), '||
				     ' sdo.dia_corte,sdo.fecha_proceso,cre.cuenta_clabe,nvl(sdo.act,'' ''),NVL(int_gral,0),ROUND((NVL(c.comi_gral,0) + NVL(e.comi_surcharge,0)),2),NVL(d.anualidad,0) ';
		LET v_sql8 = ' FROM bdicred:sd_maecred cre '||
                     ' INNER JOIN resumScor scr ON cre.num_credito = scr.num_credito '||
				     ' INNER JOIN bdicred:sd_indicador_cred ind ON cre.num_credito = ind.num_credito and cre.empresa = ind.empresa '||
					 ' INNER JOIN AmortizaCred sdo ON cre.num_credito = sdo.num_credito AND cre.empresa = sdo.empresa '||
					 ' LEFT JOIN bdicred:sd_tarjeta tar on (sdo.num_credito = tar.num_credito) and secuencia = (select max(secuencia) from bdicred:sd_tarjeta where num_credito = tar.num_credito and tipo_tarjeta = ''T'' and empresa = ''001'' and empresa = tar.empresa)  '||
                     ' LEFT OUTER JOIN tmp_intereses_grales2 i ON cre.num_credito = i.num_credito '||						
                     ' LEFT OUTER JOIN tmp_comis_grales c ON cre.num_credito = c.num_credito '||
					 ' LEFT OUTER JOIN tmp_comis_sourcharge e ON cre.num_credito = e.num_credito '||
					 ' LEFT OUTER JOIN tmp_anualidades d ON cre.num_credito = d.num_credito '||
                     ' where cre.empresa = ''001'' and cre.campo_trab3 <> ''BAJA''; " >'|| v_ruta||'querySDO.sql';                     			

        LET v_sql = trim(v_sql0) || " " || trim(v_sql1) || " " || trim(v_sql2) || " " || trim(v_sql3) || " " || trim(v_sql4) || " " || trim(v_sql5) || " " || trim(v_sql7) || " " || trim(v_sql8);

        system v_sql;
        LET v_sql = "dbaccess bdicred "|| v_ruta||"querySDO.sql";
        system v_sql;

        LET v_sql = '';
        LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaSDO.unl'||" >"||v_ruta||'descargaSDO1.unl';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaSDO.unl';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaSDO1.unl'||" > "||v_ruta||'Edocta_Saldos'||'.unl';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaSDO1.unl ';
        SYSTEM v_sql; 
		
        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'querySDO.sql ';
		SYSTEM v_sql;
		
		-- Descarga de archivo Edocta_sdoint.unl
		
		--'JMAH INI CAT
		LET v_sql6 = ' echo "UNLOAD TO '||v_ruta||'descargasdoint1.unl'  ||		
		' select cre.num_credito, CASE WHEN  num_producto = ''6001'' THEN 0 ELSE nvl((c.captrans19 + c.capvenexig19),0) END + '||
		' CASE WHEN  num_producto = ''6001'' THEN 0 ELSE nvl((c.captrans20 + c.capvenexig20),0) END + '||
		' nvl((c.captrans21 + c.capvenexig21),0) + '||
		' nvl((c.captrans22 + c.capvenexig22),0) + '||
		' nvl((c.captrans23 + c.capvenexig23),0) + '||
		' nvl((c.captrans24 + c.capvenexig24),0) + '||
		' nvl((c.captrans25 + c.capvenexig25),0) + '||
		' nvl((c.captrans26 + c.capvenexig26),0) + '||
		' nvl((c.captrans27 + c.capvenexig27),0) + '||
		' nvl((c.captrans28 + c.capvenexig28),0) + '||
		' nvl((c.captrans29 + c.capvenexig29),0) + '||
		' nvl((c.captrans30 + c.capvenexig30),0) + '||
		' nvl((c.captrans31 + c.capvenexig31),0) + '||
		' (b.captrans1 + b.capvenexig1) + ' ||
		' (b.captrans2 + b.capvenexig2) + ' ||
		' (b.captrans3 + b.capvenexig3) + ' ||
		' (b.captrans4 + b.capvenexig4) + ' ||
		' (b.captrans5 + b.capvenexig5) + ' ||
		' (b.captrans6 + b.capvenexig6) + ' ||
		' (b.captrans7 + b.capvenexig7) + ' ||
		' (b.captrans8 + b.capvenexig8) + ' ||
		' (b.captrans9 + b.capvenexig9) + ' ||
		' (b.captrans10 + b.capvenexig10) +  '||
		' (b.captrans11 + b.capvenexig11) +  '||
		' (b.captrans12 + b.capvenexig12) + '||
		' (b.captrans13 + b.capvenexig13) + '||
		' (b.captrans14 + b.capvenexig14) +  '||
		' (b.captrans15 + b.capvenexig15) +  '||
		' (b.captrans16 + b.capvenexig16) +  '||
		' (b.captrans17 + b.capvenexig17) +  '||
		' (b.captrans18 + b.capvenexig18) + '||
		' CASE WHEN  num_producto  <> ''6001'' THEN 0 ELSE nvl((b.captrans19 + b.capvenexig19),0) END + '||
		' CASE WHEN  num_producto  <> ''6001'' THEN 0 ELSE nvl((b.captrans20 + b.capvenexig20),0) END , '||
		' round((b.captrans1 + b.capvenexig1) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans2 + b.capvenexig2) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans3 + b.capvenexig3) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans4 + b.capvenexig4) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans5 + b.capvenexig5) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans6 + b.capvenexig6) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans7 + b.capvenexig7) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans8 + b.capvenexig8) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans9 + b.capvenexig9) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans10 + b.capvenexig10) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans11 + b.capvenexig11) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans12 + b.capvenexig12) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans13 + b.capvenexig13) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans14 + b.capvenexig14) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans15 + b.capvenexig15) * tasa_moratorios / 36000,2) +  '||
		' round((b.captrans16 + b.capvenexig16) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans17 + b.capvenexig17) * tasa_moratorios / 36000,2) + '||
		' round((b.captrans18 + b.capvenexig18) * tasa_moratorios / 36000,2) + '||
		' CASE WHEN  num_producto  <> ''6001'' THEN 0 ELSE round((b.captrans19 + b.capvenexig19) * tasa_moratorios / 36000,2)  END + '||
		' CASE WHEN  num_producto  <> ''6001'' THEN 0 ELSE round((b.captrans20 + b.capvenexig20) * tasa_moratorios / 36000,2)  END + '||
		' CASE WHEN  num_producto  =''6001'' THEN 0 ELSE round((c.captrans19 + c.capvenexig19) * tasa_moratorios / 36000,2)  END + '||
		' CASE WHEN  num_producto  = ''6001'' THEN 0 ELSE round((c.captrans20 + c.capvenexig20) * tasa_moratorios / 36000,2)  END + '||
		' nvl(round((c.captrans21 + c.capvenexig21) * tasa_moratorios / 36000,2),0) + '||
		' nvl(round((c.captrans22 + c.capvenexig22) * tasa_moratorios / 36000,2),0) + '||
		' nvl(round((c.captrans23 + c.capvenexig23) * tasa_moratorios / 36000,2),0) + '||
		' nvl(round((c.captrans24 + c.capvenexig24) * tasa_moratorios / 36000,2),0) + '||
		' nvl(round((c.captrans25 + c.capvenexig25) * tasa_moratorios / 36000,2),0) + '||
		' nvl(round((c.captrans26 + c.capvenexig26) * tasa_moratorios / 36000,2),0) + '||
		' nvl(round((c.captrans27 + c.capvenexig27) * tasa_moratorios / 36000,2),0) + '||
		' nvl(round((c.captrans28 + c.capvenexig28) * tasa_moratorios / 36000,2),0) + '||
		' nvl(round((c.captrans29 + c.capvenexig29) * tasa_moratorios / 36000,2),0) + '||
		' nvl(round((c.captrans30 + c.capvenexig30) * tasa_moratorios / 36000,2),0) + '||
		' nvl(round((c.captrans31 + c.capvenexig31) * tasa_moratorios / 36000,2),0)  '||
		'from bdicred:sd_maecred cre  '||
--		'  join  bdicred:sd_maesdoshist sdo  ON (cre.empresa = sdo.empresa  and cre.num_credito = sdo.num_credito and sdo.fecha  ='''|| to_char(pperiodo,'%m-%d-%Y') || ''')'|| 
		' join bdicred:sd_sdodiario b on (cre.num_credito = b.num_credito and b.fecha = '''|| pperiodoSdoInt1|| ''')'|| 
		' left outer join bdicred:sd_sdodiario c on (cre.num_credito = c.num_credito and c.fecha = '''|| pperiodoSdoInt2|| ''') '||
		' where cre.num_credito = b.num_credito and  cre.num_producto <> ''7800''  " > '||v_ruta ||'querysdoint.sql';


		system v_sql6;
		LET v_sql6 = "dbaccess bdicred "||v_ruta||"querysdoint.sql";
		system v_sql6;

		LET v_sql6 = '';
		LET v_sql6 = "sed 's/|$//g' "||v_ruta||'descargasdoint1.unl'||" >"||v_ruta||'descargasdoint.unl';
		SYSTEM v_sql6;

		LET v_sql6 = '';
		LET v_sql6 = "rm "||v_ruta||'descargasdoint1.unl';
		SYSTEM v_sql6;

		LET v_sql6 = '';
		LET v_sql6 = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargasdoint.unl'||" > " ||v_ruta||'Edocta_sdoint'||'.unl';
		SYSTEM v_sql6;

		LET v_sql6 = '';
		LET v_sql6 = "rm "||v_ruta||'descargasdoint.unl ';
		SYSTEM v_sql6;

		LET v_sql6 = '';
		LET v_sql6 = "rm "||v_ruta||'querysdoint.sql';
		SYSTEM v_sql6;
	
		--'JMAH FIN CAT
			
		
        --SYSTEM v_sql;  
		/*
			SELECT COUNT(tabid)
				  INTO sPaso
				  FROM systables
				 WHERE tabname= 'cred_sol';

				IF NVL(sPaso,0) > 0 THEN
					DROP TABLE cred_sol;
				END IF;				
		
		 CREATE  TABLE "informix".cred_sol ( 
                 fecha_emision		date,  
                 num_credito 		CHAR(20), 
				 num_promo 			INTEGER, 
                 num_sol_prestamo 	CHAR(20),
				 folio_suc			CHAR(16),
				 plazo				SMALLINT, 
				 diasmes				SMALLINT, 
				 fecha				DATE,
				 tasa				DECIMAL(12,2),
				 sdo_capital			DECIMAL(20,2),
				 prox_fecha_pago		DATE, 
				 concepto			CHAR(38),
				 capital_mto_cuota	DECIMAL(16,2),
				 numero_cuotas		DECIMAL(17,2), 
				 secuencia		SMALLINT, 
				 nlinea			SMALLINT 
				 ) extent size 32 next size 16; 

		------------------------------------------------------------------------
		LET v_sql1 = ' echo " set isolation to dirty read; '||
		             ' SELECT promoCred.num_credito, promoCred.num_promo, promoCred.num_sol_prestamo, promoCred.folio_suc, '||
					 '   promoCred.plazo, DAY(promoCred.fecha) diasmes, promoCred.fecha, tasaPlazo.tasa '||
					 ' FROM "informix".sd_promocion_credito promoCred, "informix".sd_tasa_plazo tasaPlazo,'||
					 ' bdicred:sd_maecred cr, BDICRED:SD_MAECREDCRD CRD' ||
					 ' WHERE promoCred.empresa = ''001'''||
  					 ' AND promoCred.empresa = tasaPlazo.empresa' ||
					 ' AND promoCred.num_promo = tasaPlazo.num_promo'||
					 ' AND promoCred.plazo = tasaPlazo.plazo'||
					 ' AND promoCred.status = 2'||
					 ' AND promoCred.fecha <=''' ||to_char(pperiodo,'%m-%d-%Y')||''' ';					 
        LET v_sql2 = ' AND cr.num_credito = promoCred.num_credito '||
                     ' AND cr.empresa = ''001'' '||
                     ' AND cr.campo_trab3= '''' '||
					 ' and cr.status_cred in (''AA'',''BA'',''BT'') ' ||
                     ' and Crd.empresa = ''001'' ' ||
                     ' and crd.num_credito = promoCred.num_sol_prestamo '||
                     --' and crd.status_cred in (''AA'',''BA'',''BT'') '||
                     ' INTO TEMP tmpCredisoluciones WITH NO LOG; ' ||
                     '  SELECT amortCred.capital_status, sdoHist.empresa, sdoHist.num_credito, '||
                     '  sdoHist.sdo_capital, tmpCred.fecha, maeAnexo.prox_fecha_pago, '||
					 ' (CASE 	WHEN tmpCred.num_promo = 1 THEN ''CREDISOLUCIONES FOLIO: '' || tmpCred.num_sol_prestamo '||
                     ' WHEN tmpCred.num_promo = 4 THEN ''CREDISOLUCIONES FOLIO: '' || tmpCred.num_sol_prestamo '||
                     '  WHEN tmpCred.num_promo = 7 THEN ''CREDISOLUCIONES FOLIO: '' || tmpCred.num_sol_prestamo'|| 
                     ' END) concepto, amortCred.capital_mto_cuota, tmpCred.tasa  '||
                     ' FROM "informix".sd_maesdoscrd sdoHist, tmpCredisoluciones tmpCred,  ';
        LET v_sql3 = ' "informix".sd_maecredanexocrd maeAnexo, "informix".sd_amortiza_creditocrd amortCred'||                
				'  WHERE sdoHist.num_credito = tmpCred.num_sol_prestamo ' || 
        		'  AND	tmpCred.num_sol_prestamo = maeAnexo.num_credito '|| 
            	'  AND amortCred.num_credito = tmpCred.num_sol_prestamo ' ||
                '  AND amortCred.FECHA_CUOTA> ''' ||to_char(pperiodo,'%m-%d-%Y')||''''||                
				'  AND amortCred.capital_status = ''3'''||
        		'  INTO TEMP tmpSaldosCred WITH NO LOG; ' || 
            	'  SELECT amortCred.num_credito, COUNT(amortCred.fecha_cuota) numero_cuotas '||                
				' FROM "informix".sd_amortiza_creditocrd amortCred, tmpCredisoluciones tmpCred  '||
                '  WHERE amortCred.empresa = ''001'' ' ||        
                ' AND amortCred.NUM_CREDITO = tmpCred.num_sol_prestamo '||
                ' AND amortCred.fecha_cuota <= CASE WHEN tmpCred.diasmes <= DAY(TODAY-1) THEN '||
                ' MDY(MONTH(TODAY-1), tmpCred.diasmes, YEAR(TODAY-1)) ELSE DATE(TODAY-1) END '||			
                ' GROUP BY amortCred.num_credito ' ;
        LET v_sql4 = ' INTO TEMP tmpCrediPagos WITH NO LOG; '||				                
				' INSERT INTO cred_sol '||
				' (fecha_emision, num_credito, num_promo,num_sol_prestamo, folio_suc, plazo, diasmes,fecha, '||
				' tasa,sdo_capital,prox_fecha_pago, concepto,capital_mto_cuota,numero_cuotas, secuencia, nlinea)';
		LET v_sql5 = ' SELECT '''||to_char(pperiodo,'%m-%d-%Y')||''', tcs.num_credito, NVL(tcs.num_promo,0),'||   
				' NVL(tcs.num_sol_prestamo,''''), NVL(tcs.folio_suc,''''),NVL(tcs.plazo,0),'||
				' NVL(tcs.diasmes,0), NVL(tcs.fecha,DATE(1)), NVL(tcs.tasa,0), NVL(tsc.sdo_capital,0),'||
				' NVL(tsc.prox_fecha_pago,DATE(1)),NVL(tsc.concepto,''''), NVL(tsc.capital_mto_cuota,0),'||
				' NVL(tcp.numero_cuotas,0),1,1 FROM tmpCredisoluciones tcs, tmpSaldosCred tsc, tmpCrediPagos tcp'||
				' WHERE tcs.num_sol_prestamo = tsc.num_credito '||
				' AND tcs.num_sol_prestamo = tcp.num_credito ; " >'|| v_ruta||'queryCRESOL.sql';					
				
        LET v_sql = Trim(v_sql1) || ' ' || Trim(v_sql2) || ' ' ||Trim(v_sql3)|| ' ' ||Trim(v_sql4)|| ' ' ||Trim(v_sql5);
        system v_sql;
		
        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryCRESOL.sql";
        system v_sql;
		
				
		foreach 
		   select num_credito 
		     into vNumCredito
			from cred_sol
			group by num_credito
			
			let VSecuencia = 1;	
			
			Foreach 
			  select num_sol_prestamo
		        into Vnum_solpres
			   from cred_sol
			   where num_credito = vNumCredito
			   
			  update cred_sol 
			    set secuencia = VSecuencia
			  where fecha_emision = pperiodo
			    and num_credito = vNumCredito
                and num_sol_prestamo =	Vnum_solpres;
				
			  let VSecuencia = VSecuencia +1;	
			end foreach;	
		end foreach;  		
		
		LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descargaCredisolucion.unl' ||
		             ' SELECT *  FROM cred_sol " > '||v_ruta ||'queryCredisolucion.sql';
		
		-- SE EJECUTA ARCHIVO DE QUERY PARA OBTENER LA INFORMACION
		LET v_sql = Trim(v_sql1);
		SYSTEM v_sql;
		
		LET v_sql = "dbaccess bdicred "||v_ruta||"queryCredisolucion.sql";
		SYSTEM v_sql;


		-- SE COPIA EL ARCHIVO DE DESCARGA A UNO NUEVO
		LET v_sql = '';
		LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaCredisolucion.unl'||" >"||v_ruta||'descargaCredisolucion1.unl';
		SYSTEM v_sql;

		-- SE BORRA EL ARCHIVO DE DESCARGA
		LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'descargaCredisolucion.unl';
		SYSTEM v_sql;

		-- SE COPIA LA INFORMACION DEL ARCHIVO DE DESCARGA AL NUEVO ARCHIVO DE CREDISOLUCION
		LET v_sql = '';
		LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaCredisolucion1.unl'||" > " ||v_ruta||'Edocta_Credisolucion'||'.unl';
		SYSTEM v_sql;

		-- BORRA ARCHIVO DE DESCARGA
		LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'descargaCredisolucion1.unl';
		SYSTEM v_sql;  

		-- SE BORRA ARCHIVO QUERY
		LET v_sql = '';
		LET v_sql = "rm "||v_ruta||'queryCredisolucion.sql';
		--SYSTEM v_sql;  
		
		-- ELIMINACION DE TABLAS
		DROP TABLE "informix".cred_sol;*/
			
		--Tipo 2   >  DESCARGA Edocta_direcciones
		ELIF pTipo = 2 THEN

        -----------------DESCARGA DIRECCIONES-------------------------------------------------------------
        LET v_sql1 = ' echo " UNLOAD TO '||v_ruta||'descargaDirecCred.unl' ;
        LET v_sql2 = ' SELECT  numcte FROM bdicred:sd_maecred  WHERE empresa  = ''001'' and  status_cred in (''AA'',''BA'',''BT'',''FF'',''E1'',''E2'',''E3''); ' --;
        		|| ' create temp table sd_CreditosDir (numcte char(20)) with no log ;' --;
            	|| ' create index CreditosIX on sd_CreditosDir(numcte);' --;
                ||	' load from '||v_ruta||'descargaDirecCred.unl insert into sd_CreditosDir;' --;
            	||	' UNLOAD TO '||v_ruta||'DireccionCred.unl ' --;
                ||	' SELECT   ''001'', a.numcte, Trim(b.numeroextcalle) , Trim(b.numerointcalle) ,  b.cod_postal,	' --;
                || ' b.entre_calles , b.observaciones,' --;
            	|| ' b.numerociudad,  b.numerocolonia, ' --;
                ||	' b.numerocalle,  b.estado' --;
        		||	' FROM sd_CreditosDir a, ' --;
            	|| ' bdinteg:si_direcciones_actual b ' --;
                || ' WHERE a.numcte = b.numcte ' --;
                || ' and  b.tipo_dir = 1; ';
        LET v_sql3 = 'create temp table direccioneEdo (' --;
            || ' empresa char(3),' --;
            || ' numcte char(20),' --;
            || ' numeroextcalle 	CHAR(10),' --;
            || ' numerointcalle 	CHAR(10),' --;
            || ' cod_postal     	CHAR(5),' --;
            || ' entre_calles   	CHAR(40),' --;
            || ' observaciones  	CHAR(80),' --;
            || ' numerociudad   	SMALLINT,' --;
            || ' numerocolonia  	INTEGER,' --;
            || ' numerocalle    	INTEGER,' --;
            || ' estado         	CHAR(2)' --;
            || ' ) with no log;' --;
            || ' create index diredoc on direccioneEdo( numcte);'  --;
            || ' load from '||v_ruta||'DireccionCred.unl insert into direccioneEdo;' --;
            || ' update statistics medium for table direccioneEdo; ' --;
            || ' UNLOAD TO '||v_ruta||'descargaDIR.unl ';	 
        --LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descargaDIR.unl';
        LET v_sql4 = ' SELECT  a.empresa, a.numcte, Trim(b.numeroextcalle) , Trim(b.numerointcalle) , '||
                ' b.cod_postal,	b.entre_calles , b.observaciones,b.numerociudad,'||
                '  b.numerocolonia, zon.nombrezona,	zon.centro, zon.jefegrupozona,zon.supervisorzona,'||
                ' zon.numerociudadcoppel, zon.numerocoloniacoppel, b.numerocalle,'||
                ' Trim(ca.nombrecalle) 	,ci.nombreciudad, b.estado, es.nombre, '||
                ' Trim(nvl(cte.nombre1,'''')) || '' '' ||Trim(nvl(cte.nombre2,'''')) || '' '' || '||
                ' Trim(nvl(cte.apell_paterno,'''')) || '' '' ||Trim(nvl(cte.apell_materno,'''')), NVL(cte.rfc, cte.rfc_alterno), NVL(SUBSTR(YEAR(cte.fecha_alta), 3, 2),''''), '||
                ' TRIM(NVL(estado_civil,'''')), nvl(substr(TRIM(habita_en),1,1), ''P''), TRIM(NVL(sexo,'''')), '||
    			' NVL(SUBSTR(YEAR(fecha_nac), 3, 2),'''')';
        LET v_sql5=' FROM bdicred:sd_maecred a, bdinteg:si_cliente cte, bdinteg:si_ctepf pf '||
         		' left outer join direccioneEdo b on (pf.numcte = b.numcte ) '||    --bdicred:sd_maesdoshist sdo,
                ' join bdinteg:si_estados es on (es.pais = ''001'' and es.estado = b.estado ) '||
                ' left outer join bdinteg:si_catcalles ca on (b.numerocalle = ca.numerocalle) '||
                ' left outer join bdinteg:si_catzonas zon on (b.numerociudad = zon.numerociudad and b.numerocolonia = zon.numerocolonia) '||
            	' left outer join bdinteg:si_catciudades ci on (b.numerociudad = ci.numerociudad) '||
                ' WHERE a.empresa  = ''001'' and  a.numcte = cte.numcte  '|| 
                ' and cte.numcte = pf.numcte ' ||
                --' and cte.numcte = b.numcte ' ||
                --' and b.tipo_dir=''1'' '
                ' and a.status_cred in (''AA'',''BA'',''BT'',''FF'',''E1'',''E2'',''E3'') " >' ||v_ruta|| 'queryDIR.sql ';
			 	 --' and sdo.fecha = '''||to_char(pperiodo,'%m-%d-%Y')|| ''' " > query.sql';

        LET v_sql = v_sql1||v_sql2||v_sql3||v_sql4||v_sql5;

        system v_sql;
        LET v_sql = "dbaccess bdicred "|| v_ruta||"queryDIR.sql";
        system v_sql;

        LET v_sql = '';
        LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaDIR.unl'||" >"||v_ruta||'descargaDIR1.unl';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaDIR.unl ';
        SYSTEM v_sql;

        LET v_sql = '';
        --LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaDIR1.unl'||" > " ||v_ruta||'Edocta_direcciones'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'.unl';
        LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaDIR1.unl'||" > " ||v_ruta||'Edocta_direcciones'||'.unl';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaDIR1.unl '; -- queryDIR.sql';
        SYSTEM v_sql;
	  
        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'DireccionCred.unl '; -- queryDIR.sql';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'queryDIR.sql '; -- queryDIR.sql';
        SYSTEM v_sql;
	  
        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaDirecCred.unl '; -- queryDIR.sql';
        SYSTEM v_sql;
  
        /*LET v_sql = '';
        LET v_sql = " gzip " || v_ruta||'Edocta_direcciones'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'.unl ';
        SYSTEM v_sql;*/
    ELIF pTipo = 3 THEN
        -----------------DESCARGA SALDOS-------------------------------------------------------------
        LET v_sql1 = ' echo "UNLOAD TO '||v_ruta||'descargaSDO.unl ';
        LET v_sql2 = ' select sdo.fecha, cre.empresa, cre.num_credito, cre.numcte, cre.num_producto, tar.num_tarjeta, cre.fecha_apertura,  '||
                ' cre.sucursal, scr.ingreso_mensual,cre.status_cred, cre.tasa_interes,sdo.monto_otorgado,cre.tasa_moratorios, '||
                ' monto_vencido, mto_venc_trasp,sdo_cap_insoluto, sdo_retenido, sdo_acum_mes_cap,dias_acum_cap, '||
                ' int_tra_no_exig,sdo_moratorio,sdo_contab_mora,monto_financiado,mto_fin_ven_trasp, mto_venc_int Iva_Int_vdo, ';
        LET v_sql3 = ' anx.prox_fecha_pago, monto_ult_convenio, fecha_ult_convenio, decode(cumplio_convenio,''1'',''S'',''0'',''N'', cumplio_convenio ) , '||
                ' ind.fecha_ultima_compra,  ( case when sdo.sdo_cap_insoluto > 0 then sdo.sdo_int_anticip else 0 end ) interes_debe, ' || 
        		' amor.iva_debe ,  '|| 
            	' ind.fecha_ultimo_pago, today fecha_primer_vencido, sdo.act ' ||
                ' from bdicred:sd_maecred cre, bdicred:sd_maecredanexo anx, bdicred:sd_maesdoshist sdo , '||			
                ' bdisolic:ss_resum_scor_fin scr, bdicred:sd_amortiza_credito amor, bdicred:sd_indicador_cred ind '||			            
        		' left join bdicred:sd_tarjeta tar on (ind.empresa = tar.empresa  and ind.num_credito = tar.num_credito '||
            	' and secuencia = ( select max(secuencia) from bdicred:sd_tarjeta where empresa = ''001'' and empresa = tar.empresa '||
                ' and num_credito = tar.num_credito and tipo_tarjeta = ''T''  ) ) ' ||
                ' where cre.empresa = anx.empresa ';
        LET v_sql4 = ' and cre.num_credito = anx.num_credito '||		
                ' and sdo.fecha  ='''|| to_char(pperiodo,'%m-%d-%Y') || ''''||
                ' and cre.empresa = sdo.empresa '||
                ' and cre.num_credito = sdo.num_credito '||			
                ' and cre.empresa = scr.empresa '||
                ' and cre.num_credito = scr.num_solicitud '||
                ' and cre.empresa = ind.empresa '||
                ' and cre.num_credito = ind.num_credito '||	
                ' and cre.empresa  = amor.empresa  '||
                ' and cre.num_credito  = amor.num_credito '||
                ' and amor.fecha_cuota = '''|| to_char(pperiodo,'%m-%d-%Y') || ''' " >'|| v_ruta||'querySDO.sql';

        LET v_sql = v_sql1 || v_sql2 || v_sql3|| v_sql4;

        system v_sql;
        LET v_sql = "dbaccess bdicred "|| v_ruta||"querySDO.sql";
        system v_sql;

        LET v_sql = '';
        LET v_sql = "sed 's/|$//g' "||v_ruta||'descargaSDO.unl'||" >"||v_ruta||'descargaSDO1.unl';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaSDO.unl';
        SYSTEM v_sql;

        LET v_sql = '';
        --LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaSDO1.unl'||" > "||v_ruta||'Edocta_Saldos'||LPAD(DAY(pperiodo),2,'0')||LPAD(MONTH(pperiodo),2,'0')||LPAD(YEAR(pperiodo),4,'0')||'.unl';
        LET v_sql = "sed 's/" || '"' ||  "//g' "||v_ruta||'descargaSDO1.unl'||" > "||v_ruta||'Edocta_Saldos'||'.unl';
        SYSTEM v_sql;

        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'descargaSDO1.unl ';
        SYSTEM v_sql;
        LET v_sql = '';
        LET v_sql = "rm "||v_ruta||'querySDO.sql ';
        SYSTEM v_sql;
	
    END IF;

    --CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cod_ret, cMensajeRet, '03') RETURNING cCodRetBit;

END;

RETURN cod_ret;

END PROCEDURE;