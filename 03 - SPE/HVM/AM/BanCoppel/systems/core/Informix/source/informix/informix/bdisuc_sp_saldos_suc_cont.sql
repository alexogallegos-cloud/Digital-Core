CREATE PROCEDURE "informix".sp_saldos_suc_cont(pempresa CHAR(3),
                                               pfecha date,
                                               ptpo_suc   char(1))

RETURNING VARCHAR(5),          -- CodigoRetorno
          VARCHAR(255)         -- DescripcionError

DEFINE cVarDataErr  VARCHAR(64);
DEFINE iSqlErr      INTEGER;
DEFINE iSamErr      INTEGER;
DEFINE vCodRet      CHAR(5);
DEFINE vfecha_cont  DATE;

DEFINE vsucursal    VARCHAR(4);
DEFINE vfecha_hoy   DATE;
DEFINE vsaldosuc    MONEY(14,2);
DEFINE vsaldocont   MONEY(14,2);
DEFINE vrowid       INTEGER;
DEFINE v_sql        char(400);


LET vcodret = "000";
LET vsucursal = "";


BEGIN
    ON EXCEPTION SET iSqlErr, iSamErr, cVarDataErr
	   IF iSqlErr <> 0 THEN
          LET vCodret = iSqlErr;
	      RETURN vCodret, cVarDataErr;
	   END IF;
	END EXCEPTION;

--SET debug file to "saldos.out";
--trace on;

SET ISOLATION TO DIRTY READ;

--- Verifica recepcion correcta de datos
IF pempresa = '' or ptpo_suc = '' then
   LET vCodret = "101";
   LET cVarDataErr='Falta Parámetros, Favor de Verificar !!!';
   return vCodret,cVarDataErr;
ELSE

   SELECT fecha_hoy 
     INTO vfecha_cont
    FROM bdicont:co_fechas;

   IF vfecha_cont <= pfecha THEN
      LET vCodret = "001";
      LET cVarDataErr='Fecha de Consulta es Mayor o Igual a la Fecha de Contabilidad';
      return vCodret,cVarDataErr;
   End if;

  IF pfecha= '' or pfecha is null THEN
     LET pfecha=vfecha_cont - 1;
  END IF

   TRUNCATE ss_concilsdocont;

   INSERT INTO bdisuc:ss_concilsdocont(sucursal, descsucursal, cod_proveedor, descprovedor, saldosuc, fecha_concil) 
       SELECT a.sucursal, a.nombre, b.cod_proveedor, b.descripcion, s.saldo_total, s.fecha
       FROM bdinteg:si_sucursales a, bdisuc:ss_proveedores b, bdisuc:ss_saldossuc s
       WHERE b.plaza = a.plaza_cajagen 
         AND a.empresa= pempresa 
         AND a.sucursal = s.sucursal 
         AND s.fecha = pfecha 
         AND a.tpo_sucursal = ptpo_suc;

   INSERT INTO bdisuc:ss_concilsdocont(sucursal, descsucursal, cod_proveedor, descprovedor, saldosuc, fecha_concil) 
      SELECT b.cod_proveedor,'CAJA GENERAL', b.cod_proveedor, b.descripcion, s.saldo_total, pfecha
       FROM bdisuc:ss_cajageneral s, bdisuc:ss_proveedores b 
       WHERE s.empresa = pempresa
         AND s.cod_proveedor = b.cod_proveedor;

   
   IF YEAR(pfecha)  = YEAR(vfecha_cont)  AND  MONTH(pfecha) = MONTH(vfecha_cont) THEN
      foreach 
        SELECT rowid,sucursal, saldosuc
          INTO  vrowid, vsucursal, vsaldosuc
          FROM  bdisuc:ss_concilsdocont

         SELECT sum(saldo_fin_de_dia)  
           INTO vsaldocont
           FROM bdicont: co_sdodias 
           WHERE empresa = pempresa
            AND ccmayor='1101' 
            AND ccsub='01' 
            AND ccsubsub ='00' 
            AND ccssubsub='00'
            AND ccsssubsub='00' 
            AND sector='00' 
            AND ciudad is NOT NULL
            AND sucursal = vsucursal
            AND moneda ='01' -- Moneda Nacional
            AND mes_dia = pfecha ;

         UPDATE bdisuc:ss_concilsdocont set saldocont=vsaldocont, saldodiff= vsaldosuc - vsaldocont where rowid=vrowid;

      end foreach; 
   ELSE
        foreach 
        SELECT rowid,sucursal , saldosuc
          INTO  vrowid, vsucursal, vsaldosuc
          FROM  bdisuc:ss_concilsdocont

         SELECT sum(saldo_fin_de_dia)  
           INTO vsaldocont
           FROM bdicont: co_histsdodias
           WHERE empresa = pempresa
            AND ccmayor='1101' 
            AND ccsub='01' 
            AND ccsubsub ='00' 
            AND ccssubsub='00'
            AND ccsssubsub='00' 
            AND sector='00' 
            AND ciudad is NOT NULL
            AND sucursal = vsucursal
            AND moneda ='01' -- Moneda Nacional
            AND mes_dia = pfecha ;

         UPDATE bdisuc:ss_concilsdocont set saldocont=vsaldocont, saldodiff= vsaldosuc - vsaldocont where rowid=vrowid;
         
        end foreach; 
   END IF;

      let v_sql = 'echo "UNLOAD TO ss_concilsdocont.unl' ||
                  ' SELECT * FROM bdisuc:ss_concilsdocont ORDER BY cod_proveedor asc" > cgconcilsdocont.sql';
      SYSTEM v_sql;
      LET v_sql = "dbaccess bdisuc cgconcilsdocont.sql ";
      SYSTEM v_sql;
/* 
     TRUNCATE ss_concilsdocont;

      let v_sql = 'echo "LOAD FROM ss_concilsdocont.unl' ||
                  ' INSERT INTO bdisuc:ss_concilsdocont" > cgconcilsdocont.sql  ';
      SYSTEM v_sql;
      LET v_sql = "dbaccess bdisuc cgconcilsdocont.sql ";
      SYSTEM v_sql;
  */
   RETURN vCodret,'Poceso Realizado Exitosamente';
END IF;
END;
END PROCEDURE;