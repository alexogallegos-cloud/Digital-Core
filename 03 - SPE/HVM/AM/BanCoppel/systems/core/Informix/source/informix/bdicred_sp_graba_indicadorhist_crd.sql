CREATE PROCEDURE "informix".sp_graba_indicadorhist_crd()
       RETURNING char(5), char(50);
 
DEFINE	sql_err			INTEGER;
DEFINE	isam_err		INTEGER;
DEFINE	error_info	CHAR(150);
DEFINE	cMensaje		CHAR(80);
DEFINE	cCod_ret		CHAR(6);
DEFINE	cMensaje2		CHAR(50);

DEFINE vcantReg		  SMALLINT;
DEFINE vlCredito    LIKE bdicred:sd_indicador_cred_crd.num_credito;
DEFINE pEmpresa     CHAR(3);
DEFINE vLaborable   LIKE bdinteg:si_feriado.laborable;
DEFINE vtoday       date;
DEFINE vContador    INTEGER; 
 

  LET cCod_ret      = '00000';
	LET sql_err       = 0;
	LET isam_err      = 0;
	LET error_info    = '';
	LET cMensaje      = 'PROCESO EXITOSO';	
	LET pEmpresa      = '001';
  LET vLaborable    = '';
  LET vtoday        = '01/01/1900';
  LET cMensaje2     = '';
  LET vContador     = 0;
  
--  SET DEBUG FILE TO 'sp_graba_indicadorhist_crd.trc';
--  TRACE ON;

	
BEGIN
        ON EXCEPTION SET sql_err, isam_err, error_info
            LET cCod_ret = sql_err;
            LET cMensaje = error_info;
            LET cMensaje2 = error_info;
			      insert into bdicobranza:cb_bitacora (mensaje) values  (error_info);		
            RETURN cCod_ret, cMensaje2;
        END EXCEPTION;		
		SET LOCK MODE TO WAIT 3;		
    SET ISOLATION TO DIRTY READ;

  LET vtoday        = today;

    SELECT laborable INTO vLaborable
      FROM bdinteg:si_feriado
     WHERE fecha = vtoday;

     IF vLaborable IS NULL THEN LET vLaborable = ''; END IF;

      
     IF vLaborable = 'N' THEN
        IF month(vtoday) = 12 AND day(vtoday) = 25 THEN -- valida Diciembre
            SELECT a.num_credito
              FROM bdicred:sd_maecredcrd a
              INNER JOIN bdicred:sd_maecredanexocrd b ON b.empresa='001' AND b.num_credito=a.num_credito 
                     AND b.fecha_proceso = vtoday + 1 AND b.dia_corte IN (24,25)
             WHERE a.empresa='001' 
               AND a.num_credito>=''
              INTO temp paso_indcred_crd WITH NO LOG;
        ELIF month(vtoday) = 1  AND day(vtoday) = 1 THEN  -- valida Enero
            SELECT a.num_credito
              FROM bdicred:sd_maecredcrd a
              INNER JOIN bdicred:sd_maecredanexocrd b ON b.empresa='001' AND b.num_credito=a.num_credito 
                     AND b.fecha_proceso = vtoday + 1 --and b.dia_corte in (31,1)
             WHERE a.empresa='001' 
               AND a.num_credito>=''
              INTO temp paso_indcred_crd WITH NO LOG;
        END IF;
     ELSE
        IF day(vtoday) = 2 AND month(vtoday) = 1 THEN  -- Si es dia 1 se respalda todo lo que se procesó
           LET cMensaje2 = 'Hoy no es día de proceso por ser día no laborable.';   
           RETURN cCod_ret, TRIM(cMensaje2);
        ELIF day(vtoday) = 26 AND month(vtoday) = 12 THEN  -- Si es dia 1 se respalda todo lo que se procesó
           LET cMensaje2 = 'Hoy no es día de proceso por ser día no laborable.';   
           RETURN cCod_ret, TRIM(cMensaje2);
        ELIF day(vtoday) = 1 AND month(vtoday) != 1 THEN  -- Si es dia 1 se respalda todo lo que se procesó
             SELECT a.num_credito
               FROM bdicred:sd_maecredcrd a
               INNER JOIN bdicred:sd_maecredanexocrd b ON b.empresa='001' AND b.num_credito=a.num_credito 
                      AND b.fecha_proceso = vtoday 
               WHERE a.empresa='001' 
                 AND a.num_credito>=''
                INTO temp paso_indcred_crd WITH NO log;
        ELSE   --valida meses cuyo último día del mes es 30
             SELECT a.num_credito
               FROM bdicred:sd_maecredcrd a
               INNER JOIN bdicred:sd_maecredanexocrd b ON b.empresa='001' AND b.num_credito=a.num_credito 
                      AND b.fecha_proceso = vtoday AND b.dia_corte = day(vtoday - 1 UNITS day)
               WHERE a.empresa='001' 
                  AND a.num_credito>=''  
               INTO temp paso_indcred_crd WITH NO LOG;
        END IF;
    END IF;

    IF day(vtoday) = 16 THEN
        INSERT INTO paso_indcred_crd
        SELECT a.num_credito
          FROM bdicred:sd_maecredcrd a
          INNER JOIN bdicred:sd_maecredanexocrd b ON b.empresa = '001' AND b.num_credito = a.num_credito
                 AND a.num_producto = '6400' AND a.periodo_plazo = 'Q' AND b.dia_corte IN (28,29,30,31)
          WHERE a.empresa = '001'
            AND a.num_credito >= '';
    END IF;

    CREATE UNIQUE INDEX "informix".idx_paso_indcred_crd ON "informix".paso_indcred_crd(num_credito);
    UPDATE STATISTICS MEDIUM FOR TABLE "informix".paso_indcred_crd;

            
    	FOREACH WITH HOLD
              SELECT num_credito
                INTO vlCredito
                FROM paso_indcred_crd 
               WHERE num_credito NOT IN ( SELECT num_credito 
                                              FROM sd_indicador_cred_crd_hist 
                                             WHERE empresa = pEmpresa
                                               AND num_credito >= '600000000001'
                                               AND fecha_insert = vtoday-1 UNITS day)
     
        			  BEGIN WORK; 
            				INSERT INTO sd_indicador_cred_crd_hist			
            				(empresa, num_credito, fecha_insert, fecha_alta, fecha_vencido, dias_atraso, fecha_ultimo_pago, fecha_ultimo_pago_h,
            				 monto_ultimo_pago, monto_ultimo_pago_h, cumplio_convenio,
							 
							 sdo_tot_liquidar, sdo_tot_liquidar_ch, sdo_tot_liquidar_h, pago_minimo, pago_minimo_ch, pago_minimo_h, sdo_tot_vencido, 
							 sdo_tot_vencido_ch, sdo_tot_vencido_h, monto_pagos, monto_pagos_ch, intereses_periodo_ch, num_vencidos_ch, monto_mensual, 
							 fecha_primera_mora, fecha_ultima_mora, fecha_promesa_rota, peor_mora_12m, saldo_maximo_hist, num_pagos_hist, num_convenios_hist, 
							 promesa_pago, trans_ultimo_pago, folio_ultimo_pago, max_mora_hist, fecha_ultimo_pago_rev, monto_ultimo_pago_rev, trans_ultimo_pago_rev, 
							 folio_ultimo_pago_rev,intereses_ree) 

            				SELECT empresa, num_credito, (vtoday-1 units day), fecha_alta, fecha_vencido, dias_atraso, fecha_ultimo_pago, fecha_ultimo_pago_h,
            				       monto_ultimo_pago, monto_ultimo_pago_h, cumplio_convenio,
								   
								   sdo_tot_liquidar, sdo_tot_liquidar_ch, sdo_tot_liquidar_h, pago_minimo, pago_minimo_ch, pago_minimo_h, sdo_tot_vencido, 
								   sdo_tot_vencido_ch, sdo_tot_vencido_h, monto_pagos, monto_pagos_ch, intereses_periodo_ch, num_vencidos_ch, monto_mensual, 
								   fecha_primera_mora, fecha_ultima_mora, fecha_promesa_rota, peor_mora_12m, saldo_maximo_hist, num_pagos_hist, num_convenios_hist, 
								   promesa_pago, trans_ultimo_pago, folio_ultimo_pago, max_mora_hist, fecha_ultimo_pago_rev, monto_ultimo_pago_rev, trans_ultimo_pago_rev, 
								   folio_ultimo_pago_rev,intereses_ree 

            				  FROM bdicred:sd_indicador_cred_crd
            				 WHERE empresa = pEmpresa
            				   AND num_credito = vlCredito;  
        			  COMMIT WORK;
                LET vContador = vContador + 1;	 
          END FOREACH;

    --UPDATE statistics medium FOR TABLE "informix".sd_indicador_cred_crd_hist;   -- SOLO COMENTAR PARA TEST MACF
    DROP TABLE paso_indcred_crd;
    LET cMensaje2 = 'Registros Procesados: ' || vContador;   
    RETURN cCod_ret, trim(cMensaje2);
    
 END;
END PROCEDURE
DOCUMENT
'DESCRIPCION: Actualizar la tabla de indicadores de crédito histórica CRD.',
'AUTOR : Marco A. Campos. 20140120',
'BD: bdicred',
'DESCRIPCION: Actualizar proceso por nuevos campos de indicadores TRIAD.',
'AUTOR : Marco A. Campos. 20180830';

Create procedure "informix".constarcred(pempresa char(3),
                                        pnumtarjeta  char(20))
                                                         
 Returning	char(5),char(3),char(20),char(20),char(20),date,char(1),char(1),char(14),char(30),date;

 define vcodret		char(5);
 define vsqlerr         integer;
 define vempresa	char(3);
 define vnum_cred       char(20);
 define vnum_tar        char(20);
 define vnumcte         char(20);
 define vexpiracion     date;
 define vtipo_tar       char(1);
 define vstatus_tar     char(1);
 define vlimite_aut     char (14);
 define vnombre         char(30);
 define vfecha_nac      date;
 define vstatus_cred    char(2);

 let vcodret     = "";
 let vsqlerr     = 0;
 let vempresa    =  "";
 let vnum_cred   =  "";
 let vnum_tar    =  "";
 let vnumcte     =  "";
 let vexpiracion =  "";
 let vtipo_tar   =  "";
 let vstatus_tar =  "";
 let vlimite_aut =  "";
 let vnombre     =  "";
 let vfecha_nac  =  "";
 let vstatus_cred = "";

 Begin

	On exception set vsqlerr
		if vsqlerr<>0 then
			let vcodret = vsqlerr;
			return vcodret,vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre,vfecha_nac;
		end if;
	end exception;


	--set debug file to  '/pisa/pisabanco/pisa_ftes/credito/constarcred.out';
	--trace on;

SET LOCK MODE TO WAIT 3;
SET ISOLATION TO DIRTY READ;

	if pnumtarjeta is null or pnumtarjeta= "" then
	   let vcodret = '101';
           return vcodret,vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre,vfecha_nac;
	end if;

		/*
        select num_tarjeta
        into   vnum_tar
        from   "informix".sd_tarjeta
        where  empresa = pempresa and num_tarjeta = pnumtarjeta;
		*/
    --RQM 10 1473 Se contempla que no reimpriman portada TDCs Canceladas
	SELECT cred.status_cred
        INTO   vstatus_cred
        FROM   bdicred:"informix".sd_tarjeta tar, bdicred:"informix".sd_maecred cred
	WHERE  tar.empresa=pempresa 
	AND tar.num_credito = cred.num_credito
	AND tar.num_tarjeta=pnumtarjeta;
    IF vstatus_cred NOT IN ('FF','FI') THEN
            --JMAH Se modifica para obtener el monto_solicitado de la tabla de solicitudes.
            --limite_aut
        SELECT tar.empresa, tar.num_credito, tar.num_tarjeta, tar.numcte, tar.expiracion, tar.tipo_tarjeta, tar.status_tar,sol.monto_solicitado , tar.nombre --limite_aut
            INTO   vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre 
            FROM   bdicred:"informix".sd_tarjeta tar, bdisolic:"informix".ss_solicitudes sol
        WHERE  tar.empresa=pempresa 
        AND tar.num_credito = sol.num_solicitud
        AND tar.num_tarjeta=pnumtarjeta;

        -- INC 27 178 contemplar productos TDC Oro y TDC Platinum
        IF DBINFO("sqlca.sqlerrd2") = 0 THEN
            SELECT tar.empresa, tar.num_credito, tar.num_tarjeta, tar.numcte, tar.expiracion, tar.tipo_tarjeta, tar.status_tar,msdo.monto_otorgado , tar.nombre --limite_aut
                INTO   vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre 
                FROM   bdicred:"informix".sd_tarjeta tar, bdicred:"informix".sd_maesdos msdo
            WHERE  tar.empresa=pempresa 
            AND tar.num_credito = msdo.num_credito
            AND tar.num_tarjeta=pnumtarjeta;        
        END IF;  

            SELECT fecha_nac INTO vfecha_nac 
            FROM bdinteg:"informix".si_ctepf
            WHERE numcte = vnumcte;

    END IF;   
        return vcodret,vempresa,vnum_cred,vnum_tar,vnumcte,vexpiracion,vtipo_tar,vstatus_tar,vlimite_aut,vnombre,vfecha_nac;

 end
 end procedure;