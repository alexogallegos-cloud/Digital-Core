CREATE PROCEDURE "informix".sp_consulta_tc(
			 P_EMPRESA       VARCHAR(3),
                         P_SOLICITUD     VARCHAR(20))

RETURNING CHAR(5),DECIMAL(9,6),DECIMAL(9,6),DECIMAL(9,6),CHAR(1);

--*****************************************************
--DECLARACION DE VARIABLES
--*****************************************************
DEFINE P_ERROR               VARCHAR(8);
DEFINE P_MENSAJE             VARCHAR(80);
DEFINE V_TASA_INTERES        DECIMAL(9,6);
DEFINE V_TASA_MORA           DECIMAL(9,6);
DEFINE SQL_ERR               INTEGER;
DEFINE ISAM_ERR              INTEGER;
DEFINE ERROR_INFO            VARCHAR(80);
define vcodret               char(5);
DEFINE vNumCte               CHAR(20);
DEFINE vMensaje              CHAR(200);
DEFINE V_CATIVA		     	 DECIMAL(9,6);
DEFINE V_MERCADEO            CHAR(1);
DEFINE vCatFinal             DECIMAL(21,10);DEFINE dPagoReq      		 DECIMAL(18,2);
DEFINE V_MONTO               DECIMAL(14,2);
DEFINE dComisiones      	 DECIMAL(18,2);
DEFINE dComisiones_gc      	 DECIMAL(18,2);
DEFINE dAnualidad      		 DECIMAL(18,2);	   
DEFINE cCobro_Apertu    	 CHAR(1);           
DEFINE cCodComis_Apert  	 CHAR(4);
DEFINE cCobrComisAnual  	 CHAR(1);
DEFINE dClvComAnualTit  	 CHAR(4);
DEFINE dClvComAnualAdi  	 CHAR(4);      
DEFINE cCat_adicional   	 CHAR(1);            
DEFINE dMtoComAnualTit  	 DECIMAL(18,2);
DEFINE dMtoComAnualAdi  	 DECIMAL(18,2);			  
DEFINE mMntoComApert    	 DECIMAL(18,2); 
DEFINE cnumprod              CHAR(4);

--   Set debug file to 'sp_consulta_tc.out';
--   trace on;
LET V_TASA_MORA = 0;
LET V_TASA_INTERES = 0;
LEt V_MERCADEO = "";

LET vCatFinal =0;		--INI RQM 10 1253
LET dPagoReq =0;
LET V_MONTO =0;
LET dComisiones =0;
LET dComisiones_gc =0;
LET dAnualidad =0;		
LET cCobro_Apertu  = "";           
LET cCodComis_Apert  = "";
LET cCobrComisAnual  = "";
LET dClvComAnualTit  = "";
LET dClvComAnualAdi  = "";    
LET cCat_adicional   = "";          
LET dMtoComAnualTit  =0;
LET dMtoComAnualAdi  =0;			  
LET mMntoComApert    =0;  
LET cnumprod         = "";
SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- AAME RQM 10 679 Tarjeta de Crédito Bancoppel Oro
IF substr(P_SOLICITUD,1,2)='81' THEN
    --   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
    SELECT valor INTO V_CATIVA
    FROM   sd_param
    WHERE  cod_param = '093';

ELSE
    --   Asigna el Valor del CAT con IVA para el Contrato TC MEL 15 May 2008
    SELECT valor INTO V_CATIVA
    FROM   sd_param
    WHERE  cod_param = '034';
END IF
IF V_CATIVA IS NULL THEN
   LET V_CATIVA = 0;
END IF


BEGIN
    ON EXCEPTION SET SQL_ERR, ISAM_ERR, ERROR_INFO
         LET P_ERROR    = SQL_ERR;
         LET P_MENSAJE  = ERROR_INFO;
         RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
    END EXCEPTION;

      --***********************
      --INICIALIZA VARIABLE
      --***********************


      LET P_ERROR      = '00000';
      LET P_MENSAJE    = 'PROCESO EXITOSO';
	  
      --INTERES ORDINARIO
      SELECT tasa_interes,tasa_moratorios,numcte,num_producto
      INTO V_TASA_INTERES,V_TASA_MORA,vNumCte, cnumprod
      FROM sd_maecred
      WHERE empresa = P_EMPRESA
      AND num_credito = P_SOLICITUD;
 
      -- Saca la Publicacion de si_ctepf Jose Luis Puebla
      SELECT string1 INTO V_MERCADEO 
      FROM   bdinteg:si_ctepf 
      WHERE  numcte = vNumCte;

      -- Resta el Valor de la Tasa Moratoria con la de Intereses
      -- Solicitado por el Banco JLP 23May2008
      LET V_TASA_MORA = V_TASA_MORA - V_TASA_INTERES;              
      IF V_TASA_MORA < 0 THEN --Si es Menor a Cero la vuelve Positivo
         LET V_TASA_MORA = V_TASA_MORA * -1;
      END IF
	  
	  -- AAME 17072019 Se agrega calculo del CAT igual al de Portada de Apertura RQM 10 1253
	  SELECT NVL(cat,0)
      INTO vCatFinal
      FROM bdisolic:ss_revision_determinacion
      WHERE empresa = P_EMPRESA
      AND num_solicitud = P_SOLICITUD;


	  IF NVL(vCatFinal,0) = 0 THEN

		  SELECT NVL(monto_solicitado,0)
			INTO V_MONTO
		  FROM bdisolic:ss_solicitudes
		  WHERE empresa = P_EMPRESA
		  AND num_solicitud = P_SOLICITUD;

			IF NVL(V_MONTO,0) = 0 THEN
				  SELECT NVL(monto_otorgado,0)
					INTO V_MONTO
				  FROM bdicred:sd_maesdos
				  WHERE empresa = P_EMPRESA
				  AND num_credito = P_SOLICITUD;
			END IF;

		-- campo: cobro_comision_anual es para cobro de anualidad del producto. El nvo campo: cat_edc_com_anualidad es para tomar la anualidad en el calculo del CAT para x producto.
		Select nvl(cobro_comis_apertura,'0'), nvl(cod_comision_apertura,''), cat_edc_com_anualidad, substr(cod_comision_anualidad,1,4), substr(cod_comision_anualidad,5,4), cat_comi_anual_adicional
		  Into cCobro_Apertu, cCodComis_Apert, cCobrComisAnual     , dClvComAnualTit                   , dClvComAnualAdi                   , cCat_adicional               
		  From bdicred:sd_definicion Where num_producto = cnumprod;    -- Obtiene clave de comision anualidad.
			
        IF cCobro_Apertu = '1' THEN    -- Si el producto tiene cobro de comision por apertura.
            SELECT monto INTO mMntoComApert FROM bdicred:"informix".sd_tpcomis WHERE empresa = '001' AND cod_comis = cCodComis_Apert; 
            LET mMntoComApert = NVL(mMntoComApert,0);                                       -- Se toma cat originacion. Se agrega com apertura
        END IF;

        IF cCobrComisAnual = '1' THEN   -- Si el producto tiene cobro de comision por anualidad.
			SELECT monto INTO dMtoComAnualTit FROM bdicred:sd_tpcomis WHERE cod_comis = dClvComAnualTit;    -- Monto anualidad titular
			SELECT monto INTO dMtoComAnualAdi FROM bdicred:sd_tpcomis WHERE cod_comis = dClvComAnualAdi;    -- Monto anualidad adicional
			LET dMtoComAnualTit = nvl(dMtoComAnualTit,0);
			LET dMtoComAnualAdi = nvl(dMtoComAnualAdi,0);	
			
            IF cCat_adicional = '0' THEN LET dMtoComAnualAdi = 0; END IF; -- Si adicional no se agrega al CAT, se asigna valor cero.
            LET dAnualidad = dMtoComAnualTit + dMtoComAnualAdi;
		ELSE
			LET dAnualidad = 0;
		END IF;  
				
		-- Para 6001 solo cobra apertura, para <> 6001 no cobra apertura, cobra anualidad
		LET dComisiones = dComisiones + mMntoComApert;				
		LET dComisiones_gc = 0;

		LET dPagoReq = V_MONTO * (V_TASA_INTERES /100) / 360 * 30 ;
		EXECUTE PROCEDURE bdicred:"informix".sp_calculo_tiir(V_MONTO,dPagoReq,36,36,dComisiones,dComisiones_gc,dAnualidad, V_TASA_INTERES) 
		into P_ERROR,ERROR_INFO,vCatFinal;
		IF P_ERROR::INTEGER =0 AND  vCatFinal <> 0  THEN
			LET V_CATIVA = vCatFinal;
		END IF;
		UPDATE bdisolic:ss_revision_determinacion SET cat = V_CATIVA 	WHERE empresa = P_EMPRESA 	AND num_solicitud = P_SOLICITUD;
	 ELSE
			LET V_CATIVA = vCatFinal;
	 END IF;	  	
      
      RETURN P_ERROR,V_TASA_INTERES,V_TASA_MORA,V_CATIVA,V_MERCADEO;
END;
END PROCEDURE;