CREATE PROCEDURE "informix".sp_obtieneparametrochequera (pCodParam SMALLINT)

RETURNING
        CHAR( 5) AS CODRET,     -- CODIGO DE RETORNO
        CHAR(80) AS MENSAJE,    -- MENSAJE DE RETORNO
        CHAR(60) AS VALOR;      -- VALOR DEL PARAMETRO CONSULTADO
       
		 
    --DECLARACION DE VARIABLES
    DEFINE iSqlErr      INTEGER;
    DEFINE cCodRet      CHAR( 5);
    DEFINE cMensaje     CHAR(80);
    DEFINE cValor       CHAR(60);    
			
	--Crea el control de errores
	ON EXCEPTION SET iSqlErr
		IF iSqlErr != 0 THEN
			LET cCodRet= iSqlErr;
			RETURN cCodRet, cMensaje, cValor;
		END IF;
	END EXCEPTION; 		
	
	--SET DEBUG FILE TO "/respaldosbd/Armando/sp_ObtieneParametroChequera.out";
	--TRACE ON;
			
    --INICIALIZAR VARIABLES
    LET cCodRet 	= '00000';
    LET cMensaje	= '';    
    LET cValor		= '';    
	LET iSqlErr		=0;
    
    set isolation to dirty read;
    set lock mode to wait 3;
         
	BEGIN
	
	    --Validacion del parametro de entrada		
	    IF pCodParam is null then
			Let cCodRet = '001';
			Let cMensaje = 'Parametro de entrada con valor no valido, verificar';
			RETURN cCodRet, cMensaje, cValor;
	    END IF;

	    --Obtengo el valor del parametro a consultar
		SELECT TRIM(NVL(valor, ''))
		INTO cValor 
		FROM bdicntchq:"informix".sq_param 
		WHERE cod_param = pCodParam; 

		--Valido que se encontro el parametro
		IF cValor IS NULL OR cValor = '' THEN
			Let cCodRet = '002';
			Let cMensaje = 'Parametro consultado no existe';
			RETURN cCodRet, cMensaje, cValor;
		END  IF;
		
		--Retorno valor obtenido
		RETURN cCodRet, cMensaje, cValor;
			
	END
END PROCEDURE
DOCUMENT
'CREACION     : ARMANDO MERCADO FIGUEROA',
'DESCRIPCION  : OBTIENE PARAMETROS BASICOS PARA EL SISTEMA DE CHEQUERAS',
'FECHA    	  : MAYO 2011',
'BASE DE DATOS: BDICNTCHQ',
'VERSION  	  : 20110506';

create procedure "informix".sp_altachequeras_esp( pempresa char(3), --Empresa
                                            pcuenta  char(20), -- Cuenta
                                            pcanal   smallint, --Canal 1 NUEVA, 2 CAT , 3  Internet, 4 CENTRAL
                                            ptipo    Char(2),   -- Tipo de Chequera
                                            pusuario Char(8)    --Usuario
                                            )
       returning     char(5);   -- vcodret

   -- ********************************************************************
   --
   -- Nombre:              sp_altachequeras_esp
   --
   -- Version              1.0.2
   -- Objetivo:            Alta de  chequeras...SIN VALIDACION DE CHEQUES ACTIVOS
   -- Supuestos:           Ninguno
   -- Creado por:          Jorge Arango
   -- Modificado por:      Alejandro Rueda Sanchez
   -- Ultima Modificacion: Febrero  - 2010
   --
   --                      Reingenieria de SPL
   --
   -- ********************************************************************

   -- // Definicion de variables
   DEFINE vcodret         char(5);
   DEFINE vcodreterr      char(5);
   DEFINE vsqlerr         integer;
   DEFINE vno_cheques     smallint;
   DEFINE vconsec         integer;
   DEFINE v_hoy           date;
   DEFINE v_sucursal      char(4);
   DEFINE v_status        char(1);
   DEFINE v_valor         char(1);
   DEFINE v_inicial       INTEGER;
   DEFINE v_final         INTEGER;
   DEFINE a               SMALLINT;
   DEFINE vnumchq         INTEGER;
   DEFINE vnumactivos     INTEGER;
   DEFINE vmaxpermite     INTEGER;
   DEFINE vdummy          char(100);
   DEFINE vdummy1         char(100);
   DEFINE vfecha       	  DATETIME hour TO second;
   DEFINE vfecha1 	  char(8);
   DEFINE vhora           char(10);
   DEFINE vult_chq        INTEGER;
   DEFINE vsdopromant     DECIMAL(12,2);
   DEFINE vsdopromant_parm DECIMAL(12,2);
   DEFINE vfecha_alta 	  DATE;
   DEFINE vfechames  	  DATE;
   DEFINE vproducto  	  CHAR(4);
   DEFINE vval_chequeras  CHAR(1);



   LET vcodret      = " ";
   LET vno_cheques  = " ";
   LET vsqlerr      = 0;
   LET v_status     = " ";
   LET vno_cheques  = 0;
   LET vconsec      = 0;
   LET v_sucursal   = " ";
   LET v_status     = " ";
   LET v_inicial    = 0;
   LET v_final      = 0;
   LET a            = 0;
   LET v_valor      = " ";
   LET vnumchq      = 0;
   LET vmaxpermite  = 0;
   LET vdummy      = " ";
   LET vdummy1     = " ";
   LET vfecha1     = current hour to second;
   --LET vfecha1    = vfecha;
   LET vhora       = vfecha1; --trim(vfecha1[1,2])|":"|trim(vfecha1[4,5]);
   LET vsdopromant_parm = 0;
   LET vproducto   = "0000";
   LET vval_chequeras =  "N";




   --SET DEBUG FILE TO "/tmp/sp_altachequeras.out";
   --TRACE ON;

begin
    on exception set vsqlerr
       IF vsqlerr <> 0 then
          LET vcodret = vsqlerr;
          RETURN vcodret;
       END IF;
    END exception;

   --- Selecciona la fecha del dia.
   SELECT fecha_hoy INTO v_hoy FROM bdicheq:sc_fechas;

   --Validaciones de nulos en parametros de entrada
   IF pempresa = " " or pcuenta = " " or pcanal = 0 then
      LET vcodret = "001";
      call sp_errores( v_hoy, vhora, pcuenta, "001","sp_altachequeras","Error en Parametros de Entrada Nulos",pusuario);
      RETURN vcodret;
   END if

   --- Selecciona el numero de cheques por tipo de chequera.
   If ptipo = " " then
       SELECT valor INTO ptipo
       FROM sq_param
       WHERE cod_param = 2;
   END if

   --- Selecciona el numero de cheques por tipo de chequera.
   SELECT valor INTO vmaxpermite
     FROM sq_param
    WHERE cod_param = 3;
  
   --//Selecciona el monto minimo saldo promedio mes anterior
   SELECT valor INTO vsdopromant_parm
     FROM sq_param
    WHERE cod_param = 21;

   --//Selecciona el numero de cheques del tipo de chequera 
   SELECT no_cheques
     INTO vno_cheques
     FROM bdicntchq:sq_chequera
    WHERE chequera = ptipo;

   IF vno_cheques is null  then
      LET vcodret = "002";
      call sp_errores( v_hoy, vhora, pcuenta, "002","sp_altachequeras","Error al Consultar el Tipo de Chequera",pusuario);
      RETURN vcodret;
   END if

   --- Selecciona el numero maximo de cheques.
   SELECT max(numero)
     INTO vnumchq
     FROM bdicheq:sc_contch
    WHERE empresa = pempresa
      AND cuenta = pcuenta;

   IF vnumchq is null then
      LET vnumchq = 1;
   else
      LET vnumchq =  vnumchq + 1;
   END if

   --validacion de chequera maxima
   SELECT max(consec)
   INTO vconsec
   FROM bdicntchq:sq_maechqra
   WHERE cuenta = pcuenta;

   --Si la chequera es mayor o igual a 1 y el canal es OFI Regreso codigo de error
   If (vconsec >= 1 AND pcanal = 1) or (vconsec is null AND pcanal = 2) then
      LET vcodret = "004";
      call sp_errores( v_hoy, vhora, pcuenta, "004","sp_altachequeras","Error Existen Chequeras Asignadas a esta Cuenta, No Puede Darse de Alta Como Nueva",pusuario);
      RETURN vcodret;
   END if

   IF vconsec is null then
      LET vconsec = 1;
   else
      LET vconsec =  vconsec + 1;
   END if

   --Se trae el numero de sucursal y producto
   SELECT sucursal, status_cta, producto
     INTO v_sucursal, v_status, vproducto
    FROM bdicheq:sc_maechq
   WHERE empresa = pempresa
     AND cuenta = pcuenta;

   --Valida el status de la cuenta
   IF v_status <> "1" THEN
      LET vcodret = "005";
      call sp_errores( v_hoy, vhora, pcuenta, "005","sp_altachequeras","Error la Cuenta no Esta Activa",pusuario);
      RETURN vcodret;
   END IF

   --//Valida sea un producto de chequeras
   SELECT val_chequeras     
     INTO vval_chequeras
     FROM bdicheq:sc_producto
    WHERE empresa = pempresa 
      AND producto = vproducto;

   IF vval_chequeras <> "S" THEN
      LET vcodret = "007";
      call sp_errores( v_hoy, vhora, pcuenta, "007","sp_altachequeras","Error producto no acepta de chequeras",pusuario);
      RETURN vcodret;
   END IF

   --Inicia proceso de actualizacion de Datos

   LET v_inicial = vnumchq;
   LET v_final   = vnumchq + vno_cheques -1;

   If pcanal = 1 then --Apertura nueva


      INSERT INTO bdicntchq:sq_maechqra(empresa, cuenta, consec, inicial, final, fecha_req, fecha_rec, fecha_ent, status, proveedor, sucursal, usuario, origen)
       VALUES(pempresa, pcuenta, vconsec, v_inicial, v_final, v_hoy, " ", " ",
              'S', '000', v_sucursal, pusuario, pcanal);

      -- Inserta requerimiento de chequeras
       FOR a = vnumchq TO v_final

           INSERT INTO bdicheq:sc_contch(empresa, cuenta, numero, estado, fecha_alta, importe, consec)
           VALUES(pempresa, pcuenta, a, "S", v_hoy, 0, vconsec);

       END FOR
         
       --/Actualiza el maestro de cheques con el numero de cheques emitidos
       UPDATE bdicheq:sc_maechq
            SET ult_chq = v_final
          WHERE empresa = pempresa
            AND cuenta = pcuenta;

       LET vcodret = "000";
       RETURN vcodret;

   ELIF pcanal <> 1 then  --CAT 2; Internet 3; Central 4

/*        IF (SELECT COUNT(*) FROM bdicntchq:sq_maechqra WHERE empresa = pempresa AND cuenta = pcuenta AND status IN ('S','P','G','E','N','D')) > 0 THEN
             LET vcodret = "992";
             call sp_errores( v_hoy, vhora, pcuenta, "992","sp_altachequeras","Ya existe una chequera en curso",pusuario);
            RETURN vcodret;
        END IF    
*/
      --//Valida que el saldo promedio mes anterior, sea mayor ó igual al requerido en el parametro 21
      SELECT sdo_prom_mesant, fecha_alta
        INTO vsdopromant, vfecha_alta
        FROM bdicheq:sc_maenoc
       WHERE empresa = pempresa
         AND cuenta = pcuenta;

      --//Si tiene saldo promedio mayor a 0, no es apertura reciente
      IF vsdopromant > 0 THEN
         IF vsdopromant < vsdopromant_parm THEN 
              LET vcodret = "006";
              call sp_errores( v_hoy, vhora, pcuenta, "006","sp_altachequeras","Error el Saldo promedio mes anterior, es menor al necesario", pusuario);
              RETURN vcodret;
         END IF
      ELSE --//Verifica que no sea cuenta reciente para saldo promedio = 0
         EXECUTE PROCEDURE bdicheq:sp_mes_siguiente(vfecha_alta,1,day(vfecha_alta))
                      INTO vdummy, vfechames, vdummy;

         IF v_hoy > vfechames THEN
            IF vsdopromant < vsdopromant_parm THEN 
               LET vcodret = "006";
               call sp_errores( v_hoy, vhora, pcuenta, "006","sp_altachequeras","Error el Saldo promedio mes anterior, es menor al necesario", pusuario);
               RETURN vcodret;
            END IF
         END IF
      END IF

      --- Validacion de Cheque Activo.
       SELECT count(numero)
         INTO vnumactivos
         FROM bdicheq:sc_contch
        WHERE cuenta = pcuenta
          AND empresa = pempresa
          AND estado = "A";

/*       IF vnumactivos > vmaxpermite then
           LET vcodret = "003";
           call sp_errores( v_hoy, vhora, pcuenta, "003","sp_altachequeras","Error el Numero de Cheques Activos, Supera los Permitidos",pusuario);
           RETURN vcodret;
       END if
*/
      INSERT INTO bdicntchq:sq_maechqra(empresa, cuenta, consec, inicial, final, fecha_req, fecha_rec, fecha_ent, status, proveedor, sucursal, usuario, origen)
       VALUES(pempresa, pcuenta, vconsec, v_inicial, v_final, v_hoy, " ", " ",
              'S', '000', v_sucursal, pusuario, pcanal);

      -- Inserta requerimiento de chequeras
       FOR a = vnumchq TO v_final

           INSERT INTO bdicheq:sc_contch(empresa, cuenta, numero, estado, fecha_alta, importe, consec)
           VALUES(pempresa, pcuenta, a, "S", v_hoy, 0, vconsec);

       END FOR

      -- Actualiza el maestro de cuentas de cheques
      LET vult_chq = 0;
      SELECT ult_chq 
        INTO vult_chq
        FROM bdicheq:sc_maechq
       WHERE empresa = pempresa
         AND cuenta = pcuenta;

      IF v_final > vult_chq THEN
         UPDATE bdicheq:sc_maechq
            SET ult_chq = v_final
          WHERE empresa = pempresa
            AND cuenta = pcuenta;
      END IF


       LET vcodret = "000";
       RETURN vcodret;
   END if
end
END procedure;