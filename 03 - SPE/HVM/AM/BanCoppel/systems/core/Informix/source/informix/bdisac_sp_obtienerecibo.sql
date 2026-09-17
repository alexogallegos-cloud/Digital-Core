CREATE PROCEDURE "informix".sp_obtienerecibo(p_Sucursal CHAR(4), p_FolioSuc VARCHAR(16))
RETURNING
     CHAR(5), ---cod_ret
	 CHAR(20), ---Recibo
	 CHAR(1), ---Status Coppel
     CHAR(20); ---Cliente Coppel
	---DECLARACIONES
    DEFINE v_cod_ret            CHAR(5);
    DEFINE iSqlErr              INTEGER;
    DEFINE iSamErr              INTEGER;
	DEFINE vDesErr              CHAR(60);

	DEFINE v_Recibo				VARCHAR(20);
	DEFINE v_Status				VARCHAR(20);
    DEFINE v_Cliente			VARCHAR(20);

	SET LOCK MODE TO WAIT 3;

BEGIN
	ON EXCEPTION
        SET iSqlErr, iSamErr, vDesErr
        IF iSqlErr <> 0 THEN
            LET v_cod_ret = iSqlErr;
        END IF;
        RETURN v_cod_ret, NULL, NULL,NULL;
    END EXCEPTION;


	---INICIALIZACIONES
	LET v_cod_ret = '00000';
	LET vDesErr = '';
	LET v_Recibo 				= "";
	LET v_Status				= "";
    LET v_Cliente				= "";

	IF (p_Sucursal IS NULL OR p_Sucursal = '')  THEN 
		RETURN '00001', NULL, NULL,NULL;
	ELSE
		IF (p_FolioSuc IS NULL OR p_FolioSuc = '')  THEN 
			RETURN '00002', NULL, NULL,NULL;
		ELSE
			SELECT DISTINCT mov.referencia2, movdet.status_coppel,mov.referencia1
			INTO v_Recibo, v_Status,v_Cliente
			FROM bdisac: sac_movimientos mov, bdisac: sac_movimientos_detalle_td movdet
			WHERE mov.referencia2 = movdet.folio_abono
			AND mov.id_sucursal = p_Sucursal AND mov.folio_suc = p_FolioSuc;

			LET v_Recibo 		= NVL(v_Recibo,"");
			LET v_Cliente 		= NVL(v_Cliente,"");
		END IF
	END IF

	RETURN v_cod_ret, v_Recibo, v_Status,v_Cliente;

END;
--##############################################################################
--## Procedimiento   : sp_ObtieneRecibo
--## Base de Datos   : bdisac
--## Version         : 1.0
--## Creado por      : Enrique Dorantes
--## Fecha creacion  : Junio de 2009
--##Descripcion : Procedimiento para obtener el recibo de un pago coppel atraves del folio de sucursal
--##############################################################################

--PeticiÃ³n:	821.1
--Nombre:	Requerimiento Pagos Cruzados en Sucursal Web FRONT
--Empleado: 98640909 - Luis Alberto Beltran Rodriguez
--Fecha: 20-01-2022
--Database: bdisac

END PROCEDURE;