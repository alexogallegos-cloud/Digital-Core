CREATE PROCEDURE "informix".sp_consultadatospiezas_bym3_totales(pFechaCaptura DATE, pFechaIni DATE, pFechaFin DATE, pSucursal CHAR(4), pNumRecibo CHAR(10), pNumGuia CHAR(12), pEstatus INTEGER, pDictamen INTEGER, pEmpresa CHAR(3))
RETURNING  	CHAR(6) 	AS CodRet,
			INTEGER     AS total;
			
-- ****************************************************************************
-- Declarar variables
-- ****************************************************************************
DEFINE iSql_err               INTEGER;
DEFINE iSamErr               INTEGER;
DEFINE cDesErr               CHAR(80);
DEFINE cCodRet               CHAR(6);
DEFINE cMensaje              CHAR(80);
DEFINE iTotales        		 INTEGER;
DEFINE iBandFecha            INTEGER;
DEFINE iNoRegistros 		 INTEGER;
DEFINE dFechaInicio          DATE;
DEFINE dFechaFin             DATE;

    
-- ****************************************************************************
-- Inicializar variables
-- ****************************************************************************
LET iSql_err                 = 0;
LET iSamErr                 = 0;
LET cDesErr                 = '';
LET cCodRet                 = '000000';
LET cMensaje                = '';
LET iTotales          		= 0;
LET iBandFecha              = 0;
LET iNoRegistros 			= 0;
LET dFechaInicio            = DATE(1);
LET dFechaFin               = DATE(1);

    
SET ISOLATION DIRTY READ ;
SET LOCK MODE TO WAIT 3;

--SET DEBUG FILE TO "/tmp/mfinis/sp_consultadatospiezas_bym3_totales.out";
--TRACE ON;

BEGIN

	ON EXCEPTION SET iSql_err, iSamErr, cDesErr
		IF iSql_err <> 0 THEN
			LET cCodRet = CAST(iSql_err AS CHAR(6));
			LET cMensaje = cDesErr;
			RETURN cCodRet,iNoRegistros;
		END IF;
	END EXCEPTION;
	
	IF TRIM(NVL(pEmpresa,'')) <> '' THEN
		
		IF NVL(pFechaCaptura,DATE(1)) <> DATE(1) THEN
			LET dFechaInicio = pFechaCaptura;
			LET dFechaFin = pFechaCaptura;
			LET iBandFecha = 1;
		ELIF NVL(pFechaIni,DATE(1)) <> DATE(1) AND NVL(pFechaFin,DATE(1)) <> DATE(1) THEN
			LET dFechaInicio = pFechaIni;
			LET dFechaFin = pFechaFin;
			LET iBandFecha = 1;
		END IF;
			
		IF iBandFecha = 1 OR TRIM(NVL(pSucursal,'')) <> '' OR TRIM(NVL(pNumRecibo,'')) <> '' OR TRIM(NVL(pNumGuia,'')) <> '' OR NVL(pEstatus,0) > 0 OR NVL(pDictamen,0) > 0 THEN
			
			
			IF iBandFecha = 1 THEN
			
				SELECT {+INDEX (bdisuc:"informix".ss_piezas_bym_falsos idx_PiezasEstatus)}
					COUNT(Recibo.num_recibo)
				INTO
					iNoRegistros
				FROM
					bdisuc:"informix".ss_tenedor_pieza AS Tenedor INNER JOIN
					bdisuc:"informix".ss_recibo_bym_falsos AS Recibo ON
					Tenedor.id_tenedor = Recibo.id_tenedor  INNER JOIN
					bdisuc:"informix".ss_piezas_bym_falsos AS Piezas ON
					Piezas.num_recibo = Recibo.num_recibo
				WHERE	
					Recibo.empresa_retiene = pEmpresa
				AND Recibo.fecha_insert >= dFechaInicio
				AND Recibo.fecha_insert <= dFechaFin
				AND Recibo.num_sucursal_retencion = CASE WHEN TRIM(NVL(pSucursal,'')) <> '' THEN pSucursal ELSE Recibo.num_sucursal_retencion END
				AND Recibo.num_recibo = CASE WHEN TRIM(NVL(pNumRecibo,'')) <> '' THEN pNumRecibo ELSE Recibo.num_recibo END
				AND NVL(Piezas.num_guia,'') = CASE WHEN TRIM(NVL(pNumGuia,'')) <> '' THEN  pNumGuia ELSE NVL(Piezas.num_guia,'') END
				AND Piezas.estatus = CASE WHEN NVL(pEstatus,0) > 0 THEN pEstatus ELSE Piezas.estatus END
				AND NVL(Piezas.dictamen_banxico,0) =  CASE WHEN NVL(pDictamen,0) > 0 THEN pDictamen ELSE NVL(Piezas.dictamen_banxico,0) END;			
				
				IF iNoRegistros = 0 THEN
					LET cCodRet = '000002';				END IF;
		
				RETURN cCodRet,iNoRegistros;
    
			
			ELIF iBandFecha = 0 THEN
				
				SELECT {+INDEX (bdisuc:"informix".ss_piezas_bym_falsos idx_PiezasEstatus)}
					COUNT(Recibo.num_recibo)
				INTO
					iNoRegistros
				FROM
					bdisuc:"informix".ss_tenedor_pieza AS Tenedor INNER JOIN
					bdisuc:"informix".ss_recibo_bym_falsos AS Recibo ON
					Tenedor.id_tenedor = Recibo.id_tenedor  INNER JOIN
					bdisuc:"informix".ss_piezas_bym_falsos AS Piezas ON
					Piezas.num_recibo = Recibo.num_recibo
				WHERE	
					Recibo.empresa_retiene = pEmpresa
				AND Recibo.num_sucursal_retencion = CASE WHEN TRIM(NVL(pSucursal,'')) <> '' THEN pSucursal ELSE Recibo.num_sucursal_retencion END
				AND Recibo.num_recibo = CASE WHEN TRIM(NVL(pNumRecibo,'')) <> '' THEN pNumRecibo ELSE Recibo.num_recibo END
				AND NVL(Piezas.num_guia,'') = CASE WHEN TRIM(NVL(pNumGuia,'')) <> '' THEN  pNumGuia ELSE NVL(Piezas.num_guia,'') END
				AND Piezas.estatus = CASE WHEN NVL(pEstatus,0) > 0 THEN pEstatus ELSE Piezas.estatus END
				AND NVL(Piezas.dictamen_banxico,0) =  CASE WHEN NVL(pDictamen,0) > 0 THEN pDictamen ELSE NVL(Piezas.dictamen_banxico,0) END;
			
				IF iNoRegistros = 0 THEN
					LET cCodRet = '000002';				END IF;
		
				RETURN cCodRet,iNoRegistros;
    
				
			END IF;
		ELSE
			LET cCodRet = '000001';		END IF;
	ELSE
		LET cCodRet = '000001';	END IF;
	

	END;    
END PROCEDURE
DOCUMENT 'AUTOR: Martha Salgado Mendoza',
'FECHA: 14/12/2016',
'MODULO: CAJA GENERAL ',
'FUNCIONALIDAD: BILLETES PRESUNTAMENTE FALSOS EN SUCURSAL',
'DESCRIPCION: Clon de SPL, para obtener totales.',
'BD: bdisuc';

CREATE PROCEDURE "informix".sp_consultaden_mon_web(
		pempresa          CHAR(3),
		psucursal         CHAR(4),
  		ptransaccion      CHAR(4),
        pTipo             CHAR(2),
        pFecha            CHAR(8),
        Pfolio            CHAR(16),
		pcant1  		  FLOAT(8),
		pcant2  		  FLOAT(8),
		pcant3  		  FLOAT(8),
		pcant4  		  FLOAT(8),
		pcant5  		  FLOAT(8),
		pcant6  		  FLOAT(8),
		pcant7  		  FLOAT(8),
        pmonto            FLOAT(8),
        psecuencia        CHAR(8)
           ) 


--RETURNING CHAR(500);

RETURNING CHAR(5),CHAR(8),CHAR(8),CHAR(8);

DEFINE vcodret			   CHAR(5);
DEFINE vsqlerr             INTEGER;
DEFINE visamerr            INTEGER;
DEFINE vhora  			   CHAR(5);
DEFINE vproveedor 		   CHAR(4);
DEFINE vfecha              DATE;
DEFINE vmensaje			   CHAR(8);
DEFINE pcant_1  		   FLOAT(8);
DEFINE pcant_2  		   FLOAT(8);
DEFINE pcant_3  		   FLOAT(8);
DEFINE pcant_4  		   FLOAT(8);
DEFINE pcant_5  		   FLOAT(8);
DEFINE pcant_6  		   FLOAT(8);
DEFINE pcant_7  		   FLOAT(8);
DEFINE psaldo_total        CHAR(20);
DEFINE cant1  		       FLOAT(8);
DEFINE cant2  		       FLOAT(8);
DEFINE cant3  		       FLOAT(8);
DEFINE cant4  	       	  FLOAT(8);
DEFINE cant5  		      FLOAT(8);
DEFINE cant6  		      FLOAT(8);
DEFINE cant7  		      FLOAT(8);
DEFINE cantdev1  		  FLOAT(8);
DEFINE cantdev2  		  FLOAT(8);
DEFINE cantdev3  		  FLOAT(8);
DEFINE cantdev4  	      FLOAT(8);
DEFINE cantdev5  		  FLOAT(8);
DEFINE cantdev6  		  FLOAT(8);
DEFINE cantdev7  		  FLOAT(8);
DEFINE CantFaltante       CHAR(8);
DEFINE CantNum            CHAR(8);


LET vcodret = "00000";
LET vproveedor = "";
LET vhora = substr(current,12,5);
LET vmensaje ='CORRECTO';
LET psaldo_total = 0;
LET CantNum  = "";

BEGIN
ON EXCEPTION SET vsqlerr,visamerr
   IF vsqlerr != 0 THEN
      LET vcodret=vsqlerr;
   END IF;
END EXCEPTION;

   SET ISOLATION TO DIRTY READ;
   SET LOCK MODE TO WAIT 3;

--SET debug file to "/informix/sp_consultaden_mon.out";
--trace on;


 IF pempresa = '0' or pempresa = '' or psucursal = '0' or psucursal = '' or
   ptransaccion = '0' or ptransaccion = ''  or pTipo = '0' or pTipo = '' or
   pmonto = 0 or pmonto = '' THEN
   LET vcodret = "00110";
 ELSE
  LET CantFaltante = '';
  LET pFecha = pFecha;
    SELECT p.cod_proveedor
    INTO vproveedor
	FROM bdisuc:ss_proveedores p, bdinteg:si_sucursales s
    WHERE p.plaza = s.plaza_cajagen
    AND s.empresa = pempresa
	AND s.sucursal = psucursal;

	SELECT fecha_hoy 
		into vfecha
	FROM bdinteg:si_fechas;

  IF (select count(cod_proveedor) from  bdisuc:ss_proveedores where cod_proveedor = vproveedor) > 0 THEN
	    IF ptransaccion = '27' and pTipo = "1" THEN
              LET cant1 = 0;
              LET cant2 = 0;
              LET cant3 = 0;
              LET cant4 = 0;
              LET cant5 = 0;
              LET cant6 = 0;
              LET cant7 = 0;
              
             --Suma las cantidades de cajageneral
              SELECT sum(cantidad_1), sum(cantidad_2),sum(cantidad_3),sum(cantidad_4),sum(cantidad_5),sum(cantidad_6),sum(cantidad_7) INTO
              pcant_1,pcant_2,pcant_3,pcant_4,pcant_5,pcant_6,pcant_7 
              FROM bdisuc:ss_cajageneral WHERE cod_proveedor = vproveedor; 


              IF pcant_1 is null  or pcant_1 < 0 THEN
                 LET pcant_1=0;
               END IF;

              IF pcant_2 is null or pcant_2 <  0 THEN
                 LET pcant_2=0;
               END IF;

               IF pcant_3 is null or  pcant_3 < 0 THEN
                 LET pcant_3=0;
               END IF;

                IF pcant_4  is null or pcant_4 < 0 THEN
                 LET pcant_4=0;
               END IF;
              
               IF pcant_5 is null or pcant_5  < 0 THEN
                 LET pcant_5=0;
               END IF;
               
               IF pcant_6 is null or  pcant_6  < 0 THEN
                 LET pcant_6=0;
               END IF;
               
              IF pcant_7 is null or  pcant_7 < 0 THEN
                 LET pcant_7=0;
              END IF;


			select sum(cantidad_1), sum(cantidad_2),sum(cantidad_3),sum(cantidad_4),sum(cantidad_5),sum(cantidad_6),sum(cantidad_7)INTO
			cant1,cant2,cant3,cant4,cant5,cant6,cant7 
			from bdisuc:ss_operaciones a  where a.folio_sucursal in (select b.folio_sucursal 
			from bdisuc:ss_mae_entradasalida b where b.cod_proveedor = vproveedor and b.fecha_solicitud = vfecha  and  b.status = '01') and a.cod_trans = '0001';

		   
		   ---Si valor es null iguala a 0
               IF cant1   is null THEN
                 LET cant1=0;
               END IF;

              IF cant2 is null THEN
                 LET cant2=0;
               END IF;

               IF cant3 is null THEN
                 LET cant3=0;
               END IF;

                IF cant4 is null THEN
                 LET cant4=0;
               END IF;
              
               IF cant5 is null THEN
                 LET cant5=0;
               END IF;
               
               IF cant6 is null THEN
                 LET cant6=0;
               END IF;
               
              IF cant7 is null THEN
                 LET cant7=0;
              END IF;
        
		
			select sum(cantidad_1), sum(cantidad_2),sum(cantidad_3),sum(cantidad_4),sum(cantidad_5),sum(cantidad_6),sum(cantidad_7)INTO
			cantdev1,cantdev2,cantdev3,cantdev4,cantdev5,cantdev6,cantdev7 
			from bdisuc:ss_operaciones a  where a.folio_sucursal in (select b.folio_sucursal 
			from bdisuc:ss_mae_entradasalida b where b.cod_proveedor = vproveedor and b.fecha_solicitud = vfecha and b.status = '07') and a.cod_trans = '0002';

              IF cantdev1   is null THEN
                 LET cantdev1=0;
               END IF;

              IF cantdev2 is null THEN
                 LET cantdev2=0;
               END IF;

               IF cantdev3 is null THEN
                 LET cantdev3=0;
               END IF;

                IF cantdev4 is null THEN
                 LET cantdev4=0;
               END IF;
              
               IF cantdev5 is null THEN
                 LET cantdev5=0;
               END IF;
               
               IF cantdev6 is null THEN
                 LET cantdev6=0;
               END IF;
               
              IF cantdev7 is null THEN
                 LET cantdev7=0;
              END IF;


             IF pcant7 <> 0 AND pcant7 >(pcant_7 - cant7 ) THEN
                LET CantNum = '';
                LET CantFaltante = "1";
                LET CantNum = pcant_7 - cant7;  
              END IF


             IF pcant6 <> 0 AND pcant6 >(pcant_6 - cant6 ) THEN
               LET CantNum = '';
               LET CantFaltante = "20";
               LET CantNum = pcant_6 - cant6;  
              END IF


              IF pcant5 <>0 AND pcant5 >(pcant_5 - cant5 ) THEN
                   LET CantNum = '';
                  LET CantFaltante = "50";
                  LET CantNum = pcant_5 - cant5;  
              END IF

              	

              IF pcant4 <> 0 AND  pcant4 >(pcant_4 - cant4 ) THEN
                LET CantNum = '';
                LET CantFaltante = "100";
                LET CantNum = pcant_4 - cant4;  
              END IF
              IF pcant3 <> 0 AND pcant3 > (pcant_3 - cant3) THEN
                LET  CantNum = '';
                LET CantFaltante = "200";
                LET CantNum = pcant_3 - cant3;               
              END IF
       
             IF pcant2 <>0 AND pcant2 >(pcant_2 - cant2 ) THEN
                LET CantNum = '';
                LET CantFaltante = "500";
                LET CantNum= pcant_2 - cant2;  
              END IF ;

              IF pcant1 <>0 AND pcant1 >(pcant_1 - cant1 ) THEN
                LET CantNum = '';
                LET CantFaltante = "1000";
                LET CantNum = pcant_1 - cant1;  
              END IF ;


             IF pcant1  <= 0 THEN
                 LET pcant1=0;
             END IF;

              IF pcant2  <=  0 THEN
                 LET pcant2=0;
               END IF;

               IF  pcant3  <= 0 THEN
                 LET pcant3=0;
               END IF;

                IF pcant4  < 0 THEN
                 LET pcant4=0;
               END IF;
              
               IF pcant5   <= 0 THEN
                 LET pcant5=0;
               END IF;
               
               IF   pcant6   <= 0 THEN
                 LET pcant6=0;
               END IF;
               
              IF  pcant7  <= 0 THEN
                 LET pcant7=0;
              END IF;


        END IF;  
                    
      ELSE 
          LET vcodret = "00105";
  END IF;

 END IF;

RETURN vcodret,vmensaje,CantFaltante,CantNum;
--RETURN vcodret;
END;
END PROCEDURE;