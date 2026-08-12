CREATE PROCEDURE "informix".sp_traemontosdota(pEmpresa CHAR(3), 
								pFolio CHAR(20),
								pCaj CHAR(5))
RETURNING CHAR(5),CHAR(18),CHAR(18),CHAR(18),CHAR(18),CHAR(18),CHAR(18),CHAR(18),CHAR(18),CHAR(18),CHAR(18),MONEY;

DEFINE vcodret 			CHAR(5);
DEFINE vsqlerr,visamerr INTEGER;
Define vCant1 			CHAR(18); --float(0,8);
Define vCant2 			CHAR(18);
Define vCant3 			CHAR(18);
Define vCant4 			CHAR(18);
Define vCant5 			CHAR(18);
Define vCant6 			CHAR(18);
Define vCant7 			CHAR(18);
Define vCant8 			CHAR(18);
Define vCant9 			CHAR(18);
Define vCant10 			CHAR(18);
define vMonto  			MONEY;
define svstatus 		CHAR(2);

LET vcodret = '000';
LET vCant1 = '';
LET vCant2 = '';
LET vCant3 = '';
LET vCant4 = '';
LET vCant5 = '';
LET vCant6 = '';
LET vCant7 = '';
LET vCant8 = '';
LET vCant9 = '';
LET vCant10 = '';
LET vMonto = 0;
LET svstatus = '';


BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN	  --
	  LET vcodret = vsqlerr;
      RETURN vcodret, vCant1, vCant2 , vCant3 , vCant4 , vCant5 , vCant6 ,vCant7,vCant8,vCant9 , vCant10 , vMonto;
   END IF;
END EXCEPTION;


IF pEmpresa='' OR pEmpresa IS NULL OR pFolio ='' OR pFolio IS NULL OR pCaj='' OR pCaj IS NULL THEN
      LET vcodret='001';
      RETURN vcodret, vCant1, vCant2 , vCant3 , vCant4 , vCant5 , vCant6 ,vCant7,vCant8,vCant9 , vCant10 , vMonto;
END IF;


SELECT a.cantidad_1,a.cantidad_2,a.cantidad_3,a.cantidad_4,a.cantidad_5,a.cantidad_6,a.cantidad_7,a.cantidad_8,a.cantidad_9,a.cantidad_10,a.monto,b.status
INTO vCant1 , vCant2 , vCant3 , vCant4 , vCant5 , vCant6 ,vCant7,vCant8,vCant9 , vCant10 , vMonto,svstatus
FROM ss_operaciones a, ss_mae_entradasalida b
WHERE a.empresa=pEmpresa
AND a.folio_oper=pFolio
AND a.folio_oper=b.folio_oper
AND a.sucursal=pCaj;
--and b.status='11' ;

LET svstatus = NVL(svstatus,'');

--if svstatus ='01' or svstatus='03' then 
--	LET vcodret='003'; -- Esta en transito
--end if
--if svstatus ='18' or svstatus='08' then 
--	LET vcodret='004'; -- Cancelado o Reversado
--end if

IF svstatus ='05' THEN
	LET vcodret='005'; -- Ya recibido
END IF;
--if svstatus ='11' then 
--	LET vcodret='000'; -- Listo para recibir valido
--end if

IF dbinfo("sqlca.sqlerrd2") = 0 THEN
    LET vcodret='002'; -- No existe
END IF;

RETURN vcodret, vCant1 , vCant2 , vCant3 , vCant4 , vCant5 , vCant6 ,vCant7,vCant8,vCant9 , vCant10 , vMonto;

END 
END PROCEDURE;