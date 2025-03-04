# AIFS use environment

Contains all dependencies required for preparation of ICs, running and postprocessing with AIFS

## Testing the environment

Try a manual install and test run of AIFS

```bash
# Make sure the environment is on your PATH
export PATH=$NGMOENVS_BASEDIR/envs/aifs/main/bin:$PATH

# Check out the AIFS script
git clone https://git.nci.org.au/bom/cm/aifs_scripts.git 

# With resources requested
# IC preparation
envrun ./prepare_ICs.py opendata_aifs.yaml
# Model running
envrun ./run_AIFS.py opendata_aifs.yaml
# Postprocessing
envrun ./postprocess_forecast.py opendata_aifs.yaml
```
