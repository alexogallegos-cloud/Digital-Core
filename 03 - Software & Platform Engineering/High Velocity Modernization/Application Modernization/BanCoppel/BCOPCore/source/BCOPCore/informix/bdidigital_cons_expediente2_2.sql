CREATE PROCEDURE "informix".cons_expediente2_2(pEmpresa CHAR(3),
                pCliente    CHAR(20),
                pNum_regs   SMALLINT)
            RETURNING
            CHAR(5),CHAR(20),CHAR(40),CHAR(4),DATE,
            CHAR(3),CHAR(30),CHAR(35),CHAR(30),
            CHAR(1),SMALLINT,CHAR(1);


   DEFINE cCodret          CHAR(5);
   DEFINE cCodret2         CHAR(5);
   DEFINE cCuenta          CHAR(20);
   DEFINE cProd_nombre     CHAR(40);
   DEFINE cCod_docto       CHAR(4);
   DEFINE dFecha_alta      DATE;
   DEFINE cCod_grupo       CHAR(3);
   DEFINE cDescrip_gpo     CHAR(30);
   DEFINE cDescrip_docto   CHAR(35);
   DEFINE cDescrip2        CHAR(30);
   DEFINE cMulti_img       CHAR(1);
   DEFINE siSecuencia      SMALLINT;
   DEFINE siContador       SMALLINT;
   DEFINE iSql_err         INT;
   DEFINE iIsam_err        INT;
   DEFINE cIma_esnula      CHAR(1);


-- ****************************************************************************
-- Inicializa variables
-- ****************************************************************************

        LET cCodret            = "000";
        LET cCodret2           = "000";
        LET cCuenta            = " ";
        LET cProd_nombre       = " ";
        LET cCod_docto         = " ";
        LET dFecha_alta        = today;
        LET cCod_grupo         = " ";
        LET cDescrip_gpo       = " ";
        LET cDescrip_docto     = " ";
        LET cDescrip2          = " ";
        LET cMulti_img         = " ";
        LET siSecuencia        = 0;
        LET siContador         = 0;
        LET cIma_esnula        = "0";

-- set debug file to "/dbexportb/cons_expediente2.out";
-- trace on;

BEGIN
   ON EXCEPTION SET iSql_err,iIsam_err
      IF iSql_err <> 0 OR iIsam_err <> 0 THEN
         LET cCodret = iSql_err;
         RETURN cCodret,cCuenta,cProd_nombre,cCod_docto,dFecha_alta,
            cCod_grupo, cDescrip_gpo,cDescrip_docto,cDescrip2,
            cMulti_img,siSecuencia,cIma_esnula;
      END IF;
   END EXCEPTION;


SET ISOLATION TO DIRTY READ;
SET LOCK MODE TO WAIT 3;

-- ****************************************************************************
-- Valida la informacion de entrada
-- ****************************************************************************

    IF  pEmpresa IS NULL OR
        pCliente IS NULL OR
        pNum_regs IS NULL THEN

       -- datos de entrada incompletos

       LET cCodret = "110";
       RETURN cCodret,cCuenta,cProd_nombre,cCod_docto,dFecha_alta,
          cCod_grupo,cDescrip_gpo,cDescrip_docto,cDescrip2,
          cMulti_img,siSecuencia,cIma_esnula;
    END IF;


-- ****************************************************************************
-- obtener registros
-- ****************************************************************************

    FOREACH


        SELECT  ex.cuenta,ex.producto || ' ' || ex.prod_nombre,
                ex.cod_docto,ex.fecha_alta,gd.cod_grupo,
                gd.descripcion,td.descripcion,td.multi_imagen,
                ex.secuencia,nvl(ex.descrip2," ")
        INTO    cCuenta,cProd_nombre,cCod_docto,dFecha_alta,
                cCod_grupo,cDescrip_gpo,cDescrip_docto,
                cMulti_img,siSecuencia,cDescrip2
        FROM    bdidigital@coppelimg_crx:"informix".dg_expediente ex,
                bdidigital@coppelimg_crx:"informix".dg_grupodocto gd,
                bdidigital@coppelimg_crx:"informix".dg_tipodocumento td
        WHERE   ex.cod_docto       = td.cod_docto
                AND td.cod_grupo   = gd.cod_grupo
                AND ex.empresa     = pEmpresa
                AND ex.cliente     = pCliente
                AND ex.descrip2    <> 'firma_borra_da'
                                AND ex.cod_docto NOT IN('0137')
        ORDER BY ex.fecha_alta,ex.cuenta,ex.cod_docto


        LET siContador = siContador + 1;

        IF siContador < pNum_regs THEN
                CONTINUE FOREACH;
        END IF;

       EXECUTE PROCEDURE bdidigital@coppelimg_crx:"informix".cons_imgnula(pEmpresa,pCliente,cCod_docto,siSecuencia)
       INTO cCodret2,cIma_esnula;


        RETURN  cCodret,cCuenta,cProd_nombre,cCod_docto,
            dFecha_alta,cCod_grupo,cDescrip_gpo,
            cDescrip_docto,cDescrip2,cMulti_img,
            siSecuencia,cIma_esnula
            WITH resume;

    END FOREACH

END;
END PROCEDURE
DOCUMENT
'---------------------------------',
'DSB 07/07/2011',
'Autor: Roberto Aguilar',
'SP creado a partir de cons_expediente. Consulta el expediente de documentos del cliente.',
'---------------------------------';

CREATE PROCEDURE "informix".sp_actulizatipocliente (psEmpresa CHAR(3), psNumCliente CHAR(20), piTipoEjecucion INTEGER, pComprobante CHAR(1), pIdentificacion CHAR(1) )
RETURNING	 CHAR(5) AS Retorno

	DEFINE iSqlErr            INTEGER;
	DEFINE cCodRet            CHAR(5);
	DEFINE cCodIdentifi       CHAR(2);
	DEFINE cNumIdentifi       CHAR(30);
	DEFINE iIdentOficial      INTEGER;
	DEFINE iComDomicilio      INTEGER;
	DEFINE dFecha             DATE;
	DEFINE dFechaNacimiento   DATE;
	DEFINE cCodRetFecha       CHAR(5);
	DEFINE iEdad              INTEGER;
	DEFINE iBandera           INTEGER;

	----Varibles Mensaje Afore
	DEFINE cNumEmpleado		  CHAR(8);
	DEFINE cSucursal		  CHAR(4);
	DEFINE cCurp		 	  CHAR(18);
	DEFINE cApellPaterno	  CHAR(26);
	DEFINE cApellMaterno	  CHAR(26);
	DEFINE cNombre1	 		  CHAR(26);
	DEFINE cNombre2	  		  CHAR(26);
	DEFINE dFechaNac		  DATE;
	DEFINE cEntidadNac		  CHAR(2);
	DEFINE cSexo			  CHAR(1);
	DEFINE cAvisoCte		  CHAR(1);
	DEFINE cSucursalEjecut	  CHAR(4);
    DEFINE sTieneDireccion    CHAR(1);
    DEFINE sTieneHuella       CHAR(1);
    DEFINE sProducto          CHAR(1);
    DEFINE sAutorizacion      CHAR(1);
    DEFINE sMensajeAfore      CHAR(1);



	-----------------------------------------------------------------------------------------------------
	-- AUTOR: Felipe Urias
	-- FECHA: 14/08/2012
	-- DESCRIPCION: Realiza la validaciones necesarias para que un cliente sea considerado titulas y de
	--              cumplir con estas realiza la actualizacion del tipo de cliente.
	------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------
	-- MODIFICO:    Felipe Urias
	-- FECHA:       02/01/2013
	-- DESCRIPCION: se agrega consultas de fecha de nacimiento del cliente y consulta de la fecha actual
	--              se agrega validacion de edad  para que los menores no validen identificacion.
	------------------------------------------------------------------------------------------------------
	-----------------------------------------------------------------------------------------------------
	-- MODIFICO:    Rodolfo Tortolero
	-- FECHA:       22/02/2013
	-- DESCRIPCION: se agrega la misma funcionalidad que se utiliza en el sp_valida_aviso_privacidad
	--              para validar si el cliente tiene el aviso de privacidad.
	--              Se modifica para que consulte los documentos digitalizados en la tabla
	--              bdidigital@coppelimg_tcp:dg_expediente_img.
	--              Se agrega validaciÃ?ÃÂ³n para clientes menores de edad no sea abligatorio el campo
	--              nÃ?ÃÂ¹mero identificaciÃ?ÃÂ³n.
	------------------------------------------------------------------------------------------------------

	LET iSqlErr          = 0;
	LET cCodRet          = '00000';
	LET cCodIdentifi     = '';
	LET cNumIdentifi     = '';
	LET iIdentOficial    = 0;
	LET iComDomicilio    = 0;
	LET dFecha           = '';
	LET dFechaNacimiento = '';
	LET cCodRetFecha     = '00000';
	LET iEdad            = 0;
	LET iBandera         = 0;

	LET cNumEmpleado  = '';
	LET cSucursal	  = '';
	LET cCurp		  = '';
	LET cApellPaterno = '';
	LET cApellMaterno = '';
	LET cNombre1	  = '';
	LET cNombre2	  = '';
	LET dFechaNac	  = DATE(1);
	LET cEntidadNac	  = '';
	LET cSexo		  = '';
	LET cAvisoCte	  = '';
	LET cSucursalEjecut = '';
    LET sTieneDireccion ='';
    LET sTieneHuella ='';
    LET sProducto ='0';
    LET sAutorizacion = '';
    LET sMensajeAfore = '0';





	--SET DEBUG FILE TO "/tmp/sp_actulizatipocliente_pba.sql";
	--TRACE ON;

	SET ISOLATION TO DIRTY READ;
	SET LOCK MODE TO WAIT 3;

	BEGIN
		ON EXCEPTION SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = CAST(iSqlErr AS CHAR(5));
				RETURN cCodRet;
			END IF;
		END EXCEPTION;


        SELECT 1 INTO sTieneDireccion
        FROM  bdinteg:"informix".si_direcciones_actual WHERE numcte = psNumCliente AND tipo_dir = 1;


        SELECT codidentifi, numidentifi, fecha_nac, curp, lugar_nac, sexo
		INTO cCodIdentifi, cNumIdentifi, dFechaNacimiento, cCurp, cEntidadNac, cSexo
		FROM bdinteg:"informix".si_ctepf
		WHERE empresa = psEmpresa
		AND numcte = psNumCliente;


        --IF  EXISTS(SELECT 1 FROM  bdinteg:"informix".si_direcciones_actual WHERE numcte = psNumCliente AND tipo_dir = 1 AND secuencia = (SELECT MAX(secuencia) FROM si_direcciones_actual WHERE numcte = psNumCliente AND tipo_dir = 1))THEN
        IF  sTieneDireccion = '1' THEN

            SELECT fecha_hoy
            INTO dFecha
            FROM bdinteg:"informix".si_fechas
			WHERE empresa = psEmpresa;

			EXECUTE PROCEDURE sp_ObtenerEdadPersona(dFecha, NVL(dFechaNacimiento, '1900/01/01') )
			INTO cCodRetFecha, iEdad;

		    IF TRIM(cCodRetFecha) = '000' THEN
			    IF iEdad >=18 THEN
				    IF TRIM (NVL(cCodIdentifi,'')) <> '' AND TRIM (NVL(cNumIdentifi, '')) <> '' THEN
					    LET iBandera = 1;
				    END IF;
			    ELSE
			        IF TRIM (NVL(cCodIdentifi,'')) <> '' THEN
					    LET iBandera = 1;
				    END IF;
			    END IF;
			END IF;

			IF iBandera = 1 THEN


                SELECT 1 INTO sTieneHuella
                    FROM bdinteg:"informix".si_cte_huella WHERE numcte = psNumCliente AND estado = 'A';

				--IF EXISTS(SELECT 1 FROM bdinteg:"informix".si_cte_huella WHERE numcte = psNumCliente AND estado = 'A' AND secuencia = (SELECT MAX(secuencia)	FROM bdinteg:"informix".si_cte_huella WHERE numcte = psNumCliente AND estado = 'A')) THEN
                IF sTieneHuella = '1' THEN



                   /* SELECT NVL(num_cte,'0') INTO sProducto
                    FROM bdicheq:"informix".sc_maechq  WHERE empresa = psEmpresa AND num_cte = psNumCliente;

                    IF sProducto <> '1' THEN
                        SELECT NVL(numcte,'0') INTO sProducto
                        FROM bdisolic:"informix".ss_solicitudes WHERE empresa = psEmpresa AND numcte  = psNumCliente;
                        IF sProducto <> '1' THEN
                            SELECT NVL(num_cte,'0') INTO sProducto
                            FROM bdinvers:"informix".sv_maeinv WHERE empresa = psEmpresa AND num_cte = psNumCliente;
                            IF sProducto <> '1' THEN
                               SELECT NVL(numcte,'0')  INTO sProducto
                               FROM bdinteg:"informix".si_autorizacion_privacidad WHERE empresa = psEmpresa AND numcte = psNumCliente AND respuesta = '1';
                            END IF;
                        END IF;
                    END IF;*/


					--IF sProducto = '1' THEN
						IF piTipoEjecucion = 2 THEN
                            LET iIdentOficial = pIdentificacion;
                            LET iComDomicilio = pComprobante;

							IF iIdentOficial = 1 AND iComDomicilio = 1 THEN
								UPDATE bdinteg:"informix".si_cliente
								SET tipo_cliente = '1'
								WHERE empresa = psEmpresa
								AND numcte = psNumCliente;
								LET cCodRet = '00000';
							END IF;
						ELIF piTipoEjecucion = 1 THEN
							UPDATE bdinteg:"informix".si_cliente
							SET tipo_cliente = '1'
							WHERE empresa = psEmpresa
							AND numcte = psNumCliente;
							LET cCodRet = '00000';
						END IF;
					--END IF;
				END IF;
			END IF;
		END IF;

		IF cCodRet = '00000' THEN


            SELECT 1 INTO sAutorizacion
            FROM bdinteg:"informix".si_autorizacion_privacidad WHERE empresa = psEmpresa AND numcte = psNumCliente AND respuesta = '1';

            --IF EXISTS(SELECT numcte FROM bdinteg:"informix".si_autorizacion_privacidad WHERE empresa = psEmpresa AND numcte = psNumCliente AND respuesta = '1') THEN
			IF sAutorizacion = '1' THEN


                SELECT 1 INTO sMensajeAfore
                FROM bdinteg:"informix".si_ws_mensajeafore WHERE numcte = psNumCliente;

				--IF NOT EXISTS(SELECT numcte FROM bdinteg:"informix".si_ws_mensajeafore WHERE numcte = psNumCliente) THEN
                IF sMensajeAfore = '0' THEN

					--Obtenemos los datos del cliente
					SELECT  c.ejecutivo,c.sucursal,c.apell_paterno,c.apell_materno,c.nombre1,c.nombre2
					INTO cNumEmpleado,cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2
					FROM  bdinteg:"informix".si_cliente c
					WHERE c.numcte =  psNumCliente
					AND c.empresa =  psEmpresa;

					-- Notifica a afore
					INSERT INTO "informix".si_ws_mensajeafore(numcte,ejecutivo,sucursal,apell_paterno,apell_materno,nombre1,nombre2,curp,fecha_nac,lugar_nac,sexo,fecha_insert)
					VALUES(psNumCliente,cNumEmpleado,cSucursal,cApellPaterno,cApellMaterno,cNombre1,cNombre2,cCurp,dFechaNac,cEntidadNac,cSexo,CURRENT);
				END IF;
			END IF;
		END IF;

		RETURN cCodRet;

	END
END PROCEDURE;