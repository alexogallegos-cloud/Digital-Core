CREATE PROCEDURE "informix".sp_consulta_disposiciones_general (pEmpresa CHAR(3),
                                                               pNumCredito CHAR(20))
RETURNING CHAR(6)  AS Codigo_Retorno,
          CHAR(80) AS Mensaje_Retorno,
          DATE     AS Fecha,
          DATETIME HOUR TO FRACTION(3) AS Hora,
          CHAR(16) AS Referencia,
          DECIMAL(18,2) AS Monto,
          VARCHAR(140)  AS Tipo,
          DECIMAL(18,2) AS Linea_disponible;

--*******************************************************************************************************
-- Realizo    : Jose Luis Pulido Zepeda
-- Proyecto  : Consulta generalizada de credito
-- Actividad: Realizar la consulta de las disposiciones que realizo un crÃ©dito determinado
-- Fecha       : 22-06-2009
--*******************************************************************************************************
-- Autor     : Roque Solis C.
-- Proyecto  : Consulta generalizada de credito
-- Modificacion: Se agrego la consulta de la linea disponible
-- Fecha          : 25-06-2009
--*******************************************************************************************************
-- Autor     : Roque Solis C.
-- Proyecto  : Prestamos personales
-- Modificacion: Se agrego la consulta para las disposiciones de prestamos personales
-- Fecha          : 08/10/2009
--*******************************************************************************************************

DEFINE cCodRet        CHAR(6);
DEFINE cErrorInfo     CHAR(80);
DEFINE cErrorInfoR    CHAR(80);
DEFINE iSqlerr        INTEGER;
DEFINE iIsamErr       SMALLINT;

DEFINE dtFechaMov     DATE;
DEFINE dtHoraMov      DATETIME HOUR TO FRACTION;
DEFINE cFolioSuc      CHAR(16);
DEFINE dMonto         DECIMAL(18,2);
DEFINE vDescripcion   VARCHAR(140);
DEFINE iRegistros     INTEGER;

DEFINE iSecuencia     INTEGER;
DEFINE dLinAut        DECIMAL(18,2);

DEFINE cNumCredito    CHAR(20);
DEFINE cNumProducto   CHAR(4);
DEFINE cTipCred       CHAR(2);

LET cCodRet         = '000000';
LET cErrorInfo      = "";
LET cErrorInfoR     = "OPERACION EXITOSA";
LET iSqlerr         = 0;
LET iIsamErr        = 0;

LET dtFechaMov     = DATE(1);
LET dtHoraMov      = CURRENT;
LET cFolioSuc      = "";
LET dMonto          = 0;
LET vDescripcion    = "";
LET iRegistros      = 0;

LET iSecuencia      = 0;
LET dLinAut         = 0;
LET cNumCredito     = '';
LET cNumProducto    = '';
LET cTipCred        = '';

BEGIN

	ON EXCEPTION  SET iSqlerr, iIsamErr, cErrorInfo
		IF iSqlerr <> 0  THEN
			LET cCodRet     = iSqlerr;
			LET cErrorInfoR = cErrorInfo;
			RETURN cCodRet, cErrorInfoR, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,''), NVL(dLinAut,0);
		END IF;
	END  EXCEPTION


--SET DEBUG FILE TO "/tmp/sp_consulta_disposiciones_general.out";
--TRACE ON;

--SET ISOLATION TO COMMITTED READ LAST COMMITTED;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;


IF NVL(TRIM(pEmpresa),'')='' OR NVL(TRIM(pNumCredito),'')='' THEN
        LET cCodRet     = '000001';
        LET cErrorInfoR ='LOS DATOS DE ENTRADA SON INCORRECTOS';
     RETURN cCodRet, cErrorInfoR, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,''), NVL(dLinAut,0);
END IF;

   
 SELECT a.num_producto, cod_tipcred
   INTO cNumProducto, cTipCred
   FROM "informix".sd_maecred a, "informix".sd_definicion b
  WHERE num_credito=pNumCredito
    AND a.num_producto= b.num_producto;

IF cNumProducto IS NOT NULL THEN

			SELECT NVL(monto_otorgado,0) - (NVL(sdo_cap_insoluto,0) + NVL(sdo_retenido,0))
			  INTO dLinAut
			  FROM "informix".sd_maecred a, "informix".sd_maesdos b
			 WHERE b.num_credito = a.num_credito
			   AND b.empresa = a.empresa
			   AND a.num_credito = pNumCredito
			   AND a.empresa = pEmpresa;

			FOREACH
  			    SELECT fecha_mov,
			           EXTEND(hora_mov, HOUR TO SECOND),
			           folio_suc,
			           monto,
			           TRIM(b.descripcion) ||  ' ' || NVL(UPPER(TRIM(SUBSTR(a.referencia,16,280))),''),
			           a.secuencia
			      INTO dtFechaMov,
			           dtHoraMov,
			           cFolioSuc,
			           dMonto,
			           vDescripcion,
			           iSecuencia
			      FROM bdicred:sd_movhis_new a
			 LEFT JOIN bdicred:sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
			 LEFT JOIN bdinteg:si_transacc c ON (a.empresa = c.empresa AND b.transacc = c.numero)
			 LEFT JOIN bdinteg:si_prodtran d ON (a.empresa = d.empresa AND b.transacc = d.transaccion and d.producto=a.num_producto)
			     WHERE a.empresa = pEmpresa
			       AND num_credito = pNumCredito
			       AND reversado = 'N'
			       AND se_contabiliza = 'S'
			       AND TRIM(c_ccmayor) IN ('1311','1361','1402','7710','7837','9512','2402','1312')
			       AND se_emite_edocta = 'S'
			       AND c.sistema = '06'
			 UNION ALL
			    SELECT fecha_mov,
			           EXTEND(hora_mov, HOUR TO SECOND),
			           folio_suc,
			           monto,
			           TRIM(b.descripcion) ||  ' ' || NVL(UPPER(TRIM(SUBSTR(a.referencia,16,280))),''),
			           a.secuencia
			      FROM bdicred:sd_movhis a
			 LEFT JOIN bdicred:sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
			 LEFT JOIN bdinteg:si_transacc c ON (a.empresa = c.empresa AND b.transacc = c.numero)
			 LEFT JOIN bdinteg:si_prodtran d ON (a.empresa = d.empresa AND b.transacc = d.transaccion and d.producto=a.num_producto)
			     WHERE a.empresa = pEmpresa
			       AND num_credito = pNumCredito
			       AND reversado = 'N'
			       AND se_contabiliza = 'S'
			       AND TRIM(c_ccmayor) IN ('1311','1361','1402','7710','7837','9512','2402','1312')
			       AND se_emite_edocta = 'S'
			       AND c.sistema = '06'
			 UNION ALL
			    SELECT fecha_mov,
			           EXTEND(hora_mov, HOUR TO SECOND),
			           folio_suc,
			           monto,
			           TRIM(b.descripcion) ||  ' ' || NVL(UPPER(TRIM(SUBSTR(a.referencia,16,280))),''),
			           a.secuencia
			      FROM bdicred:sd_movdia a
			 LEFT JOIN bdicred:sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
			 LEFT JOIN bdinteg:si_transacc c ON (a.empresa = c.empresa AND b.transacc = c.numero)
			 LEFT JOIN bdinteg:si_prodtran d ON (a.empresa = d.empresa AND b.transacc = d.transaccion and d.producto=a.num_producto)
			     WHERE a.empresa = pEmpresa
			       AND num_credito = pNumCredito
			       AND reversado = 'N'
			       AND se_contabiliza = 'S'
			       AND TRIM(c_ccmayor) IN ('1311','1361','1402','7710','7837','9512','2402','1312')
			       AND se_emite_edocta  = 'S'
			       AND c.sistema = '06'
			  ORDER BY a.fecha_mov DESC
			    RETURN cCodRet, cErrorInfoR, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,''), NVL(dLinAut,0) WITH RESUME;
			END FOREACH;

			   LET iRegistros = DBINFO("sqlca.sqlerrd2");
			   IF iRegistros  = 0 THEN
			      LET cCodRet  = '000002';
			      LET cErrorInfoR = 'NO SE OBTUVIERON RESULTADOS';
			      RETURN cCodRet, cErrorInfoR, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,''), NVL(dLinAut,0);
			   END IF;
END IF;
   
 SELECT a.num_producto, cod_tipcred
   INTO cNumProducto, cTipCred
   FROM "informix".sd_maecredcrd a, "informix".sd_definicion b
  WHERE num_credito=pNumCredito
    AND a.num_producto= b.num_producto;
	
   IF cTipCred ='05' THEN   -- 05   Prestamos
       SELECT NVL(monto_otorgado,0) - (NVL(sdo_cap_insoluto,0) + NVL(sdo_retenido,0))
			  INTO dLinAut
			  FROM "informix".sd_maecredcrd a, "informix".sd_maesdoscrd b
			 WHERE b.num_credito = a.num_credito
			   AND b.empresa = a.empresa
			   AND a.num_credito = pNumCredito
			   AND a.empresa = pEmpresa;

			FOREACH
			    SELECT fecha_mov,
			           EXTEND(hora_mov, HOUR TO SECOND),
			           folio_suc,
			           monto,
			           TRIM(b.descripcion) ||  ' ' || NVL(UPPER(TRIM(SUBSTR(a.referencia,16,280))),''),
			           a.secuencia
			      INTO dtFechaMov,
			           dtHoraMov,
			           cFolioSuc,
			           dMonto,
			           vDescripcion,
			           iSecuencia
			      FROM bdicred:sd_movhiscrd a
			 LEFT JOIN bdicred:sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
			 LEFT JOIN bdinteg:si_transacc c ON (a.empresa = c.empresa AND b.transacc = c.numero)
			 LEFT JOIN bdinteg:si_prodtran d ON (a.empresa = d.empresa AND b.transacc = d.transaccion and d.producto=a.num_producto)
			     WHERE a.empresa = pEmpresa
			       AND num_credito = pNumCredito
			       AND reversado = 'N'
			       AND se_contabiliza = 'S'
			       AND TRIM(a_ccmayor) ='9513'
			       AND se_emite_edocta = 'S'
			       AND c.sistema = '06'
			 UNION ALL
			    SELECT fecha_mov,
			           EXTEND(hora_mov, HOUR TO SECOND),
			           folio_suc,
			           monto,
			           TRIM(b.descripcion) ||  ' ' || NVL(UPPER(TRIM(SUBSTR(a.referencia,16,280))),''),
			           a.secuencia
			      FROM bdicred:sd_movdiacrd a
			 LEFT JOIN bdicred:sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
			 LEFT JOIN bdinteg:si_transacc c ON (a.empresa = c.empresa AND b.transacc = c.numero)
			 LEFT JOIN bdinteg:si_prodtran d ON (a.empresa = d.empresa AND b.transacc = d.transaccion and d.producto=a.num_producto)
			     WHERE a.empresa = pEmpresa
			       AND num_credito = pNumCredito
			       AND reversado = 'N'
			       AND se_contabiliza = 'S'
			       AND TRIM(a_ccmayor) ='9513'
			       AND se_emite_edocta  = 'S'
			       AND c.sistema = '06'
			  ORDER BY a.fecha_mov DESC
			  
			    RETURN cCodRet, cErrorInfoR, NVL(dtFechaMov,DATE(1)), 
				       NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), 
					   NVL(vDescripcion,''), NVL(dLinAut,0) WITH RESUME;
				
			END FOREACH;

			   LET iRegistros = DBINFO("sqlca.sqlerrd2");
			   IF iRegistros  = 0 THEN
			      LET cCodRet  = '000002';
			      LET cErrorInfoR = 'NO SE OBTUVIERON RESULTADOS';
			      RETURN cCodRet, cErrorInfoR, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,''), NVL(dLinAut,0);
			   END IF;
   END IF;

   IF cTipCred ='03' THEN  -- 03              reeestructuras
       SELECT NVL(monto_otorgado,0) - (NVL(sdo_cap_insoluto,0) + NVL(sdo_retenido,0))
			  INTO dLinAut
			  FROM "informix".sd_maecredcrd a, "informix".sd_maesdoscrd b
			 WHERE b.num_credito = a.num_credito
			   AND b.empresa = a.empresa
			   AND a.num_credito = pNumCredito
			   AND a.empresa = pEmpresa;

			FOREACH
			    SELECT fecha_mov,
			           EXTEND(hora_mov, HOUR TO SECOND),
			           folio_suc,
			           monto,
			           TRIM(b.descripcion) ||  ' ' || NVL(UPPER(TRIM(SUBSTR(a.referencia,16,280))),''),
			           a.secuencia
			      INTO dtFechaMov,
			           dtHoraMov,
			           cFolioSuc,
			           dMonto,
			           vDescripcion,
			           iSecuencia
			      FROM bdicred:sd_movhiscrd a
			 LEFT JOIN bdicred:sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
			 LEFT JOIN bdinteg:si_transacc c ON (a.empresa = c.empresa AND b.transacc = c.numero)
			 LEFT JOIN bdinteg:si_prodtran d ON (a.empresa = d.empresa AND b.transacc = d.transaccion and d.producto=a.num_producto)
			     WHERE a.empresa = pEmpresa
			       AND num_credito = pNumCredito
			       AND reversado = 'N'
			       AND se_contabiliza = 'S'
			       AND TRIM(a_ccmayor) ='8824'
			     --  AND se_emite_edocta = 'S'
			       AND c.sistema = '06'
			 UNION ALL
			    SELECT fecha_mov,
			           EXTEND(hora_mov, HOUR TO SECOND),
			           folio_suc,
			           monto,
			           TRIM(b.descripcion) ||  ' ' || NVL(UPPER(TRIM(SUBSTR(a.referencia,16,280))),''),
			           a.secuencia
			      FROM bdicred:sd_movdiacrd a
			 LEFT JOIN bdicred:sd_transfun b ON (a.empresa = b.empresa AND a.codigo_fun = b.codigo_fun AND a.codigo_ref = b.codigo_ref)
			 LEFT JOIN bdinteg:si_transacc c ON (a.empresa = c.empresa AND b.transacc = c.numero)
			 LEFT JOIN bdinteg:si_prodtran d ON (a.empresa = d.empresa AND b.transacc = d.transaccion and d.producto=a.num_producto)
			     WHERE a.empresa = pEmpresa
			       AND num_credito = pNumCredito
			       AND reversado = 'N'
			       AND se_contabiliza = 'S'
			       AND TRIM(a_ccmayor) ='8824'
			     --  AND se_emite_edocta  = 'S'
			       AND c.sistema = '06'
			  ORDER BY a.fecha_mov DESC
			  
			    RETURN cCodRet, cErrorInfoR, NVL(dtFechaMov,DATE(1)), 
				       NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), 
					   NVL(vDescripcion,''), NVL(dLinAut,0) WITH RESUME;
				
			END FOREACH;

			   LET iRegistros = DBINFO("sqlca.sqlerrd2");
			   IF iRegistros  = 0 THEN
			      LET cCodRet  = '000002';
			      LET cErrorInfoR = 'NO SE OBTUVIERON RESULTADOS';
			      RETURN cCodRet, cErrorInfoR, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,''), NVL(dLinAut,0);
			   END IF;
   END IF;

   IF iRegistros  = 0 THEN
	      LET cCodRet  = '000002';
	      LET cErrorInfoR = 'NO SE OBTUVIERON RESULTADOS';
	      RETURN cCodRet, cErrorInfoR, NVL(dtFechaMov,DATE(1)), NVL(dtHoraMov,CURRENT), NVL(cFolioSuc,''), NVL(dMonto,0), NVL(vDescripcion,''), NVL(dLinAut,0);
    END IF;

END;
END PROCEDURE;