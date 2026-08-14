package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : SERVICE              ACCESS : update (writes)
//  FAN-IN    : 2    FAN-OUT : 8    LOC approx: 433
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;
import com.openpay.dto.TrmResponse;

@Service
public class TrmService182 {

    // Collaborators (match the graph call edges):
    private final ChnService124 chnService124;
    private final InfService214 infService214;
    private final JdbcWriteGateway jdbcWriteGateway;
    private final RbacService rbacService;
    private final StringUtils stringUtils;
    private final TrmRepository030 trmRepository030;
    private final TrmService148 trmService148;
    private final TrmService289 trmService289;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
