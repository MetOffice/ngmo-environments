#!/bin/bash

docker build --tag ngmoenvs-baseimage:latest .

apptainer build ngmoenvs-baseimage.sif docker-daemon:ngmoenvs-baseimage:latest
