CREATE PROCEDURE "informix".sp_actualiza_saldos_admin_tco() 
RETURNING char(6), char(80);

--  execute PROCEDURE "informix".sp_actualiza_saldos_admin_tco();
DEFINE cCod_ret             CHAR(6);
DEFINE sql_err				INTEGER;
DEFINE isam_err				INTEGER;
DEFINE error_info			CHAR(80);
DEFINE cMensaje				CHAR(150);
DEFINE vhora				CHAR(8);
DEFINE max_fch_eje          DATE;
DEFINE vlNumInsert          INTEGER;
DEFINE vnumcte              CHAR(20);
DEFINE vnum_credito         CHAR(20);
DEFINE vpagos_vencidos      INTEGER;
DEFINE vciudad              CHAR(20);
DEFINE vestado              CHAR(20);
DEFINE vtelefono_celular    CHAR(13);
DEFINE vnumcampania         SMALLINT;
DEFINE vproducto            CHAR(4);
DEFINE vNombre1				CHAR(26);
DEFINE vNombre2				CHAR(26);
DEFINE vApellidoP			CHAR(26);
DEFINE vApellidoM			CHAR(26);
DEFINE v_mto_venc_trasp     DECIMAL(18,2);
DEFINE v_monto_financiado   DECIMAL(18,2);
DEFINE v_sdo_retenido       DECIMAL(18,2);
DEFINE v_sdo_cap_insoluto   DECIMAL(18,2);
DEFINE vinteres             DECIMAL(18,2);
DEFINE viva_interes         DECIMAL(18,2);
DEFINE vmoratorio           DECIMAL(18,2);
DEFINE viva_moratorio       DECIMAL(18,2);
DEFINE vpago_minimo_total   DECIMAL(18,2);
DEFINE vsaldo_total         DECIMAL(18,2);
DEFINE v_sdo_venc_int_mora  DECIMAL(18,2);
DEFINE v_pago_min_sin_vdo   DECIMAL(18,2);
DEFINE cCodRet              CHAR(6);
DEFINE P_COD_RET            CHAR(06);
DEFINE vempresa             CHAR(3);
DEFINE cproceso             CHAR(4);
DEFINE vsituacion           CHAR(1);
DEFINE vcausa               SMALLINT;
DEFINE vinstruccion         CHAR(1);

DEFINE	vSdoTotal1			DECIMAL(18,2);
DEFINE	vMtoVencido1		DECIMAL(18,2);
DEFINE	vSdoTotal2			DECIMAL(18,2);
DEFINE	vMtoVencido2		DECIMAL(18,2);
DEFINE	vMensualidad		DECIMAL(18,2);
DEFINE dtFechaHoy           DATE;
DEFINE sNumCampania         SMALLINT;
DEFINE cNumProducto         CHAR(4);
DEFINE dtfecha_ant          DATE;
DEFINE iCel                 SMALLINT;
DEFINE vpago_vencido		DECIMAL(18,2);
DEFINE vmora                SMALLINT;
DEFINE vvalor_numerico      INTEGER;
DEFINE vcontador            INTEGER;
DEFINE vlimit               INTEGER;
DEFINE vnum                 INTEGER;
DEFINE vnum1                INTEGER;
--define vcount	integer;
DEFINE iCount_TCO_MORA1S     INTEGER; --A.L.L.
DEFINE iCount_TCO_MORA2S     INTEGER; 
DEFINE vvalor               SMALLINT;
DEFINE i                    INTEGER;
DEFINE num                  SMALLINT;
DEFINE vCampoBaja           CHAR(10);
DEFINE P_MENSAJE            CHAR(80);
DEFINE iCuentasProcesadas               INTEGER;
DEFINE iCuentasExcluidasXSdosVencidos   INTEGER;
DEFINE iCuentasExcluidasXCel            INTEGER;
DEFINE iCuentasExcluidasXSitEspecial    INTEGER;
DEFINE dFechaCarLinea       DATE;
DEFINE iCuentasProcesadas_TCO_MORA1S     INTEGER;
DEFINE iCuentasProcesadas_TCO_MORA2S     INTEGER;
DEFINE iCuentasExcluidasXCel_TCO_MORA1S  INTEGER;
DEFINE iCuentasExcluidasXCel_TCO_MORA2S  INTEGER;

--SET DEBUG FILE TO '/informix/ALL/AMBIENTE_ORO/sp_actualiza_saldos_admin.out';
--TRACE ON;

LET cCod_ret        = '000000';
LET P_COD_RET       = "000000";
LET sql_err         = 0;
LET isam_err        = 0;
LET error_info      = '';
LET cMensaje        = 'PROCESO EXITOSO';
let P_MENSAJE       = 'El proceso de las campañas SMS MORAS TCO se realizó correctamente.';
LET vempresa        = '001';
LET cproceso        = '0013';
LET dtFechaHoy      = '';
LET dtfecha_ant     = '';
LET vmora           = 0;
LET vvalor_numerico = 0;
LET vcontador       = 0;
LET vlimit          = 0;
LET vnum            = 0;
LET vnum1           = 0;
--	let vcount = 0;
LET iCount_TCO_MORA1S = 0;
LET iCount_TCO_MORA2S = 0;
LET i           = 0;
LET num         = 0;
LET vCampoBaja  = '';
LET iCuentasProcesadas               = 0;
LET iCuentasExcluidasXSdosVencidos   = 0;
LET iCuentasExcluidasXCel            = 0;
LET iCuentasExcluidasXSitEspecial    = 0;
LET dFechaCarLinea = date(1); 
LET cNumProducto	= '';
LET iCuentasExcluidasXCel_TCO_MORA1S = 0;
LET iCuentasExcluidasXCel_TCO_MORA2S = 0;
LET iCuentasProcesadas_TCO_MORA1S    = 0;
LET iCuentasProcesadas_TCO_MORA2S    = 0;
LET vnum_credito			  = '';


    BEGIN        
        ON EXCEPTION SET sql_err, isam_err, error_info
        LET cCod_ret = sql_err;
        LET P_COD_RET= sql_err;
        LET P_MENSAJE = error_info;
        LET cMensaje = vnum_credito||'  '||error_info;
        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '02')
        RETURNING cCodRet;
        RETURN P_COD_RET,P_MENSAJE;
    END EXCEPTION;

 	 CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '01') RETURNING cCodRet;

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO dirty READ;

    LET vlNumInsert =0;
	LET vSdoTotal1			=0;
	LET vMtoVencido1		=0;
	LET vSdoTotal2			=0;
	LET vMtoVencido2		=0;
	LET vMensualidad		=0;
	LET iCel =0;
	LET vpago_vencido 		=0;

    SELECT NVL(fecha_hoy ,today), fecha_ant
    INTO dtFechaHoy, dtfecha_ant
    FROM bdicred:"informix".sd_fechas
    WHERE empresa = '001';	

--let dtFechaHoy = mdy('02','26','2015');
--let dtfecha_ant = mdy('02','25','2015');
	
	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;

 -- LET dtFechaHoy = '12-26-2012';  --- PARA PRUEBA SOLAMENTE
			
FOREACH
	select valor_numerico into vvalor_numerico
	from bdicobranza:cb_param_campania
	where tipo_campania = 51
		and grupo_parametro = 'LATINIA'
		and num_parametro in (2,3)
	let vmora = vmora + 1 ;	
	
	--busca total de enviados y limir por tipo de mora
	select cuenta from bdimnsj:mnsjr_trx_batch where id_mensaje = 'TCO_MORA'||vmora||'S' into temp cuentas;
	if (vmora = 1) then
	select valor_numerico into vlimit from bdicobranza:cb_param_campania
		where tipo_campania = 51 and grupo_parametro = 'LATINIA' and num_parametro = 13; end if;
	if (vmora = 2) then
	select valor_numerico into vlimit from bdicobranza:cb_param_campania
		where tipo_campania = 51 and grupo_parametro = 'LATINIA' and num_parametro = 14; end if;

	select count(*) into vnum1 from bdimnsj:mnsjr_trx_batch where id_mensaje = 'TCO_MORA'||vmora||'S';
	let vnum = vvalor_numerico - vnum1;
	if(vnum1 < vvalor_numerico ) then	
		if (vnum > vlimit) then
			let vlimit = vlimit;
		else
			let vlimit = vvalor_numerico - vnum1;
		end if;	
	end if;
	
    if (vmora <= 2 )then 
        FOREACH
            SELECT mae.numcte,mae.num_credito,mas.mto_fin_ven_trasp, mae.num_producto    
            INTO vnumcte, vnum_credito, vpagos_vencidos, cNumProducto
            FROM bdicred:sd_maecred mae
            INNER JOIN bdicred:sd_maesdos mas ON mas.empresa=mae.empresa AND mas.num_credito=mae.num_credito AND mas.mto_fin_ven_trasp = vmora 
            WHERE mae.empresa = vempresa
                AND mae.num_producto = '8100' 
                AND mae.numcte NOT IN (SELECT numcliente FROM bdicobranza:"informix".cb_compac) -- que no tengan compromiso
                AND mae.num_credito NOT IN (select nvl(cuenta,'') FROM cuentas)
                AND campo_trab3 <> 'BAJA'

            LET iCuentasProcesadas = iCuentasProcesadas + 1;

            SELECT cl.fecha  
                ,cl.mto_fin_ven_trasp                                                         --- pagos vencidos
                ,(cl.sdo_capital +  cl.monto_vencido + cl.mto_venc_trasp + cl.cap_tras_no_venci + cl.moratorio + cl.interes_iva ) SdoTotal1
                ,(cl.monto_vencido + cl.mto_venc_trasp + cl.moratorio + cl.interes_iva) MtoVencido1,
                cl.mensualidad_actual,
                cl.monto_vencido + cl.mto_venc_trasp     	
            INTO dFechaCarLinea,
                 vpagos_vencidos, 
                 vsaldo_total, 
                 v_sdo_venc_int_mora,
                 vMensualidad,
                 vpago_vencido  
            FROM bdicred:"informix".sd_sdos_cartera_linea cl
            WHERE cl.num_credito = vnum_credito;

			IF dFechaCarLinea IS NULL OR dFechaCarLinea = '' THEN
               LET iCuentasExcluidasXSdosVencidos = iCuentasExcluidasXSdosVencidos + 1;
    		   CONTINUE foreach;
			END IF;

            let vtelefono_celular ='';	

            SELECT limit 1 d.telefono
                    INTO vtelefono_celular
                    FROM bdinteg:"informix".si_telefonos_actual d
                   WHERE d.numcte= vnumcte
                     AND d.tipo_tel= '2' and status_tel = 'A' and cofetel ='V' ;

			IF vtelefono_celular IS NULL OR vtelefono_celular = '' THEN	LET vtelefono_celular =''; END IF;

            SELECT  
                 b.numerociudad || '-' || TRIM(j.inicialciudad) Ciudad            --- ciudad
                ,j.numeroestado || '-' || TRIM(j.inicialestado) Estado            --- estado        
            INTO vciudad, vestado
            FROM bdinteg:"informix".si_direcciones_actual b , 
                 bdinteg:"informix".si_catciudades j
            WHERE b.numcte = vnumcte
                AND b.numerociudad = j.numerociudad
                AND b.tipo_dir = '1';

            SELECT nombre1,nombre2, apell_paterno,apell_materno
            INTO vNombre1,vNombre2,vApellidoP,vApellidoM
            FROM bdinteg:"informix".si_cliente
            WHERE numcte=vnumcte;

            LET vlNumInsert = vlNumInsert +1;

                LET iCel = LENGTH(vtelefono_celular) + 1 - 10;

                    IF ( LENGTH(vtelefono_celular) > 10 ) THEN
                       LET vtelefono_celular = SUBSTR(vtelefono_celular,iCel,10);
                    ELIF ( LENGTH(vtelefono_celular) < 10 ) THEN
                        LET vtelefono_celular =''; 
                    END IF;

                LET v_pago_min_sin_vdo =  nvl(vMensualidad,0);   --Mensualidad

                LET vpago_minimo_total = v_sdo_venc_int_mora  +  vMensualidad;  --- Pago minimo  
                LET vsituacion = NULL;
                LET vcausa     = NULL;

                SELECT {+INDEX(bdisitesp:"informix".se_ctessitespcte "informix".se_ctessitespcte_idx1)} FIRST 1 NVL(situacion, ''),  NVL(causa, 0)
                  INTO   vsituacion, vcausa
                FROM bdisitesp:"informix".se_ctessitespcte
                WHERE numcte = vnumcte;

                LET vinstruccion = 1;

                IF ( vsituacion <> '' AND vcausa <> 0 ) THEN   
                    SELECT FIRST 1 instruccion
                    INTO vinstruccion
                    FROM bdisitesp:"informix".se_situacionaccion
                    WHERE situacion= vsituacion
                        AND causa= vcausa
                        AND idaccion = 9
                        AND empresa = vempresa;
                END IF;
			
                IF (vinstruccion = 1) THEN				

                    if (vmora = 1) then
                        LET iCuentasProcesadas_TCO_MORA1S = iCuentasProcesadas_TCO_MORA1S + 1;

                        IF vtelefono_celular IS NULL OR vtelefono_celular = '' THEN 
                           LET iCuentasExcluidasXCel_TCO_MORA1S = iCuentasExcluidasXCel_TCO_MORA1S + 1;
                           CONTINUE foreach; 
                        END IF;

                        let iCount_TCO_MORA1S	= iCount_TCO_MORA1S +1;		
						call "informix".sp_inserta_info_rep_envios (vempresa,'SMS',25, vnum_credito, vnumcte, cNumProducto, today, vtelefono_celular, '','',vpago_minimo_total) returning P_COD_RET;
                    end if;
                    if (vmora = 2) then
                        LET iCuentasProcesadas_TCO_MORA2S = iCuentasProcesadas_TCO_MORA2S + 1;

                        IF vtelefono_celular IS NULL OR vtelefono_celular = '' THEN 
                           LET iCuentasExcluidasXCel_TCO_MORA2S = iCuentasExcluidasXCel_TCO_MORA2S + 1;
                           CONTINUE foreach; 
                        END IF;

                        let iCount_TCO_MORA2S	= iCount_TCO_MORA2S +1;		
						call "informix".sp_inserta_info_rep_envios (vempresa,'SMS',26, vnum_credito, vnumcte, cNumProducto, today, vtelefono_celular, '','',vpago_minimo_total) returning P_COD_RET;
                    end if;

                    call bdimnsj:"informix".sp_registra_evento (2, 'TCO_MORA'||vmora||'S' , vnumcte, vnum_credito,'', 2,
                                        '','','','','',vpago_minimo_total,0,0,0,0, '', '')RETURNING P_COD_RET;


                    let vcontador = vcontador + 1;
                ELSE
                    LET iCuentasExcluidasXSitEspecial = iCuentasExcluidasXSitEspecial + 1;
                END IF;                    

                LET vSdoTotal1			=0;
                LET vMtoVencido1		=0;
                LET vSdoTotal2			=0;
                LET vMtoVencido2		=0;
                LET vMensualidad		=0;					

                IF vlNumInsert = 5000 then 
                   LET vlNumInsert = 1;
                   update statistics medium for table bdicobranza:"informix".cb_info_administrativa;
                END IF;
--            END IF;

            if (vcontador = vlimit) then exit FOREACH; end if;

        END FOREACH;
    end if;

	if (vcontador >= 1) then 
        let i = 0;
        LET num = 0;
        FOR i in (1 to vvalor)
            insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1,importe1)
            select  2, 'TCO_MORA'||vmora||'S',numcte,current,apell_paterno,100
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
			let num = num + 10;
		end for
	end if;
		
		let vvalor_numerico	= 0; let vcontador = 0;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCodRet, 'Proceso TCO Mora '||vmora, '02')
        RETURNING cCodRet; 
	drop table cuentas;
END FOREACH;


         CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCO_MORA1S',iCuentasProcesadas_TCO_MORA1S,iCuentasExcluidasXCel_TCO_MORA1S) RETURNING cCodRet;

         CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCO_MORA2S',iCuentasProcesadas_TCO_MORA2S,iCuentasExcluidasXCel_TCO_MORA2S) RETURNING cCodRet;


--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campañas TCO_MORA1S y 2S : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    SMSs enviados MORA 1 : ' ||iCount_TCO_MORA1S;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'SMSs enviados MORA 2 : ' ||iCount_TCO_MORA2S;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por error saldos vencidos : ' ||iCuentasExcluidasXSdosVencidos;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel_TCO_MORA1S + iCuentasExcluidasXCel_TCO_MORA2S;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por situación especial : ' ||iCuentasExcluidasXSitEspecial;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cproceso, cCod_ret, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, cProceso, cCod_ret, cMensaje, '03')
    RETURNING cCodRet;

     if cCodRet != '000000' then
        let P_COD_RET = cCodRet;
        let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
        RETURN P_COD_RET,P_MENSAJE;
     end if;

	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.
END
END PROCEDURE
DOCUMENT 
'DESCRIPCION: Se actualiza procedimiento debido a un cambio en la estructura de la tabla cb_info_administrativa y si elimina el borrado de la ',
'tabla antes de la inserccion debido a que se encuentran implicadas otras campañas en la tabla.',
'AUTOR : Maria Elena Angulo Aispuro ',
'FECHA : 25/05/2011',
'BD    : BDICOBRANZA',
'Version: 20110525.1330',
'20110922 Optimización y conjuntar queries usados en sp_targetphone. Autor: Faviola Martínez J.',
'20120504 Cambio de fuente de obtención de saldos. Autor: Marco A. Campos',
'20120516 Que en la condición de fecha de sd_sdos_cartera_linea se compare con la fecha dia anterior. Autor: Marco A. Campos';

CREATE PROCEDURE "informix".sp_mail_compsinadeudo_tco(pempresa char (3), pfechacorte date)
returning 
VARCHAR(6)  AS codigo_retorno,
CHAR(80)    AS mensaje_retorno;

--execute procedure "informix".sp_mail_compsinadeudo_tco('001',today)
DEFINE pnumcredito   char(20);
DEFINE pnumcte		 char(20);
DEFINE pemail		 char (60);
DEFINE pfechacompac  DATE;
DEFINE pimporte      DECIMAL(18,2);
DEFINE pfechapago    DATE;
DEFINE pflagpago     SMALLINT;
DEFINE pfechahoy     date;
DEFINE vnumtarjeta 	 CHAR(20);
define pparam		 smallint;
DEFINE v_sdo_venc_int_mora 	 DECIMAL(18,2);
DEFINE vpago_min_sin_venc	 DECIMAL(18,2);
DEFINE vpago_venc 			 DECIMAL(18,2);
DEFINE vsaldo_total 		 DECIMAL(18,2);
DEFINE vpago_min 			 DECIMAL(18,2);

DEFINE cProceso  char(4);
DEFINE cCod_ret  char (06);
DEFINE cMensaje  char (100); 

DEFINE pfechaarmada date; 

DEFINE SQL_ERR            INTEGER;
DEFINE ISAM_ERR           INTEGER;
DEFINE ERROR_INFO         VARCHAR(80);
DEFINE P_COD_RET          VARCHAR(6);
DEFINE P_MENSAJE          VARCHAR(80);
define vapell_paterno 		char(30);
define iCount_TCO_COMPAG  integer; 
define vvalor smallint;
define i integer;
define num smallint;
define iCuentasProcesadas  integer;
define iCuentasExcluidasXMail integer;
define cNumProducto 	char(04);
define cCodRet 		char(06);


LET vnumtarjeta = '';
let pparam =0;
let P_COD_RET   = '000000';
let P_MENSAJE   ='El proceso de las campañas EMAIL TDC COMP SIN ADEUDO se realizó correctamente.';
LET v_sdo_venc_int_mora   =0;
LET vpago_min_sin_venc	  =0;
LET vpago_venc 			  =0;
LET vsaldo_total 		  =0;
LET vpago_min 			  =0;
let vapell_paterno = '';
let iCount_TCO_COMPAG = 0; 
let i = 0;
LET num = 0;		
let iCuentasProcesadas  = 0;
let iCuentasExcluidasXMail = 0;
let cNumProducto = '';
let cCod_ret = '';
let cMensaje = '';
let cproceso = '0015';
let cCodRet 	= '';


--SET DEBUG FILE TO "/informix/ALL/TCOro/comp_sinaduedo.out";
--TRACE ON;
BEGIN 
  
ON exception SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, P_COD_RET, P_MENSAJE, '02')
        RETURNING P_COD_RET;

        LET P_COD_RET = SQL_ERR;
       RETURN P_COD_RET,P_MENSAJE;
END exception;

    CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '01')
        RETURNING P_COD_RET;

    if P_COD_RET != '000000' then
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;
	
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
		
		let P_COD_RET = cCod_ret;
        let P_MENSAJE = cMensaje;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '02') RETURNING cCod_Ret;
		RETURN P_COD_RET,P_MENSAJE;
	END IF;
	
	IF NVL (pfechacorte, '') = '' THEN
        LET cCod_Ret= '104008';        
        SELECT descripcion
        INTO cMensaje
        FROM cb_errores
        WHERE origen = 3
        AND codigo_error = cCod_Ret;
	
       IF cMensaje IS NULL THEN 
            LET cMensaje = ""; 
        END IF;

		let P_COD_RET = cCod_ret;
        let P_MENSAJE = cMensaje;

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '02') RETURNING cCod_Ret;
        RETURN P_COD_RET,P_MENSAJE;
	END IF;

    Select Fecha_Hoy
        Into pfechahoy
    From bdicred:sd_fechas
    Where empresa = pempresa ;
	
	set isolation to dirty read;
	SELECT valor_numerico into pparam
	  FROM cb_param_campania
	  WHERE tipo_campania =1
	    and grupo_parametro ='EMAIL'
		and num_parametro = 1;	
		
			select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
		
  	let pfechaarmada = date (pfechacorte) -  1 units day;

	set isolation to dirty read;
	
	let i = 0;
		LET num = 0;
	FOR i in (1 to vvalor)
	insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,estatus, fecha_hora_registro,string1,importe1,fecha1,fecha2)
		select  1, 'TCO_COMPAG',numcte,1,current,apell_paterno,100,current,current
		from bdinteg:si_cliente
        where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param in (57));
			let num = num + 10;
	end for
		
	foreach 
	
    SELECT a.numcte,a.num_credito, d.importe, d.fecha_compac,d.fecha_insert, d.flag_pago, a.num_producto
        INTO pnumcte,pnumcredito, pimporte, pfechacompac,  pfechapago, pflagpago, cNumProducto
    FROM bdicred:sd_maecred a, bdicobranza:cb_compac_his d
    WHERE a.empresa = d.empresa  and a.num_credito =d.numcuenta and a.num_producto = '8100' and a.status_cred ='AA'
	    AND d.fecha_insert = pfechaarmada
		AND d.flag_pago = 1 
		AND nvl(d.imp_pagado,0) > 0
		and d.importe <= d.imp_pagado
			
	let iCuentasProcesadas = iCuentasProcesadas + 1;
	
	select limit 1 cte.correo_elec into pemail 
	from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = pnumcte and cte.status_correo ='A'
							and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
	where empresa  = '001' and numcte = pnumcte and status_correo ='A');

	if pemail is null or pemail = '' then 
       let iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
       continue foreach; 
    end if;
	   
		select LIMIT 1 t.num_tarjeta into vnumtarjeta
		from bdicred:sd_tarjeta t
		where t.empresa = '001'
		and t.num_credito = pnumcredito
		and t.secuencia = (select max(tar.secuencia)
                    from bdicred:sd_tarjeta tar
                    where tar.empresa = '001'
                    and tar.num_credito = pnumcredito
                    and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
        and t.tipo_tarjeta ='T'  and t.status_tar = 'A';

		let iCount_TCO_COMPAG = iCount_TCO_COMPAG +1;
		call bdimnsj:"informix".sp_registra_evento (1, 'TCO_COMPAG' , pnumcte, pnumcredito,vnumtarjeta, 2,
							'','','','','',pimporte,0,0,0,0, pfechacompac, pfechapago  )RETURNING P_COD_RET;

		call "informix".sp_inserta_info_rep_envios (pempresa,'EMAIL',1026, pnumcredito, pnumcte, cNumProducto, today,pemail, '','',pimporte) returning P_COD_RET;
	
	end foreach

	CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCO_COMPAG',iCuentasProcesadas,iCuentasExcluidasXMail) RETURNING P_COD_RET;
	
	--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña TCO_COMPAG : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados : ' ||iCount_TCO_COMPAG;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error email : ' ||iCuentasExcluidasXMail;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control
	

        CALL bdicobranza:"informix".sp_inserta_bitacora_cob(pempresa, cProceso, cCod_ret, cMensaje, '03')
    RETURNING P_COD_RET;

    if P_COD_RET != '000000' then
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

end
  RETURN P_COD_RET,P_MENSAJE;
END PROCEDURE;