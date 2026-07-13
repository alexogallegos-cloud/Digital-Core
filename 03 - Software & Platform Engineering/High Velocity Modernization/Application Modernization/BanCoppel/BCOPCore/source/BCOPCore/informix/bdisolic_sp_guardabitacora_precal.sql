CREATE PROCEDURE "informix".sp_guardabitacora_precal(o_empresa          CHAR(3),
                                                    o_sucursal          CHAR(4),
                                                    o_num_cliente       CHAR(20),
                                                    o_num_referencia    CHAR(20),
                                                    o_codretorno        CHAR(5),
                                                    o_mensaje           CHAR(300),
                                                    o_casusasol         CHAR(3),
                                                    o_producto          CHAR(4),
                                                    o_ejecutivo         CHAR(8),
                                                    o_porcentaje        DECIMAL(5,2),                                                   
                                                    o_situacion         CHAR(1),
                                                    o_causa		        SMALLINT,
                                                    o_nombre	        CHAR(104),
                                                    o_nombre_coppel     CHAR(104),
                                                    o_meses_hist        SMALLINT,
                                                    o_vencidomuebles    INTEGER,
                                                    o_vencidoropa       INTEGER,
                                                    o_vencidoprestamos  INTEGER,
                                                    o_abonomuebles	    INTEGER,
                                                    o_abonoropa         INTEGER,
                                                    o_abonoprestamos    INTEGER,
                                                    o_saldomuebles      INTEGER,
                                                    o_saldoropa         INTEGER,
                                                    o_saldoprestamos    INTEGER,
                                                    o_ultimacompra      DATE,
                                                    pEjecucion		    CHAR(1),
                                                    o_canal             CHAR(1),
                                                    o_bandera           CHAR(1))
RETURNING CHAR(5) AS CodRet; --Retorno

DEFINE sCodRet              CHAR(5);
DEFINE sql_err              SMALLINT;
DEFINE isam_err             SMALLINT;
DEFINE error_info           CHAR(100);
DEFINE cNomcte              CHAR (104);
DEFINE s_cteref             CHAR(20);
DEFINE cRFC					CHAR(13);
DEFINE cCodigoRet 			CHAR(6);
DEFINE cFechaUltimoPago 	CHAR(13); 
DEFINE cPrestamoAutorizado 	CHAR(1); 
DEFINE iMontoAutorizado 	INT8; 
DEFINE iReprestamo 			INT8; 
DEFINE v_motivo             CHAR(1);
DEFINE vlCteLargo 			SMALLINT;
DEFINE iVencidoAire      	INTEGER;			
DEFINE iAbonoAire         	INTEGER;
DEFINE iSaldoAire    		INTEGER;
DEFINE iVencidoAfiliados    INTEGER;
DEFINE iAbonoAfiliados      INTEGER;
DEFINE iSaldoAfiliados      INTEGER;
DEFINE iVencidoReestructura INTEGER;
DEFINE iAbonoReestructura   INTEGER;
DEFINE iSaldoReestructura   INTEGER;	
DEFINE iScorePuntualidad    INTEGER;
DEFINE vlGrupo				CHAR(1);	
DEFINE cTipoRechazo         CHAR(1);
DEFINE dtFecha              DATE;

LET sCodRet                 = '00000';
LET sql_err                 = 0;
LET isam_err                = 0;
LET error_info              = "";
LET s_cteref                = "";
LET cRFC                    = "";
LET cCodigoRet              = "";
LET cFechaUltimoPago        = ""; 
LET cPrestamoAutorizado     = ""; 
LET iMontoAutorizado        = "";
LET iReprestamo             = "";
LET	vlCteLargo			    = 0;
LET iVencidoAire    	    = 0;	
LET iAbonoAire      	    = 0;
LET iSaldoAire   		    = 0;
LET iVencidoAfiliados       = 0;
LET iAbonoAfiliados         = 0;
LET iSaldoAfiliados         = 0;
LET iVencidoReestructura    = 0;
LET iAbonoReestructura      = 0;
LET iSaldoReestructura      = 0;	
LET iScorePuntualidad       = 0;
LET vlGrupo				    = "";
LET v_motivo                = "B";
LET cTipoRechazo            = " ";
LET dtFecha              = DATE (1);

BEGIN
    ON EXCEPTION SET sql_err, isam_err, error_info
        IF sql_err != 0 THEN
            LET sCodRet = sql_err;
            RETURN sCodRet;
        END IF;      
    END EXCEPTION;

    --SET DEBUG FILE TO "/home/sysifx/Oscar/Sps_Motor/sp_guardabitacora_precal.trc";
    --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT RFC
    INTO cRFC
	FROM bdinteg:"informix".si_cliente
	WHERE numcte = o_num_cliente;

    SELECT fecha_hoy 
    INTO dtFecha
    FROM bdicred:"informix".sd_fechas
    where empresa = o_empresa;

    IF cRFC <> "" THEN
		EXECUTE PROCEDURE bdisolic:"informix".sp_valida_cliente_coppel('3','',cRFC,'','','','','','','','','','','','','','','','','','','','','')
		INTO cCodigoRet, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo;
    ELIF o_num_cliente <> "" THEN
        EXECUTE PROCEDURE bdisolic:"informix".sp_valida_cliente_coppel('2',o_num_cliente,'','','','','','','','','','','','','','','','','','','','','','')
		INTO cCodigoRet, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo;         
    ELSE
        LET cFechaUltimoPago = '1900-01-01';
        LET cPrestamoAutorizado = '0';
        LET iMontoAutorizado = '0';
        LET iRePrestamo = '0';
        LET cCodigoRet = '000000';
    END IF;

    IF NVL(o_num_referencia,'') = '' THEN
        SELECT TRIM(TRIM((TRIM(nombre1)||" "|| TRIM(nombre2))||" "|| TRIM(apell_paterno)||" "|| TRIM(apell_materno))), 
        NVL(numcte_ref, "")
        INTO cNomcte, s_cteref
        FROM bdinteg:"informix".si_cliente
        WHERE numcte= o_num_cliente;

         IF NVL(s_cteref,'') = '' THEN
            LET s_cteref = o_num_cliente;
        END IF;

        SELECT count(*) into vlCteLargo
        FROM bdisolic:"informix".ss_clienteslargos
        WHERE numcte = o_num_cliente
        AND fecha_vig_ini<= dtFecha 
        AND fecha_vig_fin >= dtFecha;
        
        IF nvl(vlCteLargo,0) > 0 THEN  
            LET vlGrupo = '8'; 
        END IF;            
        SELECT vencidototalaire,abonomensualaire,saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,
        abonomensualreestructura,saldototalreestructura,scorepuntualidad
        INTO iVencidoAire,iAbonoAire,iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,
        iAbonoReestructura,iSaldoReestructura,iScorePuntualidad
        FROM bdisolic:"informix".ss_cliente_coppel_pp
        WHERE empresa = o_empresa
        AND cliente_coppel = s_cteref;

        INSERT INTO bdisolic:"informix".ss_bitacora_precal
        (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
        causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos,   saldomuebles,
        saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos, fecha_ultima_compra,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
        saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
        VALUES
        (o_empresa,CURRENT,o_producto,o_sucursal,cNomcte,o_nombre_coppel,s_cteref,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
        o_causa,v_motivo,cTipoRechazo,o_codretorno, o_mensaje,o_casusasol, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
        o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo,iVencidoAire,iAbonoAire,
        iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);

    ELSE
        SELECT motivo_rechazo_sol, tipo_rechazo
        INTO v_motivo, cTipoRechazo
        FROM bdicred:"informix".sd_situacion_cred
        WHERE empresa = o_empresa
        AND situacion = o_situacion;

        SELECT vencidototalaire,abonomensualaire,saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,
        abonomensualreestructura,saldototalreestructura,scorepuntualidad
        INTO iVencidoAire,iAbonoAire,iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,
        iAbonoReestructura,iSaldoReestructura,iScorePuntualidad
        FROM bdisolic:"informix".ss_cliente_coppel_pp
        WHERE empresa = o_empresa
        AND cliente_coppel = o_num_referencia;

        INSERT INTO bdisolic:"informix".ss_bitacora_precal
        (empresa,fecha,producto,sucursal,nombre,nombre_coppel,num_referencia,ejecutivo,porcentaje,situacion,meses_hist,
        causa,motivo,tipo_rechazo,codret,mensaje,causa_solicitud, vencidototalmuebles, vencidototalropa, vencidoprestamos,   saldomuebles,
        saldoropa, saldoprestamos, abonomuebles, abonoropa, abonoprestamos, fecha_ultima_compra,fechaultimopago,prestamoautorizado,montoautorizado,represtamo,vencidototalaire,abonomensualaire,
        saldototalaire,vencidototalafiliados,abonomensualafiliados,saldototalafiliados,vencidototalreestructura,abonomensualreestructura,saldototalreestructura,scorepuntualidad)
        VALUES
        (o_empresa,CURRENT,o_producto,o_sucursal,o_nombre,o_nombre_coppel,o_num_referencia,o_ejecutivo,o_porcentaje,o_situacion,o_meses_hist,
        o_causa,v_motivo,cTipoRechazo,o_codretorno, o_mensaje,o_casusasol, o_vencidomuebles, o_vencidoropa, o_vencidoprestamos, o_saldomuebles, 
        o_saldoropa, o_saldoprestamos, o_abonomuebles, o_abonoropa, o_abonoprestamos,o_ultimacompra, cFechaUltimoPago, cPrestamoAutorizado, iMontoAutorizado, iRePrestamo,
        iVencidoAire,iAbonoAire,iSaldoAire,iVencidoAfiliados,iAbonoAfiliados,iSaldoAfiliados,iVencidoReestructura,iAbonoReestructura,iSaldoReestructura,iScorePuntualidad);
    END IF;   

    IF o_canal = '3' THEN
        IF o_num_referencia <> "" THEN
            INSERT INTO bdisolic:ax_paso values ("alta internet.situacion_pago_tienda_cjunk", o_codretorno, CURRENT ||' cte '||TRIM(o_num_cliente));
        ELSE
            INSERT INTO bdisolic:ax_paso values ("alta internet.situacion_pago_banco_cjunk", o_codretorno, CURRENT ||' cte '||TRIM(o_num_cliente));
        END IF;
    END IF;
    
END
    RETURN sCodRet;
END PROCEDURE
