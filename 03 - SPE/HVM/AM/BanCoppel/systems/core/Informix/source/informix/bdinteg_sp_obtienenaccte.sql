CREATE PROCEDURE "informix".sp_obtienenaccte(pCodNac CHAR(3))

	-- DATOS A REGRESAR --
	RETURNING
	 CHAR(6) 	AS COD_RET,    		-- Codigo de retorno
	CHAR(60) 	AS MENSAJE_EJEC, 	-- Mensaje de Ejecucion
	 CHAR(3) 	AS COD_NAC, 		-- Clave del regimen
	CHAR(15) 	AS DESCRIPCION;   	-- Descripcion
	
	--	VARIABLES CONTROL DE ERRORES --
	DEFINE cCodRet  CHAR(5);
	DEFINE sql_err  INTEGER;
	
	-- VARIABLES --
	DEFINE cCodNac	CHAR(3);
	DEFINE cMens	CHAR(60);
	DEFINE cDesc	CHAR(15);
	DEFINE iBand	SMALLINT;
	

	-- INICIALIZACION DE VARIABLES --
	LET cCodRet = "000";
	LET cCodNac = "";
	LET cMens 	= "EJECUCION GENERADA CORRECTAMENTE";
	LET cDesc 	= "";
	LET iBand 	= 0;

	-- CONTROL DE ERRORES --	
BEGIN
	ON EXCEPTION SET sql_err
        IF sql_err <> 0 THEN
            LET cCodRet = sql_err;
            RETURN TRIM(cCodRet), TRIM(cMens), TRIM(cCodNac), TRIM(cDesc);
        END IF
	END EXCEPTION;

    set isolation to dirty read;
	SET LOCK MODE TO WAIT 3;
	
	--SET DEBUG FILE TO "/dbexport/victor/sp_obtienenaccte.out";
	--TRACE ON;	
		
	IF pCodNac = "" THEN
		LET pCodNac = NULL;
	END IF
	
	IF pCodNac IS NULL THEN		--SE REALIZA UNA CONSULTA COMPLETA Y REGRESA TODOS LOS REGISTROS		
		FOREACH
			SELECT nacion, descripcion
			INTO cCodNac, cDesc
			FROM Bdinteg:"informix".si_nacion
			ORDER BY nacion
			
			LET iBand = 1;
			
			RETURN TRIM(cCodRet), TRIM(cMens), TRIM(cCodNac), TRIM(cDesc) WITH RESUME;
			
		END FOREACH;
		
	ELSE							--SE REALIZA UNA CONSULTA PARA UN CODIGO DE NACION EN ESPECIFICO	
		SELECT nacion, descripcion
		INTO cCodNac, cDesc
		FROM Bdinteg:"informix".si_nacion
		WHERE nacion = pCodNac;
		
		IF cCodNac IS NULL THEN --NO EXISTE EL CODIGO DE LA NACION
			LET cCodRet = '100';
			LET cMens = 'NO EXISTE EL CODIGO DE LA NACION, VERIFIQUE';
		END IF;
		
		RETURN TRIM(cCodRet), TRIM(cMens), TRIM(cCodNac), TRIM(cDesc);
		
	END IF;
	
	IF iBand = 0 THEN --NO HAY DATOS EN LA TABLA-CATALOGO
		LET cCodRet = '200';
		LET cMens = 'NO EXISTEN DATOS EN EL CATALOGO, VERIFIQUE';
		RETURN TRIM(cCodRet), TRIM(cMens), TRIM(cCodNac), TRIM(cDesc);
	END IF
	
END
END PROCEDURE
DOCUMENT
'Versión         : 1.0',
'Creado por      : Clemente Angulo Ballardo',
'Fecha creacion  : 13 de Junio 2011',
'Descripcion     : Obtiene todas las naciones o la descripcion de una en especifico',
'Base de Datos	 : Bdinteg';

CREATE PROCEDURE "informix".sp_updcte_fus() 
RETURNING CHAR(5), CHAR(80);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INTEGER;
DEFINE vi_iSAMErr        INTEGER;
DEFINE vi_iSAMData        CHAR(80);
DEFINE vc_Mensaje       CHAR(80);
DEFINE pClienteTitular        CHAR(20);
DEFINE pClienteTraspasaCtas        CHAR(20);
DEFINE vc_detalle_mov2   CHAR(200);
DEFINE vc_proceso       CHAR(50);
DEFINE vc_tabla         CHAR(30);
DEFINE vc_detalle_mov   CHAR(200);
DEFINE vc_Cuenta        CHAR(20);
DEFINE vc_Cuenta2        CHAR(20);
DEFINE vi_secuencia     INTEGER;
DEFINE vc_aniomes       CHAR(6);
DEFINE pCte        CHAR(20);
DEFINE vi_num_serial    INTEGER;
DEFINE vd_fecha_mov     DATE;
--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_secuencia = 0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET pClienteTitular="";
LET pClienteTraspasaCtas="";
LET vc_detalle_mov2 = "";
LET vc_proceso = "FusionClientes";
LET vc_tabla = "";
LET vc_detalle_mov = "";
LET vc_Cuenta = "";
LET vc_aniomes="";
LET vc_Cuenta2="";
LET pCte="";
LET vi_num_serial=0;
LET vd_fecha_mov = "";




set isolation to dirty read;
set lock mode to wait 3;

    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            LET vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/ids10_uc9/VH/sp_updcte_fus.out";
    --TRACE ON;


SET ISOLATION TO DIRTY READ;
FOREACH
    SELECT {+INDEX (bdinteg:log_fusionclientes pk_fusionclientes)} DISTINCT TRIM(cliente_tit),TRIM(cliente_tras) INTO pClienteTitular,pClienteTraspasaCtas FROM log_fusionclientes WHERE cliente_tit<>'' AND cliente_tras<>''
    --******************INICIA TRASPASO DE SOBREGIROS ******************************************
    --******************************************************************************************    
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (bdicheq:sc_histsbg ix173_1)} cuenta INTO vc_Cuenta FROM bdicheq:sc_histsbg WHERE empresa='001' AND num_cte = pClienteTraspasaCtas

            LET vc_proceso='SOBREGIROS';
            LET vc_tabla = "sc_histsbg";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fushistsbg 
            SELECT {+INDEX (bdicheq:sc_histsbg idx_histsbg1)} * FROM bdicheq:sc_histsbg WHERE empresa='001' AND cuenta = vc_Cuenta;     
		
            UPDATE {+INDEX (bdicheq:sc_histsbg idx_histsbg1)} bdicheq:sc_histsbg SET num_cte = pClienteTitular WHERE empresa='001' AND cuenta = vc_Cuenta; 
        END FOREACH;  
    --******************INICIA TRASPASO DE PROAC ***********************************************
    --******************************************************************************************
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT cta_eje,cuenta,secuencia INTO vc_Cuenta,vc_Cuenta2,vi_secuencia FROM bdicheq:sc_proac WHERE num_cte = pClienteTraspasaCtas

            LET vc_proceso='PROAC';
            LET vc_tabla = "sc_proac";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(vc_Cuenta2)||'|'||vi_secuencia||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fusproac 
            SELECT {+INDEX (bdicheq:sc_proac idxproac_13)} * FROM bdicheq:sc_proac WHERE cta_eje = vc_Cuenta AND num_cte = pClienteTraspasaCtas;     
		
            UPDATE {+INDEX (bdicheq:sc_proac idxproac_13)} bdicheq:sc_proac SET num_cte = pClienteTitular WHERE cta_eje = vc_Cuenta AND num_cte = pClienteTraspasaCtas;  
        END FOREACH;  
    --******************INICIA TRASPASO DE PORTABILIDAD NOMINA**********************************
    --******************************************************************************************
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT cuenta INTO vc_Cuenta FROM bdicheq:sc_portabilidad WHERE numcte = pClienteTraspasaCtas AND empresa='001'

            LET vc_proceso='PORTABILIDAD NOMINA';
            LET vc_tabla = "sc_portabilidad";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fusportabilidad 
            SELECT * FROM bdicheq:sc_portabilidad WHERE cuenta = vc_Cuenta AND empresa='001';     
		
            UPDATE bdicheq:sc_portabilidad SET numcte = pClienteTitular WHERE cuenta = vc_Cuenta AND empresa='001';
        END FOREACH;  
    --******************INICIA TRASPASO DE FACTURA ELECTRONICA**********************************
    --******************************************************************************************
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT num_cuenta,idreg INTO vc_Cuenta,vi_secuencia FROM bdicheq:sc_encabezado_edocta_factelect WHERE num_cte = pClienteTraspasaCtas

            LET vc_proceso='FACTURA ELECTRONICA';
            LET vc_tabla = "sc_encabezado_edocta_factelect";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas)||'|'||vi_secuencia;   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fusencabezado_edocta_factelect 
            SELECT * FROM bdicheq:sc_encabezado_edocta_factelect WHERE num_cuenta = vc_Cuenta AND idreg = vi_secuencia;     
		
            UPDATE bdicheq:sc_encabezado_edocta_factelect SET num_cte = pClienteTitular WHERE num_cuenta = vc_Cuenta AND idreg = vi_secuencia;  
        END FOREACH;  
    --******************INICIA TRASPASO DE BENEFICIARIOS INVERSION *****************************
    --******************************************************************************************
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT cuenta INTO vc_Cuenta FROM bdinvers:sv_benefic WHERE numcte = pClienteTraspasaCtas AND empresa='001'

            LET vc_proceso='BENEFICIARIOS INVERSION';
            LET vc_tabla = "sv_benefic";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fusbenefic_inv 
            SELECT * FROM bdinvers:sv_benefic WHERE cuenta = vc_Cuenta AND empresa='001';     
		
            UPDATE bdinvers:sv_benefic SET numcte = pClienteTitular WHERE cuenta = vc_Cuenta AND empresa='001';
        END FOREACH;  
    --******************INICIA TRASPASO DE AUTORIZADOS INVERSION *******************************
    --******************************************************************************************
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT cuenta INTO vc_Cuenta FROM bdinvers:sv_cotitular WHERE numcte = pClienteTraspasaCtas AND empresa='001'

            LET vc_proceso='AUTORIZADOS INVERSION';
            LET vc_tabla = "sv_cotitular";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fuscotitular_inv 
            SELECT {+INDEX (bdinvers:sv_cotitular idx_cotit)} * FROM bdinvers:sv_cotitular WHERE empresa='001' AND cuenta = vc_Cuenta;     
		
            UPDATE {+INDEX (bdinvers:sv_cotitular idx_cotit)} bdinvers:sv_cotitular SET numcte = pClienteTitular WHERE empresa='001' AND cuenta = vc_Cuenta;
        END FOREACH;  
    --******************SD_ENCABEZADO_EDOCTACRD ************************************************
    --******************************************************************************************
    SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (bdicred:sd_encabezado_edoctacrd id_encabezado_fecha_tarjeta)} num_credito,fecha_emision INTO vc_Cuenta,vd_fecha_mov FROM bdicred:sd_encabezado_edoctacrd WHERE numcte = pClienteTraspasaCtas

            LET vc_proceso='SD_ENCABEZADO_EDOCTACRD';
            LET vc_tabla = "sd_encabezado_edoctacrd";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTitular)||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fusencabezado_edoctacrd
            SELECT {+INDEX (bdicred:sd_encabezado_edoctacrd id_encabezado_fecha_tarjeta)} * FROM bdicred:sd_encabezado_edoctacrd WHERE num_credito= vc_Cuenta AND fecha_emision=vd_fecha_mov;

            UPDATE {+INDEX (bdicred:sd_encabezado_edoctacrd id_encabezado_fecha_tarjeta)} bdicred:sd_encabezado_edoctacrd SET numcte = pClienteTitular WHERE num_credito= vc_Cuenta AND fecha_emision=vd_fecha_mov;
        END FOREACH;  
    --******************INICIA TRASPASO DE ACLARACIONES ****************************************
    --******************************************************************************************
        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (bdiaclaracion:acl_cliente 114_31)} pky_cliente INTO vi_secuencia FROM bdiaclaracion:acl_cliente WHERE numero=pClienteTraspasaCtas 

            LET vc_proceso='ACLARACIONES';
            LET vc_tabla = "acl_cliente";
            LET vc_detalle_mov = TRIM(pClienteTitular)||'|'||vi_secuencia||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fusaclcliente
            SELECT {+INDEX (bdiaclaracion:acl_cliente 114_31)} * FROM bdiaclaracion:acl_cliente WHERE pky_cliente= vi_secuencia;

            UPDATE {+INDEX (bdiaclaracion:acl_cliente 114_31)} bdiaclaracion:acl_cliente SET numero = pClienteTitular WHERE pky_cliente= vi_secuencia; 
        END FOREACH;  
    --******************INICIA TRASPASO DE CASOS ESPECIALES ************************************
    --******************************************************************************************
        IF EXISTS (SELECT {+INDEX (bdinteg:si_ctessitesp marcamen)} keyx FROM bdinteg:si_ctessitesp WHERE numcliente = pClienteTitular) THEN
            SET ISOLATION TO DIRTY READ;
            FOREACH
                SELECT {+INDEX (bdinteg:si_ctessitesp marcamen)} keyx INTO vi_num_serial FROM bdinteg:si_ctessitesp WHERE numcliente = pClienteTraspasaCtas

                LET vc_proceso='RESPALDO CASOS ESPECIALES';
                LET vc_tabla = "si_ctessitesp";
                LET vc_detalle_mov = TRIM(pClienteTitular)||'|'||vi_num_serial||'|'||TRIM(pClienteTraspasaCtas);   
                INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
                VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

                INSERT INTO bdinteg:si_fusctessitesp 
                SELECT {+INDEX (bdinteg:si_ctessitesp marcamen)} * FROM bdinteg:si_ctessitesp WHERE numcliente = pClienteTraspasaCtas;

                DELETE {+INDEX (bdinteg:si_ctessitesp marcamen)} FROM bdinteg:si_ctessitesp WHERE numcliente = pClienteTraspasaCtas;
            END FOREACH;
        ELSE
            SET ISOLATION TO DIRTY READ;
            FOREACH
                SELECT {+INDEX (bdinteg:si_ctessitesp marcamen)} keyx INTO vi_num_serial FROM bdinteg:si_ctessitesp WHERE numcliente = pClienteTraspasaCtas

                LET vc_proceso='CASOS ESPECIALES';
                LET vc_tabla = "si_ctessitesp";
                LET vc_detalle_mov = TRIM(pClienteTitular)||'|'||vi_num_serial||'|'||TRIM(pClienteTraspasaCtas);   
                INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
                VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

                INSERT INTO bdinteg:si_fusctessitesp 
                SELECT {+INDEX (bdinteg:si_ctessitesp marcamen)} * FROM bdinteg:si_ctessitesp WHERE numcliente = pClienteTraspasaCtas;

                UPDATE {+INDEX (bdinteg:si_ctessitesp marcamen)} bdinteg:si_ctessitesp SET numcliente=pClienteTitular WHERE numcliente = pClienteTraspasaCtas;
            END FOREACH;    
        END IF;

END FOREACH;  


   --******************INICIA TRASPASO DE EDO CTA**********************************************
    --******************************************************************************************
SET ISOLATION TO DIRTY READ;
FOREACH
    SELECT {+INDEX (bdinteg:log_fusionclientes pk_fusionclientes)} DISTINCT TRIM(cliente_tit),TRIM(cliente_tras),SUBSTR(detalle_mov,1,11) INTO pClienteTitular,pClienteTraspasaCtas,vc_Cuenta2 FROM log_fusionclientes WHERE cliente_tit<>'' AND cliente_tras<>'' and tabla='sc_maechq'

        SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT aniomes INTO vc_aniomes FROM bdicheq:sc_maehis WHERE cuenta = vc_Cuenta2 AND empresa='001'

            LET vc_proceso='ESTADO DE CUENTA';
            LET vc_tabla = "sc_maehis";
            LET vc_detalle_mov = TRIM(vc_Cuenta2)||'|'||vc_aniomes||'|'||TRIM(pClienteTraspasaCtas);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fusmaehis 
            SELECT {+INDEX (bdicheq:sc_maehis idx_maehis1)} * FROM bdicheq:sc_maehis WHERE empresa='001' AND aniomes=vc_aniomes AND cuenta = vc_Cuenta2;     
		
            UPDATE {+INDEX (bdicheq:sc_maehis idx_maehis1)} bdicheq:sc_maehis SET num_cte = pClienteTitular WHERE empresa='001' AND aniomes=vc_aniomes AND cuenta = vc_Cuenta2;  
        END FOREACH;  
END FOREACH;
   --******************INICIA TRASPASO DE EDO CTA**********************************************
    --******************************************************************************************

SET ISOLATION TO DIRTY READ;
FOREACH
    SELECT {+INDEX (bdinteg:log_fusionclientes pk_fusionclientes)} TRIM(cliente_tit),TRIM(cliente_tras),SUBSTR(detalle_mov,26,16)  INTO pClienteTitular,pClienteTraspasaCtas,vc_Cuenta2 FROM log_fusionclientes WHERE cliente_tit<>'' AND cliente_tras<>'' AND proceso='TARJETAS CREDITO'
    SET ISOLATION TO DIRTY READ;
        FOREACH
            SELECT {+INDEX (bdicred:sd_encabezado_edocta td_encabezado_tarjeta)} num_credito INTO vc_Cuenta FROM bdicred:sd_encabezado_edocta WHERE num_tarjeta=vc_Cuenta2

            LET vc_proceso='SD_ENCABEZADO_EDOCTA';
            LET vc_tabla = "sd_encabezado_edocta";
            LET vc_detalle_mov = TRIM(vc_Cuenta)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_Cuenta2);   
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), 'informix', CURRENT);

            INSERT INTO bdinteg:si_fusencabezado_edocta
            SELECT {+INDEX (bdicred:sd_encabezado_edocta td_encabezado_tarjeta)} * FROM bdicred:sd_encabezado_edocta WHERE num_tarjeta=vc_Cuenta2;

            UPDATE {+INDEX (bdicred:sd_encabezado_edocta td_encabezado_tarjeta)} bdicred:sd_encabezado_edocta SET numcte = pClienteTitular WHERE num_tarjeta=vc_Cuenta2;
        END FOREACH;
END FOREACH;

    IF vc_CodRet = "00000" THEN
        RETURN vc_CodRet, vc_Mensaje;
    END IF;
END;
END PROCEDURE;