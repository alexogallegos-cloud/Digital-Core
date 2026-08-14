CREATE PROCEDURE "informix".sp_tc_geolocalizacion_bpi(
  pOpcion CHAR(2), 
  pNumCte VARCHAR(20),
  pIdUsuario INTEGER, 
  pLatitud LVARCHAR(100), 
  pLongitud LVARCHAR(100), 
  pFechaOper DATETIME year to second,
  pIpUsuario CHAR(15), 
  pIdOperacion CHAR(4),
  pSucursal CHAR(4),
  pIpCliente CHAR(15),
  pNavegador CHAR(20),  
  pVersion CHAR(10)
  )

	RETURNING CHAR(5) as codret;

DEFINE vcodret CHAR(5);
DEFINE vsqlerr INTEGER;
DEFINE vNumCte INTEGER;
DEFINE vCount SMALLINT;
DEFINE vCodRetBit CHAR(5);
DEFINE vFecha DATE;
DEFINE  valor INTEGER;

LET vcodret = '00000';
LET vsqlerr = 0;
LET vNumCte = '';
LET vCount = 0;
LET vCodRetBit = '00000';
LET vFecha    = DATE(1);
Let valor= '';


  BEGIN
    ON EXCEPTION SET vsqlerr
			IF vsqlerr <> 0 THEN
				LET vcodret = vsqlerr;
				RETURN vcodret;
			END IF
		END EXCEPTION;

		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;


    -- ValidaciÃ³n de cliente
    IF pNumCte IS NOT NULL AND pNumCte  <> '' THEN 
      LET vNumCte = pNumCte;      IF NVL(vNumCte, 0) = 0 THEN
        LET vcodret='00006'; -- Si el numero cliente es igual a NULL o ''
        RETURN vcodret;
      END IF;
    END IF;



    IF pOpcion='01' THEN -- La opciÃ³n 1 - Consulta T&C con un cliente
        
      SELECT  {+ INDEX (bpi_terminoscondiciones_geolocalizacion idx_numcte)}  COUNT(*) INTO vCount FROM bdibpi:bpi_terminoscondiciones_geolocalizacion WHERE numcte = vNumCte; 
	  --SELECT  {+ INDEX (bpi_terminoscondiciones_geolocalizacion idx_numcte)} numcte INTO valor FROM bdibpi:bpi_terminoscondiciones_geolocalizacion WHERE numcte = vNumCte; 
		  
	  
      IF vCount=0 THEN
           LET vcodret='00002'; -- Presenta pantalla para aceptar T&C
           RETURN vcodret;
      ELIF vCount > 0 THEN
            LET vcodret='00003'; -- No presenta pantalla para aceptar T&C
            RETURN vcodret;
      ELIF vCount IS NULL OR vCount = '' THEN
            LET vcodret='00004';
            RETURN vcodret; --- Error al consultar
      END IF;   

	--	IF valor   <> ''  THEN
      --     LET vcodret='00002'; -- Presenta pantalla para aceptar T&C
    --      else
     --       LET vcodret='00003'; -- No presenta pantalla para aceptar T&C
     --       RETURN vcodret;
      
     -- END IF;  


	  

    ELIF pOpcion='02' THEN --LA OPCION 2 - Inserta en tabla de Terminos y condciones y en tabla de bitÃ¡cora      
      IF ((pIdUsuario = 0 OR pIdUsuario IS NULL) OR (pIpUsuario = '' OR pIpUsuario IS NULL) OR (pIdOperacion = '' OR pIdOperacion IS NULL) OR
          (pSucursal = '' OR pSucursal IS NULL) OR (pIpCliente = '' OR pIpCliente IS NULL) OR (pNavegador = '' OR pNavegador IS NULL) OR 
          (pVersion = '' OR pVersion IS NULL) OR (pFechaOper = '' OR pFechaOper IS NULL) ) THEN
        LET vcodret='00001';
        RETURN vcodret; --- Datos incorrectos
      ELSE
        
        INSERT INTO bdibpi:"informix".bpi_terminoscondiciones_geolocalizacion 
        VALUES(pNumCte, pFechaOper, pLatitud, pLongitud, pIpCliente, pNavegador, pVersion);

        EXECUTE PROCEDURE bdinteg:"informix".sp_agregarbitacora_bpi(pFechaOper,pIdOperacion,pSucursal,pIdUsuario,pIpUsuario,
          vFecha,'','','0.0','','','','','','','','','','','','',pVersion)
        INTO vCodRetBit;

      

      END IF;
    END IF;
	RETURN vcodret;

  END;
END PROCEDURE;