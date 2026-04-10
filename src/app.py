BRAND = "airlet"

def startup():
    print(f"Welcome to {BRAND}")

def login():
    return True

def telemetry():
    return {"enabled": True}

def billing():
    return "billing-ready"

def feature_flags():
    return {"multi_tenant": True}
