
with open("build-brain.py", "r", encoding="utf-8") as f:
    content = f.read()

changes = 0

# SOC platform
old = ""id": "SOC", "name": "Sistema Operativo Central", "acronym": "SOC",
        "type": "core-app", "provider": "TASF", "platform": "Por confirmar","
new = ""id": "SOC", "name": "Sistema Operativo Central", "acronym": "SOC",
        "type": "core-app", "provider": "TASF", "platform": "Linux RedHat 7.2 / JBoss EAP 7.0 / Postgres 9.4.11 / ZK8","
if old in content:
    content = content.replace(old, new, 1)
    changes += 1
    print("SOC platform: OK")
else:
    print("SOC platform: NOT FOUND")

with open("build-brain.py", "w", encoding="utf-8") as f:
    f.write(content)
print(f"Total changes: {changes}")
