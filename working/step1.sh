#!/bin/bash

TRIVY_USERNAME=" " TRIVY_PASSWORD=" " trivy image -f json -o "step1OUT/$3/$2.json" $1 --scanners vuln
exit 0