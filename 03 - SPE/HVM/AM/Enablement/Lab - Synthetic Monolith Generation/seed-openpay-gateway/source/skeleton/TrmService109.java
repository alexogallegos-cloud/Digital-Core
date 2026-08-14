package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : SERVICE              ACCESS : inquiry (read-only)
//  FAN-IN    : 1    FAN-OUT : 5    LOC approx: 500
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;
import com.openpay.dto.TrmEntity;
import com.openpay.dto.TrmRequest;
import com.openpay.dto.TrmResponse;

@Service
public class TrmService109 {

    // Collaborators (match the graph call edges):
    private final ConfigService configService;
    private final JdbcReadGateway jdbcReadGateway;
    private final StringUtils stringUtils;
    private final TrmRepository028 trmRepository028;
    private final TrmService278 trmService278;

    public ResponseEnvelope handle(AuditContext ctx) {
        return jdbcReadGateway.query(ctx);   // inquiry only
    }
}
