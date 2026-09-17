CREATE PROCEDURE "informix".sp_obtienegrupo_cons(pnum_solicitud CHAR(12)) 
RETURNING 
CHAR(6) AS codret,
--CHAR(80) AS Mensaje,
CHAR(2) AS tipogrupo, 
CHAR(6) AS hit;


---DECLARACION DE VARIABLES
DEFINE cCodRet CHAR(6);
DEFINE cCodRet1 CHAR(6);
DEFINE ptipogrupo CHAR(1);
DEFINE ptipogrupoAux CHAR(1);
DEFINE phit CHAR(6);
DEFINE VSQL  CHAR(6000);
DEFINE iSqlErr INTEGER;
DEFINE dPaso  SMALLINT;
DEFINE error_info CHAR(80);
DEFINE isam_err INTEGER;
DEFINE pempresa CHAR(3);
DEFINE pproceso CHAR(30);
DEFINE pMensaje CHAR(80);
DEFINE cCod_RetIB CHAR(6);
DEFINE pmeses_historia SMALLINT;
DEFINE psituacion_pago DECIMAL(5,2);
DEFINE pgrupo CHAR(1);
DEFINE pevalua_cc CHAR(1);
DEFINE pfuente CHAR(1);
DEFINE pnum_producto CHAR(4);
DEFINE pnumcte CHAR(20);
DEFINE ptipo_alta CHAR(1);
DEFINE vlGpoCliente char(1);
DEFINE vlNumCte char(20);
DEFINE vlCodigo char(5);
DEFINE vlFecha	DATE;
DEFINE vlCteLargo smallint;
DEFINE vgrupoA smallint;
DEFINE iMeses INTEGER;
DEFINE iSecuencia INTEGER;


--SET DEBUG FILE TO "/informix/sp_obtienegrupo.out";
--TRACE ON;

---INICIALIZACION DE VARIABLESa
LET cCodRet  = '000000';
LET cCodRet1  = '000000';
LET ptipogrupo = '';
LET ptipogrupoAux = '';
LET phit = '';
LET VSQL = '';
LET iSqlErr = 0;
LET dPaso = 0;
LET pMensaje = 'PROCESO EXITOSO';
LET pproceso = '2119';
LET pempresa = '001';
LET cCod_RetIB	= "000000";
LET pmeses_historia = 0;
LET psituacion_pago = 0;
LET pgrupo = '';
LET pevalua_cc = '';
LET pfuente = '';
LET pnum_producto = '';
LET pnumcte = '';
LET ptipo_alta = '';
LET vlGpoCliente ='';
LET vlNumCte = '';
LET vlCodigo = '00000';
LET vlFecha = DATE(1);
LET vlCteLargo =0;
LET vgrupoA = 0;
LET iMeses = 0;
LET iSecuencia = 0;


BEGIN

ON EXCEPTION SET iSqlErr, isam_err, error_info
LET cCodRet = iSqlErr;
	RETURN cCodRet,'','';
END EXCEPTION;

--Directiva para lectura de tablas bloqueadas.
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

SELECT fecha_hoy 
  into vlFecha
 FROM bdicred:sd_fechas
 WHERE empresa = '001';

SELECT a.meses_historia,a.situacion_pago,a.grupo,a.evalua_cc,a.fuente,b.num_producto,b.numcte,nvl(c.tipo_alta,''), b.numcte
INTO pmeses_historia,psituacion_pago,pgrupo,pevalua_cc,pfuente,pnum_producto,pnumcte,ptipo_alta, vlNumCte
FROM bdisolic:ss_resum_scor_fin a, bdisolic:ss_solicitudes b, outer bdiprospectos:pr_cliente c
WHERE a.empresa = pEmpresa 
AND a.num_solicitud = b.num_solicitud 
AND b.numcte = c.numcte
AND a.num_solicitud = pnum_solicitud;

-- Determina si es grupo 8
SELECT count(*) into vlCteLargo
	FROM "informix".ss_clienteslargos
	WHERE numcte = vlNumCte
	  AND fecha_vig_ini <= vlFecha 
	  AND fecha_vig_fin >= vlFecha
      AND status = 'AC';


-- Determina si es grupo A
SELECT COUNT(*) INTO vgrupoA
    FROM bdicred:"informix".sd_grupo_cliente 
   WHERE empresa = pEmpresa
     AND numcte  = vlNumCte;

    IF (vgrupoA > 0) THEN
        LET ptipogrupo = 'A';
	ELIF nvl(vlCteLargo,0) > 0 then 
        LET ptipogrupo = '8';
	ELSE
        IF pnum_producto = '6500' AND ptipo_alta = '2' THEN
            LET ptipogrupo = '7';
        ELIF  ( NVL(pgrupo,'') = '6' AND pmeses_historia = 0 AND psituacion_pago = 0 AND pnum_producto <> '7800') THEN
            LET ptipogrupo = '6';
        ELIF NVL(pgrupo,'')= 'A' THEN
            LET ptipogrupo = 'A';
        ELIF pmeses_historia >= 13 AND psituacion_pago >= 85 AND NVL(pgrupo,'') NOT IN ('A') THEN 
            LET ptipogrupo = '1';
        ELIF pmeses_historia >= 6 AND pmeses_historia < 13 AND psituacion_pago >= 85 AND NVL(pgrupo,'') NOT IN ('A') THEN
            LET ptipogrupo = '2';
        ELIF (( pmeses_historia < 6 AND psituacion_pago >= 85) ) AND NVL(pgrupo,'') NOT IN ('A') THEN
            LET ptipogrupo = '3';
        ELIF pmeses_historia >= 6 AND psituacion_pago >= 0 AND psituacion_pago < 85 AND NVL(pgrupo,'') NOT IN ('A') THEN
            LET ptipogrupo = '4';
        ELIF ( ( NVL(psituacion_pago,0) = 0 AND NVL(pmeses_historia,0) = 0 ) or ( NVL(psituacion_pago,0) = -1) or ( pmeses_historia < 6 AND psituacion_pago < 85)) AND NVL(pgrupo,'') NOT IN ('A') THEN
            LET ptipogrupo = '5';
        END IF;
	END IF;

IF NVL(pmeses_historia,0) > 0 THEN 
	EXECUTE PROCEDURE bdinteg:"informix".mesesvalidoscte (vlNumCte) INTO cCodRet1,iMeses;
	 IF NVL(pmeses_historia,0) > iMeses  THEN 
		 IF NVL(pgrupo,'') = '' then 
			LET ptipogrupoAux =  ptipogrupo;
		 ELSE
			LET ptipogrupoAux =  pgrupo;
		 END IF; 
		LET ptipogrupo = '5';
		
	

	END IF;
END IF;
    

RETURN cCodRet,ptipogrupo, pevalua_cc;

END
END PROCEDURE
