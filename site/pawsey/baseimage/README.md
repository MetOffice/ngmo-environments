NCI Apptainer base image
========================

Apptainer containers can't be built directly at NCI, this requires root
privileges. Instead we create a base image using Docker, then convert that base
image to apptainer format.

Environment containers are created as squashfs overlays on top of this base
image, these are inserted into the base image as part of the install process so
the end result is a single container file.
