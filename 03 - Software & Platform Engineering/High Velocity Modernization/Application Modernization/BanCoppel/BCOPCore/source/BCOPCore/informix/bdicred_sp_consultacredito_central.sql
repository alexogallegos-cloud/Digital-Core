CREATE PROCEDURE "informix".sp_consultacredito_central(pEmpresa CHAR(3), pNumeroCredito CHAR(20))
RETURNING CHAR(6),CHAR(80),CHAR(20),CHAR(104),DECIMAL(18,2);

DEFINE cNumCte          CHAR(20);
DEFINE dMontoOtorgado   DECIMAL(18,2);
DEFINE cNombreCte       CHAR(104);

DEFINE iSqlErr      	INTEGER;
DEFINE iIsamErr         INTEGER;
DEFINE cErrorInfo       CHAR(80);
DEFINE cCodRet          CHAR(6); 
DEFINE cMensajeRet      CHAR(80);

BEGIN

ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
   IF iSqlErr != 0 THEN
      LET cCodRet= iSqlErr;
      LET cMensajeRet= cErrorInfo;
      RETURN cCodRet, cMensajeRet, NVL(cNumCte,''), NVL(cNombreCte,''), NVL(dMontoOtorgado,0);
   END IF;
END EXCEPTION;

-- Se genera archivo DEBUG!
 --SET DEBUG FILE TO '/tmp/sp_consultacredito_central.out';
 --TRACE ON;

LET cCodRet= '000000';
LET cMensajeRet= "Se realizo la consulta correctamente";
LET cNumCte= "";
LET cNombreCte= "";
LET dMontoOtorgado= 0;

    IF EXISTS(SELECT a.num_credito FROM bdicred:sd_tarjeta a WHERE a.empresa= pEmpresa  AND a.num_credito = pNumeroCredito) THEN

        -- Se obtiene el monto de la linea "ACTUAL" (monto_otorgado)
          SELECT a.numcte, b.monto_otorgado
            INTO cNumCte, dMontoOtorgado
            FROM bdicred:sd_maecred a, bdicred:sd_maesdos b, bdicred:sd_definicion c
           WHERE a.empresa      = b.empresa
             AND a.num_credito  = b.num_credito
             AND a.empresa      = c.empresa
             AND a.num_producto = c.num_producto
             AND a.empresa      = pEmpresa
             AND a.num_credito  = pNumeroCredito;

        -- Se obtiene el nombre del cliente
            SELECT decode(nvl(a.razon_social,''), '', TRIM(nvl(a.nombre1,'')) ||' '||
                                                      TRIM(nvl(a.nombre2,'')) ||' '||
                                                      TRIM(nvl(a.apell_paterno,'')) ||' '||
                                                      TRIM(nvl(a.apell_materno,'')),
                                                      TRIM(a.razon_social))
              INTO cNombreCte
              FROM bdinteg:si_cliente a
             WHERE a.empresa = pEmpresa
               AND a.numcte = cNumCte;

    ELSE
        LET cCodRet= '000001';
        LET cMensajeRet= "El numero de credito no existe";
        RETURN cCodRet, cMensajeRet, cNumCte, cNombreCte, dMontoOtorgado;
    END IF;

    RETURN cCodRet, cMensajeRet, NVL(cNumCte,''), NVL(cNombreCte,''), NVL(dMontoOtorgado,0);
		
END

END PROCEDURE
DOCUMENT 
'Se realiza procedimiento para obtener',
'la consulta del credito al central',
'AUTOR : Paul Ivan Quintero Varela',
'FECHA : 19/Diciembre/2008',
'BD    : BDICRED';

CREATE PROCEDURE "informix".sp_crea_cambio_linea()

RETURNING char(6);


    DEFINE cCodRet                  char(6);
    DEFINE sql_err                  integer;
    DEFINE isam_err                 integer;
    DEFINE cSql                     char(1024);


	    
    ON EXCEPTION SET sql_err,isam_err
      LET cCodRet = sql_err;
      RETURN cCodRet;
   END EXCEPTION;
   
   --SET DEBUG FILE TO "/tmp/CAMBIO_LINEA.out";
   --TRACE ON;

    LET cCodRet = "000000";
    
    LET cSql= "";

IF EXISTS( SELECT dbsname, tabname FROM sysmaster:systabnames  WHERE tabname = 'cambio_linea') THEN
                DROP TABLE bdicred:cambio_linea;
End if;
        CREATE TABLE bdicred:cambio_linea(
                num_solicitud   CHAR(20),
                monto           DECIMAL(14,2));    

 RETURN cCodRet;

END PROCEDURE
DOCUMENT
'AUTOR :Roque Enrique Solis Campaña',
'DESCRIPCION: Se creó el sp para crear la tabla cambio linea y si esta creado borrarla',
'Crédito',
'FECHA : Enero de 2009',
'VERSION: 200901',
'BD    : BDICRED';

CREATE PROCEDURE "informix".interes_vencido_cero(pempresa CHAR(3))
RETURNING CHAR(6)


----definicion de variables 
    DEFINE cCodRet          CHAR(6);
    DEFINE iSqlErr          INTEGER;
    DEFINE cMensaje         CHAR(250);
    DEFINE v_folio	        CHAR(16);
    DEFINE vcredito         CHAR(20);
    DEFINE vestatus         CHAR(2);
    DEFINE interes_vencido  DECIMAL(18,2);
    DEFINE iva_vencido      DECIMAL(18,2);
    DEFINE vsucursal        CHAR(4);
    DEFINE vcodigo_fun      CHAR(3);
    DEFINE vcodigo_ref      INTEGER;

        ON EXCEPTION SET iSqlErr
           IF iSqlErr != 0 THEN
              ROLLBACK;
              LET cCodRet=iSqlErr;
              RETURN cCodRet;
           END IF;
        END EXCEPTION;

  --      SET DEBUG FILE TO "condona_interes.out";
  --      TRACE ON;

----inicializacion

    LET cCodRet='000000';
    LET vcodigo_fun='005';

	set isolation to dirty read;
	set lock mode to wait 5;

    FOREACH WITH HOLD 
        select a.num_credito, status_cred, int_tra_no_exig,
        (select sum(iva_debe - iva_pagado) from bdicred:sd_amortiza_credito 
         where a.empresa = empresa and a.num_credito = num_credito 
         and fecha_cuota < mdy('02','20','2009')),a.sucursal
         into vcredito, vestatus,interes_vencido,iva_vencido,vsucursal
        from bdicred:sd_maecred a,
             bdicred:sd_maesdos b
        where a.empresa=pempresa
          and a.empresa = b.empresa
          and a.num_credito = b.num_credito
          and a.status_cred in ('AA','BA')
          and int_tra_no_exig > 0

    BEGIN WORK;

        UPDATE bdicred:sd_maesdos
        SET int_tra_no_exig=0
        WHERE empresa=pempresa
        AND num_credito=vcredito;

        LET v_folio='ints'||vcredito;
        LET vcodigo_ref=13;

        EXECUTE PROCEDURE GENMOV( pempresa         , vcredito,
                                  ''       ,vcodigo_ref,
                                  vcodigo_fun      , today,
                                  interes_vencido    , v_folio,
                                  vsucursal        ,'',
                                  "0000")
        INTO cCodRet,cMensaje;


        UPDATE bdicred:sd_amortiza_credito
        SET interes_pagado=interes_debe,
            iva_pagado=iva_debe,
            interes_status= (case when interes_status='3' then '5' else interes_status end),
	        campo_trabajo2= (case when interes_status='3' then 1 else 0 end),
            campo_trabajo3= interes_pagado,
            campo_trabajo4= iva_pagado
        WHERE empresa=pempresa
        AND num_credito=vcredito
        AND fecha_cuota<mdy('02','20','2009')
        and ( interes_pagado<>interes_debe or iva_pagado<>iva_debe);

        LET v_folio='ivav'||vcredito;
        LET vcodigo_ref=14;

        EXECUTE PROCEDURE GENMOV( pempresa         , vcredito,
                                  ''       ,vcodigo_ref,
                                  vcodigo_fun     , today,
                                  iva_vencido    , v_folio,
                                  vsucursal        ,'',
                                  "0000")
        INTO cCodRet,cMensaje;

    COMMIT WORK;

    END FOREACH;
     RETURN cCodRet;
END PROCEDURE;