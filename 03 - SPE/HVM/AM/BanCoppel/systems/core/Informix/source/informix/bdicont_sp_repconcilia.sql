CREATE PROCEDURE "informix".sp_repconcilia(pEmpresa CHAR(3))
RETURNING
   CHAR(5),   CHAR(10),     CHAR(16), 
   CHAR(60),  MONEY(14,2), CHAR(1),  
   CHAR(30),  CHAR(20),    CHAR(20),  MONEY(14,2); 

--######################################################################
--## Procedimiento       : sp_repconcilia
--## BD                  : bdicheq
--## Objetivo            : Encontrar las cuentas que difieren en montos
--##                       para la conciliacion de cheques
--## Valores Retorno     : v_CodRet -->   Código de Retorno.
--## Creado por          : Edith Rodriguez
--## Fecha creacion      : Junio de 2009
--## Modificado por      :
--######################################################################


DEFINE v_CodRet        CHAR(5);
DEFINE vsqlerr         INTEGER;
DEFINE v_vt_folio      CHAR(16);
DEFINE v_vt_transacc   CHAR(60);
DEFINE v_vtmonto       MONEY(14,2);
DEFINE v_vt_usuario    CHAR(20);
DEFINE v_vt_naturaleza CHAR(1);
DEFINE v_vt_status     CHAR(30);
DEFINE v_nro_cuenta    CHAR(20);
DEFINE v_importe       MONEY(14,2);
DEFINE vdiferencia     MONEY(14,2);
DEFINE v_folio         CHAR(16);
DEFINE vSucnro_cuenta  char(20);
DEFINE v_transaccion   CHAR(60);
DEFINE v_naturaleza    CHAR(1);
DEFINE v_estado        CHAR(30);
DEFINE v_Comodin       VARCHAR(60);
DEFINE v_Cuantos       integer;
DEFINE vBandera        CHAR(10);


LET v_CodRet            = "000";
LET vsqlerr             = "0";
LET v_vt_folio          ="";
LET v_vt_transacc       ="";
LET v_vtmonto           = 0;
LET v_vt_usuario        ="";
LET v_vt_naturaleza     ="";
LET v_vt_status         ="";
LET v_nro_cuenta        ="";
LET v_importe           = 0;
LET vdiferencia         = 0;
LET v_folio             ="";
LET vSucnro_cuenta      ="";
LET v_transaccion       ="";
LET v_naturaleza        ="";
LET v_estado            ="";
LET v_Comodin           ="";
LET v_Cuantos           = 0;
let vBandera            ="";
BEGIN

  ON EXCEPTION SET  vsqlerr
       IF  vsqlerr <>  0 THEN
         LET v_CodRet=vsqlerr;
         RETURN v_CodRet,NULL,    NULL,
                NULL,    NULL,    NULL,
                NULL,    NULL,    NULL,
                NULL;
       END IF;
    END EXCEPTION;

 --SET DEBUG FILE TO "/tmp/sp_repconcilia.out";
 --TRACE ON;


   EXECUTE PROCEDURE bdicont:sp_buscatemporal('tmp_rconciliacentral')
       INTO v_CodRet, v_Comodin, v_Cuantos;
    IF v_CodRet = '000' THEN
       DROP TABLE tmp_rconciliacentral;
    ELSE
     LET v_CodRet = '000';
    END IF

   EXECUTE PROCEDURE bdicont:sp_buscatemporal('tmp_rconciliasucursal')
       INTO v_CodRet, v_Comodin, v_Cuantos;
    IF v_CodRet = '000' THEN
       DROP TABLE tmp_rconciliasucursal;
    ELSE
     LET v_CodRet = '000';
    END IF

  SELECT  vfolio, vtransaccion, vimporte,  vnaturaleza, vestado, nro_cuenta
    FROM  bdicont:tmp_central_concilia
   WHERE  vfolio = '00000000'
    INTO  TEMP tmp_rconciliacentral
    WITH NO LOG;

  SELECT  vt_folio, vt_transacc, vt_monto, vt_usuario, vt_naturaleza, vt_status, nro_cuenta, 0 as diferencia
    FROM  bdicont:tmp_suc_concilia
   WHERE  vt_folio = '00000000'
    INTO  TEMP tmp_rconciliasucursal
    WITH NO LOG;

--******************************* PROGRAMA PRINCIPAL  *********************************************
    FOREACH
       SELECT  vfolio, vtransaccion,vimporte,vnaturaleza,vestado,   nro_cuenta
         INTO  v_folio,v_transaccion,v_importe,v_naturaleza,v_estado, v_nro_cuenta
         FROM bdicont:tmp_central_concilia

		FOREACH
             SELECT vt_folio, vt_transacc, vt_monto, vt_usuario, vt_naturaleza, vt_status, nro_cuenta
               INTO v_vt_folio, v_vt_transacc, v_vtmonto, v_vt_usuario, v_vt_naturaleza, v_vt_status, vSucnro_cuenta
               FROM bdicont:tmp_suc_concilia
              WHERE vt_folio = v_folio AND nro_cuenta = v_nro_cuenta AND vt_naturaleza = v_naturaleza

                    IF v_vtmonto <>  v_importe AND v_nro_cuenta = vSucnro_cuenta  THEN

                      LET vdiferencia = v_importe - v_vtmonto;

                       INSERT INTO tmp_rconciliasucursal(vt_folio,      vt_transacc, vt_monto,   vt_usuario, 
                                                         vt_naturaleza, vt_status,   nro_cuenta, diferencia)
                            VALUES (v_vt_folio,      v_vt_transacc, v_vtmonto,     v_vt_usuario,
                                    v_vt_naturaleza, v_vt_status,   v_nro_cuenta, vdiferencia);

                    ELSE
                      CONTINUE FOREACH;
                    END IF;

        END FOREACH;

        IF NOT EXISTS (SELECT vt_folio from tmp_suc_concilia 
					    WHERE vt_folio = v_folio 
						  AND nro_cuenta=v_nro_cuenta 
						  AND vt_monto= v_importe
						  AND vt_naturaleza=v_naturaleza ) THEN

                 INSERT INTO tmp_rconciliacentral (vfolio, vtransaccion, vimporte,  vnaturaleza, vestado, nro_cuenta)
                 VALUES ( v_folio,v_transaccion,v_importe,v_naturaleza,v_estado,   v_nro_cuenta);

		END IF
    END FOREACH;

	FOREACH
        SELECT vt_folio, vt_transacc, vt_monto, vt_usuario, vt_naturaleza, vt_status, nro_cuenta
          INTO v_vt_folio, v_vt_transacc, v_vtmonto, v_vt_usuario, v_vt_naturaleza, v_vt_status, vSucnro_cuenta
          FROM bdicont:tmp_suc_concilia
	    FOREACH
			 SELECT vfolio, vtransaccion,vimporte,vnaturaleza,vestado,nro_cuenta
	           INTO v_folio,v_transaccion,v_importe,v_naturaleza,v_estado, v_nro_cuenta
	           FROM bdicont:tmp_central_concilia
              WHERE vfolio = v_vt_folio AND nro_cuenta = vSucnro_cuenta AND vnaturaleza = v_vt_naturaleza

                    IF v_vtmonto <>  v_importe AND v_nro_cuenta = vSucnro_cuenta  THEN

						LET vdiferencia = v_vtmonto - v_importe;

						INSERT INTO tmp_rconciliacentral (vfolio, vtransaccion, vimporte,  vnaturaleza, vestado, nro_cuenta)
							 VALUES ( v_folio,v_transaccion,v_importe,v_naturaleza,v_estado,v_nro_cuenta);
                    ELSE
                      CONTINUE FOREACH;
                    END IF;
        END FOREACH;

        IF NOT EXISTS (SELECT vfolio FROM tmp_central_concilia 
						WHERE vfolio = v_vt_folio 
						  AND nro_cuenta=vSucnro_cuenta 
						  AND vimporte = v_vtmonto
						  AND vnaturaleza=v_vt_naturaleza) THEN

			INSERT INTO tmp_rconciliasucursal(vt_folio, vt_transacc, vt_monto,vt_usuario, vt_naturaleza, vt_status,nro_cuenta, diferencia)
                 VALUES (v_vt_folio,v_vt_transacc, v_vtmonto, v_vt_usuario, v_vt_naturaleza, v_vt_status, vSucnro_cuenta, 0);

		END IF
    END FOREACH;

	/*Muestra Diferencias*/
  LET vBandera = "CENTRAL";
  LET v_vt_usuario = "X";

  FOREACH
       SELECT DISTINCT vfolio,        vtransaccion,   vimporte,     
                       vnaturaleza,   vestado,        nro_cuenta
         INTO          v_folio,       v_transaccion,  v_importe, 
                       v_naturaleza, v_estado,        v_nro_cuenta
         FROM tmp_rconciliacentral
        ORDER BY vfolio,nro_cuenta

      RETURN v_CodRet,       vBandera,       v_folio,        
             v_transaccion,  v_importe,      v_naturaleza,   
             v_estado,       v_nro_cuenta,   v_vt_usuario, vdiferencia
        WITH RESUME;

  END FOREACH;

  LET vBandera = "SUCURSAL";

  FOREACH
       SELECT DISTINCT vt_folio,        vt_transacc,    vt_monto,     vt_usuario,
                       vt_naturaleza,   vt_status,      nro_cuenta,   diferencia      
      
         INTO          v_folio,     v_transaccion,  v_importe,    v_vt_usuario,
                       v_naturaleza, v_estado,      v_nro_cuenta, vdiferencia

         FROM tmp_rconciliasucursal
        ORDER BY vt_folio,nro_cuenta

      RETURN v_CodRet,       vBandera,       v_folio,        
             v_transaccion,  v_importe,      v_naturaleza,   
             v_estado,       v_nro_cuenta,   v_vt_usuario, vdiferencia
        WITH RESUME;

  END FOREACH;
--******************************** FIN DEL PROGRAMA PRINCIPAL *************************************

END
END PROCEDURE;