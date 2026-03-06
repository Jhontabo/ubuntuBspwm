#!/usr/bin/env python3
# coding: utf-8

import re
import subprocess
import sys


if len(sys.argv) != 2:
    print(f"\n[!] Uso: {sys.argv[0]} <direccion-ip>\n")
    sys.exit(1)


def get_ttl(ip_address: str) -> int:
    proc = subprocess.run(
        ["/usr/bin/ping", "-c", "1", ip_address],
        capture_output=True,
        text=True,
        check=False,
    )
    output = proc.stdout + proc.stderr

    match = re.search(r"ttl[=|:](\\d+)", output, re.IGNORECASE)
    if not match:
        raise RuntimeError("No se pudo obtener TTL. Verifica conectividad/IP.")

    return int(match.group(1))


def detect_os(ttl: int) -> str:
    if 0 <= ttl <= 64:
        return "Linux"
    if 65 <= ttl <= 128:
        return "Windows"
    return "Not Found"


if __name__ == "__main__":
    ip_address = sys.argv[1]
    try:
        ttl_value = get_ttl(ip_address)
    except RuntimeError as exc:
        print(f"\n[!] {exc}\n")
        sys.exit(1)

    os_name = detect_os(ttl_value)
    print(f"\n\t{ip_address} (ttl -> {ttl_value}): {os_name}")
