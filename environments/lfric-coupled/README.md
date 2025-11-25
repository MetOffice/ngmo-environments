# LFRic build environment

Contains all dependencies required to build and run LFRic coupled with NEMO

## Testing the environment

Try a manual install and test run of LFRic

```bash
# Make sure the environment is on your PATH
export PATH=$NGMOENVS_BASEDIR/envs/lfric-coupled/bin:$PATH

# Check out the LFRic source
svn checkout https://code.metoffice.gov.uk/svn/lfric_apps/main/trunk lfric_apps

# App to build from lfric_apps/applications
APP=gravity_wave

# Build the app
envrun lfric_apps/build/local_build.py --application $APP

# Run the app example
cd lfric_apps/applications/$APP/example
envrun mpirun -n  1 ../bin/$APP configuration.nml
```
