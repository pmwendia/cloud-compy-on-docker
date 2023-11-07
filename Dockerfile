FROM continuumio/miniconda3:master

ENV CONDA_NO_PLUGINS=true

# Install base utilities
RUN apt-get update \
    && apt-get install -y build-essential \
    && apt-get install -y wget \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app/notebooks

RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate && \
    conda create --name CloudComPy310 python=3.10 && \
    conda activate CloudComPy310 && \
    conda config --add channels defaults && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority flexible && \
    conda install mamba && \
    mamba install "boost=1.74" "cgal=5.4" cmake ffmpeg "gdal=3.5" jupyterlab jupyter notebook laszip "matplotlib=3.5" "mysql=8.0" "numpy=1.22" "opencv=4.5" "openmp=8.0" "pcl=1.12" "pdal=2.4" "psutil=5.9" pybind11 "qhull=2020.2" "qt=5.15.4" "scipy=1.8" sphinx_rtd_theme spyder tbb tbb-devel "xerces-c=3.2" &&\
    conda clean --all --yes


RUN mkdir -p /opt/cloudcompy && \
    # wget "https://www.simulation.openfields.fr/phocadownload/cloudcompy_conda39_linux64_20211208.tgz" && \
    cp . ./ && \
    tar -xvzf "CloudComPy_Conda310_Linux64_20231026.tgz" -C /opt/cloudcompy && \
    rm "CloudComPy_Conda310_Linux64_20231026.tgz"

RUN apt-get update && apt-get install -y libgl1 libomp5 
RUN apt-get update && apt install -y git sudo cmake gcc software-properties-common libpython3-dev pybind11-dev libgl1-mesa-dev libglu1-mesa-dev 

RUN echo "#!/bin/bash\n\
. /opt/conda/etc/profile.d/conda.sh\n\
cd /opt/cloudcompy/CloudComPy310\n\
. bin/condaCloud.sh activate CloudComPy301\n\
export QT_QPA_PLATFORM=offscreen\n\
cd /opt/cloudcompy/CloudComPy39/doc/PythonAPI_test\n\
ctest" > /entrypoint.sh && chmod +x /entrypoint.sh

RUN git clone https://github.com/tmontaigu/CloudCompare-PythonPlugin.git

ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 8888 80 443