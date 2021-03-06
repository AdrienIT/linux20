#!/bin/bash

# Ajout des hosts
hosts="
192.168.2.21  node1.tp2.b2
192.168.2.22  node2.tp2.b2
"
echo -e "${hosts}" > /etc/hosts

# Ajout route vers node1
ip route add 192.168.2.0/24 via 192.168.2.22 dev eth1


# Ajout de mon cert vers le ca-trust permettant l'acces en https au site1
echo -e "-----BEGIN CERTIFICATE-----
MIIDszCCApugAwIBAgIUWfg5//zbvbjxcX0CVYdWwtMb44QwDQYJKoZIhvcNAQEL
BQAwaTELMAkGA1UEBhMCRlIxEjAQBgNVBAgMCUFxdWl0YWluZTERMA8GA1UEBwwI
Qm9yZGVhdXgxDTALBgNVBAoMBFlub3YxDTALBgNVBAsMBEwzM1QxFTATBgNVBAMM
DG5vZGUxLnRwMi5iMjAeFw0yMDEwMDQxNDA5MzdaFw0yMTEwMDQxNDA5MzdaMGkx
CzAJBgNVBAYTAkZSMRIwEAYDVQQIDAlBcXVpdGFpbmUxETAPBgNVBAcMCEJvcmRl
YXV4MQ0wCwYDVQQKDARZbm92MQ0wCwYDVQQLDARMMzNUMRUwEwYDVQQDDAxub2Rl
MS50cDIuYjIwggEiMA0GCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQDN33DDmYRY
5ngYl6srN3uZHMOCQFFKFafy6uVYkQMlA8RA8oSjK565x+k3gtKCNhWX+MWDbBqb
4A8NOSahj08RIuSLnSNCCvp8O15BBHLqm46lo+XKMepQ+URffZgm7sziSEKCUIhP
jAA1G5MXAWi2a9cOoMQuKTXQNeieFQnWcJdlHBuE9b9WC/YoYMtY45dFNgOeaIsm
AKqsYtbNQF1TrjK67StJfD3y2bsShiqrqv8zCHXotOdSbphHvxkL3WOf/aHgsJhT
YBK8z7LLlviC+MvYdBK6J6HCavAQAzyU7wi6AKyUyJIm8oHHdIge7fEHehaFV95r
YKg1y+OqLy8ZAgMBAAGjUzBRMB0GA1UdDgQWBBRx6RciWdoTPaDFAtiD2/f11ynD
mTAfBgNVHSMEGDAWgBRx6RciWdoTPaDFAtiD2/f11ynDmTAPBgNVHRMBAf8EBTAD
AQH/MA0GCSqGSIb3DQEBCwUAA4IBAQCZLT+nONrhyMVxBOHQCywu3O02Qr2oLHzz
cGzQyCAaITquOP15hBXMhFJ1D+1iZ0igCXsJkpT5DbzlkAjkFmov8HM+AOGrzSoA
6Dbr5VobV0lmgwB92MrtnqVGeFaaSfrGsnXRbcFRVPHNNj7U6tvcGysMSlRqKgUZ
wtaY+9b9jz7Ln4fiIPxYFlYc2Ty70Mwq0wR9En95lBMgT5T+1YIoGyCbpqBBTjTy
9xY7XAXoHvXG5F3n/w3f6rqbteyntLHeSfmFw1NmwJgNTfDGj+kE93iHJW3AI7QY
6wTHg8UCtQGhuW6XiBK2I+PQuc6bzZ8eWMEIYfP1Pe7d2b7hCtKT
-----END CERTIFICATE-----" > /etc/pki/ca-trust/source/anchors/node1.tp2.b2.crt

# reload des ca-trust
update-ca-trust