# Site configuration for AWS Amazon Linux

## Bootstrapping

If conda and spack are not already installed you can install them and their
dependencies with

```bash
# Configure where environments are installed
export NGMOENVS_BASEDIR=~/ngmo-envs

./site/aws/bootstrap.sh
```

This will print out the path to an activate script which you should source before installing environments, e.g.

```bash
source ~/ngmo-envs/bin/activate
```

## SVN Credentials

Store SVN credentials by running

```bash
conda env create -n svn subversion
conda activate svn

sudo dnf install pinentry-tty

mkdir -p ~/.gnupg
echo "pinentry-program /usr/bin/pinentry-tty" >> ~/.gnupg/gpg-agent.conf

gpg-connect-agent reloadagent /bye

export GPG_TTY=$(tty)

cat >> ~/.subversion/config <<EOF
[auth]
store-passwords = yes
EOF

svn info https://code.metoffice.gov.uk/svn/lfric
```

## Installing Environments

Install an environment from the `environments/` directory with

```bash
source ~/ngmo-envs/bin/activate

# Configure the compiler and MPI to use
export NGMOENVS_COMPILER=gcc
export NGMOENVS_MPI=openmpi@4

# The environment to install
export ENV=lfric

./site/aws/install.sh $ENV
```


