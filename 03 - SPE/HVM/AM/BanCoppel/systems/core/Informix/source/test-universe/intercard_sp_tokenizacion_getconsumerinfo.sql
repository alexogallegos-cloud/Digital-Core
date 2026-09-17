CREATE PROCEDURE "informix".sp_tokenizacion_getconsumerinfo( pcliente CHAR(64), pempresa CHAR(10), ptarjeta CHAR(48), pidentificado CHAR(64))
	RETURNING  CHAR(5) AS codretorno,  CHAR(150) AS descodretorno,  CHAR(128) AS nombre1,  CHAR (128) AS nombre2,  CHAR(128) AS apellidos,  DATE AS fechana,  CHAR(3) AS titulo,
			   CHAR(50) AS correo,  CHAR(10) AS codigo_pais_tel,  CHAR(14) AS telefono,  VARCHAR(150) AS direccion,  VARCHAR(80) AS entracalles,  CHAR(128) AS cuidad,  CHAR(128) AS estado,
			   CHAR(10) AS cp,  CHAR(2) AS codpais ;
			   
--Definicion de Variables
DEFINE isqlerr 	   					INTEGER;
DEFINE codigoRetorno				CHAR (05);
DEFINE desCodRetorno 				CHAR (80);
DEFINE inCliente 					CHAR (20);
DEFINE outCliente 					CHAR (20);
DEFINE outNombre1 			   		CHAR (128);
DEFINE outNombre2			 		CHAR (128);
DEFINE outApellidos			 		CHAR (128);
DEFINE outApellidoPat				CHAR (128);
DEFINE outApellidoMat				CHAR (128);
DEFINE outFechaNac			 		DATE;
DEFINE outTitulo			 		CHAR (3);
DEFINE outCodPaisTel 				CHAR (10);	
DEFINE outNumTel					CHAR (13);
DEFINE outCorreo					CHAR (128);
DEFINE outDireccion					VARCHAR (150);
DEFINE outEntreCalles				VARCHAR (80);
DEFINE outCiudad					CHAR (128);
DEFINE outEstado					CHAR (20);
DEFINE outCodigoPostal				CHAR (20);
DEFINE outCodigoPais				CHAR (2);
DEFINE outSexo						CHAR (1);
DEFINE outNumExtCalle			 	CHAR (20);
DEFINE outNumIntCalle			 	CHAR (20);
DEFINE outNombreCalle			 	VARCHAR (20);
DEFINE outNomColonia		 		VARCHAR (150);

--Inicializacion de Variables
LET isqlerr 						= 0;
LET codigoRetorno 					= '00000';
LET desCodRetorno 					= 'Consulta Exitosa.';
LET inCliente 						= '';
LET outCliente 						= '';
LET outNombre1 			   			= '';
LET outNombre2			 			= '';
LET outApellidos			 		= '';
LET outApellidoPat					= '';
LET outApellidoMat					= '';
LET outFechaNac			 			= '';
LET outTitulo			 		 	= '';
LET outCodPaisTel 					= '+52';
LET outNumTel						= '';
LET outDireccion					= '';
LET outEntreCalles					= '';
LET outCiudad						= '';
LET outEstado						= '';
LET outCodigoPostal					= '';
LET outCodigoPais					= 'MX';
LET	outSexo							= '';
LET outNumExtCalle			 		= '';
LET outNumIntCalle			 		= '';
LET outNombreCalle			 		= '';
LET outNomColonia		 			= '';
LET outCorreo                       = '';

	BEGIN
			
			ON EXCEPTION SET isqlerr
				IF isqlerr <> 0 THEN		
					LET codigoRetorno = isqlerr;
					LET desCodRetorno = 'Error No Controlado al invocar SP sp_tokenizacion_getconsumerinfo. Validar.';
				END IF;
				RETURN codigoRetorno, desCodRetorno, outNombre1, outNombre2, outApellidos, outFechaNac, outTitulo, outCorreo, outCodPaisTel, outNumTel, outDireccion, outEntreCalles, outCiudad, outEstado, outCodigoPostal, outCodigoPais;
			END EXCEPTION;
			
			SET ISOLATION TO DIRTY READ;
			SET LOCK MODE TO WAIT 10;
			
			LET inCliente 	 = trim(pcliente);
			
			-- Obtiene informacion de cliente

		    SELECT cte.numcte, cte.nombre1, cte.nombre2 , cte.apell_paterno , cte.apell_materno,
					ctepf.fecha_nac, ctepf.sexo, 
					NVL(cor.correo_elec, ' ') as correo,
					tel.telefono,
					direc.entre_calles, direc.cod_postal, direc.numeroextcalle, direc.numerointcalle, 
					direc.nombrecalle, direc.nombrezona, direc.poblacionzona, direc.nombre
				INTO outCliente , outNombre1, outNombre2, outApellidoPat , outApellidoMat , 
					 outFechaNac, outSexo,outCorreo,outNumTel,outEntreCalles, outCodigoPostal, 
					 outNumExtCalle, outNumIntCalle,
					 outNombreCalle, outNomColonia, outCiudad, outEstado
			FROM bdinteg:"informix".si_cliente cte
				LEFT JOIN (SELECT numcte,fecha_nac,sexo FROM bdinteg:"informix".si_ctepf WHERE numcte= inCliente ) ctepf
					ON ctepf.numcte = cte.numcte
				LEFT JOIN (SELECT correo_elec,numcte FROM bdinteg:"informix".si_correos WHERE numcte= inCliente AND tipo_correo = "1" AND status_correo = 'A') cor
					ON cor.numcte = cte.numcte
				LEFT JOIN (SELECT numcte,telefono FROM bdinteg:"informix".si_telefonos_actual WHERE numcte= inCliente AND tipo_tel = '2' AND status_tel = 'A' ) tel
					ON tel.numcte = cte.numcte
				LEFT JOIN (SELECT dir.numcte,dir.entre_calles, dir.cod_postal, dir.numeroextcalle, dir.numerointcalle, cat.nombrecalle, zon.nombrezona, zon.poblacionzona, edo.nombre
								FROM bdinteg:"informix".si_direcciones_actual dir
									LEFT JOIN bdinteg:"informix".si_catcalles cat
										ON cat.numerocalle = dir.numerocalle
									LEFT JOIN bdinteg:"informix".si_catzonas zon
										ON zon.numerociudad = dir.numerociudad
									LEFT JOIN bdinteg:"informix".si_estados edo
										ON edo.estado = dir.estado
								 WHERE dir.numcte = inCliente
								 AND dir.tipo_dir = '1'
								 AND zon.numerocolonia = dir.numerocolonia
						   ) direc
					ON direc.numcte = cte.numcte
			WHERE cte.numcte = inCliente;
				
			-- Valida que exista cliente
			IF outCliente IS NULL OR outCliente = '' THEN
				LET codigoRetorno = '00404';
				LET desCodRetorno =  'El numero de cliente no existe';
				RETURN codigoRetorno, desCodRetorno, outNombre1, outNombre2, outApellidos, outFechaNac, outTitulo, outCorreo, outCodPaisTel, outNumTel, outDireccion, outEntreCalles, outCiudad, outEstado, outCodigoPostal, outCodigoPais;
			END IF
			
			-- Junta los apellidos
			LET outApellidos = trim(outApellidoPat)||' '||trim(outApellidoMat);
			
			-- Valida sexo para asignar Titulo
			IF outSexo = 'F' THEN
				LET outTitulo = 'Sra';
			ELIF outSexo = 'M' THEN
				LET outTitulo = 'Sr';
			END IF;

			-- Valida nÃÂºmero de calle ext
			IF outNumExtCalle IS NOT NULL OR outNumExtCalle <> '' THEN
				LET outNumExtCalle = 'EXT'||' '||outNumExtCalle;
			END IF;
			
			-- Valida nÃÂºmero de calle int
			IF outNumIntCalle IS NOT NULL OR outNumIntCalle <> '' THEN
				LET outNumIntCalle = 'INT'||' '||outNumIntCalle;
			END IF;
			
			-- Valida nombre de calle
			IF outNombreCalle IS NULL OR outNombreCalle = '' THEN
				LET outNombreCalle = 'Calle sin Nombre';
			END If;
			
			-- Junta direcciÃÂ³n
			LET outDireccion = TRIM(outNombreCalle)||' '||TRIM(outNumExtCalle)||' '||TRIM(outNumIntCalle)||', '||TRIM(outNomColonia);
			
			RETURN codigoRetorno, desCodRetorno, outNombre1, outNombre2, outApellidos, outFechaNac, outTitulo, outCorreo, outCodPaisTel, outNumTel, outDireccion, outEntreCalles, outCiudad, outEstado, outCodigoPostal, outCodigoPais;
	END
END PROCEDURE;