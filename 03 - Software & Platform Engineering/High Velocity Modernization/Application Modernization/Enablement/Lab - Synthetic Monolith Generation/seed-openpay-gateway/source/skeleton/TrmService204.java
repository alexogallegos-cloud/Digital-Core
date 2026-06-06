package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 1    FAN-OUT : 7    LOC approx: 235
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;
import com.openpay.dto.TrmEntity;
import com.openpay.dto.TrmRequest;

@Service
public class TrmService204 {

    // Collaborators (match the graph call edges):
    private final DocumentService documentService;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final SecService196 secService196;
    private final StringUtils stringUtils;
    private final TrmRepository006 trmRepository006;
    private final TrmRepository070 trmRepository070;
    private final TrmService029 trmService029;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
