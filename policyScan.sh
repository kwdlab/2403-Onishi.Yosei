#!/bin/bash

trivy config -f json -o "dockerfile/step1OUT/$3/$2.json" $1
exit 0