package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 1    FAN-OUT : 6    LOC approx: 521
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TrmRequest;

@Service
public class TrmService280 {

    // Collaborators (match the graph call edges):
    private final JdbcReadGateway jdbcReadGateway;
    private final JsonUtils jsonUtils;
    private final SecService169 secService169;
    private final TrmRepository028 trmRepository028;
    private final TrmService037 trmService037;
    private final TrmService106 trmService106;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
