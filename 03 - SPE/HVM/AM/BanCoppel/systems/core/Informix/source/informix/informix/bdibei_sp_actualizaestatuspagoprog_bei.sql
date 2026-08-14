CREATE PROCEDURE "informix".sp_actualizaestatuspagoprog_bei(pIdUsuario INTEGER, pNumCte char(9))
 returning char(5);

    DEFINE cod_ret char(5);
    DEFINE sql_err INTEGER ;
    DEFINE idOperacion INT;

    SET LOCK MODE TO WAIT 4;

	LET cod_ret  = "00000";
	LET idOperacion = 0;


	BEGIN
	   ON EXCEPTION SET sql_err
			ROLLBACK WORK;
			IF sql_err <> 0 THEN
				let cod_ret = sql_err;
				RETURN cod_ret;
			END IF ;
	   END EXCEPTION ;

	   IF(LENGTH(TRIM(NVL(pNumCte, ''))) = 0) THEN
			LET cod_ret = "001"; --Numero de cliente incorrecto
			RETURN cod_ret;
	   END IF;

	   IF(pIdUsuario <= 0 OR pIdUsuario IS NULL) THEN
			LET cod_ret = "002"; --Id operador es incorrecto
			RETURN cod_ret;
	   END IF;  

       FOREACH 
               Select tb.id_operacion
			Into idOperacion
			From  bdiprog:"informix".pp_pagoprog as pg
			Inner Join bdiprog:"informix".pp_pagospend as pp On(pg.cve_pagoprog = pp.cve_pagoprog)
			Inner Join (
    			Select op.id_operacion, op.statusoperacion, opr.cuenta_origen, opr.cuenta_destino, op.id_cliente, opr.importe, op.foliopagoprogramado
    			From  bdibei:"informix".bei_operacionesmancomunadasoperador opr
    			Inner Join bdibei:"informix".bei_operacionesmancomunadasoperadorresumen op On(op.id_operacion = opr.id_operacion)
    			Inner Join bdibei:"informix".bei_cat_operaciones cat On(cat.id_cat_oper = op.id_catoperacion)
    			Where op.id_usuarioCambiaStatus = pIdUsuario 
    			And   op.statusoperacion = 'A'
    			And   op.f_aplicacion <= today
    			And   opr.id_cliente = pNumCte
			) as tb On(pg.num_cte = tb.id_cliente And pg.cuenta_origen = tb.cuenta_origen And pg.cuenta_destino = tb.cuenta_destino And pg.importe = tb.importe And pg.descripcion = tb.foliopagoprogramado)
			Where (pp.estado = '04' Or pp.estado = '05')
			And   pp.fecha_prog <= today

            Update "informix".bei_operacionesmancomunadasoperador 
			Set statusoperacion = 'L'
	   		Where id_operacion = idOperacion;

	   		Update "informix".bei_operacionesmancomunadasoperadorresumen 
	   		Set statusoperacion = 'L'
	   		Where id_operacion = idOperacion;

        END FOREACH;
        
        
        FOREACH 
              
        	Select tab.id_operacion 
        	Into idOperacion
			From bdicheq:"informix".sc_nominaencabezadosumariohist as nom
			Inner Join (
    			Select op.id_operacion, op.statusoperacion, opr.cuenta_origen, op.id_cliente, opr.importe, concat(substring(opr.nombre_archivo from 0 for 14),'.dat') as nombre_archivo, opr.empresa
    			From  bdibei:"informix".bei_operacionesmancomunadasoperador opr
    			Inner Join bdibei:"informix".bei_operacionesmancomunadasoperadorresumen op On(op.id_operacion = opr.id_operacion)
    			Inner Join bdibei:"informix".bei_cat_operaciones cat On(cat.id_cat_oper = op.id_catoperacion)
    			Where op.id_usuarioCambiaStatus = pIdUsuario 
    			And   op.statusoperacion = 'A'
    			And   op.f_aplicacion <= today
    			And   opr.id_cliente = pNumCte
			) as tab On (tab.importe = nom.importe_tot And tab.cuenta_origen = nom.cuenta_cargo And tab.nombre_archivo = nom.nombre_archivo And tab.empresa = nom.empresa)
			Where (nom.status = '2' Or nom.status = '3')
			And nom.fecha_aplicacion <= today
       
       

            Update "informix".bei_operacionesmancomunadasoperador 
			Set statusoperacion = 'L'
	   		Where id_operacion = idOperacion;

	   		Update "informix".bei_operacionesmancomunadasoperadorresumen 
	   		Set statusoperacion = 'L'
	   		Where id_operacion = idOperacion;

        END FOREACH;
        


	   RETURN cod_ret;
	END    
END PROCEDURE;