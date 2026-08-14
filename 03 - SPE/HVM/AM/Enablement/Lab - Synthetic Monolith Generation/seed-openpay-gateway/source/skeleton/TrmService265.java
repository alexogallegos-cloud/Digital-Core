package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 7    LOC approx: 223
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;

@Service
public class TrmService265 {

    // Collaborators (match the graph call edges):
    private final ChnService080 chnService080;
    private final ChnService218 chnService218;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final StringUtils stringUtils;
    private final TrmRepository006 trmRepository006;
    private final TrmRepository017 trmRepository017;
    private final TrmService148 trmService148;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
