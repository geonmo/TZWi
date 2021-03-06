#!/bin/bash

if [ $# != 4 ]; then
    echo $#
    echo "Usage: ./run.sh MuEl MC2016.WW.txt 10 5 ## process WW sample assuming emu channel, split by 10 files and run 5th section"
    echo "Usage: ./run.sh ElEl MC2017.TT_powheg.txt 1 0 ## process TTbar sample assuming eechannel, one file per each section and run 0th one."
    echo "Usage: ./run.sh MuMu Run2016B.DoubleMuon 1 0"
    exit 1
fi

eval `scram runtime -sh`

CHANNEL=$1
FILELIST=$2
MAXFILES=$3
JOBNUMBER=$4

[ $CHANNEL == 'ElMu' ] && CHANNEL='MuEl'

DATATYPE0=`basename $FILELIST | sed -e 's;.txt;;g' | cut -d. -f1`
DATASET=`basename $FILELIST | sed -e 's;.txt;;g' | cut -d. -f2`
DATATYPE=$DATATYPE0
if [ ${DATATYPE::3} == "Run" ]; then
  DATATYPE=${DATATYPE::7} ## This gives Run2018A -> Run2018
  
  [ ${DATATYPE::8} == "Run2017B" ] || DATATYPE=Run2017CF
fi

FILENAMES=$(cat $FILELIST | xargs -n$MAXFILES | sed -n "$(($JOBNUMBER+1)) p" | sed 's;/xrootd/;root://cms-xrdr.sdfarm.kr//xrd/;g')

ARGS=""
ARGS="$ARGS -I TZWi.TopAnalysis.ttbarDoubleLepton ttbar_${CHANNEL}"
ARGS="$ARGS -I TZWi.TopAnalysis.ttbarDoubleLeptonHLT hlt_${CHANNEL}_${DATATYPE}"
ARGS="$ARGS -I TZWi.TopAnalysis.ttbarDoubleLeptonHLT flags_${DATATYPE}"
ARGS="$ARGS -I TZWi.TopAnalysis.ttbarDoubleLeptonCutFlow cutFlow_${CHANNEL}"

OUTPATH=ntuple/reco
CMD="nano_postproc.py --friend"
[ ! -d $OUTPATH ] && mkdir -p $OUTPATH
if [ ${DATATYPE::2} == "MC" ]; then
    ARGS="$ARGS -I PhysicsTools.NanoAODTools.postprocessing.modules.common.lepSFProducer lepSF"
    ARGS="$ARGS -I PhysicsTools.NanoAODTools.postprocessing.modules.common.puWeightProducer puWeight"
fi
echo $CMD $ARGS $OUTPATH $FILENAMES
$CMD $ARGS $OUTPATH $FILENAMES

