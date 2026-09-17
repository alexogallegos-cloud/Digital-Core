CREATE PROCEDURE "informix".sp_mail_primerconsumo_pln()
RETURNING 	
CHAR(06)  AS codigo_retorno,
CHAR(150)  AS mensaje_retorno;

--EXECUTE PROCEDURE "informix".sp_mail_primerconsumo_pln();

------------------------------------------------------------------------------------
--Maria Elizabeth Anzures Ibarguen
--2012-05-09
--crea archivo con datos que se muestran en pantalla cat con cliente con mora 1

----DATOS QUE VAN EN LA TABLA
DEFINE vnumcte		char(20);
define vnumcredito	char(20);
define vnumtarjeta	char(20);
define vimporte		decimal(18,2);
define vfecha		date;
define vfechas		date;

---DECLARACIONES
DEFINE cNumCta			CHAR(20);
DEFINE dCapMtoCuota		DECIMAL(18,2);
DEFINE cDiasAnticipados	DECIMAL(18,2);
DEFINE cCel				CHAR(13);
DEFINE cEstado			CHAR(2);
DEFINE cCiudad			CHAR(3);
DEFINE cNombre1			CHAR(26);
DEFINE cNombre2			CHAR(26);
DEFINE cApellPat		CHAR(26);
DEFINE cApellMat		CHAR(26);
DEFINE cTipoRed			CHAR(10);
DEFINE cCodRet2			CHAR(6);
DEFINE cNumCarrier		CHAR(3);
DEFINE cSituacion		CHAR(1);
DEFINE iCausa			INTEGER;
DEFINE cNomEstado 		CHAR(20);
DEFINE cNomCiudad 		CHAR(20);
DEFINE iPagoVenc 		INTEGER;
DEFINE vSdoTotal1  		DECIMAL(18,2);
DEFINE vMtoVencido1  	DECIMAL(18,2);
DEFINE vMensualidad 	DECIMAL(18,2);
DEFINE vSdoTotal2  		DECIMAL(18,2);
DEFINE vMtoVencido2 	DECIMAL(18,2);
DEFINE vsaldo_total 	DECIMAL(18,2);
DEFINE v_sdo_venc_int_mora  DECIMAL(18,2);
DEFINE v_pago_min_sin_vdo   DECIMAL(18,2);
DEFINE vpago_minimo_total   DECIMAL(18,2);
define vpago 			DECIMAL(18,2);
DEFINE Vfecha_apertura 	DATE;
DEFINE iCel 			SMALLINT;
DEFINE vdia_pago 		smallint;
DEFINE vmail 			char(100);
DEFINE vvalor_numerico	INTEGER;
DEFINE vtotal1			INTEGER;
DEFINE vtotal2			INTEGER;
DEFINE vtotal			INTEGER;
define vregistrostotal	integer;
define vfecha1 			date;
define vfecha2 			date;
define vimporte1		DECIMAL(18,2);
define vimporte2 		DECIMAL(18,2);     
DEFINE cCodRet        	CHAR(6); 

---VARIABLES PARA CAPTURAR ERRORES
DEFINE SQL_ERR          INTEGER;
DEFINE ISAM_ERR         INTEGER;
DEFINE ERROR_INFO       VARCHAR(80);
DEFINE P_COD_RET     	VARCHAR(6);
DEFINE P_MENSAJE     	VARCHAR(150);
DEFINE vproceso			CHAR (4);
DEFINE cMensaje			CHAR(150);
DEFINE vpago_vencido	DECIMAL(18,2);
DEFINE vcontador		INTEGER;
define vpri_dia_mes		date;
define vapell_paterno 	char(30);
--define vcount 			INTEGER;
define iCount_TCP_PRIMER INTEGER; --A.L.L.
define iCount_TCP_PRIMES INTEGER; --A.L.L.
define vvalor           smallint;
define i                integer;
define num              smallint;
DEFINE iCuentasProcesadas     integer;
DEFINE iCuentasExcluidasXMail integer;
DEFINE iCuentasExcluidasXSdosVencidos integer;
DEFINE icuentasnopimerconsumo integer;
DEFINE dFechaCarLinea       date;
DEFINE iOtrasExclusiones    integer;
DEFINE vempresa             char(3);
DEFINE icuentasexcluidasxcel integer;
DEFINE iCuentasExcluidasxIndicador integer;

---INICIALIZACIONES
LET cNumCta				= '';
LET dCapMtoCuota		= 0;
LET	cDiasAnticipados	= 0;
LET cCel				= '';
LET cEstado				= '';
LET cCiudad				= '';
LET cNombre1			= '';
LET cNombre2			= '';
LET cApellPat			= '';
LET cApellMat			= '';
LET cTipoRed			= '';
LET cCodRet2			= '';
LET cNumCarrier			= '';
LET cSituacion			= '';
LET iCausa				= 0;
LET cNomEstado          = '';
LET cNomCiudad          = '';
LET iPagoVenc           = 0;
LET vSdoTotal1          = 0;
LET vMtoVencido1        = 0;
LET vMensualidad        = 0;
LET vSdoTotal2          = 0;
LET vMtoVencido2        = 0;
LET vsaldo_total        = 0;
LET v_sdo_venc_int_mora = 0;
LET v_pago_min_sin_vdo  = 0;
LET vpago_minimo_total  = 0;
let vpago               = 0;
LET iCel                = 0;
LET vdia_pago           = 0;
LET vpago_vencido       = 0;

let vnumcte     = '';
let vnumcredito = '';
let vnumtarjeta = '';
let vimporte	=0;
let vfecha		= date(1);
let vfechas		= date(1);

let SQL_ERR		= 0;
let ISAM_ERR	= 0;
let ERROR_INFO	= '';
let P_COD_RET	= '000000';
let cCodRet     = '000000';
let P_MENSAJE	= 'El proceso de las campañas PRIMER CONSUMO se realizó correctamente.';
let vproceso	= '0300';
let cMensaje	= '';
let vmail 		= '';
let vvalor_numerico	= 0;
let vtotal1			= 0;
let vtotal2			= 0;
let vtotal			= 0;
let vregistrostotal = 0;
let vcontador 		= 0;
let vfecha1 		= date(1);
let vfecha2 		= date(1);
let vimporte1		= 0;
let vimporte2 		= 0; 
let vpri_dia_mes = date(1);
let vapell_paterno = '';
--let vcount = 0;
let iCount_TCP_PRIMER = 0; --A.L.L.
let iCount_TCP_PRIMES = 0; --A.L.L.
let i = 0;
LET num = 0;
let iCuentasProcesadas      = 0;
let iCuentasExcluidasXMail  = 0;
let iCuentasExcluidasXSdosVencidos = 0;
let icuentasnopimerconsumo = 0;
let dFechaCarLinea = date(1);
let iOtrasExclusiones = 0;
let vempresa = '001';
let icuentasexcluidasxcel = 0;
let iCuentasExcluidasxIndicador = 0;

--Set debug file to 'sp_mail_primerconsumo_pln.out';
--trace on;

BEGIN

    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
        LET P_COD_RET = SQL_ERR;
        LET P_MENSAJE = ERROR_INFO;
		CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, P_MENSAJE, '02')RETURNING cCodRet;	
        RETURN P_COD_RET,P_MENSAJE;
    END EXCEPTION;


    CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '01')RETURNING cCodRet;	

    if cCodRet  != '000000' then
       let P_COD_RET = cCodRet;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

	select fecha_ant into vfecha from bdicred:sd_fechas where empresa = '001';

--temporal solo para pruebas	
--let vfecha = today;
--temporal solo para pruebas	

	let vpri_dia_mes = mdy(month(vfecha),day(1),year(vfecha));
    set isolation to dirty read;
	
--	DELETE FROM bdicobranza:cb_info_administrativa WHERE empresa ='001' and fecha_ejecucion <= today and num_campania = 16; 

	select length(valor) into vvalor
	from bdicobranza:cb_param where cod_param = 57;
	LET vvalor = vvalor / 9;
		
		
--------------------------------------------------------EMAIL y SMS------------------------------------------------------------------   
	FOREACH
		SELECT  a.numcte, a.num_credito, b.f_primer_compra,b.monto_primer_compra ,b.f_primer_disp, b.monto_primer_disp
				INTO vnumcte, vnumcredito,vfecha1,vimporte1,vfecha2,vimporte2--vimporte
		FROM bdicred:sd_maecred a, bdicred:sd_indicador_cred b 
		WHERE a.empresa = '001'
			and a.empresa = b.empresa
			and a.num_producto = '7000'
			and a.num_credito = b.num_credito			
			and (b.f_primer_compra = vfecha or b.f_primer_disp  = vfecha)

        LET iCuentasProcesadas = iCuentasProcesadas + 1;

--		if (vfecha1 is null or vfecha2 is null) then
		if (vfecha1 = vfecha or vfecha2 = vfecha) then
    		if (vfecha1 = vfecha and (vfecha2 is null or vfecha2 = date(0) or vfecha2 = date(1))) then
    			if (vfecha1 = vfecha) then let vimporte = vimporte1; end if;
            elif ((vfecha1 is null or vfecha1 = date(0) or vfecha1 = date(1)) and vfecha2 = vfecha) then
                if (vfecha2 = vfecha) then let vimporte = vimporte2; end if;
            else
                let iCuentasNoPimerConsumo = iCuentasNoPimerConsumo + 1;
                CONTINUE foreach;
            end if;
				
/*			select  apell_paterno into vapell_paterno
			from bdinteg:si_cliente where empresa = '001' and numcte = vnumcte ;*/
		  
			let vmail = '';
			select limit 1 cte.correo_elec into vmail 
			from  bdinteg:si_correos cte  where  cte.empresa ='001' and cte.numcte = vnumcte and cte.status_correo ='A'
			and cte.secuencia = (select max(secuencia) from bdinteg:si_correos 
				where empresa  = '001' and numcte = vnumcte and status_correo ='A');

            IF vmail IS NULL OR vmail = '' THEN 
                LET iCuentasExcluidasXMail = iCuentasExcluidasXMail + 1;
--                CONTINUE foreach; 
            END IF;

			SELECT limit 1 d.telefono
		    INTO cCel
		    FROM bdinteg:"informix".si_telefonos_actual d
		    WHERE d.numcte= vnumcte
		     AND d.tipo_tel= '2' and status_tel = 'A'; /* and cofetel ='V' ;*/--RQM 09 598"

            IF cCel IS NULL OR cCel = '' THEN 
                LET iCuentasExcluidasXCel = iCuentasExcluidasXCel + 1;
                CONTINUE foreach; 
            END IF;
	
			LET iCel = LENGTH(cCel) + 1 - 10;
    
			IF cCel <> '' then
				IF ( LENGTH(cCel) > 10 ) THEN
					LET cCel = SUBSTR(cCel,iCel,10);
				ELIF ( LENGTH(cCel) < 10 ) THEN
					LET cCel =''; 
				END IF;		
			END IF;

			select LIMIT 1 t.num_tarjeta into vnumtarjeta
			from bdicred:sd_tarjeta t
			where t.empresa = '001'
			and t.num_credito = vnumcredito
			and t.secuencia = (select max(tar.secuencia)
                from bdicred:sd_tarjeta tar
                where tar.empresa = '001'
                and tar.num_credito = vnumcredito
                and tar.tipo_tarjeta ='T' and tar.status_tar = 'A')
			and t.tipo_tarjeta ='T'  and t.status_tar = 'A';   

--			if (vmail <> '') then	
--				if nvl(vnumcte,'') <> '' then
--A.L.L.
				LET iCount_TCP_PRIMER = iCount_TCP_PRIMER + 1;
				call bdimnsj:"informix".sp_registra_evento (1, 'TCP_PRIMER' , vnumcte, vnumcredito,vnumtarjeta, 2,
							'','','','','',vimporte,0,0,0,0, today, '')RETURNING P_COD_RET;
--				call bdicobranza:"informix".sp_mail_inserta_cliente ('001',1, vnumcte, vnumcredito, vmail,0,vimporte,10,0,
--				'','','',0,0,0,0,0) returning P_COD_RET;									
--A.L.L.
                LET iCount_TCP_PRIMES = iCount_TCP_PRIMES +1 ;
                call bdimnsj:"informix".sp_registra_evento (2, 'TCP_PRIMES' , vnumcte, vnumcredito,vnumtarjeta, 2,
                            '','','','','',0,0,0,0,0, today, '')RETURNING P_COD_RET;
--				end if;
--			end if;
		end if;
	END FOREACH

	let i = 0;
	LET num = 0;

	if (iCount_TCP_PRIMER >= 1) then 
        FOR i in (1 to vvalor)		
--            insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente, fecha_hora_registro,string1,importe1,fecha1,fecha2)
            insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente, fecha_hora_registro,string1,importe1)
--            select  1, 'TCP_PRIMER',numcte,current,'',100,current,current
            select  1, 'TCP_PRIMER',numcte,current,'',100
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);

            let num = num + 10;
        end for
    end if;
--A.L.L.
	IF iCount_TCP_PRIMER > 0 THEN
--       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_PRIMER',iCount_TCP_PRIMER) RETURNING P_COD_RET;
       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_PRIMER',iCount_TCP_PRIMER,null) RETURNING P_COD_RET;
	END IF;
							
	if (iCount_TCP_PRIMES >= 1) then 
        let i = 0;
        LET num = 0;
        FOR i in (1 to vvalor)
        insert into bdimnsj:mnsjr_trx_batch(tipo_mensaje,id_mensaje,cliente,fecha_hora_registro,string1)
            select  2, 'TCP_PRIMES',numcte,current,''
            from bdinteg:si_cliente
            where numcte in (select substr(valor,num,9) from bdicobranza:cb_param where cod_param = 57);
                let num = num + 10;
        end for
	end if;
	
--A.L.L.
	IF iCount_TCP_PRIMES > 0 THEN
--       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_PRIMES',iCount_TCP_PRIMES) RETURNING P_COD_RET;
       CALL bdicobranza:"informix".sp_latinia_contador_cobranza('TCP_PRIMES',iCount_TCP_PRIMES,null) RETURNING P_COD_RET;
	END IF;

--Genera cifras de control
    if iCuentasProcesadas > 0 then
       let cMensaje = 'TOTAL Cuentas procesadas campaña PRIMER CONSUMO PLATINO : ' ||iCuentasProcesadas;
       let cMensaje = trim(cMensaje) ||'    EMAILs enviados PRIMER CONSUMO: ' ||iCount_TCP_PRIMER;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'SMSs enviados PRIMER CONSUMO: ' ||iCount_TCP_PRIMES;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por no ser primer consumo : ' ||iCuentasNoPimerConsumo;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
       let cMensaje = 'Cuentas excluidas por error mail : ' ||iCuentasExcluidasXMail;
       let cMensaje = trim(cMensaje) ||'    Cuentas excluidas por error celular : ' ||iCuentasExcluidasXCel;
       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
--       let cMensaje = 'Cuentas excluidas porque no existen en indicadores : ' ||iCuentasExcluidasxIndicador;
--       CALL bdicobranza:"informix".sp_inserta_bitacora_cob(vempresa, vproceso, P_COD_RET, trim(cMensaje), '02') RETURNING P_COD_RET;
    end if;
--Genera cifras de control

	CALL bdicobranza:"informix".sp_inserta_bitacora_cob('001', vproceso, P_COD_RET, cMensaje, '03')RETURNING cCodRet ;	

    if cCodRet  != '000000' then
       let P_COD_RET = cCodRet;
       let P_MENSAJE  = 'Error en el llamado al sp_inserta_bitacora_cob.';
       RETURN P_COD_RET,P_MENSAJE;
    end if;

	RETURN P_COD_RET,P_MENSAJE;  --Se ejecuto Exitosamente.

end;
end procedure;