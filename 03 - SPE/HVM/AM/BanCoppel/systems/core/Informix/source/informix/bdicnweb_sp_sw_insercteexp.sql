CREATE PROCEDURE "informix".sp_sw_insercteexp(pidresulcte integer,pidbusqueda integer,pidoficio integer)
	returning  char(5) as CodRet

        define cCodRet char(5);
        define iSqlErr int;

        let cCodRet = '00000';
        let iSqlErr = 0;

        begin
        
            on exception set iSqlErr
                if iSqlErr <> 0 then
                    let cCodRet = iSqlErr;
                    return cCodRet;
                end if;
            end exception;


        end;
end procedure;