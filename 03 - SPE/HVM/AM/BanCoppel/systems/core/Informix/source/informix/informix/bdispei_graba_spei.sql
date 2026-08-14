create procedure "informix".graba_spei(monto money(14,2), num_cte char(20), num_ren integer, referencia varchar(255), pTrans char(4))
   returning char(5), char(30);

{
CREADO POR : Alberto Lopez de Lara
FECHA DE CREACION : 23 de Diciembre del 2003	
FUNCIONALIDAD : Utilizado por BANSI EN LINEA para registrar ordenes de pago de tipo CLIENTE-CLIENTE.
MODIFICADO POR : Arturo Salinas
DESCRIPCION MODIFICACION : Formatea a 3 digitos el codigo del banco al llamar al spl bditef:spobtenerccc
Parametros de Entrada: 
	monto : Importe de la orden que se desea enviar.
	num_cte : numero de cliente que realiza la operacion.
	num_ren : Numero de renglon de sus convenio MN que utiliza el cliente para realizar la operacion.
	referencia : Instrucciones o referencia del pago para el cliente o banco beneficiario.
	pTrans : Numero de transaccion utlizada para realizar el movimiento.

Parametros de Salida:
	Codigo de Retorno : 	'000' - Si la orden pudo ser registrada correctamente.
				<> '000' - Indica el error ocurrido al tratar de registrar la orden de pago.
	Clave de Rastreo : Entrega la clave de rastreo generada para la orden de pago registrada.

MODIFICACION: Daniel Chirinos Lopez
              L-18/sep/2006
              - Se modifico las lineas que direccionaban a bdicent por bdinteg
}

-- ************* Declaracion de Variables

-- Variables para convenio_mn
   define vt_rastreo            char(30);
   define vt_cta_cte            varchar(20);
   define vt_cliente            integer;
   define vt_banco              char(4);
   define vt_plaza              char(5);
   define vt_sucursal           char(5);
   define vt_cta_ben            char(20);
   define vt_nom_ben            char(30);
   define vt_bco_propio         char(4);
   define vt_ordenante          char(30);
   define vt_comision           money(10,2);
   define vt_clabe              char(18);
   define vt_FuenteError	char(7);
   define vdtfecha		date;

-- Variables de trabajo
   define vt_cod_ret            char(5);
   DEFINE vintcodret		INTEGER;

-- Inicia Debug del Programa	FRA 09/08/1999
-- set debug file to "/tmp/bel/graba_speua.dbg";
-- trace on;

ON EXCEPTION SET vintcodret
	IF vintcodret <> 0 THEN
		LET vt_cod_ret= vintcodret;
		RETURN vt_cod_ret, vt_rastreo;
	END IF;
END EXCEPTION;

-- ************* Inicializacion de Variables
   let vt_cod_ret = 0;
   let vt_rastreo = " ";
   let vt_clabe = "";
   
-- **********AQUI VA LA COMISION POR ENVIO SPEUA POR BEL
   let vt_comision=0;
   
-- Establece Modo de Espera
   --set isolation to cursor stability;
   set isolation dirty read;
   set lock mode to wait;

-- ************* Programa Principal
begin
-- Lectura del renglon del Convenio
   select cuentacliente, cuentabeneficiario, cliente, sucursal, banco, plaza, nombrebeneficiario, clabe
   into vt_cta_cte, vt_cta_ben, vt_cliente, vt_sucursal, vt_banco, vt_plaza, vt_nom_ben, vt_clabe
   from terceros:convenio_mn where cliente = num_cte and renglon = num_ren;
 
   if vt_banco=60 then   
        LET vt_cod_ret=755;
   	RETURN vt_cod_ret,vt_rastreo;          
   end if
      
   --Si el instructivo no tiene CLABE capturada, deben generar la CLABE del beneficiario
   IF vt_clabe IS NULL OR TRIM(vt_clabe) = '' THEN
   	EXECUTE PROCEDURE bditef:spobtenerccc(LPAD(TRIM(vt_banco),3,'0'), vt_plaza, vt_cta_ben) 
   		INTO vt_cod_ret, vt_FuenteError, vt_clabe;
   ELSE
   	--Verifica que la CLABE es correcta.
   	EXECUTE PROCEDURE bditef:spvalidaccc(vt_clabe) 
   		INTO vt_cod_ret, vt_FuenteError;
   END IF;
   
   IF vt_cod_ret <> 0 THEN
   	RETURN vt_cod_ret,vt_rastreo; 
   END IF;
   
   -- Se extrae la fecha del Movimiento
   --->select fecha_hoy into vdtfecha from bdicent:si_fechas;
   select fecha_hoy into vdtfecha from bdinteg:si_fechas;

   --Genera la clave de rastreo para la operacion
   EXECUTE PROCEDURE sp_gencverastreo('201', '20100000') INTO vt_cod_ret, vt_rastreo;
   
   IF vt_cod_ret <> 0 THEN
   	RETURN vt_cod_ret,vt_rastreo; 
   END IF;
   
   --Registra la orden de pago en el sistema.
   EXECUTE PROCEDURE sp_regordenpago(
			'20100000',
			'201',
			SUBSTR(vt_rastreo, -16),
			vt_banco,
			'S',
			vdtfecha,
			'1', --Tipo de pago CLIENTE-CLIENTE.
			NULL,
			monto,
			vt_cta_cte,
			vt_nom_ben,
			vt_clabe,
			'',
			0,
			0,
			0,
			NULL,
			NULL,
			NULL,
			NULL,
			NULL,
			referencia,
			vt_rastreo,
			pTrans) INTO vt_cod_ret, vt_rastreo;

   --Marca el pago como Listo para enviar
   UPDATE tblpago 
   SET chrestatusenvio = 'N',
   	chrusuariovent = '20100000',
   	chrfolioliqu = vt_rastreo
   WHERE vchrclaverastreo = vt_rastreo
   AND dtfechavalor = vdtfecha
   AND chrestatusenvio = 'P';


return vt_cod_ret,vt_rastreo;
end
end procedure;