CREATE PROCEDURE "informix".sp_obtenerparametros_altaunica_web(pEmpresa CHAR(3), pSucursal CHAR(4))
    RETURNING CHAR(5), CHAR(1), CHAR(1), CHAR(1), CHAR(15), CHAR(15), CHAR(3), CHAR(3), CHAR(3), CHAR(1);

	DEFINE cCodRet CHAR(5);
	DEFINE iSqlErr INTEGER;	
	DEFINE sValor1 CHAR(100);
	DEFINE sValor2 CHAR(100);
	DEFINE sValor3 CHAR(100);
	DEFINE sValor4 CHAR(100);
	DEFINE sValor5 CHAR(100);
	DEFINE sValor6 CHAR(100);
	DEFINE sValor7 CHAR(100);
	DEFINE sValor8 CHAR(100);
	DEFINE sValor9 CHAR(100);

	LET cCodRet  = '00000';
	LET iSqlErr = 0;
	LET sValor1 = "";
	LET sValor2 = "";
	LET sValor3 = "";
	LET sValor4 = "";
	LET sValor5 = "";
	LET sValor6 = "";
	LET sValor7 = "";
	LET sValor8 = "";
	LET sValor9 = "";

	--------------------------------------------------------------------------
	-- Creado por Rodolfo Tortolero Varela 08/12/2010
	--SET DEBUG FILE TO "/tmp/sp_obtenerparametros_altaunica.out";
	--TRACE ON;
	--------------------------------------------------------------------------
                
	BEGIN
		ON EXCEPTION SET iSqlErr
				IF iSqlErr !=0 THEN
						LET cCodRet = iSqlErr;
						RETURN cCodRet, sValor1, sValor2, sValor3, sValor4, sValor5, sValor6, sValor7, sValor8, sValor9;
				END IF;
		END EXCEPTION;
		
		SET ISOLATION TO DIRTY READ;
		SET LOCK MODE TO WAIT 3;
				
		SELECT valor INTO sValor1 FROM bdinteg:si_param WHERE empresa = pEmpresa AND cod_param =  70; --FlagBancoppel
		SELECT valor INTO sValor2 FROM bdinteg:si_param WHERE empresa = pEmpresa AND cod_param =  62; --FlagCoppel
		SELECT valor INTO sValor3 FROM bdinteg:si_param WHERE empresa = pEmpresa AND cod_param =  63; --FlagSolicitudes
		SELECT valor INTO sValor4 FROM bdinteg:si_param WHERE empresa = pEmpresa AND cod_param =  64; --IPConsultaCoppel
		SELECT valor INTO sValor5 FROM bdinteg:si_param WHERE empresa = pEmpresa AND cod_param =  65; --PuertoCoppel
		SELECT valor INTO sValor6 FROM bdinteg:si_param WHERE empresa = pEmpresa AND cod_param =  66; --OffsetCoppel
		SELECT valor INTO sValor7 FROM bdinteg:si_param WHERE empresa = pEmpresa AND cod_param =  67; --TotalRegisCoppel
		SELECT valor INTO sValor8 FROM bdinteg:si_param WHERE empresa = pEmpresa AND cod_param =  68; --TotalRegisPaginaciÃ³n

		SELECT {+INDEX(bditarjcop:sucursalescajaunica idx_sucursalescajaunica)} ostelefonica INTO sValor9 FROM bditarjcop:sucursalescajaunica WHERE empresa = pEmpresa AND cvesucursal = pSucursal; --OSTelActiva/Desactiva

		RETURN cCodRet, sValor1, sValor2, sValor3, sValor4, sValor5, sValor6, sValor7, sValor8, sValor9;
	END
END PROCEDURE;