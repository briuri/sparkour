#!/bin/bash
#
# Starts the webapp.
systemctl daemon-reload
systemctl enable sparkour.service
systemctl restart sparkour.service