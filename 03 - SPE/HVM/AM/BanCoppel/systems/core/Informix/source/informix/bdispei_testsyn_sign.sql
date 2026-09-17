CREATE FUNCTION "informix".testsyn_sign(mensaje CHAR(512) )
RETURNING LVARCHAR(512) as RetCode, SMALLINT as ret;

DEFINE RetCode LVARCHAR(512);
DEFINE l_CadSign LVARCHAR(512);
DEFINE l_Cad LVARCHAR(3000);
DEFINE ret SMALLINT;

LET l_Cad=mensaje;
LET RetCode ='';
LET ret=0;
--LET l_CadSign = '                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                ';
LET l_CadSign = space(512);
        EXECUTE function bdispei:syn_sign(l_Cad, l_CadSign,11) INTO ret;
        RETURN l_CadSign, ret;

END FUNCTION;