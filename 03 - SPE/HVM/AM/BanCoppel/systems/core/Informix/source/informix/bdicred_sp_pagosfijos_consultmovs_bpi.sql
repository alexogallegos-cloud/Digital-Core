CREATE FUNCTION "informix".sp_pagosfijos_consultmovs_bpi(pEmpresa CHAR(3), pNumCredito CHAR(20), pFechaInicial DATE, pFechaFinal DATE, pRegistro INTEGER)
RETURNING CHAR(6) AS COD_RET,DATE AS FECHA,CHAR(40) AS REFERENCIA,CHAR(40) AS DESCRIPCION,CHAR(1) AS NATURALEZA,MONEY(14,2) AS MONTO, CHAR(40) AS PERIODO, MONEY(14,2) AS CAPITAL;

--Variables auxiliares
DEFINE iSqlErr         INTEGER;
DEFINE iIsamErr        INTEGER;
DEFINE cErrorInfo      CHAR(80);
DEFINE vcodret         CHAR(6); 
DEFINE cMensajeRet     CHAR(80);

--Definicion de variables
DEFINE vfecha        char(10);
DEFINE cDescripcion     CHAR(40);
DEFINE cDescripcion1     VARCHAR(60);
DEFINE cDescripcion2    MONEY(14,2);
DEFINE cDescripcion3    CHAR(20);
DEFINE cDescripcion4   CHAR(40);
DEFINE vmonto        MONEY(14,2);
DEFINE vmontoP        MONEY(14,2);
DEFINE vTrans     CHAR(4);
DEFINE iNumPago			VARCHAR(2);
DEFINE iPlazo       	INTEGER;
DEFINE vReferencia    CHAR(40);
DEFINE vCapital_insoluto DECIMAL(14,2);
DEFINE vfecha_contrato char(10);
DEFINE vNaturaleza CHAR(1);
DEFINE vContPago CHAR(2);


DEFINE vReferencia23  CHAR(23);
DEFINE vRfcComer     CHAR(15);
DEFINE vCapitalInsoluto DECIMAL(14,2);
DEFINE cDescripcionTransfun     CHAR(40);
DEFINE vNumPagoFijo CHAR(12);

LET vcodret            	= "00000";
LET cMensajeRet        	= "Se realizo la consulta correctamente";
LET vfecha = '01/01/1900';
LET cDescripcion = " ";
LET cDescripcion1 = " ";
LET cDescripcion2 = " ";
LET cDescripcion3 = " ";
LET cDescripcion4 = " ";

LET vmonto = 0;
LET vmontoP = 0;
LET vTrans = '';
LET iNumPago = 0;
LET iPlazo = 0;
LET vReferencia = '';
LET vCapital_insoluto=0;
LET vfecha_contrato = '01/01/1900';
LET vNaturaleza ='';
LET vContPago=1;

LET vReferencia23 = '';
LET vRfcComer = '';
LET vCapitalInsoluto = 0;
LET cDescripcionTransfun = '';
LET vNumPagoFijo = "";

 -- *****************************************************************************************************        
   -- Obejtivo:			Pagos fijos - consulta de pagos
   -- Creado por:		Juan Rivera
   -- BD: 				bdicred
   -- Solicitado por:	Gabriela Aguilar
   -- Fecha:			20/10/2023
   -- *****************************************************************************************************
BEGIN

	ON EXCEPTION SET iSqlErr, iIsamErr, cErrorInfo
	   IF iSqlErr != 0 THEN
		  LET vcodret = iSqlErr;
		  LET cMensajeRet = cErrorInfo;
		  RETURN vcodret, vfecha, TRIM(vReferencia), cDescripcion, vNaturaleza,vmonto ,cDescripcion4 ,cDescripcion2;
	   END IF;
	END EXCEPTION;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	-- Productos permitidos: 
	-- 6900 - Pagos fijos

	FOREACH
       (
        SELECT SKIP pRegistro FIRST 10
            a.fecha_mov,
            CASE WHEN NVL(TRIM(a.referencia),'') = ''
            THEN c.transacc
              ELSE TRIM(a.referencia) END
              CASE,
            b.descripcion, naturaleza, monto, a.referencia23, a.rfc_comer , b.numero, c.descripcion
            INTO vfecha,vReferencia,cDescripcion,vNaturaleza,vmonto, vReferencia23, vRfcComer, vTrans, cDescripcionTransfun
             FROM sd_movdia a
                JOIN sd_transfun c ON (a.codigo_fun = c.codigo_fun and a.codigo_ref = c.codigo_ref)
                JOIN bdinteg:si_transacc b ON (c.transacc = b.numero)
                LEFT OUTER JOIN sd_tarjeta d ON (a.nro_tarjeta=d.num_tarjeta)
             WHERE a.empresa = pEmpresa
             AND a.num_credito = pNumCredito
             AND b.sistema = "06"
             AND b.se_emite_edocta = "S"
             AND a.reversado = "N"
             AND a.fecha_mov between pFechaInicial and pFechaFinal
			 AND b.numero IN('4200', '4245','4220') --Restriccion para movimientos de pagos fijos

        UNION ALL
        SELECT a.fecha_mov,
            CASE WHEN NVL(TRIM(a.referencia),'') = ''
              THEN c.transacc
            ELSE TRIM(a.referencia) END CASE,
            b.descripcion, naturaleza, monto, a.referencia23 , a.rfc_comer, b.numero, c.descripcion
             FROM sd_movhis a
                JOIN sd_transfun c ON (a.codigo_fun = c.codigo_fun and a.codigo_ref = c.codigo_ref)
                JOIN bdinteg:si_transacc b ON (c.transacc = b.numero)
                LEFT OUTER JOIN sd_tarjeta d ON (a.nro_tarjeta=d.num_tarjeta)
             WHERE a.empresa = pEmpresa
             AND a.num_credito = pNumCredito
             AND b.sistema = "06"
             AND b.se_emite_edocta = "S"
             AND a.reversado = "N"
             AND a.fecha_mov between pFechaInicial and pFechaFinal
			 AND b.numero IN('4200', '4245','4220') --Restriccion para movimientos de pagos fijos
         ) ORDER BY a.fecha_mov

         IF vNaturaleza = "C" THEN
            LET vmonto = (vmonto*(-1));
         END IF;
		
		LET cDescripcion2 = '';
		LET cDescripcion4 = 0;
		IF (vTrans = '4200' OR vTrans = '4245' OR vTrans ='4220') THEN
		
			LET vNumPagoFijo =  TRIM(SUBSTRING(vReferencia FROM 17));
			
			SELECT sdo_cap_insoluto INTO vCapitalInsoluto FROM bdicred:sd_maesdoscrd WHERE num_credito = vNumPagoFijo; --Consulta el saldo pagado
			SELECT fecha INTO vfecha_contrato FROM bdicred:sd_promocion_credito WHERE num_sol_prestamo = vNumPagoFijo; --Consulta la fecha de la compra
			
			LET cDescripcion2 = NVL(vCapitalInsoluto, 0);
			LET cDescripcion4 = NVL(TRIM(vfecha_contrato),'') ||" "|| NVL(SUBSTRING(TRIM(vRfcComer) FROM 7),'');
			LET cDescripcion = cDescripcionTransfun;
			
		END IF;
	
        RETURN vcodret,vfecha,vReferencia,cDescripcion,vNaturaleza,vmonto, cDescripcion4, cDescripcion2 WITH RESUME;
		 
    END FOREACH;

	IF DBINFO("sqlca.sqlerrd2") <=	0 THEN
	   LET vcodret = "002"; --No existen registros con el filtro de consulta indicado.
	   RETURN vcodret, vfecha, TRIM(vReferencia), cDescripcion, vNaturaleza,vmonto ,cDescripcion4 ,cDescripcion2;
	END IF;

END
END FUNCTION;