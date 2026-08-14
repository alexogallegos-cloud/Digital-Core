package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 3    FAN-OUT : 5    LOC approx: 396
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;
import com.openpay.dto.TrmRequest;
import com.openpay.dto.TrmResponse;

@Service
public class TrmService242 {

    // Collaborators (match the graph call edges):
    private final CmpService298 cmpService298;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final StringUtils stringUtils;
    private final TrmRepository017 trmRepository017;
    private final TrmRepository030 trmRepository030;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
