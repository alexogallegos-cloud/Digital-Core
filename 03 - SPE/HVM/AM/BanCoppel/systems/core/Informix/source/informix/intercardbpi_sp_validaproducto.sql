CREATE PROCEDURE "informix".sp_validaproducto(pNumProd CHAR(4), pNumTarjeta CHAR(16), pNumOpc CHAR(1),pClave CHAR(2) )
   RETURNING CHAR(5), CHAR(6), CHAR(3), INTEGER;
      
   DEFINE cCodRet             CHAR(5);
   DEFINE iSqlErr             INTEGER;
   
   DEFINE cCodBin	  CHAR(6);
   DEFINE cCodProd	  CHAR(3);
   DEFINE cCodClaveTar	INTEGER;
   DEFINE cNumCta     CHAR(12);
   DEFINE cLimiteAut money (14,2);
     
   LET cCodRet 		  = '00001';   
   LET cCodBin	      	  = '000000';
   LET cCodProd	      = '000';
   LET cCodClaveTar	= 0;
         
BEGIN
	   ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
			    LET cCodRet = iSqlErr;
				
				RETURN cCodRet, cCodBin, cCodProd, cCodClaveTar;
			END IF;
		END EXCEPTION;
	
	--SET DEBUG FILE TO "/tmp/combinacion/Sp_ValidaProducto.out";
	--TRACE ON;
	
	SET LOCK MODE TO WAIT 3;
	SET ISOLATION TO DIRTY READ;
	
	IF pNumOpc = '1' THEN
	
		IF pNumProd <> '' THEN
			SELECT bin,codproductotarjeta INTO cCodBin,cCodProd  FROM intercard: binproducto WHERE codprodcta = pNumProd;		
		ELSE 	
			SELECT binp.bin, tar.codproductotarjeta INTO cCodBin,cCodProd  
			FROM intercard: 'informix'.tarjeta tar,	intercard: 'informix'.binproducto binp
			WHERE tar.numtarjeta = pNumTarjeta AND tar.codproductotarjeta = binp.codproductotarjeta;		
		END IF
			
		IF cCodProd = '505' OR cCodProd = '504' OR cCodProd = '503' OR cCodProd = '501' THEN
				LET cCodRet = "00000";
		END IF;
              IF pClave = '14' THEN
                    LET cCodClaveTar = 14;
              END IF
              
              IF pClave = '15' THEN
                    LET cCodClaveTar = 15;
              END IF
		
	ELSE
		
		SELECT LIMIT 1 bin INTO cCodBin FROM intercard: binproducto WHERE codprodcta = pNumProd;
		
		IF pNumProd = "6001" THEN
			
			SELECT LIMIT 1 num_credito INTO cNumCta FROM bdicred: sd_tarjeta WHERE num_tarjeta = pNumTarjeta;
			SELECT LIMIT 1 monto_otorgado INTO cLimiteAut FROM bdicred: sd_maesdos where num_credito = cNumCta;	
		
			--* La busqueda en la tabla intercard:"informix".segmentoproducto donde el tipo_producto sea igual a C y los limites que anteriormente tenia en el sp
			SELECT LIMIT 1 TRIM(codproductotarjeta) INTO cCodProd
			FROM intercard:"informix".segmentoproducto
			WHERE tipo_producto = "C"
			AND limite_max >= NVL(cLimiteAut,0) 
			AND limite_min <= NVL(cLimiteAut,0);			
		ELSE
			SELECT LIMIT 1 codproductotarjeta INTO cCodProd FROM intercard: binproducto WHERE codprodcta = pNumProd;	
		END IF;
			
		IF cCodBin <> '000000' THEN
		
			IF pNumProd = "6001"  OR pNumProd = "6600" THEN
				SELECT LIMIT 1 clave_tipotarjeta INTO cCodClaveTar FROM intercard: TipoTarjeta where bin = cCodBin and flagsolicitud = 1;
			ELSE
				SELECT LIMIT 1 clave_tipotarjeta INTO cCodClaveTar FROM intercard: TipoTarjeta where bin = cCodBin;
             
              IF pClave = '14' THEN
                    LET cCodClaveTar = 14;
              END IF
              
              IF pClave = '15' THEN
                    LET cCodClaveTar = 15;
              END IF

			END IF;
			
			IF cCodClaveTar is null THEN
				LET cCodClaveTar = 0;
			ELSE
				LET cCodRet = "00000";
			END IF;
			
		END IF;
		
	END IF
	
	RETURN cCodRet, cCodBin, cCodProd,cCodClaveTar;

END;
END PROCEDURE
DOCUMENT
'AUTOR: Irma Ureta Gaxiola',
'FECHA: 17/10/2016',
'BD: Intercard',
'Objetivo: Se crea procedimiento para validar que en número de producto de la cuenta exista en la base de datos intercard ';

CREATE PROCEDURE "informix".sp_operstatusbloqprev_pba ( psNumTarjeta  CHAR (16), psUsuario CHAR (16), psOperacion CHAR (1) )

RETURNING CHAR (2), CHAR (100) ;

--****************************************************************************************************
-- DESCRIPCION: Desarrollo de un Stored Procedure en Informix, para grabar en la Tabla Bitácora Cambios
--		de Estatus de Tarjeta, un registro que indica que se modifico el estatus de la Tarjeta
-- AUTOR : Jorge Quiroz
-- FECHA : 30/08/2010
-- BD: Intercard
-- SISTEMA : InterCard
-- MODIFICADO :
--***************************************************************************************************

--DEFINICION DE VARIABLES Tarjeta
DEFINE viContador INTEGER ;
DEFINE vsQUERY1 CHAR (1000) ;
DEFINE vsStatusTar CHAR (3) ;
DEFINE vsStatusTarNvo CHAR (3) ;
DEFINE vsCodError CHAR (2) ;
DEFINE vsDescError CHAR (100) ;

-- VARIABLES DE MANEJO DE ERRORES
DEFINE visqlerr INTEGER ;


--INICIALIZACION DE VARIABLES
LET viContador  = 0 ;
LET vsQUERY1= '' ;
LET vsStatusTar = '' ;
LET vsStatusTarNvo = '' ;
LET vsCodError = '00' ;
LET vsDescError = 'Operacion Exitosa' ;

-- VARIABLE DE MANEJO DE ERRORES
LET visqlerr = 0 ;

BEGIN

    ON EXCEPTION SET visqlerr   --cacha el error en caso de que no exista y regresa un valor predeterminado
        IF visqlerr <> 0 THEN
	    LET vsCodError = '05' ;
	    LET vsDescError = 'ERROR: [' || visqlerr || '], DESCRIPCION: [ Error SPL]' ;
	    RETURN '05', 'ERROR: [' || visqlerr || '], DESCRIPCION: [ Error SPL]' ;
        END IF ;
    END EXCEPTION ;

    SET DEBUG FILE TO "/tmp/salida_sp_operstatusbloqprev.out";
    TRACE ON;

    SET ISOLATION TO DIRTY READ ;

    SELECT COUNT (NumTarjeta)  INTO viContador FROM Tarjeta
    WHERE  NumTarjeta = psNumTarjeta ;

    IF ( viContador >= 1 ) THEN
        --SE ENCONTRO EL NUMERO DE TARJETA

        SET ISOLATION TO DIRTY READ ;

	SELECT NVL( CodStatusTarjeta , '' ) INTO vsStatusTar FROM Tarjeta WHERE NumTarjeta = psNumTarjeta ;

	IF ( psOperacion = 'D' ) THEN
		--Desbloqueo de Tarjeta
		IF ( vsStatusTar = 'BLT' ) THEN
			LET vsStatusTarNvo = 'ACT' ;
			UPDATE Tarjeta SET CodStatusTarjeta = 'ACT' WHERE NumTarjeta = psNumTarjeta ;
		ELSE
			LET vsCodError = '02' ;
			LET vsDescError = 'Estatus invalido' ;
			--RETURN '02', 'Estatus invalido' ;
		END IF ;
	ELIF ( psOperacion = 'B' ) THEN
		--Bloqueo de Tarjeta
		IF ( vsStatusTar = 'ACT' ) THEN
			LET vsStatusTarNvo = 'BLT' ;
			UPDATE Tarjeta SET CodStatusTarjeta = 'BLT' WHERE NumTarjeta = psNumTarjeta ;
		ELSE
			LET vsCodError = '02' ;
			LET vsDescError = 'Estatus invalido' ;
			--RETURN '02', 'Estatus invalido' ;
		END IF ;
	ELSE
		LET vsCodError = '03' ;
		LET vsDescError = 'Operacion No Valida' ;
		--RETURN '03', 'OPERACION NO VALIDA' ;
	END IF ;
    ELSE
	LET vsCodError = '01' ;
	LET vsDescError = 'Tarjeta No Existe' ;
    END IF ;

	INSERT INTO BitacoraCambiosStatusTarjeta (
			Tarjeta,
			FechaHora,
			CodStatusTarjetaOrig,
			CodStatusTarjetaNvo,
			CambioEstatusInterCard,
			CodigoError,
			DescError,
			Usuario)
	VALUES (psNumTarjeta,CURRENT,vsStatusTar,vsStatusTarNvo,'F',vsCodError,vsDescError,psUsuario) ;


	RETURN vsCodError, vsDescError ;

END
END PROCEDURE
;