CREATE FUNCTION "informix".convert_to_date(dt int8)
RETURNING datetime year to second
WITH (NOT VARIANT)
define d_return date;

ON EXCEPTION
    begin
        let d_return = today + 1 units day;
        return d_return;
    end
end exception

let d_return = to_date(to_char(dt),"%Y%m%d%H%M%S");
return d_return;
END FUNCTION;