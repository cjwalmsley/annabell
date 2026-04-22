### on mac enter the apptainer environment with the following command:
limactl shell apptainer.

### To build apptainer image
apptainer build --build-arg ANNABELL_VERSION=annabell annabell.sif annabell.def
apptainer build --build-arg ANNABELL_VERSION=annabell_WMSize8500_ElActfStSize600k annabell_WMSize8500_ElActfStSize600k.sif annabell.def
apptainer build --build-arg ANNABELL_VERSION=annabell_WMSize5000_ElActfStSize480k annabell_WMSize5000_ElActfStSize480k.sif annabell.def

### start the annabell apptainer image in a shell
makes the apptainer directory available in the container for read/write access needs to be run from the directory where annabell.sif is located

apptainer shell -e --bind ./:/apptainer ~/PycharmProjects/Training-and-evaluating-cognitive-language-models/apptainer/ANNABELL_LATEST.sif



apptainer shell -e --bind ./:/apptainer ~/PycharmProjects/Training-and-evaluating-cognitive-language-models/apptainer/annabell.sif

### Start the annabell apptainer and runs the script my_script.sh located in the apptainer directory

apptainer exec annabell.sif bash /app/pre_train_annabell_squad_nyc.sh test_logfile.txt test_training_file.txt
output_weights.dat