package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 1    FAN-OUT : 5    LOC approx: 444
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;
import com.openpay.dto.TrmResponse;

@Service
public class TrmService233 {

    // Collaborators (match the graph call edges):
    private final JdbcWriteGateway jdbcWriteGateway;
    private final JsonUtils jsonUtils;
    private final NotificationService notificationService;
    private final TrmRepository006 trmRepository006;
    private final TrmRepository070 trmRepository070;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
