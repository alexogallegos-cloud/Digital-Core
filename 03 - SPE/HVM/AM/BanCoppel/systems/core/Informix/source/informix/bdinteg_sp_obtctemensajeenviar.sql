CREATE PROCEDURE "informix".sp_obtctemensajeenviar(pRegistro smallint)

	RETURNING  CHAR(5) ,DATETIME year to fraction,CHAR(10),CHAR(16), CHAR(16), CHAR(1), CHAR(80), CHAR(80), MONEY(16,2), CHAR(2), 
				CHAR(60), CHAR(60), CHAR(40), CHAR(100), CHAR(40);

	--************************************
	--sp_obtctemensajeenviar
	--Objetivo: Obtener los clientes a los que se les enviarán los correos de manera dinámica.
	--Autor: Francisco Rodriguez Ibarra
	--Fecha: 12/07/2010
	--************************************************************
	--Actualización:Se modificó para poder retornar la fecha en datetime
	--Fecha:15/07/2010
	--Autor:Francisco Rodriguez Ibarra
	--**************************************************************
	--Actualización:Se agrega el order by por linea
	--Fecha:22/07/2010
	--Autor:Walber Castro
	--********************************************************************
	--Actualización:Se modifica para enviar el dato de inicio y fin de lineas del mensaje asi como suprimir información que no se necesita del query.
	--Fecha:12/01/2011
	--Autor:Walber Castro
	--*******************************************************************
	--Actualización:Se modifica para retornar el número y tipo de tarjeta.
	--Fecha:19/10/2011
	--Autor:Manuel Ramos Figueroa
	--****************************************

	--DEFINICION DE VARIABLES
	DEFINE iSqlErr		INTEGER;					--variable usada par obtener el numero de error de informix en caso de que ocurra un error interno de informix.
	DEFINE cCodRet		CHAR(5);					--variable para el codigo de retorno
	DEFINE dFecMensaje	DATETIME year to fraction;	--variable para obtener la fecha en que se envia el mensaje
	DEFINE cNumCte		CHAR(10);					--variable para obtener el numero de cliente
	DEFINE cNumCta		CHAR(16);					--variable para obtener la cuenta del cliente
	DEFINE cNumTar		CHAR(16);					--variable para obtener el numero de tarejta del cliente
	DEFINE cTipoTar		CHAR(1);					--variable para obtener el tipo de tarjeta del cliente
	DEFINE vNomCte		VARCHAR(80);				--variable para obtener el nombre del cliente
	DEFINE vCorreo		VARCHAR(80);				--variable para obtener el correo
	DEFINE mMonto		money(16,2);				--variible para obtener el monto
	DEFINE cIdTipoMen	CHAR(2);					--id tipo de transanccion
	DEFINE iCont		INTEGER;					--variable usada para detectar si hay o no clientes con mensajes pendientes
	DEFINE iAux			INTEGER;
	DEFINE vLinea		VARCHAR(60);
	DEFINE vAsunto		VARCHAR(60);
	DEFINE vEncabezado	VARCHAR(40);
	DEFINE vDetalle		VARCHAR(100);
	DEFINE vPie			VARCHAR(40);
	DEFINE vMaxLinea	VARCHAR(9);


	--ASIGNACION DE VALORES A LAS VARIABLES
	LET iSqlErr		= 0;
	LET cCodRet		= "00000";
	LET dFecMensaje	= null;
	LET cNumCte		= "";
	LET cNumCta		= "";
	LET cNumTar		= "";
	LET cTipoTar	= "";
	LET vNomCte		= "";
	LET vCorreo		= "";
	LET mMonto		= "0.00";
	LET cIdTipoMen	= "";
	LET vLinea		= "";
	LET vAsunto		= "";
	LET vEncabezado	= "";
	LET vDetalle	= "";
	LET vPie		= "" ;
	LET iCont		= 0;
	LET iAux		= 0;
	
	--set debug file to "sp_obtctemensajeenviar.out";
	--trace on;

	BEGIN
		ON EXCEPTION
			SET iSqlErr
			IF iSqlErr <> 0 THEN
				LET cCodRet = iSqlErr;
				RETURN cCodRet, "", "", "", "", "", "","", "", "" ,"", "","", "", "";
			END IF;
		END EXCEPTION;

		IF NVL( pRegistro, '' ) = '' THEN
			--Error en datos de parametros invalidos
			LET cCodRet = '00001';
			RETURN cCodRet, "", "", "", "", "", "","", "", "" ,"", "","", "", "";
		END IF;
		
		SET LOCK MODE TO WAIT 3;
		SET ISOLATION DIRTY READ;
		FOREACH
				SELECT {+ INDEX (bdinteg:"informix".si_mensajes_enviar "informix".idx_msgs_envdos), +INDEX (bdinteg:"informix".si_tipo_mensaje "informix".idx_tipo_msg)} SKIP pRegistro FIRST 10
				    a.f_mensaje, a.numcte, a.cuenta, a.num_tarjeta, a.tipo_tarjeta, a.nombre_cliente, a.correo_cliente, a.monto_reportar, a.id_tipo_mensaje,
					b.linea,b.asunto,b.encabezado,b.detalle,b.pie
				INTO dFecMensaje, cNumCte, cNumCta, cNumTar, cTipoTar, vNomCte, vCorreo, mMonto, cIdTipoMen, 
				    vLinea, vAsunto, vEncabezado, vDetalle, vPie
				FROM bdinteg:"informix".si_mensajes_enviar as a, bdinteg:"informix".si_tipo_mensaje  as b
				WHERE extend(a.f_mensaje, year to day) >= "2010-07-01"
				AND a.enviado='F'
				AND a.id_tipo_mensaje = b.id_tipo_mensaje
				AND b.id_tipo_mensaje <> '00'
				AND b.linea > 0
				ORDER BY f_mensaje, a.numcte, a.cuenta, a.id_tipo_mensaje, b.linea

				SELECT MAX(linea)
				INTO vMaxLinea
				FROM bdinteg:"informix".si_tipo_mensaje
				WHERE id_tipo_mensaje = cIdTipoMen;

				IF ( vMaxLinea = vLinea ) THEN
					LET vLinea = "FIN";
				END IF;

					LET iCont = iCont + 1;
					LET iAux  = iAux + 1;

				IF ( vLinea = '1' ) THEN
					LET vNomCte = "INICIO";
				ELSE
					LET vNomCte    = "";
					LET vCorreo    = "";
					LET mMonto     = "";
					LET cIdTipoMen = "";
					LET vAsunto    = "";
				END IF;

				RETURN cCodRet,dFecMensaje,cNumCte,cNumCta,cNumTar,cTipoTar,vNomCte,vCorreo,mMonto,cIdTipoMen , 
					vLinea , vAsunto , vEncabezado , vDetalle ,vPie WITH RESUME;
		END FOREACH

		IF ( iCont = 0 ) THEN
			LET cCodRet = '00002'; ---no hay mensajes pendientes de enviar
			RETURN cCodRet, "", "", "", "", "", "","", "", "" ,"", "","", "", "";
		END IF

	END;
END PROCEDURE;