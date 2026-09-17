CREATE PROCEDURE "informix".sp_pld_chq_crg_xml_head()
RETURNING	CHAR(08)	AS	cod_ret 		 ,
			CHAR(120)	AS	mensaje			 ,
			CHAR(10)	AS	vercion 		 ,
			CHAR(06)	AS	org_regulador	 ,
			CHAR(06)	AS	cve_entidad		 ;
			
			
--variables de retorno
	DEFINE	cod_ret			CHAR(08); 		
	DEFINE	mensaje			CHAR(80);
	DEFINE	vvercion 		CHAR(10);
	DEFINE	vorg_regulador	CHAR(06);
	DEFINE	vcve_entidad	CHAR(06);
	
	
--variables de control de errores
	DEFINE	iSqlErr 		INTEGER;
	DEFINE	iIsamErr		INTEGER;
	DEFINE	vErrorInfo		VARCHAR(80);
	DEFINE	vpaso			INTEGER; 	
	
BEGIN
ON EXCEPTION SET iSqlErr, iIsamErr, vErrorInfo
		IF iSqlErr <> 0 OR iIsamErr <> 0 THEN
			LET cod_ret = iSqlErr;
			LET mensaje = vErrorInfo;
			RETURN 	 cod_ret
					,'iIsamErr: '|| iIsamErr || 'vErrorInfo: sp_pld_chq_crg_xml_head ' || vErrorInfo || ' En paso: ' || vpaso 
					,""
					,""
					,""
			;
			
		END IF;
	END EXCEPTION;

	--inicializciÃ³n de variables
	LET cod_ret			='00000000';
	LET	mensaje			='PROCESO EXITOSO';
	LET	vvercion		='';
	LET	vorg_regulador	='';
	LET	vcve_entidad	='';
	
	SET ISOLATION TO DIRTY READ;
	
	LET vpaso =1;
	
	--obtenemos la verciÃ³n
	SELECT valor INTO vvercion FROM param WHERE llave = 'VERSION_XML';
	IF    (dbinfo('sqlca.sqlerrd2')=0)  THEN
		LET	vvercion = '1.0';
	END IF
	
	LET vpaso =2;
	--obtenemos el organismo regulador
	SELECT valor INTO vorg_regulador FROM param WHERE llave = 'CVE_ORGANO_REGULADOR';
	IF    (dbinfo('sqlca.sqlerrd2')=0)  THEN
		RETURN '00000002','NO SE ENCONTRO EL ORGANISMO REGULADOR EN LA TABLA BDIAUDITOR:PARAM','','','';
	END IF

	LET vpaso =3;
	--obtenemos la clave de la entidad
	SELECT valor INTO vcve_entidad FROM param WHERE llave = 'CVE_ENTIDAD';
	IF    (dbinfo('sqlca.sqlerrd2')=0)  THEN
		RETURN '00000003','NO SE ENCONTRO LA CLAVEDE LA ENTIDAD EN LA TABLA BDIAUDITOR:PARAM','','','';
	END IF
	
	RETURN cod_ret,mensaje,vvercion,vorg_regulador,vcve_entidad;
	
END
END PROCEDURE	
	
	;