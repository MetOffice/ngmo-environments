# LFRic build environment

Contains all dependencies required to build and run LFRic

## Testing the environment

Try a manual install and test run of LFRic

```bash
svn checkout https://code.metoffice.gov.uk/svn/lfric_apps/main/trunk lfric_apps

# App to build from lfric_apps/applications
APP=gravity_wave

# Build the app
cd lfric_apps/applications/$APP
envrun make

# Run the app example
cd example
envrun mpirun -n  1 ../bin/$APP configuration.nml
```
