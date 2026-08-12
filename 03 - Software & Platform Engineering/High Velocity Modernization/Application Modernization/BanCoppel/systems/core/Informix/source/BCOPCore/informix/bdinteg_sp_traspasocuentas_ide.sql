CREATE PROCEDURE "informix".sp_traspasocuentas_ide(pClienteTitular CHAR(20), pClienteTraspasaCtas CHAR(20), pUsuario CHAR(8)) 
RETURNING CHAR(5), CHAR(80);
--DEFINICION DE VARIABLES
DEFINE vc_CodRet        CHAR(5);
DEFINE vi_SqlErr        INTEGER;
DEFINE vi_iSAMErr        INTEGER;
DEFINE vi_iSAMData        CHAR(80);
DEFINE vc_Mensaje       CHAR(80);
DEFINE vc_detalle_mov2   CHAR(200);
DEFINE vc_proceso       CHAR(50);
DEFINE vc_tabla         CHAR(30);
DEFINE vc_detalle_mov   CHAR(200);
DEFINE vc_numsolic        CHAR(20);
DEFINE vc_Cuenta2        CHAR(20);
DEFINE vi_secuencia     INTEGER;
DEFINE vc_AnioMes	CHAR(6);
DEFINE vc_aniomesI       CHAR(6);
DEFINE vc_aniomesF       CHAR(6);
DEFINE pCte        CHAR(20);
DEFINE vi_num_serial    INTEGER;
DEFINE iExiste     INTEGER;
DEFINE vc_statusolic    CHAR(2);
DEFINE vd_FechaSolic    DATE;
DEFINE iNumRows			INTEGER;
DEFINE vc_rfc           CHAR(13);
DEFINE vc_rfc_ori          CHAR(13);
DEFINE vc_ref_ret       CHAR(20);
DEFINE vc_tipo_cta      CHAR(1);
DEFINE vc_sucursal      CHAR(4);
DEFINE vc_num_cta       CHAR(20);
DEFINE vd_fecha_mov     DATE;
DEFINE vm_imp_tot_dep   MONEY(10,2);
DEFINE vm_imp_ide       MONEY(10,2);
DEFINE vc_user_insert   CHAR(8);
DEFINE vd_fecha_insert  DATE;
DEFINE CparamRango		CHAR(13);
DEFINE sEjercicio		SMALLINT;
DEFINE cUser_insert_ide	CHAR(8);
DEFINE dFecha_insert_ide	DATE;
DEFINE cPendiente		CHAR(1);
DEFINE cAniomes		CHAR(6);
DEFINE cCuenta_ret	CHAR(20);
DEFINE cConsecutivo  CHAR(1);
DEFINE cNumcte		CHAR(20);
DEFINE cRfc			CHAR(13);



DEFINE mImp_acumulado	MONEY;
DEFINE mImp_gravado		MONEY;
DEFINE mImp_arecaudar	MONEY;
DEFINE mImp_recaudado	MONEY;
DEFINE mImp_mesanterior MONEY;
DEFINE mImp_excedente	MONEY;
DEFINE mImp_arecaudarc	MONEY;
DEFINE mImp_recaudadoc	MONEY;
DEFINE mImp_pendiente	MONEY;
DEFINE mImp_anterior	MONEY;

--INICIALIZACION DE VARIABLES
LET vc_CodRet = "00000";
LET vi_SqlErr = 0;
LET vi_iSAMErr=0;
LET vi_secuencia = 0;
LET vi_iSAMData="";
LET vc_Mensaje = "EL PROCESO SE EFECTUO CORRECTAMENTE";
LET vc_detalle_mov2 = "";
LET vc_proceso = "FusionClientes";
LET vc_tabla = "";
LET vc_detalle_mov = "";
LET vc_numsolic = "";
LET vc_AnioMes= "";
LET vc_aniomesI="";
LET vc_aniomesF="";
LET vc_Cuenta2="";
LET pCte="";
LET vi_num_serial=0;
LET vd_fecha_mov = "";
LET iExiste=0;
LET vc_statusolic = "";
LET vd_FechaSolic = "";
LET iNumRows= 0;
LET vc_rfc="";
LET vc_rfc_ori="";
LET vc_ref_ret = "";
LET vc_tipo_cta = "";
LET vc_sucursal = "";
LET vc_num_cta = "";
LET vd_fecha_mov = "";
LET vm_imp_tot_dep = 0;
LET vm_imp_ide = 0;
LET vc_user_insert = "";
LET vd_fecha_insert = "";
LET CparamRango="";
LET sEjercicio=0;
LET cUser_insert_ide = '';
LET dFecha_insert_ide = '';
LET cPendiente = '';
LET cAniomes	= '';
LET cCuenta_ret = '';
LET cConsecutivo = '';
LET cNumcte = '';
LET cRfc = '';

LET mImp_acumulado	= 0;
LET mImp_gravado	= 0;
LET mImp_arecaudar	= 0;
LET mImp_recaudado	= 0;
LET mImp_mesanterior	= 0;
LET mImp_excedente = 0;
LET mImp_arecaudarc = 0;
LET mImp_recaudadoc = 0;
LET mImp_pendiente = 0;
LET mImp_anterior = 0;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

    BEGIN WORK;
    BEGIN

    ON EXCEPTION SET vi_SqlErr,vi_iSAMErr,vi_iSAMData
        IF vi_SqlErr <> 0 THEN
            LET vc_CodRet = vi_SqlErr;
            LET vc_Mensaje = "ERROR NO CONTROLADO";
            ROLLBACK WORK;
            let vc_detalle_mov2=vi_SqlErr||'|'||vi_iSAMErr||'|'||vi_iSAMData; 
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov2, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

            RETURN vc_CodRet, vc_Mensaje;
        END IF;
    END EXCEPTION;

    --SET DEBUG FILE TO "/tmp/ALAN/fusion/sp_traspasocuentas_ide.out";
    --TRACE ON;

	--SELECT  trim(valor) INTO vc_aniomesI FROM si_param where cod_param=151;
	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_movefec WHERE num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas, pClienteTraspasaCtas));
	--SELECT  trim(valor) INTO vc_aniomesF FROM si_param where cod_param=152;
	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_movefec WHERE num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTraspasaCtas));
	--LET sEjercicio=SUBSTR(vc_aniomesI,1,4);

    SELECT  {+INDEX(bdinteg:si_cliente idx_si_cliente5)} rfc INTO vc_rfc FROM si_cliente WHERE numcte = pClienteTitular;

	SELECT  {+INDEX(bdilide:sl_movefec i_102)} FIRST 1 num_cte INTO pCte FROM bdilide:sl_movefec WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF 
	AND num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte=pClienteTraspasaCtas);
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           SELECT  {+INDEX(bdilide:sl_movefec i_102)} num_serial, rfc, ref_ret, tipo_cta, sucursal, num_cta, fecha_mov, imp_tot_dep, imp_ide, user_insert, fecha_insert,aniomes
            INTO   vi_num_serial, vc_rfc_ori, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert,vc_AnioMes
            FROM bdilide:sl_movefec WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cta in (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta from bdicheq:sc_maechq where empresa='001' and num_cte=pClienteTraspasaCtas)

            LET vc_tabla = "sl_movefec";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret)||'|'||TRIM(vc_num_cta)||'|'||vd_fecha_mov||'|'||vm_imp_tot_dep;
            LET vc_proceso='MOVIMIENTO IDE';   
        
            INSERT INTO bdinteg:si_fusmovefec
            SELECT  {+INDEX(bdilide:sl_movefec i_102)} * FROM bdilide:sl_movefec WHERE aniomes = vc_AnioMes AND num_cta= vc_num_cta AND num_cte = pClienteTraspasaCtas;

			
			--DELETE {+INDEX(bdilide:sl_movefec i_102)} FROM bdilide:sl_movefec WHERE aniomes = vc_AnioMes AND num_cta= vc_num_cta AND num_cte = pClienteTraspasaCtas;

            --INSERT INTO bdilide:sl_movefec(aniomes, num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,imp_tot_dep,imp_ide,user_insert,fecha_insert)
            --VALUES (vc_AnioMes, pClienteTitular,vi_num_serial, vc_rfc, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert);

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

			UPDATE {+INDEX(bdilide:sl_movefec i_102)} bdilide:sl_movefec SET num_cte=pClienteTitular,rfc=vc_rfc WHERE aniomes =vc_AnioMes AND num_cta=vc_num_cta AND num_cte=pClienteTraspasaCtas;
        END FOREACH;
    END IF;	
	
	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_movefec_his WHERE num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTraspasaCtas));

	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_movefec_his WHERE num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTraspasaCtas));
	
    SELECT  FIRST 1 num_cte INTO pCte FROM bdilide:sl_movefec_his WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF 
	AND num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte=pClienteTraspasaCtas);
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
        FOREACH         
            SELECT  {+INDEX(bdilide:sl_movefec_his i_102_his)} num_serial, rfc, ref_ret, tipo_cta, sucursal, num_cta, fecha_mov, imp_tot_dep, imp_ide, user_insert, fecha_insert,aniomes
            INTO   vi_num_serial, vc_rfc_ori, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert,vc_AnioMes
            FROM bdilide:sl_movefec_his
            WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cta IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' and num_cte=pClienteTraspasaCtas)

            LET vc_tabla = "sl_movefec_his";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret)||'|'||TRIM(vc_num_cta)||'|'||vd_fecha_mov||'|'||vm_imp_tot_dep;
            LET vc_proceso='MOVIMIENTO IDE';           

            INSERT INTO bdinteg:si_fusmovefec_his
            SELECT  {+INDEX(bdilide:sl_movefec_his i_102_his)} * FROM bdilide:sl_movefec_his WHERE aniomes = vc_AnioMes AND num_cta= vc_num_cta AND num_cte = pClienteTraspasaCtas;

			--DELETE {+INDEX(bdilide:si_fusmovefec_his i_102_his)} FROM bdilide:sl_movefec_his WHERE aniomes = vc_AnioMes AND num_cta= vc_num_cta AND num_cte = pClienteTraspasaCtas;

            --INSERT INTO bdilide:sl_movefec_his(aniomes, num_cte,num_serial,rfc,ref_ret,tipo_cta,sucursal,num_cta,fecha_mov,imp_tot_dep,imp_ide,user_insert,fecha_insert)
            --VALUES (vc_AnioMes, pClienteTitular,vi_num_serial, vc_rfc, vc_ref_ret, vc_tipo_cta, vc_sucursal, vc_num_cta, vd_fecha_mov, vm_imp_tot_dep, vm_imp_ide, vc_user_insert, vd_fecha_insert);

            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

			UPDATE {+INDEX(bdilide:sl_movefec_his i_102_his)} bdilide:sl_movefec_his SET num_cte=pClienteTitular,rfc=vc_rfc WHERE aniomes=vc_AnioMes AND num_cta=vc_num_cta AND num_cte=pClienteTraspasaCtas;
			
        END FOREACH;
    END IF;

	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_retlide WHERE num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND pendiente IS NOT NULL;

	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_retlide WHERE num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND pendiente IS NOT NULL;
	
	SELECT  {+INDEX(bdilide:sl_retlide idx_retcte)}  FIRST 1 num_cte INTO pCte FROM bdilide:sl_retlide WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cte =pClienteTraspasaCtas AND pendiente IS NOT NULL;
	
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           SELECT   {+INDEX(bdilide:sl_retlide idx_retcte)} rfc, ref_ret,aniomes
            INTO   vc_rfc_ori, vc_ref_ret,vc_AnioMes
            FROM bdilide:sl_retlide
            WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cte = pClienteTraspasaCtas AND pendiente IS NOT NULL

            LET vc_tabla = "sl_retlide";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret);
            LET vc_proceso='RETENCION IDE';   
			
			IF EXISTS (SELECT  {+INDEX(bdilide:sl_retlide idx_retcte)} 1 FROM bdilide:sl_retlide  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes) THEN
				SELECT  {+INDEX(bdilide:sl_retlide idx_retcte)} user_insert, fecha_insert, pendiente
				INTO cUser_insert_ide, dFecha_insert_ide, cPendiente
				FROM bdilide:sl_retlide  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes;
				
				INSERT INTO bdinteg:si_fusretlide
				SELECT  * FROM bdilide:sl_retlide WHERE aniomes = vc_AnioMes AND num_cte IN (pClienteTitular, pClienteTraspasaCtas) AND pendiente IS NOT NULL;
				
				SELECT  {+INDEX(bdilide:sl_retlide idx_retcte)} 
					 SUM(imp_acumulado), SUM(imp_gravado), SUM(imp_arecaudar), SUM(imp_recaudado), SUM(imp_mesanterior)
				INTO mImp_acumulado, mImp_gravado, mImp_arecaudar, mImp_recaudado, mImp_mesanterior
				FROM bdilide:sl_retlide WHERE num_cte IN (pClienteTitular, pClienteTraspasaCtas)
				AND aniomes = vc_AnioMes;
				
				UPDATE {+INDEX(bdilide:sl_retlide idx_retcte)}  bdilide:sl_retlide 
				SET imp_acumulado = mImp_acumulado, imp_gravado = mImp_gravado, imp_arecaudar = mImp_arecaudar, imp_recaudado = mImp_recaudado, imp_mesanterior = mImp_mesanterior
				WHERE rfc = vc_rfc AND num_cte = pClienteTitular AND aniomes = vc_AnioMes AND pendiente IS NOT NULL;
				
				DELETE FROM bdilide:sl_retlide
				WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND  pendiente IS NOT NULL;				

			ELSE
				INSERT INTO bdinteg:si_fusretlide
				SELECT  * FROM bdilide:sl_retlide WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND pendiente IS NOT NULL;
				
				UPDATE bdilide:sl_retlide SET rfc = vc_rfc,num_cte = pClienteTitular WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND pendiente IS NOT NULL;
			END IF;
			
			INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);		

        END FOREACH;
    END IF;
	
	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_detlide WHERE cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTitular));

	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_detlide WHERE cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTitular));
	
	SELECT  {+INDEX(bdilide:sl_detlide i_d102)} FIRST 1 num_cte INTO pCte FROM bdilide:sl_detlide WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF 
	AND cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq where empresa='001' AND num_cte=pClienteTraspasaCtas);
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           SELECT   {+INDEX(bdilide:sl_detlide i_d102)} rfc, ref_ret,aniomes,cuenta_ret,consecutivo
            INTO   vc_rfc_ori, vc_ref_ret,vc_AnioMes,vc_num_cta,vi_num_serial
            FROM bdilide:sl_detlide WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta from bdicheq:sc_maechq where empresa='001' and num_cte=pClienteTraspasaCtas)

            LET vc_tabla = "sl_detlide";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_ref_ret)||'|'||TRIM(vc_num_cta)||'|'||vi_num_serial;
            LET vc_proceso='DETALLE IDE';  

			IF EXISTS (SELECT  {+INDEX(bdilide:sl_detlide i_d102)} 1 FROM bdilide:sl_detlide  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes) THEN
				SELECT  {+INDEX(bdilide:sl_detlide i_d102)} aniomes,cuenta_ret--,consecutivo
				INTO cAniomes, cCuenta_ret --cConsecutivo
				FROM bdilide:sl_detlide  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes AND consecutivo = vi_num_serial;
				
				INSERT INTO bdinteg:si_fusdetlide
				SELECT  * FROM bdilide:sl_detlide 
				WHERE aniomes = cAniomes 
					AND cuenta_ret IN (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta FROM bdicheq:sc_maechq WHERE empresa='001' AND num_cte IN (pClienteTraspasaCtas,pClienteTitular)) AND consecutivo = vi_num_serial;
				
				SELECT  {+INDEX(bdilide:sl_detlide i_d102)} 
					 SUM(imp_recaudado)
				INTO mImp_recaudado
				FROM bdilide:sl_detlide WHERE num_cte IN (pClienteTitular, pClienteTraspasaCtas)
				AND aniomes = vc_AnioMes AND consecutivo = vi_num_serial;
				
				UPDATE {+INDEX(bdilide:sl_detlide i_d102)}  bdilide:sl_detlide 
				SET  imp_recaudado = mImp_recaudado
				WHERE rfc = vc_rfc_ori AND num_cte = pClienteTitular AND aniomes = vc_AnioMes AND consecutivo = vi_num_serial;
				
				DELETE FROM bdilide:sl_detlide 
				WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND consecutivo = vi_num_serial;				
			ELSE
        
				INSERT INTO bdinteg:si_fusdetlide
				SELECT  {+INDEX(bdilide:sl_detlide i_d102)} * FROM bdilide:sl_detlide WHERE aniomes = vc_AnioMes AND cuenta_ret =vc_num_cta AND num_cte=pClienteTraspasaCtas;
			
				UPDATE {+INDEX(bdilide:sl_detlide i_d102)} bdilide:sl_detlide SET rfc = vc_rfc,num_cte = pClienteTitular WHERE aniomes = vc_AnioMes AND cuenta_ret =vc_num_cta AND num_cte=pClienteTraspasaCtas AND consecutivo = vi_num_serial;
			END IF;
			
            INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);			
        END FOREACH;
    END IF;

	
	SELECT  MIN (aniomes)  
	INTO vc_aniomesI
	FROM bdilide:sl_constancias WHERE  num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND tipo_cons is not null;

	SELECT  MAX (aniomes)  
	INTO vc_aniomesF
	FROM bdilide:sl_constancias WHERE  num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND tipo_cons is not null;
	
	SELECT  {+INDEX(bdilide:sl_constancias 112_228)} FIRST 1 num_cte INTO pCte FROM bdilide:sl_constancias WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cte =pClienteTraspasaCtas AND tipo_cons is not null;
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           SELECT   rfc, tipo_cons,aniomes
            INTO   vc_rfc_ori, vc_sucursal,vc_AnioMes
            FROM bdilide:sl_constancias
            WHERE aniomes BETWEEN vc_aniomesI AND vc_aniomesF AND num_cte = pClienteTraspasaCtas AND tipo_cons is not null

            LET vc_tabla = "sl_constancias";
            LET vc_detalle_mov = TRIM(vc_AnioMes)||'|'||TRIM(pClienteTraspasaCtas)||'|'||TRIM(vc_rfc_ori)||'|'||TRIM(vc_sucursal);
            LET vc_proceso='CONSTANCIAS IDE';
						
			IF EXISTS (SELECT  {+INDEX(bdilide:sl_constancias  112_228)} 1 FROM bdilide:sl_constancias  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes) THEN
				SELECT  {+INDEX(bdilide:sl_constancias  112_228)} aniomes,num_cte,rfc
				INTO cAniomes,cNumcte,cRfc
				FROM bdilide:sl_constancias  WHERE num_cte = pClienteTitular AND aniomes = vc_AnioMes AND tipo_cons = vc_sucursal;
				
				INSERT INTO bdinteg:si_fusconstancias
				SELECT  * FROM bdilide:sl_constancias  WHERE aniomes = vc_AnioMes AND num_cte IN (pClienteTraspasaCtas,pClienteTitular) AND tipo_cons = vc_sucursal;
				
				SELECT  {+INDEX(bdilide:sl_constancias  112_228)} 
					 SUM(imp_excedente),SUM(imp_arecaudar),SUM(imp_recaudado),SUM(imp_pendiente),SUM(imp_anterior)
				INTO mImp_excedente, mImp_arecaudarc,mImp_recaudadoc,mImp_pendiente,mImp_anterior
				FROM bdilide:sl_constancias WHERE num_cte IN (pClienteTitular, pClienteTraspasaCtas)
				AND aniomes = vc_AnioMes AND tipo_cons = vc_sucursal;
				
				UPDATE {+INDEX(bdilide:sl_constancias  112_228)}  bdilide:sl_constancias 
				SET  imp_excedente = mImp_excedente, imp_arecaudar = mImp_arecaudarc,imp_recaudado = mImp_recaudadoc,imp_pendiente = mImp_pendiente,imp_anterior = mImp_anterior
				WHERE rfc = vc_rfc_ori AND num_cte = pClienteTitular AND aniomes = vc_AnioMes AND tipo_cons = vc_sucursal;
				
				DELETE FROM bdilide:sl_constancias 
				WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND tipo_cons = vc_sucursal;							
			ELSE
			
				INSERT INTO bdinteg:si_fusconstancias
				SELECT  * FROM bdilide:sl_constancias WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND tipo_cons is not null;

				UPDATE bdilide:sl_constancias SET rfc = vc_rfc,num_cte = pClienteTitular WHERE aniomes = vc_AnioMes AND num_cte = pClienteTraspasaCtas AND tipo_cons is not null;
			END IF;
			
			INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
			VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);		
        END FOREACH;
    END IF;

	SELECT  FIRST 1 num_cte INTO pCte FROM bdicheq:sc_retenisr WHERE empresa='001' 
	AND cuenta in (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta from bdicheq:sc_maechq where empresa='001' and num_cte=pClienteTraspasaCtas);
	LET iNumRows = dbinfo("sqlca.sqlerrd2");
	IF iNumRows>0 THEN
        SET ISOLATION TO DIRTY READ;
         FOREACH         
           --BD-- SELECT   {+INDEX(bdicheq:sc_retenisr inx_retenisr_02)}  cuenta
           SELECT   cuenta
            INTO    vc_num_cta
            FROM bdicheq:sc_retenisr WHERE empresa='001' AND cuenta in (SELECT  {+INDEX(bdicheq:sc_maechq mae1)} cuenta from bdicheq:sc_maechq where empresa='001' and num_cte=pClienteTraspasaCtas)

            LET vc_tabla = "sc_retenisr";
            LET vc_detalle_mov = vi_num_serial||'|'||TRIM(vc_num_cta)||'|'||TRIM(pClienteTraspasaCtas);
            LET vc_proceso='RETEN ISR';   
        
            INSERT INTO bdinteg:si_fusretenisr
            SELECT  {+INDEX(bdicheq:sc_retenisr inx_retenisr_02)} * FROM bdicheq:sc_retenisr WHERE empresa='001' AND num_cte =pClienteTraspasaCtas AND cuenta=vc_num_cta; 

			INSERT INTO log_fusionclientes(proceso, tabla, cliente_tit, cliente_tras, detalle_mov, fecha_hora, user_insert, fecha_insert)
            VALUES (vc_proceso, vc_tabla, pClienteTitular, pClienteTraspasaCtas, vc_detalle_mov, CURRENT HOUR TO FRACTION(4), pUsuario, CURRENT);

			UPDATE {+INDEX(bdicheq:sc_retenisr inx_retenisr_02)} bdicheq:sc_retenisr SET num_cte = pClienteTitular WHERE empresa='001' AND num_cte = pClienteTraspasaCtas AND cuenta=vc_num_cta;

        END FOREACH;
    END IF;

   IF vc_CodRet = "00000" THEN
        COMMIT WORK;
        RETURN vc_CodRet, vc_Mensaje;
    END IF;

END;
END PROCEDURE;