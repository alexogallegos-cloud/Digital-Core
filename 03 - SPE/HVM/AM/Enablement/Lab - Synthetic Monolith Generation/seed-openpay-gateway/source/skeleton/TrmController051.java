package com.openpay.dashboard.terminals;

// ================================================================
//  SYSTEM    : openpay-gateway   (synthetic · graph-as-data)
//  COMPONENT : Dashboard (WAR)      DOMAIN : terminals
//  LAYER     : WEB                  ACCESS : update (writes)
//  FAN-IN    : 0    FAN-OUT : 3    LOC approx: 112
//  NOTE      : generated skeleton; imports = DTO coupling, fields = graph edges.
//              The real business logic is synthetic.
// ================================================================
import com.openpay.dto.AuditContext;
import com.openpay.dto.ResponseEnvelope;
import com.openpay.dto.TransactionDTO;
import com.openpay.dto.TrmRequest;

@RestController
public class TrmController051 {

    // Collaborators (match the graph call edges):
    private final TrmService029 trmService029;
    private final TrmService103 trmService103;
    private final TrmService221 trmService221;

    public ResponseEnvelope handle(AuditContext ctx) {
        jdbcWriteGateway.persist(ctx);   // writes to the system of record
    }
}
