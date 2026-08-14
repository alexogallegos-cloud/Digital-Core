CREATE PROCEDURE "informix".sp_tipored (
pempresa CHAR(3),
pnum_telefono CHAR(10)
)
RETURNING CHAR (6), CHAR(10), CHAR (3);

--Creado por: Enrique Lizárraga Lugo 28/oct/2010
--Función: Determina el tipo de red del número telefónico requerido así como el número de carrier que proporciona el servicio telefónico al cliente.

--Variables
DEFINE 	cCodRet CHAR(5);
DEFINE 	iSqlErr INTEGER;
DEFINE	vnir	CHAR(3);
DEFINE 	vserie	CHAR(4);
DEFINE 	vnumeracion CHAR(4);
DEFINE 	vtipored CHAR(10);
DEFINE	vnum_carrier_cat CHAR (3);

--Inicialización de variables
LET cCodret = '00000';
LET iSqlErr = 0;
LET vnir = '';
LET vserie = '';
LET vnumeracion = '';
LET vtipored = '';
LET vnum_carrier_cat = '';

BEGIN
    ON EXCEPTION SET iSqlErr
        IF iSqlErr !=0 THEN
            LET cCodRet = iSqlErr;
            RETURN cCodRet, vtipored, vnum_carrier_cat;
        END IF;
    END EXCEPTION;
	
IF pnum_telefono <> '' THEN
	LET vnir = SUBSTR(pnum_telefono,1,2);
	IF vnir IN ('55','33','81') THEN
		LET vnir = SUBSTR(pnum_telefono,1,2);
		LET	vserie = SUBSTR(pnum_telefono,3,4);
		LET vnumeracion = SUBSTR(pnum_telefono,7,4)*1;
		IF EXISTS (SELECT 1 FROM bdinteg:si_catcofetel a WHERE a.nir = vnir AND a.serie = vserie AND vnumeracion >= a.numeracion_inicial AND vnumeracion <= a.numeracion_final) THEN
		SELECT limit 1 a.tipored, b.num_carrier_cat 
		INTO vtipored , vnum_carrier_cat FROM bdinteg:si_catcofetel a , bdinteg:si_catcarrier b
		WHERE a.nir = vnir AND a.serie = vserie AND trim(vnumeracion)*1 >= a.numeracion_inicial AND trim(vnumeracion)*1 <= a.numeracion_final AND a.razonsocial = b.nombre_carrier;
		RETURN cCodRet, vtipored, vnum_carrier_cat;
		END IF;
	ELSE
		LET vnir = SUBSTR(pnum_telefono,1,3);
		LET vserie = SUBSTR(pnum_telefono,4,3);
		LET vnumeracion = SUBSTR(pnum_telefono,7,4)*1;
		IF EXISTS (SELECT 1 FROM bdinteg:si_catcofetel a WHERE a.nir = vnir AND a.serie = vserie AND vnumeracion >= a.numeracion_inicial AND vnumeracion <= a.numeracion_final) THEN
		SELECT limit 1 a.tipored, b.num_carrier_cat 
		INTO vtipored , vnum_carrier_cat FROM bdinteg:si_catcofetel a , bdinteg:si_catcarrier b
		WHERE a.nir = vnir AND a.serie = vserie AND trim(vnumeracion)*1 >= a.numeracion_inicial AND trim(vnumeracion)*1 <= a.numeracion_final AND a.razonsocial = b.nombre_carrier;
		RETURN cCodRet, vtipored, vnum_carrier_cat;
		END IF;
	END IF;
ELSE
	RETURN '00001', vtipored, vnum_carrier_cat;
END IF;
--cCodRet = '00001' = Campo de número vacío

END;
END PROCEDURE;