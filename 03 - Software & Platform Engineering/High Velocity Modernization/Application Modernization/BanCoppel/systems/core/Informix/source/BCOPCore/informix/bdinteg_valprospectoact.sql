CREATE PROCEDURE "informix".valprospectoact(cEmpresa CHAR(4),
                                                     cNumcte  CHAR(20))
  RETURNING CHAR(5), CHAR(1);

   --DEFINICION DE VARIABLES
   DEFINE cCodret             CHAR(5);
   DEFINE cExiste			  CHAR(1);
   DEFINE iSqlErr             INTEGER;
   DEFINE cTipoCliente	      CHAR(1);

   --INCIALIZACION DE VARIABLES
   LET cCodret = '00000';
   LET cExiste = 0;
   LET cTipoCliente = "0";

   BEGIN

        ON EXCEPTION SET iSqlerr
            IF iSqlErr <> 0 THEN
                LET cCodret = iSqlErr;
                RETURN cCodret,cExiste ;
            END IF;
        END EXCEPTION;

  --SET DEBUG FILE TO '/tmp/ValProspectoAct.out';
  --TRACE ON;

  -- cExiste = 1 Cliente Titular
  -- cExiste = 2 Cliente Prospecto Activo
  -- cExiste = 3 Cliente Prospecto Inactivo
  -- cExiste = 4 Tipo de Cliente incorrecto

  SELECT tipo_cliente INTO cTipoCliente FROM si_cliente WHERE numcte = cNumcte;

	IF cTipoCliente = "1" THEN
		LET cExiste = 1;
	ELIF cTipoCliente = "2" THEN
		IF EXISTS (	select 1 from bdicred:sd_tarjeta tar, bdicred:sd_maecred cred
				where cred.numcte = cNumcte
				and cred.num_credito = tar.num_credito
				and tar.tipo_tarjeta = 'A'
				and tar.status_tar = 'A') THEN
			LET cExiste = 2;
		ELIF EXISTS (SELECT 1 FROM bdicheq:sc_firmantes WHERE numcte = cNumcte) THEN
			LET cExiste = 2;
		ELIF EXISTS(SELECT 1 FROM bdinvers:sv_cotitular WHERE numcte = cNumcte) THEN
			LET cExiste = 2;
		--ELIF EXISTS (SELECT 1 FROM bdinteg:si_adiccoppel WHERE numcte = cNumcte AND secuencia <> 1) THEN
			--LET cExiste = 2;
		ELSE
			LET cExiste = 3;
		END IF;
	ELSE
		LET cExiste = 4;
	END IF;

  RETURN  cCodret,cExiste;

  END
--*************************************************************************
--| Procedimiento   : sp_ValidaClienteProspectoSPL
--| Versión         : 1.0
--| Creado por      : Martha Aguirre
--| Fecha creacion  : Mayo de 2009
--| Descripción     : Realiza una busqueda para validar la existencia
--|                   de un cliente activo y adicional.
--| Modificado por: Martha Aguirre
--| Modificación: Se comenta la consulta a la tabla de adicionales coppel
--1 Fecha Modificación: 01 Abril de 2009
--*************************************************************************
END PROCEDURE                                              
;