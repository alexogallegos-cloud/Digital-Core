"""Prueba funcional de B39: el metodo tiene que negar lo que la regla niega."""
import importlib.util, sqlite3, sys, os, tempfile

ASSET = sys.argv[1]
db_path = os.path.join(tempfile.mkdtemp(), "brain.db")
con = sqlite3.connect(db_path)
con.executescript(open(os.path.join(ASSET, "templates", "schema.sql"), encoding="utf-8").read())
con.executemany(
    "INSERT INTO action_catalog (id, tier, action_type, itom_domain, description, "
    "authorized_level, never_below_a3, accountable_role, tool, creates_only, authorized_by) "
    "VALUES (?,?,?,?,?,?,?,?,?,?,?)",
    [
        ("ACT-ticket-itsm", "gold", "Abrir ticket en ITSM", "Technology Operations",
         "Levanta un ticket con campos preestablecidos", "A2", 0, "STK-incident-manager",
         "ServiceNow", 1, "STK-change-manager"),
        ("ACT-runbook-prod", "gold", "Ejecutar runbook de remediacion en produccion",
         "Technology Operations", "Corre un runbook contra produccion", "A3", 1,
         "STK-change-manager", "Ansible", 0, "STK-change-manager"),
        ("ACT-sin-dueno", "gold", "Accion sin rol accountable", "IT Management",
         "Existe en catalogo pero nadie responde por ella", "A2", 0, None, None, 1, None),
    ])
con.commit()
con.close()

spec = importlib.util.spec_from_file_location("bt", os.path.join(ASSET, "templates", "brain.py"))
m = importlib.util.module_from_spec(spec)
spec.loader.exec_module(m)
Brain = next(getattr(m, n) for n in dir(m)
             if isinstance(getattr(m, n), type) and hasattr(getattr(m, n), "evalua_accion"))
b = Brain(__import__("pathlib").Path(db_path))

casos = [
    ("tipo que no existe en el catalogo",
     ("ACT-inventada", "gold", None), False, None),
    ("A2 con conocimiento gold",
     ("ACT-ticket-itsm", "gold", None), True, "A2"),
    ("A2 con conocimiento silver, debe caer a A1",
     ("ACT-ticket-itsm", "silver", None), True, "A1"),
    ("A3 sin aprobador declarado",
     ("ACT-runbook-prod", "gold", None), False, "A3"),
    ("A3 con aprobador",
     ("ACT-runbook-prod", "gold", "STK-change-manager"), True, "A3"),
    ("tipo nunca-bajo-A3 con silver, techo A1",
     ("ACT-runbook-prod", "silver", "STK-change-manager"), True, "A1"),
    ("catalogado A2 pero sin rol accountable",
     ("ACT-sin-dueno", "gold", None), False, "A2"),
]
fallos = 0
print("=== evalua_accion ===")
for nombre, (cid, tier, apr), esp_perm, esp_niv in casos:
    r = b.evalua_accion(cid, tier, apr)
    ok = r["permitido"] == esp_perm and r["nivel"] == esp_niv
    fallos += 0 if ok else 1
    print(f"  [{'ok ' if ok else 'FALLA'}] {nombre}")
    print(f"          permitido={r['permitido']} nivel={r['nivel']}  {r['razon'][:78]}")

print("\n=== registrar_accion: no deja escribir por encima del nivel permitido ===")
r = b.registrar_accion("ACT-ticket-itsm", "intento A2 con silver", level="A2",
                       knowledge_tier="silver")
ok = r["registrado"] is False
fallos += 0 if ok else 1
print(f"  [{'ok ' if ok else 'FALLA'}] rechazada: {r['veredicto']['razon'][:80]}")

r = b.registrar_accion("ACT-ticket-itsm", "ticket de capacidad de Caja", level="A2",
                       knowledge_tier="gold", knowledge_refs=[101, 102], outcome="logrado")
ok = r["registrado"] is True
fallos += 0 if ok else 1
print(f"  [{'ok ' if ok else 'FALLA'}] aceptada en A2 con gold")

print("\n=== autonomia ===")
a = b.autonomia()
for t in a["tipos"]:
    print(f"  {t['catalog_id']:<20} {t['nivel']}  ejec={t['ejecuciones']} "
          f"inc={t['incidentes']}  {t['veredicto']}")
print("  acciones sin catalogo:", a["acciones_sin_catalogo"])

print(f"\n{'TODO EN VERDE' if not fallos else str(fallos) + ' FALLAS'}")
sys.exit(1 if fallos else 0)
