CREATE PROCEDURE "informix".sp_validarfccliente(pEmpresa CHAR(3), pNumcte CHAR (20), pRFC CHAR (13))
RETURNING CHAR(5) AS retorno, 
          CHAR(1)  As Tipo;

    -- // DEFINICION DE VARIABLES
    DEFINE iSqlErr		INTEGER;
    DEFINE cValRetorno	CHAR(5);
    DEFINE cNumCte		CHAR(20);
    DEFINE cRfc			CHAR(13);
    DEFINE cRfcAlt		CHAR(13);
    DEFINE iRFCCont		INTEGER;
    Define cTipo		CHAR(1);
    DEFINE vexiste1     INTEGER;
    DEFINE vexiste2     INTEGER;
    DEFINE vexiste3     INTEGER;
    DEFINE vexiste4     INTEGER;

    -- // INICIALIZACION DE VARIABLES
    LET cValRetorno = '00005';
    LET iRFCCont    = 0;
    LET cTipo 		= 0;
    LET cTipo 		= 0;
    LET cNumCte 	= "";
    LET cRfc 		= "";
    LET cRfcAlt 	= "";
    LET vexiste1    = 0;
    LET vexiste2    = 0;
    LET vexiste3    = 0;
    LET vexiste4    = 0;

     --SET DEBUG FILE TO "/respaldosbd/cris/sp_validarfccliente.out"; 
     --TRACE ON;

    SET ISOLATION TO DIRTY READ;
    SET LOCK MODE TO wait 3;

    BEGIN
        ON EXCEPTION SET iSqlErr
            IF iSqlErr <> 0 THEN
            RETURN iSqlErr,'';
        END IF;
    END EXCEPTION;

    IF NVL(pEmpresa,'') = '' OR NVL(pRFC,'') = '' THEN
        LET cValRetorno = '00004';
    ELSE
		LET pRFC = TRIM (LPAD(TRIM(pRFC),13,'0'));
		LET cValRetorno = '00000';	
		/*  SELECT COUNT(*)
		INTO vexiste1
		FROM bdinteg:"informix".si_cliente 
		WHERE rfc = pRFC
		AND (numcte is not null OR numcte <> '');

		SELECT COUNT(*)
		INTO vexiste2
		FROM bdinteg:"informix".si_cliente 
		WHERE rfc_alterno = pRFC
		AND (numcte is not null OR numcte <> '');*/

		--  IF vexiste1 > 0 OR vexiste2 > 0 THEN
		--- IF EXISTS (SELECT rfc FROM bdinteg:"informix".si_cliente WHERE rfc = pRFC) OR EXISTS (SELECT rfc_alterno FROM bdinteg:"informix".si_cliente WHERE rfc_alterno = pRFC) THEN
		FOREACH
		
			SELECT {+ INDEX( bdinteg:si_cliente "informix".ix_cliente_rfc_alterno)} 
			numcte,rfc--,rfc_alterno 
			INTO cNumCte, cRfc--,cRfcAlt
			FROM bdinteg:"informix".si_cliente 
			WHERE rfc_alterno = pRFC 			
		
			/*SELECT
			numcte,rfc--,rfc_alterno 
			INTO cNumCte, cRfc--,cRfcAlt
			FROM bdinteg:"informix".si_cliente 
			WHERE numcte IS NOT NULL 
			AND rfc_alterno = pRFC 
			AND rfc <> ""*/
				IF cNumCte <> pNumcte THEN
				-- If NVL(cRfc,'') = pRFC OR NVL (cRfcAlt,'') = pRFC THEN
					IF NVL(cRfc,'') = pRFC THEN
						LET iRFCCont = iRFCCont + 1;
					END IF;	
				ELSE
					LET vexiste3 = 1;
				END IF;	
		END FOREACH	;	

		LET vexiste1 = dbinfo("sqlca.sqlerrd2");
		/*IF vexiste1 = 0 THEN
		LET cTipo = '4'; 
		LET cValRetorno = '00000';	
		END IF;*/
		FOREACH
			SELECT {+ INDEX( bdinteg:si_cliente "informix".ix_cliente_rfc)} 
			numcte,rfc_alterno --,rfc,rfc_alterno 
			INTO cNumCte,cRfcAlt--, cRfc,cRfcAlt
			FROM bdinteg:"informix".si_cliente 
			WHERE rfc = pRFC
			/*
			SELECT 
			numcte,rfc_alterno --,rfc,rfc_alterno 
			INTO cNumCte,cRfcAlt--, cRfc,cRfcAlt
			FROM bdinteg:"informix".si_cliente 
			WHERE rfc = pRFC
			AND numcte IS NOT NULL*/

				IF cNumCte <> pNumcte THEN
				-- If NVL(cRfc,'') = pRFC OR NVL (cRfcAlt,'') = pRFC THEN
					IF NVL(cRfcAlt,'') = pRFC THEN
					LET iRFCCont = iRFCCont + 1;
					END IF;	
				ELSE
					LET vexiste4 = 1;
				END IF;	
		END FOREACH	;		

		LET vexiste2 = dbinfo("sqlca.sqlerrd2");
		/*IF vexiste2 = 0 THEN
		LET cTipo = '4'; 
		LET cValRetorno = '00000';	
		END IF;*/

		/*SELECT COUNT(*)
		INTO vexiste3
		FROM bdinteg:"informix".si_cliente 
		WHERE rfc = pRFC 
		AND numcte = pNumcte;

		SELECT COUNT(*)
		INTO vexiste4
		FROM bdinteg:"informix".si_cliente 
		WHERE rfc_alterno = pRFC 
		AND numcte = pNumcte;*/

		IF vexiste1 > 0 OR vexiste2 > 0 THEN
			IF vexiste3 = 0 AND vexiste4 = 0 THEN
				--- IF NOT EXISTS (SELECT rfc FROM bdinteg:"informix".si_cliente WHERE rfc = pRFC AND numcte = pNumcte) AND  NOT EXISTS (SELECT rfc_alterno FROM bdinteg:"informix".si_cliente WHERE rfc_alterno = pRFC AND numcte = pNumcte) THEN
				LET cTipo = '4'; 
				--LET cValRetorno = '00000';						
				IF iRFCCont = 0 THEN							
					LET cTipo = '2'; 
					-- LET cValRetorno = '00000';
				END IF;
			ELSE
				LET cTipo = '3';
					-- LET cValRetorno = '00000';			
			END IF;
		ELSE    --    ELSE
			LET cTipo = '1'; -- Mostrar Mensaje
			--   LET cValRetorno = '00000';			
		END IF;
    END IF;
	
    RETURN cValRetorno,cTipo;
    
	END
    
END PROCEDURE
DOCUMENT
'Creado: Martin Miranda',
'Fecha: 04/03/2011',
'Descripcion: Se crea para validar el rfc del cliente ',
'Modifico: Martin Miranda',
'Fecha: 07/06/2011',
'Descripcion: Modifica para agregar un nuevo retorno para el caso en que no exista el',
'RFC enviado en el Cliente Consultado pero que si exista en otro Cliente diferente',
'Modifico: Cristian Valentina Aguilar',
'Fecha: 02/05/2012',
'Descripcion: Se optimiza procedimiento se quintan select count' ,
'Modifico: Cristian Valentina Aguilar',
'Fecha: 21/06/2012',
'Descripcion: Se cambia para que tome los nuevos index' ;

CREATE PROCEDURE "informix".sp_generararchivoplano_pba(cTipoMov CHAR(2), pFechaAct DATE)
RETURNING
     CHAR(6); ---cod_ret

    DEFINE v_cod_ret            CHAR(6);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE vDesErr              CHAR(60);
	DEFINE vsSQL1 				CHAR (150);
	DEFINE vsSQL2 				CHAR (750) ;
	DEFINE vsSQL3 				CHAR (150) ;
	--DEFINE v_NomArchivo  VARCHAR(50);
	DEFINE vRuta CHAR (90);
	DEFINE vsSQL CHAR (1050) ;
	DEFINE sPreNomArchivoFinal VARCHAR(100);
	DEFINE sNombreArchivoFinal VARCHAR(100);
	DEFINE iCountMovTO INTEGER;
	DEFINE  v_TipoMov VARCHAR (20);
	DEFINE cFecha_hoy CHAR(8);
	DEFINE cFechaSistema DATE;
	
	LET vsSQL = '' ;
	LET vsSQL1 = '' ;
	LET vsSQL2 = '' ;
	LET vsSQL3 = '' ;
	LET iCountMovTO = 0;
	LET  v_TipoMov = '';
	LET cFecha_hoy = '19000101';
	LET cFechaSistema = DATE(1);
	
	SET LOCK MODE TO WAIT 10;


BEGIN

   ON EXCEPTION
        SET iSqlErr, iSamErr
        IF iSqlErr <> 0 THEN
                LET v_cod_ret = iSqlErr;
                --EXECUTE PROCEDURE bdinteg:"informix".sp_desc_ret(20, v_cod_ret)
                --INTO v_cod_ret, vDesErr;
        END IF;
        RETURN v_cod_ret;
    END EXCEPTION;
	
	SET LOCK MODE TO WAIT 3;

	SET DEBUG FILE TO "/resplogifx/archivoscartera/altaunica/envios/sp_generararchivoplano_pba.out";
	--SET DEBUG FILE TO "/resplogifx/archivoscartera/altaunica/envios/sp_GenerarArchivoPlano.out";
	TRACE ON;

	LET v_cod_ret = '000000';
	LET vDesErr = '';

	---LET vRuta = '/resplogifx/archivoscartera/altaunica/envios/';
	LET vRuta = '/respaldos/rodolfo/';
	---LET sNombreArchivoFinal = '/resplogifx/archivoscartera/altaunica/envios/movimientosaltaunica';
	LET sNombreArchivoFinal = '/respaldos/rodolfo/movimientosaltaunica';

	
	IF cTipoMov IS NULL OR (cTipoMov <> '' AND cTipoMov <> 'TO') THEN
		LET v_cod_ret = '000001';
		RETURN v_cod_ret;
	END IF;
	
	SELECT COUNT(tipomovto) INTO iCountMovTO FROM bdinteg:"informix".si_archivoscoppeldiario WHERE tipomovto = 'TO';
	
	SELECT fecha_hoy INTO cFechaSistema FROM bdinteg:"informix".si_fechas;
	
	IF pFechaAct <> mdy(1,1,1900) OR pFechaAct IS NOT NULL THEN	
		IF iCountMovTO > 0 THEN
			IF cTipoMov = '' THEN	---	Se valida el tipo de movimiento
				IF EXISTS (SELECT DISTINCT tipomovto FROM bdinteg:"informix".si_archivoscoppeldiario WHERE tipomovto <> 'TO') THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
					LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
					LET sNombreArchivoFinal = '/respaldos/rodolfo/movimientosaltaunica'|| cFecha_hoy || '.txt' ;
					LET sPreNomArchivoFinal = '/respaldos/rodolfo/movimientosaltaunica.unl';
					---LET vsSQL = ' echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/altaunica/envios/movimientosaltaunicax.unl''' || ' DELIMITER ' || '''|''' || 
					LET vsSQL = ' echo "UNLOAD TO ' || '''/respaldos/rodolfo/movimientosaltaunicax.unl''' || ' DELIMITER ' || '''|''' || 
								' SELECT trama '||
								' FROM bdinteg:si_archivoscoppeldiario '||
								' WHERE tipomovto <> '||'''TO'''||
								' " > /respaldos/rodolfo/Ejecutamovimientosaltaunica.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					LET vsSQL = 'dbaccess bdinteg /respaldos/rodolfo/Ejecutamovimientosaltaunica.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					---LET vsSQL =  "sed 's/\\//g' /resplogifx/archivoscartera/altaunica/envios/movimientosaltaunicax.unl > " || sPreNomArchivoFinal;
					LET vsSQL =  "/resplogifx/archivoscartera/altaunica/envios/sed_arc.sh /respaldos/rodolfo/movimientosaltaunicax.unl " || sNombreArchivoFinal;
					SYSTEM vsSQL;
					LET vsSQL = '';
					---LET vsSQL =  "sed 's/|$//g' /resplogifx/archivoscartera/altaunica/envios/movimientosaltaunica.unl > " || sNombreArchivoFinal;
					---SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "chmod 777 "||sNombreArchivoFinal||" > "||"/respaldos/rodolfo/movimientosaltaunicaderechos.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					LET vsSQL =  "rm /respaldos/rodolfo/movimientosaltaunicaderechos.txt";
					SYSTEM vsSQL;
					
					---	RESPALDA LOS DATOS DEL MOVIMIENTO A LA TABLA HISTORICA
					INSERT INTO bdinteg:"informix".si_archivoscoppelhistorial(empresa,secuencia, identificador,trama,tipomovto,fecha_archivo,fecha_insert)
					SELECT empresa,secuencia,'',trama,tipomovto,fecha_insert, cFechaSistema
					FROM bdinteg:"informix".si_archivoscoppeldiario
					WHERE tipomovto <> 'TO';
					
					--BORRA LOS MOVIMIENTOS DE LA TABLA DIARIA
					DELETE FROM bdinteg:"informix".si_archivoscoppeldiario
					WHERE tipomovto <> 'TO';
					
				END IF;
			ELIF cTipoMov = 'TO'  THEN --Valida el tipo de movimiento para generar el archivo de totales
				LET v_cod_ret = '000000';
				IF EXISTS (SELECT DISTINCT tipomovto FROM bdinteg:"informix".si_archivoscoppeldiario WHERE tipomovto = 'TO') THEN		---	Se valida que que tlpo de movimiento se encuentre en la tabla
					LET cFecha_hoy = YEAR(pFechaAct)||""||LPAD(MONTH(pFechaAct),2,0)||""||LPAD(DAY(pFechaAct),2,0);
					---LET sNombreArchivoFinal = '/resplogifx/archivoscartera/altaunica/envios/cifrasaltaunica'|| cFecha_hoy || '.txt';
					LET sNombreArchivoFinal = '/respaldos/rodolfo/cifrasaltaunica'|| cFecha_hoy || '.txt';
					---LET sPreNomArchivoFinal = '/resplogifx/archivoscartera/altaunica/envios/cifrasaltaunica.unl';
					LET sPreNomArchivoFinal = '/respaldos/rodolfo/cifrasaltaunica.unl';
					---	GENERA EL ARCHIVO PLANO
					---LET vsSQL1 = ' echo "UNLOAD TO ' || '''/resplogifx/archivoscartera/altaunica/envios/cifrasaltaunicax.unl''' || ' DELIMITER ' || '''|''';
					LET vsSQL1 = ' echo "UNLOAD TO ' || '''/respaldos/rodolfo/cifrasaltaunicax.unl''' || ' DELIMITER ' || '''|''';
					LET vsSQL2 = "SELECT  trama FROM  bdinteg:si_archivoscoppeldiario WHERE  tipomovto = '"||cTipoMov||"';";
					LET vsSQL3 = ' " > '|| TRIM(vRuta) || 'Ejecutacifrasaltaunica.sql'; 
					LET vsSQL = vsSQL1 || vsSQL2 || vsSQL3;
					SYSTEM vsSQL;

					LET vsSQL = '';
					---LET vsSQL = 'dbaccess bdinteg /resplogifx/archivoscartera/altaunica/envios/Ejecutacifrasaltaunica.sql';
					LET vsSQL = 'dbaccess bdinteg /respaldos/rodolfo/Ejecutacifrasaltaunica.sql';
					SYSTEM vsSQL;

					LET vsSQL = '';
					---LET vsSQL =  "sed 's/\\//g' /resplogifx/archivoscartera/altaunica/envios/cifrasaltaunicax.unl > "|| sPreNomArchivoFinal;
					LET vsSQL =  "sed 's/\\//g' /respaldos/rodolfo/cifrasaltaunicax.unl > "|| sPreNomArchivoFinal;
					SYSTEM vsSQL;
					LET vsSQL = '';
					---LET vsSQL =  "sed 's/|$//g' /resplogifx/archivoscartera/altaunica/envios/cifrasaltaunica.unl > "|| sNombreArchivoFinal;
					LET vsSQL =  "sed 's/|$//g' /respaldos/rodolfo/cifrasaltaunica.unl > "|| sNombreArchivoFinal;
					SYSTEM vsSQL;
					LET vsSQL = '';
					---LET vsSQL =  "chmod 777 " || sNombreArchivoFinal || " > "|| "/resplogifx/archivoscartera/altaunica/envios/cifrasaltaunicaderechos.txt";
					LET vsSQL =  "chmod 777 " || sNombreArchivoFinal || " > "|| "/respaldos/rodolfo/cifrasaltaunicaderechos.txt";
					SYSTEM vsSQL;
					LET vsSQL = '';
					---LET vsSQL =  "rm /resplogifx/archivoscartera/altaunica/envios/cifrasaltaunicaderechos.txt";
					LET vsSQL =  "rm /respaldos/rodolfo/cifrasaltaunicaderechos.txt";
					SYSTEM vsSQL;

					---	RESPALDA LOS DATOS DEL MOVIMIENTO A LA TABLA HISTORICA
					INSERT INTO bdinteg:"informix".si_archivoscoppelhistorial(empresa,secuencia,identificador,trama,tipomovto,fecha_archivo,fecha_insert)
					SELECT empresa,secuencia,'', trama,tipomovto,fecha_insert, cFechaSistema
					FROM bdinteg:"informix".si_archivoscoppeldiario
					WHERE tipomovto = 'TO';
					
					--BORRA LOS MOVIMIENTOS DE LA TABLA DIARIA
					DELETE FROM bdinteg:"informix".si_archivoscoppeldiario
					WHERE tipomovto = 'TO';
					
				END IF;
			END IF;
		ELSE
			LET v_cod_ret = '000002';
		END IF;
	ELSE
		LET v_cod_ret = '000003';
	END IF;
	RETURN v_cod_ret;
END;
--##############################################################################
--## Procedimiento   : "informix".sp_GenerarArchivoPlano
--## Version         : 1.0
--## Creado por      : Mohamed Carreón
--## Fecha creacion  : Diciembre de 2008
--## Descripcion     : Realiza la generacion del archivo plano.
--##############################################################################
--## Modificado por  : Adrian Lara
--## Fecha creacion  : Octubre de 2011
--## Descripcion     : Se cambia el nombre al archivo que se genera y se agrega sentencia para limpiar el archivo.
--##############################################################################
END PROCEDURE;