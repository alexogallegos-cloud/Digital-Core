CREATE PROCEDURE "informix".sp_conciliacion_trf()

RETURNING CHAR(5) AS Cod_Retorno;

---DECLARACION DE VARIABLES
DEFINE iSqlErr         	INTEGER;
DEFINE cCodRet          CHAR(5);
DEFINE cNumCta          CHAR(11);
DEFINE cTelefono        CHAR(13);
DEFINE cApell_Paterno   CHAR(26);
DEFINE cApell_Materno   CHAR(26);
DEFINE cNombre_1        CHAR(26);
DEFINE cNombre_2        CHAR(26);
DEFINE dFecha_Nac       DATE;
DEFINE cNumeroCta       CHAR(11);
DEFINE cTelefono_Trf    CHAR(13);
DEFINE cNom_Cliente     CHAR(50);
DEFINE dFecha_Naci      DATE;
DEFINE cNom_Cliente_tf  CHAR(200);
DEFINE vRegintegro     	CHAR(1);
DEFINE viid             integer;
DEFINE iEsregistro       integer;
DEFINE dFechaAnt         DATE;
DEFINE dFechaHoy         DATE;
DEFINE vesRegistro        CHAR(1);
DEFINE cCodErr          CHAR(3);
--DEFINICION DE VARIABLES REPORTE
DEFINE vsSQL 		CHAR(2204);
DEFINE vsSQL1 		CHAR(100);
DEFINE vsSQL2 		CHAR(2004);
DEFINE vsSQL3 		CHAR(100);
DEFINE vsArch   	CHAR(50); 
DEFINE vsRepositorio CHAR(100);	
DEFINE vsArchTemp    CHAR(50);
DEFINE dFec_Can    		 CHAR(11);
DEFINE cDia	   		     CHAR(2);
DEFINE cMes			     CHAR(2);
DEFINE cAnio		     CHAR(4);

---INICIALIZACION DE VARIABLES
LET iSqlErr              = 0;
LET cCodRet              = '00000';
LET cNumCta              = '';
LET cTelefono            = '';
LET cApell_Paterno       = '';
LET cApell_Materno       = '';
LET cNombre_1            = '';
LET cNombre_2            = '';
LET dFecha_Nac           = DATE(1);
LET cNumeroCta           = '';
LET cTelefono_Trf        = '';
LET cNom_Cliente         = '';
LET dFecha_Naci          = DATE(1);
LET cNom_Cliente_Tf      = '';
LET vRegintegro 		 ='';
LET viid                 = 0;
LET iEsregistro          = 0;
LET dFechaAnt            = DATE(1);
LET dFechaHoy            = DATE(1);
LET vesRegistro          = '';
LET cCodErr              = '';
LET vsArch          	 = 'diferenciaaltatransfer';
LET vsArchTemp          	 = 'diferenciaaltatransfer.sql';
--LET vsRepositorio        = '/informix/mijail/';
LET vsRepositorio        = '/RESPALDOS/';
LET dFec_Can    	  = '';
LET cDia              = '';
LET cMes              = '';
LET cAnio             = '';


--SET DEBUG FILE TO '/informix/mijail/sp_conciliacion_trf.out';
--TRACE ON;

BEGIN
    ON EXCEPTION
    SET iSqlErr
    IF     iSqlErr <> 0 THEN
        LET cCodRet = iSqlErr;
        RETURN cCodRet;
    END IF
END EXCEPTION;


    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO WAIT 3;

	SELECT fecha_ant,fecha_hoy INTO dFechaAnt,dFechaHoy FROM bdinteg:"informix".si_fechas;


    FOREACH CONCILIA WITH HOLD FOR
        --Identificar un registro que no haya sido conciliado
		SELECT id, cuenta_tf,telefono,nombre1,nombre2,apell_paterno,apell_materno,fecha_nac,esregistro,cod_error
        INTO viid, cNumCta,cTelefono,cNombre_1,cNombre_2,cApell_Paterno,cApell_Materno,dFecha_Nac,vesRegistro,cCodErr
        FROM bditransfer:"informix".tf_cte_online
        WHERE cte_conciliado = '0'
		AND fec_sistema = dFechaAnt

        LET cNom_Cliente = TRIM(TRIM(TRIM(cNombre_1) || ' '||TRIM(cNombre_2)) ||'/'|| TRIM(TRIM(cApell_Paterno) ||','|| TRIM (cApell_Materno)));


		IF vesRegistro = '1' THEN
			--Identificar el registro de la tabla online, en la tabla del archivo batch
			SELECT cuenta,telefono,nom_cliente,fecha_nac, integridad
			INTO cNumeroCta,cTelefono_Trf,cNom_Cliente_Tf,dFecha_Naci, vRegintegro
			FROM bditransfer:"informix".tf_user_transfer
			WHERE cuenta  = TRIM(cNumCta)
			AND telefono = TRIM(cTelefono)
			AND nom_cliente = TRIM(cNom_cliente)
			AND fecha_nac = dFecha_Nac
			AND fecha_alta = dFechaAnt
			AND fecha_corte = dFechaHoy
			AND no_mod = 0;
			--si encuentra una coincidencia y tiene "V" en el campo integridad, es exitosa la conciliaciÃ³n

			IF cNumeroCta is not null and vRegintegro = 'V' and  cCodErr = '0' THEN
				UPDATE bditransfer:"informix".tf_cte_online
					SET cte_conciliado = '1',
						err_conciliacion = 'Cumplio con la integridad de los datos'
				WHERE     cuenta_tf = cNumCta AND
						telefono=cTelefono    AND
						fecha_nac=dFecha_Nac;

			elif  cNumeroCta is not null and vRegintegro = 'V' and  cCodErr <> '0'  THEN

				INSERT INTO bditransfer:"informix".tf_concilia_difer(nombrearchivo,cuenta,descripcion) VALUES ('NEWREGISTRATION ' || cNom_Cliente, cNumCta, 'LA CUENTA NO EXISTE EN LA TABLA MAESTRA ErrCod:' || cCodErr);


			--si encuentra una coincidencia y tiene "E" en el campo integridad, no es exitosa la conciliaciÃ³n
			elif  cNumeroCta is not null  and vRegintegro = 'E' THEN
				UPDATE bditransfer:"informix".tf_cte_online
					SET err_conciliacion = 'No cumple con la integridad de los datos'
				WHERE     cuenta_tf = cNumCta AND
						telefono=cTelefono    AND
						fecha_nac=dFecha_Nac;
			--si encuentra una coincidencia y tiene "P" en el campo integridad, no es exitosa la conciliaciÃ³n
			elif  cNumeroCta is not null  and vRegintegro = 'P' THEN
				UPDATE bditransfer:"informix".tf_cte_online
					SET err_conciliacion = 'Pendiente de validar integridad de datos'
				WHERE     cuenta_tf = cNumCta AND
						telefono=cTelefono    AND
						fecha_nac=dFecha_Nac;


			--si no encuentra coincidencia no realiza actualizaciones continua pendiente de conciliar
			elif  cNumeroCta is not null THEN
						LET cCodRet = '00000';

						INSERT INTO bditransfer:"informix".tf_concilia_difer(nombrearchivo,cuenta,descripcion) VALUES ('NEWREGISTRATION ' || cNom_Cliente, cNumCta, 'LA CUENTA NO EXISTE EN EL ARCHIVOs');
			END IF;

        ELIF vesRegistro = '0' THEN
			INSERT INTO bditransfer:"informix".tf_concilia_difer(nombrearchivo,cuenta,descripcion) VALUES ('NEWREGISTRATION ' || cNom_Cliente, cNumCta, 'TRANSACCION NO CONCILIADA');
		END IF;

    END FOREACH;

		INSERT INTO tf_concilia_difer(nombrearchivo,cuenta,descripcion)
		SELECT nombrearchivo,cuenta,'LA CUENTA NO EXISTE EN LA TABLA MAESTRA'
		FROM bditransfer:"informix".tf_user_transfer
		WHERE fecha_corte = dFechaHoy
		AND fecha_alta != dFechaAnt;
		--and cuenta not in (SELECT cuenta_tf FROM tf_cte_online WHERE  fec_sistema = dFechaAnt ) ;

		--SE DESCARGA LA INFORMACION DE REPORTE DE SP_CONCILIACION_TRF
		
		LET dFec_Can = YEAR(TODAY)||LPAD(MONTH(TODAY),2,'0')||LPAD(DAY(TODAY),2,'0');
			
		LET vsSQL1 = 'echo "UNLOAD TO  '||TRIM(vsRepositorio)||TRIM(vsArch)||TRIM(dFec_Can)||'.txt DELIMITER ' || ''',''';
		LET vsSQL2 =" SELECT 'consecutivo','nombrearchivo','cuenta','descripcion','fecha_insert' FROM 'informix'.tf_concilia_difer UNION SELECT  {INDEX (bditransfer:'informix'.tf_concilia_difer idx_bconcilia)}  consecutivo::CHAR(20),nombrearchivo,cuenta,descripcion,fecha_insert::CHAR(22)"
						||" FROM 'informix'.tf_concilia_difer"
						||" WHERE  fecha_insert::DATE = TODAY"
						||" AND nombrearchivo like '%NEWREGISTRATION%'"
						||" ORDER BY 1 DESC;";		
						
		LET vsSQL3 = ' " > '|| TRIM(vsRepositorio)||TRIM(vsArchTemp);

		LET vsSQL = TRIM(vsSQL1) ||' ' ||TRIM(vsSQL2)||TRIM(vsSQL3);
			
			--Verifica que no este vacia la consulta.
			IF ( vsSQL <> '' ) THEN
				SYSTEM vsSQL;
               --Permiso para la creacion de archivo.
				LET vsSQL = '' ;
				LET vsSQL = 'chmod 666 '|| TRIM(vsRepositorio)||TRIM(vsArchTemp);
				SYSTEM vsSQL ;

				LET vsSQL = '' ;
				LET vsSQL = 'dbaccess bditransfer < '|| TRIM(vsRepositorio)||TRIM(vsArchTemp) ;
				SYSTEM vsSQL ;
				--Borra el archivo de control.
				LET vsSQL = '' ;
				LET vsSQL = 'rm  '|| TRIM(vsRepositorio)||TRIM(vsArchTemp);
				SYSTEM vsSQL;				
			ELSE
				--No fue posible generar el archivo.
				LET cCodRet = '00002';
				--LET cDescripcion = 'No fue posible generar el archivo';	
			END IF;		
		
		
    RETURN cCodRet;
END;
END PROCEDURE;