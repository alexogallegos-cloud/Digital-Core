CREATE PROCEDURE "informix".abono_cred (pEmpresa    CHAR(3),
			     pCredito    CHAR(20),
			     pSucursal   CHAR(4),
			     pUsuario    CHAR(8),
			     pTran       CHAR(4),
			     pMonto      DECIMAL(14,2),
			     pFolio      CHAR(16),
			     pTarjeta    CHAR(20),
			     pMontoDls   DECIMAL(14,2),
			     pTpCambio   DECIMAL(14,6),
			     pFecha      DATE,
			     pReferencia CHAR(40),
			     pTpMov      CHAR(1),	
	  		     pRfcComer    VARCHAR(20),
			     pRef23       VARCHAR(23))

   RETURNING CHAR(5);

   -- **************************************************************************
   -- *                      DEFINICION DE VARIABLES                           *
   -- **************************************************************************
   DEFINE cod_ret             CHAR(5);
   DEFINE sql_err             SMALLINT;
   DEFINE isam_err            SMALLINT;
   DEFINE error_info          CHAR(40);
   DEFINE vSucCred	      CHAR(4);
   DEFINE vIvaSuc	      DECIMAL(5,3);
   DEFINE vIvaBase	      DECIMAL(5,3);
   DEFINE vTpTran             CHAR(2);
   DEFINE vTpTranRel          CHAR(2);
   DEFINE vTranRelac          CHAR(4);
   DEFINE vTranParalela       CHAR(4);
   DEFINE vTranNro	      SMALLINT;
   DEFINE vDiasRet	      SMALLINT;
   DEFINE vMensaje	      CHAR(1);
   DEFINE vProducto	      CHAR(4);
   DEFINE vTranRetuvo	      CHAR(4);
   DEFINE vDivisa             CHAR(2);
   DEFINE vMtoRet	      DECIMAL(14,2);

   -- **************************************************************************
   -- *                      CONTROL DE ERRORES                                *
   -- **************************************************************************

   ON EXCEPTION SET sql_err, isam_err, error_info
      LET cod_ret = sql_err;
      RETURN cod_ret;
   END EXCEPTION;



  SET LOCK MODE TO WAIT 10;

  -- **************************************************************************
  -- *                      ASIGNACION DE VARIABLES                           *
  -- **************************************************************************

   LET cod_ret    = "000";
   LET vTranNro   = pTran;
   LET vMtoRet    = 0;

   LET pTran = vTranNro;
   IF LENGTH(pTran) < 4 THEN
       LET pTran = LPAD(TRIM(pTran),4,"6");
   END IF

-- ****************************************************************************
-- *                        PROGRAMA PRINCIPAL                                *
-- ****************************************************************************
   -- ******************************
   -- Extrae Parametro de IVA Base *
   -- ******************************
   SELECT valor INTO vIvaBase
     FROM bdinteg:si_param
    WHERE empresa = pEmpresa
      AND cod_param = 47;

   IF vIvaBase IS NULL THEN
	LET vIvaBase = 0;
   END IF

   -- **************************************************
   -- Extrae informacion de Sucursal e Iva del Credito *
   -- **************************************************
   SELECT a.sucursal, a.iva, b.num_producto, b.divisa
     INTO vSucCred, vIvaSuc, vProducto, vDivisa
     FROM bdinteg:si_sucursales a, sd_maecred b
    WHERE b.empresa = pEmpresa
      AND b.num_credito = pCredito
      AND a.empresa = b.empresa
      AND a.sucursal = b.sucursal;

   -- ***************************************
   -- Extrae informacion de la Transaccion  *
   -- ***************************************

   SELECT tipo_tran, NVL(tran_relac,"0000"), NVL(trancivaesp,"0000"),
	  NVL(dias_ret,0)
     INTO vTpTran, vTranRelac, vTranParalela, vDiasRet
     FROM bdinteg:si_transacc
    WHERE empresa = pEmpresa
      AND sistema = "06"
      AND numero = pTran;

   IF LENGTH(vTranRelac) = 0 THEN
	LET vTranRelac = "0000";
   END IF

   IF LENGTH(vTranParalela) = 0 THEN
	LET vTranParalela = "0000";
   END IF
   -- **************************************************************
   -- Determina la transaccion a utilizar por clasificacion de IVA *
   -- **************************************************************
   IF vIvaSuc <> vIvaBase AND vTranParalela <> "0000" THEN
	LET pTran = vTranParalela;
   END IF

   -- ******************************************************************
   -- Determina si es reversion y busca los valores para la aplicacion *
   -- ******************************************************************
   IF pTpMov = "R" THEN
	-- Extrae Datos de la Transaccion de Reversion
	SELECT tipo_tran, NVL(tran_relac,"0000"), NVL(trancivaesp,"0000"),
               NVL(dias_ret,0)
   	  INTO vTpTran, vTranRelac, vTranParalela, vDiasRet
     	  FROM bdinteg:si_transacc
   	 WHERE empresa = pEmpresa
      	   AND sistema = "06"
      	   AND numero = pTran;

   	IF LENGTH(vTranRelac) = 0 THEN
        	LET vTranRelac = "0000";
  	END IF

   	IF LENGTH(vTranParalela) = 0 THEN
        	LET vTranParalela = "0000";
  	 END IF

        -- Extrae Datos de la Transaccion a Reversar
	IF vTranRelac <> "0000" THEN
		LET pTran = vTranRelac;
        	SELECT tipo_tran, NVL(tran_relac,"0000"),
		       NVL(trancivaesp,"0000"), NVL(dias_ret,0)
          	  INTO vTpTran, vTranRelac, vTranParalela, vDiasRet
          	  FROM bdinteg:si_transacc
         	 WHERE empresa = pEmpresa
           	   AND sistema = "06"
           	   AND numero = pTran;

        	IF LENGTH(vTranRelac) = 0 THEN
                	LET vTranRelac = "0000";
        	END IF

        	IF LENGTH(vTranParalela) = 0 THEN
                	LET vTranParalela = "0000";
         	END IF
	END IF

   END IF

   -- Libera Retencion por Reversion
   IF vTpTran >= "20" AND vTpTran <= "29" AND pTpMov = "R" THEN

	SELECT monto
	  INTO vMtoRet
	  FROM sd_maeretenido
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND folio_suc = pFOlio
	   AND transacc = pTran;

	UPDATE sd_maesdos SET sdo_retenido = sdo_retenido - vMtoRet
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito;

	UPDATE sd_maeretenido
	   SET estatus = "S"
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND folio_suc = pFOlio
	   AND transacc = pTran;

	UPDATE sd_movhis
	   SET reversado = "S"
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND folio_suc = pFOlio
	   AND transacc_suc = pTran;

	UPDATE sd_movdia
	   SET reversado = "S"
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND folio_suc = pFOlio
	   AND transacc_suc = pTran;

   -- Reversa Movimientos sin retencion
   ELIF vTpTran >= "00" AND vTpTran <= "19" AND pTpMov = "R" THEN

        UPDATE sd_maesdos SET sdo_capital = sdo_capital - pMonto,
                              sdo_cap_insoluto = sdo_cap_insoluto - pMonto,
                              mto_ministra_cap = mto_ministra_cap - pMonto,
                              cargos_mes_cap   = cargos_mes_cap - pMonto
         WHERE empresa = pEmpresa
           AND num_credito = pCredito;

	UPDATE sd_movdia
	   SET reversado = "S"
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito
	   AND folio_suc = pFolio
	   AND transacc_suc = pTran;

   ELIF VTpTran >= "00" AND vTpTran <= "19" AND pTpMov <> "R" THEN
	UPDATE sd_maesdos SET sdo_capital = sdo_capital - pMonto,
			      sdo_cap_insoluto = sdo_cap_insoluto - pMonto,
		              mto_ministra_cap = mto_ministra_cap - pMonto,
          		      cargos_mes_cap   = cargos_mes_cap - pMonto
	 WHERE empresa = pEmpresa
	   AND num_credito = pCredito;

   END IF

   -- **************************
   -- Aplica Movimiento Diario *
   -- **************************
   IF pTpMov <> "R" THEN
   	EXECUTE PROCEDURE genmov_tc(pEmpresa, pCredito, vProducto,
                               	    pFecha, pMonto, pFolio, pSucursal,
                                    vDivisa, pTran, pTarjeta, pReferencia,
			            pTpCambio, pMontoDls, pUsuario, vSucCred,
				      pRfcComer,pRef23)
   	INTO cod_ret, vMensaje;
   	IF cod_ret <> "000" THEN
		RETURN cod_ret;
   	END IF
   END IF

   -- ************************************************
   -- Ejecuta Aplicacion de Transaccion Relacionada  *
   -- ************************************************
   IF vTranRelac IS NULL THEN
	LET vTranRelac = "0000";
   END IF

   IF vTranRelac <> "0000" THEN
	SELECT tipo_tran INTO vTpTranRel
	  FROM si_transacc
	 WHERE empresa = pEmpresa
	   AND sistema = "06"
	   AND numero = vTranRelac;

	IF pTpMov = "R" THEN
		SELECT monto INTO pMonto
	          FROM sd_movdia
		 WHERE empresa = pEmpresa
		   AND num_credito = pCredito
		   AND folio_suc = pFolio
		   AND transacc_suc = vTranRelac;
	END IF

        EXECUTE PROCEDURE abono_cred(pEmpresa, pCredito, pSucursal,
                                     pUsuario,vTranRelac, pMonto,
                                     pFolio, pTarjeta, pMontoDls,
                                     pTpCambio, pFecha, pReferencia,"R",
					       pRfcComer,pRef23)

	INTO cod_ret;

   END IF


   RETURN cod_ret;


END PROCEDURE
DOCUMENT
'Esta funcion se encarga de realizar los movimientos de abono y reversion ',
'relacionados a la tarjeta de credito',
'AUTOR : Procesaminto Interactivo S.A.',
'FECHA : 23/01/2006',
'BD : bdicred ',
'CLIENTE : COPPEL';

create procedure "informix".sp_consultafecha (dfecini char(10),dfecfin char(10))
        returning  char(5),char(20),money,date,DateTime Hour to Second,char(35),char(35),char(20),char(200) ;
        define cCodret char(5);
        define cCuenta char(20);
        define mImporte money ; --(14,2);
        define dFecha date ;
        define dHora DateTime Hour to Second ;
        define cDescripcion char(35);
        define cDescripcion2 char(35);
        define cNombre char(200);
        define cRfc char(20);
        define cSQL_ERR integer;

        let cCuenta = "";
        let mImporte= 0;
        let cDescripcion = "";
        let cDescripcion2 = "";
        let cNombre = "";
        let cRfc = "";
        let cSQL_ERR = 100 ;
        let cCodret  = "00000";
        let dFecha = "" ;
        let dHora = '' ;


--SET DEBUG FILE TO '/tmp/consxcta.out';
--TRACE ON;

BEGIN
                ON EXCEPTION SET cSQL_ERR
                LET cCodret = cSQL_ERR;
                RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre;
                END EXCEPTION;

FOREACH

select hb.cuenta,
NVL(TRIM(si_cliente.nombre1),"") ||' '|| NVL(TRIM(si_cliente.nombre2),"") ||' '|| NVL(TRIM(si_cliente.apell_paterno),"") ||' '|| NVL(TRIM(si_cliente.apell_materno),""),
rfc,cb.descripcion,ob.descripcion,hb.importe,hb.fecha,hb.hora
INTO
    cCuenta,cNombre,cRfc, cDescripcion, cDescripcion2, mImporte, dFecha, dHora
 from bdicheq:sc_maechq mae
             INNER JOIN bdinteg:si_cliente si_cliente on si_cliente.numcte= mae.num_cte
             INNER JOIN bdicheq:sc_histbloq hb on hb.cuenta=mae.cuenta
             INNER JOIN bdicheq:sc_opcionbloqueo ob  on ob.opcion= hb.opcion
             INNER JOIN bdicheq:sc_bloqueo cb on  cb.codigo=hb.motivo
where hb.fecha>=dfecini  and hb.fecha<=dfecfin
             order by hb.fecha desc,hb.hora desc

     RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre with resume ;
END FOREACH;


end;
end procedure
DOCUMENT
'AUTOR :Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se creo el sp para el llenado del reporte por periodo de fechas de bloqueo.',
'Captacion',
'FECHA : Septiembre de 2008',
'VERSION: 200809',
'BD    : BDICHEQ';

create procedure "informix".sp_consultacta(cCta char(20))
        returning  char(5),char(20),money,date,DateTime Hour to Second,char(35),char(35),char(20),char(200) ;
        define cCodret char(5);
        define cCuenta char(20);
        define mImporte money ; --(14,2);
        define dFecha date ;
        define dHora DateTime Hour to Second ;
        define cDescripcion char(35);
        define cDescripcion2 char(35);
        define cNombre char(200);
        define cRfc char(20);
        define cSQL_ERR integer;

        let cCuenta = "";
        let mImporte= 0;
        let cDescripcion = "";
        let cDescripcion2 = "";
        let cNombre = "";
        let cRfc = "";
        let cSQL_ERR = 100 ;
        let cCodret  = "00000";
        let dFecha = "" ;
        let dHora = '' ;


--SET DEBUG FILE TO '/tmp/consxcta.out';
--TRACE ON;

BEGIN
                ON EXCEPTION SET cSQL_ERR
                LET cCodret = cSQL_ERR;
                RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre;
                END EXCEPTION;

FOREACH

select hb.cuenta,
NVL(TRIM(si_cliente.nombre1),"") ||' ' || NVL(TRIM(si_cliente.nombre2),"") ||' '|| NVL(TRIM(si_cliente.apell_paterno),"") ||' '|| NVL(TRIM(si_cliente.apell_materno),""),
rfc,cb.descripcion,ob.descripcion,hb.importe,hb.fecha,hb.hora
INTO
        cCuenta,cNombre,cRfc, cDescripcion, cDescripcion2, mImporte, dFecha, dHora
 from bdicheq:sc_maechq mae
             INNER JOIN bdinteg:si_cliente si_cliente on si_cliente.numcte= mae.num_cte
             INNER JOIN bdicheq:sc_histbloq hb on hb.cuenta=mae.cuenta
             INNER JOIN bdicheq:sc_opcionbloqueo ob  on ob.opcion= hb.opcion
             INNER JOIN bdicheq:sc_bloqueo cb on  cb.codigo=hb.motivo
where mae.cuenta= cCta
             order by hb.fecha desc,hb.hora desc

     RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre with resume ;
END FOREACH;


end;
end procedure
DOCUMENT
'AUTOR :Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se creo el sp para el llenado del reporte por cuenta de bloqueo.',
'Captacion',
'FECHA : Septiembre de 2008',
'VERSION: 200809',
'BD    : BDICHEQ';

Create procedure "informix".sp_consultaclave(cClave char(35), dFecha1 char(10), dFecha2 char(10))
    Returning  char(5),char(20),money,date,DateTime Hour to Second,char(35),char(35),char(20),char(200);
		
	define cCodret char(5);
	define cCuenta char(20);
	define mImporte money ; --(14,2);
	define dFecha date ;
	define dHora DateTime Hour to Second ;
	define cDescripcion char(35);
	define cDescripcion2 char(35);
	define cNombre char(200);
	define cRfc char(20);
	define cSQL_ERR integer;

	let cCuenta = "";
	let mImporte= 0;
	let cDescripcion = "";
	let cDescripcion2 = "";
	let cNombre = "";
	let cRfc = "";
	let cSQL_ERR = 100 ;
	let cCodret  = "000";
	let dFecha = "" ;
	let dHora = '' ;


--SET DEBUG FILE TO '/tmp/consxcta.out';
--TRACE ON;

BEGIN
	ON EXCEPTION SET cSQL_ERR
	LET cCodret = cSQL_ERR;
	RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre;
	END EXCEPTION;

    FOREACH
        Select hb.cuenta, NVL(TRIM(si_cliente.nombre1),"") ||' '|| NVL(TRIM(si_cliente.nombre2),"") ||' '
            || NVL(TRIM(si_cliente.apell_paterno),"") ||' '|| NVL(TRIM(si_cliente.apell_materno),""),
            rfc,cb.descripcion,ob.descripcion,hb.importe,hb.fecha,hb.hora
        INTO cCuenta,cNombre,cRfc, cDescripcion, cDescripcion2, mImporte, dFecha, dHora
        From bdicheq:sc_maechq mae
			INNER JOIN bdinteg:si_cliente si_cliente on si_cliente.numcte= mae.num_cte
			INNER JOIN bdicheq:sc_histbloq hb on hb.cuenta=mae.cuenta
			INNER JOIN bdicheq:sc_opcionbloqueo ob  on ob.opcion= hb.opcion
			INNER JOIN bdicheq:sc_bloqueo cb on  cb.codigo=hb.motivo
        Where cb.descripcion = cClave
			And hb.fecha >= dFecha1 And hb.fecha <= dFecha2
        Order by hb.fecha desc,hb.hora desc

        RETURN cCodret,cCuenta, mImporte , dFecha, dHora, cDescripcion, cDescripcion2, cRfc, cNombre with resume;

    END FOREACH;


end;
end procedure
DOCUMENT
'AUTOR :Jesus Antonio Bastidas Lopez',
'DESCRIPCION: Se creo el sp para el llenado del reporte por clave de bloqueo.',
'Captacion',
'FECHA : Septiembre de 2008',
'VERSION: 200809',
'BD    : BDICHEQ';

CREATE PROCEDURE "informix".desbloq_cuentas(pempresa char(3))

RETURNING CHAR(5);

   DEFINE vcodret     	CHAR(5);
   DEFINE sql_err     	INTEGER;
   DEFINE vcuenta	CHAR(20);
   DEFINE vstatus 	CHAR(1);
   DEFINE vmotivo 	CHAR(2);
   DEFINE vfecha	DATE;
   DEFINE vhora		CHAR(15);
   DEFINE vfolio	CHAR(20);

   LET vcodret = "000";

   BEGIN

   ON EXCEPTION
       SET sql_err
       IF sql_err <> 0 THEN
	    LET vcodret = sql_err;
           RETURN vcodret;
       END IF;
   END EXCEPTION;

   -- SET DEBUG FILE TO "./desbloq_cuentas.out";
   -- TRACE ON;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

   SELECT fecha_hoy
     INTO vfecha
     FROM sc_fechas
    WHERE empresa = pempresa;

   LET vhora = current hour to fraction;

   LET vfolio = "informix"||vhora[1,2]||vhora[4,5]||vhora[7,8]||vhora[10,11];
   
   FOREACH
       SELECT UNIQUE cuenta
	 INTO vcuenta
         FROM cuentas_desbloq
        WHERE cuenta IS NOT NULL

	SELECT status_cta, motivo
	  INTO vstatus, vmotivo
	  FROM sc_maechq
	 WHERE empresa = pempresa
	   AND cuenta = vcuenta;

	IF vstatus = "3" AND vmotivo = "09" THEN

            UPDATE sc_maechq
               SET status_cta = "1",
	           motivo = "00"
	     WHERE empresa = pempresa
               AND cuenta = vcuenta;

	    INSERT INTO sc_histbloq VALUES(
			pempresa, vcuenta, "D", "00", " ",
	                0.00, "informix", vfecha,
			current hour to fraction,
			"1111", "D", vfolio, " ");

	    INSERT INTO sc_ctabloqueohist VALUES (vcuenta, "09", 4);

            DELETE FROM sc_ctabloqueo
	     WHERE cuenta = vcuenta;

	END IF;

   END FOREACH

   END;

   RETURN vcodret;

END PROCEDURE;