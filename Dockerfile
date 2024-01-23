FROM continuumio/miniconda3:master

ENV CONDA_NO_PLUGINS=true

# Install base utilities
RUN apt-get update \
    && apt-get install -y build-essential  wget  libgl1 libomp5 git sudo cmake gcc software-properties-common libpython3-dev pybind11-dev libgl1-mesa-dev libglu1-mesa-dev cmake ninja-build  libqt5svg5-dev libqt5opengl5-dev qt5-default qttools5-dev qttools5-dev-tools libqt5websockets5-dev libtbb-dev libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libboost-program-options-dev libboost-thread-dev libeigen3-dev libcgal-dev libcgal-qt5-dev libgdal-dev libpcl-dev libdlib-dev libproj-dev libxerces-c-dev xvfb libjsoncpp-dev liblaszip-dev

RUN apt-get update -qq

RUN apt-get install -y qtbase5-dev qtchooser qt5-qmake qtbase5-dev-tools libqt5concurrent5 cmake pkg-config mesa-utils libglu1-mesa-dev freeglut3-dev mesa-common-dev libpython3-dev pybind11-dev libglew-dev libglfw3-dev libglm-dev libao-dev libmpg123-dev freeglut3-dev libqt5opengl5 freeglut3-dev

RUN apt-get update -qq \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*


RUN . /opt/conda/etc/profile.d/conda.sh && \
    conda activate && \
    conda create --name CloudComPy310 python=3.10 && \
    conda activate CloudComPy310 && \
    conda config --add channels defaults && \
    conda config --add channels conda-forge && \
    conda config --set channel_priority flexible && \
    conda install mamba && \
    mamba install -y "boost=1.74" "cgal=5.4" cmake ffmpeg "gdal=3.5" jupyterlab jupyter notebook laszip "matplotlib=3.5" "mysql=8.0" "numpy=1.22" "opencv=4.5" "openmp=8.0" "pcl=1.12" "pdal=2.4" "psutil=5.9" pybind11 "qhull=2020.2" "qt=5.15.4" "scipy=1.8" sphinx_rtd_theme spyder tbb tbb-devel "xerces-c=3.2" &&\
    conda clean --all --yes

WORKDIR /app/cloudcompy/workspace

COPY . .

COPY CloudComPy_Conda310_Linux64_20231219.tgz .

RUN mkdir -p /opt/cloudcompy && \
    # wget "https://www.simulation.openfields.fr/phocadownload/cloudcompy_conda39_linux64_20211208.tgz" && \
    # cp -r CloudComPy_Conda310_Linux64_20231219.tgz ./ && \
    tar -xvzf "CloudComPy_Conda310_Linux64_20231219.tgz" -C /opt/cloudcompy \
    rm "CloudComPy_Conda310_Linux64_20231219.tgz"

# WORKDIR /app/cloudcompy/workspace

RUN git clone https://github.com/tmontaigu/CloudCompare-PythonRuntime.git

SHELL ["/bin/bash", "-c"]
RUN . /opt/conda/etc/profile.d/conda.sh &&\
cd /opt/cloudcompy/CloudComPy310 &&\
. bin/condaCloud.sh activate CloudComPy310 &&\
python --version &&\
cp -r ./doc/samples /app/cloudcompy/notebooks &&\
cd /app/cloudcompy/workspace/CloudCompare-PythonRuntime &&\
    pip install wrapper/cccorelib && \
    pip install wrapper/pycc && \
    pip install git+https://github.com/Amsterdam-AI-Team/Urban_PointCloud_Processing.git#egg=upcp

WORKDIR /app/cloudcompy/notebooks

# RUN git clone https://github.com/Amsterdam-AI-Team/Urban_PointCloud_Processing.git

# # RUN echo '#!/bin/bash \
# . /opt/conda/etc/profile.d/conda.sh  \
# cd /opt/cloudcompy/CloudComPy310  \
# . bin/condaCloud.sh activate CloudComPy310  \
# export QT_QPA_PLATFORM=offscreen  \
# jupyter notebook --ip 0.0.0.0 --port 8889 --allow-root --no-browser --notebook-dir=/app/cloudcompy/notebooks '> entrypoint.sh && chmod +x entrypoint.sh

RUN echo '#!/bin/bash' > /entrypoint.sh \
    && echo ". /opt/conda/etc/profile.d/conda.sh" >> /entrypoint.sh \
    && echo "cd /opt/cloudcompy/CloudComPy310" >> /entrypoint.sh \
    && echo ". bin/condaCloud.sh activate CloudComPy310" >> /entrypoint.sh \
    && echo "export QT_QPA_PLATFORM=offscreen" >> /entrypoint.sh \
    && echo "jupyter notebook --ip 0.0.0.0 --port 8889 --allow-root --no-browser --notebook-dir=/app/cloudcompy/notebooks" >> /entrypoint.sh \
    && chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
# jupyter notebook --ip 0.0.0.0 --port 8889 --allow-root --no-browser --notebook-dir=/app/notebooks" > /entrypoint.sh && chmod +x /entrypoint.sh

EXPOSE 8888 8889 8899 80 443
