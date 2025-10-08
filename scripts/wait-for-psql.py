#!/usr/bin/env python3
import time
import argparse
import psycopg2
from psycopg2 import OperationalError

def parse_args():
    parser = argparse.ArgumentParser(description="Wait for PostgreSQL to be ready.")
    parser.add_argument("--db_host", required=True)
    parser.add_argument("--db_port", required=True)
    parser.add_argument("--db_user", required=True)
    parser.add_argument("--db_password", required=True)
    parser.add_argument("--timeout", type=int, default=30)
    return parser.parse_args()

def wait_for_postgres(args):
    deadline = time.time() + args.timeout
    while time.time() < deadline:
        try:
            conn = psycopg2.connect(
                host=args.db_host,
                port=args.db_port,
                user=args.db_user,
                password=args.db_password,
                dbname="postgres"
            )
            conn.close()
            print("PostgreSQL está disponible.")
            return
        except OperationalError:
            print("Esperando conexión con PostgreSQL...")
            time.sleep(1)
    print("Timeout esperando a PostgreSQL.")
    exit(1)

if __name__ == "__main__":
    args = parse_args()
    wait_for_postgres(args)
