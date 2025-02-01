## Install Conda
```commandline
# Miniconda (recommended for minimal setup)
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
bash Miniconda3-latest-Linux-x86_64.sh
# Miniconda3 will now be installed into this location:
# /home/mike/miniconda3

# Anaconda (larger with more pre-installed packages):
wget https://repo.anaconda.com/archive/Anaconda3-latest-Linux-x86_64.sh
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh.sha256
sha256sum Miniconda3-latest-Linux-x86_64.sh
bash Anaconda3-latest-Linux-x86_64.sh

source ~/.bashrc
conda --version

# Ensure Conda is up-to-date
conda update -n base -c defaults conda

# Install Jupyter (Optional)
conda install -c conda-forge jupyterlab

```

## Create Conda Env
`<your-environment-name>` comes from `environment.yaml`
```bash
cd /path/to/your/environment.yaml
conda env create -f environment.yaml
conda activate <your-environment-name>
```

## Add the Conda Environment to Jupyter
Install the ipykernel package in the Conda environment:
```bash
conda install -c anaconda ipykernel
```
Add the environment to Jupyter:
```bash
python -m ipykernel install --user --name=<your-environment-name> --display-name "Python (<your-environment-name>)"
```

## Verify in Jupyter
```bash
jupyter notebook
jupyter lab
```

## (Optional) Clean Up
```bash
# List installed kernels
jupyter kernelspec list

# Remove a kernel
jupyter kernelspec uninstall <kernel-name>
```


## Disable auto-activation of the base environment:
```bash
conda config --set auto_activate_base false

# Re-enable auto activate
conda config --set auto_activate_base true

# Re-activate if needed
conda env list
conda activate base
```